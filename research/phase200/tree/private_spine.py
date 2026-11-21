"""A restricted source pass for closed finite-tag, product-headed private list spines.

Original public definitions survive. Fresh clones have an incompatible private spine
type, so a complete type check also verifies the representation boundaries.
"""
import argparse
from dataclasses import dataclass
import json
from pathlib import Path
import re

ID = r'[A-Za-z_][A-Za-z0-9_.]*'
VAR = r'[a-z_][A-Za-z0-9_]*'
DECL = re.compile(r'^(type|law|def) ('+ID+r')(?=[: (])[^\n]*\n(?:^[ \t]+[^\n]*\n|^\n)*',re.M)


class Refusal(ValueError):
    pass


def require(test, reason):
    if not test:
        raise Refusal(reason)


@dataclass
class Frame:
    name: str
    constructor: str
    fields: list
    flag: int


def frames(decls):
    for d in decls:
        if d[1]!='type':
            continue
        rows=d[0].strip().splitlines()
        if len(rows)!=2 or ' is Data:' not in rows[0]:
            continue
        m=re.fullmatch(r'  ('+ID+r')\{([^{}]+)\}',rows[1])
        if not m:
            continue
        fields=[re.fullmatch(r'('+VAR+r'): ('+ID+r')',s.strip()) for s in m[2].split(',')]
        if not all(fields):
            continue
        flags=[i for i,f in enumerate(fields) if f[2]=='Bool']
        if len(flags)==1 and len(fields)>1:
            yield Frame(d[2],m[1],[(f[1],f[2]) for f in fields],flags[0])


def bare_functions(text):
    return set(re.findall(r'(?<![\w.])('+ID+r')\(',text))


def separate(text, separator):
    """Split at outer separators in a checked source expression or type."""
    depth=0
    items=[]
    start=0
    for pos,char in enumerate(text):
        if char in '({[<':depth+=1
        elif char in ')}]>':
            depth-=1
            if depth<0:return []
        elif depth==0 and char==separator:
            items.append(text[start:pos].strip());start=pos+1
    return [*items,text[start:].strip()] if depth==0 else []


def private_entries(source,group,laws,clone,ty,empty):
    signatures={}
    for name in group:
        lines=[line.strip() for line in laws[name].splitlines() if line.strip()]
        params=[]
        for line in lines[1:-1]:
            m=re.fullmatch(r'for [+-]?'+VAR+r'\s*:\s*(.+)',line)
            require(m,'unsupported law signature')
            params.append(m[1])
        signatures[name]=(params,lines[-1])
    count=0

    def convert(expr,expected):
        if ty not in expected:return expr,0
        if expr=='Nil{}' and expected==ty:return empty+'{}',1
        if expr.startswith('(') and expr.endswith(')'):
            wants=separate(expected,'&')
            args=separate(expr[1:-1],',')
            require(len(args)==len(wants)==2,'unsupported tuple in entry')
            args=[convert(arg,want) for arg,want in zip(args,wants)]
            return '('+', '.join(arg for arg,n in args)+')',sum(n for arg,n in args)
        return call(expr,expected)

    def call(expr,expected):
        m=re.fullmatch(r'('+ID+r')\((.*)\)',expr)
        require(m and m[1] in group,'unproven private argument')
        types,result=signatures[m[1]]
        require(expected is None or expected==result,'unknown intermediate result')
        require(expected is not None or ty not in result,'private result would escape')
        fields=separate(m[2],',')
        require(len(fields)==len(types),'wrong entry arity')
        args=[convert(arg,want) for arg,want in zip(fields,types)]
        return clone[m[1]]+'('+', '.join(arg for arg,n in args)+')',sum(n for arg,n in args)

    lines=[]
    for line in source.splitlines(keepends=True):
        indent=line[:len(line)-len(line.lstrip())]
        expr=line.strip()
        if indent and expr.split('(',1)[0] in group:
            try:new,roots=call(expr,None)
            except Refusal:pass
            else:
                if roots:
                    line=indent+new+('\n' if line.endswith('\n') else '')
                    count+=1
        lines.append(line)
    return ''.join(lines),count


def specialize(source,frame):
    decls=list(DECL.finditer(source))
    laws={d[2]:d[0] for d in decls if d[1]=='law'}
    defs={d[2]:d[0] for d in decls if d[1]=='def'}
    # Only List at the Data kind. Other lists may coexist in the book.
    ty='List<&2, '+frame.name+'>'
    group={name for name,law in laws.items() if ty in law}
    require(group and group<=defs.keys(),'missing a definition for a private-spine law')
    original_words=set(re.findall(ID,source))
    pref='PSp'
    while any(x.startswith(pref) or x.startswith(pref.lower()+'.') for x in original_words):
        pref+='X'
    spine=pref+'Trail';empty=pref+'End';tags={True:pref+'On',False:pref+'Off'}
    clone={name:pref.lower()+'.'+name for name in sorted(group)}
    names=re.compile(r'(?<![\w.])('+'|'.join(map(re.escape,sorted(group,key=len,reverse=True)))+r')(?![\w.])')
    prefix='type '+spine+' is Data:\n  '+empty+'{}\n'
    saved=[f for j,f in enumerate(frame.fields) if j!=frame.flag]
    next_field='tail'
    while any(n==next_field for n,t in saved):next_field+='x'
    for tag in tags.values():
        prefix+='  '+tag+'{'+', '.join(n+': '+t for n,t in [*saved,(next_field,spine)])+'}\n'
    token=r'(?:'+VAR+r'|True\{\}|False\{\})'
    record=re.compile(r'(?<![\w.])'+re.escape(frame.constructor)+r'\{('+token+r'(?:,\s*'+token+r')*)\}\s*<>\s*('+VAR+r')')
    transformed={};counts={'push':0,'pop':0,'emptyMatch':0,'entry':0}
    # Incoming Nil must be scoped to the private path. Private functions cannot
    # invoke arbitrary parametric observers or hide a path in an untyped call.
    pure_calls={'U32.is_lt','U32.is_gt','U32.is_eq','U32.add','U32.sub','U32.xor','U32.and','U32.mul'}
    for name in sorted(group):
        law=laws[name];body=defs[name];hdr,logic=body.split('\n',1)
        require('List<' not in law.replace(ty,'') and frame.name not in law.replace(ty,''),'mixed list or frame type')
        require(bare_functions(logic)<=group|pure_calls,'external or polymorphic operation on the closed component')
        require('#' not in logic and '"' not in logic and 'do IO' not in logic,'outside the pure source subset')
        def replacement(m):
            parts=[s.strip() for s in m[1].split(',')]
            require(len(parts)==len(frame.fields) and parts[frame.flag] in ('True{}','False{}'),'data-dependent flag')
            require(all(re.fullmatch(VAR,v) for j,v in enumerate(parts) if j!=frame.flag),'nonvariable frame payload')
            prior=logic[:m.start()].rsplit('\n',1)[-1].lstrip()
            counts['pop' if prior.startswith('case ') and ':' not in prior else 'push']+=1
            return tags[parts[frame.flag]=='True{}']+'{'+', '.join([*[v for j,v in enumerate(parts) if j!=frame.flag],m[2]])+'}'
        copied=record.sub(replacement,logic)
        require('<>' not in copied and frame.constructor+'{' not in copied,'an unmatched list or independent frame escapes')
        copied,n=re.subn(r'(?m)^(\s*case )Nil\{\}(:\s*)$',lambda m:m[1]+empty+'{}'+m[2],copied)
        counts['emptyMatch']+=n
        require('Nil{}' not in copied,'unscoped empty list')
        transformed[name]=names.sub(lambda m:clone[m[1]],law.replace(ty,spine)+'\n'+hdr+'\n'+copied).rstrip()
    require(all(counts[k]>0 for k in ['push','pop','emptyMatch']),'incomplete push/pop component')
    # Prove all private inputs of a representation-free result are derived
    # exclusively from fresh empty literals through clone signatures and pairs.
    updated,counts['entry']=private_entries(source,group,laws,clone,ty,empty)
    require(counts['entry']>0,'no closed empty-spine entry returning an unrelated type')
    first=min(d.start() for d in decls if d[1] in ('law','def') and d[2] in group)
    clones='\n\n'.join(transformed[name] for name in defs if name in group)
    # The upstream book checker requires callees to be defined before use.
    # Preserve the original definition order and place clones before new entries.
    new=updated[:first]+prefix+'\n'+clones+'\n\n'+updated[first:]
    return new,dict(frame=frame.name,group=sorted(group),counts=counts)


def transform(source):
    candidates=list(frames(list(DECL.finditer(source))));reasons=[]
    for f in candidates:
        try:return specialize(source,f)
        except Refusal as e:reasons.append(f.name+': '+str(e))
    raise Refusal('; '.join(reasons) or 'no single-constructor product with one Bool field')


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('input',type=Path);p.add_argument('output',type=Path)
    p.add_argument('--require-change',action='store_true')
    a=p.parse_args();original=a.input.read_text()
    try:
        new,receipt=transform(original)
        receipt['changed']=True
    except Refusal as refusal:
        if a.require_change:raise
        new=original;receipt={'changed':False,'reason':str(refusal)}
    a.output.write_text(new);print(json.dumps(receipt))
