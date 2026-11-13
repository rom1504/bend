#!/usr/bin/env python3
"""Freeze exact retained C/QBE and Phase191 N2 baseline runtime products."""
import argparse
import copy
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path[:0] = [str(ROOT/'selfhost/tools/bench'), str(ROOT/'selfhost/tools/build')]
import bench as B
import common as C

PINS = [('selfhost/build/phase191/references01/manifest.json', 369210, 'b53a5c51df3a9497313ba2dd81d7db6a0c734926c20cebde2ae5b8042ef551a2'), ('selfhost/build/phase191/native45-02/report.json', 142489, '664b69cefc02d9f5dc9205385f2c34a295d137fdcec0faf1550d08ff5007e0da'), ('selfhost/build/phase191/native45-02/programs.manifest.json', 1593718, '2ad258a853579234478476ee9db6634adfb1916d5c4c120b3b055b438862119c')]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    pins = [dict(file=str(ROOT/p), bytes=n, sha256=h) for p, n, h in PINS]
    references, acquisition, native = [json.loads(C.verify(p).read_text()) for p in pins]
    C.require(acquisition.get('complete') and not acquisition.get('changedInputs')
              and not acquisition.get('error'), 'Incomplete Phase191 baseline acquisition')
    catalog = ROOT/'selfhost/tools/bench/catalogs/native45/catalog.json'
    known = {c['id']: c for c in B.catalog(catalog)['cases']}
    old = {c['id']: c for c in references['cases']}
    new = {c['id']: c for c in native['cases']}
    rows = {c['id']: c for c in acquisition['rows']}
    C.require(set(known) == set(old) == set(new) == set(rows), 'Catalog identity mismatch')
    roles = {}
    for alias, source_alias in [('c', 'c'), ('qbe', 'qbe'), ('prior-x86', 'baseline')]:
        roles[alias] = copy.deepcopy(references['roles'][source_alias])
        roles[alias]['inputs'] += [pins[0], C.pin(__file__)]
    roles['baseline'] = dict(host='native', stage='N2', target='x86', emit='object',
        policy='ordinary-single-cpu', preparation='cache', emitter='selfhost',
        status='retained-executable-for-fresh-runtime', inputs=[*pins[1:], C.pin(__file__)])
    cases = []
    for name, case in known.items():
        for original in [old[name], new[name]]:
            C.require(original['source'] == case['source'] and
                      original['expectedFile'] == case['expectedFile'] and
                      all(original['point'][k] == case['point'][k] for k in
                          ['expectedStdout', 'runtimeArgs', 'ratioEligible']),
                      'Source/oracle mismatch: '+name)
        row = rows[name]
        C.require(row.get('complete') and row.get('status') == 'executed-independent-oracle-pass'
                  and row['source'] == case['source'] and row['expectedFile'] == case['expectedFile'],
                  'Missing baseline oracle: '+name)
        product = new[name]['products']['candidate']
        built = json.loads(C.verify(row['buildReceipt']).read_text())
        C.verify(row['oracleReceipt'])
        C.require(row['artifact'] == product['artifact'] == built['binary'] and
                  built.get('emissionFormat') == 'elf64-le-amd64-relocatable',
                  'Baseline product mismatch: '+name)
        products = {alias: copy.deepcopy(old[name]['products'][source_alias])
                    for alias, source_alias in [('c', 'c'), ('qbe', 'qbe'), ('prior-x86', 'baseline')]}
        products['baseline'] = dict(artifact=row['artifact'],
            runtimeArgumentConvention=built['runtimeArgumentConvention'],
            inputs=[*pins[1:], row['buildReceipt'], row['oracleReceipt']])
        for item in products.values():
            C.verify(item['artifact'])
            for pin in item.get('inputs', []):
                C.verify(pin)
        cases.append(dict(id=name, products=products))
    out = C.fresh_output(args.out, ROOT)
    recipe = dict(kind='programs', cwd=str(ROOT), catalog=str(catalog), reference='c',
        roles=roles, cases=cases,
        scope='Retained exact C, QBE, Phase188 prior-x86 and Phase191 N2 baseline executables. '
              'Fresh runtime observations only; no new compiler acquisition or qualification.')
    C.write_json(out/'recipe.json', recipe)
    B.freeze(out/'recipe.json', out/'manifest.json')
    C.write_json(out/'report.json', dict(kind='phase192-executable-references', complete=True,
        targetsRun=False, inputs=pins, manifest=C.pin(out/'manifest.json'), cases=list(known),
        scope=recipe['scope']))
    print('Reference runtime manifest:', out/'manifest.json')


if __name__ == '__main__':
    main()
