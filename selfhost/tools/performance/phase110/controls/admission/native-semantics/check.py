#!/usr/bin/env python3
"""Check saved direct-entry observations against frozen complete values."""
import argparse
import json
from pathlib import Path
import sys
sys.dont_write_bytecode=True
from prepare import HERE,verify

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root',type=int,choices=range(4))
    parser.add_argument('--case',action='append',default=[])
    parser.add_argument('--stdout',type=Path)
    args=parser.parse_args()
    manifest=json.loads((HERE/'manifest.json').read_text())
    for row in manifest['inputs']:verify(row)
    cases=json.loads((HERE/'cases.json').read_text())['cases']
    names={c['name'] for c in cases if args.root is None or c['root']==args.root}
    if set(args.case)-names:raise ValueError('unknown case for selected root')
    if args.case:names &= set(args.case)
    expected=[json.loads(s) for s in (HERE/'expected.jsonl').read_text().splitlines() if json.loads(s)['name'] in names]
    if args.stdout:
        actual=[json.loads(s) for s in args.stdout.read_text().splitlines()]
        if actual!=expected:raise ValueError('native closure differs from frozen complete-value/lifetime oracle')
    print(json.dumps(dict(complete=True,targetsRun=False,observations=len(expected),savedOutputChecked=bool(args.stdout))))

if __name__=='__main__':main()
