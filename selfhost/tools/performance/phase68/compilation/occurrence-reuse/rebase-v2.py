#!/usr/bin/env python3
"""Replay the already-reviewed local edits onto the actual Products10 snapshot."""
import difflib
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]
OUT = ROOT/'selfhost/build/phase68/occurrence-reuse-proposal02'
assert not OUT.exists()


def pin(p):
    p = Path(p).resolve(strict=True)
    data = p.read_bytes()
    return dict(file=str(p), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


parent_path = HERE/'candidate-v1.json'
parent = json.loads(parent_path.read_text())
attempt_path = ROOT/'selfhost/build/phase68/products-build10/attempt.json'
attempt = json.loads(attempt_path.read_text())
assert attempt['checked'] and attempt['config']['strictExact']
assert attempt['artifactKind'] == 'derived-b1'
inputs = [pin(attempt_path), pin(attempt['api']['file']), pin(parent_path), pin(__file__)]
assert inputs[1]['sha256'] == attempt['api']['sha256']
for row in attempt['snapshot']['sources']:
    p = pin(row['frozen']['file'])
    assert p['sha256'] == row['frozen']['sha256']
    inputs.append(p)
OUT.mkdir()
files = []
for f in parent['files']:
    relative = f['path'].removeprefix('selfhost/')
    source = Path(attempt['snapshot']['root'])/relative
    before = source.read_text()
    after = before
    for edit in f['edits']:
        assert after.count(edit['before']) == edit['count']
        after = after.replace(edit['before'], edit['after'])
    old, new = OUT/(source.stem+'-before.bend'), OUT/(source.stem+'-after.bend')
    old.write_text(before)
    new.write_text(after)
    files.append(dict(path=f['path'], source=pin(source), before=pin(old), after=pin(new),
        edits=f['edits'], lineDelta=len(after.splitlines())-len(before.splitlines())))
patch = HERE/'candidate-v2.patch'
assert not patch.exists()
patch.write_text(''.join(''.join(difflib.unified_diff(
    Path(f['before']['file']).read_text().splitlines(True),
    Path(f['after']['file']).read_text().splitlines(True),
    fromfile='a/'+f['path'], tofile='b/'+f['path'])) for f in files))
result = dict(kind='phase68-native-local-occurrence-reuse', version=2,
    status='isolated-unselected-no-target', parent=pin(parent_path), producer=pin(__file__),
    baselineAttempt=pin(attempt_path), baselineApi=pin(attempt['api']['file']),
    files=files, patch=pin(patch), lineDelta=sum(f['lineDelta'] for f in files),
    newTypes=0, newFunctions=0, invariant=parent['invariant'],
    productBoundary='Only the unchanged boxed-binding algorithm is rewritten, now named nf_bind_boxed. NC_Code calls metadata and target fields are preserved exactly. nq_bind original/substituted bodies remain untouched; no occurrence-index identity comparison is introduced.',
    inputs=inputs)
manifest = HERE/'candidate-v2.json'
assert not manifest.exists()
manifest.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(manifest=pin(manifest), patch=pin(patch), lineDelta=result['lineDelta'])))
