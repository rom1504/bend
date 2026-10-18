#!/usr/bin/env python3
"""Check existing saved output from a native Base String.append entry."""
import argparse
import json
import sys
from pathlib import Path
sys.dont_write_bytecode=True
from prepare import HERE,verify

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--stdout',type=Path);p.add_argument('--case',action='append',default=[])
    a=p.parse_args();manifest=json.loads((HERE/'manifest.json').read_text())
    for row in manifest['inputs']:verify(row)
    rows=[json.loads(line) for line in (HERE/'expected.jsonl').read_text().splitlines()]
    if set(a.case)-{row['name'] for row in rows}:raise ValueError('unknown case')
    if a.case:rows=[row for row in rows if row['name'] in a.case]
    if a.stdout and rows!=[json.loads(line) for line in a.stdout.read_text().splitlines()]:raise ValueError('complete String.append oracle differs')
    print(json.dumps(dict(complete=True,targetsRun=False,observations=len(rows),savedOutputChecked=bool(a.stdout))))

if __name__=='__main__':main()
