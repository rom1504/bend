#!/usr/bin/env python3
"""Compare two completed existing timed-product receipts; never execute targets."""
import argparse
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import changed_inputs, fresh_output, pin, require, same_bytes, verify, write_json


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--candidate', type=Path, required=True)
    parser.add_argument('--reference', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    inputs = {}

    def keep(row):
        old = inputs.get(row['file'])
        require(old is None or old == row, 'Conflicting input pin')
        verify(row)
        inputs[row['file']] = row
        return Path(row['file'])

    def identity(row):
        return row['bytes'], row['sha256']

    keep(pin(__file__))
    keep(pin(ROOT / 'selfhost/tools/build/common.py'))
    reports = {}
    for role, path in [('candidate', args.candidate), ('reference', args.reference)]:
        receipt = pin(path)
        value = json.loads(keep(receipt).read_text())
        require(value.get('kind') == 'bend-phase170-timed-product-reemission'
                and value.get('complete') is True and not value.get('changedInputs')
                and value.get('expectedCount') == 45 and len(value.get('rows', [])) == 45,
                'Complete unchanged timed45 receipt required: ' + role)
        keep(value['image'])
        for reference in value['references']:
            keep(reference)
        reports[role] = (value, receipt)
    current, current_pin = reports['candidate']
    previous, previous_pin = reports['reference']
    require(current['machinePolicy'] == previous['machinePolicy'], 'Machine policy differs')
    require({identity(x) for x in current['references']} ==
            {identity(x) for x in previous['references']}, 'Different frozen timed references')
    by_source = {}
    for row in previous['rows']:
        require(row.get('complete') is True, 'Reference row incomplete')
        key = identity(row['source'])
        require(key not in by_source, 'Duplicate reference source')
        by_source[key] = row
    out = fresh_output(args.out, ROOT)
    result = dict(kind='phase177-timed-products-v175', version=1,
        complete=False, targetsRun=False, candidate=current_pin, reference=previous_pin,
        rows=[], expectedCount=45, inputs=[],
        scope='Complete source and QBE byte equality between two existing timed45 receipts. '
              'No compiler, generated program, runtime benchmark or additional machine build is executed.')
    try:
        seen = set()
        for row in current['rows']:
            require(row.get('complete') is True, 'Candidate row incomplete')
            key = identity(row['source'])
            require(key not in seen and key in by_source, 'Duplicate/unmatched candidate source')
            seen.add(key)
            old = by_source[key]
            for value in (row, old):
                for field in ('source', 'expected', 'product', 'emission'):
                    keep(value[field])
            source_exact = same_bytes(row['source']['file'], old['source']['file'])
            expected_exact = same_bytes(row['expected']['file'], old['expected']['file'])
            product_exact = same_bytes(row['product']['file'], old['product']['file'])
            result['rows'].append(dict(id=row['id'], source=row['source'],
                candidate=row['product'], reference=old['product'], sourceExact=source_exact,
                expectedExact=expected_exact, byteExact=product_exact))
            require(source_exact and expected_exact and product_exact, 'Complete bytes differ: ' + row['id'])
        result['complete'] = len(seen) == len(by_source) == 45
    except Exception as error:
        result['error'] = repr(error)
    finally:
        result['inputs'] = list(inputs.values())
        result['changedInputs'] = changed_inputs(result['inputs'])
        result['complete'] = result['complete'] and not result['changedInputs']
        write_json(out / 'report.json', result)
    print(json.dumps({key: result.get(key) for key in ('complete', 'targetsRun', 'error')}))
    return 0 if result['complete'] else 1


if __name__ == '__main__':
    sys.exit(main())
