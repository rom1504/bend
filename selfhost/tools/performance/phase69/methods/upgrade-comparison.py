#!/usr/bin/env python3
"""Correct the inherited aggregate field label without changing observations."""
import argparse
import ast
import hashlib
import json
from pathlib import Path


def pin(p):
    p = Path(p).resolve(strict=True)
    b = p.read_bytes()
    return dict(file=str(p), sha256=hashlib.sha256(b).hexdigest(), bytes=len(b))


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--parent', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
before = a.parent.read_text()
old, new = 'geomeanBaseline20OverCandidate', 'geomeanBaseline23OverCandidate'
assert before.count(old) == 1 and 'native-facts23-lexer' in before
after = before.replace(old, new)
ast.parse(after)
with a.out.open('x') as f:
    f.write(after)
derivation = dict(kind='phase69-runtime-comparison-label-fix', producer=pin(__file__),
                  parent=pin(a.parent), output=pin(a.out),
                  edits=[dict(before=old, after=new, count=1)], dataOnly=True,
                  scope='Only the aggregate result field label changes20→23. The prior method already executed actual compiler23; artifacts, clocks, counts, roles and checks are identical.')
with a.out.with_suffix('.derivation.json').open('x') as f:
    json.dump(derivation, f, indent=2)
    f.write('\n')
print(json.dumps(pin(a.out)))
