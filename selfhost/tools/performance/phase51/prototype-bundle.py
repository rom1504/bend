#!/usr/bin/env python3
"""Apply reviewed exact runtime spans to current saved outputs; no compilation."""
import hashlib
import json
import sys
from pathlib import Path

reference, recipe_file, out = map(Path, sys.argv[1:])
reference, recipe_file, out = reference.resolve(), recipe_file.resolve(), out.resolve()
out.mkdir(parents=True, exist_ok=False)
(out / 'modules').mkdir()


def identity(path):
    return dict(file=str(path), bytes=path.stat().st_size,
                sha256=hashlib.sha256(path.read_bytes()).hexdigest())


source = json.loads(reference.read_text())
recipe = json.loads(recipe_file.read_text())
assert source['complete'] and recipe['complete']
if recipe['kind'] == 'phase51-dispatch-prototype':
    edits = [(recipe['originalApply'], recipe['replacement'])]
elif recipe['kind'] == 'phase51-batched-string-guard':
    edits = [(e['old'], e['new']) for e in recipe['edits']]
else:
    raise ValueError('Unknown prototype recipe')
records, rows, seen = [], [], {}
for case in source['cases']:
    old = case['modules']['baseline']
    key = old['sha256']
    if key not in seen:
        path = reference.parent / old['path']
        original = path.read_bytes()
        assert hashlib.sha256(original).hexdigest() == key and len(original) == old['bytes']
        text = original.decode()
        for before, after in edits:
            assert text.count(before) == 1
            text = text.replace(before, after, 1)
        restored = text
        for before, after in reversed(edits):
            assert restored.count(after) == 1
            restored = restored.replace(after, before, 1)
        assert restored.encode() == original
        data = text.encode(); digest = hashlib.sha256(data).hexdigest()
        target = out / 'modules' / (digest + '.mjs'); target.write_bytes(data)
        seen[key] = dict(path=str(target.relative_to(out)), bytes=len(data), sha256=digest)
        records.append(dict(parent=identity(path), candidate=identity(target)))
    rows.append(dict(id=case['id'], point=case['point'], sourceSha256=case['sourceSha256'], modules={'candidate':seen[key]}))
manifest = dict(kind='bend-program-bundle', schemaVersion=1, complete=True,
    upstreamCommit=source['upstreamCommit'], catalogSha256=source['catalogSha256'],
    roles={'candidate':dict(label='UNQUALIFIED saved-JavaScript runtime prototype',
        compiler=dict(kind='saved-output-runtime-prototype', parent=source['roles']['baseline'], recipe=identity(recipe_file)))}, cases=rows)
(out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
(out / 'derivation.json').write_text(json.dumps(dict(complete=True, compilerExecuted=False,
    producer=identity(Path(__file__).resolve()), reference=identity(reference), recipe=identity(recipe_file),
    edits=edits, modules=records, scope='Runtime span substitutions only; no emitted source bodies changed; not a checked compiler artifact.'), indent=2) + '\n')
print(json.dumps(dict(complete=True, points=len(rows), modules=len(seen))))
