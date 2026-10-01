#!/usr/bin/env python3
"""Bind the frozen tree input variants to the same saved-output ablations."""
import argparse,hashlib,json
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('derived',type=Path);p.add_argument('catalog',type=Path)
p.add_argument('baseline',type=Path);p.add_argument('out',type=Path)
a=p.parse_args();assert not a.out.exists()
def digest(file):return hashlib.sha256(Path(file).read_bytes()).hexdigest()
config=json.loads((a.derived/'compare.json').read_text())
catalog=json.loads(a.catalog.read_text());baseline=json.loads(a.baseline.read_text())
assert baseline['complete'] and baseline['catalogSha256']==digest(a.catalog)
ids=['tree-bitonic','variation-tree-bitonic-6-17','variation-tree-bitonic-9-123']
modules=config['cases'][0]['modules'];cases=[]
for name in ids:
 case=next(c for c in catalog['cases'] if c['id']==name)
 prepared=next(c for c in baseline['cases'] if c['id']==name)
 assert case['point']==prepared['point'] and case['source']['sha256']==prepared['sourceSha256']
 module=prepared['modules']['baseline']
 assert digest(a.baseline.parent/module['path'])==module['sha256']==digest(modules['original'])
 cases.append(dict(id=name,point=case['point'],modules=modules))
out=dict(inputs=config['inputs']+[str(Path(__file__).resolve()),str(a.catalog.resolve()),str(a.baseline.resolve())],cases=cases)
a.out.write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps(dict(complete=True,cases=len(cases),roles=len(modules),out=str(a.out))))
