#!/usr/bin/env python3
"""Root-only candidate counts against saved baseline counts; no timing credit."""
import argparse
import importlib.util
import json
import os
import sys
import time
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('p68_frozen_profile_runner', HERE / 'run.py')
B = importlib.util.module_from_spec(spec)
spec.loader.exec_module(B)
S, C, O, ROOT = B.S, B.C, B.O, B.ROOT


def read(path):
    return json.loads(Path(path).read_text())


def attempt_identity(item):
    actual = S.identity(item['canonicalPath'])
    assert actual['sha256'] == item['sha256'], item
    return actual


def prepare(acquired, attempt_dir, baseline_path, cases):
    acquisition_path = acquired / 'report.json'
    acquisition = read(acquisition_path)
    assert acquisition['complete']
    recipe_path = Path(acquisition['recipe']['path'])
    B.verify([acquisition['recipe']])
    recipe = read(recipe_path)
    attempt_path = attempt_dir / 'attempt.json'
    attempt = read(attempt_path)
    build = read(attempt_dir / 'build.json')
    assert build['complete'] and attempt['checked'] and attempt['config']['strictExact']
    api = attempt_identity(attempt['api'])
    assert api == attempt_identity(build['api'])
    assert api['path'] == recipe['api']
    assert api in recipe['inputs']
    baseline = read(baseline_path)
    assert baseline['complete'] and baseline['diagnosticOnly'] and not baseline['timingValid']
    assert S.identity(HERE / 'native-counts.py') in baseline['inputs']
    assert S.identity(HERE / 'run.py') in baseline['inputs']
    original_recipe = B.RAW / 'native-scalars01-recipe.json'
    original = read(original_recipe)
    assert S.identity(original_recipe) in baseline['inputs']
    for key in ('clang', 'clangArgs', 'linkArgs', 'compilerEnvironment'):
        assert recipe[key] == original[key], ('changed toolchain method', key)
    assert {k: os.environ.get(k) for k in recipe['compilerEnvironment']} == recipe['compilerEnvironment']
    toolroot = str(Path(recipe['clang']).parent.parent) + '/'
    def tool_inputs(r):
        return [x for x in r['inputs'] if x['path'].startswith(toolroot) or
                Path(x['path']).name in ('ld', 'ld.bfd', 'x86_64-linux-gnu-ld.bfd')]
    toolchain = tool_inputs(recipe)
    assert toolchain == tool_inputs(original), 'toolchain identity changed'
    inputs = [S.identity(x) for x in (acquisition_path, recipe_path, attempt_path,
        attempt_dir / 'build.json', baseline_path, original_recipe, __file__,
        HERE / 'run.py', HERE / 'native-counts.py', B.HERE.parents[1] / 'programs/support.py',
        B.OLD / 'oracle.py', B.OLD / 'cases.json', *O.ORACLE_FILES)]
    inputs += toolchain + [api, attempt_identity(attempt['checkedApi']),
        attempt_identity(attempt['bootstrapReport']), attempt_identity(attempt['derivationReport'])]
    # Bind the checked compiler to its immutable source snapshot, never mutable
    # working-tree originals or whichever compiler happens to be installed now.
    inputs += [attempt_identity(x['frozen']) for x in attempt['snapshot']['sources']]
    records = []
    for case in cases:
        rows = [x for x in acquisition['records'] if x['case'] == case and x['role'] == 'selfhost']
        bases = [x for x in baseline['records'] if x['case'] == case and x['role'] == 'selfhost']
        assert len(rows) == len(bases) == 1
        row, base = rows[0], bases[0]
        assert row['correct'] and base['complete']
        emission = read(row['emissionReceipt']['path'])
        assert emission['complete'] and emission['role'] == 'selfhost' and emission['target'] == 'c'
        assert emission['observation']['status'] == 'ok' and emission['observation']['checked']
        assert emission['output'] == row['nativeSource'] and emission['input'] == row['source']
        assert emission['recipe'] == acquisition['recipe'] and api in emission['compiler']
        assert row['emissionReceipt']['path'] == row['nativeSource']['path'] + '.json'
        old_receipt = Path(base['source']['path'] + '.json')
        old = read(old_receipt)
        assert S.identity(old_receipt) in baseline['inputs'] and old['output'] == base['source']
        assert old['input'] == emission['input'], 'workload differs'
        # This comparison isolates lowering, using the SAME native runtime C.
        runtime = lambda e: next(x for x in e['compiler'] if x['path'].endswith('/runtime/native/runtime.c'))
        assert runtime(old) == runtime(emission), 'runtime differs from baseline'
        assert old['effectInputs'] == emission['effectInputs'], 'effect implementations differ'
        assert [x['repetitions'] for x in base['runs']] == [1, 17]
        assert all(x['correct'] for x in base['runs'])
        expected_command = ['taskset', '-c', '3', recipe['clang'], *recipe['clangArgs'],
                            row['nativeSource']['path'], *recipe['linkArgs'], '-o', row['executable']['path']]
        assert row['toolchain']['complete'] and row['toolchain']['command'] == expected_command
        inputs += [row[k] for k in ('nativeSource', 'emissionReceipt', 'executable', 'source')]
        inputs += emission['compiler'] + emission['effectInputs'] + emission['programInputs']
        inputs += [S.identity(old_receipt), base['source'], base['derivation']]
        records.append((case, row, base))
    identities = {}
    for item in inputs:
        assert item['path'] not in identities or identities[item['path']] == item, item['path']
        identities[item['path']] = item
    inputs = list(identities.values())
    B.verify(inputs)
    return recipe, api, inputs, records


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--acquisition', required=True, type=Path)
    p.add_argument('--attempt', required=True, type=Path)
    p.add_argument('--baseline-counts', type=Path, default=ROOT / 'selfhost/build/phase68/native-counts01/report.json')
    p.add_argument('--cases', default='numeric,array')
    p.add_argument('--out', type=Path)
    p.add_argument('--check-only', action='store_true', help='CPU0 source/data checks, no targets or files')
    a = p.parse_args()
    cases = a.cases.split(',')
    assert cases and len(cases) == len(set(cases)) and set(cases) <= {'numeric', 'array', 'closures', 'tree', 'map', 'lexer'}
    recipe, api, inputs, artifacts = prepare(a.acquisition.resolve(), a.attempt.resolve(), a.baseline_counts.resolve(), cases)
    if a.check_only:
        for case, row, base in artifacts:
            code, mapping = C.instrument(Path(row['nativeSource']['path']).read_text())
            print(json.dumps(dict(case=case, anchorsValid=True, segments=len(mapping), instrumentedBytes=len(code.encode()))))
        return
    assert a.out, '--out required for execution'
    a.out = a.out.resolve()
    a.out.relative_to(ROOT / 'selfhost/build/phase68')
    a.out.mkdir(parents=True, exist_ok=False)
    catalog = {x['name']: x for x in read(B.OLD / 'cases.json')}
    records, created = [], []
    report = dict(kind='phase68-native-candidate-counts-v1', complete=False, diagnosticOnly=True,
        timingValid=False, selectedAPI=api, inputs=inputs, createdArtifacts=created, started=time.time(),
        records=records, compilerEnvironment=recipe['compilerEnvironment'],
        limitations='No speed credit. Atomic counters alter execution/optimization. Counts include whole-process IO and digest. Repetition subtraction includes formatting changes. Segment frequency is not CPU time. Requested words are allocator capacity, not RSS. Same selfhost runtime/effects verified; baseline counts reused without rerunning.')
    def save():
        report['finished'] = time.time()
        S.save(a.out / 'report.json', report)
    def run(guard, command, dest, seconds):
        result = guard.run(['taskset', '-c', '3', *map(str, command)], dest, time.monotonic() + seconds)
        assert not guard.interrupted, 'Guard interrupted; inspect retained logs'
        return result
    save()
    try:
        with S.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
            for case, row, base in artifacts:
                d = a.out / (case + '-selfhost')
                r = dict(case=case, role='selfhost', source=row['nativeSource'], baselineSource=base['source'], runs=[], complete=False)
                records.append(r)
                derivation = C.derive(row['nativeSource']['path'], d)
                r['derivation'] = S.identity(d / 'derivation.json')
                created += [r['derivation'], derivation['output']]
                exe = d / 'program'
                r['build'] = run(guard, [recipe['clang'], *recipe['clangArgs'], d / 'program.c', *recipe['linkArgs'], '-o', exe], d / 'build', 90)
                save()
                assert r['build']['complete'], 'Diagnostic Clang build failed'
                r['executable'] = S.identity(exe)
                created.append(r['executable'])
                save()
                for count in (1, 17):
                    B.verify([r['executable']])
                    dest = d / ('run' + str(count))
                    process = run(guard, [exe, '--threads', '1', '--gpu', 'off', '--', count, 0], dest, 60)
                    item = dict(repetitions=count, process=process, correct=False)
                    r['runs'].append(item)
                    save()
                    assert process['complete'], 'Diagnostic execution failed'
                    stdout = (dest / 'stdout.log').read_text().strip().splitlines()
                    expected = [catalog[case]['expected'], O.digest(O.points(catalog[case]), 0), O.digest(O.points(catalog[case]), count)]
                    correct = len(stdout) == 4 and all(x.isdecimal() for x in stdout) and list(map(int, stdout[:3])) == expected
                    counter_rows = [json.loads(x) for x in (dest / 'stderr.log').read_text().splitlines() if x.startswith('{"kind":"phase68-native-counts"')]
                    assert len(counter_rows) == 1 and counter_rows[0]['invalidClassCalls'] == 0
                    item.update(stdout=stdout, expected=expected, correct=correct, counts=counter_rows[0])
                    save()
                    assert correct, 'Independent output mismatch'
                low, high = [x['counts'] for x in r['runs']]
                r['delta'] = {k: high[k] - low[k] for k in high if isinstance(high[k], int)}
                r['delta']['allocationClassCounts'] = [h-l for l,h in zip(low['allocationClassCounts'], high['allocationClassCounts'])]
                sd = [(int(k), high['segments'].get(k, 0)-low['segments'].get(k, 0)) for k in set(low['segments']) | set(high['segments'])]
                mapping = {x['index']: x for x in derivation['segments']}
                r['topSegmentDeltas'] = [dict(**mapping[k], decoded=B.decoded(mapping[k]['symbol']), entries=v) for k,v in sorted(sd,key=lambda x:x[1],reverse=True)[:40]]
                r['baselineDelta'] = base['delta']
                r['candidateOverBaseline'] = {k: v/base['delta'][k] if base['delta'][k] else None for k,v in r['delta'].items() if isinstance(v,int)}
                r['complete'] = True
                B.verify(created)
                save()
                print(json.dumps(dict(case=case, complete=True, candidateOverBaseline=r['candidateOverBaseline'])), flush=True)
        B.verify(inputs)
        B.verify(created)
        report['complete'] = len(records) == len(artifacts) and all(x['complete'] for x in records)
        save()
    except BaseException as error:
        report['error'] = repr(error)
        save()
        raise


if __name__ == '__main__':
    main()
