#!/usr/bin/env python3
"""Rejected-candidate diagnostic: remove only fusion-root proof open/close."""
from pathlib import Path
import argparse,hashlib,json

def identity(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
a=argparse.ArgumentParser();a.add_argument('module',type=Path);a.add_argument('out',type=Path);a=a.parse_args()
parent=identity(a.module);assert parent['sha256']=='ac3deb19cb98e1beab263f5284de50a7b229292d6b9c0ce7122a3f803a370091'
s=a.module.read_text();line=next(l for l in s.splitlines() if l.startswith('G["bench"]=scalarCapture'))
assert line.count('/* private total scalar fusion */')==1
opening='const $previousProof=regionProofOpen($guards);';closing='finally{regionProofClose($previousProof);}'
assert line.count(opening)==1 and line.count(closing)==1
replacement=line.replace(opening,'').replace(closing,'finally{}')
new=s.replace(line,replacement);assert new!=s
out=a.out.resolve();out.mkdir(exist_ok=False,parents=True);frozen=out/'consumed-derive.py';frozen.write_bytes(Path(__file__).read_bytes())
rows=[]
for name,text in [('original',s),('no-scope',new)]:
 p=out/(name+'.mjs');p.write_text(text);rows.append(dict(role=name,**identity(p)))
report={'kind':'phase42-fusion-entry-rejection','complete':True,'checked':False,'certified':False,'decision':'reject pending public pre-import reentry counterexample execution','parent':parent,'producer':identity(frozen),'modules':rows,'scope':'Diagnostic removes only fusion-root regionProofOpen/Close. Original exact entry, canonical input, host and dependency checks retained. No production edit.'}
(out/'derive.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({'complete':True,'out':str(out)}))
