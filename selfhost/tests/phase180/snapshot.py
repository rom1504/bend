#!/usr/bin/env python3
"""Freeze maintained source and explicit Bend declaration replacements only."""
import hashlib
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
import source
from common import fresh_output, pin, write_json, require

out = fresh_output(Path(sys.argv[1]), ROOT)
recipe = ROOT/'selfhost/src/compiler.json'
config = json.loads(recipe.read_text())
baseline = source.maintained_assemble(recipe, ROOT/'selfhost', 'qbe')
if isinstance(baseline, tuple): baseline = baseline[0]
require(hashlib.sha256(baseline).hexdigest() ==
        '8fd5043cd47361474ab9da6713687a2fd0825d8a7f0885192e5f70f67d7994db',
        'Baseline changed; explicit project review required')
prefix, blocks = source.blocks(baseline)
original = {(b['kind'],b['name']):b for b in blocks}
files = [Path(__file__).with_name(n) for n in
         ['application-accessors.bend','application-core.bend','application-substitution.bend','application-laws.bend']]
edits = {}
for path in files:
    _, rows = source.blocks(path.read_bytes())
    for b in rows:
        key = b['kind'],b['name']
        require(key not in edits, 'Repeated delta: '+str(key))
        require(b['name'] not in config['protectedDeclarations'], 'Protected delta: '+b['name'])
        edits[key] = b
replacement_keys = set(edits).intersection(original)
additions = [b for k,b in edits.items() if k not in original and b['kind']!='law']
laws = [b for k,b in edits.items() if k not in original and b['kind']=='law']
# New helper declarations follow KTerm's definition; their laws precede first use.
chunks = [prefix]
for b in blocks:
    key = b['kind'],b['name']
    chunks.append(edits.get(key,b)['data'])
    if key == ('type','KTerm'):
        chunks.extend(r['data'] for r in laws)
chunks.extend(b['data'] for b in additions)
candidate = b'\n'.join(chunks)
(out/'baseline.bend').write_bytes(baseline)
(out/'candidate.bend').write_bytes(candidate)
write_json(out/'report.json',dict(kind='phase180-representation-snapshot',complete=True,
    inputs=[pin(__file__),pin(recipe),*[pin(f) for f in files]],
    baseline=pin(out/'baseline.bend'),candidate=pin(out/'candidate.bend'),
    replacements=[dict(kind=k[0],name=k[1],originalSha256=hashlib.sha256(original[k]['data']).hexdigest(),
                       replacementSha256=hashlib.sha256(edits[k]['data']).hexdigest()) for k in sorted(replacement_keys)],
    additions=[dict(kind=b['kind'],name=b['name']) for b in additions+laws],
    protectedUnchanged=True,scope='Text transport only; no parsing/checking semantics or qualification.'))
print(json.dumps(dict(baseline=len(baseline),candidate=len(candidate),replacements=len(replacement_keys))))
