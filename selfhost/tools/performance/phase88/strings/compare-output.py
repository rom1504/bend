#!/usr/bin/env python3
"""Check both executions against each other, Base, and a codepoint oracle."""
import hashlib, json, re, sys
from pathlib import Path

assert len(sys.argv)==5, 'Usage: compare-output.py CONTROL.json JS_STDOUT C_STDOUT NEW_REPORT.json'
manifest,js,c,out=map(Path,sys.argv[1:])
meta=json.loads(manifest.read_text()); corpus=meta['corpus']; n=len(corpus)
assert js.read_bytes()==c.read_bytes(), 'JS/native complete observations differ'
text=js.read_text(); matches=list(re.finditer(r'P88StringCheck\{([^{}]*)\}',text)); seen=set()
for match in matches:
    values=[int(x.strip()) for x in match[1].split(',')]
    assert len(values)==12,values
    i,j,*actual=values
    assert 0<=i<n and 0<=j<n and (i,j) not in seen,(i,j)
    seen.add((i,j));a,b=corpus[i],corpus[j]
    eq=int(a==b);order=0 if a<b else 1 if a==b else 2
    expected=[eq,eq,eq,order,order,order,len(a),len(b),sum(a)%(2**32),sum(b)%(2**32)]
    assert actual==expected,(i,j,a,b,actual,expected)
assert len(seen)==n*n==meta['pairs'],(len(seen),n*n)
pin=lambda p:dict(file=str(p.resolve()),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
report=dict(kind='phase88-consuming-string-controls',complete=True,passed=True,strings=n,pairs=n*n,
            exactOutput=True,oracle='lexicographic Unicode codepoint lists; equality; reused lengths and codepoint sums',
            inputs=[pin(manifest),pin(js),pin(c)],method=pin(Path(__file__)))
with out.open('x') as f:json.dump(report,f,indent=2);f.write('\n')
print(json.dumps(dict(complete=True,strings=n,pairs=n*n,exactOutput=True)))
