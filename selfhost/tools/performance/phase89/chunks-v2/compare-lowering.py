#!/usr/bin/env python3
"""Compare actual old/new recursive lowering products, with non-vacuity checks."""
import hashlib,json,re,sys
from pathlib import Path
assert len(sys.argv)==5,'Usage: compare-lowering.py OLD_JS NEW_JS NEW_NATIVE NEW_REPORT.json'
paths=list(map(Path,sys.argv[1:4]));out=Path(sys.argv[4]);data=[p.read_bytes() for p in paths]
assert data[0]==data[1]==data[2],'Complete lowering results differ'
text=data[0].decode()
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
for m in re.finditer(r'P89LowerCase\{',text):
    start=m.end()-1;name,code=fields(text[start+1:end_at(text,start)]);name=json.loads(name)
    assert name not in seen and code.startswith('P89Code{') and code.endswith('}')
    body,segs,fresh,error,calls=fields(code[len('P89Code{'):-1]);body=json.loads(body)
    seen[name]=dict(bodyBytes=len(body.encode()),fresh=int(fresh),error=json.loads(error),segments=segs.count('N_Segment{'),calls=json.loads(calls))
expected={'scalar':'','field-count':'','hit-error':'native lowering does not support core node HitUnsupported',
          'miss-error':'native lowering does not support core node MissUnsupported',
          'both-errors':'native lowering does not support core node HitUnsupported',
          'hit-closure':'','both-closures':'','flat-scalar':'','flat-closure-refusal':'flat worker: escaping closure'}
assert set(seen)==set(expected)
for name,error in expected.items():
    assert seen[name]['error']==error,(name,seen[name])
    assert seen[name]['bodyBytes']>0,(name,'Missing match wrapper')
assert seen['scalar']['fresh']==100
assert seen['field-count']['fresh']==102
assert seen['hit-closure']['segments']>=1 and seen['hit-closure']['fresh']>100
assert seen['both-closures']['segments']>=2 and seen['both-closures']['fresh']>seen['hit-closure']['fresh']
pin=lambda p:dict(file=str(p.resolve()),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
with out.open('x') as f:json.dump(dict(kind='phase89-body-chunks-lowering-products',complete=True,passed=True,exactOutput=True,cases=seen,inputs=[pin(p) for p in paths],method=pin(Path(__file__))),f,indent=2);f.write('\n')
print(json.dumps(dict(complete=True,cases=len(seen),exactOutput=True)))
