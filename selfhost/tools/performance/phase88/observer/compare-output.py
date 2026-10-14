#!/usr/bin/env python3
"""Compare complete observer products and independently check intended case coverage."""
import hashlib,json,re,sys
from pathlib import Path
assert len(sys.argv)==5,'Usage: compare-output.py OLD_JS_STDOUT NEW_JS_STDOUT NEW_NATIVE_STDOUT NEW_REPORT.json'
files=list(map(Path,sys.argv[1:4]));out=Path(sys.argv[4])
data=[p.read_bytes() for p in files]
assert data[0]==data[1]==data[2],'Complete printed analysis products differ; retain all outputs'
text=data[0].decode()
def matching(s,start):
    depth=0;quoted=False;escape=False
    for i in range(start,len(s)):
        c=s[i]
        if quoted:
            if escape:escape=False
            elif c=='\\':escape=True
            elif c=='"':quoted=False
        elif c=='"':quoted=True
        elif c=='{':depth+=1
        elif c=='}':
            depth-=1
            if depth==0:return i
    raise AssertionError('Unbalanced printed constructor')
def fields(s):
    out=[];start=0;depth=0;quoted=False;escape=False
    for i,c in enumerate(s):
        if quoted:
            if escape:escape=False
            elif c=='\\':escape=True
            elif c=='"':quoted=False
        elif c=='"':quoted=True
        elif c in '{[(':depth+=1
        elif c in '}])':depth-=1
        elif c==',' and depth==0:out.append(s[start:i].strip());start=i+1
    out.append(s[start:].strip());return out
rows={}
for match in re.finditer(r'P88Case\{',text):
    begin=match.end()-1;parts=fields(text[begin+1:matching(text,begin)])
    assert len(parts)==2
    name=json.loads(parts[0]);assert name not in rows
    analysis=parts[1];assert analysis.startswith('NO_Analysis{') and analysis.endswith('}')
    body,fresh,fuel,error=fields(analysis[len('NO_Analysis{'):-1])
    tag=re.match(r'KTerm\{\s*("(?:[^"\\]|\\.)*")',body)
    assert tag,(name,body)
    rows[name]=dict(tag=json.loads(tag[1]),fresh=int(fresh),fuel=int(fuel),error=json.loads(error))
success=['literal','application','nested-application','let-body','constructor-fields','virtual-match-yes','virtual-match-no','primitive-prefix']
expected={n:('NO_Return' if n!='primitive-prefix' else 'NO_Let','') for n in success}
expected.update({
 'symbolic-fresh-order':('NO_Match',''),
 'symbolic-resume-both':('NO_Match',''),
 'symbolic-first-error':('Absent','observer: unsupported evaluated core Unsupported'),
 'zero-fuel':('Absent','observer: candidate budget or fresh range'),
 'exhausted-application':('Absent','observer: candidate budget or fresh range'),
 'fresh-limit':('Absent','observer: candidate budget or fresh range'),
 'absurd-skips-continuation':('NO_Error',''),
 'recursive-tail':('NO_Loop',''),
 'recursive-non-tail':('Absent','observer: non-tail or discarded recursive result'),
})
assert set(rows)==set(expected),(set(rows),set(expected))
for name,(tag,error) in expected.items():
    assert (rows[name]['tag'],rows[name]['error'])==(tag,error),(name,rows[name],tag,error)
assert rows['symbolic-fresh-order']['fresh']==102
assert rows['symbolic-resume-both']['fresh']==102
assert rows['symbolic-first-error']['fresh']==100
assert rows['zero-fuel']['fuel']==0
assert rows['fresh-limit']['fresh']==294967200
assert rows['recursive-tail']['fresh']==101
pin=lambda p:dict(file=str(p.resolve()),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
report={'kind':'phase88-observer-complete-products','complete':True,'pass':True,'exactOutput':True,'cases':rows,'inputs':[pin(p) for p in files],'method':pin(Path(__file__))}
with out.open('x') as f:json.dump(report,f,indent=2)
print(json.dumps(dict(complete=True,cases=len(rows),exactOutput=True)))
