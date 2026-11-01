#!/usr/bin/env python3
"""Prepare explicit profiling/inspection jobs from frozen program artifacts; execute nothing."""
import argparse
import json
from pathlib import Path
import sys

from bench import HERE, PRESETS, pin, read, require, save, select, verify


def prepare(args):
    manifest = read(args.manifest)
    require(manifest['schema'] == 'bend-benchmark-manifest-v1' and manifest['kind'] == 'programs',
            'Program-artifact manifest required; compiler workloads use the generic profiler directly')
    for entry in manifest['inputs']:
        verify(entry)
    cases = select(manifest, args.budget, args.set, args.cases)
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    inputs = [pin(args.manifest), pin(__file__)]
    jobs, js_entries, native_workloads = [], [], {}
    empty = out / 'expected-empty.stderr'
    empty.write_bytes(b'')
    js_engine = None
    for case in cases:
        for role, definition in manifest['roles'].items():
            artifact = case['products'][role]['artifact']
            if definition['target'] == 'js':
                engine = definition['engine']['file']
                require(js_engine is None or js_engine == engine, 'Use one JS engine per syntax-analysis plan')
                js_engine = engine
                require(definition.get('emitter') in ('selfhost', 'upstream'),
                        'JS diagnostics require explicit emitter=selfhost|upstream')
                js_entries.append(dict(id=case['id'], role=role, family=definition['emitter'],
                                       path=artifact['file'], sourcePath=case['source']['file']))
                if args.kind != 'static':
                    for kind in (['cpu', 'allocation'] if args.kind == 'all' else [args.kind]):
                        stem = case['id'] + '-' + role + '-' + kind
                        config = dict(case['point'], profileKind=kind, warmupCalls=3,
                                      warmupMs=PRESETS[args.budget]['warmupMs'], targetMs=1000,
                                      maxRepetitions=1000000)
                        config_path = out / (stem + '.config.json')
                        save(config_path, config, fresh=True)
                        jobs.append(dict(kind='js-' + kind, diagnosticOnly=True,
                                         command=[engine, '--stack-size=4096', '--max-old-space-size=1024',
                                                  str(HERE / 'js/profile.mjs'), artifact['file'], str(config_path),
                                                  str(out / (stem + '.receipt.json')), str(out / (stem + '.profile.json'))]))
            else:
                require(args.kind in ('cpu', 'static', 'all'),
                        'Native allocation events require an explicitly instrumented generic-profiler recipe')
                point = case['point']
                workload = native_workloads.setdefault(case['id'], dict(name=case['id'], timeoutSeconds=args.budget, variants=[]))
                workload['variants'].append(dict(name=role, command=[artifact['file'], '--threads', '1', '--gpu', 'off', '--',
                        str(point['repetitions']), str(point['warmups']), *map(str, point['runtimeArgs'])],
                        inputs=[case['source']['file'], *[p['file'] for p in case['products'][role].get('inputs', [])]],
                        stdout=dict(kind='prefix-integer-line', prefix=point['expectedStdout'] + str(point['warmups']) + '\n' + str(point['repetitions']) + '\n',
                                    evidence=case['expectedFile']['file']), stderr=str(empty)))
                if args.kind in ('static', 'all'):
                    product = case['products'][role]
                    require('generatedSource' in product, 'Native syntax inspection needs pinned generatedSource in product')
                    jobs.append(dict(kind='native-static', diagnosticOnly=True,
                        command=[sys.executable, '-B', str(HERE / 'inspect.py'), '--target', definition['target'],
                                 '--source', product['generatedSource']['file'], '--binary', artifact['file'],
                                 '--out', str(out / (case['id'] + '-' + role + '-inspection'))]))
    if js_entries:
        config = out / 'syntax.json'
        save(config, dict(entries=js_entries), fresh=True)
        jobs.insert(0, dict(kind='js-static', diagnosticOnly=True,
                            command=[js_engine, str(HERE / 'js/analyze.mjs'), str(config), str(out / 'js-syntax')]))
    if native_workloads and args.kind != 'static':
        require(args.sampler is not None, 'Native CPU profiling requires an explicitly built sampler')
        inputs.append(pin(args.sampler))
        profiler = HERE.parent / 'profiler'
        recipe, frozen, capture, comparison = (out / name for name in ('native-recipe.json', 'native-manifest.json', 'native-capture', 'native-comparison.json'))
        save(recipe, dict(cwd=manifest['cwd'], sampler=str(args.sampler.resolve()),
                         scope='Diagnostic native CPU profiles of the exact prepared benchmark products; not clean timing.',
                         inputs=[p['file'] for p in manifest['inputs']], workloads=list(native_workloads.values())), fresh=True)
        jobs.extend([
            dict(kind='native-freeze', diagnosticOnly=True,
                 command=[sys.executable, '-B', str(profiler / 'freeze.py'), '--recipe', str(recipe), '--out', str(frozen)]),
            dict(kind='native-sample', diagnosticOnly=True,
                 command=[sys.executable, '-B', str(profiler / 'run.py'), '--manifest', str(frozen), '--out', str(capture),
                          '--modes', 'sample', '--rounds', '2', '--periods-us', '8000,13000']),
            dict(kind='native-compare', diagnosticOnly=True,
                 command=[sys.executable, '-B', str(profiler / 'compare.py'), '--report', str(capture / 'report.json'), '--out', str(comparison)]),
            dict(kind='native-render', diagnosticOnly=True,
                 command=[sys.executable, '-B', str(profiler / 'render.py'), '--comparison', str(comparison), '--out', str(out / 'native-profile.md')]),
        ])
    result = dict(schema='bend-benchmark-diagnostics-plan-v1', complete=True, targetsRun=False,
                  diagnosticBudgetSeconds=args.budget, inputs=inputs, jobs=jobs,
                  execution='Run jobs in order under ONE outer guard with this separate total deadline; no job is a speed measurement.',
                  nativeScope='Existing generic profiler main-thread coverage gate applies; runtime-event/ownership instrumentation remains an explicit profiler workflow.')
    save(out / 'jobs.json', result, fresh=True)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--manifest', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--kind', choices=('static', 'cpu', 'allocation', 'all'), default='all')
    parser.add_argument('--budget', type=int, choices=PRESETS, default=60)
    parser.add_argument('--set', choices=('fast', 'core', 'broad', 'full'))
    parser.add_argument('--cases')
    parser.add_argument('--sampler', type=Path)
    result = prepare(parser.parse_args())
    print(json.dumps(dict(targetsRun=False, jobs=len(result['jobs']))))


if __name__ == '__main__':
    main()
