#!/usr/bin/env python3
"""Phase102 exact-C binary reuse successor; root owns all target execution."""
import argparse
import importlib.util
import json
import math
import re
from pathlib import Path
import statistics
import sys
from types import SimpleNamespace

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parents[2] / 'phase99/runtime'
ROOT = HERE.parents[4]
QPATH = HERE.parent / 'qualification/reuse.py'
spec = importlib.util.spec_from_file_location('phase99_runtime_baseline', QPATH)
Q = importlib.util.module_from_spec(spec); spec.loader.exec_module(Q)
S = Q.support
RUNTIME_PARENT = HERE / 'run.py'
assert S.pin(RUNTIME_PARENT)['sha256'] == '4d2e5edf601a80e7081935ad45bd43bfc06cb983df1d15e03636842c0103c90c'
PARENT = ROOT / 'selfhost/tools/performance/phase93/run.py'
assert S.pin(PARENT)['sha256'] == '2c2785d1543a044d1a603c292ff28cd4cf76cf8afb9892552e66036a2d99b64b'
# The two historical modules both use the name support. Import Phase93 against
# its own unchanged Phase92 support, then restore the qualification module.
previous_support, previous_path = sys.modules.pop('support'), list(sys.path)
try:
    spec = importlib.util.spec_from_file_location('phase99_original_phase93_run', PARENT)
    R = importlib.util.module_from_spec(spec); spec.loader.exec_module(R)
finally:
    sys.modules['support'] = previous_support; sys.path[:] = previous_path


def load(b, path):
    rp = b.bind(path); value = S.read(rp['file'])
    assert value['complete'] and not value.get('error') and value.get('inputsUnchanged', True)
    b.tree(value.get('inputs', [])); return rp, value


def same(a, b): return all(a[key] == b[key] for key in ['sha256', 'bytes'])


def methods(b):
    for item in R.methods(): b.bind(item)
    b.bind(__file__); b.bind(RUNTIME_PARENT); b.bind(QPATH); b.bind(HERE.parent / 'qualification/baseline.json')


def bind_job(b, job):
    assert job['guardExit'] == 0 and S.bounded_exit(job['process'], 0)
    folder = Path(job['guard']); assert S.read(b.bind(folder / 'process.json')['file']) == job['process']
    for stream in ['stdout.log', 'stderr.log']: b.bind(folder / stream)
    argv = job['command'][job['command'].index('--') + 1:]
    assert job['process']['command'][-len(argv):] == argv


def unique_rows(rows):
    result = {row['id']: row for row in rows}
    assert len(result) == len(rows)
    return result


def request_evidence(b, ctx, producer, case, row):
    """Reopen the recorded native request, without executing it."""
    assert row['source'] == case['source'] and row['live'] is False and row['passed'] is True
    assert S.bounded_exit(row['process'], 0)
    output = b.bind(row['output']); path = Path(output['file'])
    assert path.name == 'output.1.c'
    directory = path.parent; prefix = directory / 'output'
    argv = S.native_args(ctx, producer, case['source']['file'], prefix, False)
    command = ['bash', '-c', 'ulimit -f 65536; ulimit -c 0; exec "$@"', 'phase98', 'taskset', '-c', '3', *argv]
    assert row['command'] == row['process']['command'] == command
    expected_raw = [b.bind(directory / 'guard' / name) for name in ['process.json', 'stdout.log', 'stderr.log']]
    assert row['raw'] == expected_raw and S.read(expected_raw[0]['file']) == row['process']
    assert Path(expected_raw[1]['file']).read_bytes() == b''
    stderr = Path(expected_raw[2]['file']).read_text()
    diagnostic = S.strip_clocks(stderr)
    assert row['diagnosticExact'] is True and diagnostic == row['diagnostic'] == case['expectedDiagnostic']
    assert row['diagnosticFile'] == b.bind(directory / 'diagnostic.txt')
    assert Path(row['diagnosticFile']['file']).read_text() == diagnostic
    clocks = [list(value) for value in re.findall(r'^request=(\d+) request_ms=(\d+) consumed_chars=(\d+)$', stderr, re.M)]
    assert row['clocks'] == clocks and len(clocks) == 1 and clocks[0][0] == '1'
    return output


def reusable_products(b, ctx, path, plan_pin, plan):
    """Authenticate only the frozen complete original-method acquisition."""
    prior_pin, prior = load(b, path)
    allowed = {'afb79e2a7af268020275a2026485b45ffea79a877769a071c2a8ed77d8646c67': 1196870,
               '8a3baeec41436c7a1c4d3674dcfc577e0b721df7ace023782152f7c3d8571964': 1400785}
    assert prior_pin['sha256'] in allowed and prior_pin['bytes'] == allowed[prior_pin['sha256']]
    assert prior['kind'] == 'phase99-native-runtime-acquisition'
    assert prior['inputsUnchanged'] is True and prior['executionPerformed'] is True
    if prior_pin['sha256'] == '8a3baeec41436c7a1c4d3674dcfc577e0b721df7ace023782152f7c3d8571964':
        reviewed = b.bind(ROOT / 'selfhost/tools/performance/phase102/runtime-reuse.py')
        assert reviewed['sha256'] == 'fc371913847f3ce0a71a770a85465e33789ba06ed254d1ddc861825c59d0b68c'
        assert prior['method'] == reviewed and prior['parentMethod'] == b.bind(RUNTIME_PARENT)
        assert prior['source']['sha256'] == 'b3927732f2250c19a7a8988dab7cbf30726359c18b5305f73c28cadddb902d1f'
        assert prior['reusedCaseIds'] == [] and prior['freshBuildCaseIds'] == prior['changedCases']
    else:
        assert prior['method'] == b.bind(RUNTIME_PARENT)
    inputs = {item['file']: item for item in prior['inputs']}
    assert len(inputs) == len(prior['inputs']) and inputs[ctx['clang']['file']] == b.bind(ctx['clang'])
    b.bind(prior['source'])
    producers = {}
    for stage in ['b1', 'b2']:
        recorded = prior['producers'][stage]
        producers[stage] = S.authenticate(recorded['binary'], stage, prior['source'], recorded['build'], b, ctx)
        assert recorded == producers[stage]
    policy = S.backend_policy(prior['backendPolicy']['file'], prior['source'], b)
    assert policy == prior['backendPolicy']
    continuity_pin, continuity = load(b, prior['continuity'])
    changed_pin, changed = load(b, prior['changedPlan'])
    assert continuity['passed'] is True and continuity['inputsUnchanged'] is True
    assert continuity['producer'] == changed['producer'] == producers['b2']
    assert continuity['plan'] == plan_pin and changed['continuityPlan'] == plan_pin
    assert continuity['backendPolicy'] == policy and continuity['changedPlan'] == changed_pin
    assert prior['continuity'] == continuity_pin and changed['kind'] == 'phase98-phase93-changed-batch-plan'
    names = [case['id'] for case in plan['cases']]
    assert len(names) == len(set(names)) == 45
    assert prior['changedCases'] == continuity['changedCases'] == names and continuity['unchangedCases'] == []
    assert [row['id'] for row in prior['cases']] == [row['id'] for row in changed['cases']] == names
    rows = unique_rows(prior['cases']); b1_rows = unique_rows(prior['emissions']); b2_rows = unique_rows(continuity['rows'])
    assert set(rows) == set(b1_rows) == set(b2_rows) == set(names)
    assert prior['zeroWorkControl'] == plan['zeroWorkControl']
    for case, selected in zip(plan['cases'], changed['cases']):
        name = case['id']; row = rows[name]; product = row['products']['own']
        assert row['passed'] is True and row['sameNativeC'] is True
        assert all(row[key] == value for key, value in case['originalCase'].items())
        assert row['source'] == case['source'] and row['products']['upstream'] == case['historicalProducts']['upstream']
        assert row['phase98Product'] == case['historicalProducts']['own']
        b.tree(case['originalCase']); b.bind(case['source'])
        assert selected == dict(case, candidateC=row['candidateC'])
        assert product['c'] == row['candidateC'] == b2_rows[name]['output']
        c1 = request_evidence(b, ctx, producers['b1'], case, b1_rows[name])
        c2 = request_evidence(b, ctx, producers['b2'], case, b2_rows[name])
        assert b1_rows[name]['exactC'] is True and b1_rows[name]['oracle'] == c2 and same(c1, c2)
        assert row['cAgreement'] == 'Fresh candidate B1/B2 full-C equality'
        b.bind(product['c']); b.bind(product['binary']); bind_job(b, product['build'])
        job = product['build']; cc = ctx['clang']['file']
        command = [cc, '-isystem', str(Path(cc).parents[1] / 'include/clang'), '-std=c11', '-O3', product['c']['file'], '-o', product['binary']['file'], '-lpthread', '-lm']
        assert job['command'] == ['/usr/bin/python3', '-B', str(ROOT / 'selfhost/tools/performance/phase86/guard.py'), '--out', job['guard'], '--seconds', '60', '--cpu', '3', '--rss-mib', '2048', '--available-mib', '4096', '--', *command]
        assert job['process']['command'] == ['bash', '-c', 'ulimit -f 65536; ulimit -c 0; exec "$@"', 'phase86', 'taskset', '-c', '3', *command]
        assert math.isfinite(job['process']['wallSeconds']) and job['process']['wallSeconds'] >= 0
    assert math.isclose(sum(rows[name]['products']['own']['build']['process']['wallSeconds'] for name in names), prior['compilationWallSeconds'], rel_tol=0, abs_tol=1e-9)
    return dict(acquisition=prior_pin, source=prior['source'], producers=producers, backendPolicy=policy, cases=rows)


def acquire(a, out):
    b = S.Bindings(); ctx = S.baseline(b); methods(b)
    changed_pin, changed = load(b, a.changed_plan)
    assert changed['kind'] == 'phase98-phase93-changed-batch-plan'
    continuity_pin, continuity = load(b, a.changed_plan.parent / 'report.json')
    assert continuity['passed'] and continuity['changedPlan'] == changed_pin and continuity['producer'] == changed['producer']
    plan_pin, plan = load(b, changed['continuityPlan']); assert continuity['plan'] == plan_pin and len(plan['cases']) == 45
    changed_ids = [row['id'] for row in changed['cases']]
    assert changed_ids == continuity['changedCases'] and set(changed_ids).isdisjoint(continuity['unchangedCases'])
    assert set(changed_ids) | set(continuity['unchangedCases']) == {row['id'] for row in plan['cases']}
    producers = {}
    for stage, path in [('b1', a.b1_build), ('b2', a.b2_build)]:
        build = S.read(path); producers[stage] = S.authenticate(build['binary'], stage, build['source'], path, b, ctx)
    assert producers['b1']['source'] == producers['b2']['source'] and producers['b2'] == changed['producer']
    policy = S.backend_policy(continuity['backendPolicy']['file'], producers['b2']['source'], b)
    old_pin, old = load(b, ROOT / 'selfhost/build/phase98/origin-batch-continuity01/report.json')
    assert old['passed'] and old['allHistoricalCExact'] and old['plan'] == plan_pin and old['counts']['exactC'] == 45
    baseline = S.baseline_producer(ctx, 'b2')
    assert all(old['producer'][key] == baseline[key] for key in ['binary', 'source', 'build'])
    current_rows = {row['id']:row for row in continuity['rows']}; old_rows = {row['id']:row for row in old['rows']}
    reuse = reusable_products(b, ctx, a.reuse, plan_pin, plan) if a.reuse else None
    report = dict(kind='phase99-native-runtime-acquisition', complete=False, inputsUnchanged=False,
        executionPerformed=False,
        source=producers['b2']['source'], producers=producers, changedPlan=changed_pin, continuity=continuity_pin,
        priorPhase98Continuity=old_pin, backendPolicy=policy, changedCases=changed_ids, cases=[], inputs=[],
        compilationWallSeconds=0.0, emissions=[], zeroWorkControl=plan['zeroWorkControl'], zeroObservations=[], method=S.pin(__file__),
        parentMethod=b.bind(RUNTIME_PARENT), reuseAcquisition=reuse['acquisition'] if reuse else None,
        reusedCaseIds=[], freshBuildCaseIds=[], avoidedHistoricalClangWallSeconds=0.0,
        reuseScope='Existing pinned binaries only after fresh B1/B2 full-C equality. Historical Clang executable and argv authenticated; no hermetic header/library rebuild claim. Avoided historical Clang seconds are neither current saved time nor clean-build speed.')
    def save():
        report['inputs'] = list(b.rows.values())
        report['reusedCaseCount'] = len(report['reusedCaseIds']); report['freshBuildCaseCount'] = len(report['freshBuildCaseIds'])
        R.save(out / 'report.json', report)
    save()
    try:
        for case in plan['cases']:
            name = case['id']; original = case['originalCase']; b.bind(case['source'])
            assert current_rows[name]['passed'] and old_rows[name]['passed'] and old_rows[name]['exactHistoricalC']
            candidate_c = b.bind(current_rows[name]['output']); assert same(b.bind(old_rows[name]['output']), case['historicalC'])
            for product in case['historicalProducts'].values():
                b.bind(product['c']); b.bind(product['binary']); bind_job(b, product['build'])
            row = dict(original, passed=False, sameNativeC=True, products=dict(case['historicalProducts']),
                       phase98Product=case['historicalProducts']['own'], candidateC=candidate_c)
            report['cases'].append(row); save()
            if name in changed_ids:
                selected = next(value for value in changed['cases'] if value['id'] == name)
                assert selected == dict(case, candidateC=candidate_c)
                directory = out / name; directory.mkdir()
                report['executionPerformed'] = True; save()
                with S.S.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
                    emission = S.run_request(guard, ctx, producers['b1'], case['source'], directory / 'b1', seconds=60,
                                             oracle=candidate_c, expected_diagnostic=case['expectedDiagnostic'])
                emission['id'] = name; report['emissions'].append(emission); save()
                assert emission['passed'] and emission['exactC']; b.bind(emission['output']); b.bind(emission['diagnosticFile'])
                for item in emission['raw']: b.bind(item)
                previous = reuse['cases'][name]['products']['own'] if reuse else None
                if previous is not None and same(candidate_c, previous['c']):
                    current_b1 = request_evidence(b, ctx, producers['b1'], case, emission)
                    current_b2 = request_evidence(b, ctx, producers['b2'], case, current_rows[name])
                    assert current_b2 == candidate_c and same(current_b1, current_b2) and same(current_b2, previous['c'])
                    row['products']['own'] = previous
                    row['binaryReuse'] = dict(acquisition=reuse['acquisition'], historicalSource=reuse['source'],
                        historicalProducers=reuse['producers'], historicalBackendPolicy=reuse['backendPolicy'],
                        currentSource=producers['b2']['source'], currentB1C=current_b1, currentB2C=current_b2,
                        historicalProduct=previous, exactWholeC=True,
                        scope='Product object and build paths remain historical; current emission evidence is separate. Fresh runtime sampling is still required.')
                    report['reusedCaseIds'].append(name)
                    report['avoidedHistoricalClangWallSeconds'] += previous['build']['process']['wallSeconds']
                else:
                    cc = ctx['clang']['file']; binary = directory / 'candidate.program'
                    command = [cc, '-isystem', str(Path(cc).parents[1] / 'include/clang'), '-std=c11', '-O3', candidate_c['file'], '-o', str(binary), '-lpthread', '-lm']
                    job = R.guard(directory / 'clang', command, 60); bind_job(b, job)
                    row['products']['own'] = dict(c=candidate_c, binary=b.bind(binary), build=job)
                    report['compilationWallSeconds'] += job['process']['wallSeconds']
                    report['freshBuildCaseIds'].append(name)
                row['cAgreement'] = 'Fresh candidate B1/B2 full-C equality'
            else:
                assert current_rows[name]['exactHistoricalC'] and same(candidate_c, case['historicalC'])
                row['cAgreement'] = 'Fresh candidate B2 exact historical C; retained original B1/B2 product evidence, no fresh B1 batch request'
            row['passed'] = True; save()
            if name == 'scalar-region-0' and name in changed_ids:
                for role in ['own', 'upstream']:
                    observation = R.sample(out / ('zero-' + role), row, role, 8, 1)
                    bind_job(b, observation['job']); b.bind(observation['child'])
                    report['zeroObservations'].append(observation); save()
        calibration = {case['id']:case['calibration'] for case in plan['cases'] if case['calibration'] is not None}
        assert len(calibration) == 44 and 'scalar-region-0' not in calibration
        R.save(out / 'calibration.json', dict(complete=True, plan=calibration, originals=plan['calibrationReports'], targetsRun=False))
        b.bind(out / 'calibration.json'); b.unchanged(); report.update(complete=True, inputsUnchanged=True,
            scope='Changed C receives fresh B1/B2 agreement; exact-C historical binary reuse is separately counted, otherwise the original Clang22 C11-O3 build runs. All45 product identities retained. Compilation wall time counts fresh builds only; historical avoided Clang time is separate from program elapsedMs. Zero-work ratio stays undefined.')
        save()
        for comparator in ['phase98', 'upstream']:
            cases = []
            for row in report['cases']:
                products = dict(row['products'])
                if comparator == 'phase98': products['upstream'] = row['phase98Product']
                cases.append(dict(row, products=products))
            R.save(out / (comparator + '-products.json'), dict(complete=True, inputsUnchanged=True, cases=cases,
                kind='phase99-runtime-comparison-products', comparator=comparator, acquisition=b.bind(out / 'report.json'),
                source=report['source'], changedCases=changed_ids, method=S.pin(__file__),
                roleMeaning=dict(own='Selected candidate product', upstream='Retained ' + comparator + ' native product; legacy Phase93 role label')))
    except BaseException as error: report.update(complete=False, inputsUnchanged=False, error=repr(error)); save(); raise


def timing(a, out):
    b = S.Bindings(); methods(b); product_pin, products = load(b, a.products)
    acquired_pin, acquired = load(b, products['acquisition'])
    assert products['kind'] == 'phase99-runtime-comparison-products'
    assert products['source'] == acquired['source'] and products['changedCases'] == acquired['changedCases']
    assert products['comparator'] in ['phase98', 'upstream'] and len(products['cases']) == len(acquired['cases']) == 45
    for row, original in zip(products['cases'], acquired['cases']):
        expected = dict(original['products'])
        if products['comparator'] == 'phase98': expected['upstream'] = original['phase98Product']
        assert row == dict(original, products=expected)
    names = [row['id'] for row in products['cases'] if row['id'] != 'scalar-region-0' and (a.all or row['id'] in products['changedCases'])]
    assert names, 'No changed measurable cases; do not launch an empty campaign'
    if a.all: assert len(names) == 44
    plans = a.plans or [Path(acquired_pin['file']).parent / 'calibration.json']
    for path in plans:
        b.bind(path)
        if a.plans:
            calibration_pin, calibration = load(b, path)
            context_pin, context = load(b, path.parent / 'context.json')
            assert calibration['kind'] == 'phase93-native-runtime-calibrate' and context['timing'] == calibration_pin
            assert context['source'] == products['source'] and context['productManifest'] == product_pin
            assert context['parentMethod'] == b.bind(PARENT) and context['method'] == b.bind(__file__)
    envelope = dict(complete=False, method=S.pin(__file__), parentMethod=b.bind(PARENT), source=products['source'],
        productManifest=product_pin, acquisition=acquired_pin, comparator=products['comparator'], cases=names,
        all44=a.all, rounds=3, targetMs=250, inputs=[], compilationWallSeconds=acquired['compilationWallSeconds'],
        scope='Fresh selected runtime samples via unchanged Phase93 functions. Legacy own/upstream labels mean candidate/named comparator. Build time excluded; zero-work ratio undefined.')
    def save(): envelope['inputs'] = list(b.rows.values()); R.save(out / 'context.json', envelope)
    save()
    try:
        args = SimpleNamespace(action=a.action, acquired=[a.products], cases=','.join(names), plans=plans, rounds=3, target_ms=250)
        R.timing(args, out)
        receipt = S.read(out / 'report.json'); assert receipt['complete']
        for row in receipt['records']:
            bind_job(b, row['job']); child = S.read(b.bind(row['child'])['file'])
            case = next(case for case in products['cases'] if case['id'] == row['case'])
            expected = str(case['expected']) + '\n' + str(row['warmups']) + '\n' + str(row['repetitions']) + '\n' + str(row['elapsedMs']) + '\n'
            assert child['stdout'] == expected and child['stderr'] == '' and child['returncode'] == 0
        b.unchanged(); envelope.update(complete=True, inputsUnchanged=True, timing=b.bind(out / 'report.json')); save()
        if a.action == 'measure':
            rows = []
            for name in names:
                records = [row for row in receipt['records'] if row['case'] == name]
                assert len(records) == 6 and all(row['qualified'] and row['elapsedMs'] >= 100 for row in records)
                roles = {role:[1000 * row['elapsedMs'] / row['repetitions'] for row in records if row['role'] == role] for role in ['own', 'upstream']}
                assert all(len(values) == 3 for values in roles.values())
                case = next(case for case in products['cases'] if case['id'] == name)
                rows.append(dict(id=name, original=case['original'], mediansUs={role:statistics.median(values) for role, values in roles.items()},
                    rangesUs={role:[min(values), max(values)] for role, values in roles.items()}, ratio=statistics.median(roles['own']) / statistics.median(roles['upstream'])))
            gm = lambda values: math.exp(statistics.mean(math.log(value) for value in values))
            groups = {}
            for row in rows: groups.setdefault(row['original']['sha256'], []).append(row['ratio'])
            R.save(out / 'summary.json', dict(complete=True, source=products['source'], context=S.pin(out / 'context.json'),
                comparator=products['comparator'], freshlyMeasuredCases=len(rows), all44=a.all, rows=rows,
                equalPointGeomean=gm(row['ratio'] for row in rows), equalSourceGeomean=gm(gm(values) for values in groups.values()),
                zeroWorkRatio=None, compilationWallSeconds=acquired['compilationWallSeconds'], scope=envelope['scope']))
    except BaseException as error: envelope['error'] = repr(error); save(); raise


def main():
    p = argparse.ArgumentParser(description=__doc__); p.add_argument('action', choices=['acquire', 'measure', 'calibrate'])
    p.add_argument('--out', type=Path, required=True)
    for name in ['changed-plan', 'b1-build', 'b2-build', 'products']: p.add_argument('--' + name, type=Path)
    p.add_argument('--reuse', type=Path, help='Acquire only: frozen original-method acquisition eligible for exact-C binary reuse')
    p.add_argument('--plans', type=Path, nargs='+'); p.add_argument('--all', action='store_true', help='Freshly time all44 nonzero products; default changed subset only')
    a = p.parse_args(); out = a.out.resolve(); assert out.is_relative_to(ROOT / 'selfhost/build/phase99') and not out.exists()
    assert all([a.changed_plan, a.b1_build, a.b2_build]) if a.action == 'acquire' else a.products
    assert a.reuse is None or a.action == 'acquire', '--reuse applies only to acquire'
    out.mkdir(parents=True)
    if a.action == 'acquire': acquire(a, out)
    else: timing(a, out)


if __name__ == '__main__': main()
