#!/usr/bin/env python3
"""Saved native timing with one explicit compiler-manifest snapshot continuity."""
import argparse
import importlib.util
import json
import math
import os
import statistics
import sys
import time
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
OLD = HERE.parents[1] / 'phase46'
PREVIOUS = HERE.parents[1] / 'phase67/benchmark/run.py'
V1 = HERE / 'saved-native.py'
V1_SHA256 = '8cffef36ebeb8418942aaa4d5a07a27239aa2a980ed22515060445db9963c7cd'
CALIBRATOR = ROOT / 'selfhost/tools/performance/phase67/benchmark/fast-plan.py'
CALIBRATOR_SHA256 = 'a94c28533fffa7286425014b1486fded365e0bca1038098be7d96136e83e7082'
MANIFEST = ROOT / 'selfhost/src/compiler.json'
RAW = ROOT / 'selfhost/build/phase68'


def module(name, file):
    spec = importlib.util.spec_from_file_location(name, file)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


S = module('p68_saved_support', HERE.parents[1] / 'programs/support.py')
O = module('p68_saved_oracle', OLD / 'oracle.py')
CATALOG = {c['name']: c for c in json.loads((OLD / 'cases.json').read_text())}


def pin(p):
    return S.identity(p)


def verify(item):
    assert pin(item['path']) == item, item['path']
    return item


def read(p):
    return json.loads(Path(p).read_text())


def file_pin(item):
    actual = pin(item.get('file', item.get('path')))
    assert actual['sha256'] == item['sha256'], actual['path']
    if 'bytes' in item:
        assert actual['bytes'] == item['bytes']
    if 'canonicalPath' in item:
        assert actual['path'] == item['canonicalPath']
    return actual


def admit(recipe_path, attempt_path, acquisitions):
    """All original pins stay exact; only the compiler manifest uses its snapshot."""
    recipe_pin, attempt_pin = pin(recipe_path), pin(attempt_path)
    recipe, attempt = read(recipe_path), read(attempt_path)
    assert recipe['kind'] == 'phase67-native-method-v2'
    assert attempt['checked'] and attempt['config']['strictExact']
    assert attempt['artifactKind'] in ('derived-b1', 'checked-b1')
    identities = {p['path']: p for p in recipe['inputs']}
    assert file_pin(attempt['api']) == identities[recipe['api']], 'Recipe must select this exact checked API'
    original = identities[str(MANIFEST)]
    entries = [x for x in attempt['snapshot']['sources'] if x['original']['file'] == str(MANIFEST)]
    assert len(entries) == 1
    entry = entries[0]
    assert entry['original']['sha256'] == original['sha256']
    frozen = file_pin(entry['frozen'])
    assert Path(frozen['path']) == Path(attempt['snapshot']['root']) / 'src/compiler.json'
    assert (frozen['sha256'], frozen['bytes']) == (original['sha256'], original['bytes'])
    continuity = dict(attempt=attempt_pin, api=identities[recipe['api']], original=original, frozen=frozen)
    actual_inputs = [frozen if p['path'] == str(MANIFEST) else verify(p) for p in recipe['inputs']]
    assert identities[str(PREVIOUS)] == pin(PREVIOUS)
    products, acquisition_pins = {}, []
    for path in acquisitions:
        acquisition_pins.append(pin(path))
        acquired = read(path)
        assert acquired['kind'] == 'phase67-native-acquire' and acquired['complete']
        assert acquired['recipe'] == recipe_pin and acquired['inputs'] == recipe['inputs']
        for row in acquired['records']:
            key = row['case'], row['role']
            assert key not in products and row['correct']
            assert row['role'] in ('selfhost', 'upstream')
            for field in ('source', 'nativeSource', 'executable', 'emissionReceipt'):
                verify(row[field])
            assert row['source'] == pin(OLD / (row['case'] + '-batch.bend'))
            emitted = read(row['emissionReceipt']['path'])
            assert emitted['complete'] and emitted['role'] == row['role'] and emitted['target'] == 'c'
            assert emitted['recipe'] == recipe_pin and emitted['input'] == row['source']
            assert emitted['output'] == row['nativeSource']
            if row['role'] == 'selfhost':
                assert identities[recipe['api']] in emitted['compiler']
            assert row['emission']['complete'] and row['toolchain']['complete'] and row['process']['complete']
            assert row['toolchain']['command'] == ['taskset', '-c', '3', recipe['clang'],
                *recipe['clangArgs'], row['nativeSource']['path'], *recipe['linkArgs'], '-o', row['executable']['path']]
            values = O.points(CATALOG[row['case']])
            assert values[0] == CATALOG[row['case']]['expected']
            assert row['expected'] == [values[0], O.digest(values, 0), O.digest(values, 1)]
            products[key] = row
    assert recipe['cpu'] == 3 and recipe['treeRssMiB'] == 2048 and recipe['availableMiB'] == 4096
    return recipe, recipe_pin, continuity, actual_inputs, acquisition_pins, products


def measure(args):
    acquired = [p.resolve() / 'report.json' if p.is_dir() else p.resolve() for p in args.acquired]
    attempt = args.attempt.resolve() / 'attempt.json' if args.attempt.is_dir() else args.attempt.resolve()
    recipe, recipe_pin, continuity, inputs, acquisitions, products = admit(args.recipe, attempt, acquired)
    plan_pin, plan = pin(args.plan), read(args.plan)
    names, roles = args.cases.split(','), args.roles.split(',')
    assert names and roles and len(set(names)) == len(names) and len(set(roles)) == len(roles)
    assert args.rounds > 0 and set(roles) <= {'selfhost', 'upstream'}
    assert all((case, role) in products for case in names for role in roles)
    for case in names:
        assert type(plan[case]['repetitions']) is int and plan[case]['repetitions'] > 0
        assert type(plan[case]['warmups']) is int and plan[case]['warmups'] >= 0
    if args.check_only:
        print(json.dumps(dict(checked=True, targetsExecuted=False, products=len(products), continuity=continuity)))
        return
    assert {k: os.environ.get(k) for k in recipe['compilerEnvironment']} == recipe['compilerEnvironment']
    out = args.out.resolve()
    out.relative_to(RAW)
    out.mkdir(parents=True, exist_ok=False)
    records = []
    report = dict(kind='phase68-saved-native-measure', complete=False, producer=pin(__file__),
        predecessorMethod=pin(PREVIOUS), recipe=recipe_pin, continuity=continuity, actualInputs=inputs,
        acquisitions=acquisitions, plan=plan_pin, started=time.time(), records=records,
        scope='Phase67 fixed-work runtime protocol on saved binaries; no compiler or Clang invocation. Only compiler.json resolves through the exact selected checked snapshot. Prepared C/build provenance remains in original acquisitions.')

    def save():
        report['finished'] = time.time()
        S.save(out / 'report.json', report)

    save()
    try:
        with S.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
            for case in names:
                n, warm = plan[case]['repetitions'], plan[case]['warmups']
                values = O.points(CATALOG[case])
                expected = [CATALOG[case]['expected'], O.digest(values, warm), O.digest(values, n)]
                for round_index in range(args.rounds):
                    for role in roles[round_index % len(roles):] + roles[:round_index % len(roles)]:
                        artifact = verify(products[(case, role)]['executable'])
                        dest = out / (case + '-' + role + '-r' + str(round_index))
                        child = dest / 'child.json'
                        command = ['taskset', '-c', '3', 'python3', str(OLD / 'execute.py'), str(child),
                            artifact['path'], '--threads', '1', '--gpu', 'off', '--', str(n), str(warm)]
                        row = dict(case=case, role=role, round=round_index, repetitions=n, warmups=warm, expected=expected)
                        row['process'] = guard.run(command, dest, time.monotonic() + 45)
                        row['stdout'] = (dest / 'stdout.log').read_text() if (dest / 'stdout.log').exists() else ''
                        row['stderr'] = (dest / 'stderr.log').read_text() if (dest / 'stderr.log').exists() else ''
                        words = row['stdout'].strip().splitlines()
                        row['correct'] = row['process']['complete'] and len(words) == 4 and all(w.isdecimal() for w in words) and list(map(int, words[:3])) == expected
                        if row['correct']:
                            row['elapsedMs'] = int(words[3])
                        if child.exists():
                            row['child'] = read(child)
                        row['validClock'] = row['correct'] and 0 < row.get('elapsedMs', 0) <= row.get('child', {}).get('processSeconds', 0) * 1000 + 2
                        row['timingQualified'] = row['validClock'] and row['elapsedMs'] >= 100
                        records.append(row)
                        save()
                        print(json.dumps({k: row.get(k) for k in ('case', 'role', 'round', 'correct', 'elapsedMs', 'timingQualified')}), flush=True)
                        assert row['correct'], 'Runtime correctness failure'
        admit(args.recipe, attempt, acquired)
        for item in [recipe_pin, continuity['attempt'], *acquisitions]:
            verify(item)
        verify(plan_pin)
        verify(report['producer'])
        report['complete'] = all(r['correct'] for r in records)
        report['allTimingQualified'] = all(r['timingQualified'] for r in records)
        save()
    except BaseException as error:
        report['error'] = repr(error)
        save()
        raise


def endpoint(timing_path, attempt_path):
    timing = read(timing_path)
    assert timing['complete'] and timing['kind'] in ('phase67-native-measure', 'phase68-saved-native-measure')
    verify(timing['recipe']);verify(timing['plan'])
    for item in timing['acquisitions']:
        verify(item)
    attempt = attempt_path / 'attempt.json' if attempt_path.is_dir() else attempt_path
    admitted = admit(timing['recipe']['path'], attempt, [p['path'] for p in timing['acquisitions']])
    recipe, _, continuity, _, _, products = admitted
    if timing['kind'] == 'phase68-saved-native-measure':
        assert timing['continuity'] == continuity
        v1 = pin(V1)
        assert v1['sha256'] == V1_SHA256
        assert timing['producer'] in (v1, pin(__file__))
        assert timing['predecessorMethod'] == pin(PREVIOUS)
    else:
        assert timing['inputs'] == recipe['inputs']
    plan, samples = read(timing['plan']['path']), {}
    seen = set()
    for row in timing['records']:
        key = row['case'], row['role']
        unique = (*key, row['round'])
        assert unique not in seen;seen.add(unique)
        assert row['correct'] and row['validClock'] and row['timingQualified']
        n, warm = plan[row['case']]['repetitions'], plan[row['case']]['warmups']
        values = O.points(CATALOG[row['case']])
        expected = [CATALOG[row['case']]['expected'], O.digest(values, warm), O.digest(values, n)]
        assert (row['repetitions'], row['warmups'], row['expected']) == (n, warm, expected)
        assert list(map(int, row['stdout'].strip().splitlines())) == [*expected, row['elapsedMs']]
        assert row['process']['complete'] and row['child']['returncode'] == 0
        assert 100 <= row['elapsedMs'] <= row['child']['processSeconds'] * 1000 + 2
        cmd = row['process']['command']
        assert cmd[:5] == ['taskset', '-c', '3', 'python3', str(OLD / 'execute.py')]
        assert cmd[6:] == [products[key]['executable']['path'], '--threads', '1', '--gpu', 'off', '--', str(n), str(warm)]
        samples.setdefault(key, []).append(row)
    assert samples
    return timing, recipe, continuity, products, samples


def compare(args):
    a, ra, ca, pa, sa = endpoint(args.baseline_timing, args.baseline_attempt)
    b, rb, cb, pb, sb = endpoint(args.candidate_timing, args.candidate_attempt)
    for field in ('node', 'clang', 'nodeArgs', 'clangArgs', 'linkArgs', 'cpu', 'treeRssMiB', 'availableMiB', 'compilerEnvironment', 'upstreamCommit', 'protocol'):
        assert ra[field] == rb[field], field
    ia, ib = ({p['path']: p for p in r['inputs']} for r in (ra, rb))
    changed = sorted(p for p in ia.keys() & ib.keys() if ia[p] != ib[p])
    added_inputs = []
    if args.allow_added_input:
        assert args.allow_added_input == ['selfhost/tools/performance/phase67/benchmark/fast-plan.py']
        calibration = pin(CALIBRATOR)
        assert calibration['sha256'] == CALIBRATOR_SHA256 and calibration['bytes'] == 2919
        assert str(CALIBRATOR) not in ia and ib.get(str(CALIBRATOR)) == calibration
        dependencies = [PREVIOUS, PREVIOUS.parent / 'emit.mjs', OLD / 'execute.py',
            OLD / 'oracle.py', HERE.parents[1] / 'programs/support.py']
        for dependency in dependencies:
            assert ia[str(dependency)] == ib[str(dependency)] == pin(dependency)
            assert 'fast-plan' not in dependency.read_text()
        added_inputs.append(dict(input=calibration, candidateOnly=True,
            role='Pure data-only calibration-plan producer, outside acquisition and runtime executed commands.',
            unchangedExecutedDependencies=[pin(p) for p in dependencies],
            scope='Exact pinned source reviewed: no subprocess, compiler, native, or toolchain invocation; neither imported nor invoked by these acquisition/runtime controllers. Both campaigns consume the same already-frozen plan.'))
    assert (ia.keys() ^ ib.keys()) <= {ra['api'], rb['api'], *(x['input']['path'] for x in added_inputs)}, 'Unregistered input inventory change'
    allowed = [str(ROOT / p) for p in args.allow_compiler_input]
    assert set(changed) <= set(allowed), changed
    assert not allowed or allowed == [str(MANIFEST)], 'Only the registered compiler manifest is allowed'
    assert a['plan'] == b['plan'], 'Use the exact same fixed plan'
    for p in set(changed):
        assert p == ca['original']['path'] == cb['original']['path']
        assert ia[p] == ca['original'] and ib[p] == cb['original']
    rows = []
    median = lambda rs: statistics.median(r['elapsedMs'] / r['repetitions'] * 1000 for r in rs)
    compared = [key for key in sorted(sb) if key[1] == 'selfhost']
    assert compared, 'A compiler ablation needs selfhost samples'
    for key in compared:
        assert key in sa
        old, new = pa[key], pb[key]
        assert old['source'] == new['source']
        before, after = median(sa[key]), median(sb[key])
        rows.append(dict(case=key[0], role=key[1], baselineMicroseconds=before, candidateMicroseconds=after,
            candidateOverBaselineRuntime=after / before, baselineRounds=len(sa[key]), candidateRounds=len(sb[key]),
            baselineClangSeconds=old['toolchain']['wallSeconds'], candidateClangSeconds=new['toolchain']['wallSeconds'],
            candidateOverBaselineClang=new['toolchain']['wallSeconds'] / old['toolchain']['wallSeconds'],
            baselineCBytes=old['nativeSource']['bytes'], candidateCBytes=new['nativeSource']['bytes'],
            candidateOverBaselineCBytes=new['nativeSource']['bytes'] / old['nativeSource']['bytes']))
    gm = lambda field: math.exp(statistics.mean(math.log(r[field]) for r in rows))
    result = dict(kind='phase68-saved-native-comparison', complete=True, dataOnly=True, targetExecuted=False,
        producer=pin(__file__), predecessorMethod=pin(PREVIOUS),
        inputs=[pin(args.baseline_timing), pin(args.candidate_timing)], baselineContinuity=ca, candidateContinuity=cb,
        baselineRecipe=a['recipe'], candidateRecipe=b['recipe'], plan=a['plan'],
        registeredCompilerInputs=allowed, registeredAddedInputs=added_inputs, changedSharedInputs=[dict(path=p, baseline=ia[p], candidate=ib[p]) for p in changed],
        rows=rows, geomeanCandidateOverBaselineRuntime=gm('candidateOverBaselineRuntime'),
        geomeanCandidateOverBaselineClang=gm('candidateOverBaselineClang'),
        geomeanCandidateOverBaselineCBytes=gm('candidateOverBaselineCBytes'),
        scope='Separate sequential campaigns; same saved-native workload/oracle/toolchain and Phase67 runtime protocol. Manifest continuity is explicit; compiler/API changes are intentional ablations. All runtime samples >=100ms. C build clocks remain single original acquisitions, not fresh timing.')
    output = args.out.resolve()
    assert not output.is_relative_to(ROOT / 'selfhost/build') or output.is_relative_to(RAW)
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open('x') as stream:
        stream.write(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(output=pin(output), runtimeRatio=result['geomeanCandidateOverBaselineRuntime'])))


parser = argparse.ArgumentParser(description=__doc__)
sub = parser.add_subparsers(dest='action', required=True)
measurement = sub.add_parser('measure')
measurement.add_argument('--recipe', type=Path, required=True)
measurement.add_argument('--attempt', type=Path, required=True)
measurement.add_argument('--acquired', type=Path, nargs='+', required=True)
measurement.add_argument('--plan', type=Path, required=True)
measurement.add_argument('--out', type=Path, required=True)
measurement.add_argument('--cases', default='numeric,array,closures,tree,map,lexer')
measurement.add_argument('--roles', default='selfhost')
measurement.add_argument('--rounds', type=int, default=2)
measurement.add_argument('--check-only', action='store_true', help='Source/data admission only; no output or targets')
comparison = sub.add_parser('compare')
for name in ('baseline-timing', 'candidate-timing', 'baseline-attempt', 'candidate-attempt', 'out'):
    comparison.add_argument('--' + name, type=Path, required=True)
comparison.add_argument('--allow-compiler-input', action='append', choices=['selfhost/src/compiler.json'], default=[])
comparison.add_argument('--allow-added-input', action='append',
    choices=['selfhost/tools/performance/phase67/benchmark/fast-plan.py'], default=[])
args = parser.parse_args()
measure(args) if args.action == 'measure' else compare(args)
