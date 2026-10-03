#!/usr/bin/env python3
"""Root-run retrospective accounting and static complexity; never execute targets."""
import argparse,datetime,hashlib,json,re,subprocess
from pathlib import Path

def identity(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def stats(b):
 t=b.decode();ls=t.splitlines();return dict(physicalLines=len(ls),nonblankLines=sum(bool(x.strip()) for x in ls),bytes=len(b),**{k:len(re.findall('^'+v+r'\b',t,re.M)) for k,v in [('defs','def'),('laws','law'),('types','type')]})
def union(intervals):
 merged=[]
 for a,b in sorted(intervals):
  if not merged or a>merged[-1][1]:merged.append([a,b])
  else:merged[-1][1]=max(b,merged[-1][1])
 return merged

def category(row):
 s=' '.join(row.get('command',[])).lower();label=row.get('label','').lower()
 if any(x in s for x in ['compiler-cost','compiler_cost','compile-cost']):return 'compiler-request sampling'
 if re.fullmatch(r'checked[0-9]+(?:-build)?',label) or any(x in s for x in ['build-checked','checked-build','checked_build','development/build','bootstrap/build','b1-build']):return 'checked build'
 if any(x in s for x in ['programs/prepare.py','emit-worker.mjs']):return 'checked acquisition'
 if any(x in s for x in ['programs/run.py','compare.py','screen.py']):return 'generated-program timing'
 if 'profile' in s or 'profile' in label:return 'profiling'
 if any(x in s or x in label for x in ['controls','oracle','probe','conformance','frontend','gate','audit','verify']):return 'controls and verification'
 if any(x in s or x in label for x in ['derive','freeze','preserve','snapshot','preflight','source-count','account']):return 'derivation, preservation and accounting'
 return 'other recorded work'

def source_counts(repo,commit):
 def historical(name):return subprocess.check_output(['git','show',commit+':selfhost/'+name],cwd=repo)
 old_manifest=historical('src/compiler.json');current_manifest=repo/'selfhost/src/compiler.json'
 result={}
 for role,manifest,read in [('baseline',old_manifest,historical),('current',current_manifest.read_bytes(),lambda n:(repo/'selfhost'/n).read_bytes())]:
  names=json.loads(manifest)['modules'];assert names and len(names)==len(set(names));rows=[]
  for name in names:
   assert name.startswith('src/') and '..' not in Path(name).parts
   b=read(name);rows.append(dict(name=name,sha256=hashlib.sha256(b).hexdigest(),counts=stats(b)))
  counts={k:sum(r['counts'][k] for r in rows) for k in rows[0]['counts']};counts['modules']=len(rows)
  result[role]=dict(manifestSha256=hashlib.sha256(manifest).hexdigest(),files=rows,counts=counts)
 expected=dict(physicalLines=18898,defs=2108,modules=70,types=71,laws=640)
 assert all(result['baseline']['counts'][k]==v for k,v in expected.items()),'Baseline differs from Phase41 maintained count definitions'
 result['delta']={k:result['current']['counts'][k]-v for k,v in result['baseline']['counts'].items()}
 result['runtime']={role:dict(sha256=hashlib.sha256(b).hexdigest(),counts=stats(b)) for role,b in [('baseline',historical('src/runtime.mjs')),('current',(repo/'selfhost/src/runtime.mjs').read_bytes())]}
 result['baselineCommit']=subprocess.check_output(['git','rev-parse',commit],cwd=repo,text=True).strip()
 for row in result['current']['files']:assert hashlib.sha256((repo/'selfhost'/row['name']).read_bytes()).hexdigest()==row['sha256'],'Source changed during accounting'
 assert hashlib.sha256(current_manifest.read_bytes()).hexdigest()==result['current']['manifestSha256']
 return result

def module_bytes(files):
 output=[]
 for file in files:
  manifest=json.loads(file.read_text());assert manifest.get('complete') is True
  roles={}
  for case in manifest['cases']:
   for role,row in case['modules'].items():
    data=roles.setdefault(role,{});key=row.get('path',row.get('file'));assert key and row['bytes']>0
    if key in data:assert data[key]==row,'Conflicting module identities'
    data[key]=row
  output.append(dict(manifest=identity(file),roles={role:dict(uniquePaths=len(rows),uniqueContents=len({r['sha256'] for r in rows.values()}),generatedBytes=sum(r['bytes'] for r in rows.values()),modules=list(rows.values())) for role,rows in roles.items()}))
 return output

def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--repo',type=Path,default=Path(__file__).resolve().parents[5]);p.add_argument('--ledger',type=Path,required=True);p.add_argument('--baseline',default='5ec82b3');p.add_argument('--manifest',type=Path,action='append',default=[]);p.add_argument('--category-map',type=Path);p.add_argument('--end',type=float,help='Explicit UTC epoch closure; otherwise last recorded ledger boundary');p.add_argument('--out',type=Path,required=True);a=p.parse_args();assert not a.out.exists()
 raw=[json.loads(l) for l in a.ledger.read_text().splitlines() if l.strip()];start=next(r['started'] for r in raw if r['kind']=='start');end=a.end if a.end is not None else max(r.get('finished',r.get('recorded',start)) for r in raw);assert end>=start
 overrides=json.loads(a.category_map.read_text()) if a.category_map else {};jobs=[];seen=set()
 for r in raw:
  if r.get('kind')!='event' or 'started' not in r or 'finished' not in r:continue
  key=(r['started'],r['finished'],r.get('label'));assert key not in seen,'Duplicate enclosing job';seen.add(key)
  receipt=r.get('receipt');receipt_checked=False
  if receipt:
   actual=identity(receipt['file']);assert actual['sha256']==receipt['sha256'];receipt_checked=True
  status='failed' if r.get('returncode') not in [0,None] else 'pass' if r.get('complete') is True and r.get('returncode')==0 else 'incomplete'
  jobs.append(dict(label=r.get('label'),started=r['started'],finished=r['finished'],startedUTC=datetime.datetime.fromtimestamp(r['started'],datetime.timezone.utc).isoformat(),finishedUTC=datetime.datetime.fromtimestamp(r['finished'],datetime.timezone.utc).isoformat(),durationSeconds=r['finished']-r['started'],category=overrides.get(r.get('label'),category(r)),status=status,returncode=r.get('returncode'),command=r.get('command'),receipt=receipt,receiptVerified=receipt_checked))
 jobs.sort(key=lambda r:(r['started'],r['finished']));intervals=[(max(start,r['started']),min(end,r['finished'])) for r in jobs if min(end,r['finished'])>=max(start,r['started'])];merged=union(intervals);covered=sum(b-a for a,b in merged);categories={}
 for job in jobs:
  row=categories.setdefault(job['category'],dict(jobs=0,failed=0,incomplete=0,summedSeconds=0,intervals=[]));row['jobs']+=1;row['failed']+=job['status']=='failed';row['incomplete']+=job['status']=='incomplete';row['summedSeconds']+=job['durationSeconds'];row['intervals'].append([job['started'],job['finished']])
 for row in categories.values():row['unionSeconds']=sum(b-a for a,b in union(row.pop('intervals')))
 report=dict(kind='phase42-retrospective-accounting',complete=True,producer=identity(__file__),ledger=identity(a.ledger),started=start,finished=end,closureBasis='explicit epoch' if a.end is not None else 'last recorded ledger boundary; not a claim of campaign closure',campaignElapsedSeconds=end-start,jobSummedSeconds=sum(r['durationSeconds'] for r in jobs),jobUnionSeconds=covered,unclassifiedSeconds=end-start-covered,overlapSeconds=sum(b-a for a,b in intervals)-covered,failedJobs=sum(r['status']=='failed' for r in jobs),incompleteJobs=sum(r['status']=='incomplete' for r in jobs),categories=categories,mergedIntervals=merged,jobs=jobs,sourceComplexity=source_counts(a.repo.resolve(),a.baseline),generatedJS=module_bytes(a.manifest),scope='Enclosing recorded jobs only; nested intervals are not separately added. Category sums can overlap. Unclassified wall time is not idle time or model latency. Static canonical compiler counts use the maintained Phase32/40 definitions; generated program module bytes are separate from compiler/API size.')
 a.out.mkdir(parents=True);(a.out/'report.json').write_text(json.dumps(report,indent=2)+'\n');lines=['# Phase42 elapsed-time and complexity account','',report['scope'],'',f"Campaign elapsed: {end-start:.3f}s; recorded union: {covered:.3f}s; unclassified: {end-start-covered:.3f}s.",f"Jobs: {len(jobs)}; failures: {report['failedJobs']}; incomplete: {report['incompleteJobs']}.",'','| Category | Jobs | Failures | Summed seconds | Union seconds |','|---|---:|---:|---:|---:|']
 for name,row in categories.items():lines.append(f"| {name} | {row['jobs']} | {row['failed']} | {row['summedSeconds']:.3f} | {row['unionSeconds']:.3f} |")
 lines+=['','| Count | Phase41 baseline | Current | Delta |','|---|---:|---:|---:|']
 c=report['sourceComplexity']
 for k,v in c['baseline']['counts'].items():lines.append(f"| {k} | {v} | {c['current']['counts'][k]} | {c['delta'][k]} |")
 lines+=['','| Started UTC | Job | Category | Status | Seconds |','|---|---|---|---|---:|']
 for row in jobs:lines.append(f"| {row['startedUTC']} | {row['label']} | {row['category']} | {row['status']} | {row['durationSeconds']:.3f} |")
 lines+=['','All module identities and complete job commands are retained in report.json.',''];(a.out/'report.md').write_text('\n'.join(lines));print(json.dumps({k:report[k] for k in ['campaignElapsedSeconds','jobUnionSeconds','unclassifiedSeconds','failedJobs','incompleteJobs']}))

if __name__=='__main__':main()
