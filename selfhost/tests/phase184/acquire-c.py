#!/usr/bin/env python3
"""Acquire handwritten C and authenticate existing Bend products; one outer guard."""
import argparse
import copy
import json
import os
from pathlib import Path
import sys
import time
import traceback

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
BENCH = ROOT / 'selfhost/tools/bench'
BUILD = ROOT / 'selfhost/tools/build'
sys.path[:0] = [str(BENCH), str(BUILD)]
import assets
import bench
import common

DIRECT = BENCH / 'handwritten-c'
CATALOG = BENCH / 'catalogs/native45/catalog.json'
GROUPS = ('algorithms', 'numeric', 'render-symbolic', 'structures', 'text-map')
FLAGS = ['-std=c11', '-O3', '-ffp-contract=off', '-fno-lto']
PAIRS = [(0, 0), (1, 17), (3, 31)]
# The second argument is not universally a seed: mandelbrot-grid uses it as
# an iteration limit. Large words are admitted only for reviewed bounded work.
EDGE_PAIRS = {
    'algorithms/complete-generic-row.c': [(129, 17)],  # 128-slot masked access
    'structures/bst.c': [(3, 128), (3, 4294967295)],  # duplicate keys, wrapped seed
    'structures/local-pair.c': [(0, 4294967295), (1, 0)],  # b is ignored
    'numeric/numeric-recurrence.c': [(3, 96), (3, 97), (3, 4294967295)],
    'structures/closures.c': [(3, 4294967295)],
    'structures/list-pipeline.c': [(3, 4294967295)],
    'structures/expression.c': [(3, 4294967295)],
}
CHILD_SECONDS = 30
BEND_ROLES = {'bend-qbe': 'qbe', 'bend-c': 'c'}


def read(path):
    return json.loads(Path(path).read_text())


def differential_pairs(source):
    relative = Path(source).resolve().relative_to(DIRECT).as_posix()
    return [*PAIRS, *EDGE_PAIRS.get(relative, [])]


def original_catalog():
    catalog = bench.catalog(CATALOG)
    common.require(catalog.get('schema') == 'bend-benchmark-native-catalog-v1'
                   and len(catalog['cases']) == 45, 'Original native45 catalog required')
    return catalog


def mappings(catalog):
    known = {row['id'] for row in catalog['cases']}
    result, inputs = {}, []
    actual = {p.parent.name for p in DIRECT.glob('*/mapping.json')}
    common.require(actual == set(GROUPS), 'Exact five handwritten C mapping groups required')
    for group in GROUPS:
        path = DIRECT / group / 'mapping.json'
        inputs.append(common.pin(path))
        rows = read(path)
        common.require(isinstance(rows, list), 'Mapping must be a list')
        for row in rows:
            common.require(set(row) == {'id', 'source', 'result'}
                           and row['id'] in known and row['id'] not in result
                           and row['result'] in ('u32', 'text'), 'Invalid/duplicate C mapping')
            relative = Path(row['source'])
            common.require(not relative.is_absolute() and '..' not in relative.parts,
                           'C source must be a repository-relative path')
            source = common.pin(ROOT / relative)
            common.require(Path(source['file']).is_relative_to(DIRECT / group)
                           and Path(source['file']).suffix == '.c', 'C source escapes its group')
            result[row['id']] = dict(row, source=source)
            inputs.append(source)
    common.require(set(result) == known, 'All 45 original catalog IDs must have C mappings')
    for source in {row['source']['file'] for row in result.values()}:
        common.require(len({row['result'] for row in result.values()
                            if row['source']['file'] == source}) == 1,
                       'One C translation unit has conflicting result ABIs')
    inputs += [common.pin(path) for path in sorted(DIRECT.rglob('*.h'))]
    return result, bench.unique_inputs(inputs)


def validate_oracle(process, product, case):
    command = [product['artifact']['file'], *bench.native_runtime_arguments(product),
               '1', '0', *map(str, case['point']['runtimeArgs'])]
    common.require(process.get('complete') is True and process.get('command') == command
                   and not process.get('timedOut') and not process.get('error'),
                   'Bend independent oracle receipt differs from exact product/arguments')
    bench.observation(common.verify(process['stdout']).read_bytes(),
                      common.verify(process['stderr']).read_bytes(), process['exitCode'],
                      dict(case['point'], repetitions=1, warmups=0), process['seconds'])


def bend_product(product, case, target):
    """Require emission, machine construction and independently checked output."""
    inputs = bench.unique_inputs([product['artifact'], product['generatedSource'], *product['inputs']])
    receipts = []
    for item in product['inputs']:
        path = Path(item['file'])
        if path.name in ('report.json', 'build.json', 'oracle-process.json'):
            common.require(item['bytes'] <= 16 * 1024 * 1024, 'Oversized build/oracle receipt')
            receipts.append((item, read(path)))
    emitted = [(p, r) for p, r in receipts if r.get('kind') == 'bend-build-request'
               and r.get('source') == case['source'] and r.get('product') == product['generatedSource']]
    common.require(len(emitted) == 1, 'Exactly one matching maintained Bend emission receipt required')
    emission = emitted[0][1]
    common.require(emission.get('complete') is True and emission.get('target') == target
                   and not emission.get('changedInputs')
                   and emission.get('process', {}).get('complete') is True,
                   'Bend emission receipt is incomplete or changed')
    kind = 'bend-native-build' if target == 'qbe' else 'bend-benchmark-c-construction'
    built = [(p, r) for p, r in receipts if r.get('kind') == kind
             and r.get('binary') == product['artifact']]
    common.require(len(built) == 1, 'Exactly one matching Bend machine build receipt required')
    machine = built[0][1]
    common.require(machine.get('complete') is True and not machine.get('changedInputs'),
                   'Bend machine construction incomplete or changed')
    if target == 'qbe':
        common.require(machine.get('target') == 'qbe'
                       and machine.get('sourceIR') == product['generatedSource']
                       and machine.get('runtimeArgumentConvention') == product['runtimeArgumentConvention'],
                       'Bend QBE machine/runtime source binding differs')
    else:
        common.require(machine.get('source') == product['generatedSource']
                       and machine.get('process', {}).get('complete') is True,
                       'Bend C construction source/process binding differs')
    oracles = [(p, r) for p, r in receipts if Path(p['file']).name == 'oracle-process.json']
    common.require(len(oracles) == 1, 'Exactly one original Bend oracle receipt required')
    validate_oracle(oracles[0][1], product, case)
    for _, receipt in emitted + built:
        inputs += receipt.get('inputs', [])
        process = receipt.get('process', {})
        inputs += [process[key] for key in ('stdout', 'stderr') if key in process]
    inputs += [oracles[0][1][key] for key in ('stdout', 'stderr')]
    return dict(command=[product['artifact']['file'], *bench.native_runtime_arguments(product)],
                inputs=bench.unique_inputs(inputs), artifact=product['artifact'],
                emissionReceipt=emitted[0][0], buildReceipt=built[0][0], oracleReceipt=oracles[0][0],
                runtimeArgumentConvention=product['runtimeArgumentConvention'])


def bend_products(path, catalog, selected, upstream):
    manifest_pin = common.pin(path)
    manifest = read(path)
    common.require(manifest.get('schema') == 'bend-benchmark-manifest-v1'
                   and manifest.get('kind') == 'programs', 'Maintained programs.manifest.json required')
    common.require(Path(manifest['cwd']).resolve() == ROOT, 'Bend product workspace differs')
    acquisition_pin = common.pin(path.parent / 'report.json')
    acquisition = read(acquisition_pin['file'])
    common.require(acquisition.get('kind') == 'bend-benchmark-acquisition'
                   and acquisition.get('complete') is True and not acquisition.get('changedInputs')
                   and acquisition.get('programManifest') == manifest_pin,
                   'Complete maintained Bend acquisition receipt required')
    for name, target in BEND_ROLES.items():
        role = manifest['roles'].get(name, {})
        common.require(role.get('target') == target and role.get('emitter') == 'selfhost',
                       'Actual selfhost '+name+' product role required')
        authorities = []
        for item in role.get('inputs', []):
            if Path(item['file']).suffix == '.json' and item['bytes'] <= 16 * 1024 * 1024:
                authority = read(common.verify(item))
                if authority.get('kind') == 'bend-build-assets':
                    authorities.append(authority)
        common.require(authorities and all(row.get('complete') is True and row.get('upstream') == upstream
                                           for row in authorities), 'Bend role asset upstream differs: '+name)
    known = {row['id']: row for row in catalog['cases']}
    cases = {row['id']: row for row in manifest['cases']}
    common.require(len(cases) == len(manifest['cases']) and set(cases) <= set(known)
                   and set(selected) <= set(cases), 'Bend catalog cases missing, duplicated or unknown')
    common.require(set(acquisition['selected']) == set(cases)
                   and {row['id'] for row in acquisition['rows'] if row.get('complete') is True} == set(cases),
                   'Bend acquisition selected/completed case set differs')
    inputs = bench.unique_inputs([manifest_pin, acquisition_pin, *manifest['inputs'], *acquisition['inputs']])
    for item in inputs:
        common.verify(item)
    pins = {item['file']: item for item in inputs}
    results = {}
    for name, case in cases.items():
        for key in ('family', 'sourceGroup', 'source', 'expectedFile', 'point'):
            common.require(case.get(key) == known[name].get(key), 'Original catalog '+key+' differs: '+name)
        if name not in selected:
            continue
        roles = {}
        for role, target in BEND_ROLES.items():
            product = case['products'][role]
            for item in [product['artifact'], product['generatedSource'], *product['inputs']]:
                common.require(pins.get(item['file']) == item, 'Product input is outside frozen manifest closure')
            roles[role] = bend_product(product, case, target)
            inputs += roles[role]['inputs']
        results[name] = roles
    return results, bench.unique_inputs(inputs)


def differential_value(process):
    common.require(process.get('complete') is True and process.get('exitCode') == 0
                   and not process.get('timedOut') and not process.get('error'), 'Differential process failed')
    stdout = common.verify(process['stdout']).read_bytes()
    stderr = common.verify(process['stderr']).read_bytes()
    parts = stdout.rsplit(b'\n', 4)
    common.require(len(parts) == 5 and parts[1:3] == [b'0', b'0'] and parts[4] == b'',
                   'Differential Bend output lacks exact trailing zero/zero/elapsed lines')
    value = parts[0] + b'\n'
    bench.observation(stdout, stderr, process['exitCode'],
                      dict(expectedStdout=value.decode('utf8'), warmups=0, repetitions=0), process['seconds'])
    return value


def execute(args):
    common.clean_environment()
    common.timeout(args.seconds)
    common.require(args.guarded and args.cpu == 3 and sorted(os.sched_getaffinity(0)) == [3],
                   'One outer guarded CPU3 lane required')
    common.require('BENDRTS' not in os.environ, 'Ambient BENDRTS must be unset')
    out = common.fresh_output(args.out, ROOT)
    started = time.monotonic()
    report = dict(kind='phase184-direct-c-acquisition', version=1, complete=False, fullCatalog=False,
                  inputs=[], generatedInputs=[], jobs=[], cases=[], differential=[],
                  flags=FLAGS, differentialPairs=PAIRS, differentialEdgePairs=EDGE_PAIRS,
                  childLimitSeconds=CHILD_SECONDS, cpu=3, guarded=True,
                  invocation=[str(Path(__file__).resolve()), *sys.argv[1:]],
                  scope='Fresh C construction and independent complete-output checks; acquisition is not benchmark timing.')
    products = None

    def save():
        report['seconds'] = time.monotonic() - started
        common.write_json(out / 'report.json', report)

    def left():
        remaining = args.seconds - (time.monotonic() - started)
        if remaining <= 0:
            raise TimeoutError('Whole C acquisition deadline exceeded')
        return remaining

    def job(label, command):
        directory = out / ('job-'+str(len(report['jobs'])).zfill(4))
        directory.mkdir()
        row = dict(label=label, command=list(map(str, command)))
        report['jobs'].append(row)
        save()
        process = common.run(command, cwd=ROOT, stdout=directory / 'stdout',
                             stderr=directory / 'stderr', seconds=min(CHILD_SECONDS, left()))
        row['process'] = process
        common.write_json(directory / 'process.json', process)
        row['receipt'] = common.pin(directory / 'process.json')
        report['generatedInputs'].extend([row['receipt'], *[process[k] for k in ('stdout', 'stderr') if k in process]])
        save()
        if process.get('error', '').startswith('KeyboardInterrupt('):
            raise KeyboardInterrupt(label+' interrupted')
        common.require(process.get('complete') is True and process.get('exitCode') == 0
                       and not process.get('error') and not process.get('timedOut'), label+' failed')
        return process, row['receipt']

    save()
    try:
        document = assets.load_assets(args.assets, ROOT)
        policy = document.get('toolchains', {}).get('c', {})
        common.require(policy.get('compiler') == 'clang' and isinstance(policy.get('includeFlags', []), list),
                       'Explicit pinned clang C toolchain required')
        compiler = assets.asset(document, 'clang')
        include_flags = policy.get('includeFlags', [])
        common.require(all(isinstance(flag, str) for flag in include_flags), 'Invalid C include flags')
        report.update(compiler=compiler, includeFlags=include_flags, linkLibraries=['-lm'], upstream=document['upstream'])
        catalog = original_catalog()
        mapped, mapping_inputs = mappings(catalog)
        names = args.cases.split(',') if args.cases else [row['id'] for row in catalog['cases']]
        common.require(names and len(names) == len(set(names)) and set(names) <= set(mapped), 'Unknown/duplicate case selection')
        selected = [row for row in catalog['cases'] if row['id'] in names]
        report['selected'] = [row['id'] for row in selected]
        report['fullCatalog'] = len(selected) == 45
        driver = common.pin(DIRECT / 'driver.c')
        methods = [__file__, DIRECT / 'run.py', bench.__file__, common.__file__, assets.__file__,
                   BENCH / 'acquire.py', sys.executable, CATALOG]
        report['inputs'] = bench.unique_inputs([document['_manifest'], compiler, driver,
                          *mapping_inputs, *map(common.pin, methods),
                          *[pin for case in catalog['cases'] for pin in (case['source'], case['expectedFile'])]])
        bend, bend_inputs = bend_products(args.bend_products.resolve(strict=True), catalog, set(names), document['upstream'])
        report['inputs'] = bench.unique_inputs([*report['inputs'], *bend_inputs])
        for item in report['inputs']:
            common.verify(item)
        save()
        driver_dir = out / 'drivers'
        driver_dir.mkdir()
        driver_objects, driver_receipts = {}, {}
        for result in ('u32', 'text'):
            output = driver_dir / (result+'.o')
            defines = ['-DP184_TEXT_RESULT'] if result == 'text' else []
            _, receipt = job('compile-driver-'+result,
                             [compiler['file'], *FLAGS, *include_flags, *defines, '-c', driver['file'], '-o', output])
            driver_objects[result], driver_receipts[result] = common.pin(output), receipt
        kernels = {}
        source_names = sorted({mapped[case['id']]['source']['file'] for case in selected})
        for number, source in enumerate(source_names):
            representative = next(case for case in selected if mapped[case['id']]['source']['file'] == source)
            mapping = mapped[representative['id']]
            directory = out / ('kernel-'+str(number).zfill(2)+'-'+Path(source).stem)
            directory.mkdir()
            obj, binary = directory / 'kernel.o', directory / 'program'
            _, compile_receipt = job('compile-kernel-'+Path(source).stem,
                                     [compiler['file'], *FLAGS, *include_flags, '-c', source, '-o', obj])
            _, link_receipt = job('link-kernel-'+Path(source).stem,
                                  [compiler['file'], *FLAGS, *include_flags,
                                   driver_objects[mapping['result']]['file'], obj, '-lm', '-o', binary])
            construction = dict(kind='phase184-handwritten-c-construction', complete=True,
                                compiler=compiler, flags=FLAGS, includeFlags=include_flags, libraries=['-lm'],
                                source=mapping['source'], result=mapping['result'], driver=driver,
                                driverObject=driver_objects[mapping['result']], object=common.pin(obj),
                                binary=common.pin(binary), driverReceipt=driver_receipts[mapping['result']],
                                compileReceipt=compile_receipt, linkReceipt=link_receipt)
            common.write_json(directory / 'build.json', construction)
            receipt = common.pin(directory / 'build.json')
            kernels[source] = dict(binary=construction['binary'], receipt=receipt,
                                   inputs=[construction['binary'], construction['object'], construction['driverObject'],
                                           receipt, compile_receipt, link_receipt, construction['driverReceipt']])
            report['generatedInputs'] += kernels[source]['inputs']
            save()
        for case in selected:
            name = case['id']
            kernel = kernels[mapped[name]['source']['file']]
            binary = kernel['binary']['file']
            row = dict(id=name, complete=False, source=mapped[name]['source'], binary=kernel['binary'])
            report['cases'].append(row)
            process, receipt = job('catalog-value-'+name, [binary, '--value', *map(str, case['point']['runtimeArgs'])])
            row['valueReceipt'] = receipt
            common.require(common.verify(process['stderr']).read_bytes() == b''
                           and common.verify(process['stdout']).read_bytes() == case['point']['expectedStdout'].encode(),
                           'Handwritten C catalog value differs: '+name)
            process, receipt = job('catalog-observation-'+name,
                                   [binary, case['expectedFile']['file'], '1', '1', *map(str, case['point']['runtimeArgs'])])
            row['observationReceipt'] = receipt
            bench.observation(common.verify(process['stdout']).read_bytes(), common.verify(process['stderr']).read_bytes(),
                              process['exitCode'], dict(case['point'], repetitions=1, warmups=1), process['seconds'])
            row['complete'] = True
            save()
        for source in source_names:
            case = next(case for case in selected if mapped[case['id']]['source']['file'] == source)
            for a, b in differential_pairs(source):
                row = dict(source=common.pin(source), representative=case['id'], arguments=[a, b], complete=False, bend={})
                report['differential'].append(row)
                process, receipt = job('differential-c-'+case['id'], [kernels[source]['binary']['file'], '--value', str(a), str(b)])
                row['cReceipt'] = receipt
                common.require(common.verify(process['stderr']).read_bytes() == b'', 'Differential C stderr is nonempty')
                value = common.verify(process['stdout']).read_bytes()
                for role in BEND_ROLES:
                    process, receipt = job('differential-'+role+'-'+case['id'],
                                           [*bend[case['id']][role]['command'], '0', '0', str(a), str(b)])
                    actual = differential_value(process)
                    row['bend'][role] = dict(receipt=receipt, exact=actual == value)
                    save()
                    common.require(actual == value, 'Differential value differs: '+case['id']+' '+role+' '+str((a, b)))
                row['complete'] = True
                save()
        product_cases = []
        for case in selected:
            kernel = kernels[mapped[case['id']]['source']['file']]
            roles = copy.deepcopy(bend[case['id']])
            roles['handwritten-c'] = dict(command=[kernel['binary']['file'], case['expectedFile']['file']],
                                          inputs=bench.unique_inputs([*kernel['inputs'], case['expectedFile']]),
                                          result=mapped[case['id']]['result'])
            product_cases.append(dict(id=case['id'], family=case['family'], sourceGroup=case['sourceGroup'],
                                      point=copy.deepcopy(case['point']), roles=roles))
        products = dict(kind='phase184-direct-c-products', version=1, complete=True,
                        fullCatalog=report['fullCatalog'], reference='handwritten-c', cwd=str(ROOT),
                        cases=product_cases, inputs=bench.unique_inputs(report['inputs'] + report['generatedInputs']),
                        scope='All original45' if report['fullCatalog'] else 'Explicit selected pilot; not full45 qualification')
        report['complete'] = True
    except BaseException as error:
        report.update(error=repr(error), traceback=traceback.format_exc(),
                      interrupted=isinstance(error, KeyboardInterrupt))
    finally:
        report['changedInputs'] = common.changed_inputs(bench.unique_inputs(report['inputs'] + report['generatedInputs']))
        if report['changedInputs']:
            report['complete'] = False
        save()
        if products is not None:
            products['complete'] = report['complete']
            products['acquisition'] = common.pin(out / 'report.json')
            products['inputs'] = bench.unique_inputs(products['inputs'] + [products['acquisition']])
            common.write_json(out / 'products.json', products)
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--assets', type=Path, required=True)
    parser.add_argument('--bend-products', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--seconds', type=float, default=900)
    parser.add_argument('--guarded', action='store_true')
    parser.add_argument('--cpu', type=int, default=3)
    parser.add_argument('--cases', help='Explicit comma-separated pilot IDs; omitted requires all45')
    args = parser.parse_args()
    result = execute(args)
    print(json.dumps({k: result.get(k) for k in ('complete', 'fullCatalog', 'seconds', 'error')}))
    return 0 if result['complete'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
