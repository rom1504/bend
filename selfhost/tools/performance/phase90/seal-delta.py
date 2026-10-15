#!/usr/bin/env python3
"""Seal completed Phase90 files absent or changed from immutable earlier capsules."""
import argparse
import hashlib
import json
import subprocess
import zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
RAW = ROOT / 'selfhost/build/phase90'
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('label')
p.add_argument('--parent', action='append', required=True, type=Path)
p.add_argument('--exclude-raw', action='append', default=[])
p.add_argument('--exclude-tools', action='append', default=[])
a = p.parse_args()
assert a.label.startswith('evidence') and '/' not in a.label and '..' not in a.label

def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.relative_to(ROOT)), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))

known, parents = {}, []
for parent in a.parent:
    parent = parent.resolve()
    record = json.loads(parent.read_text())
    assert record['complete']
    for key in ['archive', 'manifest']:
        item = record[key]
        file = ROOT / item['file']
        assert pin(file) == item
        committed = subprocess.check_output(['git', 'show', 'HEAD:' + item['file']], cwd=ROOT)
        assert hashlib.sha256(committed).hexdigest() == item['sha256']
    rows = json.loads((ROOT / record['manifest']['file']).read_text())
    with zipfile.ZipFile(ROOT / record['archive']['file']) as archive:
        for row in rows:
            data = archive.read(row['file'])
            assert len(data) == row['bytes'] and hashlib.sha256(data).hexdigest() == row['sha256']
            known.setdefault(row['file'], set()).add((row['sha256'], row['bytes']))
    parents.append(pin(parent))

files, reused = [], []
for base, excluded in [(RAW, a.exclude_raw), (HERE, a.exclude_tools)]:
    for file in base.rglob('*'):
        rel = file.relative_to(base)
        if not file.is_file() or '__pycache__' in rel.parts or any(x.startswith('evidence') for x in rel.parts):
            continue
        if any(str(rel).startswith(prefix) for prefix in excluded):
            continue
        row = pin(file)
        if (row['sha256'], row['bytes']) in known.get(row['file'], set()):
            reused.append(row)
        else:
            if file.name == 'process.json':
                process = json.loads(file.read_text())
                assert 'wallSeconds' in process or 'finished' in process, 'Unfinished guard: ' + str(file)
            files.append((file, row))

out = HERE / a.label
out.mkdir(exist_ok=False)
archive = out / 'phase90.zip'
files.sort()
with zipfile.ZipFile(archive, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=6) as packed:
    for file, row in files:
        packed.write(file, row['file'])
with zipfile.ZipFile(archive) as packed:
    assert packed.namelist() == [row['file'] for _, row in files]
    for file, row in files:
        data = packed.read(row['file'])
        assert len(data) == row['bytes'] and hashlib.sha256(data).hexdigest() == row['sha256']
        assert pin(file) == row
manifest = out / 'manifest.json'
manifest.write_text(json.dumps([row for _, row in files], indent=2) + '\n')
result = dict(complete=True, archive=pin(archive), manifest=pin(manifest), parents=parents,
              files=len(files), rawBytes=sum(row['bytes'] for _, row in files), reusedFiles=len(reused),
              excludedRawPrefixes=a.exclude_raw, excludedToolPrefixes=a.exclude_tools,
              scope='Delta of completed files against verified committed capsules; earlier bytes and failures remain in their original capsules. Active trees explicitly excluded.')
receipt = ROOT / ('implementation/phase90/' + a.label + '.json')
with receipt.open('x') as stream:
    json.dump(result, stream, indent=2)
    stream.write('\n')
print(json.dumps(result))
