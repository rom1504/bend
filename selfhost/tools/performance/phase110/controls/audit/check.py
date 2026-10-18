#!/usr/bin/env python3
"""Authenticate supplemental expected values and compare existing probe output."""
import argparse
import hashlib
import json
from pathlib import Path
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--stdout', type=Path)
    parser.add_argument('--case', action='append', default=[])
    parser.add_argument('--drop-order', choices=['result-first', 'remaining-first'])
    parser.add_argument('--split', choices=['all', 'training', 'heldout'], default='all')
    args = parser.parse_args()
    manifest = json.loads((HERE / 'manifest.json').read_text())
    for key in ('recipes', 'expected', 'harness'):
        item = manifest[key]
        if hashlib.sha256((ROOT / item['file']).read_bytes()).hexdigest() != item['sha256']:
            raise ValueError('frozen audit asset changed: ' + item['file'])
    recipes = json.loads((HERE / 'recipes.json').read_text())['recipes']
    names = {r['name'] for r in recipes if args.split == 'all' or r['split'] == args.split}
    if set(args.case) - names:
        raise ValueError('unknown case in selected split')
    if args.case:
        names &= set(args.case)
    expected = [json.loads(line) for line in (HERE / 'expected.jsonl').read_text().splitlines()]
    expected = [row for row in expected if row['name'] in names and (not args.drop_order or row['dropOrder'] == args.drop_order)]
    if args.stdout:
        actual = [json.loads(line) for line in args.stdout.read_text().splitlines()]
        if actual != expected:
            raise ValueError('probe differs from frozen complete-value oracle')
    print(json.dumps(dict(complete=True, targetsRun=False, observations=len(expected), capturedOutputChecked=bool(args.stdout))))


if __name__ == '__main__':
    main()
