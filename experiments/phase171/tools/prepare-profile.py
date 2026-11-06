#!/usr/bin/env python3
"""Phase171 metadata only: retained-object stage plan or post-build manifests."""
import argparse
import json
from pathlib import Path
import subprocess
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

CHAIN = ROOT / 'selfhost/build/phase170/native-chain-final'
IMAGE = ROOT / 'selfhost/dist/qbe/bend'
SOURCE = ROOT / 'selfhost/build/phase170/source-final/compiler.bend'
SAMPLER = ROOT / 'selfhost/build/phase161/profile-build03/sampler-base/report.json'


def read(path):
    return json.loads(Path(path).read_text())


def same(a, b):
    return all(a[k] == b[k] for k in ('bytes', 'sha256'))


def save(path, value):
    with Path(path).open('x') as stream:
        json.dump(value, stream, separators=(',', ':'))
        stream.write('\n')


def metadata_tool(name, *args):
    # Both named tools only materialize plans; no compiler/linker/target runs.
    assert name in ('runtime.py', 'stages-build-v1.py')
    subprocess.run([sys.executable, '-B', str(TOOLS/name), *map(str, args)], check=True, timeout=60)


def prepare(out):
    assert not out.exists()
    build = read(CHAIN/'n2/report.json')
    assert build['complete'] and not build['changedInputs']
    assert same(pin(IMAGE), build['binary']) and same(pin(SOURCE), build['imageBinding']['sourceIdentity'])
    assert same(pin(CHAIN/'n2/program.ssa'), build['irDigest'])
    verify(build['object']); verify(build['runtime'])
    out.mkdir(parents=True)
    owner_map = owners.parse_qbe_owners(CHAIN/'n2/program.ssa', [SOURCE])
    save(out/'owners.json', owner_map)
    _, linked, binding = attribute.bind_owners(owner_map, IMAGE)
    save(out/'selected-elf.json', dict(complete=True, image=pin(IMAGE), binding=binding, fids=len(linked)))
    order = [
        'p88_cache_prepare', 'p86_plan', 'p86_plan_loaded', 'p86_plan_checked',
        'p86_plan_reported', 'p86_plan_owned', 'p86_plan_context', 'p86_plan_annotated',
        'p144o_prepare_annotated', 'p169np_plan', 'p168_request_mode', 'p168_catalogued',
        'p168_prepared', 'p168_scanned', 'p168_seed_verified', 'p168_selected',
        'p113pl_candidates', 'p168_candidates', 'p168_closed', 'p169q_inlined',
        'p168_finish_functions', 'p169s_lowered', 'p169a_original', 'p169a_view',
        'p169a_checked', 'p169c_output', 'p169s_registered', 'p169s_print', 'p134w_drain']
    optional = ['p169q_closed', 'p169o_closed', 'p169np_admitted']
    by_name = {r['decoded']: r for r in owner_map['fids']}
    markers = []
    for name in order + optional:
        row = by_name['$direct.' + name]
        assert row['role'] == 'direct_segment'
        mode = 'optional' if name in optional else 'first' if name in ('p113pl_candidates', 'p134w_drain') else 'once'
        markers.append(dict(label=name, fid=row['fid'], symbol=row['symbol'], multiplicity=mode))
    sampler = read(SAMPLER)
    for row in sampler['inputs'] + sampler['snapshots']:
        verify(row)
    table = next(row for row in sampler['inputs'] if Path(row['file']).name == 'table.json')
    spec = dict(schema='bend-native-stage-spec-v1', ownerMap=pin(out/'owners.json'),
        programObject=build['object'], unwindTable=table, markers=markers, requiredOrder=order,
        intervals=[dict(label=a+' to '+b, begin=a, end=b) for a, b in zip(order, order[1:])] +
                  [dict(label='cursor rendering / output / exit hook', begin=order[-1], end='@exit')],
        scope='Source-derived successful ordinary-request boundary hypotheses. Fresh small-output/order gate required; no old FIDs reused. All intervals disjoint; startup before first marker and after-exit-hook work remain outside.')
    validate_spec(spec, owner_map)
    save(out/'spec.json', spec)
    assets = read(ROOT/'selfhost/manifests/assets-runtime.json')
    recipe = assets['runtimeRecipes']['serial-rfc']
    def asset(key):
        row = dict(assets['assets'][key], file=str(ROOT/assets['assets'][key]['file']))
        verify(row)
        return row
    assert same(asset(recipe['expectedObject']), build['runtime'])
    runtime = dict(runtime=asset(recipe['source']), headers=[asset(k) for k in recipe['headers']],
        compiler=asset(recipe['compiler'])['file'], linker=asset(recipe['compiler'])['file'],
        compileFlags=recipe['flags'], programObject=build['object'])
    save(out/'runtime-input.json', runtime)
    metadata_tool('runtime.py', '--manifest', out/'runtime-input.json', '--out', out/'base-runtime')
    metadata_tool('stages-build-v1.py', '--spec', out/'spec.json', '--runtime-plan', out/'base-runtime/plan.json',
                  '--sampler-build', SAMPLER, '--out', out/'stage-runtime')
    save(out/'ready.json', dict(complete=True, targetsRun=False, method=pin(__file__),
        image=pin(IMAGE), source=pin(SOURCE), imageBuild=pin(CHAIN/'n2/report.json'),
        owners=pin(out/'owners.json'), spec=pin(out/'spec.json'), plan=pin(out/'stage-runtime/plan.json'),
        ownershipLimit='Only exact FID identities are unconditional; invalid lexical groups remain unknown. Active dispatcher is not allocation origin or a complete stack.'))


def manifests(out, built):
    ready = read(out/'ready.json')
    for key in ('method', 'image', 'source', 'imageBuild', 'owners', 'spec', 'plan'):
        verify(ready[key])
    report = read(built)
    assert report['complete'] and same(report['plan'], ready['plan'])
    for product in report['products']:
        verify(product)
    binary, sampler = out/'stage-runtime/program', out/'stage-runtime/sampler.so'
    _, _, binding = attribute.bind_owners(read(out/'owners.json'), binary)
    save(out/'diagnostic-elf.json', dict(complete=True, image=pin(binary), binding=binding, build=pin(built)))
    spec = read(out/'spec.json')
    requests = dict(full=CHAIN/'q3/report.json',
        pilot=ROOT/'selfhost/build/phase170/qbe64-final/27-test-map-set-ops/emission/report.json')
    for name, request_file in requests.items():
        request = read(request_file)
        assert request['complete'] and not request['changedInputs'] and same(request['image'], ready['image'])
        verify(request['product']); verify(request['process']['stderr'])
        command = list(request['process']['command']); command[0] = str(binary)
        recipe = dict(cwd=str(ROOT), sampler=str(sampler), unwindTable=spec['unwindTable']['file'],
            inputs=[str(out/'ready.json'), str(out/'spec.json'), str(out/'owners.json'), str(built),
                    str(request_file), str(out/'stage-runtime/plan.json'), str(out/'diagnostic-elf.json')],
            scope='Retained-object diagnostic relink. Exact final selected-image output oracle; stages/physical leaves only, event counters disabled.',
            workloads=[dict(name=name, timeoutSeconds=300 if name=='full' else 45,
                variants=[dict(name='installed-n2-staged', command=command, dispatchInstrumentation=True,
                    inputs=[request[k]['file'] for k in ('source', 'base', 'preparedBase', 'imageRuntime')],
                    stdout=request['product']['file'], stderr=request['process']['stderr']['file'])])])
        save(out/(name+'-recipe.json'), recipe)
        save(out/(name+'-manifest.json'), freeze(recipe, out/(name+'-recipe.json')))
    print(json.dumps(dict(complete=True, targetsRun=False, manifests=[str(out/(n+'-manifest.json')) for n in requests])))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('operation', choices=['prepare', 'manifests'])
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--build-report', type=Path)
    args = parser.parse_args()
    if args.operation == 'prepare':
        prepare(args.out.resolve())
    else:
        assert args.build_report is not None
        manifests(args.out.resolve(), args.build_report.resolve())
