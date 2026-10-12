#!/usr/bin/env python3
"""Bind the existing frozen checker adapter to its actual pinned upstream path."""
import argparse
import hashlib
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]


def pin(path, expected=None):
    path = Path(path).resolve(strict=True)
    data = path.read_bytes()
    value = dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if expected:
        assert value['sha256'] == expected['sha256']
        assert 'bytes' not in expected or value['bytes'] == expected['bytes']
    return value


ap = argparse.ArgumentParser(description=__doc__)
ap.add_argument('--source-plan', required=True, type=Path)
ap.add_argument('--out', required=True, type=Path)
a = ap.parse_args()
assert os.sched_getaffinity(0) == {0}
out = a.out.resolve()
assert out.is_relative_to(ROOT/'selfhost/build/phase70') and not out.exists()
source_pin = pin(a.source_plan)
source = json.loads(a.source_plan.read_text())
assert source['kind'] == 'phase70-source-check-plan'
command = source['optionalUpstreamCommand'].copy()
upstream = Path(command[command.index('--upstream')+1]).resolve(strict=True)
assert upstream == ROOT/'selfhost/.bootstrap/upstream-phase66'
inputs = [pin(__file__), source_pin]
for name in ['selection','originalSelection','attempt','node','guard']:
    inputs.append(pin(source[name]['file'], source[name]))
for item in source['copies']:
    inputs.append(pin(item['copy']['file'], item['copy']))
for item in source['fixtureInputs']:
    inputs.append(pin(item['source']['file'], item['source']))
for name in ['bend.ts','comp.ts','base.bend','main.ts','safe.ts','bendtt.lean']:
    inputs.append(pin(upstream/'bend2'/name))
old_output = command[command.index('--output')+1]
old_guard = str(a.source_plan.resolve().parent/'upstream-supervisor')
assert command.count(old_guard) == 1
command[command.index(old_guard)] = str(out/'upstream-supervisor')
command[command.index('--output')+1] = str(out/'upstream.json')
assert not any(x.startswith('BEND_UPSTREAM=') for x in command)
command.insert(command.index('env')+1, 'BEND_UPSTREAM='+str(upstream))
out.mkdir(parents=True)
result = dict(kind='phase70-upstream-source-check-plan', producer=pin(__file__),
    sourcePlan=source_pin, expectedCases=source['expectedCases'], inputs=inputs,
    command=command, targetsExecuted=False, requiresEscalatedExecution=True,
    exactChanges=[dict(field='environment', added='BEND_UPSTREAM='+str(upstream)),
        dict(field='--output', before=old_output, after=str(out/'upstream.json')),
        dict(field='supervisor directory', before=old_guard, after=str(out/'upstream-supervisor'))],
    scope='Only upstream adapter source-check lane. Frozen adapter and sourcecheck project are reused read-only; explicit BEND_UPSTREAM supplies its actual pinned reference root before runner artifact identity collection. Earlier failed command/output is retained. Same isolated worker mode, cases, positive checker oracles and guard limits; no compiler, Clang or native execution occurred during preparation.')
with (out/'plan.json').open('x') as stream:
    stream.write(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(plan=pin(out/'plan.json'), targetsExecuted=False)))
