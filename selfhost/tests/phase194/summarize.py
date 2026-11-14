#!/usr/bin/env python3
"""Authenticate Phase194 runtime receipts with inherited metrics; never run targets."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('phase193_summary', HERE.parent/'phase193/summarize.py')
P = importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)
B, C = P.B, P.C
P.S.PARTITION = HERE/'cases.json'


def summarize(args):
    partition = B.read(P.S.PARTITION)
    C.require(partition.get('kind') == 'phase194-frozen-development-partition'
              and len(partition['development']) == 10 and len(partition['heldout']) == 35,
              'Frozen Phase194 ten-development / 35-heldout partition required')
    C.require(len({args.c_role, args.baseline_role, args.qbe_role}) == 3,
              'Distinct C, baseline and QBE roles required')
    # Phase193 installs its family/excess aggregates into this inherited strict
    # analyzer. Keep every oracle, timing, input and reference admission check.
    result = P.S.summarize(args)
    references = B.read(args.references)
    C.require(args.qbe_role in result['roles'] and args.qbe_role in references['roles']
              and references['roles'][args.qbe_role]['target'] == 'qbe', 'Frozen QBE reference required')
    prior = {case['id']: case for case in references['cases']}
    for case in result['cases']:
        C.require(case['artifacts'][args.qbe_role] == prior[case['id']]['products'][args.qbe_role]['artifact'],
                  'Runtime differs from frozen QBE reference: '+case['id'])
    C.require(C.pin(args.references) == result['references'], 'Reference manifest changed during analysis')
    result.update(kind='phase194-authenticated-runtime-summary', inheritedMethod=result['method'],
        diagnosticsMethod=C.pin(P.__file__), method=C.pin(__file__), qbeRole=args.qbe_role)
    result['scope'] += (' Equal-family and positive fixed-catalog excess diagnostics use the Phase193 formulas. '
        'QBE executable identity is also authenticated against the reference manifest. '
        'Candidate role names do not establish B1/native generation or qualification.')
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', required=True, type=Path)
    parser.add_argument('--references', required=True, type=Path, help='Pinned Phase194 C/QBE/Phase193 N2 reference manifest')
    parser.add_argument('--out', required=True, type=Path)
    parser.add_argument('--c-role', default='c')
    parser.add_argument('--baseline-role', default='baseline')
    parser.add_argument('--qbe-role', default='qbe')
    parser.add_argument('--spread-limit', type=float, default=1.10)
    parser.add_argument('--emission', nargs=2, action='append', default=[], metavar=('LABEL', 'RECEIPT'))
    args = parser.parse_args()
    md = args.out.with_suffix('.md')
    C.require(args.out.suffix == '.json' and not args.out.exists() and not md.exists(), 'Fresh JSON/Markdown required')
    result = summarize(args)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    B.save(args.out, result, fresh=True)
    with md.open('x') as stream:
        stream.write(P.markdown(result).replace('# Phase193 runtime summary', '# Phase194 runtime summary', 1))
    print(json.dumps(dict(json=str(args.out), markdown=str(md), warnings=result['warnings'])))


if __name__ == '__main__':
    main()
