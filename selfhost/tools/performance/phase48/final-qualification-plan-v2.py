#!/usr/bin/env python3
"""Write serial RNFA semantic commands and their receipt contracts; never execute."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
RAW = ROOT / 'selfhost/build/phase48'
UPSTREAM = '018751270e800bc222a93dad7f257083ee53a5f7'
BASE_API = '28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f'
BASE_RUNTIME = '880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b'
NODE = Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('attempt', type=Path)
    parser.add_argument('out', type=Path, help='Fresh directory under build/phase48')
    parser.add_argument('--program-preparation', type=Path, help='Optional exact selected full acquisition; binds actual Evening')
    parser.add_argument('--count-preparation', type=Path, help='Reuse an existing exact selected count fixture acquisition; never recompile it')
    parser.add_argument('--prior-arrays', action='store_true', help='Also renew four Phase47 array controls against their original predecessors')
    args = parser.parse_args()
    attempt, out = args.attempt.resolve(strict=True), args.out.resolve()
    assert out.is_relative_to(RAW) and not out.exists() and not out.is_relative_to(attempt)
    pins, jobs, fixtures = {}, [], []

    def pin(file, expected=None):
        file = Path(file).resolve(strict=True)
        digest = hashlib.sha256()
        with file.open('rb') as stream:
            for chunk in iter(lambda: stream.read(2**20), b''):
                digest.update(chunk)
        row = dict(file=str(file), sha256=digest.hexdigest(), bytes=file.stat().st_size)
        if expected:
            assert row['sha256'] == expected['sha256'], file
            if 'bytes' in expected:
                assert row['bytes'] == expected['bytes'], file
            if 'canonicalPath' in expected:
                assert row['file'] == expected['canonicalPath'], file
        assert row == pins.get(str(file), row), file
        pins[str(file)] = row
        return row

    def read(file):
        pin(file)
        return json.loads(Path(file).read_text())

    def audit(value):
        if isinstance(value, list):
            for child in value:
                audit(child)
        elif isinstance(value, dict):
            file = value.get('file', value.get('path', value.get('canonicalPath')))
            if isinstance(file, str) and 'sha256' in value:
                pin(file, value)
            for child in value.values():
                audit(child)

    pin(__file__)
    parent_plan = pin(HERE / 'final-qualification-plan.py', {'sha256': '2af5e6bdf5058d6fa823771068ec61b453d1c54875e764b52e2bc1db07873199'})
    manifest = read(attempt / 'attempt.json')
    assert manifest['checked'] and manifest['config']['strictExact']
    focused = read(attempt / 'validation-001/report.json')
    assert focused['complete'] and focused['pass'] and focused['strictExact']
    assert pin(focused['attempt']['file'], focused['attempt']) == pin(attempt / 'attempt.json')
    assert pin(focused['api']['file'], focused['api']) == pin(manifest['api']['file'], manifest['api'])
    selected = {key: pin(manifest[key]['file'], manifest[key]) for key in ['api', 'runtime', 'base', 'node']}
    assert Path(selected['node']['file']) == NODE.resolve()
    snapshot = Path(manifest['snapshot']['root']).resolve(strict=True)
    for row in manifest['snapshot']['sources']:
        file = Path(row['frozen']['file']).resolve(strict=True)
        assert file.is_relative_to(snapshot)
        pin(file, row['frozen'])
    assert read(snapshot / 'src/compiler.json')['upstream'] == UPSTREAM
    selected['attempt'] = pin(attempt / 'attempt.json')
    selected['driver'] = pin(snapshot / 'tools/typed-driver.mjs')
    tools = HERE.parent
    prepare = pin(tools / 'programs/prepare.py')
    guard = pin(tools / 'phase46/job.py')
    pin(tools / 'programs/support.py')
    for name in ['emit-worker.mjs', 'run.py']:
        pin(tools / 'programs' / name)

    def job(name, command, guarding, report=None, expect=None, bindings=None):
        row = dict(index=len(jobs), name=name, cwd=str(ROOT), command=list(map(str, command)), guard=guarding,
                   stage='after-live-integration' if name in ['maintained8', 'prepare-backend81', 'backend81'] else 'focused-controls')
        if report is not None:
            row.update(report=str(report), expect=expect)
        if bindings is not None:
            row['bindings'] = bindings
        jobs.append(row)

    def guarded(name, command, report, expect, seconds=120, bindings=None):
        job(name, ['python3', guard['file'], '--out', out / ('job-' + name), '--seconds', seconds,
                   '--', *command], 'phase46/job.py only', report, expect, bindings)

    node = [selected['node']['file'], '--stack-size=4096', '--max-old-space-size=1024']
    specs = [
        ('composite', 'composite-results-catalog-v1.json', 'composite-results-v4.mjs', 'composite-baseline01', 'phase48-composite-result-controls', 'passed', {'oracles': 30, 'boundaries': 6}),
        ('native', 'native-values-catalog-v1.json', 'native-values-v1.mjs', 'native-baseline01', 'phase48-actual-native-string-append-controls', 'pass', {'valueRows': 1372, 'ordinaryRows': 7, 'boundaries': 18}),
        ('float', 'private-float-catalog-v1.json', 'private-float-controls-v2.mjs', 'float-baseline01', 'phase48-private-finite-f32-controls', 'passed', {'oracles': 408, 'boundaries': 17, 'activation': 9}),
        ('arrays', 'array-effects-catalog-v2.json', 'array-effects-controls-v3.mjs', 'arrays-baseline02', 'phase48-array-effects-controls-v3', 'pass', {'oracles': 115, 'boundaries': 14, 'activation': 16}),
        ('literals', 'array-literals-catalog-v2.json', 'array-literals-controls-v4.mjs', 'literals-baseline02', 'phase48-array-literals-controls-v4', 'pass', {'oracles': 96}),
        ('fill', 'array-fill-boundary-catalog-v1.json', 'array-fill-boundary-controls-v1.mjs', 'array-fill-baseline01', 'phase48-array-fill-boundary-controls-v1', 'pass', {'observations': 2}),
        ('counts', 'array-counts-catalog-v1.json', 'array-counts-controls-v1.mjs', 'array-counts-baseline01', 'phase48-array-count-mapping', 'pass', {'oracles': 43, 'boundaries': 13, 'activation': 56}),
        ('composite-float', 'composite-float-catalog-v2.json', 'composite-float-controls-v3.mjs', 'composite-float-baseline02', 'phase48-composite-float-controls', 'passed', {'oracles': 50, 'boundaries': 5, 'activation': 6}),
    ]
    old = [
        ('prior-view', 'array-view-catalog-v1.json', 'array-view-controls-v4.mjs', 'array-controls-baseline01', 'phase48-independent-array-view-controls-v4', {'oracles': 24, 'boundaries': 39}),
        ('prior-layout', 'array-layout-catalog-v3.json', 'array-layout-controls-v3.mjs', 'layout-controls-baseline03', 'phase47-independent-array-layout-controls-v3', {'oracles': 77, 'publicStates': 56, 'boundaries': 7}),
        ('prior-tree', 'array-tree-catalog-v4.json', 'array-tree-controls-v6.mjs', 'tree-controls-baseline04', 'phase48-independent-array-tree-controls-v6', {'oracles': 159, 'boundaries': 11}),
        ('prior-integer', 'array-integer-guard-catalog-v5.json', 'array-integer-guard-controls-v5.mjs', 'integer-controls-baseline05', 'phase47-independent-array-integer-guard-controls-v5', {'oracles': 153, 'boundaries': 46}),
    ]
    if args.prior_arrays:
        specs += [(n, c, t, b, k, 'pass', counts) for n, c, t, b, k, counts in old]
    evening = None
    if args.program_preparation:
        file = args.program_preparation.resolve(strict=True)
        bundle = read(file)
        assert bundle['complete'] and bundle['upstreamCommit'] == UPSTREAM
        rows = [c for c in bundle['cases'] if c['id'] == 'test-evening-program']
        assert len(rows) == 1
        module = rows[0]['modules']['candidate']
        evening = pin(file.parent / module['path'], module)
        receipt = read(evening['file'] + '.json')
        audit(receipt)
        assert receipt['complete'] and receipt['observation']['checked'] and receipt['observation']['status'] == 'ok'
        assert receipt['output']['sha256'] == evening['sha256']
        assert pin(receipt['attempt']['file'], receipt['attempt']) == selected['attempt']
        for key in ['api', 'runtime', 'base', 'driver']:
            assert pin(receipt['compiler'][key]['file'], receipt['compiler'][key]) == selected[key]
    for name, catalog_name, controller_name, baseline_name, kind, status, counts in specs:
        historical = name.startswith('prior-')
        directory = tools / ('phase47' if historical else 'phase48') / 'controls'
        catalog_id = pin(directory / catalog_name)
        catalog = read(catalog_id['file'])
        assert catalog['upstreamCommit'] == UPSTREAM and len(catalog['cases']) == 1
        case = catalog['cases'][0]
        source = pin(directory / case['source']['path'], case['source'])
        controller_directory = HERE / 'controls' if name in ['prior-view', 'prior-tree'] else directory
        controller = pin(controller_directory / controller_name)
        baseline_file = ROOT / 'selfhost/build' / ('phase47' if historical else 'phase48') / baseline_name / 'manifest.json'
        baseline = read(baseline_file)
        assert baseline['complete'] and baseline['catalogSha256'] == catalog_id['sha256']
        assert baseline['upstreamCommit'] == UPSTREAM and len(baseline['cases']) == 1
        base_case = baseline['cases'][0]
        assert base_case['id'] == case['id'] and base_case['sourceSha256'] == source['sha256']
        assert base_case['point'] == case['point']
        base_module = pin(baseline_file.parent / base_case['modules']['baseline']['path'], base_case['modules']['baseline'])
        receipt = read(base_module['file'] + '.json')
        audit(receipt)
        assert receipt['kind'] == 'bend-program-checked-emission' and receipt['complete']
        assert receipt['observation']['checked'] and receipt['observation']['status'] == 'ok'
        assert receipt['input']['sha256'] == source['sha256'] and receipt['catalog']['sha256'] == catalog_id['sha256']
        assert receipt['output']['sha256'] == base_module['sha256']
        if not historical:
            assert receipt['compiler']['api']['sha256'] == BASE_API and receipt['compiler']['runtime']['sha256'] == BASE_RUNTIME
        acquire = out / ('acquire-' + name)
        candidate = acquire / 'modules' / (Path(source['file']).stem + '.mjs')
        reused = None
        if name == 'counts' and args.count_preparation:
            reuse_file = args.count_preparation.resolve(strict=True)
            reuse = read(reuse_file)
            assert reuse['complete'] and reuse['upstreamCommit'] == UPSTREAM and reuse['catalogSha256'] == catalog_id['sha256']
            assert len(reuse['cases']) == 1
            reuse_case = reuse['cases'][0]
            assert reuse_case['id'] == case['id'] and reuse_case['point'] == case['point'] and reuse_case['sourceSha256'] == source['sha256']
            candidate_id = pin(reuse_file.parent / reuse_case['modules']['candidate']['path'], reuse_case['modules']['candidate'])
            candidate = Path(candidate_id['file'])
            emitted = read(str(candidate) + '.json'); audit(emitted)
            assert emitted['kind'] == 'bend-program-checked-emission' and emitted['complete']
            assert emitted['observation']['checked'] and emitted['observation']['status'] == 'ok'
            assert emitted['output']['sha256'] == candidate_id['sha256']
            assert emitted['input']['sha256'] == source['sha256'] and emitted['catalog']['sha256'] == catalog_id['sha256']
            assert pin(emitted['attempt']['file'], emitted['attempt']) == selected['attempt']
            for key in ['api', 'runtime', 'base', 'driver']:
                assert pin(emitted['compiler'][key]['file'], emitted['compiler'][key]) == selected[key]
            reused = dict(manifest=pin(reuse_file), module=candidate_id, emission=pin(str(candidate) + '.json'),
                          scope='Previously completed exact selected count acquisition; no fresh acquisition is claimed by this queue.')
        bindings = dict(attempt=selected['attempt'], api=selected['api'], runtime=selected['runtime'],
                        base=selected['base'], driver=selected['driver'], catalog=catalog_id, source=source,
                        candidateModule=str(candidate), candidateEmission=str(candidate) + '.json')
        if not reused:
            job('acquire-' + name, ['python3', prepare['file'], '--catalog', catalog_id['file'], '--set', 'full',
                '--role', 'candidate', '--attempt', attempt, '--node', selected['node']['file'], '--cpu', '3',
                '--heap-mib', '1024', '--rss-mib', '2048', '--available-mib', '4096', '--out', acquire],
                'programs/prepare.py only', acquire / 'manifest.json', {'complete': True, 'catalogSha256': catalog_id['sha256']}, bindings)
        arguments = [base_module['file'], candidate, out / ('control-' + name)]
        if name == 'literals' and evening:
            arguments.append(evening['file'])
        guarded('control-' + name, [*node, controller['file'], *arguments], out / ('control-' + name) / 'report.json',
                {'kind': kind, 'complete': True, status: True, 'arrayLengths': counts}, bindings=bindings)
        fixtures.append(dict(name=name, baselineManifest=pin(baseline_file), baselineModule=base_module,
                             baselineEmission=pin(base_module['file'] + '.json'), controller=controller, bindings=bindings,
                             reusedAcquisition=reused, baselineScope='Original historical predecessor' if historical else 'Installed Phase47 array06'))
    float_ir = pin(HERE / 'controls/private-float-ir-v1.mjs')
    guarded('float-ir', [*node, float_ir['file'], attempt, out / 'float-ir'], out / 'float-ir/report.json',
            {'kind': 'phase48-private-finite-f32-ir-controls', 'complete': True, 'pass': True, 'arrayLengths': {'patterns': 22, 'refusals': 4}})
    native_rejection = pin(HERE / 'controls/array-native-rejection-controls-v2.mjs')
    eager = RAW / 'checked-combined-rnfa02'
    eager_id = pin(eager / 'attempt.json', {'sha256': '280e5645b089b2254ff58a720bf2f0b0a47a86739f1fa90b522dfd68cd6474ec'})
    eager_manifest = read(eager / 'attempt.json')
    assert eager_manifest['checked']
    for key in ['api', 'runtime', 'base']:
        pin(eager_manifest[key]['file'], eager_manifest[key])
    guarded('native-rejection', [*node, native_rejection['file'], eager, attempt, out / 'native-rejection'],
            out / 'native-rejection/report.json', {'kind': 'phase48-array-native-rejection-controls-v2', 'complete': True,
            'pass': True, 'arrayLengths': {'roles': 2}}, bindings=dict(historicalEagerAttempt=eager_id, candidate=selected))
    qualify = pin(tools / 'phase47/qualify.py')
    job('maintained8', ['python3', qualify['file'], attempt, out / 'maintained8'], 'phase47/qualify.py only',
        out / 'maintained8/report.json', {'kind': 'phase47-maintained-semantic-qualification', 'complete': True, 'pass': True, 'arrayLengths': {'tests': 8}})
    backend_plan = pin(HERE / 'backend-plan.py')
    job('prepare-backend81', ['python3', backend_plan['file'], attempt, out / 'backend'], 'none; data only',
        out / 'backend/preparation.json', {'complete': True, 'executed': False, 'expectedRows': 81})
    backend_runner = pin(ROOT / 'selfhost/build/phase43/integration01/final-plan/tools/backend-run.py')
    guarded('backend81', ['python3', backend_runner['file'], out / 'backend/pilot.json'],
            out / 'backend/pilot/report.json', {'kind': 'phase30-retained-backend-renewal', 'complete': True,
            'agreementComplete': True, 'rowsExpected': 81, 'arrayLengths': {'rows': 81, 'unexecuted': 0, 'incompleteBatchRows': 0}}, seconds=930)
    for row in list(pins.values()):
        pin(row['file'], row)
    plan = dict(kind='phase48-rnfa-final-semantic-plan-v2', complete=True, executed=False, selected=selected, parentPlan=parent_plan,
        successorScope='Preserved v1 plus reviewed named-boundary ordinary-source oracles for prior view/tree, the small-count literal-entry successor, independent count mapping, composite/F32 composition and lazy native-predicate rejection. Existing catalogs and exact historical predecessors remain unchanged. Candidate remains an explicit argument.',
        serial=True, cwd=str(ROOT), resources=dict(cpu=3, heapMiB=1024, treeRssMiB=2048, availableMiB=4096),
        environmentPolicy='Maintained ExecutionGuard removes inherited BEND_* plus NODE_OPTIONS/NODE_PATH; each Node job declares heap/stack explicitly. No outer resource wrapper or implicit compiler environment override.',
        jobs=jobs, fixtures=fixtures, actualEvening=evening, inputs=list(pins.values()),
        integrationBarrier=dict(beforeJob='maintained8', automatic=False,
            instruction='After all focused controls pass, root integrates the selected source into the live tree. Keep the unchanged qualify.py compiler-manifest/host equality checks; do not skip or weaken them.'),
        prerequisites=['Selected source manifest and host tools must match the maintained8 snapshot contract.',
                       'Run each command serially, stop on any nonzero exit or failed receipt expectation; do not add an outer guard.',
                       'Rehash plan inputs before and after execution. Bind every fresh emission to the selected attempt/API/runtime/Base/driver and exact source/catalog, then retain all process logs and reports.',
                       'A plan is not a result. Report fields and arrayLengths are assertions to verify after each job.'],
        releaseSeparate=True,
        scope='RNFA semantic qualification only. Eight source fixtures use exact array06 baselines; an explicitly bound completed selected count acquisition may be reused. Optional Phase47 gates retain their original predecessors, including pre-array04 tree baseline. No H/V selection, frontend3026, generated runtime timing, compiler cost, default-stack, installation or release claim. Installation/verify and 42 CLI smoke checks are a separate later sequence. Backend81 preserves 69 pass, 8 N/A and 4 shared failures; it does not mean 81 passing tests.')
    out.mkdir(parents=True)
    with (out / 'plan.json').open('x') as stream:
        json.dump(plan, stream, indent=2)
        stream.write('\n')
    print(json.dumps(dict(complete=True, executed=False, jobs=len(jobs), plan=str(out / 'plan.json'))))


if __name__ == '__main__':
    main()
