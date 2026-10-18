#!/usr/bin/env python3
"""Authenticate frozen controls; optionally compare captured JSONL. Runs no targets."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]


def verify():
    manifest = json.loads((HERE / 'manifest.json').read_text())
    for key in ('ownershipCases', 'expected'):
        row = manifest[key]
        path = HERE / row['file']
        if hashlib.sha256(path.read_bytes()).hexdigest() != row['sha256']:
            raise ValueError('changed frozen control: ' + str(path))
    for row in manifest['sourceControls']:
        path = ROOT / row['file']
        if hashlib.sha256(path.read_bytes()).hexdigest() != row['sha256']:
            raise ValueError('changed source control: ' + str(path))
    cases = json.loads((HERE / manifest['ownershipCases']['file']).read_text())['cases']
    expected = [json.loads(line) for line in (HERE / manifest['expected']['file']).read_text().splitlines()]
    if len(cases) != manifest['ownershipCases']['count'] or [x['name'] for x in cases] != [x['name'] for x in expected]:
        raise ValueError('case/oracle identities differ')
    return expected


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--stdout', type=Path)
    parser.add_argument('--case', action='append', default=[])
    parser.add_argument('--variant', choices=['reverse', 'discard', 'duplicate'], default='reverse')
    args = parser.parse_args()
    expected = verify()
    if args.variant != 'reverse':
        derived = HERE / 'derived'
        manifest = json.loads((derived / 'manifest.json').read_text())
        variant = next(x for x in manifest['variants'] if x['name'] == args.variant)
        for row in (manifest['parentInputs'], manifest['source'], variant):
            path = derived / row['file']
            if hashlib.sha256(path.read_bytes()).hexdigest() != row['sha256']:
                raise ValueError('changed derived ownership control: ' + str(path))
        expected = [json.loads(line) for line in (derived / variant['file']).read_text().splitlines()]
    if args.case:
        known = {x['name'] for x in expected}
        if set(args.case) - known:
            raise ValueError('unknown cases: ' + str(set(args.case) - known))
        expected = [x for x in expected if x['name'] in args.case]
    if args.stdout:
        actual = [json.loads(line) for line in args.stdout.read_text().splitlines()]
        for row in actual:
            if row.get('released') is not True:
                raise ValueError('missing exact release assertion')
            if isinstance(row.get('count'), bool) or not isinstance(row.get('count'), int):
                raise ValueError('count must be an integer')
        if actual != expected:
            raise ValueError('captured output differs from frozen independent oracle')
    print(json.dumps({'complete': True, 'frozenControls': len(expected), 'capturedOutputChecked': bool(args.stdout), 'variant': args.variant, 'targetsRun': False}))


if __name__ == '__main__':
    main()
