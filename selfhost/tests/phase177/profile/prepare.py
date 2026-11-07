#!/usr/bin/env python3
"""Phase177 retained-object profile preparation; only 'build' executes tools.

Reuse the maintained profiler, its stage observer, and its existing libc CFI
sampler receipt. No Bend source rewriting or compiler acquisition is performed.
"""
import argparse
import importlib.util
import json
from pathlib import Path
import subprocess
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
HERE = Path(__file__).resolve().parent
TOOLS = ROOT / 'selfhost/tools/profiler'
sys.path.insert(0, str(TOOLS))
from run import pin, verify
from freeze import freeze
import attribute
import owners
from stages_v1 import validate_spec

BUILD = ROOT / 'selfhost/build/phase177/front-base-native01/report.json'
SOURCE = ROOT / 'selfhost/build/phase177/front-base-source01/compiler.bend'
SAMPLER = ROOT / 'selfhost/build/phase161/profile-build03/sampler-base/report.json'
ORACLE = ROOT / 'selfhost/build/phase177/screen-batch01/subst/result/report.json'
BINDING = ROOT / 'selfhost/build/phase177/front-base-source01/base-binding.json'
ORDER = ['p88_cache_prepare', 'p175fp_plan', 'p175fp_loaded', 'p175fp_checked',
         'p175fp_reported', 'p175fp_owned', 'p175fp_entry', 'p175fp_context',
         'p175fp_annotated', 'p144o_prepare_annotated', 'p175fp_ordinary', 'p175fn_observe']
LABELS = ['Base preparation', 'parse and load', 'check and publication',
          'dependency report', 'ownership check', 'entry check', 'context',
          'reach and annotation', 'layout check', 'erasure and request',
          'request wrapping and clocks']


def read(path):
    return json.loads(Path(path).read_text())


def need(value, message):
    if not value:
        raise ValueError(message)


def same(a, b):
    return all(a[k] == b[k] for k in ('bytes', 'sha256'))


def save(path, data):
    with Path(path).open('x') as stream:
        json.dump(data, stream, indent=2)
        stream.write('\n')


def call_metadata(name, *args):
    need(name in ('runtime.py', 'stages-build-v1.py'), 'Metadata tool allowlist')
    subprocess.run([sys.executable, '-B', str(TOOLS / name), *map(str, args)],
                   check=True, timeout=60)


def prepare(out, products):
    need(not out.exists() and not products.exists(), 'Fresh prep/products required')
    build = read(BUILD)
    need(build['complete'] and not build['changedInputs'], 'Successful baseline build required')
    need(same(pin(SOURCE), build['request']['source']), 'Exact frontend source required')
    need(build['binary']['sha256'] == '42401166d9a2fa64d75d4172a96e9ad4fc0d82b90e601a9b75fcbd9b4bc44380',
         'Wrong Phase177 frontend baseline')
    for key in ('binary', 'object', 'runtime', 'retainedIR', 'assembly'):
        verify(build[key])
    need(same(build['retainedIR'], build['irDigest']), 'Retained QBE differs from emitted digest')
    emitter_source = verify(build['request']['imageMetadata']['sourceIdentity'])
    out.mkdir(parents=True)
    owner_map = owners.parse_qbe_owners(verify(build['retainedIR']), [emitter_source])
    save(out / 'owners.json', owner_map)
    _, _, binding = attribute.bind_owners(owner_map, verify(build['binary']))
    save(out / 'selected-elf.json', dict(complete=True, image=build['binary'], binding=binding))
    by_name = {r['decoded']: r for r in owner_map['fids']}
    markers = []
    for name in ORDER:
        row = by_name['$direct.' + name]
        need(row['role'] == 'direct_segment', 'Stage lacks direct dispatcher entry: ' + name)
        markers.append(dict(label=name, fid=row['fid'], symbol=row['symbol'], multiplicity='once'))
    sampler = read(SAMPLER)
    for item in sampler['inputs'] + sampler['snapshots']:
        verify(item)
    table = next(p for p in sampler['inputs'] if Path(p['file']).name == 'table.json')
    verify(read(table['file'])['object'])
    spec = dict(schema='bend-native-stage-spec-v1', ownerMap=pin(out / 'owners.json'),
        programObject=build['object'], unwindTable=table, markers=markers, requiredOrder=ORDER,
        intervals=[dict(label=label, begin=left, end=right)
                   for label, left, right in zip(LABELS, ORDER, ORDER[1:])] +
                  [dict(label='digest, output and exit hook', begin=ORDER[-1], end='@exit')],
        scope='Exact newly derived FIDs; successful request mode only. A small or medium exact-output stage-order gate is mandatory before a full capture. Startup before Base and work after the exit hook are outside these disjoint intervals.')
    validate_spec(spec, owner_map)
    save(out / 'spec.json', spec)
    assets_path = ROOT / 'selfhost/manifests/assets-runtime.json'
    assets = read(assets_path)
    recipe = assets['runtimeRecipes']['serial-rfc']
    def asset(name):
        row = dict(assets['assets'][name])
        row['file'] = str((ROOT / row['file']).resolve())
        verify(row)
        return row
    need(same(asset(recipe['expectedObject']), build['runtime']), 'Baseline runtime recipe differs')
    save(out / 'runtime-input.json', dict(runtime=asset(recipe['source']),
        headers=[asset(k) for k in recipe['headers']], compiler=asset(recipe['compiler'])['file'],
        linker=asset(recipe['compiler'])['file'], compileFlags=recipe['flags'], programObject=build['object']))
    call_metadata('runtime.py', '--manifest', out / 'runtime-input.json', '--out', out / 'base-runtime')
    call_metadata('stages-build-v1.py', '--spec', out / 'spec.json', '--runtime-plan', out / 'base-runtime/plan.json',
                  '--sampler-build', SAMPLER, '--out', out / 'stage-runtime')
    save(out / 'ready.json', dict(complete=True, targetsRun=False, method=pin(__file__),
        image=build['binary'], source=pin(SOURCE), imageBuild=pin(BUILD), assets=pin(assets_path),
        owners=pin(out / 'owners.json'), spec=pin(out / 'spec.json'), plan=pin(out / 'stage-runtime/plan.json'),
        ownershipLimit='Exact FID identities only unconditional. Lexical active owner is not inclusive cost, allocation origin, or full stack; unknown remains explicit. Historical libc-only CFI coverage, not the Phase171 runtime-caller table.'))
    # The historical relocation operation is metadata-only and is phase-agnostic.
    path = ROOT / 'experiments/phase171/tools/profile-v2.py'
    module_spec = importlib.util.spec_from_file_location('phase171_profile_paths', path)
    module = importlib.util.module_from_spec(module_spec)
    module_spec.loader.exec_module(module)
    module.relocate(out, products, out / 'build-plan.json')


def build(plan_path, out):
    """Root lane only, under the existing guard with both roots declared."""
    plan = read(plan_path)
    for item in plan['inputs'] + plan['outputs']:
        verify(item)
    products = Path(plan['productsDirectory'])
    need(products.is_absolute() and products.is_relative_to(ROOT / 'selfhost/build/phase177')
         and not products.exists(), 'Fresh Phase177 products root required')
    products.mkdir()
    subprocess.run([sys.executable, '-B', str(TOOLS / 'build-runtime.py'), '--plan', str(plan_path),
                    '--out', str(out)], check=True)


def manifests(prep, build_report, out):
    need(not out.exists(), 'Fresh manifests required')
    ready, plan, built = read(prep / 'ready.json'), read(prep / 'build-plan.json'), read(build_report)
    need(built['complete'] and same(built['plan'], pin(prep / 'build-plan.json'))
         and same(plan['originalPlan'], ready['plan']), 'Exact completed relink plan required')
    for key in ('method', 'image', 'source', 'imageBuild', 'assets', 'owners', 'spec', 'plan'):
        verify(ready[key])
    for item in plan['inputs'] + plan['outputs'] + built['products']:
        verify(item)
    products = {r['label']: r['product'] for r in built['jobs']}
    binary = verify(products['link-diagnostic'])
    sampler = verify(products['stage-ordinal-sampler'])
    _, _, binding = attribute.bind_owners(read(prep / 'owners.json'), binary)
    oracle, base = read(ORACLE), read(BINDING)
    need(oracle['complete'] and oracle['mode'] == 'request', 'Successful prior request observation required')
    out.mkdir(parents=True)
    save(out / 'diagnostic-elf.json', dict(complete=True, image=pin(binary), binding=binding,
                                        build=pin(build_report)))
    rows = [r for r in oracle['runs'] if r['role'] == 'baseline']
    need(len(rows) == 2, 'Expected frozen small and medium observations')
    for name, prior in zip(('small', 'medium'), rows):
        need(prior['outputExact'] and pin(prior['command'][0]) == ready['image'], 'Oracle baseline differs')
        for key in ('source', 'stdout', 'stderr'):
            verify(prior[key])
        command = list(prior['command'])
        need(command[1:8] == ['--threads', '1', '--gpu', 'off', '--', 'phase175-frontend', 'request'],
             'Wrong frozen frontend invocation')
        need(command[8:] == [prior['source']['file'], base['base']['file'], base['carrier']['file'], base['stamp']],
             'Frozen Base binding differs')
        command[0] = str(binary)
        recipe = dict(cwd=str(ROOT), sampler=str(sampler), unwindTable=read(prep / 'spec.json')['unwindTable']['file'],
            inputs=[str(prep / 'ready.json'), str(prep / 'spec.json'), str(prep / 'owners.json'),
                    str(prep / 'build-plan.json'), str(build_report), str(out / 'diagnostic-elf.json'),
                    str(ORACLE), str(BINDING), str(HERE / 'adapter.py'), str(HERE / 'prepare.py')],
            scope='Same Phase177 retained object and runtime recipe. Exact prior supplementary stdout digest; stderr uses the unchanged native frontend integer timing-line grammar. Raw output retained. One diagnostic observation, not a clean timing or equivalence proof.',
            workloads=[dict(name=name, timeoutSeconds=60, variants=[dict(name='front-base-staged',
                command=command, dispatchInstrumentation=True,
                inputs=[prior['source']['file'], base['base']['file'], base['carrier']['file']],
                stdout=prior['stdout']['file'], stderr=prior['stderr']['file'])])])
        recipe_path = out / (name + '-recipe.json')
        save(recipe_path, recipe)
        manifest = freeze(recipe, recipe_path)
        # Explicit narrow adapter contract, never rewrite a target's stderr.
        manifest['workloads'][0]['variants'][0]['expected']['stderr'] = dict(
            kind='phase175-frontend-timing-line-v1', priorObservation=prior['stderr'],
            adapter=pin(HERE / 'adapter.py'))
        save(out / (name + '-manifest.json'), manifest)
    print(json.dumps(dict(complete=True, targetsRun=False, out=str(out))))


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('operation', choices=['prepare', 'build', 'manifests'])
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--products', type=Path)
    p.add_argument('--plan', type=Path)
    p.add_argument('--prep', type=Path)
    p.add_argument('--build-report', type=Path)
    a = p.parse_args()
    if a.operation == 'prepare':
        prepare(a.out.resolve(), a.products.resolve())
    elif a.operation == 'build':
        build(a.plan.resolve(), a.out.resolve())
    else:
        manifests(a.prep.resolve(), a.build_report.resolve(), a.out.resolve())
