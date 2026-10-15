#!/usr/bin/env python3
"""Freeze original Phase93 batches; root may emit final B2 C to test exact continuity."""
import argparse
import json
from pathlib import Path
from support import Bindings, ROOT, S, SUCCESS_DIAGNOSTIC, authenticate, backend_policy, baseline, freeze_methods, pin, read, run_request, strip_clocks


def historical_plan(out, bindings):
    folder = ROOT / 'selfhost/build/phase93'
    manifest_pin = bindings.bind(folder / 'fixtures01/manifest.json'); manifest = read(manifest_pin['file'])
    assert manifest['complete'] and manifest['inputsUnchanged'] and len(manifest['cases']) == 45
    for item in manifest['inputs']: bindings.bind(item)
    acquired = []; cases = {}
    for name in ['pilot02/report.json', 'broad01/report.json']:
        receipt_pin = bindings.bind(folder / name); receipt = read(receipt_pin['file']); acquired.append(receipt_pin)
        assert receipt['complete'] and receipt['inputsUnchanged'] and receipt['manifest'] == manifest_pin
        for case in receipt['cases']:
            assert case['passed'] and case['sameNativeC'] and case['id'] not in cases
            for product in case['products'].values():
                bindings.bind(product['c']); bindings.bind(product['binary'])
            guard = Path(case['emissions']['b2']['guard'])
            process = read(bindings.bind(guard / 'process.json')['file'])
            assert process == case['emissions']['b2']['process'] and process['complete'] and process['returncode'] == 0
            assert not process.get('stoppedFor') and not process.get('interrupted')
            assert not Path(bindings.bind(guard / 'stdout.log')['file']).read_bytes()
            diagnostic = strip_clocks(Path(bindings.bind(guard / 'stderr.log')['file']).read_text())
            assert diagnostic == SUCCESS_DIAGNOSTIC
            cases[case['id']] = dict(case, historicalAcquisition=receipt_pin, expectedDiagnostic=diagnostic)
    assert len(cases) == 45
    plans = {}; calibration_reports = []
    for name in ['calibrate-pilot01/report.json', 'calibration-continuation01/retained-plan.json', 'calibrate-broad02/report.json']:
        rp = bindings.bind(folder / name); receipt = read(rp['file']); calibration_reports.append(rp)
        assert receipt['complete'] and not (plans.keys() & receipt['plan'].keys())
        plans.update(receipt['plan'])
    assert set(plans) == set(cases) - {'scalar-region-0'} and len(plans) == 44
    zero = bindings.bind(folder / 'calibration-continuation01/unmeasured.json')
    assert read(zero['file'])['cases'][0]['id'] == 'scalar-region-0'
    ordered = []
    for original in manifest['cases']:
        case = cases[original['id']]
        assert all(case[k] == value for k, value in original.items())
        bindings.bind(original['source'])
        assert '@unsafe' not in Path(original['source']['file']).read_text()
        ordered.append(dict(id=original['id'], originalCase=original, source=original['source'],
                            expectedDiagnostic=case['expectedDiagnostic'], expectedStdout=original['expectedStdout'],
                            historicalAcquisition=case['historicalAcquisition'], historicalProducts=case['products'],
                            historicalC=case['products']['own']['c'], calibration=plans.get(original['id'])))
    result = dict(kind='phase98-phase93-batch-continuity-plan', complete=True, targetsRun=False,
                  manifest=manifest_pin, acquired=acquired, calibrationReports=calibration_reports,
                  zeroWorkControl=zero, cases=ordered, method=pin(__file__), inputs=list(bindings.rows.values()),
                  scope='Exact original45 Phase93 batch sources, full expected values, runtime arguments, prior native C/products and44 original calibration plans. Preparation launches no target and changes no historical source, product or calibration.')
    bindings.unchanged(); result['inputsUnchanged'] = True; S.save(out / 'plan.json', result)
    return result


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('action', choices=['prepare', 'emit'])
    p.add_argument('--plan', type=Path)
    p.add_argument('--b2-build', type=Path)
    p.add_argument('--backend-policy', type=Path)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve(); assert not out.exists(); out.mkdir(parents=True)
    b = Bindings(); freeze_methods(out, b)
    if a.action == 'prepare':
        assert not any([a.plan, a.b2_build, a.backend_policy])
        historical_plan(out, b)
        print(json.dumps(dict(complete=True, targetsRun=False, cases=45, plan=str(out / 'plan.json')))); return
    assert all([a.plan, a.b2_build, a.backend_policy])
    plan_pin = b.bind(a.plan); plan = read(plan_pin['file'])
    assert plan['kind'] == 'phase98-phase93-batch-continuity-plan' and plan['complete'] and plan['inputsUnchanged']
    for item in plan['inputs']: b.bind(item)
    assert len(plan['cases']) == 45 and len({case['id'] for case in plan['cases']}) == 45
    ctx = baseline(b); build = read(a.b2_build)
    producer = authenticate(build['binary'], 'b2', build['source'], a.b2_build, b, ctx)
    policy = backend_policy(a.backend_policy, producer['source'], b)
    report = dict(kind='phase98-phase93-batch-continuity', complete=False, passed=False, inputsUnchanged=False,
                  executionPerformed=False, imageQualified=False, producer=producer, plan=plan_pin,
                  backendPolicy=policy, method=pin(__file__), inputs=[], rows=[], changedCases=[], unchangedCases=[],
                  scope='Fresh final native B2 emission of all45 original Phase93 batch sources. Exact full C equality permits reuse of the original matched native product evidence; it is not a new timing measurement. Changed C requires fresh candidate build/execution and changed-subset timing before a runtime claim.')
    def save():
        report['inputs'] = list(b.rows.values()); S.save(out / 'report.json', report)
    save()
    try:
        with S.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
            for index, case in enumerate(plan['cases']):
                report['executionPerformed'] = True; save()
                row = run_request(guard, ctx, producer, case['source'], out / (str(index).zfill(2) + '-' + case['id']),
                                  seconds=60, expected_diagnostic=case['expectedDiagnostic'])
                row['id'] = case['id']; row['historicalC'] = case['historicalC']; report['rows'].append(row); save()
                assert row['passed'] and not row['process'].get('interrupted'), case['id']
                actual = b.bind(row['output'])
                row['exactHistoricalC'] = all(actual[k] == case['historicalC'][k] for k in ['sha256', 'bytes'])
                report['unchangedCases' if row['exactHistoricalC'] else 'changedCases'].append(case['id']); save()
                print(json.dumps(dict(case=case['id'], exactHistoricalC=row['exactHistoricalC'])), flush=True)
        changed = [case for case in plan['cases'] if case['id'] in report['changedCases']]
        S.save(out / 'changed-plan.json', dict(kind='phase98-phase93-changed-batch-plan', complete=True, targetsRun=False,
            producer=producer, continuityPlan=plan_pin, cases=[dict(case, candidateC=next(row['output'] for row in report['rows'] if row['id'] == case['id'])) for case in changed],
            calibrationReports=plan['calibrationReports'], zeroWorkControl=plan['zeroWorkControl'],
            nextSteps=['For changed cases only, emit candidate B1 C and require full equality with final B2.',
                       'Build each common changed C with the original pinned Clang recipe: -std=c11 -O3 -lpthread -lm; reuse retained upstream products.',
                       'Use the unchanged Phase93 sample/calibration/measure functions and original per-case counts, warmups, full result oracle, CPU3 and one thread.',
                       'Run three alternating rounds; any interval below100ms retains the failure and needs unchanged calibration rules before a fresh measurement.',
                       'Keep scalar-region-0 as the separately checked zero-work control; never assign a defined ratio.'],
            scope='No rebuild or timing is requested for exact-C cases. This is a changed-subset continuation plan, not an acquired or measured product report.'))
        b.bind(out / 'changed-plan.json'); b.unchanged()
        report.update(complete=True, passed=True, inputsUnchanged=True, allHistoricalCExact=not changed,
                      counts=dict(emissions=45, exactC=45-len(changed), changedC=len(changed)),
                      changedPlan=pin(out / 'changed-plan.json'), runtimeMeasurementPerformed=False)
    except BaseException as error:
        report.update(complete=False, passed=False, error=repr(error)); raise
    finally: save()
    print(json.dumps({k:report[k] for k in ['complete', 'passed', 'allHistoricalCExact', 'counts']}))


if __name__ == '__main__': main()
