"""Bounded source specialization of structurally recursive String folds.

The residual program is Bend. Only first-order syntax in the admitted subset is
interpreted. Unknown computations remain ordered let bindings in the output.
"""
import argparse
import ast
from dataclasses import dataclass
import hashlib
import json
import re
from pathlib import Path

NAME = r'[A-Za-z_][A-Za-z_0-9]*(?:\.[A-Za-z_][A-Za-z_0-9]*)*'
TOKEN = re.compile(r'''\s+|\#[^\n]*|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|'''+NAME+r'|[0-9]+n?|&&|\|\||->|.',re.S)
PREC = {':':1,'||':2,'&&':3,'+':4,'-':4,'*':5,'%':5}
LIMIT = 64
CAP = 1024
WORD = (1<<32)-1

class Unsupported(ValueError): pass

def tokens(s):
    return [m.group() for m in TOKEN.finditer(s) if not m.group().isspace() and not m.group().startswith('#')]

@dataclass(frozen=True)
class Node:
    op: str
    name: str
    args: tuple = ()

class Parser:
    def __init__(self,s): self.t=tokens(s);self.i=0
    def peek(self): return self.t[self.i] if self.i<len(self.t) else ''
    def take(self):
        t=self.peek()
        if not t: raise Unsupported('incomplete expression')
        self.i+=1;return t
    def require(self,s):
        if self.take()!=s: raise Unsupported('expected '+s)
    def args(self,end):
        result=[]
        if self.peek()!=end:
            while True:
                result.append(self.expr())
                if self.peek()!=',':break
                self.take()
        self.require(end);return tuple(result)
    def expr(self,minimum=0):
        t=self.take()
        if t=='(':
            a=self.args(')');node=a[0] if len(a)==1 else Node('tuple','',a)
        elif t=='{':
            node=self.expr();self.require('}')
        elif t.startswith(('"',"'")) or re.fullmatch(r'[0-9]+n?',t):node=Node('literal',t)
        elif re.fullmatch(NAME,t):
            if self.peek() in ('(','{'):
                p=self.take();node=Node('call' if p=='(' else 'ctor',t,self.args(')' if p=='(' else '}'))
            else:node=Node('var',t)
        else:raise Unsupported('unsupported expression')
        while self.peek() in PREC and PREC[self.peek()]>=minimum:
            op=self.take();rhs=self.expr(PREC[op]+1);node=Node('binary',op,(node,rhs))
        return node

def parse(s):
    p=Parser(s);n=p.expr()
    if p.peek():raise Unsupported('trailing expression')
    return n

def show(n):
    if n.op in ('var','literal'):return n.name
    if n.op=='binary':return '('+show(n.args[0])+' '+n.name+' '+show(n.args[1])+')'
    p,q=('(',')') if n.op in ('call','tuple') else ('{','}')
    return n.name+p+', '.join(map(show,n.args))+q

def walk(n):
    yield n
    for x in n.args:yield from walk(x)

@dataclass
class Def:
    name:str; params:list; types:list; result:str; bindings:list; body:object; source:list

def parse_program(s):
    # Each row records its input byte range in the Python source string.
    lines=s.splitlines(keepends=True);starts=[];off=0
    for l in lines:starts.append(off);off+=len(l)
    defs={};spans={};declared=set();imports=[];constructors=set();keywords={'def','type','law','import'}
    for i,l in enumerate(lines):
        if l.startswith('import '):imports.append(l.strip())
        m=re.match(r'^(def|type|law)\s+('+NAME+r')',l)
        if m:
            if m[2] in declared:raise Unsupported('multiple declarations of '+m[2])
            declared.add(m[2]);
            if m[1]=='type':
                for v in lines[i+1:]:
                    if v.strip() and not v[0].isspace():break
                    cm=re.match(r'\s+('+NAME+r')\{',v)
                    if cm:constructors.add(cm[1])
        h=re.fullmatch(r'def\s+('+NAME+r')\(([^()\n]*)\)\s*->\s*([^:\n]+):\s*',l)
        if not h:continue
        name,params,result=h.groups();ps=[];tys=[]
        try:
            for entry in ([] if not params.strip() else params.split(',')):
                pm=re.fullmatch(r'\s*\+?('+NAME+r')\s*:\s*('+NAME+r')\s*',entry)
                if not pm:raise Unsupported('parameter syntax')
                ps.append(pm[1]);tys.append(pm[2])
            if len(set(ps))!=len(ps):raise Unsupported('duplicate formal')
            end=i+1
            while end<len(lines) and (not lines[end].strip() or lines[end][0].isspace() or lines[end].startswith('#')):end+=1
            rows=[]
            for j in range(i+1,end):
                v=lines[j].strip()
                if v and not v.startswith('#'):
                    if '#' in v:raise Unsupported('inline comment')
                    rows.append((len(lines[j])-len(lines[j].lstrip(' ')),v,j))
            binds=[];k=0
            while k<len(rows)-1:
                b=re.fullmatch(r'\+?('+NAME+r')\s*=\s*(.+)',rows[k][1]);
                if not b:break
                binds.append((b[1],parse(b[2])));k+=1
            if not rows or k==len(rows):continue
            remain=rows[k:];first=remain[0][1]
            if first.startswith('match ') and first.endswith(':'):
                keys=first[6:-1].split();cases=[];j=1
                while j<len(remain):
                    cm=re.fullmatch(r'case\s+(.+?)\s*:\s*(.*)',remain[j][1]);
                    if not cm:raise Unsupported('case')
                    pats=[p.replace(' ','') for p in re.findall(r'(?:'+NAME+r'\{(?:Chr\{'+NAME+r'\}\s*,\s*'+NAME+r')?\}|_)',cm[1])]
                    if ''.join(pats)!=re.sub(r'\s','',cm[1]) or len(pats)!=len(keys):raise Unsupported('pattern dialect')
                    expr=cm[2];j+=1
                    if not expr:
                        if j==len(remain):raise Unsupported('empty case')
                        expr=remain[j][1];j+=1
                    cases.append((pats,parse(expr)))
                body=('match',keys,cases)
            else:
                if len(remain)!=1:raise Unsupported('multi-line expression')
                body=('expr',parse(first))
            defs[name]=Def(name,ps,tys,result.strip(),binds,body,rows);spans[name]=(starts[remain[0][2]],len(lines[remain[0][2]]))
        except Unsupported:pass
    return defs,spans,declared,constructors,imports

def spine(d):
    if d.bindings or d.body[0]!='match' or len(d.body[1])!=1:return None
    arg=d.body[1][0];cases=d.body[2]
    if arg not in d.params or d.types[d.params.index(arg)]!='String' or len(cases)!=2:return None
    if cases[0][0]!=['SNil{}'] or len(cases[1][0])!=1:return None
    m=re.fullmatch(r'SCon\{Chr\{('+NAME+r')\},('+NAME+r')\}',cases[1][0][0]);
    if not m or m[1]==m[2] or {m[1],m[2]}&set(d.params):return None
    j=d.params.index(arg);calls=[n for n in walk(cases[1][1]) if n.op=='call' and n.name==d.name]
    if len(calls)!=1 or any(n.op=='call' and n.name==d.name for n in walk(cases[0][1])):return None
    if len(calls[0].args)!=len(d.params) or calls[0].args[j]!=Node('var',m[2]):return None
    return j

@dataclass(frozen=True)
class V:
    kind:str; val:object; typ:str=''

def lit(n,typ='U32'):return V(typ,n)

def render(v):
    if v.kind=='dyn':return v.val
    if v.kind=='ctor':return v.val+'{}'
    if v.kind=='String':return json.dumps(v.val,ensure_ascii=False)
    if v.kind=='Char':return 'Chr{'+str(v.val)+'}'
    return str(v.val)+('n' if v.kind=='Nat' else '')

PURE_WORD={'U32.add','U32.sub','U32.mul','U32.xor','U32.and','U32.or','U32.shln','U32.shrn','U32.to_nat','U32.is_eq','U32.is_ne','U32.is_le','U32.is_lt','U32.is_ge','U32.is_gt','Char.to_u32','Bool.not'}

class Stage:
    def __init__(self,defs,returns):self.defs=defs;self.returns=returns;self.binds=[];self.fuel=0;self.steps=0;self.selected=0;self.stack=[];self.pure_cache={}
    def pure(self,n,seen):
        if n.op=='call' and n.name not in PURE_WORD:
            if n.name not in self.defs or n.name in seen:return False
            if n.name not in self.pure_cache:
                d=self.defs[n.name];expressions=[b for _,b in d.bindings]+([d.body[1]] if d.body[0]=='expr' else [v for _,v in d.body[2]])
                # Only unconditional expressions can be called total without an exhaustiveness proof.
                self.pure_cache[n.name]=d.body[0]=='expr' and all(self.pure(x,seen|{n.name}) for x in expressions)
            if not self.pure_cache[n.name]:return False
        if n.op=='binary' and n.name=='%' and not (n.args[1].op=='literal' and re.fullmatch('[1-9][0-9]*',n.args[1].name)):return False
        return all(self.pure(x,seen) for x in n.args)
    def let(self,expr,erasable,typ):
        if not typ:raise Unsupported('residual type unavailable')
        if len(self.binds)>=CAP:raise Unsupported('temporary budget')
        n='p205unfold_v'+str(len(self.binds));self.binds.append((n,expr,erasable,typ));return V('dyn',n,typ)
    def eval(self,n,env):
        self.fuel+=1
        if self.fuel>10000:raise Unsupported('evaluation fuel')
        if n.op=='var':
            if n.name not in env:raise Unsupported('unknown variable')
            return env[n.name]
        if n.op=='literal':
            t=n.name
            if t.startswith('"'):return lit(decode_string(t),'String')
            if t.startswith("'"):return lit(ord(ast.literal_eval(t)),'Char')
            return lit(int(t.rstrip('n')),'Nat' if t.endswith('n') else 'U32')
        if n.op=='binary' and n.name==':':
            x=self.eval(n.args[0],env);ty=n.args[1];
            if ty.op!='var' or ty.name not in ('U32','Nat'):raise Unsupported('ascription')
            if x.kind not in ('dyn',ty.name):raise Unsupported('literal type ambiguity')
            return x if x.kind!='dyn' else self.let('('+render(x)+' : '+ty.name+')',True,ty.name)
        if n.op=='binary' and n.name in ('&&','||'):raise Unsupported('conditional operator')
        vs=[self.eval(x,env) for x in n.args];rs=[render(v) for v in vs]
        if n.op=='ctor':
            return V('ctor',n.name) if not vs else self.let(n.name+'{'+', '.join(rs)+'}',True,self.returns.get(n.name,''))
        if n.op=='binary':
            if len(vs)==2 and all(v.kind=='U32' for v in vs):
                a,b=[v.val for v in vs];ops={'+':lambda:a+b,'-':lambda:a-b,'*':lambda:a*b,'%':lambda:a%b};
                if n.name not in ops or n.name=='%' and b==0:raise Unsupported('arithmetic')
                return lit(ops[n.name]()&WORD)
            types={v.typ if v.kind=='dyn' else v.kind for v in vs}
            if len(types)!=1 or not types<= {'Nat','U32'}:raise Unsupported('arithmetic needs a common scalar type')
            typ=next(iter(types));return self.let('('+(' '+n.name+' ').join(rs)+' : '+typ+')',self.pure(n,set()),typ)
        if n.op=='tuple':raise Unsupported('residual tuple requires type')
        if n.op!='call':raise Unsupported('expression form')
        f=n.name
        if all(v.kind=='U32' for v in vs) and len(vs)==2:
            a,b=[v.val for v in vs];ops={'U32.is_eq':a==b,'U32.is_ne':a!=b,'U32.is_lt':a<b,'U32.is_le':a<=b,'U32.is_gt':a>b,'U32.is_ge':a>=b}
            if f in ops:return V('ctor','True' if ops[f] else 'False')
            ops={'U32.add':a+b,'U32.sub':a-b,'U32.mul':a*b,'U32.and':a&b,'U32.or':a|b,'U32.xor':a^b}
            if f in ops:return lit(ops[f]&WORD)
        if f in self.defs and (not vs or any(v.kind!='dyn' for v in vs)):
            d=self.defs[f];j=spine(d);repeat=f in self.stack
            if not repeat or (j is not None and vs[j].kind=='String'):
                pos=len(self.binds);self.stack.append(f)
                try:return self.apply(d,vs)
                except Unsupported:
                    del self.binds[pos:]
                    if repeat:raise
                finally:self.stack.pop()
        typ=self.returns.get(f,'')
        if f in PURE_WORD:
            typ='Nat' if f=='U32.to_nat' else ('Bool' if '.is_' in f or f=='Bool.not' else 'U32')
        return self.let(f+'('+', '.join(rs)+')',self.pure(n,set()),typ)
    def apply(self,d,vs):
        if len(vs)!=len(d.params):raise Unsupported('call arity')
        env=dict(zip(d.params,vs))
        for name,v in d.bindings:env[name]=self.eval(v,env)
        if d.body[0]=='expr':return self.eval(d.body[1],env)
        keys=d.body[1];args=[env.get(k) for k in keys]
        if any(x is None or x.kind=='dyn' for x in args):raise Unsupported('dynamic match')
        for pats,expr in d.body[2]:
            binds={};ok=True
            for pat,v in zip(pats,args):
                if pat=='_':continue
                if pat=='SNil{}' and v.kind=='String':ok &= v.val=='';continue
                m=re.fullmatch(r'SCon\{Chr\{('+NAME+r')\},('+NAME+r')\}',pat)
                if m and v.kind=='String' and v.val:
                    binds[m[1]]=lit(ord(v.val[0]));binds[m[2]]=lit(v.val[1:],'String');continue
                ok &= v.kind=='ctor' and pat==v.val+'{}'
            if ok:
                if spine(d) is not None:self.steps+=bool(binds)
                else:self.selected+=1
                return self.eval(expr,dict(env,**binds))
        raise Unsupported('no statically selected case')
    def finish(self,value):
        used={render(value)};lines=[]
        for n,e,total,typ in reversed(self.binds):
            if n in used or not total:
                lines.append('  +'+n+' : '+typ+' = '+e);used.update(re.findall(r'\bp205unfold_v[0-9]+\b',e))
        return list(reversed(lines))+['  '+render(value)]

def decode_string(t):
    # Ordinary Unicode literals and the escapes shared by Python/JSON and Bend.
    if re.search(r'\\(?!["\\nrt])',t):raise Unsupported('unsupported string escape')
    s=json.loads(t)
    if any(0xd800<=ord(x)<=0xdfff for x in s):raise Unsupported('surrogate')
    return s

def transform(source):
    defs,spans,declared,ctors,imports=parse_program(source)
    if imports!=['import Base'] or re.search(r'(?m)^@|\bp205unfold_',source) or declared&{'U32','Nat','String','Char','Bool','True','False','SNil','SCon','Chr'} or any(n.startswith(('U32.','Bool.','Char.')) for n in declared) or ctors&{'True','False','Chr','SNil','SCon'}:return source,[]
    returns={k:t.strip() for k,t in re.findall(r'(?m)^def\s+('+NAME+r')\([^\n]*?\)\s*->\s*([^:\n]+):',source)}
    returns.update({'Chr':'Char','SCon':'String','SNil':'String'})
    kernels={d.name:(d,j) for d in defs.values() if (j:=spine(d)) is not None};edits=[];notes=[]
    for owner in defs.values():
        if owner.body[0]!='expr' or owner.bindings or set(owner.params)&declared:continue
        helpers=[];edits_here=[]
        def rewrite(n):
            if n.op=='call' and n.name in kernels:
                d,j=kernels[n.name];a=n.args
                if len(a)!=len(d.params):return n
                known={};unknown=[]
                for i,e in enumerate(a):
                    literal=e
                    if e.op=='call' and not e.args and e.name in defs:
                        c=defs[e.name]
                        if not c.params and not c.bindings and c.body[0]=='expr':literal=c.body[1]
                    if literal.op=='literal' and literal.name.startswith('"') and d.types[i]=='String':known[i]=lit(decode_string(literal.name),'String')
                    elif literal.op=='literal' and re.fullmatch(r'[0-9]+',literal.name) and int(literal.name)<=WORD and d.types[i]=='U32':known[i]=lit(int(literal.name))
                    else:unknown.append(i)
                if j not in known or not 0<=len(known[j].val)<=LIMIT:return n
                if any(d.types[i] not in ('U32','Nat','String','Char','Bool') for i in unknown):return n
                st=Stage(defs,returns); args=[known[i] if i in known else V('dyn',d.params[i],d.types[i]) for i in range(len(a))];st.stack=[d.name]
                try:r=st.apply(d,args);lines=st.finish(r)
                except (Unsupported,RecursionError):return n
                if st.steps!=len(known[j].val) or len(lines)>CAP:return n
                name='p205unfold_fn'+str(len(notes)+len(edits_here));formals=', '.join('+'+d.params[i]+': '+d.types[i] for i in unknown)
                helpers.append('def '+name+'('+formals+') -> '+d.result+':\n'+'\n'.join(lines)+'\n\n');edits_here.append(dict(owner=owner.name,kernel=d.name,formal=j,characters=st.steps,constantMatchBranches=st.selected,residualBindings=len(lines)-1));return Node('call',name,tuple(a[i] for i in unknown))
            return Node(n.op,n.name,tuple(rewrite(a) for a in n.args))
        try:changed=rewrite(owner.body[1])
        except (Unsupported,ValueError):continue
        if edits_here:
            at,length=spans[owner.name];header=source.rfind('\ndef '+owner.name+'(',0,at)+1
            if header<1:continue
            edits.extend([(at,at+length,'  '+show(changed)+'\n'),(header,header,''.join(helpers))]);notes.extend(edits_here)
    for a,b,text in sorted(edits,reverse=True):source=source[:a]+text+source[b:]
    return source,notes

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('source',type=Path);p.add_argument('--out',type=Path,required=True);a=p.parse_args();source=a.source.read_text();result,notes=transform(source);a.out.write_text(result);print(json.dumps(dict(source=hashlib.sha256(source.encode()).hexdigest(),result=hashlib.sha256(result.encode()).hexdigest(),sites=notes),indent=2))
