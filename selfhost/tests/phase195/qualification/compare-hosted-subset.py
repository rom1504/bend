#!/usr/bin/env python3
"""Offline six-product authentication, with exact source and shared-preparation gates."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


P = module('phase195_products', ROOT/'selfhost/tests/phase190/compare-products.py')
S = module('phase195_shared', ROOT/'selfhost/tests/phase195/prepared-emission/prepare.py')
C = P.common
SELECTED = ['local-pair', 'editdist', 'coverage-numeric-recurrence-256',
            'variation-ray-active-64-2440', 'tree-bitonic', 'lexer']
ROOTS = S.ROOTS + S.EMIT


def source_gate(path, evidence, native_source, hosted_source=None):
    receipt = C.pin(path)
    audit = evidence.read(receipt)
    P.completed(audit, 'Exact seven-root source audit')
    C.require(audit.get('sevenRoots') == ROOTS
              and audit.get('exactExecutableBodiesIdentical') is True
              and audit.get('selectedSource') == native_source,
              'Exact seven-root executable-body audit must bind this native source')
    if hosted_source is not None:
        C.require(audit.get('checkedApiSource') == hosted_source,
                  'Source audit must bind this checked hosted source')
    for key in ('selectedSource', 'checkedApiSource', 'checkedApiReceipt', 'method'):
        evidence.verify(audit[key])
    for item in audit.get('inputs', []):
        evidence.verify(item)
    authority = evidence.read(audit['checkedApiReceipt'])
    P.completed(authority, 'Source audit checked API')
    C.require(authority.get('checked') is True and authority['source'] == audit['checkedApiSource'],
              'Source audit checked authority differs')
    return receipt, audit



def generation_gate(side, evidence):
    receipt = side['role']['imageBinding']
    generation = evidence.read(receipt)
    P.completed(generation, 'Native image generation')
    stage = side['role']['stage']
    C.require(generation.get('kind') == 'bend-native-build'
              and generation.get('target') == ('qbe' if stage == 'N1' else 'x86')
              and generation.get('binary') == side['producer']['image']
              and generation.get('imageBinding') == side['binding']
              and generation['request']['source'] == side['producer']['source']
              and generation['request']['image'] == side['binding']['producer'],
              'Native generation receipt/source/producer binding differs')
    for item in generation['inputs']:
        evidence.verify(item)
    return receipt


def load_hosted(path, alias, evidence):
    # The historical shared-emission role omits emit. Establish it from the
    # authenticated emission, without rewriting any manifest or receipt.
    identity = C.pin(path)
    manifest = evidence.read(identity)
    C.require(manifest.get('schema') == 'bend-benchmark-manifest-v1'
              and manifest.get('kind') == 'programs' and alias in manifest['roles'],
              'Frozen hosted program manifest required')
    for item in manifest['inputs']:
        evidence.verify(item)
    role = manifest['roles'][alias]
    C.require(role.get('host') == 'js' and role.get('stage') == 'B1'
              and role.get('target') == 'x86' and role.get('emit', 'object') == 'object',
              'Hosted B1 direct-object role required')
    for key in ('compiler', 'runtime'):
        evidence.verify(role[key])
    acquisition_pin = C.pin(Path(path).parent/'report.json')
    acquisition = evidence.read(acquisition_pin)
    P.completed(acquisition, 'Hosted program acquisition')
    C.require(acquisition.get('kind') == 'bend-benchmark-acquisition'
              and acquisition.get('programManifest') == identity
              and acquisition['roles'].get(alias) == role, 'Hosted acquisition binding differs')
    rows = {r['id']: r for r in manifest['cases']}
    acquired = {r['id']: r for r in acquisition['rows']}
    C.require(len(rows) == len(manifest['cases']) == len(acquired) == len(acquisition['rows']) == 6
              and set(rows) == set(acquired) == set(SELECTED), 'Exact six hosted cases required')
    emission = evidence.read(acquisition['emission'])
    P.completed(emission, 'Checked shared hosted emission')
    C.require(emission.get('kind') == 'phase190-checked-native-emission'
              and emission.get('target') == 'x86' and emission.get('emit') == 'object',
              'Checked typed hosted object emission required')
    for item in emission['inputs']:
        evidence.verify(item)
    shared = emission['sharedPreparation']
    plan = evidence.read(shared['plan'])
    P.completed(plan, 'Shared preparation plan')
    C.require(plan.get('kind') == 'phase195-shared-preparation-plan', 'Wrong shared preparation plan')
    for item in plan['inputs']:
        evidence.verify(item)
    roles = [r for r in plan['roles'] if r['name'] == alias]
    C.require(len(roles) == 1, 'Unique exact planned emitter required')
    emitter = roles[0]
    producer = plan['producer']
    # Recompute the original conservative preparation closure and authenticate
    # the original checked generation/source receipts for both actual APIs.
    for declared in (producer, emitter):
        actual = S.authority(evidence.verify(declared['receipt']))
        C.require(actual == {k: v for k, v in declared.items() if k != 'name'},
                  'Shared preparation authority/closure differs from frozen plan')
        for item in actual['inputs']:
            evidence.verify(item)
    C.require(emitter['api'] == role['compiler']
              and emitter['manifest'] == emission['sourcePreparation']['receipt']
              and producer['receipt'] == shared['producer']
              and producer['preparationIdentity'] == emitter['preparationIdentity'] == shared['identity']
              and producer['bindingIdentity'] == emitter['bindingIdentity'],
              'Shared preparation compiler/source/Base mapping differs')
    C.require(all(pin in emission['inputs'] for pin in
                  (shared['plan'], emitter['receipt'], emitter['manifest']))
              and producer['receipt'] in plan['inputs'],
              'Emission lacks exact checked producer/emitter inputs')
    charged_pin = C.pin(shared['chargedAt'])
    charged = evidence.read(charged_pin)
    P.completed(charged, 'Shared preparation execution')
    C.require(charged.get('kind') == 'phase195-shared-preparation-emission'
              and charged['plan'] == shared['plan'] and charged['preparationIdentity'] == shared['identity']
              and dict(name=alias, emission=acquisition['emission']) in charged['roles'],
              'Shared preparation execution binding differs')
    emitted = {r['id']: r for r in emission['rows']}
    C.require(len(emitted) == len(emission['rows']) == 6 and set(emitted) == set(rows),
              'Exact emitted case set required')
    for name in rows:
        for collection in (plan['cases'], charged['cases']):
            matches = [r for r in collection if r['id'] == name]
            C.require(len(matches) == 1 and all(matches[0][k] == rows[name][k]
                      for k in ('source', 'expectedFile')), 'Shared preparation case mapping differs')
        P.completed(next(r for r in charged['cases'] if r['id'] == name), 'Shared preparation case')
    preparation = evidence.read(emitter['manifest'])
    evidence.verify(preparation['snapshot'])
    C.require(P.product_compare.same(preparation['snapshot'], preparation['snapshotIdentity']),
              'Historical snapshot identity differs')
    return dict(identity=identity, manifest=manifest, role=role, alias=alias,
                acquisition=acquisition, acquisitionPin=acquisition_pin, rows=rows, acquired=acquired,
                emission=emission, emitted=emitted, base=emitter['bindingValue'],
                sharedPreparation=dict(plan=shared['plan'], execution=charged_pin,
                    producer=producer['receipt'], emitter=emitter['receipt'], identity=shared['identity']),
                historicalParent=preparation['snapshot'],
                producer=dict(host='js', stage='B1', image=emitter['api'], source=emitter['source']))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--left', type=Path, required=True)
    parser.add_argument('--left-role', default='combined')
    parser.add_argument('--right', type=Path, required=True)
    parser.add_argument('--right-role', default='candidate')
    parser.add_argument('--source-audit', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    evidence = P.Evidence()
    for file in (__file__, P.__file__, S.__file__, S.METHOD, S.extractor.assembly.__file__,
                 P.CATALOG, P.bench.__file__, C.__file__, P.product_compare.__file__, P.request.__file__):
        evidence.verify(C.pin(file))
    out = C.fresh_output(args.out, ROOT)
    report = dict(kind='phase195-hosted-native-subset-products', version=1, complete=False,
                  targetsRun=False, compilerRun=False, selected=SELECTED, comparedCases=0, rows=[],
                  scope='Exactly six hosted shared-preparation/native N1 products: exact source-body audit, '
                  'checked generation and preparation receipts, independent observations, complete object bytes '
                  'and linked text/data/rodata. No all45, runtime speed or whole-compiler equivalence claim.')
    def save():
        report['inputs'] = list(evidence.inputs.values())
        C.write_json(out/'report.json', report)
    save()
    try:
        left = load_hosted(args.left, args.left_role, evidence)
        right = P.load_side(args.right, args.right_role, evidence)
        C.require(right['role']['host'] == 'native' and right['role']['stage'] == 'N1', 'Actual native N1 required')
        generation = generation_gate(right, evidence)
        known = {r['id']: r for r in P.bench.catalog(P.CATALOG)['cases']}
        C.require(set(SELECTED) <= set(right['rows']) <= set(known), 'Corresponding native cases required')
        C.require(left['role']['runtime'] == right['role']['runtime'], 'Target runtime differs')
        gate, audit = source_gate(args.source_audit, evidence, right['producer']['source'], left['producer']['source'])
        C.require(audit['checkedApiReceipt'] == left['sharedPreparation']['emitter'], 'Audited generation receipt differs')
        report.update(left=dict(manifest=left['identity'], role=args.left_role, producer=left['producer']),
                      right=dict(manifest=right['identity'], role=args.right_role, producer=right['producer']),
                      sourceAudit=gate, nativeGeneration=generation, historicalHostedParent=left['historicalParent'],
                      parentIdentityClaim=False, exactExecutableBodiesIdentical=True,
                      sharedPreparation=left['sharedPreparation'], base=left['base'])
        for name in SELECTED:
            a = P.authenticate_product(left, known[name], evidence)
            b = P.authenticate_product(right, known[name], evidence)
            request = evidence.read(b['buildReceipt'])['request']
            C.require(request.get('mode') == 'cache' and request['stamp'] == left['base']['stamp'],
                      'Native preparation mode/stamp differs')
            for key in ('base', 'carrier'):
                evidence.verify(request[key])
                C.require(request[key] == left['base'][key], 'Native/shared Base binding differs: '+key)
            equal = {section: a['sections'][section] == b['sections'][section] for section in a['sections']}
            exact = (P.product_compare.same(a['object'], b['object'])
                     and evidence.verify(a['object']).read_bytes() == evidence.verify(b['object']).read_bytes())
            row = dict(id=name, source=known[name]['source'], expectedFile=known[name]['expectedFile'],
                       left=a, right=b, objectIdentical=exact, linkedSectionsIdentical=equal, complete=False)
            report['rows'].append(row); save()
            C.require(exact and all(equal.values()), 'Product mismatch: '+name)
            row['complete'] = True; report['comparedCases'] += 1; save()
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        report['changedInputs'] = C.changed_inputs(list(evidence.inputs.values()))
        if report['changedInputs']:
            report['complete'] = False
        save()
    print(json.dumps({key: report.get(key) for key in ('complete', 'comparedCases', 'error')}))
    return 0 if report['complete'] else 1


if __name__ == '__main__':
    sys.exit(main())
