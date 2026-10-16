#!/usr/bin/env python3
"""Authenticate completed programs from a retained partially failed emission."""
import argparse
from pathlib import Path
import sys
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT/'selfhost/tools/performance/phase100'))
import run as R
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--parent', type=Path, required=True)
p.add_argument('--ids', required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args(); out = a.out.resolve(); out.mkdir(parents=True, exist_ok=False)
parent = R.read(a.parent); ids = a.ids.split(',')
rows = [r for r in parent['programs'] if r['id'] in ids]
assert len(rows) == len(ids) and {r['id'] for r in rows} == set(ids)
for row in rows:
    assert row['complete']
    for key in ('source','c','receipt'): R.verify(row[key])
    receipt = R.read(row['receipt']['file'])
    assert receipt['complete'] and receipt['output'] == row['c'] and receipt['source'] == row['source']
for key in ('compilerSource','api'): R.verify(parent[key])
R.save(out/'report.json', dict(complete=True, subsetOnly=True, method=R.pin(__file__),
    parentEmission=R.pin(a.parent), parentComplete=parent['complete'], programs=rows,
    compilerSource=parent['compilerSource'], api=parent['api'], scope=parent['scope'],
    excluded=[r['id'] for r in parent['programs'] if r['id'] not in ids]))
