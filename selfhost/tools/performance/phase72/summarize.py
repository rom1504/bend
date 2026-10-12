#!/usr/bin/env python3
"""Summarize retained runtime and paired request measurements without resampling."""
import hashlib, json, math, statistics
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];RAW=ROOT/'selfhost/build/phase72'
def pin(p):return dict(path=str(p.relative_to(ROOT)),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def gm(xs):return math.exp(statistics.mean(math.log(x) for x in xs))
runtime=[];inputs=[]
for group,name in [('original6','compiler02-native-comparison'),('additional6','compiler02-coverage-comparison')]:
 p=RAW/name/'report.json';r=json.loads(p.read_text());assert r['complete'] and all(x['qualified'] for x in r['records']);inputs.append(pin(p))
 for row in r['rows']:
  row=dict(row,group=group);row['timeReduction']=1-row['mediansMs']['candidate']/row['mediansMs']['baseline70'];runtime.append(row)
runtimeScores={}
for group in ['original6','additional6','all12']:
 rows=[r for r in runtime if group=='all12' or r['group']==group]
 runtimeScores[group]={role:gm(r['mediansMs'][role]/r['mediansMs']['upstream'] for r in rows) for role in ['baseline70','candidate']}
 runtimeScores[group]['timeReduction']=1-runtimeScores[group]['candidate']/runtimeScores[group]['baseline70']
plan_path=RAW/'paired-compilation/plan.json';plan=json.loads(plan_path.read_text());inputs.append(pin(plan_path));requests=[]
for job in plan['jobs']:
 p=RAW/'paired-compilation/runs'/job['name']/'report.json';r=json.loads(p.read_text());assert r['complete'] and r['pass'];inputs.append(pin(p))
 if job['action']=='request': requests.append(dict(case=job['case'],role=job['role'],round=job['round'],requestMs=r['timings']['requestMs'],importsMs=r['timings']['importsMs']))
medians={case:{role:statistics.median(r['requestMs'] for r in requests if r['case']==case and r['role']==role) for role in plan['roles']} for case in plan['cases']}
requestScores={role:gm(m[role]/m['typescript'] for m in medians.values()) for role in ['old_b1','b1','old_b2','b2']}
changes={r:1-gm(m[r]/m['old_'+r] for m in medians.values()) for r in ['b1','b2']}
out=dict(complete=True,sourceCommit='1176262',producer=pin(Path(__file__)),runtime=runtime,runtimeScores=runtimeScores,requests=requests,requestMediansMs=medians,requestOverUpstream=requestScores,requestTimeReduction=changes,inputs=inputs,scope='Finite twelve-family C execution and three-source B1/B2 request screens. All12 equal-family geometric mean is optional, not a population estimate. Imports/Base/Clang are excluded from request ratios; Bend Base preparation is outside, upstream Base checking inside. No profile samples or failed intervals enter medians.')
dest=ROOT/'implementation/phase72/measurements.json';assert not dest.exists();dest.write_text(json.dumps(out,indent=2)+'\n');print(json.dumps({k:out[k] for k in ['runtimeScores','requestOverUpstream','requestTimeReduction']}))
