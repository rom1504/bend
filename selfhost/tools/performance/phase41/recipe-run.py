#!/usr/bin/env python3
"""Run explicitly selected bound recipe commands through the campaign ledger."""
import argparse
import json
from pathlib import Path
import subprocess

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('recipe', type=Path)
p.add_argument('names', help='Comma-separated names, executed in this order')
p.add_argument('--ledger', type=Path, required=True)
p.add_argument('--jobs', type=Path, required=True)
p.add_argument('--prefix', required=True)
a = p.parse_args()
recipe = json.loads(a.recipe.read_text())
steps = {s['name']: s for s in recipe['steps']}
names = a.names.split(',')
assert len(names) == len(set(names)) and set(names) <= steps.keys()
assert all('argv' in steps[n] for n in names), 'Manual decision/mapping step'
assert recipe['bound'] is True
for name in names:
    command = steps[name]['argv']
    print(json.dumps(dict(start=name, command=command)), flush=True)
    result = subprocess.run(['python3', str(Path(__file__).with_name('job.py')),
        '--ledger', str(a.ledger), '--out', str(a.jobs/(a.prefix+'-'+name)),
        '--', *command])
    if result.returncode:
        raise SystemExit(result.returncode)
