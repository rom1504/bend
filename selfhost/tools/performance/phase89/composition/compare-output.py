#!/usr/bin/env python3
"""Exact complete-product identity plus independent state/order assertions."""
import hashlib,json,re,sys
from pathlib import Path
assert len(sys.argv)==5,'Usage: compare-output.py CONTROL.json JS_STDOUT NATIVE_STDOUT NEW_REPORT.json'
manifest,js,native,out=map(Path,sys.argv[1:]);meta=json.loads(manifest.read_text())
assert js.read_bytes()==native.read_bytes(),'Full JS/native outputs differ'
text=js.read_text()
def end_at(s,start):
    depth=0;quote=False;escape=False
    for i in range(start,len(s)):
        c=s[i]
        if quote:
            if escape:escape=False
            elif c=='\\':escape=True
            elif c=='"':quote=False
        elif c=='"':quote=True
        elif c=='{':depth+=1
        elif c=='}':
            depth-=1
            if not depth:return i
    raise AssertionError('Unbalanced constructor')
def fields(s):
    result=[];start=depth=0;quote=False;escape=False
    for i,c in enumerate(s):
        if quote:
            if escape:escape=False
            elif c=='\\':escape=True
            elif c=='"':quote=False
        elif c=='"':quote=True
        elif c in '{[(':depth+=1
        elif c in '}])':depth-=1
        elif c==',' and not depth:result.append(s[start:i].strip());start=i+1
    result.append(s[start:].strip());return result
seen={}
for m in re.finditer(r'P89Case\{',text):
    start=m.end()-1;name,old,new=fields(text[start+1:end_at(text,start)])
    name=json.loads(name);assert name not in seen and name in meta['cases'],name
    assert old==new,(name,'Complete NC_Code differs')
    assert new.startswith('NC_Code{') and new.endswith('}')
    body,segs,fresh,error,calls=fields(new[len('NC_Code{'):-1]);body=json.loads(body)
    e=meta['cases'][name]
    assert int(fresh)==e['fresh'] and json.loads(error)==e['error'],(name,fresh,error)
    assert json.loads(calls)==e['calls'],(name,calls)
    segnames=[json.loads(x[1]) for x in re.finditer(r'N_Segment\{\s*("(?:[^"\\]|\\.)*")',segs)]
    assert segnames==e['segments'],(name,segnames)
    assert all(part in body for part in e['bodyContains']),(name,body)
    assert ('!= CID_EMIT &&' in body)==e['guard'],name
    seen[name]=dict(fresh=int(fresh),error=json.loads(error),segments=segnames,calls=json.loads(calls),bodyBytes=len(body.encode()))
assert set(seen)==set(meta['cases'])
pin=lambda p:dict(file=str(p.resolve()),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
report=dict(kind='phase89-complete-composition-products',complete=True,passed=True,exactOutput=True,cases=seen,
            inputs=[pin(manifest),pin(js),pin(native)],method=pin(Path(__file__)))
with out.open('x') as f:json.dump(report,f,indent=2);f.write('\n')
print(json.dumps(dict(complete=True,cases=len(seen),exactOutput=True)))
