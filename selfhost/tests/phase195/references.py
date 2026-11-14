#!/usr/bin/env python3
"""Freeze retained C/QBE and qualified Phase194 N2 products; run no targets."""
import argparse
import copy
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path[:0] = [str(ROOT/'selfhost/tools/bench'), str(ROOT/'selfhost/tools/build')]
import bench as B
import common as C


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


R = module('phase185_runtime', ROOT/'selfhost/tests/phase185/runtime-loop.py')
N = module('phase190_native_products', ROOT/'selfhost/tests/phase190/native-programs.py')
EVIDENCE = dict(file=str(ROOT/'implementation/phase194/evidence.json'), bytes=7290,
    sha256='9f167e5318ec0380bc3b4427fc9ff25e463bcb46b084f6452a6a9503da605ba4')
RETAINED = dict(file=str(ROOT/'selfhost/build/phase194/runtime-plan01/manifest.json'), bytes=3206662,
    sha256='959d5ec718a6163615880f493943a0cfcbfc6cdf4c61d683e98b59379c02c510')


def absolute(pin):
    return dict(pin, file=str((ROOT/pin['file']).resolve()))


def freeze(out):
    evidence = B.read(C.verify(EVIDENCE))
    C.require(evidence['complete'] and evidence['kind'] == 'phase194-qualified-evidence',
              'Qualified Phase194 evidence required')
    acquisition_pin = absolute(evidence['reports']['native45-02'])
    acquisition = B.read(C.verify(acquisition_pin))
    C.require(acquisition['complete'] and not acquisition.get('error') and not acquisition['changedInputs'],
              'Complete unchanged N2 catalog acquisition required')
    native_pin = acquisition['programManifest']
    native = R.load(C.verify(native_pin))
    retained = R.load(C.verify(RETAINED))
    compiler = absolute(evidence['artifacts']['native-self01/program'])
    source = absolute(evidence['artifacts']['selected-source02/compiler.bend'])
    role = native['roles']['candidate']
    C.require(role == acquisition['roles']['candidate'] and role['stage'] == 'N2'
              and role['target'] == 'x86' and role['emit'] == 'object'
              and role['compiler'] == compiler and role['compilerSource'] == source,
              'Qualified compiler/source binding differs')
    C.verify(compiler)
    C.verify(source)
    known = {case['id']: case for case in B.catalog(R.CATALOG)['cases']}
    old = {case['id']: case for case in retained['cases']}
    new = {case['id']: case for case in native['cases']}
    rows = {row['id']: row for row in acquisition['rows']}
    C.require(len(known) == len(retained['cases']) == len(native['cases']) == len(acquisition['rows']) == 45
              and set(known) == set(old) == set(new) == set(rows), 'Exact unique native45 coverage required')
    pins = [EVIDENCE, RETAINED, acquisition_pin, native_pin, C.pin(__file__), C.pin(R.__file__), C.pin(N.__file__)]
    roles = {alias: copy.deepcopy(retained['roles'][alias]) for alias in ('c', 'qbe')}
    roles['baseline'] = copy.deepcopy(role)
    for item in roles.values():
        item['inputs'] = B.unique_inputs([*item.get('inputs', []), *pins])
    cases = []
    for name, case in known.items():
        row, product = rows[name], new[name]['products']['candidate']
        C.require(row['complete'] and row['status'] == 'executed-independent-oracle-pass'
                  and row['source'] == case['source'] and row['expectedFile'] == case['expectedFile'],
                  'Independent oracle binding differs: '+name)
        built = B.read(C.verify(row['buildReceipt']))
        obj = N.validate_build(built, case, acquisition['preflight'], role['runtime'])
        C.require(row['artifact'] == product['artifact'] == built['binary'] and row['object'] == obj,
                  'N2 object/executable identity differs: '+name)
        oracle = B.read(C.verify(row['oracleReceipt']))
        point = dict(case['point'], repetitions=1, warmups=0)
        expected = [product['artifact']['file'], *B.native_runtime_arguments(product),
                    '1', '0', *map(str, point['runtimeArgs'])]
        C.require(oracle['complete'] and oracle['exitCode'] == 0 and not oracle['timedOut']
                  and oracle['command'] == expected, 'Independent oracle command/outcome differs: '+name)
        B.observation(C.verify(oracle['stdout']).read_bytes(), C.verify(oracle['stderr']).read_bytes(),
                      oracle['exitCode'], point, oracle['seconds'])
        products = {alias: copy.deepcopy(old[name]['products'][alias]) for alias in ('c', 'qbe')}
        products['baseline'] = copy.deepcopy(product)
        cases.append(dict(id=name, products=products))
    for pin in pins:
        C.verify(pin)
    output = C.fresh_output(out, ROOT)
    recipe = dict(kind='programs', cwd=str(ROOT), catalog=str(R.CATALOG), reference='c', roles=roles, cases=cases,
        scope='Exact retained C/QBE and qualified Phase194 N2 baseline products for fresh Phase194 timings. No new target execution or qualification.')
    C.write_json(output/'recipe.json', recipe)
    B.freeze(output/'recipe.json', output/'manifest.json')
    report = dict(kind='phase194-executable-references', complete=True, programsExecuted=False,
        inputs=pins, manifest=C.pin(output/'manifest.json'), caseCount=45, independentOraclesRevalidated=45,
        baselineCompiler=compiler, baselineSource=source, scope=recipe['scope'])
    C.write_json(output/'report.json', report)
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', required=True, type=Path)
    print(json.dumps(freeze(parser.parse_args().out)))
