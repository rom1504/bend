#!/usr/bin/env python3
"""Root-only Phase98-current versus candidate B1/B2, using frozen request transport."""
import argparse
import json
import math
from pathlib import Path
import statistics
import time
from support import (Bindings, ROOT, S, SUCCESS_DIAGNOSTIC, authenticate, backend_policy,
                     baseline, baseline_producer, freeze_methods, pin, read, run_request)


def same(a, b): return all(a[k] == b[k] for k in ['sha256', 'bytes'])


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--stage', choices=['b1', 'b2'], required=True)
    p.add_argument('--mode', choices=['screen', 'self'], default='screen')
    p.add_argument('--b1-build', type=Path, required=True)
    p.add_argument('--b2-build', type=Path)
    p.add_argument('--backend-policy', type=Path, required=True)
    p.add_argument('--baseline-self-reference', type=Path)
    p.add_argument('--candidate-self-reference', type=Path)
    p.add_argument('--check-only', action='store_true')
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase99') and not out.exists()
    assert bool(a.b2_build) == (a.stage == 'b2')
    out.mkdir(parents=True); b = Bindings(); ctx = baseline(b); freeze_methods(out, b)
    images = {}
    for stage, path in [('b1', a.b1_build), *([('b2', a.b2_build)] if a.b2_build else [])]:
        receipt = read(path)
        images[stage] = authenticate(receipt['binary'], stage, receipt['source'], path, b, ctx)
    source = images['b1']['source']
    assert all(image['source'] == source for image in images.values())
    policy = backend_policy(a.backend_policy, source, b)
    producers = dict(baseline=baseline_producer(ctx, a.stage), candidate=images[a.stage])
    assert producers['baseline']['binary'] != producers['candidate']['binary']
    cases = []; references = {}; rounds = 4 if a.mode == 'screen' else 2
    if a.mode == 'screen':
        assert not a.baseline_self_reference and not a.candidate_self_reference
        old_pin = b.bind(ROOT / 'selfhost/build/phase98/origin-b2-screen01/report.json'); old = read(old_pin['file'])
        assert old['complete'] and old['passed'] and old['inputsUnchanged']
        assert old['source'] == ctx['source']
        references['sixSourceSelection'] = old_pin
        cases = [dict(name=case['name'], source=b.bind(case['source']), expectedDiagnostic=SUCCESS_DIAGNOSTIC)
                 for case in old['cases']]
        assert len(cases) == len({c['name'] for c in cases}) == 6
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
        assert refs['candidate']['producer'] == images['b1'] and refs['candidate']['purpose'] == 'changed-backend'
        assert refs['candidate']['backendPolicy'] == policy and refs['candidate']['row']['diagnosticExact']
        # Candidate B1 self-C is independently diagnosed by the current B2.
        independent = read(b.bind(refs['candidate']['oracleReport'])['file'])
        assert independent['complete'] and independent['passed'] and independent['inputsUnchanged']
        assert independent['source'] == source and independent['purpose'] == 'reference'
        assert independent['producer'] == baseline_producer(ctx, 'b2')
        assert refs['candidate']['row']['diagnostic'] == refs['baseline']['row']['diagnostic'] == independent['row']['diagnostic']
        if a.stage == 'b2':
            assert read(a.b2_build)['emission'] == references['candidate'], 'Oracle must be actual candidate B2 build input'
        cases = [dict(name='candidate-self', source=source, baselineOracle=refs['baseline']['row']['output'],
                      candidateOracle=refs['candidate']['row']['output'], expectedDiagnostic=refs['baseline']['row']['diagnostic'])]
    report = dict(kind='phase99-native-stage-comparison', complete=False, passed=False, inputsUnchanged=False,
        started=time.time(), stage=a.stage, mode=a.mode, rounds=rounds, checkOnly=a.check_only,
        executionPerformed=False, producers=producers, oracleProducer=images['b1'], backendPolicy=policy,
        source=source, references=references, cases=cases, oracleRows=[], rows=[], method=pin(__file__),
        inputs=list(b.rows.values()), imageQualified=False,
        scope='Frozen qualified Phase98 versus explicit candidate at the same native stage. Same request assets and CPU3. '
              'Four balanced rounds across six original sources, or two balanced same-candidate-source self pairs. '
              'Each role reproduces its own entire C and the same complete diagnostic; candidate B1 supplies candidate C. '
              'Request excludes preparation; process wall includes startup/preparation/write/teardown. '
              'Backend consistency and compiler timing only; generated-program execution/runtime and promotion remain separate.')
    def save():
        report['inputs'] = list(b.rows.values()); S.save(out / 'report.json', report)
    save()
    try:
        if a.check_only:
            b.unchanged(); report.update(complete=True, passed=True, inputsUnchanged=True, targetJobs=0, targetReady=True)
            return
        with S.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
            if a.mode == 'screen':
                for index, case in enumerate(cases):
                    for role, producer in [('baseline', producers['baseline']), ('candidate', images['b1'])]:
                        report['executionPerformed'] = True; save()
                        row = run_request(guard, ctx, producer, case['source'], out / f'oracle-{index}-{role}', seconds=60)
                        row.update(case=case['name'], role=role); report['oracleRows'].append(row); save()
                        assert row['passed'] and row['diagnosticExact'] and not row['process'].get('interrupted')
                        case[role + 'Oracle'] = b.bind(row['output'])
                    case['sameCAsBaseline'] = same(case['candidateOracle'], case['baselineOracle']); save()
            for rnd in range(1, rounds + 1):
                for index, case in enumerate(cases):
                    order = ['baseline', 'candidate'] if (rnd - 1 + index) % 2 == 0 else ['candidate', 'baseline']
                    for role in order:
                        report['executionPerformed'] = True; save()
                        row = run_request(guard, ctx, producers[role], case['source'], out / f'{rnd}-{case["name"]}-{role}',
                            seconds=60 if a.mode == 'screen' else 300, oracle=case[role + 'Oracle'],
                            expected_diagnostic=case['expectedDiagnostic'])
                        row.update(round=rnd, case=case['name'], role=role); report['rows'].append(row); save()
                        assert row['passed'] and row['exactC'] and row['diagnosticExact'] and not row['process'].get('interrupted')
                        assert 0 < row['requestMs'] <= row['processWallMs'] + 2
                        b.bind(row['output']); save()
                        print(json.dumps({k:row[k] for k in ['round', 'case', 'role', 'requestMs', 'processWallMs', 'exactC']}), flush=True)
        assert len(report['rows']) == 2 * rounds * len(cases)
        summary = dict(exactCCount=len(report['rows']), exactDiagnosticCount=len(report['rows']), cases={})
        for case in cases:
            rows = [r for r in report['rows'] if r['case'] == case['name']]; result = {}
            for metric in ['requestMs', 'processWallMs']:
                values = {role:[r[metric] for r in rows if r['role'] == role] for role in producers}
                medians = {role:statistics.median(v) for role, v in values.items()}
                ratios = [next(r[metric] for r in rows if r['round'] == n and r['role'] == 'candidate') /
                          next(r[metric] for r in rows if r['round'] == n and r['role'] == 'baseline') for n in range(1, rounds + 1)]
                result[metric] = dict(medians=medians, ranges={k:[min(v), max(v)] for k,v in values.items()},
                    ratioOfMedians=medians['candidate'] / medians['baseline'], pairedRatios=ratios,
                    medianPairedRatio=statistics.median(ratios))
            summary['cases'][case['name']] = result
        summary['equalCaseGeometricRatios'] = {metric:math.exp(statistics.mean(math.log(c[metric]['ratioOfMedians'])
            for c in summary['cases'].values())) for metric in ['requestMs', 'processWallMs']}
        b.unchanged(); report.update(complete=True, passed=True, inputsUnchanged=True, summary=summary,
                                    targetJobs=len(report['rows']) + len(report['oracleRows']))
    except BaseException as error:
        report.update(complete=False, passed=False, error=repr(error)); raise
    finally:
        report['finished'] = time.time(); save()


if __name__ == '__main__':
    raise SystemExit('Use reuse.py compare so the frozen current baseline is installed before import.')
