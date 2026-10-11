#!/usr/bin/env python3
"""Join completed clean requests with separately corrected diagnostic profiles."""
import argparse,hashlib,importlib.util,json,math,re,statistics
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
p=argparse.ArgumentParser(description=__doc__)
for name in ['plan','profiles','out']:p.add_argument('--'+name,type=Path,required=True)
a=p.parse_args();assert not a.out.exists();inputs=[]
def pin(p):
 p=Path(p).resolve();r=dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size);inputs.append(r);return r
def read(p):pin(p);return json.loads(Path(p).read_text())
planpin=pin(a.plan);plan=read(a.plan)
for x in plan['inputs']:assert pin(x['file'])==x
clean=[]
for job in [j for j in plan['jobs'] if j['action']=='request' and not j['profile']]:
 path=a.plan.parent/'runs'/job['name']/'report.json';r=read(path)
 assert r['complete'] and r['pass'] and r['inputsUnchanged'] and r['exactC'] and r['plan']==planpin
 assert pin(r['output']['file'])==r['output'] and pin(r['oracle']['file'])==r['oracle']
 proc=read(path.parent.with_name(path.parent.name+'-guard')/'process.json');assert proc['complete'] and proc['returncode']==0
 clean.append(dict(job=job,report=pin(path),timings=r['timings'],guardWallSeconds=proc['wallSeconds']))
rows=[]
for case in plan['cases']:
 med={role:statistics.median(r['timings']['requestMs'] for r in clean if r['job']['case']==case and r['job']['role']==role) for role in plan['roles']}
 assert all(sum(r['job']['case']==case and r['job']['role']==role for r in clean)==3 for role in med)
 rows.append(dict(case=case,requestMediansMs=med,ratios={role:med[role]/med['typescript'] for role in ['b1','b2']}))
parent=ROOT/'selfhost/tools/performance/phase68/compilation/analyze.py';pin(parent);spec=importlib.util.spec_from_file_location('A',parent);A=importlib.util.module_from_spec(spec);spec.loader.exec_module(A)
attempt=read(plan['attempt']['file']);snapshot=Path(attempt['snapshot']['root']);owners={}
for record in attempt['snapshot']['sources']:
 f=Path(record['frozen']['file'])
 if f.suffix=='.bend':
  assert pin(f)['sha256']==record['frozen']['sha256']
  for name in re.findall(r'^def\s+([\w.]+)',f.read_text(),re.M):owners[name]=str(f.relative_to(snapshot))
pr=read(a.profiles/'report.json');assert pr['complete'];profiles=[]
for row in pr['jobs']:
 r=read(row['report']['path']);assert r['complete'] and r['pass'] and r['exactC'] and r['inputsUnchanged'];assert r['stages']['nc_compile_checked']['calls']>0
 profiles.append(dict(job=r['job'],report=row['report'],stages=r['stages'],cpu=A.profile_summary(read(r['profile']['file']),owners)))
result=dict(complete=True,cleanComplete=True,profilesComplete=True,originalPlanComplete=False,originalFailedProfilePreserved=True,clean=clean,rows=rows,requestGeomeans={role:math.prod(r['ratios'][role] for r in rows)**(1/len(rows)) for role in ['b1','b2']},profiles=profiles,inputs=inputs,scope='27 balanced clean C-emission requests plus 4 separately corrected profiles. Each request emits exact qualified C. Prepared Base; excludes imports and Clang. Not program runtime, full-corpus compilation, or a measured compiler17 regression comparison.')
a.out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(rows=rows,ratios=result['requestGeomeans'])))
