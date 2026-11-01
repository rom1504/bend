#!/usr/bin/env python3
"""Verify retained historical bytes without resolving or running old paths."""
import hashlib
import json
import stat
import zipfile
from pathlib import Path

root = Path(__file__).resolve().parent
manifest = json.loads((root / 'manifest.json').read_text())
verification = json.loads((root / 'verification.json').read_text())
digest = lambda data: hashlib.sha256(data).hexdigest()
assert verification['complete'] and manifest['complete']
assert digest((root / 'manifest.json').read_bytes()) == verification['manifestSha256']
assert digest((root / 'capsule.zip').read_bytes()) == verification['zipSha256']
rows = manifest['members']
assert len(rows) == verification['members'] == len({row['file'] for row in rows})
with zipfile.ZipFile(root / 'capsule.zip') as archive:
    assert sorted(archive.namelist()) == sorted(row['file'] for row in rows)
    for row in rows:
        name = Path(row['file'])
        assert not name.is_absolute() and '..' not in name.parts
        data = archive.read(row['file'])
        assert len(data) == row['bytes'] and digest(data) == row['sha256'], row['file']
        assert stat.S_IMODE(archive.getinfo(row['file']).external_attr >> 16) == row['mode'], row['file']
assert sum(row['bytes'] for row in rows) == verification['rawBytes']
print(json.dumps(dict(complete=True, members=len(rows), targetsRun=False,
                     originalFilesRequired=False, zipSha256=verification['zipSha256'])))
