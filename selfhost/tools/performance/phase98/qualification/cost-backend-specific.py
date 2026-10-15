#!/usr/bin/env python3
"""Offline extend parent permission evidence with exact planning-cost source and controls."""
import argparse
import hashlib
import json
from pathlib import Path
from support import Bindings, S, backend_policy, freeze_methods, module, pin, read


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['parent-controls', 'bridge', 'backend-policy', 'out']:
        p.add_argument('--' + name, type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve(); assert not out.exists(); out.mkdir(parents=True)
    b = Bindings(); freeze_methods(out, b); rows = []
    report = dict(kind='phase98-backend-specific-qualification', complete=False, passed=False,
                  imageQualified=False, wholeCompilerProved=False, targetsRun=False,
                  inputsUnchanged=False, method=pin(__file__), inputs=[], rows=rows)
    def save(): report['inputs'] = list(b.rows.values()); S.save(out / 'report.json', report)
    def load(value, completed=True):
        rp = b.bind(value); r = read(rp['file']); b.tree(r)
        if completed: assert r['complete'] and r.get('inputsUnchanged', True) and not r.get('error')
        return rp, r
    def add(name, evidence, scope): rows.append(dict(id=name, passed=True, evidence=evidence, scope=scope))
    def process(value, code=0):
        assert value['returncode'] == code and not value.get('stoppedFor') and not value.get('interrupted')
        if code == 0: assert value['complete']
    def array(value):
        result = []
        while value['$'] == 'Con': result.append(value['head']); value = value['tail']
        assert value == {'$':'Nil'}; return result
    def text(value):
        if value['$'] == 'NC_Empty': return ''
        if value['$'] == 'NC_Leaf': return value['text']
        assert value['$'] == 'NC_Join'; return text(value['left']) + text(value['right'])
    save()
    try:
        parent_pin, parent = load(a.parent_controls)
        assert parent['kind'] == report['kind'] and parent['passed'] and not parent['imageQualified']
        assert len(parent['rows']) == 29 and all(row['passed'] for row in parent['rows'])
        bridge_pin, bridge = load(a.bridge)
        assert bridge['kind'] == 'phase98-observer-cost-declaration-bridge' and not bridge['imageQualified']
        assert bridge['parentSource'] == parent['source'] and bridge['priorDeclarationBridge'] == parent['finalCompositionBridge']
        assert bridge['backendQualification'] == parent['qualifiedSourceControls'] and bridge['corpusQualification'] == parent['qualifiedSourceCorpus']
        source = bridge['source']; policy_pin = backend_policy(a.backend_policy, source, b); policy = read(policy_pin['file'])
        assert policy['recipe'] == bridge['candidateRecipe']
        recipe_pin, recipe = load(policy['recipe']); old = Path(recipe['parentSource']['file']).read_text(); new = Path(source['file']).read_text()
        assert recipe['parentSource'] == parent['source'] and recipe['candidate'] == source
        def replay(text, edits):
            for change in edits:
                at, before, after = change['offset'], change['old'], change['new']
                assert isinstance(at, int) and 0 <= at <= len(text) and at + len(before) <= len(text)
                assert text[at:at + len(before)] == before
                text = text[:at] + after + text[at + len(before):]
            return text
        assert replay(Path(recipe['source']['file']).read_text(), recipe['changes']) == new
        assert replay(old, recipe['localChanges']) == new
        prior_bridge = read(parent['finalCompositionBridge']['file'])
        declarations = module('phase98_cost_declarations', prior_bridge['method']['file']).declarations
        before, after = declarations(old), declarations(new)
        assert sorted(name for name in before if before[name] != after.get(name)) == ['no_route', 'no_scalar_redirect']
        added = sorted(set(after) - set(before)); assert added == bridge['addedCacheDeclarations']
        assert added == sorted(name + '_cached' for name in recipe['originalHelpersPreserved']) and len(added) == 9
        for row in bridge['exactPermissionDeclarations']:
            body = after[row['name']]; assert row['exact'] and body == before[row['name']]
            assert len(body.encode()) == row['bytes'] and hashlib.sha256(body.encode()).hexdigest() == row['sha256']
        assert len(bridge['exactPermissionDeclarations']) == 16
        for key in ['finalPermissionProofManifest', 'finalTagProofManifest']:
            for item in read(prior_bridge[key]['file'])['candidateDefinitions']: assert new.count(item['original']) == 1
        for row in parent['rows']:
            add('parent/' + row['id'], [parent_pin, *row['evidence']],
                'Inherited parent-source evidence, connected by the exact cost declaration bridge. ' + row['scope'])
        add('cost-declaration-bridge', [bridge_pin, recipe_pin, bridge['cacheCloneSourceAudit']],
            'Only no_route/no_scalar_redirect change; nine cached helpers added; sixteen permission declarations and prior safe proof closures remain exact. Cached unsafe resolver equivalence is source audited and finitely tested, not universally proved.')

        audit = read(bridge['cacheCloneSourceAudit']['file']); assert audit['source'] == source and audit['redirectClosureByteIdentical']
        assert len(audit['scalarCloneNormalizations']) == 9 and all(row['codeEqual'] for row in audit['scalarCloneNormalizations'])
        proof_pin, proof = load(bridge['acceptedRedirectProof'])
        assert proof['independentlyChecked'] and not proof['sourceOnly'] and proof['opaqueDefinitions'] == []
        assert set(proof['lawNames']) == {'redirect_worker_choice', 'redirect_list_cons', 'redirect_workers_preserves'}
        for phase in ['check', 'elaborate', 'kernel']: process(proof['rows'][phase]['process'])
        process(proof['rows']['kernel-negative']['process'], 1); assert proof['rows']['kernel']['stdout'] == 'ALL PROOFS CHECK\n'
        prepared_pin, prepared = load(audit['redirectPrepared'], completed=False)
        assert prepared['candidate'] == source and new.count(prepared['actual']['original']) == 1
        assert old.count(prepared['reference']['original']) == 1
        for item in prepared['definitions']: assert new.count(item['original']) == 1
        checked = {Path(row['origin']['file']).name:row['origin'] for row in proof['sourceClosure']}
        for item in prepared['outputs']:
            if Path(item['file']).suffix == '.bend':
                assert all(item[k] == checked[Path(item['file']).name][k] for k in ['sha256', 'bytes'])
        add('redirect-three-laws', [proof_pin, prepared_pin],
            'Accepted independent kernel proof and byte-identical final extracted closure; full worker-list value preservation, not native lifetime or cached schema proof.')

        controls_pin, controls = load(bridge['exactCAndFullValueControls'])
        assert controls['kind'] == 'phase98-observer-cost-controls-v2' and controls['targetsRun'] and controls['reusesAdmittedApis']
        assert controls['launcherExit'] == 0 and read(controls['guard']['file']) == controls['process']; process(controls['process'])
        plan_pin, plan = load(controls['plan'], completed=False)
        assert plan['recipe'] == recipe_pin and plan['sources'] == dict(baseline=parent['source'], candidate=source)
        values_pin, values = load(controls['controls'])
        assert values['kind'] == 'phase98-observer-cost-full-values' and values['workerCases'] == 105 and values['schemaCases'] == 60
        assert len(values['rows']) == 168 and len({row['id'] for row in values['rows']}) == 168
        # The first attempt's value test failed, but its two guarded API builds
        # succeeded. Reuse only those exact source-bound products, not its failure.
        reused_pin, reused = load(plan['reusedAcquisition'], completed=False)
        assert not reused['complete']; reused_plan = read(reused['plan']['file'])
        assert reused_plan['sources'] == plan['sources'] and reused_plan['apis'] == plan['apis']
        for role in ['baseline', 'candidate']:
            row = next(row for row in reused['rows'] if row['name'] == 'api-' + role)
            assert row['launcherExit'] == 0 and read(row['guard']['file']) == row['process']; process(row['process'])
            command = row['process']['command']; at = command.index(plan['sources'][role]['file'])
            assert command[at + 1] == plan['apis'][role]; b.bind(plan['apis'][role])
        workers = [row for row in values['rows'] if row['kind'] == 'full-worker-list']
        assert len(workers) == 105
        expected_keys = {(fixture, owner, tuple(roots)) for fixture in range(7) for owner in ['owner', 'λ🙂', ''] for roots in [[], [0], [1], [0, 1], [3]]}
        assert {(row['fixture'], row['owner'], tuple(row['roots'])) for row in workers} == expected_keys
        for row in workers:
            assert row['passed']; result = read(b.bind(row['result'])['file']); assert result['baseline'] == result['candidate']
            original, actual = array(result['input']), array(result['candidate']); assert len(original) == len(actual)
            for old_worker, new_worker in zip(original, actual):
                if old_worker['name'] != row['owner']: assert new_worker == old_worker; continue
                assert {k:v for k,v in old_worker.items() if k not in ['code', 'deps']} == {k:v for k,v in new_worker.items() if k not in ['code', 'deps']}
                assert {k:v for k,v in old_worker['code'].items() if k != 'body'} == {k:v for k,v in new_worker['code'].items() if k != 'body'}
                assert array(new_worker['deps']) == ['$observer.adapter.' + row['owner'], *array(old_worker['deps'])]
                body = new_worker['code']['body']; assert text(body).startswith('if (') and text(body).endswith(text(old_worker['code']['body']))
                if old_worker['code']['body']['$'] == 'NC_Empty': assert body['$'] == 'NC_Leaf'
                else: assert body['$'] == 'NC_Join' and body['right'] == old_worker['code']['body']
            add('cost/' + row['id'], [controls_pin, values_pin, row['result']], 'Full worker list equality plus independent preservation of every untouched field, duplicate dependencies and original NC_Text subtree.')
        schemas = [row for row in values['rows'] if row['kind'] == 'full-schema']; assert len(schemas) == 60
        expected_keys = {(case['id'], name, fresh) for case in plan['controls'] for name in case['schemaNames'] + ['String', '__p98_absent_schema__'] for fresh in [0, 1, 2147483600]}
        assert {(row['control'], row['name'], row['fresh']) for row in schemas} == expected_keys
        for row in schemas:
            result = read(b.bind(row['result'])['file']); assert row['passed'] and result['baseline'] == result['candidate']
            assert result['candidate']['$'] == 'NO_Schema'
            add('cost/' + row['id'], [controls_pin, values_pin, row['result']], 'Complete schema tree equals unchanged parent actual operation; finite correspondence, including ordered/duplicate specs and refusal diagnostics.')
        q = read(parent['qualifiedSourceControls']['file']); emission = read(q['emission']['file'])
        programs = {row['id']:row for row in emission['programs']}
        c_rows = [row for row in values['rows'] if row['kind'] == 'complete-C-and-diagnostic']
        assert {row['id'] for row in c_rows} == {'real-io', 'generic-array', 'schema-refusals'}
        for row in c_rows:
            original = programs[row['id'] + '-candidate']['c']; actual = b.bind(row['c']); b.bind(original)
            assert row['passed'] and row['diagnostic'] == '' and all(actual[k] == original[k] for k in ['sha256', 'bytes'])
            assert row['normalJsDriverPermission'] is (row['id'] != 'real-io')
            add('cost/C/' + row['id'], [controls_pin, values_pin, actual, original, parent['qualifiedSourceControls']],
                'Actual a025 API C is byte-identical to the previously executed qualified-source small product. This does not assert final native-image emission.')
        ids = [row['id'] for row in rows]; assert len(ids) == len(set(ids)) == 199
        S.save(out / 'plan.json', dict(kind='phase98-backend-specific-evidence-plan', source=source,
            cases=[dict(id=row['id'], scope=row['scope']) for row in rows], expectationsChanged=False,
            originalPlans=[parent['plan'], plan_pin], parentSource=parent['source']))
        b.unchanged()
        report.update(complete=True, passed=True, inputsUnchanged=True, source=source, backendPolicy=policy_pin,
            parentSource=parent['source'], parentBackendControls=parent_pin, finalCompositionBridge=bridge_pin,
            qualifiedSource=parent['qualifiedSource'], qualifiedSourceControls=parent['qualifiedSourceControls'],
            qualifiedSourceCorpus=parent['qualifiedSourceCorpus'], documentarySnapshot=parent['documentarySnapshot'],
            acceptedRedirectProof=proof_pin, inheritedPermissionProof=bridge['inheritedPermissionProof'],
            inheritedTagProof=bridge['inheritedTagProof'], costControls=controls_pin,
            plan=b.bind(out / 'plan.json'), requiredCaseIds=ids,
            counts=dict(parentEvidenceRows=29, workers=105, schemas=60, exactPreviouslyExecutedC=3,
                        permissionDeclarations=16, cachedHelpers=9, redirectLaws=3),
            scope='Source02 execution -> exact parent59 permission bridge -> exact a025 cost bridge and observed full-value/three-C controls. Inherited safe proof closures and accepted redirect closure remain exact. Cached planning is not universally proved; no automatic native ownership, full-corpus C or whole-image qualification transfer. Actual final same-source B1/B2 self and semantic gates remain mandatory.')
    except BaseException as error:
        report.update(complete=False, passed=False, error=repr(error)); raise
    finally: save()
    print(json.dumps(dict(complete=True, passed=True, imageQualified=False, targetsRun=False, rows=len(rows), report=str(out / 'report.json'))))


if __name__ == '__main__': main()
