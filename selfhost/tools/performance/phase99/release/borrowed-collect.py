#!/usr/bin/env python3
"""Offline source-bound borrowed-call evidence collector; preserves frozen admission schema."""
import argparse
import hashlib
import json
from pathlib import Path
import re
from borrowed_support import S, ROOT, DECLARATIONS, load, small, micro, mechanism, raw, flags, control_cases


def same(a, b): return all(a[key] == b[key] for key in ['sha256', 'bytes'])


def proof(b, source, manifest_path, positive_path, negative_path):
    mp, manifest = load(b, manifest_path); b.tree(manifest); assert manifest['source'] == source
    extraction = S.module('phase99_borrowed_source_declarations', b.bind(DECLARATIONS)['file'])
    table = extraction.declarations(Path(source['file']).read_text())
    for declaration in manifest['declarations']:
        assert extraction.unique(table, declaration['name']) == declaration['original']
        body = declaration['original'].removeprefix('@unsafe\n')
        assert body == declaration['extracted'] and '@unsafe' not in body
        assert hashlib.sha256(body.encode()).hexdigest() == declaration['extractedSha256']
    name = re.search(r'(?m)^def ([\w.]+)\(', manifest['actualCaller'])[1]
    assert extraction.unique(table, name) == manifest['actualCaller']
    expected = {row['role']:row for row in manifest['rows']}; assert len(expected) == 4
    positive_text = 'import Base\n\n' + ''.join(row['extracted'] for row in manifest['declarations'])
    assert Path(expected['positive']['helper']['file']).read_text() == positive_text
    mutations = {row['role']:row for row in manifest['mutations']}; assert set(mutations) == set(expected) - {'positive'}
    for role, mutation in mutations.items():
        original = next(row['extracted'] for row in manifest['declarations'] if row['name'] == mutation['helper'])
        assert original.count(mutation['old']) == 1 and positive_text.count(original) == 1
        changed = positive_text.replace(original, original.replace(mutation['old'], mutation['new']))
        assert Path(expected[role]['helper']['file']).read_text() == changed
    pp, positive = load(b, positive_path)
    assert positive['independentlyChecked'] and not positive['sourceOnly'] and positive['opaqueDefinitions'] == []
    assert len(positive['lawNames']) == 3 and positive['source'] == expected['positive']['laws']
    def closure(report, entry, helper):
        assert report['source'] == entry; origins = {row['origin']['file']:row for row in report['sourceClosure']}
        assert set(origins) == {entry['file'], helper['file']}
        for item in [entry, helper]:
            row = origins[item['file']]; assert b.bind(row['origin']) == item
            assert same(b.bind(row['snapshot']), item)
    closure(positive, expected['positive']['laws'], expected['positive']['helper'])
    for role in ['check', 'elaborate', 'kernel', 'kernel-negative']:
        raw(b, Path(pp['file']).parent / role, positive['rows'][role], 1 if role == 'kernel-negative' else 0)
    assert positive['rows']['kernel']['stdout'] == 'ALL PROOFS CHECK\n' and not positive['rows']['kernel']['stderr']
    np, negative = load(b, negative_path)
    pairs = {(row['role'], row['kind']):row for row in negative['rows']}
    assert len(pairs) == len(negative['rows']) == 6
    for role in set(expected) - {'positive'}:
        record = expected[role]; assert record['expectedStandaloneAdmission'] == 'accept' and record['expectedLawCheck'] == 'reject'
        assert same(record['laws'], expected['positive']['laws'])
        for kind in ['candidate', 'laws']:
            row = pairs[role, kind]; assert row['expectedOutcome']
            rp, result = load(b, row['report'], complete=kind == 'candidate')
            assert result['sourceOnly'] and result['source'] == record['helper' if kind == 'candidate' else 'laws']
            if kind == 'laws':
                assert not result['complete']; closure(result, record['laws'], record['helper'])
            else:
                assert len(result['sourceClosure']) == 1
                item = result['sourceClosure'][0]; assert b.bind(item['origin']) == record['helper']
                assert same(b.bind(item['snapshot']), record['helper'])
            check = result['rows']['check']; raw(b, Path(rp['file']).parent / 'check', check, 0 if kind == 'candidate' else 1)
            if kind == 'candidate': assert check['stdout'] == 'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n' and not check['stderr']
            else: assert 'Error:' in check['stdout'] + check['stderr'] and re.search(r'expected', check['stdout'] + check['stderr'], re.I)
    return dict(kind=manifest['kind'], evidence=[mp, pp, np], laws=3, admittedBadChanges=3,
                declarations=[row['name'] for row in manifest['declarations']])


def final(b, path, source, policy, ctx, producers):
    fp, result = load(b, path)
    assert result['kind'] == 'phase99-final-image-borrowed-controls' and result['passed'] and result['executionPerformed']
    assert result['source'] == source and result['producers'] == producers and result['backendPolicy'] == policy
    reference = S.baseline_producer(ctx, 'b2'); assert result['referenceProducer'] == reference
    qp, plan, pp, ep, static = small(b, result['smallQualification'], source)
    assert result['originalPlan'] == pp and result['originalEmission'] == ep and result['allTrivialAlternative'] == static
    cases = control_cases(b, plan, ep)
    cases += [micro(b, row['oracleReceipt'], source) for row in result['cases'][len(cases):]]
    assert cases == result['cases'] and len({row['id'] for row in cases}) == len(cases)
    if static: assert any('static' in row['id'] and '10000000\n' in row['stdout'] for row in cases)
    assert len(result['rows']) == 3 * len(cases) and len(result['programs']) == len(cases)
    def request(row, producer, case, diagnostic):
        assert row['passed'] and row['source'] == case['source'] and not row['live']
        records = {Path(item['file']).name:b.bind(item) for item in row['raw']}
        folder = Path(records['process.json']['file']).parent; actual = raw(b, folder, row)
        assert actual['command'] == row['command'] and not (folder / 'stdout.log').read_bytes()
        prefix = folder.parent / 'output'; argv = S.native_args(ctx, producer, case['source']['file'], prefix, False)
        assert row['command'][-len(argv):] == argv
        assert S.strip_clocks((folder / 'stderr.log').read_text()) == row['diagnostic'] == diagnostic
        assert row['output']['file'] == str(prefix) + '.1.c'; b.bind(row['output'])
        assert Path(b.bind(row['diagnosticFile'])['file']).read_text() == diagnostic
    for index, case in enumerate(cases):
        rows = result['rows'][3*index:3*index+3]
        assert [row['stage'] for row in rows] == ['reference', 'b1', 'b2'] and all(row['id'] == case['id'] for row in rows)
        assert rows[0]['referenceDiagnosticCaptured']; diagnostic = rows[0]['diagnostic']; request(rows[0], reference, case, diagnostic)
        assert flags(rows[0]['output']['file']) == case['expectedFlags']
        for row in rows[1:]:
            request(row, producers[row['stage']], case, diagnostic)
            assert flags(row['output']['file']) == row['flags'] == case['expectedFlags']
            active = row['flags']; assert active['READONLY_OBSERVERS'] == 1
            assert active['TYPED_SCALARS'] == active['SCALAR_ARRAYS'] == case['scalar']
            assert mechanism(b, row['output'], case, static) == row['mechanism']
        assert rows[2]['exactC'] and same(rows[1]['output'], rows[2]['output'])
        product = result['programs'][index]
        assert product['id'] == case['id'] and product['passed'] and product['fullOutputExact'] and product['c'] == rows[1]['output']
        assert product['runtimeArgs'] == case['runtimeArgs']; binary = b.bind(product['binary'])['file']; cc = ctx['clang']['file']
        for role in ['build', 'run']:
            job = product[role]; assert job['passed']
            records = {Path(item['file']).name:b.bind(item) for item in job['raw']}
            actual = raw(b, Path(records['process.json']['file']).parent, job); assert actual['command'] == job['command']
            executable = cc if role == 'build' else binary
            expected = [cc, '-isystem', str(Path(cc).parents[1] / 'include/clang'), '-O2', product['c']['file'], '-o', binary, '-lm', '-pthread'] if role == 'build' else [binary, *case['runtimeArgs']]
            assert actual['command'][actual['command'].index(executable):] == expected
            if role == 'run':
                for stream in ['stdout', 'stderr']:
                    assert records[stream + '.log'] == b.bind(product[stream])
                    assert Path(product[stream]['file']).read_bytes() == case[stream].encode()
    return fp, result, qp, pp, ep


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['b1-build', 'b2-build', 'backend-policy', 'final', 'self-c', 'out']: p.add_argument('--' + name, type=Path, required=True)
    p.add_argument('--laws', nargs=3, action='append', type=Path, required=True, metavar=('MANIFEST', 'POSITIVE', 'NEGATIVES'))
    p.add_argument('--inherited', type=Path, default=ROOT / 'selfhost/build/phase98/origin-backend-specific01/report.json')
    a = p.parse_args(); out = a.out.resolve(); assert out.is_relative_to(ROOT / 'selfhost/build/phase99') and not out.exists()
    b = S.Bindings(); ctx = S.baseline(b); producers = {}; builds = {}
    for stage, path in [('b1', a.b1_build), ('b2', a.b2_build)]:
        builds[stage] = S.read(path); producers[stage] = S.authenticate(builds[stage]['binary'], stage, builds[stage]['source'], path, b, ctx)
    source = producers['b1']['source']; assert source == producers['b2']['source']; policy = S.backend_policy(a.backend_policy, source, b)
    out.mkdir(parents=True); S.freeze_methods(out, b); rows = []
    report = dict(kind='phase98-backend-specific-qualification', complete=False, passed=False, inputsUnchanged=False,
        imageQualified=False, wholeCompilerProved=False, targetsRun=False, source=source, backendPolicy=policy,
        rows=rows, method=S.pin(__file__), inputs=[])
    def save(): report['inputs'] = list(b.rows.values()); S.S.save(out / 'report.json', report)
    def add(name, evidence, scope): rows.append(dict(id=name, passed=True, evidence=evidence, scope=scope))
    save()
    try:
        fp, final_result, qp, pp, ep = final(b, a.final, source, policy, ctx, producers)
        for case in S.read(pp['file'])['cases']:
            add('predicate/' + case['id'], [qp, pp, ep], 'Actual selected-source helper and exact finite expectation; no universal native lifetime theorem.')
        add('checked-authority-and-raw-refusals', [qp, pp, ep], 'Exact selected-source checked entry agreement, denied/raw flags, changed/unknown provider refusal, forged raw boundary and complete tiny native products.')
        for case in final_result['cases']:
            add('final-native/' + case['id'], [fp, pp, *([case['oracleReceipt']] if 'oracleReceipt' in case else [])],
                'Final B1/B2 exact whole C, independent baseline diagnostics, borrowed-only worker calls and refusals, matched unpatched build and full original outputs.')
        laws = [proof(b, source, *bundle) for bundle in a.laws]
        kinds = {row['kind'] for row in laws}
        assert len(kinds) == len(laws) and 'phase99-borrowed-argument-law-preparation' in kinds
        if final_result['allTrivialAlternative']: assert 'phase99-all-trivial-guard-law-preparation' in kinds
        for row in laws: add('laws/' + row['kind'], row['evidence'], 'Three actual source helper laws independently kernel checked; three bad helpers safely admitted before unchanged laws reject.')
        sp, inspection = load(b, a.self_c)
        assert inspection['passed'] and inspection['inputs']['source'] == source and all(inspection['assertions'].values())
        assert inspection['inputs']['candidate'] == builds['b2']['c']
        emission = S.read(b.bind(builds['b2']['emission'])['file']); reference = S.read(b.bind(emission['oracleReport'])['file'])
        assert reference['source'] == source and reference['producer'] == S.baseline_producer(ctx, 'b2')
        assert inspection['inputs']['reference'] == reference['row']['output']; b.tree(inspection['inputs'])
        add('own-self-c-mechanism', [sp, b.bind(builds['b2']['emission'])], 'Exact selected self C: borrowed call edges, owned adapter cleanup and retained owning fallback; no dynamic coverage claim.')
        inherited_pin, inherited = load(b, a.inherited)
        assert inherited['kind'] == 'phase98-backend-specific-qualification' and inherited['passed'] and inherited['source'] == ctx['source']
        extraction = S.module('phase99_inherited_declarations', b.bind(DECLARATIONS)['file'])
        old, new = [extraction.declarations(Path(item['file']).read_text()) for item in [ctx['source'], source]]
        changed = {name for name in old.keys() & new.keys() if list(map(extraction.code, old[name])) != list(map(extraction.code, new[name]))}
        allowed = set('NO_Context NO_Route no_emit no_worker noa_book noa_owner noa_schema noa_reference noa_analyze no_plan_schema_ready no_route_workers no_route_ready no_route_entries no_route_pair no_route_plan no_route_one no_route no_route_schema'.split())
        if final_result['allTrivialAlternative']: allowed.add('no_scalar_redirect')
        assert changed == allowed
        removed = set(old) - set(new); added = set(new) - set(old)
        assert removed == {'no_emit_let', 'no_emit_match_found', 'no_emit_match_layout'}
        assert all(name.startswith(('no_', 'noa_', 'nob_')) or name == 'NO_Callee' for name in added)
        bridge = dict(source=source, reference=ctx['source'], changedDeclarations=sorted(changed), addedDeclarations=sorted(added),
            removedDeclarations=sorted(removed), retainedDeclarations=len(old.keys() & new.keys())-len(changed),
            comparison='Complete declaration code after excluding blank/comment-only lines and trailing whitespace; not semantic equivalence for the explicit changed declarations.')
        S.S.save(out / 'source-boundary.json', bridge)
        add('retained-phase98-boundaries', [inherited_pin, b.bind(out / 'source-boundary.json')], 'All nonlisted declaration code retained. Historical evidence remains historical; new full-image final-five and ordinary gates remain mandatory.')
        for key in ['qualifiedSourceControls', 'qualifiedSourceCorpus', 'originControls', 'finalImageControlPlans']:
            report[key] = inherited[key]; b.tree(inherited[key])
        plan = dict(kind='phase98-backend-specific-evidence-plan', source=source, cases=[dict(id=row['id'], scope=row['scope']) for row in rows])
        S.S.save(out / 'plan.json', plan); b.unchanged()
        report.update(complete=True, passed=True, inputsUnchanged=True, plan=b.bind(out / 'plan.json'), requiredCaseIds=[row['id'] for row in rows],
            smallQualification=qp, finalBorrowedControls=fp, selfCInspection=sp, inheritedControls=inherited_pin,
            counts=dict(finitePredicates=len(S.read(pp['file'])['cases']), finalPrograms=len(final_result['cases']), laws=3*len(laws), admittedBadChanges=3*len(laws)),
            scope='Source-bound finite/helper/native evidence, not whole-compiler or native RC proof. Frozen final-five, self, ordinary controls, broad45 and native69 remain separate admission gates.')
    except BaseException as error: report['error'] = repr(error); raise
    finally: save()
    print(json.dumps(dict(complete=True, passed=True, targetsRun=False, report=str(out / 'report.json'))))


if __name__ == '__main__': main()
