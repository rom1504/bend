"""Reusable static-template token-fold specialization; no compiler execution."""
import hashlib,json,re
from pathlib import Path
P=Path(__file__).resolve().parent
ROOT=P.parents[2]
MASK=0xffffffff
TEMPLATE='i = ( n o i ) o ( n o i ) o ( n o i ) ;'
KERNEL='''def p200.ident(n: Nat, t: U32, h: U32) -> U32:
  match n:
    case 0n: h
    case 1n+p:
      +u = prng(t)
      p200.ident(p, u, fnv(h, U32.add(97, U32.mod(u, 26))))

def p200.number(n: Nat, t: U32, v: U32) -> U32:
  match n:
    case 0n: v
    case 1n+p:
      +u = prng(t)
      p200.number(p, u, U32.add(U32.mul(v, 10), U32.mod(u, 10)))

def p200.op_value(a: Bool, b: Bool) -> U32:
  match a b:
    case False{} False{}: 43
    case False{} True{}: 45
    case True{} False{}: 42
    case True{} True{}: 47

def p200.operator(+t: U32) -> U32:
  p200.op_value(U32.is_ne(U32.and(t, 2), 0), U32.is_ne(U32.and(t, 1), 0))
'''
def certificate(template):
 # Classifier is ASCII-only. Other Unicode codepoints are punctuation.
 bad=[]
 for k,c in enumerate(template):
  if c not in 'ino' and ('a'<=c<='z' or '0'<=c<='9'):bad.append([k,'literal word character'])
  if c in 'in' and k and template[k-1]==c:bad.append([k,'adjacent equal generated classes'])
 return dict(admitted=not bad,refusals=bad,codepoints=len(template),removedLiteralSalts=sum(c not in 'ino' for c in template))
def specialize(template,name):
 cert=certificate(template)
 if not cert['admitted']:
  return 'def '+name+'(s: U32) -> U32:\n  lex(gen('+json.dumps(template,ensure_ascii=False)+', s, 0), (Gap{}, 0))\n',cert
 lines=['def '+name+'(+s: U32) -> U32:','  +acc = {0 : U32}']
 for k,c in enumerate(template):
  if c in 'ino':
   lines.append('  +t = salt(s, '+str(k)+')')
   if c=='i':kind=1;value='p200.ident(U32.to_nat(U32.inc(U32.and(t, 7))), t, 2166136261)'
   elif c=='n':kind=2;value='p200.number(U32.to_nat(U32.inc(U32.mod(t, 6))), t, 0)'
   else:kind=3;value='p200.operator(t)'
   lines.append('  +acc = mix(acc, '+str(kind)+', '+value+')')
  elif c!=' ':lines.append('  +acc = mix(acc, 3, '+str(ord(c))+')')
 lines.append('  acc');return '\n'.join(lines)+'\n',cert

def prng(x):
 x^=(x<<13)&MASK;x^=x>>17;x^=(x<<5)&MASK;return x&MASK
def seed(i):return prng(((i+1)*2654435761)&MASK)
def generate(tpl,s):
 chars=[]
 for k,c in enumerate(tpl):
  t=prng(s^((k*2654435761)&MASK))
  if c in 'in':
   n=1+((t&7) if c=='i' else t%6)
   for _ in range(n):t=prng(t);chars.append(chr((97+t%26) if c=='i' else (48+t%10)))
  elif c=='o':chars.append('+-*/'[t&3])
  else:chars.append(c)
 return ''.join(chars)
def lex(s):
 mode=0;v=0;acc=0
 def mix(a,k,x):return ((a*2654435761)&MASK)^((k*40503+x)&MASK)
 for ch in s:
  c=ord(ch);k=1 if 97<=c<=122 else 2 if 48<=c<=57 else 0 if c==32 else 3
  if k!=mode or k in [0,3]:
   if mode:acc=mix(acc,mode,v)
   mode=k if k in [1,2] else 0;v=2166136261 if mode==1 else 0
  if k==1:v=((v^c)*16777619)&MASK
  elif k==2:v=(v*10+c-48)&MASK
  elif k==3:acc=mix(acc,3,c)
 if mode:acc=mix(acc,mode,v)
 return acc

def pin(f):
 f=Path(f);b=f.read_bytes();return dict(file=str(f.resolve()),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
 src=ROOT/'selfhost/tools/bench/catalogs/native45/fixtures/lexer.bend';original=src.read_text()
 old='def line(i: U32) -> U32:\n  lex(gen(tpl(), seed(i), 0), (Gap{}, 0))';assert original.count(old)==1
 spec,cert=specialize(TEMPLATE,'p200.plan')
 candidate=original.replace(old,KERNEL+'\n'+spec+'\ndef line(i: U32) -> U32:\n  p200.plan(seed(i))')
 assert original.split('# Phase93:',1)[1]==candidate.split('# Phase93:',1)[1]
 (P/'candidate-v2.bend').write_text(candidate)
 templates=[TEMPLATE,'n+i o n;(i)','ii nn','λn🍎i',''];indices=[0,1,17,123,MASK]
 defs=[];checks=[];calls=[]
 for n,t in enumerate(templates):
  name='p200.control'+str(n);body,c=specialize(t,name);defs.append(body)
  for i in indices:
   value=lex(generate(t,seed(i)));checks.append(dict(template=t,index=i,expected=value,certificate=c))
   expression='lex(gen('+json.dumps(t,ensure_ascii=False)+', seed('+str(i)+'), 0), (Gap{}, 0))'
   calls.append('    Unit <- IO.print(String.append(U32.show('+expression+'), String.append(":", U32.show('+name+'(seed('+str(i)+'))))))')
 control=original[:original.index('def main() -> IO(Unit):')]+KERNEL+'\n'+'\n'.join(defs)+'\ndef main() -> IO(Unit):\n  do IO<Unit>:\n'+'\n'.join(calls)+'\n    IO.pure(Unit{})\n'
 (P/'controls-v2.bend').write_text(control)
 expected=''.join(str(x['expected'])+':'+str(x['expected'])+'\n' for x in checks);(P/'controls-v2.expected').write_text(expected)
 points=[[0,0],[0,MASK],[1,0],[3,7],[4,123],[6,17],[8,0]]
 oracle=[dict(args=[n,s],expected=str(sum(lex(generate(TEMPLATE,seed((s+i)&MASK))) for i in range(1<<n))&MASK)+'\n') for n,s in points]
 (P/'oracles-v2.json').write_text(json.dumps(dict(controls=checks,program=oracle),indent=2,ensure_ascii=False)+'\n')
 (P/'certificate-v2.json').write_text(json.dumps(dict(certificate=cert,scope='Source-level semantic specialization, not a native compiler recognizer.',inputs=[pin(src),pin(__file__)],outputs=[pin(P/f) for f in ['candidate-v2.bend','controls-v2.bend','controls-v2.expected','oracles-v2.json']]),indent=2)+'\n')
 print('prepared',len(checks),'complete-state comparison rows; original oracle',oracle[-1])
if __name__=='__main__':main()
