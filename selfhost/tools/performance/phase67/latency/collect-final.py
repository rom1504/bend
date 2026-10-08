#!/usr/bin/env python3
"""Join existing selected Phase67 receipts; data only, no target or release work."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT/'selfhost/build/phase67'
OLD = ROOT/'selfhost/build/phase66'
inputs, mappings = {}, []


def pin(value, base=ROOT):
    item = value if isinstance(value, dict) else None
    file = (base/Path(item.get('file', item.get('path')) if item else value)).resolve(strict=True)
    # The old installed baseline was consumed before installation; retain exact immutable bytes.
    if item and file == ROOT/'selfhost/dist/typed-api.mjs' and item['sha256'] == 'bb6c6e2ad6f18bf54d2b5c7e4e7a8d0fe3f0f80658a260ad52256fa4351d81a6':
        file = OLD/'checked-b1-07/equality/api.mjs'
        mappings.append(dict(logical=item, actual=str(file), scope='Exact previously installed baseline API only'))
    key = str(file)
    if key not in inputs:
        digest = hashlib.sha256()
        with file.open('rb') as stream:
            for block in iter(lambda: stream.read(2**20), b''): digest.update(block)
        inputs[key] = dict(file=key, sha256=digest.hexdigest())
    row = inputs[key]
    if item:
        assert row['sha256'] == item['sha256'], file
        if 'bytes' in item: assert file.stat().st_size == item['bytes'], file
    return row


def read(value, base=ROOT):
    return json.loads(Path(pin(value, base)['file']).read_text())


def passed(file):
    row = read(file)
    assert row['complete'] and (row.get('pass') is True or row.get('passed') is True), file
    for item in row.get('inputs', []): pin(item)
    return row


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--b1-screen', type=Path, required=True, help='Existing clean.py summary.json')
p.add_argument('--b2-screen', type=Path, required=True, help='Existing clean.py summary.json')
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
assert not a.out.exists()
attempt_file = RAW/'scalars-build01/attempt.json'
attempt, attempt_id = read(attempt_file), pin(attempt_file)
assert attempt['checked'] and attempt['config']['strictExact']
api = pin(attempt['api'])
for row in attempt['snapshot']['sources']: pin(row['frozen'])
for row in attempt['artifacts']: pin(row)
result = dict(kind='phase67-selected-final-qualification', dataOnly=True, targetsExecuted=False,
              producer=pin(__file__), attempt=attempt_id, b1=api, releaseIncluded=False)


def paired(file, count, lane):
    d = passed(file)
    assert pin(d['attempt']) == attempt_id and pin(d['api']) == api and d['strictExact']
    assert d['selected']['exactDifferences'] == d['selected']['discrepancies'] == 0
    q = read(d['selected']['file'])
    assert q['selectedComplete'] and not q['missing'] and not q['discrepancies'] and len(q['rows']) == count
    for row in q['rows']:
        assert row['lane'] == lane and row['exactAgreement'] and row['semanticAgreement']
        assert row['referenceVerdict'] == row['candidateVerdict'] == 'pass'
    return dict(receipt=pin(file), probes=count, lane=lane)


result['strict36'] = paired(RAW/'scalars-build01/validation-001/report.json', 36, 'check')
raw_file = RAW/'scalars-atoms-focused01/raw/report.json'
raw = passed(raw_file)
assert api in [pin(x) for x in raw['inputs']] and len(raw['rows']) == 10 and all(x['pass'] for x in raw['rows'])
assert any(x['file'].endswith('/raw-controls-v3.mjs') for x in raw['inputs'])
result['rawControls'] = dict(receipt=pin(raw_file), rows=10, scope='Includes mocked shared-error observation; no device execution')
result['nativePaired'], result['threadFixtures'] = [], []
for folder, count in [('scalars-atoms-focused01', 3), ('scalars-focused01', 5)]:
    result['nativePaired'].append(paired(RAW/folder/'paired/report.json', count, 'native'))
    file = RAW/folder/'threads/report.json'
    d = read(file)
    assert pin(d['identity']['api']) == api and len(d['results']) == 2
    for row in [d['identity']['runtime'], d['identity']['driver'], *d['identity']['sources']]:
        pin(row, Path(attempt['snapshot']['root']))
    for row in d['results']:
        assert row['status'] == 'ok' and {x['threads'] for x in row['runs']} == {1, 4}
        assert all(x['pass'] and not x['signal'] and not x['error'] for x in row['runs'])
    result['threadFixtures'].append(dict(receipt=pin(file), fixtures=[x['fixture'] for x in d['results']], threads=[1,4]))
closure = passed(RAW/'unchanged-js-final01.json')
assert closure['candidate'] == attempt_id and closure['frontend']['unchangedFunctionCount'] == 1403
assert closure['unchangedNonNativeFunctions'] == 3066 and closure['excludedPublicRoot'] == 'nc_compile'
result['unchangedJs'] = dict(receipt=pin(RAW/'unchanged-js-final01.json'), frontendFunctions=1403, nonNativeFunctions=3066)
pins_file = RAW/'scalars-build01-b2/image-pins.json'
pins = read(pins_file)
assert pin(pins['attempt']) == attempt_id and pin(pins['b1']) == api
result['b2'] = pin(pins['b2'])
comparison = passed(pins['comparison'])
assert comparison['observations'] == 8
result['driverComparison'] = dict(receipt=pin(pins['comparison']), observations=8)
qualification = RAW/'scalars-build01-qualification'
for name in ['self-check', 'fixed-point', 'b2-programs']:
    file = qualification/name/'report.json'
    d = passed(file)
    assert pin(d['subject']['attempt']) == attempt_id
    if name == 'self-check':
        assert d['image']['sha256'] == result['b2']['sha256'] and d['freshTypeCheck'] and d['expectedProofTrustFailure'] and not d['mathematicalProof']
    elif name == 'fixed-point':
        assert pin(d['b2']) == result['b2'] and d['byteEquality'] and pin(d['b3'])['sha256'] == result['b2']['sha256']
    else:
        assert d['image']['api']['sha256'] == result['b2']['sha256'] and d['counts']['rawByteEqualModules'] == 23 and d['counts']['pointByteEqual'] == 45
        for row in d['emissions']: assert row['byteEqual'] and pin(row['output'])['sha256'] == pin(row['reference'])['sha256']
    result[name] = dict(receipt=pin(file), seconds=d['seconds'])
new_file, old_file = qualification/'b1-programs/manifest.json', OLD/'b1-07-full-acquisition/manifest.json'
new, old = read(new_file), read(old_file)
assert new['complete'] and old['complete'] and len(new['cases']) == len(old['cases']) == 45
assert pin(new['roles']['candidate']['compiler']['api']) == api
for x, y in zip(new['cases'], old['cases']):
    assert all(x[k] == y[k] for k in ['id','point','sourceSha256'])
    assert pin(x['modules']['candidate'], new_file.parent)['sha256'] == pin(y['modules']['candidate'], old_file.parent)['sha256']
result['retainedJs45Bytes'] = dict(current=pin(new_file), previous=pin(old_file), identicalPoints=45, freshRuntimeTiming=False)
result['latency'] = {}
for name, file in [('b1', a.b1_screen), ('b2', a.b2_screen)]:
    d = passed(file)
    assert d['kind'] == 'phase66-clean-latency-summary' and d['sourceCount'] == 2 and d['rounds'] == 2 and d['successfulWorkers'] == d['exactRawOutputs'] == 8
    assert d['roles'] == ['baseline','candidate'] and {x['case'] for x in d['sources']} == {'numeric-recurrence','test-map-set-ops'}
    raw = passed(d['report']);config = read(d['config']);binding = read(config['imageBindings'])
    assert pin(binding['roles']['candidate']['attempt']) == attempt_id
    if name == 'b2': assert pin(binding['roles']['candidate']['emission']) == pin(pins['emission'])
    for row in raw['rows']: assert row['success'] and read(row['result']) == row['observation']
    result['latency'][name] = dict(receipt=pin(file), aggregate=d['aggregate'], sources=d['sources'])
result.update(complete=True, passed=True, mappings=mappings, inputs=list(inputs.values()),
              scope='Selected receipts only. Strict36, native8, four fixtures at threads1/4, actual B2 own-source/fixed-point, JS23/45 bytes and two-source compiler screens. Full conformance, broad TypeScript timing, GPU correctness and release installation are not newly established.')
a.out.parent.mkdir(parents=True, exist_ok=True)
with a.out.open('x') as stream: stream.write(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(output=pin(a.out), passed=True)))
