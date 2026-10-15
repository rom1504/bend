#!/usr/bin/env python3
"""Data-only origin termination controls and exact parent permission evidence consumer."""
import argparse
import hashlib
import json
from pathlib import Path
from support import Bindings, S, backend_policy, freeze_methods, module, pin, read
from final_control_plan import load_cases, native_flags


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['parent-controls', 'bridge', 'origin-controls', 'backend-policy', 'out']:
        p.add_argument('--' + name, type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve(); assert not out.exists(); out.mkdir(parents=True)
    b = Bindings(); freeze_methods(out, b); rows = []
    report = dict(kind='phase98-backend-specific-qualification', complete=False, passed=False,
                  imageQualified=False, wholeCompilerProved=False, targetsRun=False,
                  inputsUnchanged=False, method=pin(__file__), inputs=[], rows=rows)
    def save(): report['inputs'] = list(b.rows.values()); S.save(out / 'report.json', report)
    def load(value):
        rp = b.bind(value); r = read(rp['file']); b.tree(r)
        assert r['complete'] and r.get('inputsUnchanged', True) and not r.get('error')
        return rp, r
    def add(name, evidence, scope): rows.append(dict(id=name, passed=True, evidence=evidence, scope=scope))
    def replay(text, edits):
        for edit in edits:
            at, old, new = edit['offset'], edit['old'], edit['new']
            assert isinstance(at, int) and 0 <= at <= len(text) and at + len(old) <= len(text)
            assert text[at:at + len(old)] == old
            text = text[:at] + new + text[at + len(old):]
        return text
    def process(value):
        assert value['complete'] and value['returncode'] == 0
        assert not value.get('stoppedFor') and not value.get('interrupted')
    def same(x, y): return all(x[k] == y[k] for k in ['sha256', 'bytes'])
    save()
    try:
        parent_pin, parent = load(a.parent_controls)
        assert parent['kind'] == report['kind'] and parent['passed'] and not parent['imageQualified']
        assert len(parent['rows']) == 29 and all(row['passed'] for row in parent['rows'])
        bridge_pin, bridge = load(a.bridge)
        assert bridge['kind'] == 'phase98-origin-guard-declaration-bridge' and not bridge['imageQualified']
        assert bridge['parentBackendControls'] == parent_pin and bridge['parentSource'] == parent['source']
        assert bridge['priorDeclarationBridge'] == parent['finalCompositionBridge']
        source = bridge['source']; policy_pin = backend_policy(a.backend_policy, source, b)
        policy = read(policy_pin['file']); assert policy['recipe'] == bridge['candidateRecipe']
        recipe_pin, recipe = load(policy['recipe'])
        old = Path(parent['source']['file']).read_text(); new = Path(source['file']).read_text()
        assert recipe['candidate'] == source and recipe['parentSource'] == parent['source']
        assert replay(Path(recipe['source']['file']).read_text(), recipe['changes']) == new
        assert len(recipe['localChanges']) == 1 and recipe['localChanges'][0]['function'] == 'noa_below'
        assert replay(old, recipe['localChanges']) == new
        assert replay(new, [dict(offset=x['offset'], old=x['new'], new=x['old']) for x in reversed(recipe['localChanges'])]) == old
        prior = read(parent['finalCompositionBridge']['file'])
        declarations = module('phase98_origin_final_declarations', prior['method']['file']).declarations
        before, after = declarations(old), declarations(new)
        assert set(before) == set(after) and [name for name in before if before[name] != after[name]] == ['noa_below']
        assert bridge['changedDeclarations'] == [dict(name='noa_below', before=before['noa_below'], after=after['noa_below'])]
        assert after['noa_below'] == ('@unsafe\ndef noa_below(+origin: KTerm, +want: KTerm) -> Bool:\n'
            '  nt_choose(Bool, norm_exact(origin, want), u => True{}, u =>\n'
            '    nt_choose(Bool, p98_tag_eq(origin, "OField"), v => noa_below(kid(origin, 0), want), v => False{}))\n')
        assert len(bridge['exactPermissionDeclarations']) == 16
        for row in bridge['exactPermissionDeclarations']:
            text = after[row['name']]; assert row['exact'] and text == before[row['name']]
            assert len(text.encode()) == row['bytes'] and hashlib.sha256(text.encode()).hexdigest() == row['sha256']
        assert len(bridge['inheritedSafeClosures']) == 2
        for closure in bridge['inheritedSafeClosures']:
            proof = read(closure['proof']['file']); manifest = read(closure['manifest']['file'])
            assert proof['complete'] and proof['independentlyChecked'] and proof['opaqueDefinitions'] == []
            assert manifest['candidate'] == parent['source']
            assert len(manifest['candidateDefinitions']) == closure['exactDefinitions']
            for definition in manifest['candidateDefinitions']: assert new.count(definition['original']) == 1
        for row in parent['rows']:
            add('parent/' + row['id'], [parent_pin, *row['evidence']],
                'Inherited parent-source evidence; unchanged permission and safe-helper closures are exact. ' + row['scope'])
        add('origin-declaration-bridge', [bridge_pin, recipe_pin],
            'Only noa_below changes, to a lazy field guard. Sixteen permission declarations and inherited safe proof closures remain exact. Old/new universal equivalence is neither true nor claimed.')

        controls_pin, controls = load(a.origin_controls)
        assert controls['kind'] == 'phase98-origin-guard-qualification' and controls['targetsRun'] and not controls.get('preparedOnly')
        plan_pin = b.bind(controls['plan']); plan = read(plan_pin['file']); b.tree(plan)
        assert plan['recipe'] == recipe_pin and plan['sources'] == dict(baseline=parent['source'], candidate=source)
        assert [row['id'] for row in plan['controls']] == ['real-io', 'generic-array', 'schema-refusals', 'origin-swap']
        jobs = {row['name']:row for row in controls['rows']}
        assert list(jobs) == ['api-baseline', 'api-candidate', 'old-positive', 'old-mismatch', 'candidate', 'swap-clang', 'swap-run']
        assert len(jobs) == len(controls['rows'])
        commands = {row['name']:row for row in controls['commands']}
        for name, job in jobs.items():
            actual = read(b.bind(job['guard'])['file']); assert actual == job['process']
            argv = commands[name]['argv']; assert actual['command'][-len(argv):] == argv
            folder = Path(job['guard']['file']).parent
            job['captures'] = {stream:b.bind(folder / (stream + '.log')) for stream in ['stdout', 'stderr']}
            if name == 'old-mismatch':
                assert commands[name]['expectedFailure'] and commands[name]['seconds'] == 3
                assert not (actual['complete'] and actual['returncode'] == 0 and not actual.get('stoppedFor'))
                assert not Path(job['captures']['stdout']['file']).read_bytes()
                assert not actual.get('interrupted')
            else:
                assert job['launcherExit'] == 0; process(actual)
        for role in ['baseline', 'candidate']:
            argv = commands['api-' + role]['argv']; at = argv.index(plan['sources'][role]['file'])
            assert argv[at + 1] == plan['apis'][role]; b.bind(plan['apis'][role])
        assert Path(jobs['old-positive']['captures']['stdout']['file']).read_bytes() == b'true\n'
        add('old-origin-bounded-failure', [controls_pin, jobs['old-positive']['guard'], jobs['old-mismatch']['guard'], *jobs['old-mismatch']['captures'].values()],
            'Parent positive root returns true; distinct nonfield origin fails within a three-second guard. This is a defect witness, never a semantic success.')
        values_pin, values = load(controls['controls'])
        assert values['kind'] == 'phase98-observer-origin-controls' and len(values['rows']) == 15
        helper = [row for row in values['rows'] if row['kind'] == 'exact-origin-helper']
        expected = dict(zip(['same-root', 'different-root', 'absent-root', 'child', 'grandchild', 'other-child', 'other-grandchild', 'not-field', 'root-not-child', 'empty-field', 'same-absent'],
                            [True, False, False, True, True, False, False, False, False, False, True]))
        assert len(helper) == len(expected) and {row['id'] for row in helper} == set(expected)
        for row in helper:
            assert row['passed'] and row['actual'] is row['expected'] is expected[row['id']]
            assert row['origin']['$'] == row['want']['$'] == 'KTerm'
            add('origin/' + row['id'], [controls_pin, values_pin], 'Actual final-source helper decision over complete recorded KTerms; finite ancestry behavior, not a universal termination proof.')
        qualified = read(parent['qualifiedSourceControls']['file'])
        original = {row['id']:row for row in read(qualified['emission']['file'])['programs']}
        emitted = {row['id']:row for row in values['rows'] if 'c' in row}
        assert set(emitted) == {row['id'] for row in plan['controls']}
        audit = read(plan['audit']['file']); providers = {row['maintained']['file']:row for row in audit['providers']}
        for control in plan['controls']:
            name = control['id']; row = emitted[name]; actual = b.bind(row['c'])
            assert row['passed'] and row['diagnostic'] == ''
            assert row['normalJsDriverPermission'] is (name in ['generic-array', 'schema-refusals'])
            for provider in row['providers']:
                assert same(b.bind(provider['actual']), providers[provider['actual']['file']]['admitted'])
            flags = native_flags(actual['file']); assert flags['READONLY_OBSERVERS'] == 1 and flags['UNSHARED_ARRAYS'] == 0
            if name != 'origin-swap':
                prior_c = b.bind(original[name + '-candidate']['c'])
                assert row['kind'] == 'exact-parent-C' and same(actual, b.bind(control['expectedC'])) and same(actual, prior_c)
                add('origin/C/' + name, [controls_pin, values_pin, actual, prior_c], 'Final-source checked API emits the entire exact previously executed C. Final native-stage emission remains a separate gate.')
            else:
                assert row['kind'] == 'valid-owning-declined-observer'
                symbol = 'NF_FID_' + ''.join(str(ord(c)) + '_' for c in '$observer.' + control['declinedOwner'])
                assert symbol not in Path(actual['file']).read_text()
                assert flags['TYPED_SCALARS'] == flags['SCALAR_ARRAYS'] == 0
                build = jobs['swap-clang']; run = jobs['swap-run']
                argv = commands['swap-clang']['argv']; binary = b.bind(argv[argv.index('-o') + 1])
                assert argv[1:] == ['-isystem', str(Path(argv[0]).parent.parent / 'include/clang'), '-O2', actual['file'], '-o', binary['file'], '-lm', '-pthread']
                assert commands['swap-run']['argv'] == [binary['file'], '--threads', '1', '--gpu', 'off']
                assert run['fullOutputExact']
                for stream in ['stdout', 'stderr']:
                    assert Path(run['captures'][stream]['file']).read_bytes() == control[stream].encode()
                add('origin/owning-swap-full-output', [controls_pin, values_pin, actual, build['guard'], run['guard'], *run['captures'].values()],
                    'Valid owning string-root swapping is declined by observer analysis, built from unpatched O2 C and returns every original stdout/stderr byte.')

        corpus = read(parent['qualifiedSourceCorpus']['file'])
        corpus_plans = [row for row in corpus['inputs'] if Path(row['file']).name == 'plan.json' and 'corpus-source03' in row['file']]
        assert len(corpus_plans) == 1
        selections = [dict(plan=qualified['plan'], caseIds=['real-io', 'generic-array', 'schema-refusals']),
                      dict(plan=corpus_plans[0], caseIds=['full-string-corpus']),
                      dict(plan=plan_pin, caseIds=['origin-swap'])]
        ids = [row['id'] for row in rows]; assert len(ids) == len(set(ids)) == 46
        S.save(out / 'plan.json', dict(kind='phase98-backend-specific-evidence-plan', source=source,
            cases=[dict(id=row['id'], scope=row['scope']) for row in rows], expectationsChanged=False,
            originalPlans=[parent['plan'], plan_pin], parentSource=parent['source']))
        report.update(source=source, backendPolicy=policy_pin, parentSource=parent['source'],
            parentBackendControls=parent_pin, finalCompositionBridge=bridge_pin,
            qualifiedSource=parent['qualifiedSource'], qualifiedSourceControls=parent['qualifiedSourceControls'],
            qualifiedSourceCorpus=parent['qualifiedSourceCorpus'], documentarySnapshot=parent['documentarySnapshot'],
            inheritedSafeClosures=bridge['inheritedSafeClosures'], originControls=controls_pin,
            finalImageControlPlans=selections, plan=b.bind(out / 'plan.json'), requiredCaseIds=ids,
            counts=dict(parentEvidenceRows=29, exactPermissionDeclarations=16, boundedOldFailures=1,
                        originDecisions=11, exactPreviouslyExecutedC=3, owningSwapProgramExecutions=1),
            scope='Inherited permission and safe-helper evidence plus exact one-function origin correction and actual finite origin/refusal/full-output controls. No universal ancestry, cached-schema or native-lifetime proof. Same-source final B1/B2 self, five special programs and broad semantic gates remain mandatory.')
        _, cases = load_cases(report, b); assert len(cases) == 5
        b.unchanged(); report.update(complete=True, passed=True, inputsUnchanged=True)
    except BaseException as error:
        report.update(complete=False, passed=False, error=repr(error)); raise
    finally: save()
    print(json.dumps(dict(complete=True, passed=True, imageQualified=False, targetsRun=False, rows=len(rows), report=str(out / 'report.json'))))


if __name__ == '__main__': main()
