#!/usr/bin/env python3
"""Narrow immutable successor admitting the selected driver's frame4 cache."""
import argparse
import ast
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT/'selfhost/build/phase64'
PARENT = RAW/'latency-method01'
PARENT_SHA = '3f631cd26cc6086be7b16e1dd224bebb2a577e50955b648d415c4e3a9897a958'


def identity(file):
    file = Path(file).resolve(strict=True)
    return dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('out', type=Path)
a = p.parse_args()
out = a.out.resolve()
assert out.is_relative_to(RAW) and not out.exists()
parent = identity(PARENT/'derivation.json')
assert parent['sha256'] == PARENT_SHA
manifest = json.loads((PARENT/'derivation.json').read_text())
assert manifest['explicitCacheAdmission'] == dict(frameVersions=[1, 2, 3], decodedVersions=[4, 6])
parents = {Path(r['output']['file']).name: r['output'] for r in manifest['derivations']}
texts, rows = {}, []
for name in ['profile.mjs', 'setup.mjs', 'worker.mjs', 'run.py']:
    before = identity(PARENT/name)
    assert before == parents[name]
    text = (PARENT/name).read_text()
    edits = []
    def edit(old, new, count=1):
        global text
        assert text.count(old) == count, (name, old, text.count(old), count)
        text = text.replace(old, new)
        edits.append(dict(old=old, new=new, count=count))
    count = text.count(str(PARENT))
    if count:
        edit(str(PARENT), str(out), count)
    if name == 'setup.mjs':
        edit('/-frame(?:1|2|3)\\.json$/', '/-frame(?:1|2|3|4)\\.json$/')
    if name == 'run.py':
        ast.parse(text)
    texts[name] = text
    rows.append(dict(parent=before, output=dict(file=str(out/name),
        sha256=hashlib.sha256(text.encode()).hexdigest()), edits=edits))
out.mkdir(parents=True)
for name, text in texts.items():
    (out/name).write_text(text)
result = dict(kind='phase61-candidate-fast-loop-method', complete=True, **{'pass': True},
    dataOnly=True, targetExecuted=False, producer=identity(__file__), parentDerivation=parent,
    derivations=rows, explicitCacheAdmission=dict(frameVersions=[1, 2, 3, 4], decodedVersions=[4, 6]),
    immutableAuditSnapshot=manifest['immutableAuditSnapshot'],
    scope='Only method relocation and explicit frame4 filename recognition. The exact selected snapshot '
          'driver decoder remains authoritative for raw integrity and format validation. Semantic cache '
          'versions remain4/6. No clock, lineage, preparation, source-ID, oracle or guard change. '
          'Fresh candidate projects must contain their actual single cache, not fallback leftovers.')
(out/'derivation.json').write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(method=identity(out/'derivation.json'))))
