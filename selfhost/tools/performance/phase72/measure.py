#!/usr/bin/env python3
"""Finite, rotated runtime screen with explicit affinity and independent outputs."""
import argparse,importlib.util,json,statistics,time,sys,os
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[4];RAW=ROOT/'selfhost/build/phase72';HERE=Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('support',ROOT/'selfhost/tools/performance/programs/support.py');S=importlib.util.module_from_spec(s);s.loader.exec_module(S)
p=argparse.ArgumentParser();p.add_argument('group',choices=['product','bst','parallel']);p.add_argument('--out',required=True);p.add_argument('--rounds',type=int,default=3);a=p.parse_args();out=RAW/a.out;out.mkdir(exist_ok=False)
report=dict(complete=False,group=a.group,producer=S.identity(__file__),records=[],artifacts=[],affinity=sorted(os.sched_getaffinity(0)))
def save():S.save(out/'report.json',report)
if a.group in ['product','bst']:
 artifacts={'original':ROOT/'selfhost/build/phase70/compiler02-array-map/array-map-selfhost/program','virtual':RAW/'array-map-virtual','upstream':ROOT/'selfhost/build/phase70/coverage-baseline01/array-map-upstream/program'}
 if a.group=='bst': artifacts={'original':ROOT/'selfhost/build/phase70/compiler02-coverage-missing-five01/bst-selfhost/program','virtual':RAW/'bst-virtual','upstream':ROOT/'selfhost/build/phase70/compiler02-coverage-baseline-holdouts01/bst-upstream/program'}
 spec=importlib.util.spec_from_file_location('oracle',ROOT/'selfhost/tools/performance/phase70/coverage/oracle-v2.py');O=importlib.util.module_from_spec(spec);spec.loader.exec_module(O)
 c=next(c for c in json.loads((ROOT/'selfhost/tools/performance/phase70/coverage/cases-v2.json').read_text()) if c['name']==('bst' if a.group=='bst' else 'array-map'));v=O.points(c);reps,warm=(122880,15360) if a.group=='bst' else (15360,1920);expected=[c['expected'],O.digest(v,warm),O.digest(v,reps)]
 report['oracle']=S.identity(Path(O.__file__));configs=[(role,1,'3') for role in artifacts];args=[str(reps),str(warm)]
else:
 artifacts={r:RAW/'acquire05'/r for r in ['selfhost','upstream']};expected=[json.loads((RAW/'parallel-oracle02.json').read_text())['balancedOracle']];configs=[(r,n,{1:'3',2:'2,3',4:'0-3'}[n]) for n in [1,2,4] for r in artifacts];args=[]
 report['topology']={c:{f:(Path('/sys/devices/system/cpu/cpu%d/topology'%c)/f).read_text().strip() for f in ['physical_package_id','core_id','thread_siblings_list']} for c in [0,1,2,3]}
report['artifacts']=[S.identity(x) for x in artifacts.values()];report['expected']=expected;save()
with S.ExecutionGuard(rss_mib=2048,available_mib=4096) as g:
 for round in range(a.rounds):
  order=configs[round%len(configs):]+configs[:round%len(configs)]
  if a.group=='parallel' and round%2:order=list(reversed(order))
  for role,n,cpus in order:
   dest=out/(role+'-'+str(n)+'-'+str(round));child=dest/'child.json'
   cmd=['taskset','-c',cpus,'python3',str(ROOT/'selfhost/tools/performance/phase46/execute.py'),str(child),str(artifacts[role]),'--threads',str(n),'--gpu','off',*(['--',*args] if args else [])]
   guard=g.run(cmd,dest,time.monotonic()+45)
   r=dict(role=role,threads=n,cpus=cpus,round=round,guard=guard);report['records'].append(r)
   if child.exists():r['child']=json.loads(child.read_text())
   obs=r.get('child',{});words=obs.get('stdout','').strip().splitlines();r['correct']=guard['complete'] and obs.get('returncode')==0 and words[:len(expected)]==list(map(str,expected)) and len(words)==len(expected)+(a.group!='parallel')
   r['elapsedMs']=int(words[3]) if a.group!='parallel' and r['correct'] else obs.get('processSeconds',0)*1000
   r['qualified']=r['correct'] and r['elapsedMs']>=100 and r['elapsedMs']<=obs.get('processSeconds',0)*1000+2
   save();print(json.dumps({k:r[k] for k in ['role','threads','round','correct','elapsedMs','qualified']}),flush=True)
   if not r['correct']:raise RuntimeError('Incorrect output: '+str(dest))
for p in report['artifacts']:assert S.identity(p['path'])==p
report['medians']={role:{str(n):statistics.median(r['elapsedMs'] for r in report['records'] if r['role']==role and r['threads']==n) for n in sorted({r['threads'] for r in report['records'] if r['role']==role})} for role in artifacts}
report['complete']=all(r['qualified'] for r in report['records']);save();print(json.dumps(dict(complete=report['complete'],medians=report['medians'])))
