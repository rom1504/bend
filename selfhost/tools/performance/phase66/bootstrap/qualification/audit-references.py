#!/usr/bin/env python3
"""Summarize closed fresh HEAD semantic oracles without changing their verdicts."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
RAW = ROOT / 'selfhost/build/phase66'
PIN = '059266225b77c8ca256ac6b25ee5c21449bab151'
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
seen = {}


def pin(value):
    item = value if isinstance(value, dict) else None
    file = Path(item.get('file', item.get('path')) if item else value).resolve(strict=True)
    if str(file) not in seen:
        seen[str(file)] = dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())
    row = seen[str(file)]
    if item:
        assert row['sha256'] == item['sha256'], file
        if 'bytes' in item:
            assert file.stat().st_size == item['bytes'], file
    return row


def read(value):
    return json.loads(Path(pin(value)['file']).read_text())


groups = []
reports = {}
for name, count in [('source', 96), ('numeric', 34), ('composition', 18), ('overapplication', 2)]:
    acquisition_pin = pin(RAW / ('head-semantic-' + name) / 'manifest.json')
    acquisition = read(acquisition_pin)
    assert acquisition['complete'] and acquisition['passed']
    assert set(acquisition['roles']) == {'typescript'}
    catalog = read(acquisition['catalog'])
    assert catalog['upstreamCommit'] == PIN
    for case in catalog['cases']:
        file = Path(acquisition_pin['file']).parent / acquisition['roles']['typescript']['modules'][case['id']]
        pin(file)
        receipt = read(str(file) + '.json')
        assert receipt['complete'] and receipt['observation']['checked']
        assert receipt['observation']['status'] == 'ok'
        assert receipt['compiler']['kind'] == 'checked-pinned-typescript'
        assert receipt['compiler']['upstreamCommit'] == PIN
        assert pin(receipt['output']) == pin(file)
        for row in receipt['compiler']['sources']:
            pin(row)
    report_pin = pin(RAW / ('head-semantic-' + name + '-controls') / 'report.json')
    report = read(report_pin)
    assert report['complete'] and len(report['observations']) == count
    assert not report.get('error') and not report.get('changedInputs')
    for row in report['inputs']:
        pin(row)
    failed = [row for row in report['observations'] if not row['pass']]
    groups.append(dict(name=name, acquisition=acquisition_pin, report=report_pin,
                       passVerdict=report['pass'], observations=count,
                       oraclePass=count-len(failed), oracleFail=len(failed)))
    reports[name] = report

source_failures = [row for row in reports['source']['observations'] if not row['pass']]
assert len(source_failures) == 1
row = source_row = source_failures[0]
assert (row['fixture'], row['test']) == ('f32_table_nan_bits', 'nan-table-bits')
assert row['execution']['status'] == 1 and row['execution']['signal'] is None
assert row['execution']['error'] is None
assert row['observation']['complete'] is False and row['observation']['value'] == 1
assert row['observation']['error']['name'] == 'AssertionError'
assert 'independent expected value' in row['observation']['error']['message']
assert '1 !== 40' in row['observation']['error']['message']
numeric = reports['numeric']
assert numeric['healthy'] and numeric['counts']['referencePass'] == 28
expected_failures = [prefix + str(i) for prefix in ['original-cold-', 'renamed-cold-'] for i in range(3)]
numeric_failures = [row for row in numeric['observations'] if not row['pass']]
assert [row['id'] for row in numeric_failures] == expected_failures
for row in numeric_failures:
    result = row['roles']['typescript']
    assert result['healthy'] and result['status'] == 0
    assert result['error'] is None and result['signal'] is None
    observation = result['observation']
    assert observation['complete'] and not observation['oraclePass']
    assert observation['expected'] == 40 and observation['values'] == [1, 0, 0]
for name in ['composition', 'overapplication']:
    assert reports[name]['pass'] and all(row['pass'] for row in reports[name]['observations'])
result = dict(kind='phase66-fresh-head-semantic-reference-audit', complete=True,
              dataOnly=True, targetExecuted=False, producer=pin(__file__), upstream=PIN,
              groups=groups, verifiedInputFiles=len(seen),
              sourceFailure=dict(fixture=source_row['fixture'],
                                 test='nan-table-bits', expected=40, actual=1,
                                 classification='Independent source-value oracle failure; process completed without signal or infrastructure error.'),
              numericFailures=[dict(id=row['id'], expectedEveryCall=40, actual=[1, 0, 0]) for row in numeric_failures],
              scope='Freshly measured new-pin TypeScript failures remain failures. No historical count or emitted artifact is relabelled, no candidate has run in this audit, and no failed source golden is rewritten. Candidate source96/numeric34 remain mandatory; source/numeric counts overlap.')
out = a.out.resolve()
assert out.is_relative_to(ROOT) and not out.exists()
out.parent.mkdir(parents=True, exist_ok=True)
with out.open('x') as stream:
    stream.write(json.dumps(result, indent=2) + '\n')
print(json.dumps(dict(output=pin(out), groups=groups, targetExecuted=False)))
