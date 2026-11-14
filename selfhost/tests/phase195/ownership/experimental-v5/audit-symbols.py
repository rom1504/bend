#!/usr/bin/env python3
"""Lexical symbol/arity inventory against pinned selected source; no compiler."""
from pathlib import Path
import re,json,hashlib
ROOT=Path(__file__).resolve().parent
REPO=ROOT.parents[4]
PARENT=REPO/'selfhost/build/phase194/selected-source02/compiler.bend'
BASE=REPO/'selfhost/.bootstrap/upstream-phase182/bend2/base.bend'
MODULES=[ROOT/x for x in ['layout.bend','evaluator.bend','proof.bend']]
def clean(s):return re.sub(r'"(?:\\.|[^"\\])*"|#[^\n]*',lambda m:'""' if m[0].startswith('"') else '',s)
def pin(p):
 b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def enclosed(s,start):
 pairs={'(':')','{':'}','[':']','<':'>'};stack=[pairs[s[start]]];i=start+1
 while i<len(s) and stack:
  c=s[i]
  if c in pairs:stack.append(pairs[c])
  elif c==stack[-1]:stack.pop()
  i+=1
 return s[start+1:i-1],i
def count(s):
 s=s.strip().rstrip(',').rstrip()
 if not s:return 0
 n=1;i=0
 while i<len(s):
  if s[i] in '({[<':_,i=enclosed(s,i);continue
  if s[i]==',':n+=1
  i+=1
 return n
known={};callable={};constructors={}
for p in [PARENT,BASE,*MODULES]:
 s=clean(p.read_text())
 for m in re.finditer(r'(?m)^(def|law|type) ([A-Za-z_][\w.]*)',s):known[m[2]]=str(p)
 for m in re.finditer(r'(?m)^def ([A-Za-z_][\w.]*)\(',s):
  body,_=enclosed(s,m.end()-1);callable[m[1]]=count(body)
 for m in re.finditer(r'(?m)^  ([A-Z][\w.]*)\{',s):
  body,_=enclosed(s,m.end()-1);constructors[m[1]]=count(body);known[m[1]]=str(p)
refs=set();arityErrors=[];calls=0;constructorSites=0
for p in MODULES+[ROOT/'bst-fixture.bend']:
 s=clean(p.read_text())
 # Fixture declarations are a separate checked user book, but share Base symbols.
 if p.name=='bst-fixture.bend':
  for m in re.finditer(r'(?m)^(?:def|law|type) ([A-Za-z_][\w.]*)',s):known[m[1]]=str(p)
  for m in re.finditer(r'(?m)^def ([A-Za-z_][\w.]*)\(',s):
   body,_=enclosed(s,m.end()-1);callable[m[1]]=count(body)
  for m in re.finditer(r'(?m)^  ([A-Z][\w.]*)\{',s):
   body,_=enclosed(s,m.end()-1);constructors[m[1]]=count(body);known[m[1]]=str(p)
 refs.update(re.findall(r'\b([A-Za-z_][\w.]*)[ \t]*\(',s))
 refs.update(re.findall(r'\b([A-Z][\w.]*)\s*[<{]',s))
 refs.update(re.findall(r'(?::|->)\s*([A-Z][\w.]*)',s))
 for m in re.finditer(r'\b([A-Za-z_][\w.]*)[ \t]*([({])',s):
  name=m[1];table=callable if m[2]=='(' else constructors
  if name not in table:continue
  body,_=enclosed(s,m.end()-1);actual=count(body)
  if m[2]=='(':calls+=1
  else:constructorSites+=1
  if actual!=table[name]:arityErrors.append(dict(file=p.name,line=s.count('\n',0,m.start())+1,name=name,expected=table[name],actual=actual))
unknown=sorted(refs-known.keys())
report=dict(kind='phase195-static-symbol-audit',compilerExecuted=False,inputs=[pin(p) for p in [PARENT,BASE,*MODULES,ROOT/'bst-fixture.bend']],
 scope='Lexical constructor/type/function references and explicit argument counts only. Not name resolution/type checking.',
 references=len(refs),callSites=calls,constructorSites=constructorSites,unknown=unknown,arityErrors=arityErrors,
 resolutions={name:known[name] for name in sorted(refs) if name in known})
(ROOT/'symbol-audit.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({k:v for k,v in report.items() if k not in ['inputs','resolutions']}))
assert not unknown and not arityErrors
