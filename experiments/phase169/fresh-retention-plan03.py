#!/usr/bin/env python3
"""Root-operated exact capture/apply/restore list for six old intermediate sets.
No action runs without an explicit subcommand. Target lane must be idle.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PROPOSAL = ROOT/'experiments/phase169/fresh-archive-proposal03.json'

def authenticate(identity):
    p=Path(identity['file'])
    if not p.is_absolute():p=ROOT/p
    data=p.read_bytes()
    if len(data)!=identity['bytes'] or hashlib.sha256(data).hexdigest()!=identity['sha256']:
        raise ValueError('Changed pinned input: '+str(p))
    return p

def checked(row):
    plan=json.loads((ROOT/row['plan']).read_text())
    if not plan['complete'] or Path(plan['root'])!=ROOT/row['root']:
        raise ValueError('Incomplete or wrong-root plan')
    listing=authenticate(plan['files'])
    entries=[json.loads(line) for line in listing.read_text().splitlines()]
    actual={str(Path(v['file']['file']).relative_to(ROOT)):(v['file']['bytes'],v['file']['sha256']) for v in entries}
    expected={v['file']:(v['bytes'],v['sha256']) for v in row['selectedFiles']}
    if actual!=expected or len(entries)!=len(expected) or plan['allocatedBytes']!=row['allocatedBytes']:
        raise ValueError('Verified file selection differs from reviewed proposal')

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('action',choices=['capture','apply','restore'])
    p.add_argument('--name',help='Exact named root; omit to operate on all six reviewed roots')
    args=p.parse_args()
    proposal=json.loads(PROPOSAL.read_text())
    authenticate(proposal['method']);authenticate(proposal['archiveVerifier'])
    rows=[r for r in proposal['roots']if args.name is None or r['name']==args.name]
    if not rows:raise ValueError('Unknown root name')
    if args.action!='capture':
        for row in rows:checked(row)
    for row in rows:
        subprocess.run(row[args.action+'Command'],cwd=ROOT,check=True)
        if args.action=='capture':checked(row)
    print(json.dumps(dict(complete=True,action=args.action,roots=len(rows),selectedFiles=sum(len(r['selectedFiles'])for r in rows))))

if __name__=='__main__':main()
