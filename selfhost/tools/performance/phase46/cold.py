#!/usr/bin/env python3
"""Cold process plus one checked workload and readback, separate from warm batches."""
import argparse,importlib.util,json,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('support',ROOT/'selfhost/tools/performance/programs/support.py')
s=importlib.util.module_from_spec(spec);spec.loader.exec_module(s)
p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=Path);a=p.parse_args()
a.out=a.out.resolve();a.out.mkdir(parents=True,exist_ok=False)
cases=json.loads((HERE/'cases.json').read_text());roles=[('upstream','js'),('selfhost','js'),('upstream','c'),('selfhost','c')]
node='/home/ai/.nvm/versions/node/v24.18.0/bin/node';records=[];inputs=[s.identity(__file__),s.identity(HERE/'execute.py'),s.identity(HERE/'cases.json'),s.identity(node)]
with s.ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
 for case in cases:
  acquisition=ROOT/'selfhost/build/phase46'/('pilot02' if case['name'] in ['numeric','closures'] else 'expansion01')
  for round_index in range(3):
   for role,target in roles[round_index:]+roles[:round_index]:
    name=case['name']+'-'+role+'-'+target;d=acquisition/name
    file=d/('program' if target=='c' else 'program.'+('cjs' if role=='upstream' else 'mjs'))
    identity=s.identity(file);cmd=([node,'--max-old-space-size=1024',str(file)] if target=='js' else [str(file)])+['--threads','1','--gpu','off']
    dest=a.out/(name+'-r'+str(round_index));child=dest/'child.json'
    r=guard.run(['taskset','-c','3','python3',str(HERE/'execute.py'),str(child),*cmd],dest,time.monotonic()+10)
    observation=json.loads(child.read_text()) if child.exists() else {}
    correct=r['complete'] and observation.get('stdout','').strip()==str(case['expected'])
    assert s.identity(file)==identity
    records.append(dict(case=case['name'],role=role,target=target,round=round_index,artifact=identity,process=r,child=observation,correct=correct))
    s.save(a.out/'report.json',dict(scope='Cold process launch plus one workload and readback; not isolated runtime startup',inputs=inputs,records=records))
    if not correct:raise SystemExit('Cold correctness failure')
  print(case['name']+': 12 cold observations passed',flush=True)
for item in inputs:assert s.identity(item['path'])==item
