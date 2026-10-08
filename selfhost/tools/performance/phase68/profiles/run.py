#!/usr/bin/env python3
"""Root-only bounded Phase68 diagnostics of immutable saved Phase67 native C."""
import argparse
import importlib.util
import json
import os
import re
import shutil
import sys
import time
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
RAW = ROOT / 'selfhost/build/phase67'
OLD = ROOT / 'selfhost/tools/performance/phase46'


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    obj = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(obj)
    return obj


S = module('p68_support', HERE.parents[1] / 'programs/support.py')
O = module('p68_oracle', OLD / 'oracle.py')
C = module('p68_counts', HERE / 'native-counts.py')


def verify(items):
    for item in items:
        assert S.identity(item['path']) == item, item['path']


def decoded(symbol):
    match = re.search(r'FID_((?:\d+_)+)$', symbol)
    if match:
        try:
            return ''.join(chr(int(x)) for x in match[1].strip('_').split('_'))
        except ValueError:
            pass
    return symbol


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', required=True, type=Path)
    p.add_argument('--cases', default='numeric,array,lexer')
    p.add_argument('--roles', default='selfhost,upstream')
    p.add_argument('--mode', choices=['counts', 'gprof'], default='counts')
    p.add_argument('--profile-multiplier', type=int, default=10)
    a = p.parse_args()
    cases, roles = a.cases.split(','), a.roles.split(',')
    assert set(cases) <= {'numeric', 'array', 'closures', 'tree', 'map', 'lexer'}
    assert set(roles) <= {'selfhost', 'upstream'}
    assert 1 <= a.profile_multiplier <= 20
    a.out = a.out.resolve()
    assert (ROOT / 'selfhost/build/phase68').exists(), 'Root must create fresh Phase68 raw first'
    a.out.relative_to(ROOT / 'selfhost/build/phase68')
    a.out.mkdir(parents=True, exist_ok=False)
    recipe_path = RAW / 'native-scalars01-recipe.json'
    recipe = json.loads(recipe_path.read_text())
    # Saved C contains all runtime/effect code. Pin the exact artifacts and
    # original receipts; historical live installed APIs need not match today.
    toolroot = str(Path(recipe['clang']).parent.parent) + '/'
    inputs = [x for x in recipe['inputs'] if x['path'].startswith(toolroot) or
              Path(x['path']).name in ('ld', 'ld.bfd', 'x86_64-linux-gnu-ld.bfd')]
    inputs += [S.identity(recipe_path), S.identity(__file__), S.identity(HERE / 'native-counts.py'),
               S.identity(HERE.parents[1] / 'programs/support.py'), S.identity(OLD / 'oracle.py'),
               S.identity(OLD / 'cases.json'), *[S.identity(x) for x in O.ORACLE_FILES]]
    api = next(x for x in recipe['inputs'] if x['path'] == recipe['api'])
    assert api['sha256'].startswith('c76f1113')
    inputs.append(api)
    profiler = shutil.which('gprof') if a.mode == 'gprof' else None
    if a.mode == 'gprof':
        assert profiler, 'gprof executable unavailable'
        inputs.append(S.identity(profiler))
    assert {k: os.environ.get(k) for k in recipe['compilerEnvironment']} == recipe['compilerEnvironment']
    catalog = {x['name']: x for x in json.loads((OLD / 'cases.json').read_text())}
    plan = json.loads((RAW / 'native-fast06-plan01.json').read_text())
    inputs.append(S.identity(RAW / 'native-fast06-plan01.json'))
    artifacts = []
    for case in cases:
        for role in roles:
            heldout = case in ('tree', 'map', 'lexer')
            folder = ('native-heldout-' if heldout else 'native-') + ('scalars01' if role == 'selfhost' else 'baseline02')
            acquired = RAW / folder
            acquisition = json.loads((acquired / 'report.json').read_text())
            assert acquisition['complete']
            row = next(r for r in acquisition['records'] if r['case'] == case and r['role'] == role)
            assert row['correct']
            inputs += [S.identity(acquired / 'report.json'), row['nativeSource'], row['emissionReceipt'], row['executable'], row['source']]
            artifacts.append((case, role, row))
    inputs = list({x['path']: x for x in inputs}.values())
    records = []
    created = []
    report = dict(kind='phase68-native-' + a.mode, complete=False, diagnosticOnly=True,
        timingValid=False, selectedAPI=api, inputs=inputs, createdArtifacts=created, started=time.time(), records=records,
        compilerEnvironment=recipe['compilerEnvironment'], limitations='No speed credit. Instrumentation, -pg and atomic counts alter optimization and runtime. Sampled gprof time excludes unresolved shared-library code; its multithreaded accounting and statistical resolution limit attribution. Segment frequencies are never percentages of execution time. Repetition deltas include IO/digest differences. Saved roles retain different runtime revisions.')

    def save():
        report['finished'] = time.time()
        S.save(a.out / 'report.json', report)

    def run(guard, command, dest, seconds=45, env=None):
        result = guard.run(['taskset', '-c', '3', *map(str, command)], dest, time.monotonic() + seconds, env=env)
        if guard.interrupted:
            raise RuntimeError('Guard interrupted')
        return result

    def observation(dest, process, case, count):
        expected = [catalog[case]['expected'], O.digest(O.points(catalog[case]), 0), O.digest(O.points(catalog[case]), count)]
        words = (dest / 'stdout.log').read_text().strip().splitlines() if (dest / 'stdout.log').exists() else []
        return dict(expected=expected, stdout=words, correct=process['complete'] and len(words) == 4 and
                    all(w.isdecimal() for w in words) and list(map(int, words[:3])) == expected)

    save()
    try:
        verify(inputs)
        with S.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
            report['perfCapability'] = run(guard, ['perf', 'stat', '-e', 'task-clock', '--', 'true'], a.out / 'perf-capability', 10)
            report['perfParanoid'] = Path('/proc/sys/kernel/perf_event_paranoid').read_text().strip()
            save()
            for case, role, row in artifacts:
                d = a.out / (case + '-' + role)
                r = dict(case=case, role=role, source=row['nativeSource'], runs=[], complete=False)
                records.append(r)
                if a.mode == 'counts':
                    derivation = C.derive(row['nativeSource']['path'], d)
                    r['derivation'] = S.identity(d / 'derivation.json')
                    created.extend([r['derivation'], derivation['output']])
                    source = d / 'program.c'
                else:
                    d.mkdir()
                    source = Path(row['nativeSource']['path'])
                exe = d / 'program'
                extra = ['-pg'] if a.mode == 'gprof' else []
                r['build'] = run(guard, [recipe['clang'], *recipe['clangArgs'], *extra, source, *recipe['linkArgs'], '-o', exe], d / 'build', 90)
                save()
                if not r['build']['complete']:
                    raise RuntimeError('Diagnostic Clang build failed: ' + case + ' ' + role)
                r['executable'] = S.identity(exe)
                created.append(r['executable'])
                counts = [1, 17] if a.mode == 'counts' else [1, plan[case]['repetitions'] * a.profile_multiplier]
                for count in counts:
                    verify([r['executable']])
                    dest = d / ('run' + str(count))
                    env = {'GMON_OUT_PREFIX': str(dest / 'gmon')} if a.mode == 'gprof' else None
                    process = run(guard, [exe, '--threads', '1', '--gpu', 'off', '--', str(count), '0'], dest, 60, env)
                    observed = observation(dest, process, case, count)
                    item = dict(repetitions=count, process=process, **observed)
                    r['runs'].append(item)
                    if a.mode == 'counts':
                        counter_rows = [json.loads(x) for x in (dest / 'stderr.log').read_text().splitlines() if x.startswith('{"kind":"phase68-native-counts"')]
                        assert len(counter_rows) == 1
                        item['counts'] = counter_rows[0]
                        assert item['counts']['invalidClassCalls'] == 0
                    else:
                        gm = list(dest.glob('gmon.*'))
                        item['gmon'] = [S.identity(x) for x in gm]
                        created.extend(item['gmon'])
                        assert len(gm) == 1, 'gprof needs exactly one normal-exit gmon output'
                        r['gprofTool'] = S.identity(profiler)
                        item['analysis'] = run(guard, [profiler, '-b', '-p', exe, gm[0]], dest / 'gprof', 10)
                        save()
                        if not item['analysis']['complete']:
                            raise RuntimeError('gprof analysis failed: ' + case + ' ' + role)
                        flat = (dest / 'gprof/stdout.log').read_text()
                        created.append(S.identity(dest / 'gprof/stdout.log'))
                        rows = []
                        for line in flat.splitlines():
                            match = re.match(r'^\s*(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(.*)$', line)
                            if match:
                                tail = match[4].split()
                                rows.append(dict(percent=float(match[1]), cumulativeSeconds=float(match[2]), selfSeconds=float(match[3]), symbol=tail[-1], decoded=decoded(tail[-1])))
                        item['flatRows'] = rows
                        item['sampledSeconds'] = sum(x['selfSeconds'] for x in rows)
                        item['positiveAttributedSymbols'] = sum(x['selfSeconds'] > 0 for x in rows)
                        item['samplingUsable'] = bool(rows) and item['sampledSeconds'] >= 0.1 and item['positiveAttributedSymbols'] > 0
                    save()
                    if not item['correct']:
                        raise RuntimeError('Diagnostic result mismatch: ' + case + ' ' + role)
                if a.mode == 'counts':
                    low, high = [x['counts'] for x in r['runs']]
                    r['delta'] = {k: high[k] - low[k] for k in high if isinstance(high[k], int)}
                    r['delta']['allocationClassCounts'] = [h - l for l, h in zip(low['allocationClassCounts'], high['allocationClassCounts'])]
                    sd = [(int(k), high['segments'].get(k, 0) - low['segments'].get(k, 0))
                          for k in set(low['segments']) | set(high['segments'])]
                    mapping = {x['index']: x for x in derivation['segments']}
                    r['topSegmentDeltas'] = [dict(**mapping[k], decoded=decoded(mapping[k]['symbol']), entries=v) for k, v in sorted(sd, key=lambda pair: pair[1], reverse=True)[:40]]
                r['complete'] = all(x['correct'] for x in r['runs'])
                if a.mode == 'gprof':
                    r['samplingUsable'] = r['runs'][-1]['samplingUsable']
                verify(created)
                save()
                print(json.dumps(dict(case=case, role=role, complete=r['complete'], delta=r.get('delta'), samplingUsable=r.get('samplingUsable'))), flush=True)
        verify(inputs)
        verify(created)
        report['complete'] = len(records) == len(artifacts) and all(x['complete'] for x in records)
        save()
    except BaseException as error:
        report['error'] = repr(error)
        save()
        raise


if __name__ == '__main__':
    main()
