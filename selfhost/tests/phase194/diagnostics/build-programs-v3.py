#!/usr/bin/env python3
"""Diagnostic catalog adapter to original Phase190 construction/observation.

Only metadata authority and output scope change. The imported builder owns
linking, checked-emission authentication and independent value/count checks.
Run under one outer CPU3 disk guard; this file never acquires compiler images.
"""
import argparse
import importlib.util
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
METHOD = HERE.parents[1] / 'phase190/build-programs.py'
spec = importlib.util.spec_from_file_location('p194_diagnostic_build', METHOD)
P = importlib.util.module_from_spec(spec); spec.loader.exec_module(P)
IDS = ['value-identity-rebind', 'value-identity-helpers',
       'register-pressure-few', 'register-pressure-many',
       'f32-region-closed', 'f32-region-mixed',
       'predicate-flow-branch', 'predicate-flow-mask',
       'product-ownership-unique', 'product-ownership-shared',
       'memory-dependence-sequential', 'memory-dependence-dependent']


def main():
    P.__doc__ = __doc__
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument('--catalog', type=Path, default=HERE / 'catalog-v3.json')
    own, forwarded = parser.parse_known_args()
    P.CATALOG = own.catalog.resolve(strict=True)
    original_emission = P.emission
    original_write = P.common.write_json

    def emission(path):
        catalog = P.bench.read(P.CATALOG)
        P.common.require(catalog.get('kind') == 'phase194-independent-paired-diagnostics'
            and catalog.get('diagnosticOnly') is True
            and catalog.get('native45Membership') is False
            and [r['id'] for r in catalog['cases']] == IDS,
            'Exact twelve-case diagnostic catalog authority required')
        report, authority, known, inputs = original_emission(path)
        P.common.require(report.get('campaign') == 'phase194-diagnostics'
            and report.get('diagnosticOnly') is True
            and report.get('native45Membership') is False,
            'Diagnostic-only checked emission required')
        selected = report['selected']
        P.common.require(selected in (IDS[:6], IDS[10:], IDS)
            and [r['id'] for r in report['rows']] == selected
            and P.common.pin(P.CATALOG) in report['inputs'],
            'Emission must bind this catalog and exactly first3, memory2 or full12')
        base = (P.CATALOG.parent / catalog.get('assetRoot', '.')).resolve()
        extra = [P.common.pin(__file__), P.common.pin(METHOD), catalog['oracle']]
        for case in catalog['cases']:
            small = P.bench.bind(case['correctness']['expectedFile'], base)
            P.common.require(Path(small['file']).read_text() == case['correctness']['expectedStdout'],
                             'Independent small-point oracle differs')
            extra.extend([small, case['lineage']])
        for row in report['rows']:
            P.common.require(row.get('sameTypedSequence') is True
                and row.get('expectedFile') == known[row['id']]['expectedFile']
                and row['expectedFile'] in report['inputs'],
                'Same typed sequence and exact independent oracle binding required')
        for item in extra:
            P.common.verify(item)
        return report, authority, known, P.bench.unique_inputs([*inputs, *extra])

    def write(path, value):
        if isinstance(value, dict) and value.get('kind') == 'bend-benchmark-acquisition':
            value = dict(value, diagnosticOnly=True, native45Membership=False,
                scope='Diagnostic-only machine construction and independent value/count check at the catalog timing point. Small-point parameters are separately supplied, not executed by this adapter. No native45 score, compiler timing, self-hosting or promotion claim.')
        return original_write(path, value)

    P.emission = emission
    P.common.write_json = write
    sys.argv = [str(Path(__file__)), *forwarded]
    return P.main()


if __name__ == '__main__':
    sys.exit(main())
