#!/usr/bin/env python3
"""Admit the two explicit raw-book data encodings, without changing oracles."""
import ast
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent


def pin(p):
    b = p.read_bytes()
    return dict(file=str(p), sha256=hashlib.sha256(b).hexdigest(), bytes=len(b))


def derive(parent, destination, old, new):
    text = parent.read_text()
    assert text.count(old) == 1
    text = text.replace(old, new)
    if destination.suffix == '.py':
        ast.parse(text)
    with destination.open('x') as f:
        f.write(text)
    with destination.with_suffix('.derivation.json').open('x') as f:
        json.dump(dict(kind='phase69-raw-array-book-successor', parent=pin(parent),
                       output=pin(destination), producer=pin(Path(__file__).resolve()),
                       edits=[dict(before=old, after=new, count=1)], dataOnly=True,
                       targetsExecuted=False,
                       scope='Normalize raw module JS-array books through the same existing Con/Nil helper. Prebuilt Con/Nil books and every behavioral oracle remain unchanged.'), f, indent=2)
        f.write('\n')


derive(HERE/'raw-controls-custom-v1.mjs', HERE/'raw-controls-custom-v2.mjs',
       "const got=api.nc_compile(test.book,runtime,'');",
       "const got=api.nc_compile(Array.isArray(test.book)?list(test.book):test.book,runtime,'');")
derive(HERE/'prepare-custom-raw.py', HERE/'prepare-custom-raw-v2.py',
       "raw-controls-custom-v1.mjs", "raw-controls-custom-v2.mjs")
print(json.dumps(dict(runner=pin(HERE/'raw-controls-custom-v2.mjs'),
                      preparer=pin(HERE/'prepare-custom-raw-v2.py'), targetsExecuted=False)))
