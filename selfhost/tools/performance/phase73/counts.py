#!/usr/bin/env python3
"""Current/reference allocation-site and segment frequencies; never timings."""
import argparse,importlib.util,json,time,sys,re
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[4]
def mod(n,p):
 s=importlib.util.spec_from_file_location(n,ROOT/p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
S=mod('support','selfhost/tools/performance/programs/support.py')
R=mod('counters','selfhost/tools/performance/phase68/parity-survey/run.py')
O=mod('oracle73','selfhost/tools/performance/phase70/coverage/oracle-v2.py')
O6=mod('oracle6','selfhost/tools/performance/phase46/oracle.py')
read=lambda p:json.loads(Path(p).read_text())
p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=Path);p.add_argument('--cases',default='list-pipeline,expression,tape-observer,bst,tree,array-map');a=p.parse_args();a.out.mkdir(exist_ok=False)
rows={};pins=[S.identity(__file__),S.identity(R.__file__),S.identity(R.N.__file__)]
for role,paths in [('selfhost',['phase72/compiler02-coverage-rest','phase72/compiler02-coverage02','phase72/compiler02-native06']),('upstream',['phase70/coverage-baseline01','phase70/compiler02-coverage-baseline-holdouts01','phase67/native-baseline02','phase67/native-heldout-baseline02'])]:
 for path in paths:
  ar=read(ROOT/'selfhost/build'/path/'report.json');assert ar['complete'];recipe=read(ar['recipe']['path']);pins.append(ar['recipe'])
  for row in ar['records']:
   if row['role']==role:rows[row['case'],role]=(row,recipe)
catalog={c['name']:c for c in read(ROOT/'selfhost/tools/performance/phase70/coverage/cases-v2.json')};cat6={c['name']:c for c in read(ROOT/'selfhost/tools/performance/phase46/cases.json')}
report=dict(complete=False,inputs=pins,records=[])
with S.ExecutionGuard(rss_mib=2048,available_mib=4096) as g:
 for case in a.cases.split(','):
  for role in ['selfhost','upstream']:
   row,recipe=rows[case,role];source=Path(row['nativeSource']['path']);assert S.identity(source)==row['nativeSource'];out=a.out/(case+'-'+role);out.mkdir()
   text,sites=R.site_counts(source.read_text());text,segments=R.N.instrument(text);code=out/'program.c';code.write_text(text);exe=out/'program'
   item=dict(case=case,role=role,original=row['nativeSource'],source=S.identity(code),sites=sites,segments=segments,runs=[]);report['records'].append(item)
   def run(cmd,d):return g.run(['taskset','-c','3',*map(str,cmd)],d,time.monotonic()+90)
   item['build']=run([recipe['clang'],*recipe['clangArgs'],code,*recipe['linkArgs'],'-o',exe],out/'build');S.save(a.out/'report.json',report);assert item['build']['complete']
   o,c=(O,catalog[case]) if case in catalog else (O6,cat6[case]);vals=o.points(c)
   for n in [1,17]:
    dest=out/str(n);proc=run([exe,'--threads','1','--gpu','off','--',n,0],dest);words=(dest/'stdout.log').read_text().splitlines();expected=[c['expected'],o.digest(vals,0),o.digest(vals,n)];assert proc['complete'] and len(words)==4 and list(map(int,words[:3]))==expected
    logs=[json.loads(s) for s in (dest/'stderr.log').read_text().splitlines()];item['runs'].append(dict(count=n,process=proc,correct=True,logs=logs))
   first,last=item['runs'];find=lambda run,kind:next(x for x in run['logs'] if x['kind']==kind)
   counts=[find(x,'phase68-native-counts') for x in [first,last]]
   item['delta']={k:counts[1][k]-counts[0][k] for k in counts[0] if type(counts[0][k]) is int}
   ac=[find(x,'phase68-allocation-sites')['sites'] for x in [first,last]];item['topSites']=sorted([dict(site=s,count=y-x) for s,x,y in zip(sites,*ac)],key=lambda v:v['count'],reverse=True)[:15]
   S.save(a.out/'report.json',report);print(json.dumps(dict(case=case,role=role,delta=item['delta'],sites=item['topSites'][:5])),flush=True)
report['complete']=True;S.save(a.out/'report.json',report)
