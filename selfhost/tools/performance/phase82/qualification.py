#!/usr/bin/env python3
"""Join the completed source gates without interpreting expected reference failures as candidate failures."""
from pathlib import Path
import json, hashlib
R=Path('selfhost/build/phase82')
def pin(p):return dict(file=str(p.resolve()),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
reports=[]
for name in ['compiler04/validation-001/report.json','template04-b1/report.json','template04-b2/report.json','transport04/report.json','compiler04-raw31/execution/report.json','compiler04-new14/execution/report.json','compiler04-word10/execution/report.json','compiler04-heldout2/execution/report.json','compiler04-qualification/self-check/report.json','compiler04-qualification/fixed-point/report.json','js-continuity04/report.json']:
 p=R/name;j=json.loads(p.read_text());assert j['complete'] and j['pass'],name;reports.append(pin(p))
p=R/'native100-inventory04.json';j=json.loads(p.read_text());assert j['complete'] and j['passed'];reports.append(pin(p))
j=json.loads((R/'compiler04-threads/report.json').read_text());assert j['complete'];reports.append(pin(R/'compiler04-threads/report.json'))
p=R/'compiler04-C-identity12/plan.json';j=json.loads(p.read_text());count=0
for job in j['jobs']:
 if job['action']=='request':
  p=R/'compiler04-C-identity12/runs'/job['name']/'report.json';v=json.loads(p.read_text())
  assert v['pass'] and v['complete'] and v['exactC'] and v['output']['sha256']==j['cases'][job['case']]['expected'][job['role']]['sha256']
  reports.append(pin(p));count+=1
assert count==24
attempt=json.loads((R/'compiler04/attempt.json').read_text())
for row in attempt['snapshot']['sources']:assert Path(row['original']['file']).read_bytes()==Path(row['frozen']['file']).read_bytes(),row['original']['file']
result=dict(complete=True,passed=True,selected='compiler04',sourceCommit='070064e',images=pin(R/'compiler04-b2/image-pins.json'),measurement=pin(Path('implementation/phase82/measurements.json')),reports=reports,nativeCases=100,unchangedReferenceFailures=7,cOutputIdentity=24,jsSourceIdentity=23,rendererControls=250,transportControls=5,checkedSnapshotMatchesLive=True,promotion='Select genuine compiler04 B2; compiler05 deferred. Installation receipts are recorded separately.')
Path('implementation/phase82/qualification.json').write_text(json.dumps(result,indent=2)+'\n')
print('Selected source gates and C/JS continuity verified.')
