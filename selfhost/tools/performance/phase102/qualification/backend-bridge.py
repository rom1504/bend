#!/usr/bin/env python3
"""Data-only Phase102 backend evidence bridge for the unchanged Phase98 image collector.

The schema name is retained for that consumer, not to relabel Phase98 source.
Every inherited fact carries its original source identity and a narrow closure
audit. Fresh API and real native-image results must exist before this can pass.
"""
import argparse
import importlib.util
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
spec = importlib.util.spec_from_file_location('p102_bridge_native', HERE.parent / 'native-inherit.py')
N = importlib.util.module_from_spec(spec); spec.loader.exec_module(N)
S = N.S
from final_control_plan import load_cases

REQUIRED = ['trmc-construction', 'trmc-refusals', 'trmc-late-failure',
    'local-empty', 'local-ascii', 'local-unicode', 'local-long', 'local-bang',
    'observer-empty', 'observer-prefix', 'observer-equal-long', 'observer-late-less', 'observer-early-greater',
    'string-values', 'string-parallel', 'string-array-sharing', 'string-empty', 'string-unicode-nul',
    'string-replacement-decoding', 'string-chunk-boundaries', 'string-boundary-60', 'string-boundary-61',
    'string-boundary-62', 'bang-bang-builder', 'branch-branches', 'branch-nct-cat-control', 'branch-strict-unused']


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for key in ['source-audit', 'authority', 'backend-policy', 'out']:
        p.add_argument('--' + key, type=Path, required=True)
    p.add_argument('--controls', type=Path, nargs='+', required=True)
    p.add_argument('--native-inheritance', type=Path, nargs='+', required=True)
    a = p.parse_args(); out = a.out.resolve(); assert not out.exists(); out.mkdir(parents=True)
    b = S.Bindings(); context = N.Q.baseline(b); N.Q.freeze(out, b)
    b.bind(__file__); b.bind(N.__file__)
    rows = []
    report = dict(kind='phase98-backend-specific-qualification', successorKind='phase102-backend-specific-qualification',
        complete=False, passed=False, inputsUnchanged=False, imageQualified=False,
        wholeCompilerProved=False, targetsRun=False, method=b.bind(__file__), rows=rows, inputs=[])
    def save(): report['inputs'] = list(b.rows.values()); S.S.save(out / 'report.json', report)
    def load(path, passed=False, complete=True):
        rp = b.bind(path); value = S.read(rp['file']); b.tree(value)
        assert not value.get('error')
        if complete: assert value['complete']
        if passed: assert value['passed'] and value['inputsUnchanged']
        return rp, value
    def add(name, evidence, scope):
        assert name not in {x['id'] for x in rows}
        rows.append(dict(id=name, passed=True, evidence=evidence, scope=scope))
    save()
    try:
        baseline = S.read(context['baselineAdmission']['file'])
        parent_pin, parent = load(baseline['receipts']['backendSpecific'], True)
        assert parent['source'] == context['source'] and parent['imageQualified'] is False
        audit_pin, audit = load(a.source_audit, True)
        source = b.bind(audit['source']); policy_pin = S.backend_policy(a.backend_policy, source, b)
        policy = S.read(policy_pin['file'])
        recipe_pin, recipe = load(policy['recipe'])
        assert recipe['candidate'] == source and N.same(recipe['source'], parent['source'])
        assert audit['parentBackendControls'] == parent_pin
        assert N.same(audit['sourceRecipe'], recipe.get('originalRecipe', recipe_pin))
        text = Path(recipe['source']['file']).read_text(); original = text
        for edit in recipe['changes']:
            at, old, new = edit['offset'], edit['old'], edit['new']
            assert isinstance(at, int) and at >= 0 and text[at:at+len(old)] == old
            text = text[:at] + new + text[at+len(old):]
        final_text = Path(source['file']).read_text(); assert text == final_text
        for edit in reversed(recipe['changes']):
            at, old, new = edit['offset'], edit['old'], edit['new']
            assert text[at:at+len(new)] == new
            text = text[:at] + old + text[at+len(new):]
        assert text == original
        assert len(audit['exactPermissionDeclarations']) == 14
        assert {x['name'] for x in audit['auditedPermissionDeclarations']} == {'nf_plan_scoped', 'ns_compile_named_scoped'}
        assert all(x['exact'] is False and x['classification'] and x['beforeText'] != x['afterText']
                   for x in audit['auditedPermissionDeclarations'])
        add('final-source-and-authority-audit', [audit_pin, recipe_pin, policy_pin],
            'Exact recipe and inverse; fourteen authority declarations unchanged, two explicitly audited route changes. New unsafe lowering remains covered by finite controls, not a proof.')
        assert len(audit['inheritedSafeClosures']) == 2
        for i, closure in enumerate(audit['inheritedSafeClosures']):
            proof_pin, proof = load(closure['proof']); manifest_pin, manifest = load(closure['manifest'], complete=False)
            assert proof['independentlyChecked'] and proof['opaqueDefinitions'] == []
            assert len(proof['lawNames']) == [7, 6][i]
            assert closure['independentRecheckPerformed'] is False
            assert len(manifest['candidateDefinitions']) == [5, 8][i]
            for definition in manifest['candidateDefinitions']:
                assert final_text.count(definition['original']) == 1
            add('inherited-safe-laws/' + ['permission', 'tag-comparison'][i], [audit_pin, proof_pin, manifest_pin],
                'Original independently checked safe closure is byte-exact in final source; original proof/source identities retained. No new kernel check or native ownership theorem claimed.')
        closures = audit['inheritedRootClosures']
        assert all(closures[name]['exact'] for name in ['no_effect_definitions', 'no_effect_terms', 'ns_source', 'noa_below'])
        certificates = [x for x in parent['rows'] if x['id'].startswith('parent/certificate/')]
        origins = [x for x in parent['rows'] if x['id'].startswith('origin/') and not x['id'].startswith('origin/C/') and x['id'] != 'origin/owning-swap-full-output']
        assert len(certificates) == 18 and len(origins) == 11
        for row in certificates + origins:
            add('inherited/' + row['id'], [audit_pin, parent_pin, *row['evidence']],
                'Original finite helper observation inherited only through its exact reachable helper/type source closure. Historical source is retained; no changed emitted program behavior is inherited.')
        authority_pin, authority = load(a.authority, True)
        assert authority['kind'] == 'phase102-authority-boundary-results' and authority['source'] == source
        assert authority['imageQualified'] is False
        assert [x['id'] for x in authority['rows']] == ['real-io', 'generic-array', 'schema-refusals',
            'unknown-provider', 'raw-forged-observer-context-is-inert',
            'raw-observer-return-node-is-not-source', 'raw-observer-loop-node-is-not-source']
        for row in authority['rows']:
            assert row['passed']
            add('fresh-authority/' + row['id'], [authority_pin, *row['evidence']],
                'Fresh final-source checked API authority/refusal observation; exact raw forged-context C alone reuses its original full native output. Final five-source native gate remains mandatory.')
        checked = {}; checked_pins = []
        for path in a.controls:
            control_pin, control = load(path); checked_pins.append(control_pin)
            manifest_pin, manifest = load(control['manifest'])
            emission_pin, emission = load(control['emission'])
            assert emission['compilerSource'] == source and emission['api'] == authority['api']
            assert control['manifest'] == emission['manifest']
            for case in manifest['records']:
                assert case['id'] not in checked, case['id']
                checked[case['id']] = dict(case=case, control=control_pin, manifest=manifest_pin)
                product = control['products'][case['source']]
                assert product['source'] == b.bind(case['source'])
                emitted = [x for x in emission['programs'] if x['source'] == product['source']]
                assert len(emitted) == 1 and emitted[0]['c'] == product['variants']['candidate']['c']
                expected = Path(b.bind(case['expected'])['file']).read_bytes() if 'expected' in case else case.get('stdout', '').encode()
                wanted = {(role, workers) for role in ['baseline', 'candidate', 'upstream'] for workers in case.get('workers', [1])}
                observed = [x for x in control['executions'] if x['case'] == case['id']]
                assert {(x['role'], x['workers']) for x in observed} == wanted and len(observed) == len(wanted)
                for row in observed:
                    assert row['passed'] and row['returncode'] == case.get('returncode', 0)
                    binary = product['variants'][row['role']]['binary']
                    argv = [binary['file'], '--threads', str(row['workers']), '--gpu', 'off', '--', *case.get('argv', [])]
                    N.job_evidence(b, row['job'], argv, case.get('returncode', 0), expected, case.get('stderr', '').encode())
        assert set(checked) == set(REQUIRED), ('Required finite semantic controls', set(REQUIRED) - set(checked), set(checked) - set(REQUIRED))
        native_pins = []; native_by_control = {}
        for path in a.native_inheritance:
            native_pin, native = load(path, True); native_pins.append(native_pin)
            assert native['kind'] == 'phase102-native-semantic-inheritance' and not native.get('checkOnly')
            assert native['executionPerformed'] and native['source'] == source and native['backendPolicy'] == policy_pin
            control_reports = native.get('controlReports', [native['controls']])
            assert control_reports and control_reports[0] == native['controls']
            for index, control_report in enumerate(control_reports):
                assert control_report in checked_pins and control_report['file'] not in native_by_control
                native_by_control[control_report['file']] = (native_pin, native,
                    'control-' + str(index) if 'controlReports' in native else 'control')
            assert len(native['inherited']) + len(native['fresh']) == len(native['obligations'])
            source_map = {x['source']['file']: x for x in native['sources']}
            assert len(source_map) == len(native['sources'])
            def outcome_key(row): return row['id'], row['workers'], row['source']['file']
            obligations = {outcome_key(x): x for x in native['obligations']}
            outcomes = native['inherited'] + native['fresh']
            assert len(obligations) == len(native['obligations'])
            assert len({outcome_key(x) for x in outcomes}) == len(outcomes)
            assert {outcome_key(x) for x in outcomes} == set(obligations)
            for result in outcomes:
                obligation = obligations[outcome_key(result)]
                emitted_source = source_map[result['source']['file']]
                assert result['fullOutputExact'] and result['source'] == emitted_source['source'] == obligation['source']
                assert N.same(result['c'], emitted_source['c'])
                assert result['binary'] == emitted_source['selectedProduct']['binary']
                evidence = result.get('evidence', result.get('priorEvidence'))
                assert evidence
                process = S.read(b.bind(evidence['guard'])['file'])
                child_pin = b.bind(evidence['child'])
                argv = [result['binary']['file'], '--threads', str(obligation['workers']), '--gpu', 'off', '--', *obligation['argv']]
                N.job_evidence(b, dict(guard=evidence['guard'], process=process,
                    guardExit=0 if obligation['expectedExit'] == 0 else 1, receipt=child_pin),
                    argv, obligation['expectedExit'],
                    Path(b.bind(obligation['expectedStdout'])['file']).read_bytes(),
                    Path(b.bind(obligation['expectedStderr'])['file']).read_bytes())
            for stage in ['b1', 'b2']:
                producer = native['producers'][stage]
                assert producer['source'] == source
                assert S.authenticate(producer['binary'], stage, source, producer['build'], b, context) == producer
            for item in native['sources']:
                assert item['passed'] and len(item['rows']) == 2
                assert [x['stage'] for x in item['rows']] == ['b1', 'b2']
                assert all(x['passed'] and S.bounded_exit(x['process'], 0) for x in item['rows'])
                assert N.same(item['rows'][0]['output'], item['rows'][1]['output']) and item['rows'][1]['exactC']
                assert item['rows'][0]['diagnostic'] == item['rows'][1]['diagnostic'] == item['reference']['diagnostic']
                assert N.same(item['c'], item['rows'][0]['output'])
                assert N.same(item['c'], item['selectedProduct']['c'])
                N.build_evidence(b, item['selectedProduct'], context['clang'])
                for row in item['rows']:
                    raw = {Path(x['file']).name: b.bind(x) for x in row['raw']}
                    assert S.read(raw['process.json']['file']) == row['process']
                    assert row['command'] == row['process']['command']
                    prefix = Path(raw['process.json']['file']).parent.parent / 'output'
                    argv = S.native_args(context, native['producers'][row['stage']], item['source']['file'], prefix, row['live'])
                    assert row['command'][-len(argv):] == argv
                    assert not Path(raw['stdout.log']['file']).read_bytes()
                    assert S.strip_clocks(Path(raw['stderr.log']['file']).read_text()) == row['diagnostic']
                    assert row['output']['file'] == str(prefix) + '.1.c'
        assert set(native_by_control) == {x['file'] for x in checked_pins}
        for name in REQUIRED:
            item = checked[name]; native_pin, native, label = native_by_control[item['control']['file']]
            case = item['case']; obligations = [x for x in native['obligations'] if x['id'] == label + '/' + name]
            assert len(obligations) == len(case.get('workers', [1]))
            assert {x['workers'] for x in obligations} == set(case.get('workers', [1]))
            assert all(x['source'] == b.bind(case['source']) for x in obligations)
            expected = Path(b.bind(case['expected'])['file']).read_bytes() if 'expected' in case else case.get('stdout', '').encode()
            for obligation in obligations:
                assert obligation['argv'] == case.get('argv', [])
                assert obligation['expectedExit'] == case.get('returncode', 0)
                assert Path(b.bind(obligation['expectedStdout'])['file']).read_bytes() == expected
                assert Path(b.bind(obligation['expectedStderr'])['file']).read_bytes() == case.get('stderr', '').encode()
            add('final-native/' + name, [item['control'], item['manifest'], native_pin],
                'Frozen full exit/stdout/stderr oracle passed on final-source checked API products and exact final native B1/B2 emissions; authenticated identical-C reuse or fresh execution preserves every payload.')
        # These are historical lineage keys mandated by the unchanged five-case
        # loader. They are never rewritten to pretend old runs used new source.
        for key in ['qualifiedSource', 'qualifiedSourceControls', 'qualifiedSourceCorpus', 'originControls', 'documentarySnapshot', 'finalImageControlPlans']:
            report[key] = parent[key]
        _, original_cases = load_cases(report, b)
        assert len(original_cases) == 5
        ids = [x['id'] for x in rows]
        plan = dict(kind='phase102-backend-specific-evidence-plan', source=source, backendPolicy=policy_pin,
            cases=[dict(id=x['id'], scope=x['scope']) for x in rows], requiredControlIds=REQUIRED,
            frozenControlManifests=[x['manifest'] for x in checked.values()], expectationsChanged=False,
            historicalParent=parent_pin, finalImageControlPlans=parent['finalImageControlPlans'])
        S.S.save(out / 'plan.json', plan)
        report.update(source=source, backendPolicy=policy_pin, parentSource=parent['source'],
            parentBackendControls=parent_pin, sourceRecipe=recipe_pin, declarationBridge=audit_pin,
            inheritedSafeClosures=audit['inheritedSafeClosures'], authorityControls=authority_pin,
            checkedControls=checked_pins, nativeInheritance=native_pins,
            plan=b.bind(out / 'plan.json'), requiredCaseIds=ids,
            counts=dict(exactAuthorityDeclarations=14, auditedAuthorityDeclarations=2, inheritedSafeLaws=13,
                inheritedCertificateBooleans=18, inheritedOriginDecisions=11, freshAuthorityCases=7, finalNativeCases=27),
            scope='Exact old safe helper facts plus explicitly audited authority changes, fresh API refusal controls, and final-native finite new-mechanism outputs. Original five-source native controls and every frozen compiler-chain gate remain separately mandatory. No universal compiler or native lifetime proof.')
        b.unchanged(); report.update(complete=True, passed=True, inputsUnchanged=True)
    except BaseException as error:
        report['error'] = repr(error); raise
    finally: save()
    print(S.json.dumps(dict(complete=True, passed=True, imageQualified=False, rows=len(rows), report=str(out / 'report.json'))))


if __name__ == '__main__': main()
