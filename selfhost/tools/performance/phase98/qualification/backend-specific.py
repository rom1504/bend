#!/usr/bin/env python3
"""Offline consume exact backend controls and their final-source declaration/proof bridge."""
import argparse
import hashlib
import json
from pathlib import Path
from support import Bindings, ROOT, S, backend_policy, freeze_methods, module, pin, read


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--bridge', type=Path, required=True)
    p.add_argument('--backend-policy', type=Path, required=True)
    p.add_argument('--documents', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve(); assert not out.exists(); out.mkdir(parents=True)
    b = Bindings(); freeze_methods(out, b); rows = []
    report = dict(kind='phase98-backend-specific-qualification', complete=False, passed=False,
                  imageQualified=False, wholeCompilerProved=False, targetsRun=False,
                  inputsUnchanged=False, method=pin(__file__), inputs=[], rows=rows)
    def save(): report['inputs'] = list(b.rows.values()); S.save(out / 'report.json', report)
    def load(value):
        rp = b.bind(value); r = read(rp['file'])
        assert r['complete'] and r.get('inputsUnchanged', True) and not r.get('error')
        for row in r.get('inputs', []): b.bind(row)
        return rp, r
    def record(name, evidence, scope): rows.append(dict(id=name, passed=True, evidence=evidence, scope=scope))
    def process(r, code=0):
        assert r['returncode'] == code and not r.get('stoppedFor') and not r.get('interrupted')
        if code == 0: assert r['complete']
    def executions(receipt, emission, expectations):
        by_name = {row['name']:row for row in receipt['rows']}
        assert len(by_name) == len(receipt['rows'])
        for row in receipt['rows']:
            actual = read(b.bind(row['guard'])['file']); assert actual == row['process']
            process(actual); assert row['launcherExit'] == 0
        assert {row['id'] for row in emission['programs']} == set(expectations)
        for program in emission['programs']:
            name = program['id']; expected = expectations[name]
            assert (program['stdout'], program['stderr']) == expected
            c = b.bind(program['c']); build = by_name[name + '-clang']; run = by_name[name + '-run']
            assert run['fullOutputExact']
            command = build['process']['command']; assert c['file'] in command and '-O2' in command
            binary = b.bind(command[command.index('-o') + 1]); assert binary['file'] in run['process']['command']
            folder = Path(run['guard']['file']).parent
            for stream, text in zip(['stdout', 'stderr'], expected):
                file = folder / (stream + '.log'); b.bind(file); assert file.read_bytes() == text.encode()
    save()
    try:
        bridge_pin, bridge = load(a.bridge)
        assert bridge['kind'] == 'phase98-observer-declaration-bridge' and bridge['imageQualified'] is False
        b.tree(bridge)
        source = bridge['source']; policy = backend_policy(a.backend_policy, source, b)
        assert read(policy['file'])['recipe'] == bridge['candidateRecipe']
        old = Path(bridge['qualifiedSource']['file']).read_text(); new = Path(source['file']).read_text()
        declarations = module('phase98_exact_declaration_bridge', bridge['method']['file']).declarations
        before, after = declarations(old), declarations(new)
        assert len(bridge['exactPermissionDeclarations']) == 16
        for row in bridge['exactPermissionDeclarations']:
            body = before[row['name']]; assert row['exact'] and body == after[row['name']]
            assert len(body.encode()) == row['bytes'] and hashlib.sha256(body.encode()).hexdigest() == row['sha256']
        assert {row['name'] for row in bridge['directChangedDependencies']} == {'p88_string_eq', 'nc_compile_error_known', 'nc_foreign', 'nc_unann', 'nq_candidates_mode'}
        for row in bridge['directChangedDependencies']:
            name = row['name']; assert hashlib.sha256(before[name].encode()).hexdigest() == row['beforeSha256']
            assert hashlib.sha256(after[name].encode()).hexdigest() == row['afterSha256']
            if name != 'p88_string_eq':
                text = before[name]
                for change in row['changes']:
                    assert change['old'].startswith('p88_string_eq(tg(') and change['new'].startswith('p98_tag_eq(')
                    assert change['old'] in text; text = text.replace(change['old'], change['new'])
                assert text == after[name]
        record('final-source-declaration-bridge', [bridge_pin, bridge['candidateRecipe'], bridge['qualifiedRecipe']],
               '16 exact permission declarations; five explicitly classified shared dependencies. This is not a whole-image or C lifetime proof.')
        for label, proof_key, manifest_key, expected_count in [
            ('final-permission-laws', 'finalPermissionProof', 'finalPermissionProofManifest', 7),
            ('final-tag-and-comparison-laws', 'finalTagProof', 'finalTagProofManifest', 6)]:
            proof_pin, proof = load(bridge[proof_key]); manifest_pin = b.bind(bridge[manifest_key]); manifest = read(manifest_pin['file'])
            assert proof['independentlyChecked'] and not proof['sourceOnly'] and proof['opaqueDefinitions'] == []
            assert len(proof['lawNames']) == expected_count and manifest['candidate'] == source
            assert proof['source'] == b.bind(manifest['entry'])
            origins = {row['origin']['file']:row['origin'] for row in proof['sourceClosure']}
            for item in manifest['outputs']:
                if Path(item['file']).suffix == '.bend': assert origins[item['file']] == b.bind(item)
            for item in manifest['candidateDefinitions']: assert new.count(item['original']) == 1
            assert any(item['name'] == 'p88_string_eq' and declarations(item['original'])['p88_string_eq'] == after['p88_string_eq'] for item in manifest['candidateDefinitions'])
            for phase in ['check', 'elaborate', 'kernel']: process(proof['rows'][phase]['process'])
            process(proof['rows']['kernel-negative']['process'], 1)
            assert proof['rows']['kernel']['stdout'] == 'ALL PROOFS CHECK\n'
            record(label, [proof_pin, manifest_pin], 'Exact final safe source closure independently kernel checked; unsafe native ownership remains outside these laws.')
        qualification_pin, qualification = load(bridge['backendQualification'])
        assert qualification['kind'] == 'phase98-scoped-observer-small-qualification' and qualification['executionPerformed']
        assert qualification['fullPrograms'] == 7 and not qualification.get('preparedOnly')
        plan_pin = b.bind(qualification['plan']); plan = read(plan_pin['file'])
        assert plan['recipe'] == bridge['qualifiedRecipe']
        emission_pin, emission = load(qualification['emission'])
        assert emission['executionPerformed'] and len(emission['cases']) == 25
        observed = {row['id']:row for row in emission['cases']}; assert len(observed) == 25
        assert len(plan['cases']) == 18 and len(plan['controls']) == 3
        for case in plan['cases']:
            row = observed[case['id']]
            assert row['kind'] == 'finite-certificate' and row['passed'] and row['actual'] == row['expected'] == case['expected']
            record('certificate/' + case['id'], [plan_pin, emission_pin], 'Actual qualified-source permission helper, full Boolean expected value.')
        expectations = {}
        for case in plan['controls']:
            row = observed[case['id']]; assert row['kind'] == 'actual-emission' and row['passed']
            assert all(row[key] for key in ['normalJsDriverPermission', 'checkedEntriesExact', 'falseEntriesExact', 'rawPermissionOff'])
            for role in ['baseline', 'candidate']:
                flags = row['policies'][role]
                assert flags['TYPED_SCALARS'] == flags['SCALAR_ARRAYS'] == case['scalar'] and flags['UNSHARED_ARRAYS'] == 0
                assert flags['READONLY_OBSERVERS'] == (1 if role == 'candidate' or case['scalar'] else 0)
                expectations[case['id'] + '-' + role] = (case['stdout'], case['stderr'])
            if case['scalar'] == 0:
                assert row['changedProviderRejected'] and row['shape']['borrowedReads'] > 0 and row['shape']['sharedRedirect']
            record('emission/' + case['id'], [plan_pin, emission_pin, qualification_pin], 'Exact small program output on both qualified source APIs, permission flags and false/raw entry controls.')
        refusal = observed['unknown-provider']; assert refusal['passed'] and not refusal['permission']['safe'] and not refusal['driverPermission']
        assert not any(refusal['flags'].values())
        record('unknown-provider-refused', [emission_pin], 'Actual host authority refusal keeps all optimization flags off.')
        for name in ['raw-forged-observer-context-is-inert', 'raw-observer-return-node-is-not-source', 'raw-observer-loop-node-is-not-source']:
            row = observed[name]; assert row['kind'] == 'raw-boundary' and row['passed'] and row['exactBaseline']
            record(name, [emission_pin, b.bind(plan['rawCases'])], 'Unchanged raw boundary semantics; forged context grants no permission.')
        expectations['raw-forged-observer-context-is-inert'] = ('7n\n', '')
        executions(qualification, emission, expectations)
        corpus_pin, corpus = load(bridge['corpusQualification'])
        assert corpus['kind'] == 'phase98-real-io-full-string-corpus' and corpus['pairs'] == 1444 and corpus['observedFields'] == 14 and corpus['programs'] == 3
        corpus_emission_pin, corpus_emission = load(corpus['emission'])
        assert len(corpus_emission['cases']) == 5 and all(row['passed'] for row in corpus_emission['cases'])
        corpus_case = next(row for row in corpus_emission['cases'] if row['id'] == 'full-string-corpus')
        assert corpus_case['policies']['baseline']['READONLY_OBSERVERS'] == 0 and corpus_case['policies']['candidate']['READONLY_OBSERVERS'] == 1
        expected_files = {Path(row['file']).name:b.bind(row) for row in corpus['inputs'] if Path(row['file']).name in ['expected.stdout', 'expected.stderr']}
        assert set(expected_files) == {'expected.stdout', 'expected.stderr'}
        expected = tuple(Path(expected_files['expected.' + name]['file']).read_text() for name in ['stdout', 'stderr'])
        values = json.loads(expected[0]); assert len(values) == 1444 and all(len(row) == 14 for row in values)
        executions(corpus, corpus_emission, {**{name:expected for name in ['full-string-corpus-baseline', 'full-string-corpus-candidate']},
                                           'raw-forged-observer-context-is-inert':('7n\n', '')})
        record('full-string-alias-corpus', [corpus_pin, corpus_emission_pin, *expected_files.values()],
               '1444 pairs,14 full observations including surviving left/right characters, on qualified-source native products.')
        documents_pin = b.bind(a.documents); documents = read(documents_pin['file'])
        assert documents['kind'] == 'phase98-audited-document-snapshot' and documents['complete']
        for row in documents['rows']:
            b.bind(row['original']); b.bind(row['snapshot'])
            assert all(row['original'][k] == row['snapshot'][k] for k in ['sha256', 'bytes'])
        ids = [row['id'] for row in rows]; assert len(ids) == len(set(ids)) == 29
        S.save(out / 'plan.json', dict(kind='phase98-backend-specific-evidence-plan', source=source,
                                     cases=[dict(id=row['id'], scope=row['scope']) for row in rows],
                                     originalPlans=[plan_pin, bridge_pin], expectationsChanged=False))
        b.unchanged()
        report.update(complete=True, passed=True, inputsUnchanged=True, source=source, backendPolicy=policy,
                      qualifiedSource=bridge['qualifiedSource'], qualifiedSourceControls=qualification_pin,
                      qualifiedSourceCorpus=corpus_pin, finalCompositionBridge=bridge_pin,
                      finalPermissionProof=bridge['finalPermissionProof'], finalTagProof=bridge['finalTagProof'],
                      documentarySnapshot=documents_pin, plan=b.bind(out / 'plan.json'), requiredCaseIds=ids,
                      counts=dict(finiteCertificates=18, smallProgramExecutions=7, corpusProgramExecutions=3,
                                  corpusPairs=1444, observedFields=14, exactPermissionDeclarations=16, finalLaws=13),
                      scope='Validated existing qualified-source controls plus exact final declaration/dependency bridge and final-source kernel laws. No new target runs and no automatic transfer of native lifetime, generated-C identity or whole-image correctness. Final same-source B1/B2 self and semantic gates remain mandatory in admit.py.')
    except BaseException as error:
        report.update(complete=False, passed=False, error=repr(error)); raise
    finally: save()
    print(json.dumps(dict(complete=True, passed=True, imageQualified=False, targetsRun=False, rows=len(rows), report=str(out / 'report.json'))))


if __name__ == '__main__': main()
