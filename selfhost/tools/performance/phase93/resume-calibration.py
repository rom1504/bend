#!/usr/bin/env python3
"""Retain ten complete calibration pairs and explicitly classify the zero-work control."""
import json
from run import ROOT, pin, read, save, verify
parent=ROOT/'selfhost/build/phase93/calibrate-broad01/report.json'
r=read(parent)
assert not r['complete'] and r['error']=="AssertionError('Calibration did not reach 50 ms: scalar-region-0')"
assert len(r['plan'])==10 and len(r['records'])==74
for row in r['records']:
    assert row['correct'];verify(row['child'])
zero=[x for x in r['records'] if x['case']=='scalar-region-0']
assert len(zero)==18 and all(x['elapsedMs']==0 for x in zero)
assert {x['role'] for x in zero if x['repetitions']==200000000}=={'own','upstream'}
for name in r['plan']:
    for role in ['own','upstream']:
        rows=[x for x in r['records'] if x['case']==name and x['role']==role]
        assert rows[-1]['elapsedMs']>=50
out=ROOT/'selfhost/build/phase93/calibration-continuation01';out.mkdir(exist_ok=False)
save(out/'retained-plan.json',dict(complete=True,method=pin(__file__),parent=pin(parent),plan=r['plan'],
    scope='Ten completed calibration pairs only, reused without rerunning. Parent failure remains unchanged; no claim its full campaign completed.'))
save(out/'unmeasured.json',dict(complete=True,method=pin(__file__),parent=pin(parent),cases=[dict(
    id='scalar-region-0',reason='Zero-work input: both optimized batches take0ms at1ms resolution through200million repetitions. No defined runtime ratio.',
    correctObservations=len(zero),roles=['own','upstream'],maximumRepetitions=200000000,ratio=None)]))
print('Retained ten completed plans; scalar-region-0 explicitly unmeasured, never assigned parity.')
