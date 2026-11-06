#!/usr/bin/env python3
"""Metadata-only candidate profile setup; reuses frozen plan/build methods."""
import argparse
import copy
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
TOOLS = ROOT / 'selfhost/tools/profiler'
sys.path.insert(0, str(TOOLS))
from run import pin, verify
from freeze import freeze
import attribute
import owners
from stages_v1 import validate_spec


def module(name, file):
    spec = importlib.util.spec_from_file_location(name, file)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


OLD = module('phase171_frozen_prepare', Path(__file__).with_name('prepare-profile.py'))
RELOCATE = module('phase171_frozen_relocate', Path(__file__).with_name('profile-v2.py'))
read, save, same = OLD.read, OLD.save, OLD.same
BASELINE_SPEC = ROOT / 'selfhost/build/phase171/profile-prep01/spec.json'
BUILD = ROOT / 'selfhost/build/phase171/native-candidate01/report.json'
SOURCE = ROOT / 'selfhost/build/phase171/native-source01/compiler.bend'
COMPARISON = ROOT / 'selfhost/build/phase171/full-candidate01/report.json'
ORACLE = ROOT / 'selfhost/build/phase170/native-chain-final/q3/report.json'


def identities():
    build, comparison, oracle = read(BUILD), read(COMPARISON), read(ORACLE)
    for item in (build, comparison, oracle):
        assert item['complete'] and not item['changedInputs']
    image = verify(build['binary'])
    assert same(pin(SOURCE), build['imageBinding']['sourceIdentity'])
    assert same(pin(image), comparison['request']['image'])
    assert same(comparison['request']['source'], oracle['source'])
    assert same(comparison['request']['base'], oracle['base'])
    assert same(comparison['request']['carrier'], oracle['preparedBase'])
    assert same(comparison['irDigest'], oracle['product'])
    ir = BUILD.parent / 'program.ssa'
    assert same(pin(ir), build['irDigest'])
    for item in (build['object'], build['runtime'], oracle['product'], oracle['process']['stderr']):
        verify(item)
    return build, image, ir, oracle


def prepare(out, products):
    assert not out.exists() and not products.exists()
    build, image, ir, oracle = identities()
    out.mkdir(parents=True)
    owner_map = owners.parse_qbe_owners(ir, [SOURCE])
    save(out / 'owners.json', owner_map)
    _, linked, binding = attribute.bind_owners(owner_map, image)
    save(out / 'selected-elf.json', dict(complete=True, image=pin(image), binding=binding, fids=len(linked)))
    previous = read(BASELINE_SPEC)
    by_name = {row['decoded']: row for row in owner_map['fids']}
    spec = copy.deepcopy(previous)
    spec.update(ownerMap=pin(out / 'owners.json'), programObject=build['object'])
    for marker in spec['markers']:
        actual = by_name['$direct.' + marker['label']]
        assert actual['role'] == 'direct_segment'
        marker.update(fid=actual['fid'], symbol=actual['symbol'])
    verify(spec['unwindTable'])
    spec['scope'] = ('Same32 semantic labels and disjoint intervals as baseline; fresh candidate FIDs. '
                     'Compiler image source differs; measured workload is unchanged Phase170 S0. '
                     'New helper and moved-work attribution is not inferred from old lexical ownership.')
    validate_spec(spec, owner_map)
    save(out / 'spec.json', spec)
    assets = read(ROOT / 'selfhost/manifests/assets-runtime.json')
    recipe = assets['runtimeRecipes']['serial-rfc']
    def asset(key):
        value = dict(assets['assets'][key], file=str(ROOT / assets['assets'][key]['file']))
        verify(value)
        return value
    assert same(asset(recipe['expectedObject']), build['runtime'])
    runtime = dict(runtime=asset(recipe['source']), headers=[asset(k) for k in recipe['headers']],
        compiler=asset(recipe['compiler'])['file'], linker=asset(recipe['compiler'])['file'],
        compileFlags=recipe['flags'], programObject=build['object'])
    save(out / 'runtime-input.json', runtime)
    OLD.metadata_tool('runtime.py', '--manifest', out / 'runtime-input.json', '--out', out / 'base-runtime')
    OLD.metadata_tool('stages-build-v1.py', '--spec', out / 'spec.json', '--runtime-plan', out / 'base-runtime/plan.json',
        '--sampler-build', OLD.SAMPLER, '--out', out / 'stage-runtime')
    save(out / 'ready.json', dict(complete=True, targetsRun=False, method=pin(__file__),
        methods=[pin(OLD.__file__), pin(RELOCATE.__file__)], baselineSpec=pin(BASELINE_SPEC),
        image=pin(image), source=pin(SOURCE), imageBuild=pin(BUILD), comparison=pin(COMPARISON), oracle=pin(ORACLE),
        owners=pin(out / 'owners.json'), spec=pin(out / 'spec.json'), plan=pin(out / 'stage-runtime/plan.json'),
        ownershipLimit='Actual ELF/FIDs are bound; lexical owner remains conditional. No logical-stack or allocation-origin claim.'))
    RELOCATE.relocate(out, products, out / 'build-plan.json')
    print(json.dumps(dict(complete=True, targetsRun=False, prep=str(out), plan=str(out / 'build-plan.json'))))


def manifests(prep, built, output):
    assert not output.exists()
    build, image, ir, oracle = identities()
    ready, plan, report = read(prep / 'ready.json'), read(prep / 'build-plan.json'), read(built)
    assert report['complete'] and same(report['plan'], pin(prep / 'build-plan.json'))
    assert same(plan['originalPlan'], ready['plan']) and same(ready['image'], pin(image))
    for key in ('method', 'baselineSpec', 'image', 'source', 'imageBuild', 'comparison', 'oracle', 'owners', 'spec', 'plan'):
        verify(ready[key])
    for item in ready['methods'] + plan['inputs'] + plan['outputs'] + report['products']:
        verify(item)
    products = {row['label']: row['product'] for row in report['jobs']}
    assert set(products) == {'stage-ordinal-sampler', 'compile-runtime', 'link-diagnostic'}
    binary, sampler = verify(products['link-diagnostic']), verify(products['stage-ordinal-sampler'])
    assert binary == Path(plan['productsDirectory']) / 'program'
    assert sampler == Path(plan['productsDirectory']) / 'sampler.so'
    _, _, binding = attribute.bind_owners(read(prep / 'owners.json'), binary)
    output.mkdir(parents=True)
    save(output / 'diagnostic-elf.json', dict(complete=True, image=pin(binary), binding=binding, build=pin(built)))
    spec = read(prep / 'spec.json')
    command = list(oracle['process']['command']); command[0] = str(binary)
    recipe = dict(cwd=str(ROOT), sampler=str(sampler), unwindTable=spec['unwindTable']['file'],
        inputs=[str(prep / name) for name in ('ready.json', 'spec.json', 'owners.json', 'build-plan.json')] +
               [str(built), str(BUILD), str(COMPARISON), str(ORACLE), str(output / 'diagnostic-elf.json'), str(Path(__file__).resolve())],
        scope='Candidate retained object; identical original S0 source/Base/stamp and Q3 output oracle. Diagnostic32ms stage capture; no counters.',
        workloads=[dict(name='full', timeoutSeconds=300, variants=[dict(name='candidate-n1-staged',
            command=command, dispatchInstrumentation=True,
            inputs=[oracle[k]['file'] for k in ('source', 'base', 'preparedBase', 'imageRuntime')],
            stdout=oracle['product']['file'], stderr=oracle['process']['stderr']['file'])])])
    save(output / 'full-recipe.json', recipe)
    save(output / 'full-manifest.json', freeze(recipe, output / 'full-recipe.json'))
    print(json.dumps(dict(complete=True, targetsRun=False, manifest=str(output / 'full-manifest.json'))))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('operation', choices=('prepare', 'manifests'))
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--products', type=Path)
    parser.add_argument('--prep', type=Path)
    parser.add_argument('--build-report', type=Path)
    args = parser.parse_args()
    if args.operation == 'prepare':
        prepare(args.out.resolve(), args.products.resolve())
    else:
        manifests(args.prep.resolve(), args.build_report.resolve(), args.out.resolve())
