#!/usr/bin/env python3
"""Archive every Phase87 attempt and verify every saved byte and source binding."""
import hashlib,json,zipfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
RAW=ROOT/'selfhost/build/phase87';OUT=HERE/'evidence01'
OUT.mkdir(exist_ok=False)
def digest(b):return hashlib.sha256(b).hexdigest()
def pin(f):
    b=f.read_bytes();return dict(file=str(f.relative_to(ROOT)),sha256=digest(b),bytes=len(b))
files=sorted(f for f in RAW.rglob('*') if f.is_file())
manifest=[];archive=OUT/'phase87.zip'
with zipfile.ZipFile(archive,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=6) as saved:
    for f in files:
        b=f.read_bytes();name=str(f.relative_to(ROOT));saved.writestr(name,b)
        manifest.append(dict(file=name,sha256=digest(b),bytes=len(b)))
manifest_file=OUT/'manifest.json';manifest_file.write_text(json.dumps(manifest,indent=2)+'\n')
with zipfile.ZipFile(archive) as saved:
    assert saved.namelist()==[r['file'] for r in manifest]
    for r in manifest:
        b=saved.read(r['file']);assert len(b)==r['bytes'] and digest(b)==r['sha256']
for r in manifest:assert pin(ROOT/r['file'])==r
receipt=dict(complete=True,archive=pin(archive),manifest=pin(manifest_file),files=len(files),rawBytes=sum(r['bytes'] for r in manifest),
    methods=[pin(f) for f in sorted(HERE.rglob('*')) if f.is_file() and OUT not in f.parents],
    scope='Every Phase87 raw file, including profiles, expected failing closure controls, checked isolated source/C/JS, native candidate, output C, guard receipts and comparison reports. Phase86 exact baseline, Base/runtime assets and other pinned dependencies remain in their original capsules/checkouts. Production is unchanged; no earlier seal is changed.')
(ROOT/'implementation/phase87/evidence.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps({k:v for k,v in receipt.items() if k!='methods'}))
