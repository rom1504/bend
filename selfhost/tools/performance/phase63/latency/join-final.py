#!/usr/bin/env python3
"""Join completed State09 evidence; no compiler, tests, installer or archive execution."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase63'
FINAL = RAW / 'final-state09'
INPUTS = {}


def pin(value):
    wanted = value if isinstance(value, dict) else None
    file = Path((value.get('file') or value.get('path')) if wanted else value).resolve(strict=True)
    row = dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest(), bytes=file.stat().st_size)
    if wanted:
        assert row['sha256'] == wanted['sha256'], file
        if 'bytes' in wanted:
            assert row['bytes'] == wanted['bytes'], file
        if 'canonicalPath' in wanted:
            assert str(file) == wanted['canonicalPath'], file
    assert str(file) not in INPUTS or INPUTS[str(file)] == row, file
    INPUTS[str(file)] = row
    return row


def read(value):
    return json.loads(Path(pin(value)['file']).read_text())


def audit(record):
    for item in record.get('inputs', []):
        if isinstance(item, dict) and item.get('sha256') and (item.get('file') or item.get('path')):
            pin(item)


def passed(path, flag='pass'):
    record = read(path)
    assert record['complete'] and record[flag], path
    assert not record.get('changedInputs') and not record.get('error'), path
    audit(record)
    return record


def execution(path, count):
    record = passed(path)
    assert record['returncode'] == 0 and len(record['steps']) == count
    plan = read(record['plan'])
    assert pin(record['plan'])['sha256'] == record['planSha256']
    assert len(plan['commands']) == count
    for actual, expected in zip(record['steps'], plan['commands']):
        assert actual['name'] == expected['name'] and actual['command'] == expected['command']
        assert actual['returncode'] == 0
    return record, plan


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    assert not args.out.exists()
    pin(__file__)
    gates = {}

    def gate(name, path, **facts):
        gates[name] = dict(report=pin(path), **facts)

    attempt_file = RAW/'checked-state09/attempt.json'
    attempt = read(attempt_file)
    assert attempt['checked'] and attempt['config']['strictExact'] and attempt['artifactKind'] == 'derived-b1'
    for key in ['api','checkedApi','runtime','base','bootstrapReport','derivationReport','node']:
        pin(attempt[key])
    for item in attempt['artifacts']:
        pin(item)
    for item in attempt['snapshot']['sources']:
        pin(item['frozen'])
    bootstrap = read(attempt['bootstrapReport'])
    assert bootstrap['provenance']['verifiedAfterBuild']
    assert bootstrap['apiSha256'] == attempt['checkedApi']['sha256']
    for item in bootstrap['provenance']['inputs']:
        pin(item)
    assert pin(bootstrap['source'])['sha256'] == bootstrap['sourceSha256']
    strict_file = RAW/'checked-state09/validation-001/report.json'
    strict = passed(strict_file)
    assert strict['strictExact'] and strict['attempt']['sha256'] == pin(attempt_file)['sha256']
    assert strict['api']['sha256'] == attempt['api']['sha256']
    assert strict['selected']['selectedComplete'] and strict['selected']['exactDifferences'] == strict['selected']['discrepancies'] == 0
    assert all(strict['selected'][role]['statuses']['pass'] == 36 for role in ['candidate','reference'])
    gate('strict36', strict_file, observations=36)

    export_file = RAW/'exports09-reference/api-validation.json'
    exports = passed(export_file)
    assert len(exports['roots']) == len(set(exports['roots'])) == 94
    assert exports['api']['sha256'] == attempt['api']['sha256']
    assert exports['attempt']['sha256'] == pin(attempt_file)['sha256']
    assert exports['roots'] == bootstrap['exports']
    gate('export94', export_file, roots=94)
    execution(FINAL/'checked-execution/report.json', 14)
    gate('checkedB1Matrix', FINAL/'checked-execution/report.json', steps=14)

    def semantics(prefix, composition):
        counts = {}
        for group, expected, key in [('composition',18,'candidatePass'), ('overapplication',2,'candidatePass'),
                                     ('source',96,'candidateSourcePass'), ('numeric',34,'candidatePass')]:
            path = prefix/(composition if group == 'composition' else group+'-controls')/'report.json'
            record = passed(path)
            assert record['counts'][key] == record['counts']['total'] == len(record['observations']) == expected
            candidate_key = 'candidateSourcePass' if group == 'source' else 'candidatePass'
            assert all(row[candidate_key] and row['pass'] for row in record['observations'])
            counts[group] = dict(report=pin(path), candidate=expected, counts=record['counts'])
        return counts

    checked_semantics = semantics(FINAL/'checked', 'composition-controls')
    maintained = passed(FINAL/'checked/maintained8/report.json')
    assert len(maintained['tests']) == 8 and all(x['pass'] for x in maintained['tests'])
    assert maintained['api']['sha256'] == attempt['api']['sha256']
    census = passed(FINAL/'checked/direct-census/report.json')
    assert census['semanticAgreement'] == 26 and census['oraclePass'] and census['referenceOraclePass']
    native = passed(FINAL/'checked/native3/report.json')
    assert len(native['rows']) == 3 and all(x['pass'] and x['byteEqual'] for x in native['rows'])
    smoke = passed(FINAL/'checked/program45-smoke/report.json', 'passed')
    assert len(smoke['cases']) == 45 and all(x['passed'] and x['result']['pass'] for x in smoke['cases'])
    for case in smoke['cases']:
        pin(case['result']['module'])
    for name, rel, count in [('maintained8','maintained8',8),('direct26','direct-census',26),
                             ('native3','native3',3),('program45Smoke','program45-smoke',45)]:
        gate(name, FINAL/'checked'/rel/'report.json', observations=count)

    execution(FINAL/'bootstrap-execution/report.json', 6)
    tiny = passed(FINAL/'bootstrap/tiny/report.json')
    assert tiny['splitEqualsUnsplit'] and tiny['planEqualsCompatibility']
    full = passed(FINAL/'bootstrap/full/report.json')
    comparison = passed(FINAL/'bootstrap/driver-comparison.json')
    assert comparison['observations'] == 8
    image_pins = read(FINAL/'bootstrap/image-pins.json')
    for key in ['producer','plan','attempt','emission','comparison','source','b1','b2','runtime','rootsReference','admission']:
        pin(image_pins[key])
    assert image_pins['attempt']['sha256'] == pin(attempt_file)['sha256']
    assert image_pins['b1']['sha256'] == attempt['api']['sha256']
    assert image_pins['b2']['sha256'] == full['module']['sha256']
    assert image_pins['roots'] == full['roots'] == exports['roots']
    gate('genuineBootstrap', FINAL/'bootstrap/image-pins.json', commands=6, driverObservations=8, tinyPlanEqualsSplitAndCompatibility=True)

    own = passed(FINAL/'self-check/report.json')
    assert own['image']['sha256'] == image_pins['b2']['sha256']
    assert own['freshSelfCheck'] and own['freshTypeCheck'] and own['expectedProofTrustFailure']
    assert own['mathematicalProof'] is False and own['observation']['typeAccepted']
    assert own['observation']['proofTrust'] == 'failed' and own['observation']['kernelChecked'] is False
    assert own['observation']['status'] == 'error' and own['observation']['phase'] == 'verdict'
    assert own['sourceTrustOracle']['definitions'] == own['sourceTrustOracle']['explicitlyUnsafe']
    assert len(own['observation']['unsafeDefinitions']) == own['sourceTrustOracle']['definitions']
    assert own['additionalUnsafeDeclarations'] == [] and own['cacheBefore'] == []
    fixed = passed(FINAL/'fixed-point/report.json')
    assert fixed['byteEquality'] and fixed['b2']['sha256'] == fixed['b3']['sha256'] == image_pins['b2']['sha256']
    pin(fixed['b3'])
    gate('freshB2OwnSource', FINAL/'self-check/report.json', typeAccepted=True, expectedUnsafeTrustRefusal=True,
         unsafeDefinitions=own['sourceTrustOracle']['definitions'], mathematicalProof=False)
    gate('fixedPoint', FINAL/'fixed-point/report.json', exactB2B3Bytes=True)

    parent_failure = read(FINAL/'b2-stage-execution/report.json')
    assert not parent_failure['complete'] and not parent_failure['pass']
    assert [x['returncode'] for x in parent_failure['steps']] == [0,0,0,1]
    old_semantics = read(FINAL/'b2-semantics-execution/report.json')
    assert not old_semantics['complete'] and not old_semantics['pass']
    assert [x['returncode'] for x in old_semantics['steps']] == [0,1]
    failure_file = FINAL/'b2-semantics/composition-controls/report.json'
    failure = read(failure_file)
    assert not failure['complete'] and not failure['pass'] and failure['observations'] == []
    assert 'canonicalPath' in failure['error'] and 'image-provenance.mjs' in failure['error']
    _, resume = execution(FINAL/'b2-semantics-resume02-execution/report.json', 7)
    pin(resume['preservedFailure']);pin(resume['reusedSuccessfulAcquisition'])
    successor = read(resume['successor'])
    assert successor['complete'] and len(successor['rows']) == 5
    for derivative in successor['rows']:
        source = Path(pin(derivative['parent'])['file']).read_text()
        for edit in derivative['edits']:
            assert source.count(edit['old']) == 1
            source = source.replace(edit['old'],edit['new'])
        assert source == Path(pin(derivative['output'])['file']).read_text()
    b2_semantics = semantics(FINAL/'b2-semantics', 'composition-controls-retry02')
    gate('b2SemanticsResume', FINAL/'b2-semantics-resume02-execution/report.json', commands=7,
         preservedFailure=pin(failure_file), acquisitionRepeated=False)

    execution(FINAL/'b2-program-resume-execution/report.json', 1)
    equality = passed(FINAL/'b2-program-equality/report.json')
    assert equality['programsExecuted'] is False and equality['image']['api']['sha256'] == image_pins['b2']['sha256']
    assert equality['generator']['api']['sha256'] == attempt['api']['sha256']
    assert equality['counts'] == dict(freshCheckedSources=23,rawByteEqualModules=23,pointByteEqual=45,uniquePointModules=24,observerModules=1)
    assert len(equality['emissions']) == 23 and len(equality['points']) == 45
    for row in equality['emissions'] + equality['points']:
        assert row['byteEqual'] and pin(row['output'])['sha256'] == pin(row['reference'])['sha256']
    assert len({r['source']['sha256'] for r in equality['emissions']}) == 23
    manifest = read(equality['reference'])
    assert manifest['complete'] and len(manifest['cases']) == 45
    assert {r['id'] for r in manifest['cases']} == {r['id'] for r in equality['points']}
    gate('b2RawProgramEquality', FINAL/'b2-program-equality/report.json', **equality['counts'], programsExecuted=False)

    broad_file = RAW/'state09-b2-latency/broad/report.json'
    broad = passed(broad_file)
    assert broad['successfulWorkers'] == broad['expectedWorkers'] == len(broad['rows']) == 207
    assert len(broad['statistics']) == len(broad['coverage']['compileInputIds']) == 23
    assert broad['coverage']['freshRuntimeExecutions'] == 0
    for row in broad['rows']:
        observation = row['observation']
        assert row['success'] and observation['complete'] and observation['pass']
        assert pin(observation['output'])['sha256'] == pin(observation['expected'])['sha256']
        if row['role'] == 'candidate':
            assert observation['image']['api']['sha256'] == image_pins['b2']['sha256']
    broad_summary_file = ROOT/'implementation/phase63/evidence/state09-broad3.json'
    broad_summary = read(broad_summary_file)
    assert broad_summary['pass_'] and broad_summary['report']['sha256'] == pin(broad_file)['sha256']
    gate('balancedBroadCompilation', broad_summary_file, workers=207, sources=23, rounds=3, freshProgramRuntimeExecutions=0)

    review_file = FINAL/'independent-review.json'
    review = read(review_file)
    assert review['pass'] and review['targetExecuted'] is False
    gate('independentReview', review_file, targetExecuted=False)
    admission_file = RAW/'release-admission.json'
    admission = read(admission_file)
    assert admission['pass']
    gate('rootReleaseAdmission', admission_file)

    release_module = Path(__file__).with_name('join-release.py')
    pin(release_module)
    spec = importlib.util.spec_from_file_location('phase63_release_join',release_module)
    module = importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    release = module.collect(ROOT,pin,read)
    result = dict(kind='phase63-selected-state09-qualification-join',complete=True,pass_=True,
        dataOnly=True,targetExecuted=False,producer=pin(__file__),attempt=pin(attempt_file),
        checkedApi=attempt['checkedApi'],selectedB1=attempt['api'],genuineB2=image_pins['b2'],
        source=image_pins['source'],gates=gates,checkedSemantics=checked_semantics,b2Semantics=b2_semantics,
        performance=broad_summary['summary'],release=release,
        failedParentsPreserved=[pin(FINAL/'b2-stage-execution/report.json'),pin(FINAL/'b2-semantics-execution/report.json'),pin(failure_file)],
        scope='Finite pinned suites with overlapping counts, not full-language conformance. B2 type acceptance and expected unsafe proof-trust refusal are distinct. Raw equality transfers selected program artifacts, not unmeasured runtime speed. Compiler latency uses 23 sources and three medians per role; no significance claim. Failed parents remain failed; exact successful resume receipts close remaining gates.')
    for item in list(INPUTS.values()):
        pin(item)
    result['verifiedInputCount'] = len(INPUTS)
    result['verifiedInputIndexSha256'] = hashlib.sha256(json.dumps(sorted(INPUTS.values(),key=lambda r:r['file']),sort_keys=True).encode()).hexdigest()
    args.out.parent.mkdir(parents=True,exist_ok=True)
    with args.out.open('x') as stream:stream.write(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(output=pin(args.out),complete=True,pass_=True,verifiedInputs=result['verifiedInputCount'])))


if __name__ == '__main__':
    main()
