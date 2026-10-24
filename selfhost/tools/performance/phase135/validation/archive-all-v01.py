#!/usr/bin/env python3
"""Archive the completed bounded Phase135 campaign; no target execution."""
import argparse
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
plan = json.loads((ROOT / 'selfhost/build/phase135/machine-gates-plan01/plan.json').read_text())
summary = json.loads((ROOT / 'selfhost/build/phase135/machine-gates-executed01/summary.json').read_text())
assert plan['complete'] and summary['complete']
roots = [
    'selfhost/build/phase111/p135-machine-api01',
    'selfhost/build/phase111/p135-machine-api02',
    'selfhost/build/phase111/p135-ownership-api01',
    'selfhost/build/phase111/p135-monolithic-b01',
    'selfhost/build/phase134/p135-machine-native01',
    *['selfhost/build/phase135/' + s for s in (
        'stage-bridge01', 'stage-bridge-guard01',
        'ownership-source01', 'ownership-api-guard01',
        'ownership-finite01', 'ownership-finite-guard01',
        'ownership-compare01', 'ownership-compare-guard01',
        'monolithic-b-plan01', 'monolithic-b-guard01')],
]
for row in plan['requests'] + plan['ordinary']:
    report = Path(row['report'])
    assert report.is_relative_to(ROOT / 'selfhost/build')
    assert json.loads(report.read_text())['complete']
    roots.append(str(report.parent))
command = [sys.executable, '-B', str(ROOT / 'selfhost/tools/performance/phase135/machine/archive-v01.py'),
           '--out', str(a.out.resolve())]
for root in roots:
    command += ['--root', str((ROOT / root).resolve())]
subprocess.run(command, cwd=ROOT, check=True)
