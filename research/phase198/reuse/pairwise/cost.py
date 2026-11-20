"""Count the necessary public type telescope across full source, including Base.

This is a conservative pre-reachability source census. It does no compiling.
Explicit function signatures and paired law/def declarations are resolved.
"""
import argparse
import hashlib
import importlib.util
import json
import re
from pathlib import Path
here=Path(__file__).resolve().parent
root=here.parents[3]
spec=importlib.util.spec_from_file_location('phase198_source',root/'selfhost/tools/build/source.py')
source=importlib.util.module_from_spec(spec);spec.loader.exec_module(source)

def parts(s):
    depth=0;last=0;out=[]
    for i,ch in enumerate(s):
        if ch in '([<{':depth+=1
        elif ch in ')]>}':depth-=1
        elif ch==',' and not depth:out.append(s[last:i]);last=i+1
    if s[last:].strip():out.append(s[last:]);
    return out

def sig(block):
    s=re.sub(r'#[^\n]*','',block['data'].decode());kind=block['kind'];name=re.escape(block['name']);
    if kind=='law':
        body=re.split(r'(?m)^law\s+'+name+r'\s*:',s,maxsplit=1)[-1];lines=[l.strip() for l in body.splitlines() if l.strip() and not l.strip().startswith('@')];
        ps=[re.sub(r'\s','',l.split(':',1)[1]) for l in lines if l.startswith('for ') and ':' in l];others=[l for l in lines if not l.startswith('for ')];return ps,(''.join(others)).strip()
    m=re.search(r'(?m)^def\s+'+name+r'\s*\(',s)
    if not m:return None
    start=m.end();depth=1
    for i in range(start,len(s)):
        if s[i]=='(':depth+=1
        elif s[i]==')':depth-=1
        if not depth:break
    ps=parts(s[start:i]);out=re.match(r'\s*->\s*([^:]+):',s[i+1:]);
    if out:return [re.sub(r'\s','',x.split(':',1)[1]) if ':' in x else '<implicit>' for x in ps],re.sub(r'\s','',out.group(1))
    return len(ps)

def census(p):
    data=p.read_bytes();rows=source.blocks(data)[1];laws={r['name']:sig(r) for r in rows if r['kind']=='law'};ds=[r for r in rows if r['kind']=='def'];interesting=[];unknown=[];triples=0
    for d in ds:
        s=sig(d)
        if isinstance(s,int):
            argc=s;s=laws.get(d['name'])
            if s is None:
                if argc==3:unknown.append(d['name'])
                continue
        if s is None:unknown.append(d['name']);continue
        pars,ret=s
        if len(pars)!=3:continue
        triples+=1
        if pars[0] in (ret,'<implicit>') and pars[1] in (ret,'<implicit>') and pars[2] in ('Bool','<implicit>') and re.fullmatch(r'[\w.]+',ret):
            body=d['data'].decode();mat=re.search(r'(?m)^  match ([^:\n]+):',body)
            interesting.append(dict(name=d['name'],type=ret,firstTopLevelMatch=mat[1] if mat else None))
    assert not unknown,unknown
    return dict(source=str(p.relative_to(root)),sha256=hashlib.sha256(data).hexdigest(),definitions=len(ds),laws=len(laws),resolvedThreeArgument=triples,matchingTelescope=interesting)

def main():
    p=argparse.ArgumentParser();p.add_argument('--compiler',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();inputs=[a.compiler.resolve(),root/'selfhost/.bootstrap/upstream-phase182/bend2/base.bend',root/'selfhost/tools/bench/catalogs/native45/fixtures/tree-bitonic.bend',here/'envelope.bend'];a.out.write_text(json.dumps([census(f) for f in inputs],indent=2)+'\n')
if __name__=='__main__':main()
