#!/usr/bin/env python3
"""Inventory closed Phase135 resource guards, including failed work."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
assert not a.out.exists()
rows = []
for path in sorted((ROOT / 'selfhost/build/phase135').glob('*/process.json')):
    raw = path.read_bytes()
    value = json.loads(raw)
    assert 'finished' in value and 'returncode' in value
    rows.append(dict(name=path.parent.name, file=str(path), bytes=len(raw),
                     sha256=hashlib.sha256(raw).hexdigest(), **value))
overlap = []
for i, x in enumerate(rows):
    for y in rows[i + 1:]:
        seconds = min(x['finished'], y['finished']) - max(x['started'], y['started'])
        if seconds > 0:
            overlap.append(dict(a=x['name'], b=y['name'], seconds=seconds))
result = dict(complete=True, targetsRun=False, method=str(Path(__file__).resolve()),
              guards=rows, sumGuardWallSeconds=sum(x['wallSeconds'] for x in rows),
              overlappingGuards=overlap,
              extraRefusal=dict(action='First cold replay launch while cached replay was finishing',
                  outcome='Execution lock refused before target launch; retried with machine-cold-guard02',
                  observedToolWallSeconds=0.241553609, guardReceiptCreated=False),
              scope='Sum of top-level guarded jobs, not elapsed session time, nested stage time or billing. '
                    'Metadata audits, archive, agent work and unguarded source preparation are excluded. '
                    'The two source/API and finite-control overlaps are reported explicitly.')
a.out.parent.mkdir(parents=True, exist_ok=True)
a.out.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({k: result[k] for k in ('complete', 'sumGuardWallSeconds', 'overlappingGuards')}))
