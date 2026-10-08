#!/usr/bin/env python3
"""Join completed Phase64 compiler gates, without running targets or authorizing release."""
import argparse
import hashlib
import importlib.util
import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase64'
FINAL = RAW / 'final-state09'
PLANS = RAW / 'final-state09-plans'
PARENT = ROOT / 'selfhost/tools/performance/phase63/latency/join-final.py'
PARENT_SHA = 'fea5078e72aa4c3626366590f3584f16c846b3776fbd1e7125aad784e9598602'
assert hashlib.sha256(PARENT.read_bytes()).hexdigest() == PARENT_SHA
spec = importlib.util.spec_from_file_location('phase63_receipt_readers', PARENT)
parent = importlib.util.module_from_spec(spec)
spec.loader.exec_module(parent)
pin, read, passed, audit, execution = parent.pin, parent.read, parent.passed, parent.audit, parent.execution


def historical_context(path, selected_snapshot):
    """Resolve one recorded State08 workflow identity to its exact retained snapshot."""
    record = read(path)
    assert record['complete'] and record['pass'] and not record.get('changedInputs') and not record.get('error')
    old_attempt_file = RAW/'checked-state08/attempt.json'
    old_attempt = read(old_attempt_file)
    logical = str(ROOT/'selfhost/tools/development/workflow.mjs')
    expected_sha = '54d4e745908cfd6119e8c548927c78f8380a4b0c5704c9d65b5b24a12b8a36a1'
    retained = Path(old_attempt['snapshot']['root'])/'tools/development/workflow.mjs'
    source = next(x for x in old_attempt['snapshot']['sources'] if x['original']['file'] == logical)
    assert source['original']['sha256'] == source['frozen']['sha256'] == expected_sha
    assert Path(source['frozen']['file']) == retained
    retained_pin = pin(source['frozen'])
    current = pin(logical)
    assert current['sha256'] == pin(selected_snapshot/'tools/development/workflow.mjs')['sha256']
    relocations = []
    for item in record['inputs']:
        if not isinstance(item, dict) or not item.get('sha256') or not (item.get('file') or item.get('path')):
            continue
        if item.get('file') == logical and item['sha256'] == expected_sha:
            assert item['bytes'] == retained_pin['bytes']
            relocations.append(dict(logical=item, retained=retained_pin, current=current, snapshotAttempt=pin(old_attempt_file),
                reason='State08 control recorded the pre-frame4 workflow; exact frozen bytes remain in its checked snapshot.'))
        else:
            pin(item)
    assert len(relocations) == 1
    return record, relocations


def required_receipts():
    paths = [RAW/'checked-state09/attempt.json', RAW/'checked-state09/validation-001/report.json',
             RAW/'export-reference-state09/api-validation.json', PLANS/'index.json',
             PLANS/'reused-bootstrap-image-pins.json', RAW/'bootstrap-state09/image-pins.json',
             RAW/'context-state08/report.json', RAW/'arena-host-state09/report.json',
             RAW/'arena-domain02/report.json', RAW/'arena-migration-state09/report.json',
             RAW/'state09-b2-latency/broad/report.json',
             ROOT/'implementation/phase64/evidence/state09-b2-broad.json']
    paths += [FINAL/f'{name}-stage-execution/report.json' for name in ['checked', 'bootstrap', 'b2']]
    paths += [FINAL/x/'report.json' for x in ['checked-execution', 'self-check', 'fixed-point',
              'b2-semantics-execution', 'b2-program-equality', 'checked/maintained8',
              'checked/direct-census', 'checked/native3', 'checked/program45-smoke']]
    paths += [FINAL/lane/(group+'-controls')/'report.json'
              for lane in ['checked', 'b2-semantics']
              for group in ['composition', 'overapplication', 'source', 'numeric']]
    return paths


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--plan-only', action='store_true', help='Record pending paths only; never mark qualification passing.')
    args = parser.parse_args()
    assert not args.out.exists()
    pin(__file__); pin(PARENT)
    derivation_file = Path(__file__).with_suffix('.derivation.json')
    derivation = read(derivation_file)
    assert pin(derivation['output'])['file'] == str(Path(__file__).resolve())
    rebuilt = Path(pin(derivation['parent'])['file']).read_text()
    for change in derivation['edits']:
        assert rebuilt.count(change['old']) == 1
        rebuilt = rebuilt.replace(change['old'], change['new'])
    assert rebuilt == Path(__file__).read_text()
    if args.plan_only:
        result = dict(kind='phase64-final-qualification-pending-plan', complete=False, pass_=False,
                      status='pending-targets', dataOnly=True, targetExecuted=False,
                      producer=pin(__file__), inheritedReceiptReaders=pin(PARENT), successorDerivation=pin(derivation_file),
                      receipts=[dict(file=str(p), present=p.is_file()) for p in required_receipts()],
                      scope='Presence is not validation. No gate, installation or promotion is asserted.')
        write(args.out, result)
        return

    gates = {}
    def gate(name, path, **facts):
        gates[name] = dict(report=pin(path), **facts)

    attempt_file = RAW/'checked-state09/attempt.json'
    attempt = read(attempt_file)
    assert attempt['checked'] and attempt['config']['strictExact'] and attempt['artifactKind'] == 'derived-b1'
    for key in ['api', 'checkedApi', 'runtime', 'base', 'bootstrapReport', 'derivationReport', 'node']:
        pin(attempt[key])
    for item in attempt['artifacts']: pin(item)
    for item in attempt['snapshot']['sources']: pin(item['frozen'])
    bootstrap = read(attempt['bootstrapReport'])
    assert bootstrap['provenance']['verifiedAfterBuild']
    assert bootstrap['apiSha256'] == attempt['checkedApi']['sha256']
    for item in bootstrap['provenance']['inputs']: pin(item)
    assert pin(bootstrap['source'])['sha256'] == bootstrap['sourceSha256']
    strict_file = RAW/'checked-state09/validation-001/report.json'
    strict = passed(strict_file)
    assert strict['strictExact'] and strict['attempt']['sha256'] == pin(attempt_file)['sha256']
    assert strict['api']['sha256'] == attempt['api']['sha256']
    assert strict['selected']['selectedComplete'] and strict['selected']['exactDifferences'] == strict['selected']['discrepancies'] == 0
    assert all(strict['selected'][role]['statuses']['pass'] == 36 for role in ['candidate', 'reference'])
    gate('strict36', strict_file, observations=36)
    export_file = RAW/'export-reference-state09/api-validation.json'
    exports = passed(export_file)
    assert len(exports['roots']) == len(set(exports['roots'])) == 95
    assert exports['api']['sha256'] == attempt['api']['sha256']
    assert exports['attempt']['sha256'] == pin(attempt_file)['sha256']
    assert exports['roots'] == bootstrap['exports']
    gate('export95', export_file, roots=95)

    index = read(PLANS/'index.json'); audit(index)
    assert index['attempt']['sha256'] == pin(attempt_file)['sha256']
    assert index['out'] == str(FINAL) and index['executed'] is False
    stages = {row['name']: row for row in index['stages']}
    for name, count in [('checked', 2), ('bootstrap', 1), ('b2', 5)]:
        record, plan = execution(FINAL/f'{name}-stage-execution/report.json', count)
        assert pin(record['plan'])['sha256'] == pin(stages[name]['planIdentity'])['sha256']
        assert plan['attempt']['sha256'] == pin(attempt_file)['sha256']; audit(plan)
        gate(name+'Stage', FINAL/f'{name}-stage-execution/report.json', commands=count)
    assert index['bootstrapReuse']['newEmission'] is False
    execution(FINAL/'checked-execution/report.json', 14)

    def semantics(lane):
        counts = {}
        for group, expected, key in [('composition', 18, 'candidatePass'), ('overapplication', 2, 'candidatePass'),
                                     ('source', 96, 'candidateSourcePass'), ('numeric', 34, 'candidatePass')]:
            file = FINAL/lane/(group+'-controls')/'report.json'
            record = passed(file)
            assert record['counts'][key] == record['counts']['total'] == len(record['observations']) == expected
            assert all(row[key] and row['pass'] for row in record['observations'])
            counts[group] = dict(report=pin(file), candidate=expected, counts=record['counts'])
        return counts
    checked_semantics = semantics('checked')
    maintained = passed(FINAL/'checked/maintained8/report.json')
    assert len(maintained['tests']) == 8 and all(x['pass'] for x in maintained['tests'])
    assert maintained['api']['sha256'] == attempt['api']['sha256']
    census = passed(FINAL/'checked/direct-census/report.json')
    assert census['semanticAgreement'] == 26 and census['oraclePass'] and census['referenceOraclePass']
    native = passed(FINAL/'checked/native3/report.json')
    assert len(native['rows']) == 3 and all(x['pass'] and x['byteEqual'] for x in native['rows'])
    smoke = passed(FINAL/'checked/program45-smoke/report.json', 'passed')
    assert len(smoke['cases']) == 45 and all(x['passed'] and x['result']['pass'] for x in smoke['cases'])
    for case in smoke['cases']: pin(case['result']['module'])
    for name, rel, count in [('maintained8', 'maintained8', 8), ('direct26', 'direct-census', 26),
                             ('native3', 'native3', 3), ('program45Smoke', 'program45-smoke', 45)]:
        gate(name, FINAL/'checked'/rel/'report.json', observations=count)

    pins_file = PLANS/'reused-bootstrap-image-pins.json'
    image = read(pins_file)
    origin = read(index['bootstrapReuse']['imagePins'])
    assert image == origin, 'Rebound image pins must retain exact selected construction provenance'
    for key in ['producer', 'plan', 'attempt', 'emission', 'comparison', 'source', 'b1', 'b2', 'runtime', 'rootsReference', 'admission']:
        pin(image[key])
    assert image['attempt']['sha256'] == pin(attempt_file)['sha256']
    assert image['b1']['sha256'] == attempt['api']['sha256']
    full = passed(image['emission']); tiny = passed(full['qualification']); comparison = passed(image['comparison'])
    assert tiny['splitEqualsUnsplit'] and tiny['planEqualsCompatibility'] and comparison['observations'] == 8
    assert image['b2']['sha256'] == full['module']['sha256']
    assert image['roots'] == full['roots'] == exports['roots']
    assert image['source']['sha256'] == bootstrap['sourceSha256']
    gate('genuineBootstrap', pins_file, newEmission=False, driverObservations=8, tinyPlanEqualsSplitAndCompatibility=True)
    own = passed(FINAL/'self-check/report.json')
    assert own['image']['sha256'] == image['b2']['sha256']
    assert own['freshSelfCheck'] and own['freshTypeCheck'] and own['expectedProofTrustFailure']
    assert own['mathematicalProof'] is False and own['observation']['typeAccepted']
    assert own['observation']['proofTrust'] == 'failed' and own['observation']['kernelChecked'] is False
    assert own['observation']['status'] == 'error' and own['observation']['phase'] == 'verdict'
    assert own['sourceTrustOracle']['definitions'] == own['sourceTrustOracle']['explicitlyUnsafe']
    assert len(own['observation']['unsafeDefinitions']) == own['sourceTrustOracle']['definitions']
    assert own['additionalUnsafeDeclarations'] == [] and own['cacheBefore'] == []
    fixed = passed(FINAL/'fixed-point/report.json')
    assert fixed['byteEquality'] and fixed['b2']['sha256'] == fixed['b3']['sha256'] == image['b2']['sha256']; pin(fixed['b3'])
    gate('freshB2OwnSource', FINAL/'self-check/report.json', typeAccepted=True, expectedUnsafeTrustRefusal=True,
         unsafeDefinitions=own['sourceTrustOracle']['definitions'], mathematicalProof=False)
    gate('fixedPoint', FINAL/'fixed-point/report.json', exactB2B3Bytes=True)
    execution(FINAL/'b2-semantics-execution/report.json', 8)
    b2_semantics = semantics('b2-semantics')
    equality_file = FINAL/'b2-program-equality/report.json'
    equality = passed(equality_file)
    assert equality['programsExecuted'] is False and equality['image']['api']['sha256'] == image['b2']['sha256']
    assert equality['generator']['api']['sha256'] == attempt['api']['sha256']
    assert equality['counts'] == dict(freshCheckedSources=23, rawByteEqualModules=23, pointByteEqual=45, uniquePointModules=24, observerModules=1)
    assert len(equality['emissions']) == 23 and len(equality['points']) == 45
    for row in equality['emissions'] + equality['points']:
        assert row['byteEqual'] and pin(row['output'])['sha256'] == pin(row['reference'])['sha256']
    assert len({row['source']['sha256'] for row in equality['emissions']}) == 23
    manifest = read(equality['reference'])
    assert manifest['complete'] and len(manifest['cases']) == 45
    assert {x['id'] for x in manifest['cases']} == {x['id'] for x in equality['points']}
    gate('b2RawProgramEquality', equality_file, **equality['counts'], programsExecuted=False)

    context_file = RAW/'context-state08/report.json'
    context, historical_relocations = historical_context(context_file, Path(attempt['snapshot']['root']))
    assert context['roles']['candidate']['api']['sha256'] == attempt['api']['sha256']
    assert len(context['todoControls']) == 9 and all(x['pass'] for x in context['todoControls'])
    assert context['contextControls'] and all(x['pass'] for x in context['contextControls'])
    assert any(x['optimized'] and x['syntheticDefinitions'] for x in context['contextControls'])
    assert any(not x['optimized'] for x in context['contextControls'])
    gate('exactCheckedContext', context_file, sameSelectedApi=True, contexts=len(context['contextControls']), todoCases=9)
    snapshot = Path(attempt['snapshot']['root'])
    arena_file = RAW/'arena-host-state09/report.json'; arena = read(arena_file)
    assert arena['pass'] and len(arena['controls']) == 79 and all(x['pass'] for x in arena['controls'])
    for key in ['driver', 'helper', 'controller', 'derivation', 'instrumented', 'cache', 'base']: pin(arena[key])
    assert arena['driver']['sha256'] == pin(snapshot/'tools/typed-driver.mjs')['sha256']
    assert arena['helper']['sha256'] == pin(snapshot/'tools/base-cache-graph.mjs')['sha256']
    gate('arenaHostRollout', arena_file, controls=len(arena['controls']))
    domain_file = RAW/'arena-domain02/report.json'; domain = read(domain_file); audit(domain)
    assert domain['pass'] and len(domain['controls']) == 87 and all(x['pass'] for x in domain['controls'])
    assert any(x['sha256'] == arena['helper']['sha256'] for x in domain['inputs'])
    gate('arenaDomain', domain_file, controls=87)
    migration_file = RAW/'arena-migration-state09/report.json'; migration = passed(migration_file)
    assert migration['attempt']['sha256'] == pin(attempt_file)['sha256']
    assert [x['label'] for x in migration['steps']] == ['compile-legacy-frame3', 'explicit-prepare-upgrades', 'compile-arena-frame4', 'selected-frame4-idempotent-prepare']
    assert all(x['pass'] for x in migration['steps'])
    before, upgrade, after, reuse = migration['steps']
    assert before['outputSha256'] == after['outputSha256'] == pin(migration['program'])['sha256']
    assert before['queries'] == after['queries'] == dict(world=1, context=1, prepareWorld=0, prepareState=0, checkBase=0)
    assert upgrade['queries'] == dict(world=0, context=0, prepareWorld=1, prepareState=0, checkBase=0)
    assert all(n == 0 for n in reuse['queries'].values()); pin(upgrade['frame3']); pin(upgrade['frame4'])
    for pair in migration['copies']: pin(pair['before']); pin(pair['after'])
    gate('actualPreparationMigration', migration_file, steps=4, ownedContext=True, completeModuleEquality=True)

    broad_file = RAW/'state09-b2-latency/broad/report.json'; broad = passed(broad_file)
    assert broad['successfulWorkers'] == broad['expectedWorkers'] == len(broad['rows']) == 207
    assert len(broad['statistics']) == len(broad['coverage']['compileInputIds']) == 23
    assert broad['coverage']['freshRuntimeExecutions'] == 0
    config = read(broad['config']); audit(config); pin(config['node'])
    assert config['roles'] == ['baseline', 'candidate', 'typescript'] and config['rounds'] == 3
    cases = {x['id']: x for x in config['cases']}
    assert len(cases) == len(config['cases']) == 23
    assert set(cases) == set(broad['coverage']['compileInputIds']) == set(broad['statistics'])
    keys = [(x['case'], x['role'], x['sample']) for x in broad['rows']]
    assert len(set(keys)) == len(keys)
    assert set(keys) == {(case, role, sample) for case in cases for role in config['roles'] for sample in range(3)}
    preparations = {}
    for row in broad['preparations']:
        prepared = passed(row['result'])
        assert row['success'] and prepared == row['observation']
        role = prepared['role']; assert role not in preparations
        assert prepared['stage'] == 'prepare'
        for pair in prepared.get('copies', []): pin(pair['before']); pin(pair['after'])
        if role != 'typescript':
            for value in prepared['image'].values():
                if isinstance(value, dict) and value.get('sha256'): pin(value)
        preparations[role] = (pin(row['result']), prepared)
    assert set(preparations) == set(config['roles'])
    for row in broad['rows']:
        observation = row['observation']
        assert row['success'] and observation['complete'] and observation['pass']
        assert read(row['result']) == observation
        request = read(observation['request'])
        assert request == dict(row['request'], config=broad['config'])
        assert request['case'] == row['case'] and request['sample'] == row['sample'] == observation['sample']
        assert request['role'] == row['role'] == observation['role']
        assert observation['config'] == broad['config'] and observation['stage'] == 'sample'
        assert row['execution']['complete'] and row['execution']['returncode'] == 0
        assert row['execution']['command'][-2:] == [observation['request']['file'], row['result']['file']]
        assert row['execution']['command'][3] == config['node']['file']
        case = cases[row['case']]; role = row['role']
        assert observation['source'] == case['source'] and observation['expected'] == case['references'][role]
        pin(observation['source'])
        for item in case['files'] + case['emissionInputs']: pin(item)
        prep_pin, prepared = preparations[role]
        assert pin(observation['preparation']) == prep_pin and request['preparation'] == observation['preparation']
        if role != 'typescript': assert observation['image'] == prepared['image']
        if role == 'candidate':
            assert observation['image']['api']['sha256'] == image['b2']['sha256']
            assert observation['image']['checkedGenerator']['sha256'] == pin(attempt_file)['sha256']
            assert observation['image']['driver']['sha256'] == arena['driver']['sha256']
            assert observation['image']['runtime']['sha256'] == attempt['runtime']['sha256']
            assert observation['image']['base']['sha256'] == attempt['base']['sha256']
        assert pin(observation['output'])['sha256'] == pin(observation['expected'])['sha256']
    broad_summary_file = ROOT/'implementation/phase64/evidence/state09-b2-broad.json'
    summary = passed(broad_summary_file)
    assert summary['report']['sha256'] == pin(broad_file)['sha256']
    assert summary['sourceCount'] == 23 and summary['rounds'] == 3
    assert summary['roles'] == ['baseline', 'candidate', 'typescript']
    assert summary['successfulWorkers'] == summary['exactRawOutputs'] == 207
    for key in ['producer', 'config', 'method']: pin(summary[key])
    gate('balancedBroadCompilation', broad_summary_file, workers=207, sources=23, rounds=3, freshProgramRuntimeExecutions=0)

    for item in list(parent.INPUTS.values()): pin(item)
    result = dict(kind='phase64-selected-state09-pre-release-qualification-join', complete=True, pass_=True,
        dataOnly=True, targetExecuted=False, producer=pin(__file__), inheritedReceiptReaders=pin(PARENT), successorDerivation=pin(derivation_file),
        attempt=pin(attempt_file), checkedApi=attempt['checkedApi'], selectedB1=attempt['api'], genuineB2=image['b2'],
        source=image['source'], gates=gates, checkedSemantics=checked_semantics, b2Semantics=b2_semantics,
        historicalRelocations=historical_relocations, performance=summary['aggregate'], release=dict(installedByThisJoin=False, admissionGranted=False, scope='Installation and release qualification are separate root-owned gates.'),
        scope='Finite overlapping suites, not full-language conformance. Fresh B2 type acceptance and expected unsafe proof-trust refusal are distinct. Exact raw outputs do not assert newly measured generated-program speed. The balanced genuine-B2 compiler campaign has 23 sources and three rounds; no significance claim. This join neither executes targets nor authorizes installation.')
    result['verifiedInputCount'] = len(parent.INPUTS)
    result['verifiedInputIndexSha256'] = hashlib.sha256(json.dumps(sorted(parent.INPUTS.values(), key=lambda x: x['file']), sort_keys=True).encode()).hexdigest()
    write(args.out, result)


def write(file, result):
    file.parent.mkdir(parents=True, exist_ok=True)
    with file.open('x') as stream: stream.write(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(output=str(file), complete=result['complete'], pass_=result['pass_'], targetExecuted=False)))


if __name__ == '__main__': main()
