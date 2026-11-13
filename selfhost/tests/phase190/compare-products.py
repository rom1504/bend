#!/usr/bin/env python3
"""Authenticate six development products across hosted/native producer routes.

Offline only: verifies recorded full-value/count observations, exact object
bytes, and linked .text/.data/.rodata. No executable or compiler is invoked.
"""
import argparse
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path[:0] = [str(ROOT / 'selfhost/tools/bench'), str(ROOT / 'selfhost/tools/build'),
               str(ROOT / 'selfhost/tests/phase188')]
import bench
import common
import product_compare
import request

CATALOG = ROOT / 'selfhost/tools/bench/catalogs/native45/catalog.json'
PARTITION = Path(__file__).with_name('cases.json')


class Evidence:
    def __init__(self):
        self.inputs = {}

    def verify(self, item):
        previous = self.inputs.get(item['file'])
        common.require(previous is None or previous == item, 'Conflicting evidence pin: ' + item['file'])
        if previous is None:
            common.verify(item)
            self.inputs[item['file']] = item
        return Path(item['file'])

    def read(self, item):
        common.require(item['bytes'] <= 32 * 1024 * 1024, 'Bounded JSON evidence required')
        return bench.read(self.verify(item))


def completed(value, label):
    common.require(value.get('complete') is True and not value.get('error')
                   and not value.get('changedInputs'), label + ' must be complete and unchanged')


def load_side(path, alias, evidence):
    identity = common.pin(path)
    manifest = evidence.read(identity)
    common.require(manifest.get('schema') == 'bend-benchmark-manifest-v1'
                   and manifest.get('kind') == 'programs' and alias in manifest.get('roles', {}),
                   'Frozen program manifest and role required')
    for item in manifest['inputs']:
        evidence.verify(item)
    role = manifest['roles'][alias]
    common.require(role.get('target') == 'x86' and role.get('emit') == 'object'
                   and role.get('host') in ('js', 'native'), 'Explicit hosted/native direct-object role required')
    for key in ('compiler', 'runtime'):
        evidence.verify(role[key])
    acquisition_pin = common.pin(Path(path).parent / 'report.json')
    acquisition = evidence.read(acquisition_pin)
    completed(acquisition, 'Program acquisition')
    common.require(acquisition.get('kind') == 'bend-benchmark-acquisition'
                   and acquisition.get('programManifest') == identity
                   and acquisition.get('roles', {}).get(alias) == role,
                   'Acquisition/manifest/role binding differs')
    rows = {row['id']: row for row in manifest['cases']}
    acquired = {row['id']: row for row in acquisition['rows']}
    common.require(len(rows) == len(manifest['cases']) and len(acquired) == len(acquisition['rows'])
                   and set(rows) == set(acquired), 'Duplicate or different acquisition case set')
    side = dict(identity=identity, manifest=manifest, role=role, alias=alias,
                acquisition=acquisition, acquisitionPin=acquisition_pin, rows=rows, acquired=acquired)
    if role['host'] == 'js':
        common.require(role.get('stage') == 'B1', 'Hosted route requires actual B1')
        emission = evidence.read(acquisition['emission'])
        completed(emission, 'Checked hosted emission')
        common.require(emission.get('kind') == 'phase190-checked-native-emission'
                       and emission.get('target') == 'x86' and emission.get('emit') == 'object',
                       'Checked typed hosted object emission required')
        authorities = []
        for item in emission['inputs']:
            if item['file'].endswith('/report.json') and item['bytes'] <= 1024 * 1024:
                candidate = evidence.read(item)
                if candidate.get('kind') == 'bend-checked-hosted-api':
                    authorities.append(candidate)
        common.require(len(authorities) == 1, 'Exactly one checked hosted producer required')
        authority = authorities[0]
        completed(authority, 'Hosted API acquisition')
        common.require(authority.get('checked') is True and authority.get('api') == role['compiler'],
                       'Hosted producer image differs')
        evidence.verify(authority['source'])
        preparation = evidence.read(emission['sourcePreparation']['receipt'])
        completed(preparation, 'Hosted source preparation')
        common.require(preparation.get('source') == authority['source'], 'Hosted source preparation differs')
        side.update(emission=emission, emitted={row['id']: row for row in emission['rows']},
                    producer=dict(host='js', stage='B1', image=authority['api'], source=authority['source']))
    else:
        binding_document = evidence.read(role['imageBinding'])
        completed(binding_document, 'Native image acquisition')
        binding = binding_document.get('imageBinding', binding_document)
        completed(binding, 'Native image binding')
        common.require(binding.get('kind') == 'bend-build-image-binding' and binding.get('host') == 'native'
                       and binding.get('stage') == role['stage'] and binding.get('image') == role['compiler']
                       and binding.get('sourceIdentity') == role['compilerSource']
                       and 'x86' in binding.get('targets', []), 'Native producer image/source/stage differs')
        evidence.verify(role['compilerSource'])
        side.update(binding=binding, producer=dict(host='native', stage=role['stage'],
                    image=role['compiler'], source=role['compilerSource']))
    return side


def authenticate_product(side, case, evidence):
    name = case['id']
    row, acquired = side['rows'][name], side['acquired'][name]
    completed(acquired, 'Case acquisition: ' + name)
    common.require(row['source'] == case['source'] and row['expectedFile'] == case['expectedFile']
                   and row['point'] == case['point'], 'Native45 source/oracle/point differs: ' + name)
    product = row['products'][side['alias']]
    for item in product['inputs']:
        evidence.verify(item)
    for item in (product['artifact'], product['generatedSource'], case['source'], case['expectedFile']):
        evidence.verify(item)
    common.require(Path(product['generatedSource']['file']).suffix == '.o', 'Direct object product required')
    common.require(acquired['buildReceipt'] in product['inputs'] and acquired['oracleReceipt'] in product['inputs'],
                   'Product lacks authenticated build/oracle receipts')
    built = evidence.read(acquired['buildReceipt'])
    completed(built, 'Machine construction: ' + name)
    common.require(built.get('target') == 'x86' and built.get('emissionFormat') == request.X86_OBJECT_FORMAT
                   and built.get('assemblerSkipped') is True
                   and not any(job.get('label') == 'assemble' for job in built['jobs'])
                   and built.get('binary') == product['artifact']
                   and product_compare.same(built['object'], product['generatedSource'])
                   and built.get('runtime') == side['role']['runtime'] and built.get('runtimeABI') == 11102
                   and built.get('runtimeArgumentConvention') == product['runtimeArgumentConvention'],
                   'Built object/binary/runtime contract differs: ' + name)
    evidence.verify(built['object'])
    if side['role']['host'] == 'js':
        emitted = side['emitted'][name]
        completed(emitted, 'Hosted emitted row: ' + name)
        common.require(emitted.get('verified') is True and emitted.get('sameTypedSequence') is True
                       and emitted['source'] == case['source'] and emitted['expectedFile'] == case['expectedFile']
                       and emitted['product'] == product['generatedSource']
                       and built.get('sourceObject') == emitted['product'], 'Hosted object provenance differs')
    else:
        producer = built.get('request', {})
        common.require(producer.get('host') == 'native' and producer.get('stage') == side['role']['stage']
                       and producer.get('target') == 'x86' and producer.get('emit') == 'object'
                       and producer.get('image') == side['role']['compiler']
                       and producer.get('imageMetadata') == side['binding'] and producer.get('source') == case['source'],
                       'Native object producer differs')
    observation = evidence.read(acquired['oracleReceipt'])
    completed(observation, 'Independent oracle process: ' + name)
    expected_command = [product['artifact']['file'], *bench.native_runtime_arguments(product),
                        '1', '0', *map(str, case['point']['runtimeArgs'])]
    common.require(observation.get('command') == expected_command, 'Oracle observed a different executable/request')
    stdout, stderr = evidence.verify(observation['stdout']), evidence.verify(observation['stderr'])
    point = dict(case['point'], repetitions=1, warmups=0)
    bench.observation(stdout.read_bytes(), stderr.read_bytes(), observation['exitCode'], point, observation['seconds'])
    return dict(object=product['generatedSource'], binary=product['artifact'],
                sections=product_compare.sections(product['artifact']), buildReceipt=acquired['buildReceipt'],
                oracleReceipt=acquired['oracleReceipt'])


def execute(args):
    evidence = Evidence()
    for file in (__file__, bench.__file__, common.__file__, product_compare.__file__, request.__file__, CATALOG, PARTITION):
        evidence.verify(common.pin(file))
    partition = bench.read(PARTITION)
    catalog_pin = common.pin(CATALOG)
    common.require(product_compare.same(partition['catalog'], catalog_pin), 'Frozen native45 catalog differs')
    names = partition['development']
    common.require(len(names) == len(set(names)) == 6, 'Exactly six frozen development cases required')
    known = {case['id']: case for case in bench.catalog(CATALOG)['cases']}
    out = common.fresh_output(args.out, ROOT)
    report = dict(kind='phase190-hosted-native-product-equivalence', version=1, complete=False,
        targetsRun=False, selected=names, rows=[],
        scope='Offline authentication of recorded independent native45 observations, exact emitted objects and linked .text/.data/.rodata for the six frozen development cases. No executable runs, held-out performance inspection or whole-compiler equivalence claim.')

    def save():
        report['inputs'] = list(evidence.inputs.values())
        common.write_json(out / 'report.json', report)

    save()
    try:
        left = load_side(args.left, args.left_role, evidence)
        right = load_side(args.right, args.right_role, evidence)
        common.require(left['role']['host'] == 'js' and right['role']['host'] == 'native',
                       'Comparison requires hosted left and actual native right')
        common.require(set(left['rows']) & set(right['rows']) == set(names), 'Manifest intersection must be all six development cases')
        common.require(left['role']['runtime'] == right['role']['runtime'], 'Paired target runtime differs')
        report.update(left=dict(manifest=left['identity'], role=args.left_role, producer=left['producer']),
                      right=dict(manifest=right['identity'], role=args.right_role, producer=right['producer']))
        save()
        for name in names:
            a = authenticate_product(left, known[name], evidence)
            b = authenticate_product(right, known[name], evidence)
            equal = {section: a['sections'][section] == b['sections'][section] for section in a['sections']}
            row = dict(id=name, source=known[name]['source'], expectedFile=known[name]['expectedFile'],
                left=a, right=b, objectIdentical=product_compare.same(a['object'], b['object']),
                linkedSectionsIdentical=equal, complete=False)
            report['rows'].append(row)
            save()
            common.require(row['objectIdentical'], 'Hosted/native direct object differs: ' + name)
            common.require(all(equal.values()), 'Hosted/native linked program sections differ: ' + name)
            row['complete'] = True
            save()
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        report['changedInputs'] = common.changed_inputs(list(evidence.inputs.values()))
        if report['changedInputs']:
            report['complete'] = False
        save()
    print(json.dumps({key: report.get(key) for key in ('complete', 'selected', 'error')}))
    return 0 if report['complete'] else 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--left', type=Path, required=True)
    parser.add_argument('--left-role', default='final')
    parser.add_argument('--right', type=Path, required=True)
    parser.add_argument('--right-role', default='candidate')
    parser.add_argument('--out', type=Path, required=True)
    return execute(parser.parse_args())


if __name__ == '__main__':
    sys.exit(main())
