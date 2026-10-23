#!/usr/bin/env python3
"""Authenticate actual first-order summary declarations against proof closures.

This source identity certificate does not prove generic KTerm traversal,
backend translation, machine code, ownership or performance.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT=Path(__file__).resolve().parents[5]
HERE=Path(__file__).resolve().parent

def pin(path):
    path=Path(path).resolve()
    return dict(file=str(path),bytes=path.stat().st_size,sha256=hashlib.sha256(path.read_bytes()).hexdigest())

def decl(text,name):
    found=re.findall(r'^(?:def|type) '+re.escape(name)+r'\b[\s\S]*?(?=\n\n|\Z)',text,re.M)
    assert len(found)==1,(name,len(found))
    return found[0].strip()

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--source',type=Path,required=True)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args();source=a.source.resolve();out=a.out.resolve()
assert source.is_relative_to(ROOT) and out.is_relative_to(ROOT/'selfhost/build/phase131') and not out.exists()
proofs=['laws-add01','laws-low01','laws-high01','laws-absent04','laws-first-order-summary01']
origins={};receipts=[]
for name in proofs:
    path=ROOT/'selfhost/build/phase131'/name/'report.json';r=json.loads(path.read_text())
    assert r['complete'] and r['independentlyChecked'] and not r['opaqueDefinitions']
    assert pin(r['elaboration']['file'])==r['elaboration']
    for row in r['sourceClosure']:
        assert pin(row['snapshot']['file'])==row['snapshot']
        origins[row['origin']['file']]=row['origin']
    receipts.append(pin(path))
files={'production.bend':['p131a_add','p131a_low','p131a_high'],
       'absent-production.bend':['P131UEntry','p131u_absent'],
       'lookup-first-order-v02.bend':['p131u_max_loop','p131u_max','p131u_min_loop','p131u_min'],
       'merge-first-order-v01.bend':['p131u_merge_loop','p131u_merge']}
text=source.read_text();checked=[];inputs=[]
for filename,names in files.items():
    path=HERE/filename; item=pin(path);assert origins[str(path)]==item;inputs.append(item)
    proof=path.read_text()
    for name in names:
        before=decl(proof,name);after=before.replace('A.','').replace('P.','')
        assert decl(text,name)==after,name
        checked.append(name)
out.mkdir(parents=True)
(out/'method.py').write_bytes(Path(__file__).read_bytes())
result=dict(complete=True,method=pin(__file__),source=pin(source),inputs=inputs,proofReceipts=receipts,
            exactDeclarations=checked,namespaceRemoval=['A.','P.'],
            coverage='Exact safe first-order algorithm bodies, all-input equivalence to prior safe algorithms, aligned max/min lookup specification and bounded-count algebra. Generic KTerm traversal, differing-key map specification, callers and backend/runtime are not proved.')
(out/'report.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(complete=True,exactDeclarations=checked)))
