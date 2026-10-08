#!/usr/bin/env python3
"""Convert the reviewed release plan to serial guarded argv; never install."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase66'
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--plan', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
inputs = {}


def pin(value):
    item = value if isinstance(value, dict) else None
    file = Path(item.get('file', item.get('path')) if item else value).resolve(strict=True)
    row = dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())
    if item:
        assert row['sha256'] == item['sha256'], file
        if 'bytes' in item:
            assert file.stat().st_size == item['bytes'], file
    assert str(file) not in inputs or inputs[str(file)] == row
    inputs[str(file)] = row
    return row


def read(value):
    return json.loads(Path(pin(value)['file']).read_text())


plan = read(a.plan)
assert plan['kind'] == 'phase66-default-release-qualification-plan' and not plan['executed']
assert plan['cwd'] == str(ROOT) and Path(plan['output']).is_relative_to(RAW)
assert not Path(plan['output']).exists()
assert [row['name'] for row in plan['steps']] == ['install', 'verify-before', 'legacy42', 'default24', 'verify-after']
assert plan['steps'][2]['expected']['steps'] == 42 and plan['steps'][3]['expected']['steps'] == 24
for row in plan['tools'] + [plan[key] for key in ['attempt', 'api', 'node', 'directRuntime', 'vendorManifest']]:
    pin(row)
attempt = read(plan['attempt'])
assert attempt['checked'] and attempt['artifactKind'] == 'derived-b1'
assert attempt['config']['strictExact'] and attempt['node']['version'] == 'v24.18.0'
assert pin(attempt['api']) == pin(plan['api'])
validation = read(Path(plan['attempt']['file']).parent / 'validation-001/report.json')
assert validation['complete'] and validation['pass'] and validation['strictExact']
assert pin(validation['attempt']) == pin(plan['attempt'])
assert pin(validation['api']) == pin(plan['api'])
assert validation['selected']['exactDifferences'] == 0
environment = read(ROOT / 'selfhost/tools/performance/phase55/semantic-plan-v1.json')['nativeEnvironment']
assert set(environment) == {'CC', 'CPATH', 'LIBRARY_PATH', 'LD_LIBRARY_PATH'}
pin(environment['CC'])
for key in ['CPATH', 'LIBRARY_PATH', 'LD_LIBRARY_PATH']:
    assert Path(environment[key]).is_dir()
pin(__file__)
for row in list(inputs.values()):
    pin(row)
target = a.out.resolve()
assert target.is_relative_to(RAW) and not target.exists()
result = dict(kind='phase66-root-release-launch-plan', complete=True, executed=False,
              cwd=str(ROOT), sourcePlan=pin(a.plan), producer=pin(__file__),
              attempt=pin(plan['attempt']), inputs=list(inputs.values()),
              commands=[dict(name=row['name'], command=row['guardedArgv'],
                             environment=environment, expected=row['expected']) for row in plan['steps']],
              barrier='Root must admit the completed final qualification and preserve the previous installed seven files before executing installation. This data conversion grants no admission. The unpinned serial launcher must not own another ExecutionGuard; every command already has its sole guard.')
target.parent.mkdir(parents=True, exist_ok=True)
with target.open('x') as stream:
    stream.write(json.dumps(result, indent=2) + '\n')
print(json.dumps(dict(plan=pin(target), commands=5, executed=False)))
