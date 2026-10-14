#!/usr/bin/env python3
"""Immutable checkpoint of completed Phase90 evidence and method snapshots."""
import argparse
import hashlib
import json
import zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
RAW = ROOT / 'selfhost/build/phase90'
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('label')
p.add_argument('--exclude-raw', action='append', default=[])
p.add_argument('--exclude-tools', action='append', default=[])
a = p.parse_args()
assert a.label.startswith('evidence') and '/' not in a.label and '..' not in a.label
out = HERE / a.label
out.mkdir(exist_ok=False)

def pin(f):
    b = f.read_bytes()
    return dict(file=str(f.relative_to(ROOT)), sha256=hashlib.sha256(b).hexdigest(), bytes=len(b))

files = []
for base, excluded in [(RAW, a.exclude_raw), (HERE, a.exclude_tools)]:
    for f in base.rglob('*'):
        rel = f.relative_to(base)
        if not f.is_file() or '__pycache__' in rel.parts or any(x.startswith('evidence') for x in rel.parts):
            continue
        if any(str(rel).startswith(x) for x in excluded):
            continue
        files.append(f)
files = sorted(set(files))
# An interrupted process may be retained, but never snapshot an actively running
# guard as if it had completed. Explicitly exclude the active experiment instead.
for f in files:
    if f.name == 'process.json':
        r = json.loads(f.read_text())
        assert 'wallSeconds' in r or 'finished' in r, 'Unfinalized guard: ' + str(f)
archive = out / 'phase90.zip'
records = []
with zipfile.ZipFile(archive, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=6) as z:
    for f in files:
        row = pin(f)
        z.write(f, row['file'])
        records.append(row)
manifest = out / 'manifest.json'
manifest.write_text(json.dumps(records, indent=2) + '\n')
with zipfile.ZipFile(archive) as z:
    assert z.namelist() == [r['file'] for r in records]
    for r in records:
        b = z.read(r['file'])
        assert len(b) == r['bytes'] and hashlib.sha256(b).hexdigest() == r['sha256']
        assert pin(ROOT / r['file']) == r
receipt = dict(complete=True, archive=pin(archive), manifest=pin(manifest),
               files=len(records), rawBytes=sum(r['bytes'] for r in records),
               excludedRawPrefixes=a.exclude_raw, excludedToolPrefixes=a.exclude_tools,
               scope='Completed Phase90 attempt evidence and exact method snapshots, including failures. External upstream/Bun/Phase88/89 assets keep their original pins/download URLs/capsules. No prior evidence is replaced.')
(ROOT / f'implementation/phase90/{a.label}.json').write_text(json.dumps(receipt, indent=2) + '\n')
print(json.dumps(receipt))
