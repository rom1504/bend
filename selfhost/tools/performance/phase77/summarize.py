#!/usr/bin/env python3
"""Collect completed Phase76 measurements; does not execute compiler targets."""
import hashlib,json,statistics
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];R=ROOT/'selfhost/build/phase77';OUT=ROOT/'implementation/phase77'
def read(p):return json.loads(p.read_text())
def pin(p):return dict(file=str(p.resolve()),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
def write(p,v):p.write_text(json.dumps(v,indent=2)+'\n')
def compilation(name):
 d=R/name;plan=read(d/'plan.json');samples=[]
 for job in plan['jobs']:
  f=d/'runs'/job['name']/'report.json';j=read(f)
  assert j['complete'] and j['pass'] and j['inputsUnchanged'],f
  if job['action']!='request':continue
  assert j['exactC'] and not job['profile']
  g=d/'runs'/(job['name']+'-guard')/'process.json';guard=read(g)
  assert guard['complete'] and guard['returncode']==0
  samples.append(dict(case=job['case'],role=job['role'],round=job['round'],**j['timings'],report=pin(f),guard=pin(g)))
 assert len(samples)==45
 medians={case:{role:statistics.median(x['requestMs'] for x in samples if x['case']==case and x['role']==role) for role in plan['roles']} for case in plan['cases']}
 ratios={role:statistics.geometric_mean(v[role]/v['typescript'] for v in medians.values()) for role in plan['roles']}
 return dict(plan=pin(d/'plan.json'),samples=samples,mediansMs=medians,geometricRequestRatiosToUpstream=ratios,timeReduction={s:1-ratios[s]/ratios['old_'+s] for s in ['b1','b2']},scope=plan['scope'])
selected=compilation('paired01-compilation');selected.update(kind='phase77-combined-candidate-compilation',complete=True,sourceCandidate='compiler01',images=read(R/'compiler01-b2/image-pins.json'),metric='Fresh JS-hosted Bend-to-C request; imports, explicit Bend Base, Clang and execution excluded. TypeScript checks Base inside its request. Backend products disabled.')
write(OUT/'measurements.json',selected)
print(json.dumps(dict(ratios=selected['geometricRequestRatiosToUpstream'],reduction=selected['timeReduction'])))
