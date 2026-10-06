#!/usr/bin/env python3
"""Copy the already-frozen original direct06/TS bundle without repacking."""
import hashlib
import json
from pathlib import Path
import shutil

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
SOURCE = ROOT / 'selfhost/build/phase53/reference-direct06'
OUT = HERE / 'bundles/baseline'
RECEIPT = HERE / 'publication-baseline.json'


def identity(file):
    file = Path(file).resolve()
    data = file.read_bytes()
    return dict(file=str(file), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


assert not OUT.exists() and not RECEIPT.exists()
producer = identity(__file__)
manifest = json.loads((SOURCE / 'manifest.json').read_text())
assert identity(SOURCE / 'manifest.json')['sha256'] == '37be3740c46d98c16342448e5082313a49fdc32da806e10a75ce694934faa3d0'
assert manifest['complete'] and len(manifest['cases']) == 45
assert manifest['roles']['baseline']['compiler']['api']['sha256'] == '472da578ff9066413f0a2b8e5c0053b5bc26eae8c3cb343b5b0cbb2a62c03a3a'
binding = json.loads((SOURCE / 'baseline-binding.json').read_text())
assert binding['manifest']['sha256'] == identity(SOURCE / 'manifest.json')['sha256']
assert binding['compiler'] == manifest['roles']['baseline']['compiler']
for key in ['archive', 'provenance']:
    got = identity(SOURCE / manifest[key]['path'])
    assert all(got[k] == manifest[key][k] for k in ['bytes', 'sha256'])
inputs = [identity(SOURCE / name) for name in ['manifest.json', 'provenance.json', 'baseline-binding.json', 'programs.tar.gz']]
OUT.mkdir(parents=True)
copies = []
for item in inputs:
    target = OUT / Path(item['file']).name
    with Path(item['file']).open('rb') as source, target.open('xb') as dest:
        shutil.copyfileobj(source, dest)
    copied = identity(target)
    assert all(copied[k] == item[k] for k in ['bytes', 'sha256'])
    copies.append(dict(source=item, copied=copied))
for item in [producer, *inputs]:
    assert identity(item['file']) == item
report = dict(kind='phase53-original-reference-publication', complete=True, dataOnly=True,
    producer=producer, files=len(copies), bytes=sum(x['bytes'] for x in inputs), copies=copies,
    inputsUnchanged=True, byteExact=True,
    scope='Four exact existing original direct06/TypeScript bundle files copied once. No repack, compilation, target execution or historical timing relabel.')
with RECEIPT.open('x') as stream:
    json.dump(report, stream, indent=2)
    stream.write('\n')
print(json.dumps(dict(complete=True, files=len(copies), receipt=identity(RECEIPT))))
