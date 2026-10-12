#!/usr/bin/env python3
"""Data-only complete-C identity receipt; never labels these requests a benchmark."""
import argparse
import hashlib
import json
from pathlib import Path


def pin(value):
    expected = value if isinstance(value, dict) else None
    path = Path(expected['file'] if expected else value).resolve(strict=True)
    data = path.read_bytes()
    result = dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if expected:
        assert result['sha256'] == expected['sha256']
        assert 'bytes' not in expected or result['bytes'] == expected['bytes']
    return result


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--plan', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
assert not a.out.exists()
plan_pin = pin(a.plan)
plan = json.loads(a.plan.read_text())
assert plan['qualificationOnly'] and set(plan['roles']) == {'b1', 'b2'}
assert len(plan['cases']) == plan['expectedCases']
for item in plan['inputs']:
    pin(item)
observations = []
for job in plan['jobs']:
    path = a.plan.parent / 'runs' / job['name'] / 'report.json'
    report = json.loads(path.read_text())
    guard_path = path.parent.with_name(path.parent.name + '-guard') / 'process.json'
    guard = json.loads(guard_path.read_text())
    assert report['complete'] and report['pass'] and report['inputsUnchanged']
    assert report['job'] == job and report['plan'] == plan_pin
    assert guard['complete'] and guard['returncode'] == 0
    row = dict(job=job, report=pin(path), guard=pin(guard_path),
               guardWallSeconds=guard['wallSeconds'], peakRssBytes=guard['peakTreeRssBytes'])
    if job['action'] == 'request':
        assert report['exactC'] and report['observation']['checked']
        output, oracle = pin(report['output']), pin(report['oracle'])
        assert output['sha256'] == oracle['sha256']
        assert oracle == plan['cases'][job['case']]['expected'][job['role']]
        row.update(output=output, oracle=oracle, exactC=True)
    observations.append(row)
assert len(observations) == 2 + 2 * plan['expectedCases']
for case in plan['cases']:
    rows = [r for r in observations if r['job'].get('case') == case]
    assert len(rows) == 2 and {r['job']['role'] for r in rows} == {'b1', 'b2'}
result = dict(kind='phase70-checked-native-C-identity', complete=True,
    targetsExecutedByAnalyzer=False, qualificationOnly=True,
    producer=pin(__file__), plan=plan_pin, attempt=plan['attempt'], imagePins=plan['imagePins'],
    oracleAttempt=plan['oracleAttempt'], cases=plan['cases'], observations=observations,
    preparations=2, exactCheckedEmissions=2 * plan['expectedCases'],
    guardWallSeconds=sum(r['guardWallSeconds'] for r in observations),
    peakRssBytes=max(r['peakRssBytes'] for r in observations),
    scope=plan['scope'])
with a.out.open('x') as stream:
    stream.write(json.dumps(result, indent=2) + '\n')
print(json.dumps(dict(output=pin(a.out), exactCheckedEmissions=result['exactCheckedEmissions'])))
