#!/usr/bin/env python3
"""Bind a fresh checked B1 source acquisition to its fresh HEAD TS reference."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
PIN = '059266225b77c8ca256ac6b25ee5c21449bab151'
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--direct', type=Path, required=True)
p.add_argument('--typescript', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
inputs = {}


def pin(value, base=ROOT):
    item = value if isinstance(value, dict) else None
    file = Path(base) / (item.get('file', item.get('path')) if item else value)
    file = file.resolve(strict=True)
    row = dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())
    if item:
        assert row['sha256'] == item['sha256'], file
        if 'bytes' in item:
            assert file.stat().st_size == item['bytes'], file
    assert str(file) not in inputs or inputs[str(file)] == row
    inputs[str(file)] = row
    return row


def read(value, base=ROOT):
    return json.loads(Path(pin(value, base)['file']).read_text())


parents = [pin(a.direct), pin(a.typescript)]
direct, reference = [read(row) for row in parents]
for role, record in [('direct', direct), ('typescript', reference)]:
    assert record['kind'] == 'phase52-semantic-acquisition'
    assert record['complete'] and record['passed']
    assert set(record['roles']) == {role}
assert direct['catalog'] == reference['catalog']
catalog_pin = pin(direct['catalog'])
catalog = read(catalog_pin)
assert catalog['kind'] == 'phase52-direct-semantic-catalog'
assert catalog['upstreamCommit'] == PIN
assert len(catalog['cases']) == 29
assert sum(len(case['tests']) for case in catalog['cases']) == 96
attempt_pin = pin(direct['roles']['direct']['attempt'])
attempt = read(attempt_pin)
assert attempt['checked'] and attempt['config']['strictExact']
assert read(attempt['bootstrapReport'])['revision'] == PIN
roles = {}
for role, record, origin in [('direct', direct, a.direct.resolve().parent),
                             ('typescript', reference, a.typescript.resolve().parent)]:
    group = record['roles'][role]
    assert set(group['modules']) == {case['id'] for case in catalog['cases']}
    roles[role] = dict(group)
    roles[role]['modules'] = {}
    for case in catalog['cases']:
        source = pin(case['source'], Path(catalog_pin['file']).parent)
        for row in case.get('auxiliary', []):
            pin(row, Path(catalog_pin['file']).parent)
        module = pin(group['modules'][case['id']], origin)
        receipt = read(module['file'] + '.json')
        assert receipt['kind'] == 'bend-program-checked-emission'
        assert receipt['complete'] and receipt['observation']['checked']
        assert receipt['observation']['status'] == 'ok'
        assert pin(receipt['output']) == module
        assert pin(receipt['input'])['sha256'] == source['sha256']
        assert receipt['compiler']['upstreamCommit'] == PIN
        if role == 'direct':
            assert receipt['compiler']['kind'] == 'checked-development-attempt'
            assert pin(receipt['attempt']) == attempt_pin
            for name in ['api', 'runtime', 'base']:
                assert pin(receipt['compiler'][name])['sha256'] == pin(attempt[name])['sha256']
            for row in receipt['emissionInputs']:
                pin(row)
        else:
            assert receipt['compiler']['kind'] == 'checked-pinned-typescript'
            for row in receipt['compiler']['sources']:
                pin(row)
        roles[role]['modules'][case['id']] = module['file']
out = a.out.resolve()
assert out.is_relative_to(ROOT / 'selfhost/build/phase66') and not out.exists()
pin(__file__)
for row in list(inputs.values()):
    pin(row)
result = dict(kind='phase66-fresh-source-role-join', complete=True, passed=True,
              executed=False, catalog=catalog_pin, roles=roles, parents=parents,
              producer=pin(__file__), inputs=list(inputs.values()),
              scope='Identity-only join of the same fresh new-pin source catalog and checked emissions. No execution-oracle pass, reference failure count, or historical TS program is inferred.')
out.parent.mkdir(parents=True, exist_ok=True)
with out.open('x') as stream:
    stream.write(json.dumps(result, indent=2) + '\n')
print(json.dumps(dict(output=pin(out), modules=29, targetExecuted=False)))
