#!/usr/bin/env python3
"""Read-only registered-source census and interim guarded-time receipt audit."""
import argparse, collections, datetime, hashlib, json, re, subprocess, time
from pathlib import Path

def sha(data): return hashlib.sha256(data).hexdigest()
def git(*args): return subprocess.check_output(['git', *args])
def metrics(data):
    text=data.decode(); lines=text.splitlines()
    return {'physical':len(lines),'code':sum(bool(l.strip()) and not l.lstrip().startswith('#') for l in lines),
            'definitions':len(re.findall(r'^def\s',text,re.M)), 'laws':len(re.findall(r'^law\s',text,re.M)),
            'types':len(re.findall(r'^type\s',text,re.M))}
def census(ref=None):
    manifest='selfhost/src/compiler.json'
    raw=git('show',f'{ref}:{manifest}') if ref else Path(manifest).read_bytes()
    modules=json.loads(raw)['modules'];rows=[]
    for module in modules:
        path='selfhost/'+module
        data=git('show',f'{ref}:{path}') if ref else Path(path).read_bytes()
        rows.append({'path':path,'sha256':sha(data),'bytes':len(data),**metrics(data)})
    total={k:sum(r[k] for r in rows) for k in metrics(b'')};total['modules']=len(rows)
    return {'ref':ref or 'working-tree','manifestSha256':sha(raw),'totals':total,'modules':rows}
def walk_guards(obj, path, guards, pending):
    if isinstance(obj,dict):
        if isinstance(obj.get('command'),list) and isinstance(obj.get('started'),(int,float)) and 'rssLimitBytes' in obj:
            key=(obj['started'],json.dumps(obj['command'],separators=(',',':')))
            if isinstance(obj.get('finished'),(int,float)) and 'wallSeconds' in obj:
                if key not in guards: guards[key]={'command':obj['command'],'started':obj['started'],'finished':obj['finished'],
                    'wallSeconds':obj['wallSeconds'],'returncode':obj.get('returncode'),'peakTreeRssBytes':obj.get('peakTreeRssBytes',0),'paths':[]}
                guards[key]['paths'].append(path)
            else: pending[key]=path
        for key,value in obj.items(): walk_guards(value,path+'#'+key,guards,pending)
    elif isinstance(obj,list):
        for i,value in enumerate(obj):walk_guards(value,path+'#'+str(i),guards,pending)
def occupancy(rows):
    end=None;total=0
    for r in sorted(rows,key=lambda x:(x['started'],-x['finished'])):
        begin=r['started'];stop=r['finished']
        if end is None or begin>end:total+=stop-begin;end=stop
        elif stop>end:total+=stop-end;end=stop
    return total
def category(row):
    command=' '.join(row['command'])
    if 'workflow.mjs run' in command:return 'checked-build/frontend validation'
    if 'query-plans' in command or 'capture-core' in command or 'query-batch' in command:return 'analysis/core queries'
    if 'execute.py' in command:return 'saved-binary comparisons'
    if 'native-build' in command or 'compare-native' in command or 'acquire-native' in command:return 'native acquisition/comparison orchestration'
    if 'probe' in command or 'profile' in command or '--cpu-prof' in command or 'compile-screen' in command:return 'compiler/profile probes'
    return 'other guarded commands'
def time_account(root, cutoff):
    guards={};pending={};files=0;parse_errors=[]
    for path in sorted(Path(root).rglob('*.json')):
        if path.stat().st_mtime>cutoff:continue
        try:obj=json.loads(path.read_text())
        except (ValueError,OSError) as e:parse_errors.append(str(path));continue
        files+=1;walk_guards(obj,str(path),guards,pending)
    rows=sorted(guards.values(),key=lambda r:(r['started'],-r['finished']))
    # Only maximal receipt intervals for category sums: nested supervisors are
    # not added to their children. Overall occupancy uses all interval union.
    maximal=[];end=-1
    for r in rows:
        if r['finished']>end+0.001:maximal.append(r);end=max(end,r['finished'])
    cats=collections.defaultdict(list)
    for row in maximal:cats[category(row)].append(row)
    return {'scope':'Interim receipt snapshot; includes failures; interval union avoids nested/duplicate guard double counting. Does not measure agent effort or quota.',
      'jsonFilesRead':files,'parseErrors':parse_errors,'uniqueGuardReceipts':len(rows),
      'guardOccupancySeconds':occupancy(rows),'sumGuardSecondsIncludingNested':sum(r['wallSeconds'] for r in rows),
      'firstTargetStart':min((r['started'] for r in rows),default=None),'lastTargetFinish':max((r['finished'] for r in rows),default=None),
      'firstToLastSpanSeconds':(max(r['finished'] for r in rows)-min(r['started'] for r in rows)) if rows else 0,
      'peakTreeRssBytes':max((r['peakTreeRssBytes'] for r in rows),default=0),
      'failedGuardReceipts':sum(r['returncode'] not in (0,None) for r in rows),
      'pendingReceiptFiles':[p for key,p in pending.items() if key not in guards],
      'categoryMaximalReceiptIntervals':{c:{'count':len(rs),'unionSeconds':occupancy(rs)} for c,rs in cats.items()},
      'receipts':rows}
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--baseline',default='32d159b');p.add_argument('--raw',default='selfhost/build/phase70');p.add_argument('--out',required=True);args=p.parse_args()
    cutoff=time.time();before=census();base=census(args.baseline);prior=census('f1655d0')
    bi={r['path']:r for r in base['modules']};changes=[]
    for row in before['modules']:
        old=bi.get(row['path']);delta={k:row[k]-(old[k] if old else 0) for k in metrics(b'')}
        if not old or old['sha256']!=row['sha256']:changes.append({'path':row['path'],'added':old is None,'deltas':delta})
    account=time_account(args.raw,cutoff);after=census()
    assert before==after,'live registered source changed during census'
    totaldelta={k:before['totals'][k]-base['totals'][k] for k in before['totals']}
    observers=[r for r in before['modules'] if '/observer-' in r['path']]
    out={'kind':'phase70-source-and-time-checkpoint-v1','recordedUtc':datetime.datetime.fromtimestamp(cutoff,datetime.timezone.utc).isoformat(),
      'headAtCapture':git('rev-parse','HEAD').decode().strip(),'baseline':base,'working':before,
      'phase69BaselineMatchesRelease':base['modules']==prior['modules'],'delta':totaldelta,'changedModules':changes,
      'observerTotals':{k:sum(r[k] for r in observers) for k in metrics(b'')},'observerModules':observers,
      'sourceUnchangedDuringCensus':True,'time':account}
    Path(args.out).write_text(json.dumps(out,indent=2)+'\n')
    print(json.dumps({k:out[k] for k in ['recordedUtc','headAtCapture','phase69BaselineMatchesRelease','delta','observerTotals','changedModules']}))
    print(json.dumps({k:v for k,v in account.items() if k!='receipts'}))
