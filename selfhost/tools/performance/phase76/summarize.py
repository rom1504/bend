#!/usr/bin/env python3
"""Collect completed Phase76 measurements; does not execute compiler targets."""
import hashlib,json,statistics
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];R=ROOT/'selfhost/build/phase76';OUT=ROOT/'implementation/phase76'
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
identities=[]
for group in ['native06','coverage06']:
 p=R/('compiler12-'+group)/'report.json';j=read(p);assert j['complete']
 for r in j['records']:
  assert r['correct'];case=r['case'];out=p.parent/(case+'-selfhost');old=ROOT/'selfhost/build/phase73'/('compiler14-'+group)/(case+'-selfhost')
  row=dict(case=case,acquisition=pin(p))
  for label,file in [('c','program.c'),('binary','program')]:
   a,b=pin(old/file),pin(out/file);assert a['sha256']==b['sha256'] and a['bytes']==b['bytes'];row[label]=dict(baseline=a,selected=b,exact=True)
  identities.append(row)
assert len(identities)==12
write(R/'compiler12-program-identity12.json',dict(complete=True,**{'pass':True},rows=identities,scope='Exact Phase73 C/binaries, also retained by Phase75. New executions check digests; no retiming claim.'))
def size(directory):
 m=read(directory/'src/compiler.json');files=m['modules'];lines=[]
 for f in files:lines+= (directory/f).read_text().splitlines()
 return dict(modules=len(files),physicalLines=len(lines),nonblankNoncommentLines=sum(bool(s.strip()) and not s.lstrip().startswith('#') for s in lines))
selected=compilation('paired12-compilation');selected.update(kind='phase76-selected-compilation',complete=True,sourceCandidate='compiler12',images=read(R/'compiler12-b2/image-pins.json'),programIdentity=pin(R/'compiler12-program-identity12.json'),sourceSize=dict(baseline=size(ROOT/'selfhost/build/phase75/compiler14/snapshot'),selected=size(R/'compiler12/snapshot')),metric='Fresh JS-hosted checked Bend-to-C request. Imports, explicit Bend Base preparation, Clang and execution excluded; TS checks Base inside request. Backend products disabled. No parity claim.')
write(OUT/'measurements.json',selected)
prototype=compilation('paired08b-compilation');runtime=[]
for group in ['native','coverage']:
 p=R/('compiler08-runtime-'+group)/'report.json';j=read(p);assert j['complete'];assert len(j['records'])==108 and all(x['qualified'] and x['correct'] for x in j['records']);runtime+=j['rows']
prototype.update(kind='phase76-rejected-pattern-prototype',complete=True,sourceCandidate='compiler08',runtimeRows=runtime,rejectedReason='Repeated tree and Array.map execution regressions; full release qualification deliberately not completed.')
write(OUT/'prototype-measurements.json',prototype)
print(json.dumps(dict(selectedRatios=selected['geometricRequestRatiosToUpstream'],selectedTimeReduction=selected['timeReduction'],sourceSize=selected['sourceSize'],prototypeRatios=prototype['geometricRequestRatiosToUpstream'])))
