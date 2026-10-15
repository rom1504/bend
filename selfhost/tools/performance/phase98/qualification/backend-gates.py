#!/usr/bin/env python3
"""Root-only changed-backend gates: exact stage agreement and original program output."""
import argparse
import json
from pathlib import Path
import shutil
import sys
import time
from support import Bindings, ROOT, S, SUCCESS_DIAGNOSTIC, authenticate, backend_policy, baseline, freeze_methods, pin, read, run_request
from historical_diagnostics import control_diagnostic


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--b1-build', type=Path, required=True)
    p.add_argument('--b2-build', type=Path, required=True)
    p.add_argument('--backend-policy', type=Path, required=True)
    p.add_argument('--suite', choices=['controls', 'broad45'], required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve(); assert not out.exists(); out.mkdir(parents=True)
    b = Bindings(); ctx = baseline(b); freeze_methods(out, b); producers = {}
    for stage, path in [('b1', a.b1_build), ('b2', a.b2_build)]:
        receipt = read(path)
        producers[stage] = authenticate(receipt['binary'], stage, receipt['source'], path, b, ctx)
    assert producers['b1']['source'] == producers['b2']['source']
    policy_pin = backend_policy(a.backend_policy, producers['b1']['source'], b); policy = read(policy_pin['file'])
    cases = []
    if a.suite == 'broad45':
        for case in policy['cases']:
            b.bind(case['source']); cases.append({**case, 'live':False})
        assert len(cases) == 45
    else:
        old = read(b.bind(policy['independentOrigins']['controls'])['file'])
        assert old['complete'] and old['passed'] and old['inputsUnchanged']
        for row in old['compilerRows']:
            assert row['passed'] and row['exactC']
            cases.append(dict(name=row['name'], source=b.bind(row['source']), live=row['mode'] == 'live',
                              historicalC=row['oracle'], expectedDiagnostic=control_diagnostic(row, b)))
        assert len(cases) == 8
        old = read(b.bind(policy['independentOrigins']['negatives'])['file'])
        assert old['complete'] and old['passed'] and old['inputsUnchanged']
        for i, row in enumerate([r for r in old['rows'] if r['role'] == 'b1']):
            assert row['passed'] and row['outputAbsent']
            cases.append(dict(name='negative-' + str(i), source=b.bind(row['source']), live=False, negative=row['diagnostic']))
        assert len(cases) == 11
    report = dict(kind='phase98-changed-backend-gates', complete=False, passed=False, inputsUnchanged=False,
                  suite=a.suite, backendPolicy=policy_pin, producers=producers, cases=cases, rows=[], programs=[],
                  method=pin(__file__), inputs=list(b.rows.values()), executionPerformed=False, imageQualified=False,
                  scope='Full emitted C must agree across candidate B1/B2 and live/cache. Historical C differences are recorded, never called exact. Broad45 executes each common unpatched product against frozen complete stdout/stderr; native69 and self fixed point are separate. Execution clocks here are correctness telemetry, not runtime benchmarks.')
    def save():
        report['inputs'] = list(b.rows.values()); S.save(out / 'report.json', report)
    def guarded(guard, argv, destination, seconds):
        assert shutil.disk_usage(ROOT).free > 210 * 1024**2
        command = ['bash', '-c', 'ulimit -f 65536; ulimit -c 0; exec "$@"', 'phase98', 'taskset', '-c', '3', *map(str, argv)]
        process = guard.run(command, destination, time.monotonic() + seconds)
        return dict(command=command, process=process, raw=[pin(destination / n) for n in ['process.json', 'stdout.log', 'stderr.log']],
                    passed=bool(process['complete'] and process['returncode'] == 0 and not process.get('stoppedFor') and not process.get('interrupted')))
    save(); emitted = {}
    try:
        with S.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
            for i, case in enumerate(cases):
                directory = out / (str(i).zfill(2) + '-' + case['name'].replace('/', '_'))
                directory.mkdir(); common = None
                for stage in ['b1', 'b2']:
                    report['executionPerformed'] = True; save()
                    row = run_request(guard, ctx, producers[stage], case['source'], directory / stage,
                                      seconds=60, live=case['live'], negative=case.get('negative'), oracle=common,
                                      expected_diagnostic=case.get('expectedDiagnostic', SUCCESS_DIAGNOSTIC))
                    row.update(name=case['name'], stage=stage); report['rows'].append(row); save()
                    assert row['passed'], (case['name'], stage)
                    if 'negative' in case: continue
                    actual = b.bind(row['output'])
                    row['sameCAsHistorical'] = all(actual[k] == case['historicalC'][k] for k in ['sha256', 'bytes'])
                    if common is None: common = actual
                    previous = emitted.setdefault(case['name'], common)
                    row['liveCachedExact'] = all(actual[k] == previous[k] for k in ['sha256', 'bytes'])
                    assert row['liveCachedExact'], 'Live/cache candidate output diverged'
                    save()
                if a.suite != 'broad45': continue
                product = dict(name=case['name'], c=common, passed=False, originalStdout=case['expectedStdout'],
                               originalStderr=case['expectedStderr'], runtimeArgs=case['runtimeArgs'])
                report['programs'].append(product); save()
                cc = ctx['clang']['file']; binary = directory / 'program'
                product['build'] = guarded(guard, [cc, '-isystem', str(Path(cc).parents[1] / 'include/clang'), '-O2', common['file'], '-o', binary, '-lm', '-pthread'], directory / 'clang', 60)
                save(); assert product['build']['passed'], case['name']
                product['binary'] = b.bind(binary)
                product['run'] = guarded(guard, [binary, *case['runtimeArgs']], directory / 'run', 20)
                save(); assert product['run']['passed'], case['name']
                stdout, stderr = directory / 'run/stdout.log', directory / 'run/stderr.log'
                product['stdout'] = b.bind(stdout); product['stderr'] = b.bind(stderr)
                product['exactStdout'] = stdout.read_bytes() == case['expectedStdout'].encode()
                product['exactStderr'] = stderr.read_bytes() == case['expectedStderr'].encode()
                product['passed'] = product['exactStdout'] and product['exactStderr']; save()
                assert product['passed'], case['name']
                print(json.dumps(dict(case=case['name'], stageCExact=True, fullOutputExact=True)), flush=True)
        b.unchanged(); report['inputsUnchanged'] = True
        report['counts'] = dict(compilations=len(report['rows']), crossStageExactC=sum(r.get('exactC', False) for r in report['rows']),
                               historicalCChanged=sum(not r['sameCAsHistorical'] for r in report['rows'] if 'sameCAsHistorical' in r),
                               rejections=sum('expectedDiagnostic' in r for r in report['rows']), programs=len(report['programs']))
        assert len(report['rows']) == 2 * len(cases)
        assert len(report['programs']) == (45 if a.suite == 'broad45' else 0)
        report['passed'] = report['complete'] = True
    except BaseException as error:
        report['passed'] = report['complete'] = False; report['error'] = repr(error); raise
    finally: save()
    print(json.dumps({k:report.get(k) for k in ['complete', 'passed', 'suite', 'counts', 'error']}))
    sys.exit(0 if report['passed'] else 1)


if __name__ == '__main__': main()
