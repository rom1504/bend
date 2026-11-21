"""Independent call-by-value interpreter for the exact captured equations and frozen Bend RHS."""
from dataclasses import dataclass
from pathlib import Path
import gzip
import json
import re
from hashlib import sha256
from itertools import product
HERE=Path(__file__).resolve().parent
CAPTURE=HERE.parents[2]/'selfhost/build/phase200/p205-shapes01/bst.json.gz'
source=(HERE/'schema.bend').read_text()

@dataclass(frozen=True)
class Ctor:
    name:str
    fields:tuple=()

def schema(name):
    line=re.search(r'def p205t_'+name+r'\(\) -> P205TExpr:\n  ([^\n]+)',source)[1]
    # The frozen schema is a closed grammar containing only string/U32 literals and lists.
    tree=json.loads(line.replace('P205TExpr{','[').replace('}',']'))
    return tree

def match(p,t,roles,vars):
    tag,op,n,i,q,k=p
    if t['t']!=tag or t['q']!=q or len(t['k'])!=len(k):return False
    if op==1:
        if i in vars or t['i'] in vars.values():return False
        vars[i]=t['i']
    elif op==2:
        if vars.get(i)!=t['i']:return False
    else:
        if i!=t['i']:return False
        if op==3:
            if n not in roles and t['n'] in roles.values():return False
            if roles.setdefault(n,t['n'])!=t['n']:return False
        elif n!=t['n']:return False
    return all(match(pi,ti,roles,vars) for pi,ti in zip(k,t['k']))

def reify(p,r,base):
    tag,op,n,i,q,k=p
    return dict(t=tag,n=r[n] if op==3 else n,i=i+base if op in (1,2) else i,q=q,k=[reify(x,r,base) for x in k])

def call(f,args):
    for x in args:f=f(x)
    return f

def evalterm(t,bindings,defs):
    tag,name,i,k=t['t'],t['n'],t['i'],t['k']
    if tag=='Ref':
        if name=='U32.is_lt':return lambda a: lambda b:Ctor('True' if a<b else 'False')
        return evalterm(defs[name],{},defs)
    if tag=='Var':return bindings[i]
    if tag=='Lam':return lambda a:evalterm(k[0],{**bindings,i:a},defs)
    if tag=='Ctr':return Ctor(name,tuple(evalterm(a,bindings,defs) for a in k))
    if tag=='Mat':
        def apply(value):
            if value.name==name:return call(evalterm(k[0],bindings,defs),value.fields)
            return evalterm(k[1],bindings,defs)(value)
        return apply
    if tag=='App':return evalterm(k[0],bindings,defs)(evalterm(k[1],bindings,defs))
    if tag=='Let' and len(k)==2 and k[0]['t']=='Bind':
        return evalterm(k[1],{**bindings,k[0]['i']:evalterm(k[0]['k'][0],bindings,defs)},defs)
    raise ValueError(tag)

def nat(n):
    v=Ctor('Zero')
    for i in range(n):v=Ctor('Succ',(v,))
    return v

def expected(tree,x,fuel,leaf,node):
    if tree.name==leaf:return Ctor(node,(tree,x,tree))
    if fuel==0:return tree
    l,v,r=tree.fields
    return Ctor(node,(expected(l,x,fuel-1,leaf,node),v,r)) if x<v else Ctor(node,(l,v,expected(r,x,fuel-1,leaf,node)))

def main():
    defs={d['name']:d['erased'] for d in json.load(gzip.open(CAPTURE))['defs'] if 'erased' in d}
    entry='p37.bst.insert';r={}
    assert match(schema('entry'),defs[entry],r,{})
    for key,pattern in [('1','finish'),('2','down'),('3','step'),('4','push'),('5','pop')]:
        assert match(schema(pattern),defs[r[key]],r,{})
    orig=dict(defs)
    r.update({'9':'$private.p205.spine.left','10':'$private.p205.spine.right'})
    defs[r['4']]=reify(schema('new_push'),r,1600001)
    defs[r['5']]=reify(schema('new_pop'),r,1600016)
    leaf=Ctor(r['7'])
    inputs=[leaf]
    for val in [0,5,2**32-1]:inputs.append(Ctor(r['8'],(leaf,val,leaf)))
    # Include identical immutable children and both non-BST and ordered shapes:
    # the transformation follows the same comparisons even if the input is unsorted.
    inputs.extend(Ctor(r['8'],(l,5,h)) for l,h in product(inputs[:],repeat=2))
    inputs=list(dict.fromkeys(inputs))
    inputs.append(Ctor(r['8'],(leaf,1,leaf)))
    assert len(set(inputs))==len(inputs)==20
    checks=0
    for t,n,x in product(inputs,range(7),[0,1,4,5,6,2**32-2,2**32-1]):
        args=(nat(n),x,t);want=expected(t,x,n,r['7'],r['8'])
        assert call(evalterm(orig[entry],{},orig),args)==want
        assert call(evalterm(defs[entry],{},defs),args)==want
        checks+=1
    print(json.dumps(dict(captureSha256=sha256(CAPTURE.read_bytes()).hexdigest(),schemaSha256=sha256(source.encode()).hexdigest(),
      checkedSourceAndResidualPairs=checks,distinctTrees=len(inputs),fuels=list(range(7)),comparison='entire immutable value against original erased program and independent tree algorithm'),indent=2))
if __name__=='__main__':main()
