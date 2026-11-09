#!/usr/bin/env python3
"""Acquire catalog products with explicit build assets, then freeze benchmark recipes.

Acquisition is serial, guarded and excluded from execution budgets. Compiler
algorithms stay in the maintained build entry or independent upstream reference.
"""
import argparse
import copy
import json
import os
from pathlib import Path
import sys
import subprocess
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / 'build'))
import assets
import common
import native
import request
import bench


def request_args(role, source, out, seconds, root):
    values = dict(workspace=root, assets=Path(role['assets']), image_key=role.get('imageKey'),
                  image=Path(role['image']) if role.get('image') else None,
                  image_receipt=Path(role['imageReceipt']) if role.get('imageReceipt') else None,
                  source=Path(source['file']), host=role['host'], target=role['target'],
                  stage=role['stage'], mode=role.get('mode', 'cache'),
                  base_key=role.get('baseKey', 'base'), carrier_key=role.get('carrierKey', 'prepared-base'),
                  engine_key=role.get('engineKey', 'bun'), out=out, seconds=seconds,
                  expected=None, plan=False)
    return argparse.Namespace(**values)


def prepare_role(role, root, base):
    role = copy.deepcopy(role)
    for key in ('assets', 'image', 'imageReceipt', 'executionEngine'):
        if role.get(key):
            role[key] = str((base / role[key]).resolve(strict=True))
    common.require(role.get('provider') in ('build', 'upstream'), 'Explicit build/upstream provider required')
    common.require(role.get('target') in ('js', 'c', 'qbe', 'x86'), 'Unknown target')
    for key in ('host', 'stage', 'policy', 'status'):
        common.require(isinstance(role.get(key), str) and role[key], 'Missing role dimension: '+key)
    document = assets.load_assets(Path(role['assets']), root)
    inputs = [document['_manifest']]
    if role['provider'] == 'upstream':
        common.require(role['target'] in ('js', 'c') and role['stage'] == 'upstream', 'Upstream emits JS/C only')
        bend, comp = assets.asset(document, 'upstream-bend'), assets.asset(document, 'upstream-comp')
        engine = assets.asset(document, role.get('engineKey', 'bun'))
        directory = Path(bend['file']).parent
        checkout = directory.parent
        revision = subprocess.check_output(['git', '-C', str(checkout), 'rev-parse', 'HEAD'], text=True, timeout=10).strip()
        dirty = subprocess.check_output(['git', '-C', str(checkout), 'diff', '--name-only', 'HEAD', '--', 'bend2'], text=True, timeout=10).strip()
        common.require(revision == document.get('upstream') and not dirty, 'Reference checkout differs from pinned upstream')
        base_pin = assets.asset(document, role.get('baseKey', 'base'))
        common.require(Path(base_pin['file']).resolve() == (directory / 'base.bend').resolve(), 'Reference Base differs from compiler checkout')
        inputs.append(base_pin)
        common.require(Path(comp['file']).parent == directory, 'Reference compiler paths differ')
        # Foreign providers and imported modules are part of the reference, too.
        sources = [common.pin(p) for p in sorted(directory.rglob('*'))
                   if p.is_file() and p.suffix in ('.ts', '.bend', '.js', '.c')]
        common.require(0 < len(sources) <= 512, 'Unbounded reference dependency set')
        inputs += [bend, comp, engine, *sources, common.pin(HERE / 'upstream.mjs')]
        role.update(bend=bend, comp=comp, engine=engine, referenceInputs=inputs)
    if role['target'] == 'js':
        common.require(role.get('executionEngine'), 'JS requires an explicit Node executionEngine')
        inputs.append(common.pin(role['executionEngine']))
    return role, document, inputs


def reference_plan(role, source):
    inputs = bench.unique_inputs([*role['referenceInputs'], source])
    return dict(kind='bend-benchmark-reference-request-v1', target=role['target'],
                source=source, bend=role['bend'], comp=role['comp'], engine=role['engine'], inputs=inputs)


def c_build(document, product, directory, root, seconds):
    policy = document.get('toolchains', {}).get('c')
    common.require(isinstance(policy, dict) and all(k in policy for k in ('compiler','flags','libraries')),
                   'Explicit C construction policy required')
    compiler = assets.asset(document, policy['compiler'])
    binary = directory / 'program'
    command = [compiler['file'], *policy['flags'], *policy.get('includeFlags', []),
               product['file'], '-o', str(binary), *policy['libraries']]
    result = common.run(command, cwd=root, stdout=directory / 'build.stdout',
                        stderr=directory / 'build.stderr', seconds=seconds)
    common.require(result['complete'] and binary.is_file(), 'C construction failed')
    receipt = dict(kind='bend-benchmark-c-construction', complete=True, source=product,
                   toolchain=policy, compiler=compiler, process=result, binary=common.pin(binary))
    common.write_json(directory / 'build.json', receipt)
    return receipt['binary'], [compiler, common.pin(directory / 'build.json')]


def replay_request(plan, inputs, spec_file):
    """Keep the actual child compiler command, without a timed Python wrapper."""
    command = list(plan['command'])
    if plan['outputContract'] != 'stdout':
        common.require(plan.get('imageMetadata', {}).get('protocol') == 'native-c-source-v1'
                       and plan.get('emittedFile', '').endswith('/program.1.c'), 'Unknown file-output protocol')
        prefix = plan['emittedFile'][:-4]
        common.require(command.count(prefix) == 1, 'Native C output prefix is not unique')
        parts = plan['runtimePreparation']['parts']
        for part in parts: common.verify(part)
        return dict(command=['{output}' if value == prefix else value for value in command],
                    inputs=[*inputs, *parts], stderrProtocol='native-c-source-v1', productSuffix='.1.c')
    if plan['host'] == 'js':
        common.require(len(command) >= 2 and command[-2] == '--report', 'Unknown hosted report argument contract')
        command[-1] = '{output}'
        inputs = [*inputs, common.pin(spec_file)]
    return dict(command=command, inputs=inputs)


def acquire_case(role, document, source, directory, root, seconds):
    directory.mkdir()
    deadline = time.monotonic() + seconds
    def remaining():
        value = deadline - time.monotonic(); common.require(value > 0, 'Case acquisition deadline exceeded'); return value
    if role['provider'] == 'upstream':
        plan = reference_plan(role, source)
        spec = directory / 'request.json'
        common.write_json(spec, plan)
        generated = directory / ('program.mjs' if role['target'] == 'js' else 'program.c')
        command = [role['engine']['file'], str(HERE / 'upstream.mjs'), str(spec), str(directory / 'emission.json')]
        child = common.run(command, cwd=root, stdout=generated, stderr=directory / 'emission.stderr', seconds=seconds)
        common.require(child['complete'] and child['stderr']['bytes'] == 0, 'Reference emission failed')
        emitted = bench.read(directory / 'emission.json')
        common.require(emitted.get('complete') and emitted.get('checked'), 'Reference was not checked')
        product = common.pin(generated)
        inputs = [*plan['inputs'], common.pin(spec), common.pin(directory / 'emission.json')]
        replay = dict(command=[*command[:-1], '{output}'], inputs=[*plan['inputs'], common.pin(spec)])
    else:
        args = request_args(role, source, directory / 'emission', seconds, root)
        plan = request.plan(args)
        if role['target'] == 'js':
            plan['operation'] = 'library'
        emitted = request.execute(args, plan)
        common.require(emitted['complete'], 'Maintained compiler emission failed: '+str(emitted.get('error')))
        product, inputs = emitted['product'], [*emitted['inputs'], common.pin(args.out / 'report.json')]
        if role['host'] == 'js':
            hosted = bench.read(args.out / 'hosted.json')
            inputs += [*hosted['inputs'], common.pin(args.out / 'hosted.json')]
        # Exact stdout protocols can be replayed without adding Python/hash work
        # inside the compiler clock. Native-C telemetry requires a separate clock contract.
        replay = replay_request(plan, inputs, args.out / 'request.json')
    generated = product
    convention = None
    if role['target'] in ('qbe', 'x86'):
        args = request_args(role, source, directory / 'machine', remaining(), root)
        args.ir, args.source, args.image, args.image_key = Path(product['file']), None, None, None
        args.runtime, args.runtime_key = None, role.get('runtimeKey', 'qbe-runtime')
        args.retain_ir, args.expected_stdout = True, None
        args.output_stage = None
        args.output_protocol = 'native-x86-source-v1' if role['target'] == 'x86' else 'qbe-source-v1'
        built = native.build(args)
        common.require(built['complete'], role['target'].upper()+' machine build failed: '+str(built.get('error')))
        product = built['binary']
        convention = built['runtimeArgumentConvention']
        inputs += [*built['inputs'], common.pin(args.out / 'report.json')]
    elif role['target'] == 'c':
        product, machine_inputs = c_build(document, product, directory, root, remaining())
        inputs += machine_inputs
        if role['provider'] == 'build' and emitted['request'].get('publicPackage'):
            convention = assets.runtime_argument_convention(dict(runtimeArgumentConvention=emitted['request']['imageMetadata'].get('targetRuntimeArgumentConvention','bend-legacy-v1')))
        else:
            key = 'upstream-comp' if role['provider'] == 'upstream' else document.get('providers', {}).get('c', {}).get('runtime')
            common.require(isinstance(key, str), 'Explicit C runtime provider required')
            convention = assets.runtime_argument_convention(assets.runtime_provider(document, key))
    metadata = {} if convention is None else dict(runtimeArgumentConvention=convention)
    return dict(artifact=product, generatedSource=generated, inputs=bench.unique_inputs(inputs), **metadata), replay


def validate_product(role, product, case, directory, root, seconds):
    if role['target'] == 'js':
        config = dict(case['point'], warmupCalls=0, warmupMs=0, calibrationMs=0, targetMs=1, maxRepetitions=1)
        common.write_json(directory / 'oracle-config.json', config)
        command = [role['executionEngine'], '--stack-size=4096', '--max-old-space-size=1024',
                   str(HERE / 'js/execute.mjs'), product['artifact']['file'],
                   str(directory / 'oracle-config.json'), str(directory / 'oracle.json')]
        child = common.run(command, cwd=root, stdout=directory / 'oracle.stdout', stderr=directory / 'oracle.stderr', seconds=seconds)
        common.require(child['complete'] and bench.read(directory / 'oracle.json').get('pass'), 'JS independent scalar oracle failed')
    else:
        point = dict(case['point'], repetitions=1, warmups=0)
        command = [product['artifact']['file'], *bench.native_runtime_arguments(product), '1', '0',
                   *map(str, point['runtimeArgs'])]
        child = common.run(command, cwd=root, stdout=directory / 'oracle.stdout', stderr=directory / 'oracle.stderr', seconds=seconds)
        common.require(child['complete'], 'Native independent oracle process failed')
        bench.observation(Path(child['stdout']['file']).read_bytes(), Path(child['stderr']['file']).read_bytes(),
                          child['exitCode'], point, child['seconds'])
    common.write_json(directory / 'oracle-process.json', child)
    product['inputs'].append(common.pin(directory / 'oracle-process.json'))


def execute(args):
    root = common.workspace(args.workspace)
    common.clean_environment(); common.timeout(args.seconds)
    spec_file = args.recipe.resolve(strict=True)
    spec = bench.read(spec_file)
    common.require(spec.get('kind') == 'bend-benchmark-acquisition-v1', 'Versioned acquisition recipe required')
    cat_file = (spec_file.parent / spec['catalog']).resolve(strict=True)
    cat = bench.catalog(cat_file)
    selected = bench.select(cat, args.budget, args.set, args.cases)
    common.require(spec['reference'] in spec['roles'], 'Missing reference role')
    prepared = {name: prepare_role(role, root, spec_file.parent) for name, role in spec['roles'].items()}
    common.require(all(bench.NAME.fullmatch(name) for name in prepared), 'Unsafe role name')
    common.require(all(('expected' in case['point']) == (role['target'] == 'js')
                       for role, _, _ in prepared.values() for case in selected), 'Catalog/target mismatch')
    out = args.out.resolve()
    report = dict(kind='bend-benchmark-acquisition', complete=False, inputs=[common.pin(__file__), common.pin(spec_file), common.pin(cat_file)],
                  roles=spec['roles'], selected=[case['id'] for case in selected], rows=[],
                  scope='Acquisition and one independent value/count check. Not timing, broad conformance, self-hosting or installed promotion.')
    for _, _, inputs in prepared.values():
        report['inputs'] += inputs
    # Authenticated preflight for every selected image/source, before creating output.
    for case in selected:
        for name, (role, _, _) in prepared.items():
            if role['provider'] == 'build':
                plan = request.plan(request_args(role, case['source'], out / case['id'] / name / 'emission', args.seconds, root))
                report['inputs'] += plan['inputs']
    report['inputs'] = bench.unique_inputs(report['inputs'])
    if args.plan:
        report['planOnly'] = True
        print(json.dumps(report, indent=2)); return 0
    common.require(args.guarded and sorted(os.sched_getaffinity(0)) == [args.cpu], 'One outer guarded CPU lane required')
    common.fresh_output(out, root)
    common.write_json(out / 'report.json', report)
    deadline = time.monotonic() + args.seconds
    def left():
        value = deadline - time.monotonic(); common.require(value > 0, 'Acquisition deadline exceeded'); return value
    recipe = dict(kind='programs', cwd=str(root), catalog=str(cat_file), reference=spec['reference'], roles={}, cases=[])
    compiler = dict(kind='compiler', cwd=str(root), reference=spec['reference'], roles={}, cases=[], sets=cat['sets'],
                    scope='Fresh child exact-output request, including engine startup/read/write. Golden emitted bytes admitted after independent catalog execution; OS caches not flushed.')
    empty = out / 'empty.stderr'; empty.write_bytes(b'')
    try:
        for name, (role, document, inputs) in prepared.items():
            entry = {key:role[key] for key in ('host', 'stage', 'target', 'policy', 'status')}
            entry.update(preparation=role.get('mode', 'live'), inputs=inputs)
            if role['target'] == 'js': entry['engine'] = common.pin(role['executionEngine'])
            entry['emitter'] = 'upstream' if role['provider'] == 'upstream' else 'selfhost'
            recipe['roles'][name] = entry; compiler['roles'][name] = dict(entry)
        for case in selected:
            (out / case['id']).mkdir()
            row, request_row = dict(id=case['id'], products={}), dict(id=case['id'], source=case['source'], requests={})
            report['rows'].append(dict(id=case['id'], complete=False))
            for name, (role, document, _) in prepared.items():
                directory = out / case['id'] / name
                product, replay = acquire_case(role, document, case['source'], directory, root, left())
                validate_product(role, product, case, directory, root, left())
                row['products'][name] = product
                if replay:
                    oracle = dict(product=product['generatedSource'], stdout=common.pin(empty)) if replay.get('stderrProtocol') else dict(stdout=product['generatedSource'], stderr=common.pin(empty))
                    request_row['requests'][name] = dict(replay, scope='request', **oracle)
            recipe['cases'].append(row)
            compiler['cases'].append(request_row)
            report['rows'][-1]['complete'] = True
            common.write_json(out / 'report.json', report)
        for pin in report['inputs']: common.verify(pin)
        common.write_json(out / 'programs.recipe.json', recipe)
        bench.freeze(out / 'programs.recipe.json', out / 'programs.manifest.json')
        report['programManifest'] = common.pin(out / 'programs.manifest.json')
        for row in recipe['roles'].values():
            row['inputs'] = bench.unique_inputs(row['inputs'])
        if all(set(row['requests']) == set(prepared) for row in compiler['cases']):
            common.write_json(out / 'compiler.recipe.json', compiler)
            bench.freeze(out / 'compiler.recipe.json', out / 'compiler.manifest.json')
            report['compilerManifest'] = common.pin(out / 'compiler.manifest.json')
        else:
            report['compilerManifestUnavailable'] = 'A selected output protocol has no exact cold replay contract; no Python wrapper clock substituted.'
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        report['changedInputs'] = common.changed_inputs(report['inputs'])
        if report['changedInputs']: report['complete'] = False
        common.write_json(out / 'report.json', report)
    print(json.dumps({k:report.get(k) for k in ('complete','programManifest','compilerManifest','compilerManifestUnavailable','error')}))
    return 0 if report['complete'] else 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--recipe', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--workspace', type=Path)
    parser.add_argument('--budget', type=int, choices=bench.PRESETS, default=20, help='Case-set selector only; acquisition has its own deadline')
    parser.add_argument('--set', choices=['fast','core','broad','full'])
    parser.add_argument('--cases')
    parser.add_argument('--seconds', type=float, default=600)
    parser.add_argument('--cpu', type=int, default=3)
    parser.add_argument('--guarded', action='store_true')
    parser.add_argument('--plan', action='store_true')
    return execute(parser.parse_args())


if __name__ == '__main__':
    sys.exit(main())
