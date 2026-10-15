#!/usr/bin/env python3
"""Root-only paired native B2 screen; candidate B1 supplies exact new-backend C."""
import argparse
import json
import math
from pathlib import Path
import re
import statistics
import sys
import time
from support import (Bindings, ROOT, PERF, S, SUCCESS_DIAGNOSTIC, authenticate, backend_policy,
                     baseline, baseline_producer, freeze_methods, pin, read, run_request)


def same(a, b): return all(a[k] == b[k] for k in ['sha256', 'bytes'])


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--mode', choices=['screen', 'self'], default='screen')
    p.add_argument('--b1-build', type=Path, required=True)
    p.add_argument('--b2-build', type=Path, required=True)
    p.add_argument('--backend-policy', type=Path)
    p.add_argument('--baseline-self-reference', type=Path)
    p.add_argument('--candidate-self-reference', type=Path)
    p.add_argument('--rounds', type=int)
    p.add_argument('--check-only', action='store_true')
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase98') and not out.exists()
    rounds = a.rounds if a.rounds is not None else (4 if a.mode == 'screen' else 1)
    assert rounds == 4 if a.mode == 'screen' else rounds in [1, 2]
    out.mkdir(parents=True); b = Bindings(); ctx = baseline(b); freeze_methods(out, b)
    b.bind(PERF / 'phase95/compiler-compare.py'); b.bind(PERF / 'phase98/compiler-compare.py')
    images = {}
    for stage, path in [('b1', a.b1_build), ('b2', a.b2_build)]:
        receipt = read(path)
        images[stage] = authenticate(receipt['binary'], stage, receipt['source'], path, b, ctx)
    source = images['b1']['source']; assert source == images['b2']['source']
    policy = backend_policy(a.backend_policy, source, b) if a.backend_policy else None
    producers = dict(baseline=baseline_producer(ctx, 'b2'), candidate=images['b2'])
    cases = []; references = {}
    if a.mode == 'screen':
        assert not a.baseline_self_reference and not a.candidate_self_reference
        old_pin = b.bind(ROOT / 'selfhost/build/phase90/final-screen01/report.json'); old = read(old_pin['file'])
        assert old['complete'] and old['passed'] and old['inputsUnchanged']
        references['historicalSix'] = old_pin
        for name, row in old['oracles'].items():
            cases.append(dict(name=name, source=b.bind(row['input']), baselineOracle=b.bind(row['b2Oracle']),
                              expectedDiagnostic=SUCCESS_DIAGNOSTIC))
        assert len(cases) == len({r['name'] for r in cases}) == 6
    else:
        assert a.baseline_self_reference and a.candidate_self_reference
        refs = {}
        for role, path in [('baseline', a.baseline_self_reference), ('candidate', a.candidate_self_reference)]:
            references[role] = b.bind(path); r = read(path); refs[role] = r
            assert r['kind'] == 'phase98-native-qualification-request' and r['complete'] and r['passed'] and r['inputsUnchanged']
            assert not r.get('error') and r['source'] == source
            for item in r['inputs']: b.bind(item)
            b.bind(r['row']['output']); b.bind(r['row']['diagnosticFile'])
            assert Path(r['row']['diagnosticFile']['file']).read_text() == r['row']['diagnostic']
        assert refs['baseline']['producer'] == producers['baseline'] and refs['baseline']['purpose'] == 'reference'
        assert refs['candidate']['producer'] == images['b1']
        assert refs['candidate']['oracleReport'] == references['baseline']
        assert read(a.b2_build)['emission'] == references['candidate'], 'Self oracle must be actual B2 build input'
        assert refs['candidate']['row']['diagnostic'] == refs['baseline']['row']['diagnostic']
        if policy:
            assert refs['candidate']['purpose'] == 'changed-backend' and refs['candidate']['backendPolicy'] == policy
        else:
            assert refs['candidate']['purpose'] == 'compare' and refs['candidate']['row']['exactC']
        cases = [dict(name='candidate-self', source=source, baselineOracle=refs['baseline']['row']['output'],
                      candidateOracle=refs['candidate']['row']['output'], expectedDiagnostic=refs['baseline']['row']['diagnostic'])]
    report = dict(kind='phase98-native-b2-comparison', complete=False, passed=False, inputsUnchanged=False,
                  started=time.time(), mode=a.mode, rounds=rounds, checkOnly=a.check_only,
                  executionPerformed=False, producers=producers, oracleProducer=images['b1'], backendPolicy=policy,
                  source=source, references=references, cases=cases, oracleRows=[], rows=[], method=pin(__file__),
                  inputs=list(b.rows.values()), imageQualified=False,
                  derivation='Phase95 four-round alternating pairs and median/paired ratios, using Phase98 exact source/build authentication and guarded request transport.',
                  scope='Actual old/native07 B2 versus new same-source candidate B2. Same prepared Base/runtime/providers/cache, one thread and CPU3. Each role must reproduce its own entire C oracle and the same full diagnostic. New C is supplied by the independently built candidate B1; this is backend consistency, not independent semantic qualification. Request excludes preparation; process wall includes startup/preparation/write/teardown. Generated-program execution and speed gates are separate.')
    def save():
        report['inputs'] = list(b.rows.values()); S.save(out / 'report.json', report)
    save()
    try:
        if a.check_only:
            b.unchanged(); report.update(complete=True, passed=True, inputsUnchanged=True, targetJobs=0, targetReady=True)
            return
        with S.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
            if a.mode == 'screen':
                # Six preparation requests are separate from the timed pairs.
                for index, case in enumerate(cases):
                    report['executionPerformed'] = True; save()
                    row = run_request(guard, ctx, images['b1'], case['source'], out / ('oracle-' + str(index) + '-' + case['name']), seconds=60)
                    row['case'] = case['name']; report['oracleRows'].append(row); save()
                    assert row['passed'] and not row['process'].get('interrupted')
                    case['candidateOracle'] = b.bind(row['output'])
                    case['candidateOracleDiagnostic'] = b.bind(row['diagnosticFile'])
                    case['sameCAsHistorical'] = same(case['candidateOracle'], case['baselineOracle'])
                    assert case['sameCAsHistorical'] or policy, 'Changed C requires explicit source-bound backend intent'
                    save()
            for rnd in range(1, rounds + 1):
                for index, case in enumerate(cases):
                    order = ['baseline', 'candidate'] if (rnd - 1 + index) % 2 == 0 else ['candidate', 'baseline']
                    for role in order:
                        report['executionPerformed'] = True; save()
                        oracle = case[role + 'Oracle']
                        row = run_request(guard, ctx, producers[role], case['source'],
                                          out / (str(rnd) + '-' + case['name'] + '-' + role),
                                          seconds=60 if a.mode == 'screen' else 300,
                                          oracle=oracle, expected_diagnostic=case['expectedDiagnostic'])
                        row.update(round=rnd, case=case['name'], role=role); report['rows'].append(row); save()
                        assert row['passed'] and row['exactC'] and row['diagnosticExact'] and not row['process'].get('interrupted')
                        assert 0 < row['requestMs'] <= row['processWallMs'] + 2
                        text = next(Path(x['file']).read_text() for x in row['raw'] if Path(x['file']).name == 'stderr.log')
                        for key in ['base_prepare_ms', 'runtime_prepare_ms']:
                            matches = re.findall(r'^' + key + r'=(\d+)$', text, re.M); assert len(matches) == 1
                            row[key] = int(matches[0])
                        b.bind(row['output']); save()
                        print(json.dumps({k:row[k] for k in ['round', 'case', 'role', 'requestMs', 'processWallMs', 'exactC']}), flush=True)
        assert len(report['rows']) == 2 * rounds * len(cases)
        summary = dict(exactCCount=len(report['rows']), exactDiagnosticCount=len(report['rows']), cases={})
        for case in cases:
            rows = [row for row in report['rows'] if row['case'] == case['name']]; result = {}
            for metric in ['requestMs', 'processWallMs']:
                values = {role:[row[metric] for row in rows if row['role'] == role] for role in producers}
                medians = {role:statistics.median(v) for role, v in values.items()}
                ratios = [next(row[metric] for row in rows if row['round'] == n and row['role'] == 'candidate') /
                          next(row[metric] for row in rows if row['round'] == n and row['role'] == 'baseline') for n in range(1, rounds + 1)]
                result[metric] = dict(medians=medians, ranges={k:[min(v), max(v)] for k, v in values.items()},
                                      ratioOfMedians=medians['candidate'] / medians['baseline'], pairedRatios=ratios,
                                      medianPairedRatio=statistics.median(ratios))
            summary['cases'][case['name']] = result
        summary['equalCaseGeometricRatios'] = {metric:math.exp(statistics.mean(math.log(case[metric]['ratioOfMedians'])
             for case in summary['cases'].values())) for metric in ['requestMs', 'processWallMs']}
        b.unchanged(); report.update(complete=True, passed=True, inputsUnchanged=True, summary=summary,
                                     targetJobs=len(report['rows']) + len(report['oracleRows']))
    except BaseException as error:
        report.update(complete=False, passed=False, error=repr(error)); raise
    finally:
        report['finished'] = time.time(); save()
        print(json.dumps({k:report.get(k) for k in ['complete', 'passed', 'mode', 'targetJobs', 'error']}))


if __name__ == '__main__': main()
