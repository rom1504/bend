#!/usr/bin/env python3
"""Bind a relocated bootstrap producer to its actual adjacent derivation."""
import ast
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
METHODS = ROOT/'selfhost/build/phase69/methods01'


def pin(p):
    p = p.resolve(strict=True)
    b = p.read_bytes()
    return dict(file=str(p), sha256=hashlib.sha256(b).hexdigest(), bytes=len(b))


parent, output = METHODS/'prepare-bootstrap.py', METHODS/'prepare-bootstrap-v2.py'
manifest = METHODS/'methods.json'
record = json.loads(manifest.read_text())
entries = [x for x in record['methods'] if x['name'] == 'prepare-bootstrap.py']
assert len(entries) == 1 and entries[0]['output'] == pin(parent)
text = parent.read_text()
old = "identity(Path(__file__).with_name('derivation.json'))"
new = "identity(Path(__file__).with_suffix('.derivation.json'))"
assert text.count(old) == 1
text = text.replace(old, new)
ast.parse(text)
with output.open('x') as f:
    f.write(text)
derivation = dict(kind='phase69-bootstrap-adjacent-receipt-correction', producer=pin(Path(__file__)),
                  parent=pin(parent), parentManifest=pin(manifest), parentMethod=entries[0],
                  output=pin(output), edits=[dict(before=old, after=new, count=1)],
                  dataOnly=True, targetsExecuted=False,
                  scope='Correct only the moved producer derivation filename. Actual parent is the frozen methods01 entry; the successor pins this adjacent complete parent/edit receipt. Bootstrap source/export/checking and image-generation commands are unchanged.')
with output.with_suffix('.derivation.json').open('x') as f:
    json.dump(derivation, f, indent=2)
    f.write('\n')
print(json.dumps(pin(output)))
