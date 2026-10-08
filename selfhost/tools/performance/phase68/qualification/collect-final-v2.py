#!/usr/bin/env python3
"""Join selected B1/B2 and JS/native-request receipts; data only, no targets."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT/'selfhost/build/phase68'
inputs = {}


def pin(value, base=ROOT):
    expected = value if isinstance(value, dict) else None
    file = (base/Path(expected.get('file', expected.get('path')) if expected else value)).resolve(strict=True)
    key = str(file)
    if key not in inputs:
        inputs[key] = dict(file=key, sha256=hashlib.sha256(file.read_bytes()).hexdigest())
    result = inputs[key]
    if expected:
        assert result['sha256'] == expected['sha256'], file
        if 'bytes' in expected:
            assert file.stat().st_size == expected['bytes'], file
    return result


def read(value, base=ROOT):
    return json.loads(Path(pin(value, base)['file']).read_text())


def passed(file):
    result = read(file)
    assert result['complete'] and (result.get('pass') is True or result.get('passed') is True), file
    for item in result.get('inputs', []):
        pin(item)
    return result


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--methods', type=Path, required=True)
parser.add_argument('--native-compilation', type=Path, required=True, help='Closed actual selected B1/B2 native-request analysis')
parser.add_argument('--out', type=Path, required=True)
args = parser.parse_args()
output = args.out.resolve()
assert output.is_relative_to(RAW) and not output.exists()
methods = read(args.methods)
assert methods['kind'] == 'phase68-reused-final-methods' and methods['complete'] and methods['dataOnly']
pin(methods['producer']);pin(methods['parentMethods'])
method_pins = {}
for row in methods['methods']:
    pin(row['parent'])
    method_pins[Path(row['output']['file']).relative_to(args.methods.resolve().parent).as_posix()] = pin(row['output'])
attempt_id = pin(methods['selectedAttempt'])
attempt = read(attempt_id)
assert attempt['checked'] and attempt['config']['strictExact']
assert Path(methods['attempt'])/'attempt.json' == Path(attempt_id['file'])
api = pin(attempt['api'])
baseline = read(methods['baselineAttempt'])
source_maps = []
for record in (baseline, attempt):
    source_maps.append({str(Path(row['frozen']['file']).relative_to(record['snapshot']['root'])): pin(row['frozen'])
        for row in record['snapshot']['sources']})
changed = [dict(path=k, baseline=source_maps[0].get(k), candidate=source_maps[1].get(k))
    for k in sorted(source_maps[0].keys() | source_maps[1].keys())
    if source_maps[0].get(k, {}).get('sha256') != source_maps[1].get(k, {}).get('sha256')]
assert methods['changedInputs'] == changed
for item in attempt['artifacts']:
    pin(item)
qualification = Path(methods['qualification'])
validation_file = Path(methods['attempt'])/'validation-001/report.json'
validation = passed(validation_file)
assert pin(validation['attempt']) == attempt_id and pin(validation['api']) == api and validation['strictExact']
assert validation['selected']['exactDifferences'] == validation['selected']['discrepancies'] == 0
selected = read(validation['selected']['file'])
assert selected['selectedComplete'] and not selected['missing'] and not selected['discrepancies']
assert len(selected['rows']) == 36
assert all(row['lane'] == 'check' and row['exactAgreement'] and row['semanticAgreement'] and
    row['referenceVerdict'] == row['candidateVerdict'] == 'pass' for row in selected['rows'])

closure_file = qualification/'unchanged-js.json'
closure = passed(closure_file)
assert closure['kind'] == 'phase68-js-frontend-driver-closure'
assert pin(methods['closureMethod']) in [pin(item) for item in closure['inputs']]
assert pin(closure['candidate']) == attempt_id and pin(closure['baseline']) == pin(methods['baselineAttempt'])
assert closure['changedInputs'] == changed and closure['driverRoots']
assert set(closure['frontend']['roots']) <= set(closure['driverRoots'])
assert closure['nativeGuardedArms'] and not closure['targetExecuted']
pins_file = Path(methods['bootstrap'])/'image-pins.json'
pins = read(pins_file)
assert pins['kind'] == 'phase56-direct-image-pins'
assert pin(pins['producer']) == method_pins['bootstrap/prepare-bootstrap.py']
assert pin(pins['attempt']) == attempt_id and pin(pins['b1']) == api
pin(pins['plan']);pin(pins['runtime'])
b2 = pin(pins['b2'])
emission = passed(pins['emission'])
assert pin(emission['generator']['attempt']) == pin(emission['subject']['attempt']) == attempt_id
assert pin(emission['generator']['api']) == api and pin(emission['module']) == b2
bootstrap = read(attempt['bootstrapReport'])
assert pin(pins['source'])['sha256'] == bootstrap['sourceSha256']
assert pin(emission['subject']['source']) == pin(pins['source'])
comparison = passed(pins['comparison'])
assert comparison['observations'] == 8
result = dict(kind='phase68-selected-image-qualification', dataOnly=True, targetsExecuted=False,
    producer=pin(__file__), predecessorMethod=pin(ROOT/'selfhost/tools/performance/phase67/latency/collect-final.py'),
    methods=pin(args.methods), attempt=attempt_id, b1=api, b2=b2, changedInputs=changed,
    strict36=pin(validation_file), unchangedJs=pin(closure_file),
    unchangedJsScope=dict(driverRoots=closure['driverRoots'], excludedPublicRoots=closure['excludedPublicRoots'],
        stronger98RootGate=closure['stronger98RootGate']), imagePins=pin(pins_file),
    driverComparison=pin(pins['comparison']), releaseIncluded=False)

for name, method in [('self-check', 'qualification/self-check.mjs'),
                     ('fixed-point', 'bootstrap/reproduce.mjs'),
                     ('b2-programs', 'qualification/benchmark-equality.mjs')]:
    file = qualification/name/'report.json'
    row = passed(file)
    assert pin(row['subject']['attempt']) == attempt_id
    if name != 'b2-programs':
        assert pin(row['producer']) == method_pins[method]
    else:
        assert method_pins[method] in [pin(x) for x in row['inputs']]
    if name == 'self-check':
        assert row['image']['sha256'] == b2['sha256']
        assert row['freshTypeCheck'] and row['expectedProofTrustFailure'] and not row['mathematicalProof']
    elif name == 'fixed-point':
        assert pin(row['b2']) == b2 and row['byteEquality'] and pin(row['b3'])['sha256'] == b2['sha256']
    else:
        assert row['image']['api']['sha256'] == b2['sha256']
        assert row['counts']['rawByteEqualModules'] == 23 and row['counts']['pointByteEqual'] == 45
        assert pin(row['reference']) == pin(qualification/'b1-programs/manifest.json')
        for item in row['emissions']:
            assert item['byteEqual'] and pin(item['output'])['sha256'] == pin(item['reference'])['sha256']
    result[name] = dict(receipt=pin(file), seconds=row['seconds'])

current_file = qualification/'b1-programs/manifest.json'
previous_file = Path(methods['baselineJsManifest']['file'])
current, previous = read(current_file), read(methods['baselineJsManifest'])
assert current['complete'] and previous['complete'] and len(current['cases']) == len(previous['cases']) == 45
assert current['catalogSha256'] == previous['catalogSha256']
assert pin(current['roles']['candidate']['compiler']['api']) == api
assert pin(previous['roles']['candidate']['compiler']['api']) == pin(baseline['api'])
for a, b in zip(current['cases'], previous['cases']):
    assert all(a[k] == b[k] for k in ['id', 'point', 'sourceSha256'])
    assert pin(a['modules']['candidate'], current_file.parent)['sha256'] == pin(b['modules']['candidate'], previous_file.parent)['sha256']
result['retainedJs45Bytes'] = dict(current=pin(current_file), previous=pin(previous_file), identicalPoints=45, freshRuntimeTiming=False)

native = read(args.native_compilation)
assert native['kind'] == 'phase68-native-request-analysis' and native['complete'] and not native['missingJobs']
for item in native['inputs']:
    pin(item)
plan = read(native['plan'])
assert pin(plan['attempt']) == attempt_id and pin(plan['imagePins']) == pin(pins_file)
assert pin(plan['roles']['b1']['api']) == api and pin(plan['roles']['b2']['api']) == b2
assert set(plan['cases']) == {'numeric', 'array', 'lexer'}
assert len(native['observations']) == len(plan['jobs']) == native['closedJobs'] == native['plannedJobs']
seen = set()
for observation in native['observations']:
    job = observation['job']
    assert job in plan['jobs'] and job['name'] not in seen
    seen.add(job['name'])
    report = passed(observation['report'])
    assert report['inputsUnchanged'] and report['job'] == job and pin(report['plan']) == pin(native['plan'])
    if job['action'] == 'request':
        assert report['exactC'] and pin(report['output'])['sha256'] == pin(report['oracle'])['sha256']
result['nativeCompilation'] = dict(receipt=pin(args.native_compilation), clean=native['clean'],
    profiles=len(native['profiles']), scope='Imports, preparation and native-request clocks are separate. Profiled jobs are excluded from clean timings; no Clang or executable timing is synthesized.')

for item in inputs.values():
    assert hashlib.sha256(Path(item['file']).read_bytes()).hexdigest() == item['sha256'], item['file']
result.update(complete=True, passed=True, inputs=list(inputs.values()),
    scope='Selected B1 strict36, exact JS/frontend driver-route reachable closure, actual B2 own-source check and fixed point, fresh JS23/45 exact bytes, and actual selected B1/B2 native-request observations. Native runtime/control selection, broad conformance, GPU correctness, installation and speed promotion remain separate receipts.')
output.parent.mkdir(parents=True, exist_ok=True)
with output.open('x') as stream:
    stream.write(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(output=pin(output), passed=True)))
