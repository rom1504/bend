#!/usr/bin/env python3
"""Prepare native45 profiler jobs and optional retained-object diagnostic relinks.

Runs no compiler, target or profiler. Execute jobs.json serially under one guard.
Counts are explicit so enough CPU samples can be collected without changing an
input point. Sampling, clean clocks and runtime events remain separate modes.
"""
import argparse
import importlib.util
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('runtime_loop', HERE / 'runtime-loop.py')
L = importlib.util.module_from_spec(spec)
spec.loader.exec_module(L)
B, ROOT = L.B, L.ROOT
PROF = ROOT / 'selfhost/tools/profiler'


def prepare(a):
    document = L.load(a.manifest)
    B.require(a.role in document['roles'], 'Unknown role')
    target = document['roles'][a.role]['target']
    B.require(not a.instrument or target in ('qbe', 'x86'), 'Runtime hooks support QBE/x86 only')
    sampler = B.read(a.sampler.parent / 'report.json')
    B.require(sampler['complete'] and sampler['sampler'] == B.pin(a.sampler), 'Sampler receipt mismatch')
    B.require(not a.instrument or sampler['samplerScope'] == 'main_thread', 'Contexts need main-thread sampler')
    cases = {c['id']: c for c in document['cases']}
    B.require(len({n for n, _ in a.case}) == len(a.case), 'Duplicate case')
    out = L.fresh_output(a.out, ROOT)
    empty = out / 'empty.stderr'
    empty.write_bytes(b'')
    jobs, workloads, owner_maps = [], [], {}
    inputs = [B.pin(a.manifest), B.pin(__file__), B.pin(HERE / 'runtime-loop.py'),
              B.pin(a.sampler.parent / 'report.json')]

    def job(name, tool, *args):
        jobs.append(dict(name=name, command=[sys.executable, '-B', str(PROF / tool), *map(str, args)]))

    runtime = None
    if a.instrument:
        runtime = B.read(a.runtime_report)
        B.require(runtime.get('complete') and runtime.get('kind') == 'bend-runtime-build'
                  and not runtime.get('changedInputs'), 'Completed runtime source/object receipt required')
        for pin in [runtime['source'], *runtime['headers'], runtime['compiler'], runtime['object']]:
            B.verify(pin)
        inputs.append(B.pin(a.runtime_report))

    for name, raw_count in a.case:
        count = int(raw_count)
        B.require(name in cases and 0 < count <= L.MAX_COUNT, 'Invalid case/count')
        case = cases[name]
        product = case['products'][a.role]
        point = case['point']
        suffix = [*B.native_runtime_arguments(product), str(count), str(point['warmups']), *map(str, point['runtimeArgs'])]
        oracle = dict(kind='prefix-integer-line',
            prefix=point['expectedStdout'] + str(point['warmups']) + '\n' + str(count) + '\n',
            evidence=case['expectedFile']['file'])
        variant = dict(name=a.role, command=[product['artifact']['file'], *suffix],
            runtimeArgumentConvention=product['runtimeArgumentConvention'],
            inputs=[case['source']['file'], *[p['file'] for p in product.get('inputs', [])]],
            stdout=oracle, stderr=str(empty))
        variants = [variant]
        owner_maps[name] = {}
        build = None
        if target in ('qbe', 'x86'):
            build_path = Path(product['artifact']['file']).parent / 'report.json'
            build = B.read(build_path)
            B.require(build.get('complete') and build.get('kind') == 'bend-native-build'
                      and not build.get('changedInputs') and build['target'] == target
                      and build['binary'] == product['artifact'], 'Exact native construction receipt required')
            generated = product['generatedSource']['file']
            owner = out / (name + '-owners.json')
            options = ['--qbe' if target == 'qbe' else '--assembly', generated, '--output', owner]
            if target == 'x86':
                options += ['--build-receipt', build_path]
            # Current maintained emitters may be undergoing edits. Omit their
            # pins: this is an explicitly conditional lexical map, not a claim
            # that today's emitter produced an old retained executable.
            job(name + '-owners', 'owners.py', *options)
            owner_maps[name][a.role] = str(owner)
        if a.instrument:
            B.require(all(build['runtime'][k] == runtime['object'][k] for k in ('bytes', 'sha256')),
                      'Runtime source receipt does not bind this program runtime object')
            B.verify(build['object'])
            prepared = out / (name + '-diagnostic')
            runtime_manifest = out / (name + '-runtime.json')
            B.save(runtime_manifest, dict(runtime=runtime['source'], headers=runtime['headers'],
                runtimeArgumentConvention=product['runtimeArgumentConvention'],
                compiler=runtime['compiler']['file'], linker=runtime['compiler']['file'],
                compileFlags=runtime['command'][1:runtime['command'].index('-c')],
                programObject=build['object']), fresh=True)
            job(name + '-runtime-plan', 'runtime.py', '--manifest', runtime_manifest, '--out', prepared)
            job(name + '-runtime-build', 'build-runtime.py', '--plan', prepared / 'plan.json',
                '--out', out / (name + '-diagnostic-build'))
            diagnostic_name = a.role + '-diagnostic'
            variants.append(dict(variant, name=diagnostic_name,
                command=[str(prepared / 'program'), *suffix], dispatchInstrumentation=True,
                inputs=[*variant['inputs'], str(runtime_manifest), str(prepared / 'plan.json'),
                        str(out / (name + '-diagnostic-build/report.json'))]))
            # An x86 receipt binds the original ELF, so a diagnostic relink uses
            # an unreceipted owner map with its retained-object provenance explicit.
            if target == 'x86':
                diagnostic_owner = out / (name + '-diagnostic-owners.json')
                options = [v for v in options]
                at = options.index('--build-receipt')
                del options[at:at + 2]
                options[options.index('--output') + 1] = diagnostic_owner
                job(name + '-diagnostic-owners', 'owners.py', *options)
                owner_maps[name][diagnostic_name] = str(diagnostic_owner)
            else:
                owner_maps[name][diagnostic_name] = str(owner)
        workloads.append(dict(name=name, timeoutSeconds=30, variants=variants))
    recipe = out / 'recipe.json'
    B.save(recipe, dict(cwd=document['cwd'], sampler=str(a.sampler.resolve()),
        scope='Exact native45 inputs; repeated diagnostic CPU and runtime events; no clean benchmark ratios.',
        inputs=[p['file'] for p in inputs], workloads=workloads), fresh=True)
    manifest, capture = out / 'manifest.json', out / 'capture'
    job('freeze', 'freeze.py', '--recipe', recipe, '--out', manifest)
    job('capture', 'run.py', '--manifest', manifest, '--out', capture,
        '--modes', a.modes or ('clean,sample,events' if a.instrument else 'clean,sample'),
        '--rounds', 1, '--periods-us', a.periods_us)
    compare = ['--report', capture / 'report.json', '--out', out / 'comparison.json']
    if a.instrument:
        compare += ['--baseline', a.role + '-diagnostic=' + a.role]
    job('compare', 'compare.py', *compare)
    job('render', 'render.py', '--comparison', out / 'comparison.json', '--out', out / 'summary.md')
    B.save(out / 'jobs.json', dict(targetsRun=False, jobs=jobs, ownerMaps=owner_maps,
        scope='Execute jobs serially inside one outer guard; never nest guards.',
        attribution='For each sample: attribute.py --analysis ROW.analysis.file --owners ownerMaps[workload][variant] '
                    '[--contexts ROW.contexts.file] --summary-only --out FRESH. '
                    'Events: --events ROW.events.file --binary VARIANT.command[0] --owners MAP --out FRESH.'), fresh=True)
    return dict(targetsRun=False, jobs=str(out / 'jobs.json'), count=len(jobs))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--manifest', type=Path, required=True)
    p.add_argument('--role', required=True)
    p.add_argument('--case', nargs=2, action='append', required=True, metavar=('ID', 'REPETITIONS'))
    p.add_argument('--sampler', type=Path, default=ROOT / 'selfhost/build/phase183/profile-controls01/sampler/sampler.so')
    p.add_argument('--runtime-report', type=Path, default=ROOT / 'selfhost/build/phase182/runtime-build02/report.json')
    p.add_argument('--instrument', action='store_true')
    p.add_argument('--modes', help='Explicit maintained profiler modes; sample for a first screen')
    p.add_argument('--periods-us', default='8000,13000')
    p.add_argument('--out', type=Path, required=True)
    print(__import__('json').dumps(prepare(p.parse_args())))


if __name__ == '__main__':
    main()
