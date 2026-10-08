#!/usr/bin/env python3
"""Separate native3 from a frozen checked plan while its C runtime is corrected."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
RAW = ROOT / 'selfhost/build/phase66'
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--parent', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()


def pin(value):
    item = value if isinstance(value, dict) else None
    file = Path(item.get('file', item.get('path')) if item else value).resolve(strict=True)
    row = dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())
    if item:
        assert row['sha256'] == item['sha256'], file
    return row


parent = pin(a.parent)
plan = json.loads(Path(parent['file']).read_text())
assert plan['kind'] == 'phase66-remaining-semantic-qualification-plan'
assert plan['complete'] and not plan['executed'] and plan['stage'] == 'checked'
assert pin(plan['producer'])['sha256'] == '12668dbc5482229c88517e3463e9351da4b01b215d7b085c0a53d3d194e7757c'
assert [row['name'] for row in plan['commands']] == [
    'acquire-source', 'join-source', 'source-controls', 'acquire-numeric',
    'numeric-controls', 'acquire-composition', 'composition-controls',
    'acquire-overapplication', 'overapplication-controls', 'maintained8', 'native3']
for row in plan['inputs']:
    pin(row)
target = a.out.resolve()
assert target.is_relative_to(RAW) and not target.exists()
result = {**plan, 'kind': 'phase66-checked-js-semantic-launch-plan',
          'producer': pin(__file__), 'parentPlan': parent,
          'commands': plan['commands'][:-1],
          'deferredCommands': plan['commands'][-1:],
          'inputs': plan['inputs'] + [parent, pin(__file__)],
          'scope': plan['scope'] + ' Native3 is explicitly deferred pending the separately reviewed native C runtime correction. This projection qualifies only the unchanged JavaScript closure and does not admit native or release success.'}
target.parent.mkdir(parents=True, exist_ok=True)
with target.open('x') as stream:
    stream.write(json.dumps(result, indent=2) + '\n')
print(json.dumps(dict(plan=pin(target), commands=10, deferred=['native3'], executed=False)))
