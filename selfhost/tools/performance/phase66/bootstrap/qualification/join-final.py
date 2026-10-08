#!/usr/bin/env python3
"""Join closed selected-image qualification lanes; never run targets or install."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
RAW = ROOT/'selfhost/build/phase66'
inputs = {}


def pin(value):
    item = value if isinstance(value, dict) else None
    file = Path(item.get('file', item.get('path')) if item else value).resolve(strict=True)
    data = file.read_bytes()
    row = dict(file=str(file), sha256=hashlib.sha256(data).hexdigest())
    if item:
        assert row['sha256'] == item['sha256'], file
        if 'bytes' in item:
            assert len(data) == item['bytes'], file
        if 'canonicalPath' in item:
            assert str(file) == item['canonicalPath'], file
    assert row['file'] not in inputs or inputs[row['file']] == row
    inputs[row['file']] = row
    return row


def read(value):
    return json.loads(Path(pin(value)['file']).read_text())


def audit(record):
    for item in record.get('inputs', []):
        pin(item)
    if 'producer' in record:
        pin(record['producer'])


def complete(value, require_pass=True):
    result = read(value)
    assert result['complete'] is True
    if require_pass:
        assert result['pass'] is True
    audit(result)
    return result


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--gate-plan', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    assert not a.out.exists()
    plan = read(a.gate_plan)
    assert plan['complete'] is False and plan['qualified'] is False and plan['targetExecuted'] is False
    rows = {row['role']: row for row in plan['required']}
    assert len(rows) == len(plan['required'])
    assert set(rows) == {'strict36', 'exports99', 'selfhosting', 'semantics', 'conformance',
        'native', 'baseHost', 'performance', 'printability', 'minWideSources', 'widePrivate18'}
    receipts = {}
    for name, row in rows.items():
        receipt = pin(row['file'])
        if row['identityAtPreparation'] is not None:
            assert receipt == pin(row['identityAtPreparation'])
        receipts[name] = receipt
    attempt_pin = pin(plan['attempt'])
    attempt = read(attempt_pin)
    assert attempt['checked'] and attempt['config']['strictExact'] and attempt['artifactKind'] == 'derived-b1'
    for key in ['api', 'checkedApi', 'runtime', 'base', 'node', 'bootstrapReport', 'derivationReport']:
        pin(attempt[key])
    for row in attempt['snapshot']['sources']:
        pin(row['frozen'])
    bootstrap = read(attempt['bootstrapReport'])
    assert bootstrap['revision'] == '059266225b77c8ca256ac6b25ee5c21449bab151'
    assert bootstrap['apiSha256'] == attempt['checkedApi']['sha256']
    assert bootstrap['provenance']['verifiedAfterBuild']
    for item in bootstrap['provenance']['inputs']:
        pin(item)
    assert pin(bootstrap['source']) == pin(plan['source'])
    assert pin(attempt['api']) == pin(plan['selectedB1'])
    derivation = complete(attempt['derivationReport'], False)
    assert derivation['transform']['version'] == 7
    assert pin(derivation['output']) == pin(attempt['api'])
    image = read(plan['imagePins'])
    assert pin(image['attempt']) == attempt_pin
    assert pin(image['source']) == pin(plan['source'])
    assert pin(image['b1']) == pin(plan['selectedB1'])
    assert pin(image['b2']) == pin(plan['selectedB2'])

    strict = complete(receipts['strict36'])
    assert strict['strictExact'] and pin(strict['attempt']) == attempt_pin
    assert pin(strict['api']) == pin(attempt['api'])
    assert strict['selected']['selectedComplete']
    assert strict['selected']['exactDifferences'] == strict['selected']['discrepancies'] == 0
    assert all(strict['selected'][role]['statuses']['pass'] == 36 for role in ['reference', 'candidate'])
    exports = complete(receipts['exports99'])
    assert pin(exports['attempt']) == attempt_pin and pin(exports['api']) == pin(attempt['api'])
    assert exports['roots'] == image['roots'] == bootstrap['exports']
    assert len(exports['roots']) == len(set(exports['roots'])) == 99

    own = complete(receipts['selfhosting'])
    semantics = complete(receipts['semantics'])
    assert own['kind'] == 'phase66-selected-selfhosting-program-audit'
    assert semantics['kind'] == 'phase66-selected-semantic-qualification-audit'
    for record in [own, semantics]:
        assert pin(record['attempt']) == attempt_pin
        assert pin(record['selectedB1']) == pin(image['b1'])
        assert pin(record['selectedB2']) == pin(image['b2'])
        assert pin(record['source']) == pin(image['source'])
        assert pin(record['imagePins']) == pin(plan['imagePins'])
    assert own['mathematicalProof'] is False
    assert (own['exports'], own['driverObservations'], own['rawModules'], own['programPoints']) == (99, 8, 23, 45)
    assert len(semantics['groups']) == 8
    assert {(row['role'], row['name']) for row in semantics['groups']} == {
        (role, name) for role in ['checked', 'b2'] for name in ['source', 'numeric', 'composition', 'overapplication']}
    semantic_counts = {}
    for row in semantics['groups']:
        record = complete(row['report'])
        acquisition = read(row['acquisition'])
        assert acquisition['complete'] and acquisition['passed']
        assert record['counts'] == row['counts']
        total = dict(source=96, numeric=34, composition=18, overapplication=2)[row['name']]
        key = 'candidateSourcePass' if row['name'] == 'source' else 'candidatePass'
        assert record['counts'][key] == record['counts']['total'] == total
        assert len(record['observations']) == total and all(item['pass'] for item in record['observations'])
        semantic_counts[row['role']+'/'+row['name']] = row['counts']
    maintained = complete(semantics['maintained8'])
    assert pin(maintained['attempt']) == attempt_pin
    assert len(maintained['tests']) == 8 and all(row['pass'] for row in maintained['tests'])

    conformance = complete(receipts['conformance'], False)
    assert conformance['kind'] == 'phase66-selected07-conformance-lanes'
    assert pin(conformance['selectedAttempt']) == attempt_pin
    assert pin(conformance['selectedApi']) == pin(attempt['api'])
    assert conformance['exactFrontendObservations'] == 3174
    assert conformance['noUnexplainedCandidateOnlyGaps']
    assert conformance['referencePassingCandidateFailures'] == []
    for lane in conformance['primaryJavaScript'].values():
        assert lane['observations'] == sum(lane['statuses'].values()) == 1170
        pin(lane['report'])
    assert len(conformance['retainedDirectSubset']['observations']) == 25
    assert len(conformance['retainedDirectSubset']['deleted']) == 1
    assert conformance['supplementalBun']['summary'] == {'pass': 54, 'fail': 1, 'deferred-environment': 1}
    assert conformance['supplementalBun']['unchangedEmittedModules']
    assert conformance['supplementalBun']['programsRerun'] is False

    native = complete(receipts['native'])
    assert pin(native['selectedAttempt']) == attempt_pin
    assert pin(native['selectedApi']) == pin(attempt['api'])
    assert isinstance(native['unsupportedNative'], list) and native['unsupportedNative']
    host = complete(receipts['baseHost'])
    assert pin(host['attempt']) == attempt_pin
    assert pin(host['selectedB1']) == pin(image['b1'])
    assert pin(host['selectedB2']) == pin(image['b2'])
    assert pin(host['imagePins']) == pin(plan['imagePins'])

    performance = complete(receipts['performance'])
    assert performance['kind'] == 'phase66-selected-performance-summary'
    for generation, api in [('b1', image['b1']), ('b2', image['b2'])]:
        measurement = performance['compilation'][generation]
        assert measurement['workers'] == 207 and measurement['sources'] == 23
        summary = complete(measurement['summary'])
        selected = summary['images']['candidate']
        assert pin(selected['checkedGenerator']) == attempt_pin
        assert pin(selected['api'])['sha256'] == api['sha256']
        assert pin(selected['source']) == pin(image['source'])
        assert pin(selected['runtime'])['sha256'] == attempt['runtime']['sha256']
        assert pin(selected['base'])['sha256'] == attempt['base']['sha256']
        assert pin(selected['driver'])['sha256'] == pin(Path(attempt['snapshot']['root'])/'tools/typed-driver.mjs')['sha256']
        if generation == 'b2':
            assert pin(selected['emission']) == pin(image['emission'])
        else:
            assert selected['emission'] is None
    assert performance['execution']['points'] == 45 and performance['execution']['sources'] == 23
    assert performance['execution']['samples'] == 669

    printable = complete(receipts['printability'])
    printable_plan = read(printable['plan'])
    assert printable['planSha256'] == pin(printable['plan'])['sha256']
    assert pin(printable_plan['attempt']) == attempt_pin
    assert len(printable['steps']) == 2 and printable['returncode'] == 0
    for command, step in zip(printable_plan['commands'], printable['steps']):
        assert command['command'] == step['command'] and step['returncode'] == 0
    # The selected-image controllers retain independent semantic oracles, not just exit codes.
    private = complete(RAW/'printable-controls07-01/report.json')
    assert pin(private['roles']['candidate']['attempt']) == attempt_pin
    assert private['agreements'] == 28 and len(private['roles']['candidate']['cases']) == 31
    assert all(row['pass'] for row in private['roles']['candidate']['cases'])
    source2 = read(RAW/'printable-source07-01/bend-candidate-new-base/js/report.json')
    source5 = read(receipts['minWideSources'])
    for record, count in [(source2, 2), (source5, 5)]:
        # Selected reports intentionally leave whole-inventory complete=false.
        assert record['selectedComplete'] and record['finished'] and not record['changedInputs']
        assert len(record['selection']['requested']) == count
        assert {(row['id'], row['lane']) for row in record['results']} == {
            (row['id'], row['lane']) for row in record['selection']['requested']}
        assert len(record['results']) == count and all(row['status'] == 'pass' for row in record['results'])
        artifacts = record['identity']['artifacts']
        assert artifacts['compiler']['sha256'] == attempt['api']['sha256']
        assert artifacts['base']['sha256'] == attempt['base']['sha256']
        assert artifacts['runtime']['sha256'] == attempt['runtime']['sha256']
        assert artifacts['driver']['sha256'] == pin(Path(attempt['snapshot']['root'])/'tools/typed-driver.mjs')['sha256']
        for name, sha in record['inputHashes'].items():
            pin(dict(file=name, sha256=sha))
        for item in record['identity']['artifacts'].values():
            pin(item)
    wide = complete(receipts['widePrivate18'])
    assert pin(wide['attempt']) == attempt_pin and pin(wide['api']) == pin(attempt['api'])
    assert len(wide['cases']) == 18 and all(row['pass'] for row in wide['cases'])
    for item in list(inputs.values()):
        pin(item)
    result = dict(kind='phase66-selected07-pre-release-qualification', complete=True, **{'pass': True},
        dataOnly=True, targetExecuted=False, producer=pin(__file__), gatePlan=pin(a.gate_plan),
        attempt=attempt_pin, selectedB1=pin(image['b1']), genuineB2=pin(image['b2']),
        source=pin(image['source']), gates=receipts, semanticCounts=semantic_counts,
        primaryJavaScript={name: row['statuses'] for name, row in conformance['primaryJavaScript'].items()},
        supplementalBun=conformance['supplementalBun'], mixedRuntimeCoverage=conformance['mixedRuntimeCoverage'],
        unsupportedNative=native['unsupportedNative'],
        performance=dict(compilation=performance['compilation'], execution=performance['execution']),
        release=dict(installedByThisJoin=False, admissionGranted=False),
        verifiedInputCount=len(inputs),
        verifiedInputIndexSha256=hashlib.sha256(json.dumps(sorted(inputs.values(), key=lambda row: row['file']), sort_keys=True).encode()).hexdigest(),
        scope='Selected actual07 finite overlapping qualification suites, preserved upstream oracle failures and environment limits. No all1170-pass, universal conformance, mathematical proof, speedup, or installation claim. Compiler latency and generated-program runtime remain separate clocks. Root preservation/admission and installed release checks are separate.')
    a.out.parent.mkdir(parents=True, exist_ok=True)
    with a.out.open('x') as stream:
        stream.write(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(output=pin(a.out), complete=True, passed=True, verifiedInputs=len(inputs))))


if __name__ == '__main__':
    main()
