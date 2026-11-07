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
p.add_argument('--prelude', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
inputs = [pin(__file__), pin(source.__file__), pin(a.source), pin(a.module), pin(a.prelude)]
for item in inputs: verify(item)
original = a.source.read_bytes()
prefix, rows = source.blocks(original)
_, changes = source.blocks(a.module.read_bytes())
_, preludes = source.blocks(a.prelude.read_bytes())
new_defs = [r for r in changes if r['name'] != a.replace]
require(all(r['kind'] == 'def' for r in new_defs), 'New helpers must be definitions')
helper_names = {r['name'] for r in new_defs}
require(len(helper_names) == len(new_defs) and helper_names and
        not helper_names.intersection(r['name'] for r in rows), 'Distinct new helper names required')
require(all(r['kind'] == 'law' for r in preludes) and
        {r['name'] for r in preludes} == helper_names, 'Exactly the new helper laws required')
replacements = [r for r in changes if r['name'] == a.replace and r['kind'] == 'def']
require(len(replacements) == 1, 'One named replacement required')
matches = [r for r in rows if r['name'] == a.replace and r['kind'] == 'def']
require(len(matches) == 1, 'Exactly one original definition required')
old, new = matches[0], replacements[0]
require(old['data'] != new['data'], 'No-op transplant')
insert = b''.join(r['data'] for r in preludes) + new['data']
output = prefix + b''.join(insert if r is old else r['data'] for r in rows)
output += b''.join(r['data'] for r in new_defs)
_, after = source.blocks(output)
kept = [r for r in after if r['name'] not in helper_names]
require([(r['kind'], r['name']) for r in rows] ==
        [(r['kind'], r['name']) for r in kept], 'Original declaration inventory changed')
restored = prefix + b''.join(old['data'] if r['name'] == a.replace and
                            r['kind'] == 'def' else r['data'] for r in kept)
require(restored == original, 'Exact inverse transplant failed')
for item in inputs: verify(item)
out = fresh_output(a.out, ROOT)
(out/'compiler.bend').write_bytes(output)
write_json(out/'manifest.json', dict(kind='phase173-exact-source-variant', complete=True,
    targetsRun=False, inputs=inputs, source=pin(out/'compiler.bend'),
    replacement=a.replace, addedHelpers=sorted(helper_names), originalSha256=hashlib.sha256(old['data']).hexdigest(),
    replacementSha256=hashlib.sha256(new['data']).hexdigest(), inverseExact=True,
    scope='One source definition differs and explicitly declared helpers are added. Independent source and semantic checks still required.'))
print(pin(out/'compiler.bend'))
