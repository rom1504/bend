#!/usr/bin/env python3
"""Exact named definition transplant for an experimental workload; no targets."""
import argparse
import hashlib
from pathlib import Path
import sys
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
import source
from common import pin, verify, require, fresh_output, write_json

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--source', type=Path, required=True)
p.add_argument('--module', type=Path, required=True)
p.add_argument('--replace', required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
inputs = [pin(__file__), pin(source.__file__), pin(a.source), pin(a.module)]
for item in inputs: verify(item)
original = a.source.read_bytes()
prefix, rows = source.blocks(original)
_, changes = source.blocks(a.module.read_bytes())
require(len(changes) == 1 and changes[0]['kind'] == 'def' and
        changes[0]['name'] == a.replace, 'Exactly one named definition required')
matches = [r for r in rows if r['name'] == a.replace and r['kind'] == 'def']
require(len(matches) == 1, 'Exactly one original definition required')
old, new = matches[0], changes[0]
require(old['data'] != new['data'], 'No-op transplant')
output = prefix + b''.join(new['data'] if r is old else r['data'] for r in rows)
_, after = source.blocks(output)
require([(r['kind'], r['name']) for r in rows] ==
        [(r['kind'], r['name']) for r in after], 'Declaration inventory changed')
restored = prefix + b''.join(old['data'] if r['name'] == a.replace and
                            r['kind'] == 'def' else r['data'] for r in after)
require(restored == original, 'Exact inverse transplant failed')
for item in inputs: verify(item)
out = fresh_output(a.out, ROOT)
(out/'compiler.bend').write_bytes(output)
write_json(out/'manifest.json', dict(kind='phase173-exact-source-variant', complete=True,
    targetsRun=False, inputs=inputs, source=pin(out/'compiler.bend'),
    replacement=a.replace, originalSha256=hashlib.sha256(old['data']).hexdigest(),
    replacementSha256=hashlib.sha256(new['data']).hexdigest(), inverseExact=True,
    scope='One explicit source definition differs. Independent source and semantic checks still required.'))
print(pin(out/'compiler.bend'))
