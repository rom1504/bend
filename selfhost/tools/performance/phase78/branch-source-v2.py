#!/usr/bin/env python3
"""Experimental source defunctionalization of closed native tail choices.

No generated JS is edited. Restricted to typed definitions with no local body
bindings; each branch keeps its exact expression. Every result needs a fresh
checked build. Emit helpers only for unused Unit lambda parameters.
"""
import argparse,hashlib,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--names',required=True);a=p.parse_args()
names=set(a.names.split(','));records=[]
def tokens(s):
 return list(re.finditer(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|\#[^\n]*|=>|->|[A-Za-z_][A-Za-z_0-9.]*|[^\s]',s))
def args(s):
 ts=tokens(s);out=[];start=0;stack=[]
 for t in ts:
  x=t.group()
  if x in ['(','[','{','<']:stack.append(x)
  elif x in [')',']','}','>']:
   if not stack:return None
   stack.pop()
  elif x==',' and not stack:out.append(s[start:t.start()].strip());start=t.end()
 if stack:return None
 return out+[s[start:].strip()]
def choice(s):
 s=s.strip()
 start=next((q for q in ['nt_choose(', 'kc('] if s.startswith(q)),None)
 if start is None or not s.endswith(')'):return None
 ps=args(s[len(start):-1])
 if ps is None or len(ps)!=4:return None
 branches=[]
 for term in ps[2:]:
  m=re.fullmatch(r'([A-Za-z_][A-Za-z_0-9]*)\s*=>\s*(.*)',term,re.S)
  if not m:return None
  var,body=m.groups();ts=tokens(body)
  # Refuse any value use of the removed binder, including conservatively any
  # use under a same-name nested lambda. A nested unused binder is harmless.
  if any(t.group()==var and (i+1==len(ts) or ts[i+1].group()!='=>') for i,t in enumerate(ts)):return None
  branches.append(body)
 return ps[0],ps[1],branches
for file in sorted((ROOT/'selfhost/src/back/native').glob('*.bend')):
 old=file.read_text();edits=[]
 # Resolve law parameter declarations without changing the law or public def.
 laws={}
 for law in re.finditer(r'^law (\w+):\n((?:  .*\n)+)',old,re.M):
  ls=law[2].strip().splitlines();ps=[x.strip()[4:] for x in ls if x.strip().startswith('for ')]
  laws[law[1]]=(', '.join(ps),ls[-1].strip())
 for name,(params,result) in laws.items():
  if name in names:
   old=re.sub(r'^def '+name+r'\([^\n]*\):',lambda m:'def '+name+'('+params+') -> '+result+':',old,flags=re.M)
 src=old
 for m in re.finditer(r'^def (\w+)\(([^\n]*)\) -> ([^\n]+):\n((?:[ \t].*\n|\n)+)',old,re.M):
  name,params,result,body=m.groups()
  if name not in names:continue
  declarations=args(params)
  if declarations is None:continue
  fields=[]
  for d in declarations:
   dm=re.fullmatch(r'(\+?)(\w+):\s*(.+)',d)
   if not dm:break
   fields.append((dm[2],dm[3]))
  else:
   if not choice(body):continue
   generated=[];arguments=', '.join(n for n,t in fields);decl=', '.join('+'+n+': '+t for n,t in fields)
   def lower(term):
    split=choice(term)
    if split is None:return ' '.join(line.strip() for line in term.strip().splitlines())
    typ,cond,(yes,no)=split
    assert re.sub(r'\s','',typ)==re.sub(r'\s','',result),(name,typ,result)
    index=len(generated);helper=f'{name}_branch{index}';generated.append(None)
    assert not re.search(r'\b'+helper+r'\b',old)
    y=lower(yes);n=lower(no)
    generated[index]=f'@unsafe\ndef {helper}(branch: Bool, {decl}) -> {result}:\n  match branch:\n    case True{{}}: {y}\n    case False{{}}: {n}\n'
    return f'{helper}({cond}, {arguments})'
   call=lower(body)
   replacement=f'def {name}({params}) -> {result}:\n  {call}\n\n'+'\n'.join(generated)+'\n'
   edits.append((m.start(),m.end(),replacement));records.append(dict(file=str(file.relative_to(ROOT)),function=name,helpers=len(generated),before=body,after=replacement))
 for lo,hi,replacement in reversed(edits):src=src[:lo]+replacement+src[hi:]
 if edits:file.write_text(src)
assert records,'No eligible source definition'
a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(dict(complete=True,methodSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),records=records,scope='Source-only exact tail-choice defunctionalization; no correctness or performance inferred without checked compilation and differential gates.'),indent=2)+'\n')
print(json.dumps(dict(functions=len(records),helpers=sum(r['helpers'] for r in records),selected=[r['function'] for r in records])))
