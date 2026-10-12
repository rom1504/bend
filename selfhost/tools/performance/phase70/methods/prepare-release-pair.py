#!/usr/bin/env python3
"""Source-only old69/final03 Numeric request screen, using genuine checked images."""
import argparse
import hashlib
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
RAW = ROOT / 'selfhost/build/phase70'
inputs = {}


def pin(value):
    expected = value if isinstance(value, dict) else None
    path = Path(expected.get('file', expected.get('path')) if expected else value).resolve(strict=True)
    data = path.read_bytes()
    result = dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if expected:
        assert result['sha256'] == expected['sha256'], path
        assert 'bytes' not in expected or result['bytes'] == expected['bytes'], path
    inputs[str(path)] = result
    return result


def read(value):
    return json.loads(Path(pin(value)['file']).read_text())


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
assert os.sched_getaffinity(0) == {0}
out = a.out.resolve()
assert out.is_relative_to(RAW) and not out.exists()
parents = dict(old69=ROOT/'selfhost/build/phase69/typed10-compilation01/plan.json',
               final03=RAW/'compiler03-compilation01/plan.json')
identity = read(RAW/'compiler03-C-identity12-v2-summary.json')
assert identity['complete'] and identity['exactCheckedEmissions'] == 24
roles, copies, evidence, expected = {}, [], {}, {}
for label, path in parents.items():
    parent = read(path)
    for item in parent['inputs']:
        pin(item)
    attempt = read(parent['attempt'])
    image = read(parent['imagePins'])
    assert attempt['checked'] and attempt['config']['strictExact']
    assert pin(image['attempt']) == pin(parent['attempt'])
    assert pin(image['b1']) == pin(attempt['api']) == pin(parent['roles']['b1']['api'])
    assert pin(image['b2']) == pin(parent['roles']['b2']['api'])
    for key in ['emission', 'comparison']:
        report = read(image[key])
        assert report['complete'] and report['pass']
    case = parent['cases']['numeric']
    acquisition = read(case['acquisition'])
    assert acquisition['complete']
    records = [r for r in acquisition['records'] if r['case'] == 'numeric' and r['role'] == 'selfhost']
    assert len(records) == 1
    record = records[0]
    assert record['correct'] and record['expected'] == case['expectedRuntime']
    for key in ['emission', 'toolchain', 'process']:
        assert record[key]['complete'] and record[key]['returncode'] == 0
    assert pin(record['nativeSource']) == pin(case['expected']['b1']) == pin(case['expected']['b2'])
    pin(record['executable'])
    emitted = read(case['nativeOracleEvidence'])
    assert emitted['complete'] and pin(emitted['input']) == pin(case['input'])
    assert pin(emitted['output']) == pin(record['nativeSource'])
    assert pin(parent['oracleApi']) in [pin(x) for x in emitted['compiler']]
    if label == 'final03':
        assert pin(identity['attempt']) == pin(parent['attempt'])
        assert pin(identity['imagePins']) == pin(parent['imagePins'])
        assert identity['cases']['numeric']['expected'] == {stage: case['expected'][stage] for stage in ['b1', 'b2']}
    snapshot = Path(attempt['snapshot']['root'])
    originals = {x['original']['file']: x['original'] for x in parent['copies'] if '/b1/project/' in x['copy']['file']}
    assert len(originals) == 56
    for stage in ['b1', 'b2']:
        role = label + '-' + stage
        project = out / role / 'project'
        for original in originals.values():
            source = Path(pin(original)['file'])
            destination = project / source.relative_to(snapshot)
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(source.read_bytes())
            copies.append(dict(original=original, copy=pin(destination)))
        previous = parent['roles'][stage]
        roles[role] = dict(api=pin(previous['api']), node=pin(previous['node']), base=pin(previous['base']),
            project=str(project), driver=pin(project/'tools/typed-driver.mjs'), runtime=pin(project/'src/runtime.mjs'),
            preparation=str(out/'runs'/('prepare-'+role)/'report.json'), stage=stage, release=label)
        expected[role] = pin(case['expected'][stage])
    evidence[label] = dict(parent=pin(path), attempt=pin(parent['attempt']), imagePins=pin(parent['imagePins']),
        acquisition=pin(case['acquisition']), emitted=pin(case['nativeOracleEvidence']),
        expectedRuntime=case['expectedRuntime'], source=pin(case['input']))
assert evidence['old69']['source'] == evidence['final03']['source']
assert evidence['old69']['expectedRuntime'] == evidence['final03']['expectedRuntime']
assert len({r['node']['sha256'] for r in roles.values()}) == 1
assert len({r['base']['sha256'] for r in roles.values()}) == 1
order = ['old69-b1', 'final03-b1', 'old69-b2', 'final03-b2']
jobs = [dict(name='prepare-'+role, role=role, action='prepare', profile=False) for role in order]
for round_ in range(4):
    for position, role in enumerate(order[round_:] + order[:round_]):
        jobs.append(dict(name=f'clean-{round_}-numeric-{role}', role=role, action='request', case='numeric',
            profile=False, round=round_, position=position, stage=roles[role]['stage'], release=roles[role]['release']))
for role in roles:
    assert sorted(j['position'] for j in jobs if j['role'] == role and j['action'] == 'request') == list(range(4))
for path in [__file__, HERE/'analyze-release-pair.py', HERE/'compilation/worker.mjs', HERE/'compilation/run.py']:
    pin(path)
plan = dict(kind='phase68-native-compilation-plan', version=7, status='prepared-unexecuted',
    producer=pin(__file__), legitimateImages=True, evidence=evidence, identityQualification=pin(RAW/'compiler03-C-identity12-v2-summary.json'),
    roles=roles, copies=copies, cases=dict(numeric=dict(input=evidence['final03']['source'], expected=expected)), jobs=jobs,
    cpu=3, nodeArgs=['--max-old-space-size=1024', '--stack-size=4096'], seconds=90,
    rssMiB=2048, availableMiB=4096, inputs=list(inputs.values()),
    scope='One Numeric same-campaign legitimate-image screen. Old69 and final03 checked B1 plus genuine B2, four complete role-position rotations, four private Base preparations and sixteen clean full checked requests. Each release retains its own independently native-validated complete C oracle; old/new C differ intentionally. No profiler, Clang or native execution. Request timing excludes imports and Base preparation. No corpus-wide or TypeScript ratio claim, no source optimization or promotion performed by this method.')
with (out/'plan.json').open('x') as stream:
    stream.write(json.dumps(plan, indent=2) + '\n')
print(json.dumps(dict(plan=pin(out/'plan.json'), preparations=4, requests=16, targetsExecuted=False)))
