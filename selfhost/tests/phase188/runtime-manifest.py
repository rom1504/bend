#!/usr/bin/env python3
"""Freeze already qualified paired native products; never run a compiler/program."""
import argparse
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path[:0] = [str(ROOT / 'selfhost/tools/bench'), str(ROOT / 'selfhost/tools/build')]
import bench as B
import common as C
import request

CATALOG = ROOT / 'selfhost/tools/bench/catalogs/native45/catalog.json'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    acquisition_pin = C.pin(args.report)
    acquired = B.read(args.report)
    C.require(acquired.get('kind') == 'phase188-native-object-catalog' and acquired.get('complete')
              and not acquired.get('error') and not acquired.get('changedInputs'),
              'Completed unchanged paired native catalog report required')
    C.require(acquired.get('roles') == ['object', 'reference'] and not acquired.get('retainedReference'),
              'Both roles must be freshly built and independently executed')
    catalog = B.catalog(CATALOG)
    known = {case['id']: case for case in catalog['cases']}
    selected = acquired['selected']
    C.require(selected and len(selected) == len(set(selected)) and all(name in known for name in selected),
              'Exact known unique selection required')
    C.require([row['id'] for row in acquired['rows']] == selected, 'Incomplete or reordered acquisition rows')
    if acquired.get('fullCatalog'):
        C.require(set(selected) == set(known), 'Full catalog acquisition omitted cases')
    inputs = B.unique_inputs([acquisition_pin, C.pin(__file__), C.pin(CATALOG),
                              C.pin(B.__file__), C.pin(C.__file__), C.pin(request.__file__),
                              *acquired['inputs']])
    roles, cases, identity = {}, [], None
    for row in acquired['rows']:
        case = known[row['id']]
        C.require(row.get('complete') and row['source'] == case['source']
                  and row['expectedFile'] == case['expectedFile']
                  and row['point'] == dict(case['point'], repetitions=1, warmups=0),
                  'Acquisition source/point/oracle differs from catalog')
        products, pair = {}, []
        for source_role, role in [('object', 'object'), ('reference', 'assembly')]:
            result = row['products'][source_role]
            C.require(result.get('complete') and result.get('status') == 'executed-independent-oracle-pass',
                      'Every product requires a fresh independent pass')
            built = B.read(C.verify(result['buildReceipt']))
            C.require(built.get('kind') == 'bend-native-build' and built.get('complete')
                      and not built.get('changedInputs') and built['binary'] == result['binary']
                      and built.get('target') == 'x86' and built.get('host') == 'native', 'Incomplete native build')
            req = built['request']
            C.require(req['source'] == case['source'], 'Build request source differs')
            is_object = source_role == 'object'
            C.require((built.get('emissionFormat') == request.X86_OBJECT_FORMAT) == is_object,
                      'Build emission route differs from role')
            C.require(any(job.get('label') == 'assemble' for job in built['jobs']) != is_object,
                      'Assembler usage differs from role')
            generated = built['object'] if is_object else built['assembly']
            C.verify(generated); C.verify(built['binary'])
            oracle = B.read(C.verify(result['oracleReceipt']))
            C.require(oracle.get('complete'), 'Incomplete oracle process')
            B.observation(C.verify(oracle['stdout']).read_bytes(), C.verify(oracle['stderr']).read_bytes(),
                          oracle['exitCode'], row['point'], oracle['seconds'])
            bound = B.unique_inputs([*inputs, *built['inputs'], result['buildReceipt'], result['oracleReceipt'],
                                     oracle['stdout'], oracle['stderr']])
            products[role] = dict(artifact=built['binary'], generatedSource=generated,
                                  runtimeArgumentConvention=built['runtimeArgumentConvention'],
                                  inputs=bound)
            role_identity = {key: req.get(key) for key in ('image', 'base', 'carrier', 'stamp', 'host', 'stage', 'mode')}
            role_identity.update(runtime=built['runtime'], runtimeABI=built.get('runtimeABI'),
                                 convention=built['runtimeArgumentConvention'])
            pair.append(role_identity)
            if role not in roles:
                roles[role] = dict(host=req['host'], stage=req['stage'], target='x86', preparation=req['mode'],
                                   policy='ordinary-single-cpu', status='finite-qualified-native-candidate',
                                   compiler=req['image'], runtime=built['runtime'], inputs=inputs,
                                   emissionFormat=request.X86_OBJECT_FORMAT if is_object else 'amd64-assembly',
                                   producerScope='Same actual native image, source, Base and runtime for both roles')
        C.require(pair[0] == pair[1], 'Paired products do not share producer/Base/runtime identity')
        if identity is None:
            identity = pair[0]
        C.require(pair[0] == identity, 'Producer/Base/runtime changed across catalog')
        cases.append(dict(id=row['id'], products=products))
    for item in inputs:
        C.verify(item)
    out = C.fresh_output(args.out, ROOT)
    recipe = dict(kind='programs', cwd=str(ROOT), catalog=str(CATALOG), reference='assembly',
                  roles=roles, cases=cases,
                  scope='Existing freshly qualified native products only; acquisition excluded. Same source/producer/Base/runtime; object encoding and GNU-as layout differ. No compilation or program execution by this converter.')
    C.write_json(out / 'recipe.json', recipe)
    manifest = B.freeze(out / 'recipe.json', out / 'manifest.json')
    C.verify(acquisition_pin)
    C.write_json(out / 'report.json', dict(kind='phase188-runtime-manifest', complete=True,
                 targetsRun=False, acquisition=acquisition_pin, producer=identity,
                 cases=selected, roles=['object', 'assembly'], recipe=C.pin(out / 'recipe.json'),
                 manifest=C.pin(out / 'manifest.json'), inputs=inputs))
    print(json.dumps(dict(complete=True, targetsRun=False, cases=len(manifest['cases']),
                         manifest=str(out / 'manifest.json'))))
    return 0


if __name__ == '__main__':
    sys.exit(main())
