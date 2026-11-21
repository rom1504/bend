#!/usr/bin/env python3
"""Authenticate all45 exact native-N1 products from two explicit frozen sources.

Reuses the frozen Phase190 evidence reader and per-product oracle/provenance
checks. Object bytes and linked .text/.data/.rodata must match for every case.
"""
import argparse
import importlib.util
import json
import hashlib
import struct
from pathlib import Path
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
METHOD = ROOT/'selfhost/tests/phase190/compare-products.py'
spec = importlib.util.spec_from_file_location('phase190_product_evidence', METHOD)
P = importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)



def loaded_layout(path):
    data=Path(path).read_bytes()
    P.common.require(data[:6]==b'\x7fELF\x02\x01', 'Expected little-endian ELF64')
    shoff=struct.unpack_from('<Q',data,40)[0]
    entsize,count,namesindex=struct.unpack_from('<HHH',data,58)
    P.common.require(entsize==64 and 0<namesindex<count, 'Unsupported ELF section table')
    sections=[struct.unpack_from('<IIQQQQIIQQ',data,shoff+i*entsize) for i in range(count)]
    names=sections[namesindex];strings=data[names[4]:names[4]+names[5]]
    result={}
    for section in sections:
        name=strings[section[0]:].split(b'\0',1)[0].decode()
        if section[2]&2 and name!='.note.gnu.build-id':
            payload=b'' if section[1]==8 else data[section[4]:section[4]+section[5]]
            result[name]=dict(type=section[1],flags=section[2],address=section[3],offset=section[4],size=section[5],alignment=section[8],sha256=hashlib.sha256(payload).hexdigest())
    return dict(entry=struct.unpack_from('<Q',data,24)[0],sections=result)

def validate_pair(left, right, names, left_stage, right_stage, args):
    for side, stage in ((left, left_stage), (right, right_stage)):
        P.common.require(side['role']['host'] == 'native' and side['role']['stage'] == stage,
                         'Actual native producer stage differs: expected ' + stage)
        P.common.require(set(side['rows']) == set(names) and len(side['rows']) == 45,
                         'Each manifest must contain exactly the complete native45 catalog')
    P.common.require(P.product_compare.same(left['producer']['source'], P.common.pin(args.left_source)), 'Left compiler source differs from explicit frozen source')
    P.common.require(P.product_compare.same(right['producer']['source'], P.common.pin(args.right_source)), 'Right compiler source differs from explicit frozen source')
    P.common.require(left['producer']['source'] != right['producer']['source'], 'Use ordinary generation comparison for identical sources')
    P.common.require(left['role']['runtime'] == right['role']['runtime'],
                     'Paired target runtime differs')
    P.common.require(left['role']['preparation'] == right['role']['preparation']
                     and left['role']['policy'] == right['role']['policy'],
                     'Paired preparation/policy differs')


def execute(args):
    P.common.require(0 < args.seconds <= 600, 'Bounded comparison deadline required')
    started = time.monotonic()
    evidence = P.Evidence()
    for file in (__file__, METHOD, P.bench.__file__, P.common.__file__, P.product_compare.__file__,
                 P.request.__file__, P.CATALOG, P.PARTITION):
        evidence.verify(P.common.pin(file))
    evidence.verify(P.common.pin(args.left_source))
    evidence.verify(P.common.pin(args.right_source))
    partition = P.bench.read(P.PARTITION)
    P.common.require(P.product_compare.same(partition['catalog'], P.common.pin(P.CATALOG)),
                     'Frozen native45 catalog differs')
    cases = P.bench.catalog(P.CATALOG)['cases']
    names = [case['id'] for case in cases]
    P.common.require(len(names) == len(set(names)) == 45, 'Exactly45 independent catalog cases required')
    out = P.common.fresh_output(args.out, P.ROOT)
    report = dict(kind='phase198-explicit-source-native-product-equivalence', version=1,
        complete=False, targetsRun=False, measurementsRun=False, selected=names, rows=[],
        secondsLimit=args.seconds,
        scope='Offline two explicit frozen compiler sources, actual native-N1 producers, identical runtime/catalog and independent recorded value/count authentication. Every emitted object and linked .text/.data/.rodata must match. All allocated ELF sections (addresses, sizes, flags, alignments and bytes) except the non-executing GNU build ID must also match. Establishes exact generated-machine equivalence for the fixed45 inputs; no new runtime timings or broader compiler proof.')

    def left():
        P.common.require(time.monotonic() - started < args.seconds, 'Whole comparison deadline exceeded')

    def save():
        report['seconds'] = time.monotonic() - started
        report['inputs'] = list(evidence.inputs.values())
        P.common.write_json(out / 'report.json', report)

    save()
    try:
        a = P.load_side(args.left, args.left_role, evidence)
        left()
        b = P.load_side(args.right, args.right_role, evidence)
        left()
        validate_pair(a, b, names, args.left_stage, args.right_stage, args)
        report.update(left=dict(manifest=a['identity'], acquisition=a['acquisitionPin'],
                                role=args.left_role, producer=a['producer']),
                      right=dict(manifest=b['identity'], acquisition=b['acquisitionPin'],
                                 role=args.right_role, producer=b['producer']),
                      compilerSources=[a['producer']['source'],b['producer']['source']], runtime=a['role']['runtime'])
        save()
        for case in cases:
            left()
            first = P.authenticate_product(a, case, evidence)
            second = P.authenticate_product(b, case, evidence)
            P.common.require(a['rows'][case['id']]['products'][args.left_role]['runtimeArgumentConvention']
                             == b['rows'][case['id']]['products'][args.right_role]['runtimeArgumentConvention'],
                             'Paired executable argument convention differs')
            equal = {section: first['sections'][section] == second['sections'][section]
                     for section in first['sections']}
            layout_a=loaded_layout(first['binary']['file']);layout_b=loaded_layout(second['binary']['file'])
            row = dict(id=case['id'], source=case['source'], expectedFile=case['expectedFile'],
                left=first, right=second,
                objectIdentical=P.product_compare.same(first['object'], second['object']),
                linkedSectionsIdentical=equal, allocatedLayoutIdentical=layout_a==layout_b, allocatedLayout=layout_a, complete=False)
            report['rows'].append(row)
            save()
            P.common.require(row['objectIdentical'], 'Native generation object differs: ' + case['id'])
            P.common.require(all(equal.values()), 'Native generation linked sections differ: ' + case['id'])
            P.common.require(row['allocatedLayoutIdentical'], 'Allocated executable layout/content differs: '+case['id'])
            row['complete'] = True
            save()
        left()
        report.update(complete=True, objectsIdentical=45, linkedSectionsIdentical=135, allocatedLayoutsIdentical=45)
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        report['changedInputs'] = P.common.changed_inputs(list(evidence.inputs.values()))
        if report['changedInputs'] or time.monotonic() - started >= args.seconds:
            report['complete'] = False
            if not report.get('error'):
                report['error'] = 'Inputs changed or whole comparison deadline exceeded'
        save()
    print(json.dumps({key: report.get(key) for key in
                      ('complete', 'objectsIdentical', 'linkedSectionsIdentical', 'error')}))
    return 0 if report['complete'] else 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--left', type=Path, required=True)
    parser.add_argument('--left-role', default='candidate')
    parser.add_argument('--left-stage', choices=['N1'], default='N1')
    parser.add_argument('--right', type=Path, required=True)
    parser.add_argument('--right-role', default='candidate')
    parser.add_argument('--right-stage', choices=['N1'], default='N1')
    parser.add_argument('--left-source', type=Path, required=True)
    parser.add_argument('--right-source', type=Path, required=True)
    parser.add_argument('--seconds', type=float, default=120)
    parser.add_argument('--out', type=Path, required=True)
    return execute(parser.parse_args())


if __name__ == '__main__':
    sys.exit(main())
