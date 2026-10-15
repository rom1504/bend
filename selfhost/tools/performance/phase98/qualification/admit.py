#!/usr/bin/env python3
"""Offline collect actual candidate gates into a compact, nondefault native admission."""
import argparse
import json
from pathlib import Path
import re
from support import (Bindings, ROOT, SUCCESS_DIAGNOSTIC, authenticate, backend_policy,
                     baseline, baseline_producer, native_args, pin, read, strip_clocks)


def same(a, b): return all(a[k] == b[k] for k in ['sha256', 'bytes'])


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['b1-build', 'b2-build', 'b1-self', 'b2-self', 'source-recipe', 'conformance']:
        p.add_argument('--' + name, type=Path, required=True)
    p.add_argument('--controls', type=Path, nargs='+', required=True)
    p.add_argument('--broad45', type=Path, nargs='+', required=True)
    p.add_argument('--backend-policy', type=Path)
    p.add_argument('--backend-controls', type=Path)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); assert not a.out.exists()
    b = Bindings(); ctx = baseline(b); b.bind(__file__); b.bind(Path(__file__).with_name('support.py'))
    receipts = {}; producers = {}; builds = {}
    def report(file, kind):
        rp = b.bind(file); r = read(rp['file'])
        assert r['kind'] == kind and r['complete'] and r['passed'] and r['inputsUnchanged'] and not r.get('error')
        for item in r.get('inputs', []): b.bind(item)
        if 'method' in r: b.bind(r['method'])
        return rp, r
    def process(value, expected):
        assert value['complete'] and value['returncode'] == expected and not value.get('stoppedFor') and not value.get('interrupted')
    def request_row(row, producer, expected_diagnostic, expected_output=None, negative=False):
        assert row['passed']; raw = {Path(x['file']).name:b.bind(x) for x in row['raw']}
        actual = read(raw['process.json']['file']); assert actual == row['process']; process(actual, 1 if negative else 0)
        assert actual['command'] == row['command'] and not Path(raw['stdout.log']['file']).read_bytes()
        prefix = Path(raw['process.json']['file']).parent.parent / 'output'
        argv = native_args(ctx, producer, row['source']['file'], prefix, row['live'])
        assert actual['command'][-len(argv):] == argv, 'Raw command must use the selected producer and exact assets'
        text = Path(raw['stderr.log']['file']).read_text()
        assert strip_clocks(text) == row['diagnostic'] == expected_diagnostic
        if negative:
            assert 'output' not in row and not Path(str(prefix) + '.1.c').exists()
            return
        output = b.bind(row['output']); b.bind(row['diagnosticFile'])
        assert output['file'] == str(prefix) + '.1.c'
        assert Path(row['diagnosticFile']['file']).read_text() == expected_diagnostic
        assert len(re.findall(r'^request=1 request_ms=\d+ consumed_chars=\d+$', text, re.M)) == 1
        if expected_output is not None: assert same(output, expected_output)
    for stage in ['b1', 'b2']:
        path = getattr(a, stage + '_build'); builds[stage] = read(path)
        producers[stage] = authenticate(builds[stage]['binary'], stage, builds[stage]['source'], path, b, ctx)
        receipts[stage + 'Build'] = b.bind(path)
    source = producers['b1']['source']; assert source == producers['b2']['source']
    profile = Bindings(); recipe_pin = profile.bind(a.source_recipe); recipe = read(recipe_pin['file']); profile.tree(recipe)
    assert recipe['complete'] and recipe['candidate'] == source
    assert same(recipe['source'], ctx['source']), 'Profile must replay from the authenticated baseline source'
    text = Path(recipe['source']['file']).read_text(); before = text
    for change in recipe['changes']:
        at = change['offset']; old, new = change['old'], change['new']
        assert text[at:at + len(old)] == old
        text = text[:at] + new + text[at + len(old):]
    assert text == Path(source['file']).read_text()
    for change in reversed(recipe['changes']):
        at = change['offset']; old, new = change['old'], change['new']
        assert text[at:at + len(new)] == new
        text = text[:at] + old + text[at + len(new):]
    assert text == before
    for item in profile.rows.values(): b.bind(item)
    policy_pin = backend_policy(a.backend_policy, source, b) if a.backend_policy else None
    self_rows = {}
    for stage in ['b1', 'b2']:
        rp, r = report(getattr(a, stage + '_self'), 'phase98-native-qualification-request')
        assert r['source'] == source and r['producer'] == producers[stage]
        receipts[stage + 'Self'] = rp; self_rows[stage] = r
        request_row(r['row'], producers[stage], r['row']['diagnostic'])
    first, second = self_rows['b1'], self_rows['b2']
    assert second['purpose'] == 'compare' and second['row']['exactC']
    assert same(first['row']['output'], second['row']['output'])
    assert first['row']['diagnostic'] == second['row']['diagnostic']
    assert builds['b2']['emission'] == receipts['b1Self'] and same(builds['b2']['c'], first['row']['output'])
    reference_pin, reference = report(first['oracleReport'], 'phase98-native-qualification-request')
    assert reference['source'] == source and reference['purpose'] == 'reference'
    assert reference['producer'].get('historicalBaseline') and reference['producer']['stage'] == 'b2'
    assert reference['row']['referenceDiagnosticCaptured']
    request_row(reference['row'], baseline_producer(ctx, 'b2'), first['row']['diagnostic'])
    receipts['independentReference'] = reference_pin
    if policy_pin:
        assert first['purpose'] == 'changed-backend' and first['backendPolicy'] == second['backendPolicy'] == policy_pin
        assert second['oracleReport'] == receipts['b1Self']
    else:
        assert first['purpose'] == 'compare' and first['row']['exactC']
        assert second['oracleReport'] == reference_pin and same(first['row']['output'], reference['row']['output'])
    # Historical semantic sources and exact output oracles remain independent.
    control_origin = b.bind(ROOT / 'selfhost/build/phase90/native07-qualification01/report.json')
    negative_origin = b.bind(ROOT / 'selfhost/build/phase92/conformance01/diagnostics/report.json')
    broad_origin = b.bind(ROOT / 'selfhost/build/phase92/broad02/report.json')
    for origin in [control_origin, negative_origin, broad_origin]:
        old = read(origin['file']); assert old['complete'] and old['passed'] and old['inputsUnchanged']
    original_controls = read(control_origin['file'])['compilerRows']
    original_negatives = [r for r in read(negative_origin['file'])['rows'] if r['role'] == 'b1']
    broad_reference = read(broad_origin['file']); original_broad = broad_reference['cases']
    assert len(original_controls) == 8 and len(original_negatives) == 3 and len(original_broad) == 45
    assert len(broad_reference['programExecutions']) == 45 and all(row['passed'] for row in broad_reference['programExecutions'])
    for suite, paths in [('controls', a.controls), ('broad45', a.broad45)]:
        receipts[suite] = []; seen = set()
        expected = original_controls if suite == 'controls' else original_broad
        for path in paths:
            rp, r = report(path, 'phase98-changed-backend-gates' if policy_pin else 'phase98-private-native-qualification-gates')
            receipts[suite].append(rp); assert r['suite'] == suite
            stages = ['b1', 'b2'] if policy_pin else [r['producer']['stage']]
            if policy_pin:
                assert r['backendPolicy'] == policy_pin and r['producers'] == producers
            else: assert r['producer'] == producers[stages[0]]
            for stage in stages:
                assert stage not in seen; seen.add(stage)
                rows = [row for row in r['rows'] if row.get('stage', stage) == stage]
                assert len(rows) == len(expected) + (3 if suite == 'controls' else 0)
                for row, old in zip(rows, expected):
                    assert row['name'] == old['name'] and row['source'] == old['source']
                    assert row['live'] == (old['mode'] == 'live' if suite == 'controls' else False)
                    request_row(row, producers[stage], SUCCESS_DIAGNOSTIC, None if policy_pin else old['oracle'])
                if suite == 'controls':
                    for i, (row, old) in enumerate(zip(rows[len(expected):], original_negatives)):
                        assert row['name'] == 'negative-' + str(i) and row['source'] == old['source']
                        request_row(row, producers[stage], strip_clocks(old['diagnostic']), negative=True)
            if policy_pin:
                for name in {row['name'] for row in r['rows'] if 'output' in row}:
                    outputs = [row['output'] for row in r['rows'] if row['name'] == name]
                    assert all(same(output, outputs[0]) for output in outputs)
                if suite == 'broad45':
                    assert len(r['programs']) == 45
                    for product, old in zip(r['programs'], original_broad):
                        assert product['passed'] and product['name'] == old['name']
                        expected_c = next(row['output'] for row in r['rows'] if row['name'] == old['name'])
                        assert product['c'] == expected_c
                        for job in ['build', 'run']:
                            assert product[job]['passed']; process(product[job]['process'], 0)
                            assert product[job]['command'] == product[job]['process']['command']
                            for raw in product[job]['raw']: b.bind(raw)
                            raw_process = next(x for x in product[job]['raw'] if Path(x['file']).name == 'process.json')
                            assert read(raw_process['file']) == product[job]['process']
                        b.bind(product['binary']); b.bind(product['stdout']); b.bind(product['stderr'])
                        cc = ctx['clang']['file']; command = product['build']['command']
                        assert command[command.index(cc):] == [cc, '-isystem', str(Path(cc).parents[1] / 'include/clang'), '-O2', expected_c['file'], '-o', product['binary']['file'], '-lm', '-pthread']
                        command = product['run']['command']; binary = product['binary']['file']
                        assert command[command.index(binary):] == [binary, '--threads', '1', '--gpu', 'off']
                        assert Path(product['stdout']['file']).read_bytes() == (old['expectedStdout'] + '\n').encode()
                        assert not Path(product['stderr']['file']).read_bytes()
        assert seen == {'b1', 'b2'}
    # Re-evaluate the unchanged golden fields, rather than only trusting totals.
    conf_pin, conf = report(a.conformance, 'phase92-native-conformance-results'); receipts['conformance'] = conf_pin
    plan = read(b.bind(conf['plan'])['file']); assert plan['phase98'] and plan['targetReady']
    for row in plan['inputs']: b.bind(row)
    old_plan = read(b.bind(ROOT / 'selfhost/build/phase92/conformance01/plan.json')['file'])
    assert plan['eligible'] == old_plan['eligible'] and plan['excluded'] == old_plan['excluded']
    expected_ids = {row['id'] for row in plan['eligible']}; assert len(expected_ids) == 69 and len(plan['excluded']) == 31
    old_results = {row['id']:row['result'] for row in read(b.bind(plan['reference'])['file'])['results'] if row['lane'] == 'native'}
    assert {row['role'] for row in conf['roles']} == {'b1', 'b2'}
    for role in conf['roles']:
        stage = role['role']; assert role['passed'] and plan['roles'][stage]['producer'] == producers[stage]
        assert plan['roles'][stage]['argv'] == native_args(ctx, producers[stage], plan['sourceMarker'], plan['outputMarker'])
        g = read(b.bind(role['guard'])['file']); process(g, 0)
        result = read(b.bind(role['report'])['file'])
        assert result['finished'] and result['selectedComplete'] and not result['changedInputs']
        assert not result['identity']['adapterChangedDuringRun'] and not result['identity']['changedArtifacts']
        assert result['identity']['artifacts']['plan']['sha256'] == conf['plan']['sha256']
        assert len(result['results']) == 69 and {row['id'] for row in result['results']} == expected_ids
        for row in result['results']:
            assert row['status'] == 'pass'
            command = row['result']['nativeHost']['job']['command']
            expected_argv = plan['roles'][stage]['argv']
            assert len(command) == len(expected_argv)
            assert all(actual == expected for actual, expected in zip(command, expected_argv)
                       if expected not in [plan['sourceMarker'], plan['outputMarker']])
            fixture = next(item['source'] for item in plan['eligible'] if item['id'] == row['id'])
            assert command[expected_argv.index(plan['sourceMarker'])] == fixture['file']
            assert all(row['result'].get(k) == old_results[row['id']].get(k) for k in ['status', 'phase', 'checked', 'typeAccepted', 'exitCode', 'stdout', 'stderr', 'output'])
    dg = read(b.bind(conf['diagnostics']['guard'])['file']); process(dg, 0)
    diagnostics = read(b.bind(conf['diagnostics']['report'])['file'])
    assert conf['diagnostics']['passed']
    assert diagnostics['complete'] and diagnostics['passed'] and diagnostics['inputsUnchanged'] and len(diagnostics['rows']) == 6
    assert diagnostics['plan'] == conf['plan']
    negative_map = {row['id']:row for row in original_negatives}
    assert {(row['role'], row['id']) for row in diagnostics['rows']} == {(role, name) for role in ['b1', 'b2'] for name in negative_map}
    for row in diagnostics['rows']:
        old = negative_map[row['id']]; job = row['job']
        expected_argv = plan['roles'][row['role']]['argv']
        assert len(job['command']) == len(expected_argv)
        assert all(actual == expected for actual, expected in zip(job['command'], expected_argv)
                   if expected not in [plan['sourceMarker'], plan['outputMarker']])
        assert job['command'][expected_argv.index(plan['sourceMarker'])] == old['source']['file']
        assert row['passed'] and row['source'] == old['source'] and row['outputAbsent'] and row['output'] is None
        assert row['diagnostic'] == old['diagnostic'] == strip_clocks(job['stderr']) and not job['stdout']
        assert job['status'] == 1 and not any(job[k] for k in ['signal', 'error', 'timedOut', 'oversized'])
        for capture in job['captures']:
            b.bind(capture)
            assert Path(capture['file']).read_text() == job['stdout' if capture['file'].endswith('.stdout') else 'stderr']
    if policy_pin:
        assert a.backend_controls, 'Changed backends also require source-bound permission/refusal/ownership controls'
        rp, controls = report(a.backend_controls, 'phase98-backend-specific-qualification')
        assert controls['source'] == source and controls['backendPolicy'] == policy_pin
        control_plan = read(b.bind(controls['plan'])['file'])
        assert controls['requiredCaseIds'] == [row['id'] for row in control_plan['cases']]
        assert controls['requiredCaseIds'] and {row['id'] for row in controls['rows']} == set(controls['requiredCaseIds'])
        assert all(row['passed'] and row['evidence'] for row in controls['rows'])
        for row in controls['rows']:
            for evidence in row['evidence']: b.bind(evidence)
        receipts['backendSpecific'] = rp
    else: assert not a.backend_controls
    old_assets = ctx['roles']['b2']['admission']
    assets = {k:old_assets[k] for k in ['base', 'runtime', 'template', 'parts', 'effects', 'effectsDir', 'cacheBasePath', 'argvSentinel']}
    assets['cache'] = {k:old_assets['cache'][k] for k in ['carrier', 'stamp']}; b.tree(assets)
    profile.unchanged(); b.unchanged()
    admission = dict(kind='phase98-native-candidate-qualification', version=1, complete=True, qualified=True,
                     defaultSelection=False, source=source,
                     stages={stage:{**producer, 'producer':builds[stage]['producer']} for stage, producer in producers.items()}, assets=assets,
                     profile=dict(recipe=recipe_pin, inputs=list(profile.rows.values()), forwardAndInverseExact=True),
                     profileAssets=list(profile.rows.values()), receipts=receipts, backendPolicy=policy_pin,
                     method=pin(__file__), inputs=list(b.rows.values()), inputsUnchanged=True, dataOnly=True,
                     wholeCompilerProved=False, scope='Both exact same-source native stages: self-C consistency, four live/cache controls and three exact rejections,45 original products,69 golden executions per stage with31 exclusions. One CPU worker; no frontend/JS-target/GPU/parallel or universal compiler proof. Default selection and public CLI controls are separate.')
    a.out.parent.mkdir(parents=True, exist_ok=True)
    with a.out.open('x') as f: json.dump(admission, f, indent=2); f.write('\n')
    print(json.dumps(dict(complete=True, qualified=True, defaultSelection=False, admission=str(a.out))))


if __name__ == '__main__': main()
