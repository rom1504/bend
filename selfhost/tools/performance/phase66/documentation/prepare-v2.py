#!/usr/bin/env python3
"""Freeze full v2 documentation patch after independent source review."""
from pathlib import Path
import difflib, hashlib, json, os

assert os.sched_getaffinity(0) == {0}
OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[4]
sha = lambda data: hashlib.sha256(data).hexdigest()
parent = json.loads((OUT/'documentation-v1.json').read_text())
assert sha((OUT/'documentation-v1.patch').read_bytes()) == parent['patchSha256']
before, after = {}, {}
for row in parent['files']:
    name = row['path']
    before[name] = (OUT/'before-v1'/name).read_bytes()
    after[name] = (ROOT/row['candidate']).read_bytes()
    assert sha(before[name]) == row['beforeSha256']
    assert sha(after[name]) == row['afterSha256']
    assert sha((ROOT/name).read_bytes()) == row['beforeSha256']

name = 'docs/self_hosted/prepared-base-artifacts.md'
old = b'absent, explicit preparation also uses ordinary annotation.'
new = b'absent, explicit preparation also omits optional annotation products; later\ncompilation uses ordinary annotation.'
assert after[name].count(old) == 1
after[name] = after[name].replace(old, new)
name = 'docs/BEND-IN-BEND.md'
old = b'The current direct-image chain has a separate fresh source check and'
new = b'The historical Phase61 direct-image chain has a separate fresh source check and'
assert after[name].count(old) == 1
after[name] = after[name].replace(old, new)

rows, patch = [], []
for name in sorted(after):
    b, a = before[name], after[name]
    for prefix, raw in [('before-v2', b), ('candidate-v2', a)]:
        p = OUT/prefix/name
        p.parent.mkdir(parents=True, exist_ok=True)
        with p.open('xb') as f: f.write(raw)
    rows.append({'path':name, 'beforeSha256':sha(b), 'afterSha256':sha(a),
                 'beforeBytes':len(b), 'afterBytes':len(a),
                 'candidate':str((OUT/'candidate-v2'/name).relative_to(ROOT))})
    patch += list(difflib.unified_diff(b.decode().splitlines(True), a.decode().splitlines(True),
                                     fromfile='a/'+name, tofile='b/'+name))
raw = ''.join(patch).encode()
with (OUT/'documentation-v2.patch').open('xb') as f: f.write(raw)
meta = dict(parent, version=2, patchSha256=sha(raw), files=rows,
            producerSha256=sha(Path(__file__).read_bytes()),
            parentPatchSha256=parent['patchSha256'],
            review='Independent read-only source review verified all 11 hashes and exact patch reconstruction; v2 corrects preparation scope and one historical image label.')
with (OUT/'documentation-v2.json').open('x') as f: json.dump(meta,f,indent=2); f.write('\n')
print(json.dumps({'files':len(rows),'patchSha256':sha(raw),'status':meta['status']}))
