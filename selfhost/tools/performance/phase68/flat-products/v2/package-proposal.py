#!/usr/bin/env python3
"""Freeze data-only patch and hashes. Does not compile or execute Bend/C."""
from pathlib import Path
import difflib
import hashlib
import json

HERE = Path(__file__).resolve().parent
NAMES = ['flat.bend', 'bridge.bend', 'direct.bend', 'book.bend',
         'pattern.bend', 'parallel.bend', 'manifest.txt', 'compiler.json',
         'product.bend', 'product-layout.bend']
digest = lambda data: hashlib.sha256(data).hexdigest()
chunks, files = [], []
for name in NAMES:
    dest = 'selfhost/src/compiler.json' if name == 'compiler.json' else 'selfhost/src/back/native/' + name
    baseline = HERE / 'integration-baseline' / name
    old = baseline.read_bytes() if baseline.exists() else b''
    new = (HERE / 'candidate' / name).read_bytes()
    if old == new:
        continue
    chunks.extend(difflib.unified_diff(old.decode().splitlines(True), new.decode().splitlines(True),
                  fromfile='a/' + dest if baseline.exists() else '/dev/null', tofile='b/' + dest))
    files.append(dict(path=dest, baseSha256=digest(old) if baseline.exists() else None,
                      candidateSha256=digest(new), baseLines=len(old.splitlines()),
                      candidateLines=len(new.splitlines()), lineDelta=len(new.splitlines())-len(old.splitlines())))
patch = ''.join(chunks).encode()
(HERE / 'candidate.patch').write_bytes(patch)
manifest = dict(kind='phase68-flat-products-v2-source-candidate', experiment='P68-007', executed=False,
                registrationCommit='ee726e4',
                baseDescription='root flat-workers v3 plus admission shortcircuit v1, occurrence summary v1, and small-inline v1',
                patchSha256=digest(patch), lineDelta=sum(f['lineDelta'] for f in files), files=files,
                controls=['flat-product-record-v1', 'flat-product-array-v1', 'prefix-scratch-v2',
                          'aggregate-tail-swap', 'raw-unused-mistyped-product', 'flat-product-branch-drop-v1'],
                notes=['Frozen v1 remains unchanged; v2 adds syntactic layout query and branch-drop barriers',
                       'No compiler, C compiler or target executed in this lane',
                       'Lexical, hash and patch checks are not a checked Bend build',
                       'Private variants may increase C code size; no timing or parity claim'])
(HERE / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
print(json.dumps(dict(patchSha256=manifest['patchSha256'], lineDelta=manifest['lineDelta'], files=len(files))))
