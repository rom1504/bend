#!/usr/bin/env python3
"""Extract unchanged canonical Bend declarations plus explicit workload drivers."""
import argparse
import hashlib
import importlib.util
from pathlib import Path
import sys
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
import source as assembly
from common import pin, require, fresh_output, write_json, verify
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--module',type=Path,action='append',required=True)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args()
recipe=ROOT/'selfhost/src/compiler.json'
canonical=assembly.maintained_assemble(recipe,ROOT/'selfhost','qbe')
require(hashlib.sha256(canonical).hexdigest()=='434edd1d56128f9480800573abf8a0ae21d910a547837af089f25cd1d0e89b71', 'Canonical parent changed')
_,rows=assembly.blocks(canonical)
rows=[r for r in rows if r['name']!='main']
names={r['name'] for r in rows}; additions=[]
inputs=[pin(__file__),pin(assembly.__file__),pin(recipe)]
for module in a.module:
    inputs.append(pin(module));_,new=assembly.blocks(module.read_bytes())
    require(not names.intersection(r['name'] for r in new),'Workload must not replace canonical definitions')
    names.update(r['name'] for r in new);additions.extend(new)
require('main' in names,'Explicit workload main required')
extractor_file=ROOT/'experiments/phase147/tools/prepare.py'
spec=importlib.util.spec_from_file_location('p173_extract',extractor_file)
extractor=importlib.util.module_from_spec(spec);spec.loader.exec_module(extractor)
inputs.append(pin(extractor_file))
selected,inventory=extractor.extract([('canonical-plus-driver',b'\n'.join(r['data'] for r in rows+additions))],['main'],4000000)
out=fresh_output(a.out,ROOT);(out/'compiler.bend').write_bytes(selected)
for item in inputs:verify(item)
write_json(out/'manifest.json',dict(kind='phase173-unchanged-compiler-workload',complete=True,targetsRun=False,
    inputs=inputs,canonicalSha256=hashlib.sha256(canonical).hexdigest(),source=pin(out/'compiler.bend'),declarations=inventory,
    scope='Exact dependency extraction and literal drivers only; no compiler algorithm replacement. Source and semantic gates pending.'))
print(pin(out/'compiler.bend'))
