#!/usr/bin/env python3
"""Extract private checked Bend experiments from the exact maintained parent.

This transports source declarations only. Semantic changes live in explicit Bend
modules; source checking and compilation remain the real compiler's work.
"""
import argparse,hashlib,importlib.util,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];sys.dont_write_bytecode=True
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
import source as assembly
from common import fresh_output,pin,require,write_json
spec=importlib.util.spec_from_file_location('extract163',ROOT/'experiments/phase147/tools/prepare.py')
E=importlib.util.module_from_spec(spec);spec.loader.exec_module(E)
p=argparse.ArgumentParser();p.add_argument('--module',type=Path,action='append',default=[])
p.add_argument('--export',action='append',default=[]);p.add_argument('--allow-overrides',action='store_true')
p.add_argument('--out',type=Path,required=True);a=p.parse_args()
manifest=ROOT/'selfhost/src/compiler.json';qfile=ROOT/'implementation/phase152/qualification.json'
q=json.loads(qfile.read_text());canonical=assembly.maintained_assemble(manifest,ROOT/'selfhost','qbe')
require(hashlib.sha256(canonical).hexdigest()==q['source']['sha256'],'Maintained parent changed')
_,original=assembly.blocks(canonical);original=[r for r in original if r['name']!='main']
keys={(r['kind'],r['name']) for r in original};names={r['name'] for r in original};extra=[];overrides={};inputs=[pin(__file__),pin(E.__file__),pin(assembly.__file__),pin(manifest),pin(qfile)]
protected=json.loads(manifest.read_text()).get('protectedDeclarations',{})
for path in a.module:
 path=path.resolve();inputs.append(pin(path));_,rows=assembly.blocks(path.read_bytes())
 for row in rows:
  key=(row['kind'],row['name'])
  if row['name'] in names:
   require(a.allow_overrides and key in keys,'Unexpected source replacement '+row['name'])
   require(row['name'] not in protected,'Protected declaration replacement refused '+row['name'])
   require(key not in overrides,'Duplicate replacement');overrides[key]=row
  else:extra.append(row)
body=b''.join(overrides.get((r['kind'],r['name']),r)['data'] for r in original)
body+=b'\n'+b'\n'.join(r['data'] for r in extra)
exports=list(dict.fromkeys(a.export));require(exports,'Explicit exports required')
selected,inventory=E.extract([('private-compiled-Bend',body)],exports,4_000_000)
out=fresh_output(a.out,ROOT);(out/'compiler.bend').write_bytes(selected)
write_json(out/'exports.json',dict(kind='bend-hosted-api-exports',version=1,exports=exports,protocol='hosted-api-v1',targets=['qbe'],preparationModes=['live'],scope='Private architecture experiment; no installed image/ABI claim.'))
write_json(out/'manifest.json',dict(complete=True,targetsRun=False,inputs=inputs,parentSource=q['source'],source=pin(out/'compiler.bend'),exports=exports,replacements=[list(k) for k in overrides],declarations=inventory,protectedUnchanged=True))
print(json.dumps(dict(source=pin(out/'compiler.bend'),declarations=len(inventory),overrides=len(overrides))))
