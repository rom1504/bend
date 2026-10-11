#!/usr/bin/env python3
"""Run only diagnostic profile jobs with the new checked native entry observed."""
import argparse,importlib.util,json,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--plan',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(exist_ok=False)
spec=importlib.util.spec_from_file_location('S',ROOT/'selfhost/tools/performance/programs/support.py');S=importlib.util.module_from_spec(spec);spec.loader.exec_module(S)
plan=json.loads(a.plan.read_text());parent=ROOT/'selfhost/tools/performance/phase68/compilation/worker.mjs';source=parent.read_text()
edits=[("'nc_foreign_scope','kf_source','nc_foreign_source','nc_compile'];","'nc_foreign_scope','kf_source','nc_foreign_source','nc_compile','nc_compile_checked'];"),("'nc_foreign_paths','nc_compile'])assert(report.stages[name]","'nc_foreign_paths','nc_compile_checked'])assert(report.stages[name]")]
for before,after in edits:assert source.count(before)==1;source=source.replace(before,after)
worker=a.out/'worker.mjs';worker.write_text(source)
pins=[S.identity(__file__),S.identity(a.plan),S.identity(parent),S.identity(worker)]+[dict(path=x['file'],sha256=x['sha256'],bytes=x['bytes']) for x in plan['inputs']]
for pin in pins:assert S.identity(pin['path'])==pin
S.save(a.out/'derivation.json',dict(parent=S.identity(parent),candidate=S.identity(worker),edits=[dict(before=b,after=c,count=1) for b,c in edits],scope='Only diagnostic wrapper selection and mandatory observed stage change; all request, C equality, cache, input and clock checks retained. Reuses original exact prepared state; does not rerun or modify clean timing observations.'))
report=dict(complete=False,inputs=pins,originalPlan=S.identity(a.plan),derivation=S.identity(a.out/'derivation.json'),jobs=[])
try:
 with S.ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
  for job in [x for x in plan['jobs'] if x['profile']]:
   out=a.out/job['name'];role=plan['roles'][job['role']]
   command=['taskset','-c','3',role['node']['file'],*plan['nodeArgs'],str(worker.resolve()),str(a.plan.resolve()),job['name'],str(out.resolve())]
   proc=guard.run(command,out.with_name(out.name+'-guard'),time.monotonic()+90);assert proc['complete']
   r=json.loads((out/'report.json').read_text());assert r['complete'] and r['pass'] and r['exactC'] and r['inputsUnchanged'];assert r['stages']['nc_compile_checked']['calls']>0
   report['jobs'].append(dict(job=job,process=proc,report=S.identity(out/'report.json')));S.save(a.out/'report.json',report)
 for pin in pins:assert S.identity(pin['path'])==pin
 report['complete']=True
finally:S.save(a.out/'report.json',report)
print(json.dumps(dict(complete=report['complete'],jobs=len(report['jobs']))))
