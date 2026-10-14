#!/usr/bin/env python3
"""Paired historical native89 versus exact qualified native90; no TS rerun.

Each fresh process receives the same authenticated prepared Base carrier. Calls
1 and 5 are selectable; --calls 5 preserves every intermediate request/output.
This private comparison does not change public native image/cache admission.
"""
import argparse
import importlib.util
import json
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
P = ROOT/'selfhost/tools/performance'


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


B = load('phase90_broad_exact', HERE/'broad-exact.py')
A89 = load('phase89_native_admission', P/'phase89/admission.py')
CASES = ['small', 'numeric_closed', 'lexer_original', 'map_closed', 'functions65', 'unicode']
BASELINE_IMAGE = ROOT/'selfhost/build/phase89/compiler-native-self01'
CACHE_IMAGE = ROOT/'selfhost/build/phase88/compiler-native02'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('image', type=Path)
    parser.add_argument('out', type=Path)
    parser.add_argument('--gates', type=Path, required=True)
    parser.add_argument('--calls', type=int, choices=[1, 5], default=1)
    parser.add_argument('--rounds', type=int, default=2)
    parser.add_argument('--cases', default=','.join(CASES))
    parser.add_argument('--seconds', type=int, default=90)
    parser.add_argument('--check-only', action='store_true')
    args = parser.parse_args()
    cases = args.cases.split(',')
    assert cases and len(cases) == len(set(cases)) and set(cases) <= set(CASES)
    assert 1 <= args.rounds <= 5 and 1 <= args.seconds <= 180
    out = args.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase90') and not out.exists()
    inputs = {}

    def remember(path, expected=None):
        actual = B.pin(path)
        if expected is not None:
            assert actual['file'] == str(Path(expected.get('file', expected.get('path'))).resolve())
            assert all(actual[k] == expected[k] for k in ('sha256', 'bytes')), path
        prior = inputs.setdefault(actual['file'], actual)
        assert prior == actual
        return actual

    native89 = A89.authenticate(BASELINE_IMAGE, B.DEFAULT_CACHE)
    cached_origin = B.authenticate(CACHE_IMAGE, B.DEFAULT_CACHE)
    candidate = B.authenticate(args.image, None)
    assert native89['cache'] == cached_origin['cache']
    for field in ('base', 'runtime', 'runtimeParts', 'template', 'effectsDir', 'effects'):
        assert native89[field] == cached_origin[field] == candidate[field], field
    for method in [Path(__file__), HERE/'broad-exact.py', HERE/'native-gates.py',
                   P/'phase89/admission.py', P/'phase88/broad.py', P/'phase88/native_support.py',
                   P/'phase86/guard.py', P/'programs/support.py', Path(sys.executable)]:
        remember(method)
    for auth in (native89, cached_origin, candidate):
        for item in B.walk_pins(auth):
            remember(item['file'], item)
        build = B.read(auth['build']['file'])
        item = build['guard']
        remember(item.get('file', item.get('path')), item)
    remember(B.RUNTIME.parent/'receipt.json')
    qualification = B.admit_nine_gates(args.gates, cached_origin, candidate, remember)
    native90 = dict(candidate, cache=cached_origin['cache'])
    baseline_path = ROOT/'selfhost/build/phase88/screen01/report.json'
    screen_pin = remember(baseline_path)
    baseline = B.read(baseline_path)
    assert baseline['complete'] and baseline['allJobsSucceeded']
    sources, oracles = {}, {}
    for name in cases:
        expected = next(p for p in baseline['inputs'] if p.get('file', p.get('path')) == baseline['cases'][name])
        sources[name] = remember(baseline['cases'][name], expected)
        row = next(r for r in baseline['rows'] if r['case'] == name and r['role'] == 'b2')
        assert row['guard']['complete'] and row['guard']['returncode'] == 0 and len(row['outputs']) == 1
        oracles[name] = row['outputs'][0]

    def unchanged():
        assert all(B.pin(p['file']) == p for p in inputs.values()), 'Frozen comparison input changed'
        assert A89.authenticate(BASELINE_IMAGE, B.DEFAULT_CACHE) == native89
        assert B.authenticate(CACHE_IMAGE, B.DEFAULT_CACHE) == cached_origin
        assert B.authenticate(args.image, None) == candidate

    report = dict(kind='phase90-native89-native90-paired', complete=False, passed=False,
        method=B.pin(__file__), inputs=list(inputs.values()), checkOnly=args.check_only,
        executionPerformed=False, roles=['native89', 'native90'], cases=cases,
        calls=args.calls, rounds=args.rounds, sourcePins=sources, oracles=oracles,
        oracleReceipt=screen_pin, native89=native89, native90=candidate,
        candidateQualification=qualification, privateCache=cached_origin['cache'], rows=[],
        scope='Paired native compilation only. Same prepared Base boundary, single thread/CPU3. '
              'Every emitted C must equal retained B2 oracle. Process time, preparation and '
              'request clocks remain separate; five-call mode is one actual process sequence. '
              'No TS rerun, generated-program speed measurement, native B2 or public admission.')
    out.mkdir(parents=True)
    B.save(out/'plan.json', report)
    if args.check_only:
        unchanged()
        report.update(complete=True, passed=True, targetJobsRun=0, inputsUnchanged=True)
        B.save(out/'preflight.json', report)
        print(json.dumps(dict(preflight=B.pin(out/'preflight.json'), targetJobsRun=0)))
        return
    error = None
    try:
        for rnd in range(args.rounds):
            for ix, name in enumerate(cases):
                order = ['native89', 'native90'] if (ix + rnd) % 2 == 0 else ['native90', 'native89']
                for role in order:
                    assert B.pin(sources[name]['file']) == sources[name]
                    prefix = out/f'{rnd+1}-{name}-{role}'
                    producer = native89 if role == 'native89' else native90
                    command = B.native_args(producer, sources[name]['file'], prefix, args.calls)
                    job = B.guard(Path(str(prefix)+'-guard'), command, args.seconds)
                    directory = Path(job['guard'])
                    process = B.read(directory/'process.json') if (directory/'process.json').exists() else {}
                    logs = '\n'.join((directory/n).read_text() for n in ('stdout.log', 'stderr.log') if (directory/n).exists())
                    outputs = [B.pin(Path(str(prefix)+f'.{i}.c')) for i in range(1,args.calls+1) if Path(str(prefix)+f'.{i}.c').exists()]
                    requests = list(map(int, re.findall(r'request=\d+ request_ms=(\d+)', logs)))
                    exact = len(outputs) == args.calls and all(all(o[k] == oracles[name][k] for k in ('sha256','bytes')) for o in outputs)
                    row = dict(round=rnd+1, case=name, role=role, command=command, job=job, process=process,
                        outputs=outputs, exact=exact, requestMs=requests,
                        metrics={k:int(v) for k,v in re.findall(r'(base_prepare_ms|runtime_prepare_ms)=(\d+)',logs)},
                        processWallSeconds=process.get('wallSeconds'), peakRssBytes=process.get('peakTreeRssBytes'),
                        receipts=[B.pin(p) for p in sorted(directory.glob('*')) if p.is_file()])
                    row['passed'] = bool(job['pass_'] and process.get('complete') and process.get('returncode') == 0
                        and not process.get('stoppedFor') and exact and len(requests) == args.calls)
                    report['executionPerformed'] = True
                    report['rows'].append(row)
                    B.save(out/'report.json', report)
                    print(json.dumps({k:row[k] for k in ('round','case','role','exact','requestMs','processWallSeconds','passed')}), flush=True)
                    assert row['passed'], 'Failed native process/output/clock gate; preserve complete evidence'
    except BaseException as exc:
        error = exc
        report['error'] = f'{type(exc).__name__}: {exc}'
    try:
        unchanged()
        report['inputsUnchanged'] = True
    except BaseException as exc:
        error = error or exc
        report['inputVerificationError'] = f'{type(exc).__name__}: {exc}'
    report['complete'] = error is None and len(report['rows']) == args.rounds*len(cases)*2
    report['passed'] = bool(report['complete'] and report.get('inputsUnchanged') and all(r['passed'] for r in report['rows']))
    report['exactCOutputs'] = sum(len(r['outputs']) for r in report['rows'] if r['passed'])
    B.save(out/'report.json', report)
    if error:
        raise error


if __name__ == '__main__':
    main()
