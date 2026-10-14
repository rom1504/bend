#!/usr/bin/env python3
"""Exact JS/native tree-control equality and independent code-point oracle."""
import hashlib,json,re,sys
from pathlib import Path
assert len(sys.argv)==4,'Usage: compare-controls.py JS_STDOUT NATIVE_STDOUT NEW_REPORT.json'
here=Path(__file__).resolve().parent
paths=list(map(Path,sys.argv[1:3]));out=Path(sys.argv[3]);raw=[p.read_bytes() for p in paths]
assert raw[0]==raw[1],'JS/native complete tree outputs differ'
expected=json.loads((here/'controls.json').read_text())['expected']
token=re.compile(r'P89TextCase\{\s*("(?:\\.|[^"\\])*")\s*,\s*("(?:\\.|[^"\\])*")\s*,\s*(True|False)\{\}\s*,\s*(True|False)\{\}\s*,\s*(True|False)\{\}\s*,\s*(True|False)\{\}\s*,\s*(True|False)\{\}\s*\}')
seen={}
for m in token.finditer(raw[0].decode()):
    name=json.loads(m[1]);assert name not in seen
    seen[name]=dict(text=json.loads(m[2]),**{k:m[i]=='True' for i,k in enumerate(['empty','within0','within4095','within4096','within4097'],3)})
assert seen==expected,dict(missing=sorted(set(expected)-set(seen)),extra=sorted(set(seen)-set(expected)),wrong=[k for k in seen if k in expected and seen[k]!=expected[k]])
pin=lambda p:dict(file=str(p.resolve()),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
report=dict(kind='phase89-body-tree-controls',complete=True,passed=True,exactOutput=True,cases=len(seen),assertions=6*len(seen),
            inputs=[pin(p) for p in paths]+[pin(here/'controls.json'),pin(Path(__file__))],
            lengths={k:len(v['text']) for k,v in seen.items()})
with out.open('x') as f:json.dump(report,f,indent=2);f.write('\n')
print(json.dumps(dict(complete=True,cases=len(seen),assertions=6*len(seen))))
