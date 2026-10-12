#!/usr/bin/env python3
"""Validate and publish the selected Phase75 compilation and identity receipts."""
import hashlib,json,math,statistics,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];RAW=ROOT/'selfhost/build/phase75';OUT=ROOT/'implementation/phase75'
def read(p):return json.loads(Path(p).read_text())
def pin(p):
 p=Path(p).resolve();return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
plan=RAW/'paired14-compilation/plan.json';j=read(plan);samples=[]
for job in j['jobs']:
 p=plan.parent/'runs'/job['name']/'report.json';r=read(p);g=read(p.parent.with_name(p.parent.name+'-guard')/'process.json');assert r['complete'] and r['pass'] and r['inputsUnchanged'] and g['complete'] and g['returncode']==0
 if job['action']=='request':
  assert r['exactC'];samples.append(dict(case=job['case'],role=job['role'],round=job['round'],**r['timings'],report=pin(p),guard=pin(p.parent.with_name(p.parent.name+'-guard')/'process.json')))
assert len(samples)==45
medians={c:{k:statistics.median(r['requestMs'] for r in samples if r['case']==c and r['role']==k) for k in j['roles']} for c in j['cases']}
def gm(xs):return math.exp(statistics.mean(math.log(x) for x in xs))
ratios={k:gm(x[k]/x['typescript'] for x in medians.values()) for k in j['roles']}
savings={k:1-gm(x[k]/x['old_'+k] for x in medians.values()) for k in ['b1','b2']}
images=read(RAW/'compiler14-b2/image-pins.json');identity=read(RAW/'compiler14-program-identity12.json');assert identity['complete'] and len(identity['records'])==12 and all(r['sameC'] and r['sameExecutable'] for r in identity['records'])
for role in ['oldC','newC','oldBinary','newBinary']:
 for r in identity['records']:assert pin(r[role]['file'])==r[role]
counts={}
for label,config in [('baseline',json.loads(subprocess.check_output(['git','show','7d51e96:selfhost/src/compiler.json'],cwd=ROOT,text=True))),('selected',read(ROOT/'selfhost/src/compiler.json'))]:
 physical=code=0
 for module in config['modules']:
  text=subprocess.check_output(['git','show','7d51e96:selfhost/'+module],cwd=ROOT,text=True) if label=='baseline' else (ROOT/'selfhost'/module).read_text()
  lines=text.splitlines();physical+=len(lines);code+=sum(bool(x.strip()) and not x.lstrip().startswith('#') for x in lines)
 counts[label]=dict(modules=len(config['modules']),physicalLines=physical,nonblankNoncommentLines=code)
result=dict(kind='phase75-selected-compilation',complete=True,sourceCandidate='compiler14',images=images,plan=pin(plan),samples=samples,mediansMs=medians,geometricRequestRatiosToUpstream=ratios,timeReduction=savings,programIdentity=pin(RAW/'compiler14-program-identity12.json'),sourceSize=counts,scope=j['scope'],metric='Fresh JS-hosted checked Bend-to-C request. Imports, explicit Bend Base preparation, Clang and program execution excluded; TS checks Base inside its request. Backend products disabled. No parity claim.')
(OUT/'measurements.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(ratios=ratios,timeReduction=savings,sourceSize=counts)))
