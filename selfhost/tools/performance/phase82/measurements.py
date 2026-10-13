#!/usr/bin/env python3
"""Summarize completed clean intervals; retain samples and exact observations."""
import hashlib, json, math, statistics
from pathlib import Path
ROOT=Path('/home/ai/bend2/build/publish/bend');RAW=ROOT/'selfhost/build/phase82'
def pin(p):return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def gm(xs):return math.exp(sum(math.log(x) for x in xs)/len(xs))
result=dict(method=pin(Path(__file__).resolve()),screens={},cleanRequests=0)
for name in ['screen02','heldout02','paired04','heldout04','erasure05','erasure05-b2']:
 plan_file=RAW/name/'plan.json';plan=json.loads(plan_file.read_text());rows={};reports=[];observations={}
 for job in plan['jobs']:
  if job['action']!='request' or job['profile']:continue
  p=plan_file.parent/'runs'/job['name']/'report.json';r=json.loads(p.read_text())
  assert r['complete'] and r['pass'] and r['exactC'] and r['inputsUnchanged']
  assert r['actual']['sha256']==plan['cases'][job['case']]['expected'][job['role']]['sha256']
  rows.setdefault(job['case'],{}).setdefault(job['role'],[]).append(r['timings']['requestMs']);reports.append(pin(p))
  if job['role']!='typescript':
   observation={k:v for k,v in r['observation'].items() if k!='files'}
   prior=observations.setdefault(job['case'],observation);assert observation==prior,(name,job['case'],job['role'])
 medians={case:{role:statistics.median(xs) for role,xs in roles.items()} for case,roles in rows.items()}
 roles=list(next(iter(medians.values())));ratio_ts={role:gm([x[role]/x['typescript'] for x in medians.values()]) for role in roles if role!='typescript'}
 ratio_base=gm([x['ordinary']/x['baseline'] for x in medians.values()])
 ratio_b2=gm([x['ordinary-b2']/x['baseline-b2'] for x in medians.values()]) if 'ordinary-b2' in roles else None
 result['screens'][name]=dict(plan=pin(plan_file),samplesMs=rows,mediansMs=medians,ratioTypeScript=ratio_ts,candidateOverBaseline=ratio_base,b2OverBaseline=ratio_b2,exactObservations=True,exactC=True,reports=reports)
 result['cleanRequests']+=len(reports)
out=ROOT/'implementation/phase82/measurements.json';out.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({n:{k:r[k] for k in ['candidateOverBaseline','b2OverBaseline','ratioTypeScript']} for n,r in result['screens'].items()},indent=2))
