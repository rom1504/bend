#!/usr/bin/env python3
"""Summarize authenticated Phase193 runtime receipts offline; never run targets."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('phase192_summary', HERE.parent / 'phase192/summarize.py')
S = importlib.util.module_from_spec(spec)
spec.loader.exec_module(S)
B, C = S.B, S.C
S.PARTITION = HERE / 'cases.json'
BASE_AGGREGATE = S.aggregate


def aggregate(cases, role, reference):
    result = BASE_AGGREGATE(cases, role, reference)
    if result is None:
        return None
    # Same diagnostics and original-catalog weighting as phase186/analyze-runtime.py.
    eligible = [case for case in cases if case['ratioEligible']]
    families = {}
    for case in eligible:
        ratio = case['stats'][role]['medianMs'] / case['stats'][reference]['medianMs']
        families.setdefault(case['family'], []).append(ratio)
    result.update(familyCount=len(families),
        equalFamilyGeomeanOverReference=S.A.gm(S.A.gm(values) for values in families.values()),
        fixedCatalogPositiveExcessMs=sum(max(0, case['stats'][role]['medianMs'] -
            case['stats'][reference]['medianMs']) * case['point']['repetitions'] for case in eligible))
    return result


S.aggregate = aggregate


def summarize(args):
    partition = B.read(S.PARTITION)
    C.require(partition.get('kind') == 'phase193-frozen-development-partition'
              and len(partition['development']) == 10 and len(partition['heldout']) == 35,
              'Frozen Phase193 ten-development / 35-heldout partition required')
    C.require(len({args.c_role, args.baseline_role, args.qbe_role}) == 3,
              'Distinct C, baseline and QBE roles required')
    result = S.summarize(args)
    # Phase192 authenticates C and baseline against this pinned manifest. Extend
    # the same artifact-identity rule to QBE; candidate roles remain unrestricted.
    references = B.read(args.references)
    C.require(args.qbe_role in result['roles'] and args.qbe_role in references['roles']
              and references['roles'][args.qbe_role]['target'] == 'qbe',
              'Frozen QBE reference role required')
    prior = {case['id']: case for case in references['cases']}
    for case in result['cases']:
        C.require(case['artifacts'][args.qbe_role] == prior[case['id']]['products'][args.qbe_role]['artifact'],
                  'Runtime executable differs from frozen QBE reference: ' + case['id'])
    C.require(C.pin(args.references) == result['references'], 'Reference manifest changed during analysis')
    result.update(kind='phase193-authenticated-runtime-summary',
        inheritedMethod=result['method'], method=C.pin(__file__), qbeRole=args.qbe_role)
    result['scope'] += (' Family diagnostics give each observed eligible family equal weight; positive excess '
        'sums only positive per-case fixed-catalog time differences. Baseline, C and QBE executable '
        'identities are authenticated against the supplied reference manifest and freshly timed in this report. '
        'Candidate role names do not establish native generation or qualification.')
    return result


def markdown(result):
    text = S.markdown(result).replace('# Phase192 runtime summary', '# Phase193 runtime summary', 1)
    lines = ['', '## Family and positive-excess diagnostics', '',
        '| Subset | Role | Versus | Eligible families | Equal-family geomean | Positive fixed-catalog excess ms |',
        '|---|---|---|---:|---:|---:|']
    for name, subset in result['subsets'].items():
        for role, comparisons in subset['roles'].items():
            for reference, stats in comparisons.items():
                if stats is not None:
                    lines.append(f"| {name} | {role} | {reference} | {stats['familyCount']} | "
                        f"{stats['equalFamilyGeomeanOverReference']:.6g} | {stats['fixedCatalogPositiveExcessMs']:.6g} |")
    return text + '\n'.join(lines) + '\n'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', required=True, type=Path, help='Complete runtime report, including an authenticated merged report')
    parser.add_argument('--references', required=True, type=Path, help='Pinned program manifest containing Phase192 N2 baseline and C/QBE references')
    parser.add_argument('--out', required=True, type=Path, help='Fresh JSON file; adjacent .md also created')
    parser.add_argument('--c-role', default='c')
    parser.add_argument('--baseline-role', default='baseline')
    parser.add_argument('--qbe-role', default='qbe')
    parser.add_argument('--spread-limit', type=float, default=1.10)
    parser.add_argument('--emission', nargs=2, action='append', default=[], metavar=('LABEL', 'RECEIPT'))
    args = parser.parse_args()
    md = args.out.with_suffix('.md')
    C.require(args.out.suffix == '.json' and not args.out.exists() and not md.exists(),
              'Fresh .json and adjacent .md output paths required')
    result = summarize(args)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    B.save(args.out, result, fresh=True)
    with md.open('x') as stream:
        stream.write(markdown(result))
    print(json.dumps(dict(json=str(args.out), markdown=str(md), warnings=result['warnings'])))


if __name__ == '__main__':
    main()
