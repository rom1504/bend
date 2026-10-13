#!/usr/bin/env python3
"""Archive and verify all new Phase83 raw evidence; leave parent seals intact."""
import hashlib
import json
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
HERE = Path(__file__).resolve().parent
RAW = ROOT/'selfhost/build/phase83'
OUT = HERE/'evidence01'
OUT.mkdir(exist_ok=False)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.relative_to(ROOT)), sha256=digest(data), bytes=len(data))


files = sorted(p for p in RAW.rglob('*') if p.is_file())
manifest = []
archive = OUT/'phase83.zip'
with zipfile.ZipFile(archive, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=6) as output:
    for file in files:
        data = file.read_bytes()
        name = str(file.relative_to(ROOT))
        output.writestr(name, data)
        manifest.append(dict(file=name, sha256=digest(data), bytes=len(data)))
manifest_file = OUT/'manifest.json'
manifest_file.write_text(json.dumps(manifest, indent=2)+'\n')
with zipfile.ZipFile(archive) as saved:
    assert saved.namelist() == [row['file'] for row in manifest]
    for row in manifest:
        data = saved.read(row['file'])
        assert len(data) == row['bytes'] and digest(data) == row['sha256']
for row in manifest:
    assert pin(ROOT/row['file']) == row
methods = [pin(p) for p in sorted(HERE.iterdir()) if p.is_file()]
receipt = dict(complete=True, archive=pin(archive), manifest=pin(manifest_file),
    files=len(files), rawBytes=sum(row['bytes'] for row in manifest), methods=methods,
    scope='All new Phase83 raw files, including derivative image, projects, inputs, profiles, C outputs, frontend observations and guard receipts. Parent inputs are SHA-bound in plans and retained by their existing Phase81/82/earlier evidence; they are not copied into this archive. No production image change.')
(ROOT/'implementation/phase83/evidence.json').write_text(json.dumps(receipt, indent=2)+'\n')
print(json.dumps({k:v for k,v in receipt.items() if k!='methods'}))
