#!/usr/bin/env python3
"""Authenticate frozen Phase110 controls; compare existing stdout without targets."""
import argparse
import importlib.util
import json
import sys
from pathlib import Path
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
SPEC = importlib.util.spec_from_file_location('prepare', HERE / 'prepare.py')
PREPARE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(PREPARE)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--stdout', type=Path)
    parser.add_argument('--variant', choices=['reverse', 'discard', 'duplicate', 'tail', 'last', 'append'], default='reverse')
    parser.add_argument('--split', choices=['all', 'training', 'heldout'], default='all')
    parser.add_argument('--case', action='append', default=[])
    args = parser.parse_args()
    manifest, cases = PREPARE.verify()
    cases = PREPARE.REFERENCE.selected(cases, args.variant)
    if args.split != 'all':
        cases = [case for case in cases if case['split'] == args.split]
    known = {case['name'] for case in cases}
    if set(args.case) - known:
        raise ValueError('unknown cases in selected variant/split')
    if args.case:
        known &= set(args.case)
    expected = [json.loads(line) for line in (HERE / f'{args.variant}.expected.jsonl').read_text().splitlines() if json.loads(line)['name'] in known]
    if args.stdout:
        actual = [json.loads(line) for line in args.stdout.read_text().splitlines()]
        if actual != expected:
            raise ValueError('output differs from frozen independent oracle')
        for row in actual:
            if row.get('released') is not True or type(row.get('count')) is not int:
                raise ValueError('missing exact integer count/release assertion')
    print(json.dumps(dict(complete=True, targetsRun=False, frozenAtUtc=manifest['frozenAtUtc'], controls=len(expected), variant=args.variant, capturedOutputChecked=bool(args.stdout))))


if __name__ == '__main__':
    main()
