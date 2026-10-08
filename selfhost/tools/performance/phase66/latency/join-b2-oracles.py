#!/usr/bin/env python3
"""Admit genuine B2 timing outputs only after complete B1/B2 module equality."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase66'
PIN = '059266225b77c8ca256ac6b25ee5c21449bab151'
inputs = {}


def pin(value):
    item = value if isinstance(value, dict) else None
    file = Path(item.get('file', item.get('path')) if item else value).resolve(strict=True)
    row = dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())
    if item:
        assert row['sha256'] == item['sha256'], file
        if 'bytes' in item:
            assert file.stat().st_size == item['bytes'], file
        if 'canonicalPath' in item:
            assert str(file) == item['canonicalPath'], file
    assert str(file) not in inputs or inputs[str(file)] == row
    inputs[str(file)] = row
    return row


def read(value):
    return json.loads(Path(pin(value)['file']).read_text())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--b1-oracles', type=Path, required=True)
    parser.add_argument('--equality', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(RAW) and not out.exists()
    b1_id, equal_id = pin(args.b1_oracles), pin(args.equality)
    b1, equal = read(b1_id), read(equal_id)
    assert b1['kind'] == 'phase61-qualified-compiler-output-oracles'
    assert b1['complete'] and b1['pass'] and b1['upstreamCommit'] == PIN
    assert b1['counts'] == dict(sources=23, points=45)
    assert equal['kind'] == 'phase56-b2-benchmark-byte-equality'
    assert equal['complete'] and equal['pass'] and equal['programsExecuted'] is False
    assert equal['counts']['freshCheckedSources'] == equal['counts']['rawByteEqualModules'] == 23
    assert equal['counts']['pointByteEqual'] == 45
    assert equal['finalVerification']['inputsUnchanged'] and equal['finalVerification']['copiesUnchanged']
    for receipt in [b1, equal]:
        for row in receipt['inputs']:
            pin(row)
    for row in equal['finalVerification']['cacheFiles']:
        pin(row)
    assert pin(equal['reference']) == pin(b1['acquisition'])
    assert pin(equal['subject']['attempt']) == pin(equal['generator']['attempt']) == pin(b1['attempt'])
    assert pin(equal['generator']['api']) == pin(b1['image']['api'])
    assert pin(equal['subject']['source']) == pin(b1['image']['source'])
    attempt = read(b1['attempt'])
    bootstrap = read(attempt['bootstrapReport'])
    assert attempt['checked'] and attempt['config']['strictExact'] and bootstrap['revision'] == PIN
    assert pin(attempt['api']) == pin(b1['image']['api'])
    image = equal['image']
    assert image['kind'] == 'direct-self-emitted-image'
    assert pin(image['checkedSubject']) == pin(b1['attempt'])
    assert pin(image['source']) == pin(b1['image']['source'])
    emission = read(image['emission'])
    assert emission['kind'] == 'phase55-split-compiler-emission'
    assert emission['complete'] and emission['pass']
    assert emission['checking']['lane'] == 'inherited-exact-bootstrap'
    assert pin(emission['generator']['attempt']) == pin(b1['attempt'])
    assert pin(emission['generator']['api']) == pin(b1['image']['api'])
    assert pin(emission['subject']['source']) == pin(b1['image']['source'])
    api = pin(emission['module'])
    assert pin(image['api'])['sha256'] == api['sha256']
    driver_check = read(image['driverQualification'])
    assert driver_check['complete'] and driver_check['pass']
    image_pins = read(image['pins'])
    assert pin(image_pins['b2']) == api
    assert pin(image_pins['attempt']) == pin(b1['attempt'])
    for key in ['runtime', 'base', 'directRuntime', 'driver']:
        assert pin(image[key])['sha256'] == pin(b1['image'][key])['sha256']
    original = read(b1['originalRuntimeCatalog'])
    expected_points = {case['id']: case for case in original['cases']}
    points = {row['id']: row for row in equal['points']}
    assert len(points) == len(equal['points']) == 45 and points.keys() == expected_points.keys()
    for key, row in points.items():
        expected = expected_points[key]
        assert row['byteEqual'] and row['sourceSha256'] == expected['source']['sha256']
        assert row['point'] == expected['point']
        assert pin(row['output'])['sha256'] == pin(row['reference'])['sha256']
    emissions = {row['source']['sha256']: row for row in equal['emissions']}
    assert len(emissions) == len(equal['emissions']) == 23
    cases = []
    for case in b1['cases']:
        row = emissions[case['source']['sha256']]
        assert row['byteEqual'] and row['observation']['checked'] and row['observation']['status'] == 'ok'
        assert pin(row['source'])['sha256'] == case['source']['sha256']
        reference, output = pin(row['reference']), pin(row['output'])
        assert reference['sha256'] == output['sha256'] == pin(case['output'])['sha256']
        checked = read(row['checkedB1Receipt'])
        assert checked['complete'] and checked['observation']['checked'] and checked['observation']['status'] == 'ok'
        assert pin(checked['attempt']) == pin(b1['attempt'])
        assert pin(checked['output']) == reference
        for item in row['emissionInputs']:
            pin(item)
        cases.append({**case, 'output': output, 'b2Equality': equal_id})
    selected_image = {**b1['image'], 'api': api}
    for row in list(inputs.values()):
        pin(row)
    result = dict(kind='phase61-qualified-compiler-output-oracles', complete=True, **{'pass': True},
        dataOnly=True, targetExecuted=False, producer=pin(__file__), backend='direct',
        upstreamCommit=PIN, catalog=b1['catalog'], originalRuntimeCatalog=b1['originalRuntimeCatalog'],
        image=selected_image, attempt=b1['attempt'], checkedB1Oracles=b1_id, b2Equality=equal_id,
        emission=pin(image['emission']), cases=cases, counts=dict(sources=23, points=45),
        selectedCompileInputs=b1['selectedCompileInputs'], semanticQualification=b1['semanticQualification'],
        inputs=list(inputs.values()),
        scope='Genuine self-emitted B2 produced all23 complete raw modules and the45 original point modules byte-identical '
              'to separately executed, fully qualified checked-B1 programs. B2 API identity comes from actual emission; '
              'no fabricated checked sidecar or arbitrary compiler equivalence is inferred.')
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(output=pin(out), targetExecuted=False)))


if __name__ == '__main__':
    main()
