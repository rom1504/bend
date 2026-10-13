#!/usr/bin/env python3
"""Check completed candidate evidence and record a concrete selection; no install."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];R=ROOT/'selfhost/build/phase76'
def read(p):return json.loads(p.read_text())
def pin(p):return dict(file=str(p.resolve()),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
paths=['compiler12/validation-001/report.json','compiler12-b2/driver-comparison.json','compiler12-raw31/execution/report.json','compiler12-new14/execution/report.json','native100-inventory12.json','compiler12-qualification/self-check/report.json','compiler12-qualification/fixed-point/report.json','compiler12-report-controls.json','compiler12-ctor-controls/report.json','compiler12-uses-controls/report.json']
passed=[]
for name in paths:
 p=R/name;j=read(p);assert j['complete'] and j['pass'],name;passed.append(pin(p))
ident=R/'compiler12-program-identity12.json';j=read(ident);assert j['complete'] and j['pass'] and len(j['rows'])==12
fixed=read(R/'compiler12-qualification/fixed-point/report.json');assert fixed['byteEquality']
threads=R/'compiler12-threads/report.json';j=read(threads);assert j['complete'] and len(j['records'])==28
assert all(x['passCheck'] for x in j['records'])
closure=R/'compiler12-js-closure/report.json';j=read(closure);assert j['complete'] and j['unchangedFunctions']==2992 and j['changed']==[]
identity_plan=R/'compiler12-C-identity12b/plan.json';plan=read(identity_plan);b2identity=[]
for job in plan['jobs']:
 if job['action']=='request' and job['role']=='b2':
  p=identity_plan.parent/'runs'/job['name']/'report.json';j=read(p);assert j['complete'] and j['pass'] and j['exactC'];b2identity.append(pin(p))
assert len(b2identity)==12
attempt=read(R/'compiler12/attempt.json')
for r in attempt['snapshot']['sources']:
 assert pin(Path(r['original']['file']))['sha256']==r['frozen']['sha256'],r
measure=ROOT/'implementation/phase76/measurements.json';j=read(measure);assert j['complete'] and len(j['samples'])==45 and j['timeReduction']['b1']>0 and j['timeReduction']['b2']>0
j=dict(complete=True,selected='compiler12',images=read(R/'compiler12-b2/image-pins.json'),passed=passed,programIdentity=pin(ident),b2WholeC=b2identity,threads=pin(threads),nonNativeClosure=pin(closure),measurements=pin(measure),liveSourceMatchesCheckedSnapshot=True,decision='Promote lazy native admission and representation certificates. Reject scalar-pattern compaction/reconstruction and all saved-C placement variants for generated-runtime regressions. Parity not achieved; exact twelve C/binary outputs preserve runtime performance; known reference/native API gaps unchanged.')
p=R/'promotion12.json';assert not p.exists();p.write_text(json.dumps(j,indent=2)+'\n');print(json.dumps(dict(complete=True,decision=j['decision'],promotion=pin(p))))
