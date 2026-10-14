#!/usr/bin/env python3
"""Seal new/changed Phase89 evidence without duplicating the prior capsule."""
import argparse
import hashlib
import json
import zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('label')
args = parser.parse_args()
assert args.label == 'evidence03', 'This delta extends evidence02 only'
previous_path = ROOT / 'implementation/phase89/evidence02.json'
previous = json.loads(previous_path.read_text())


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.relative_to(ROOT)), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


for key in ('archive', 'manifest'):
    assert pin(ROOT / previous[key]['file']) == previous[key]
prior = {r['file']: r for r in json.loads((ROOT / previous['manifest']['file']).read_text())}
out = HERE / args.label
out.mkdir(exist_ok=False)
selected, inherited = [], []
for base in (ROOT / 'selfhost/build/phase89', HERE):
    for path in base.rglob('*'):
        relative = path.relative_to(base)
        if not path.is_file() or '__pycache__' in relative.parts or any(p.startswith('evidence') for p in relative.parts):
            continue
        record = pin(path)
        if path.name == 'process.json':
            state = json.loads(path.read_text())
            assert 'wallSeconds' in state or 'finished' in state, 'Unfinalized guard: ' + str(path)
        if prior.get(record['file']) == record:
            inherited.append(record['file'])
        else:
            selected.append(record)
selected.sort(key=lambda r: r['file'])
assert len({r['file'] for r in selected}) == len(selected)
archive = out / 'phase89.zip'
with zipfile.ZipFile(archive, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=6) as saved:
    for record in selected:
        saved.write(ROOT / record['file'], record['file'])
manifest = out / 'manifest.json'
manifest.write_text(json.dumps(selected, indent=2) + '\n')
with zipfile.ZipFile(archive) as saved:
    assert saved.namelist() == [r['file'] for r in selected]
    for record in selected:
        data = saved.read(record['file'])
        assert len(data) == record['bytes'] and hashlib.sha256(data).hexdigest() == record['sha256']
        assert pin(ROOT / record['file']) == record
receipt = dict(complete=True, archive=pin(archive), manifest=pin(manifest),
               parent=pin(previous_path), files=len(selected), rawBytes=sum(r['bytes'] for r in selected),
               inheritedUnchangedFiles=len(inherited), method=pin(Path(__file__)),
               scope='All new/changed Phase89 raw evidence and method snapshots since evidence02. '
                     'Prior unchanged and pruned products remain in the immutable earlier capsules; '
                     'external/shared dependencies retain their original receipts. No active target was sealed.')
(ROOT / 'implementation/phase89/evidence03.json').write_text(json.dumps(receipt, indent=2) + '\n')
print(json.dumps(receipt))
