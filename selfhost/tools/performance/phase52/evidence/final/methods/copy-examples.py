#!/usr/bin/env python3
"""Copy three exact source/module examples; no compiler or generated program execution."""
import argparse
import json
from pathlib import Path
import shutil
import sys
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
PROGRAMS = HERE.parent / 'programs'
sys.path.insert(0, str(PROGRAMS))
from support import identity, save
from run import load_bundle

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--candidate', type=Path, required=True)
p.add_argument('--reference', type=Path, required=True)
p.add_argument('--catalog', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
assert not a.out.exists(), 'Fresh output required'
inputs = [identity(x) for x in [__file__, PROGRAMS/'run.py', PROGRAMS/'support.py', a.catalog]]
catalog = json.loads(a.catalog.read_text())
ids = ['test-rle-roundtrip', 'lexer', 'coverage-expression-128']
selected = [next(c for c in catalog['cases'] if c['id'] == name) for name in ids]
sha = identity(a.catalog)['sha256']
bundles = {'direct': load_bundle(a.candidate, catalog, sha, selected, ['candidate'], inputs),
           'typescript': load_bundle(a.reference, catalog, sha, selected, ['baseline','typescript'], inputs)}
compiler = bundles['direct']['roles']['candidate']['compiler']
assert compiler['api']['sha256'] == '472da578ff9066413f0a2b8e5c0053b5bc26eae8c3cb343b5b0cbb2a62c03a3a'
assert compiler['directRuntime']['sha256'] == '417d2d47f98116d4eae889ff53132d9255c8a0ffaf047dd497b877f2df0c188a'
assert compiler['callingContract'] == 'upstream-compatible-direct-v1'
assert catalog['upstreamCommit'] == '018751270e800bc222a93dad7f257083ee53a5f7'
for path in [a.candidate, a.reference]:
    assert 'archive' not in json.loads(path.read_text()), 'Use exact verified loose acquisition inputs'
a.out.mkdir(parents=True, exist_ok=False)
copies = []
def copy(source, relative, expected=None):
    source = Path(source).resolve(strict=True)
    before = identity(source)
    if expected:
        assert before['sha256'] == expected['sha256']
        assert 'bytes' not in expected or before['bytes'] == expected['bytes']
    inputs.append(before)
    target = a.out / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, target)
    after = identity(target)
    assert after['sha256'] == before['sha256'] and after['bytes'] == before['bytes']
    row = dict(path=relative, sha256=after['sha256'], bytes=after['bytes'], original=before)
    copies.append(row)
    return row
copy(a.catalog, 'catalog.json')
copy(a.candidate, 'selected-manifest.json')
copy(a.reference, 'reference-manifest.json')
rows = []
for c in selected:
    name = c['id']
    row = dict(id=name, point=c['point'], source=copy(a.catalog.resolve().parent/c['source']['path'], name+'/source.bend', c['source']), modules={})
    for label, role, manifest in [('direct','candidate',a.candidate), ('typescript','typescript',a.reference)]:
        entry = bundles[label]['points'][name][role]
        row['modules'][label] = copy(manifest.resolve().parent/entry['path'], name+'/'+label+'.mjs', entry)
    rows.append(row)
for item in inputs:
    assert identity(item['path']) == item, item['path']
index = dict(kind='phase52-exact-generated-code-examples', complete=True, dataOnly=True,
    scope='Three exact source-shape examples, not independent speed measurements. Whole modules retain runtime support. Original catalog/manifests are provenance copies; their original relative paths are not repointed.',
    compiler=compiler, upstreamCommit=catalog['upstreamCommit'], inputs=inputs, copies=copies, examples=rows, inputsUnchanged=True)
save(a.out/'index.json', index)
text = ['# Exact generated-code examples', '',
    'These are unchanged selected direct06 and pinned TypeScript modules for three benchmark sources. Each whole module includes its runtime support. No code has been normalized, reformatted or postprocessed. Copying these files executed neither compiler nor generated program.', '',
    'They illustrate source and generated-code shapes. They have no independent speed claim; use the complete45-point performance report for measurements and its semantic-scope limits. The direct files use the upstream-compatible callable contract, not the legacy mutable-G interface.', '',
    '| Example | Bend source | Direct06 | TypeScript |', '| --- | --- | --- | --- |']
for row in rows:
    name = row['id']
    text.append(f'| `{name}` | [source]({name}/source.bend) | [module]({name}/direct.mjs) | [module]({name}/typescript.mjs) |')
text.extend(['', 'The [index](index.json) records exact original and copied source/module hashes, selected compiler identity and catalog point/oracle. The preserved [catalog](catalog.json), [selected manifest](selected-manifest.json) and [reference manifest](reference-manifest.json) retain their original bytes and paths as provenance, not a relocated executable bundle. The portable benchmark bundles provide that separate replay interface.', '',
    'Selected derived-B1 API: `'+compiler['api']['sha256']+'`.', 'Pinned upstream: `'+catalog['upstreamCommit']+'`.', ''])
(a.out/'README.md').write_text('\n'.join(text))
print(json.dumps(dict(complete=True, examples=len(rows), copied=len(copies), index=identity(a.out/'index.json'))))
