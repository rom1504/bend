#!/usr/bin/env python3
"""Prepare a fresh unchanged-release smoke retry after the launch diagnostic."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
RAW=ROOT/'selfhost/build/phase90'
def pin(p):
    b=p.read_bytes();return dict(file=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
original=RAW/'release07/plan.json';plan=json.loads(original.read_text())
first=RAW/'release-launch-probe01/report.json';second=RAW/'release-launch-probe02/report.json'
a,b=(json.loads(p.read_text()) for p in [first,second])
assert a['complete'] and b['complete']
assert a['rows'][0]['status']==0 and a['rows'][0]['error']['code']=='EPERM'
assert a['rows'][1]['status']==0 and a['rows'][1]['error'] is None
assert all(r['status']==0 and r['error'] is None for r in b['rows'])
assert len({r['binary']['sha256'] for x in [a,b] for r in x['rows']})==1
for x in [a,b]:
    for record in x['inputs']:assert pin(Path(record['file']))==record
out=RAW/'release07-retry01';out.mkdir(exist_ok=False)
commands=[]
for row in plan['commands']:
    if row['name'] not in ['legacy42','default24','verify-after']:continue
    commands.append(dict(name=row['name'],command=[arg.replace(str(RAW/'release07')+'/',str(out)+'/') for arg in row['command']]))
assert len(commands)==3
result=dict(kind='phase90-qualified-release-environment-retry',complete=True,dataOnly=True,targetsExecuted=False,
    method=pin(Path(__file__).resolve()),originalPlan=pin(original),sandboxDiagnostic=pin(first),authorizedOutsideSandboxDiagnostic=pin(second),
    commands=commands,requires='Run via approved outside-sandbox execution; all original guards, compiler identities and smoke assertions are retained.',
    scope='Only fresh output paths and execution environment differ. No production compiler, host, installed release or test predicate changes.')
(out/'plan.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(pin(out/'plan.json')))
