"""Generate ordinary source controls and independent unsigned arithmetic outputs."""
import hashlib, json
from pathlib import Path
HERE=Path(__file__).resolve().parent
def pin(p):
 b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def save(p,s):
 assert not p.exists();p.write_text(s);return pin(p)
source='''import Base

def witness.pick(test: Bool, a: U32, b: U32) -> U32:
  match test:
    case True{}: a
    case False{}: b

def witness.minimum(+a: U32, +b: U32) -> U32:
  witness.pick(U32.is_lt(a, b), a, b)

def witness.maximum(+a: U32, +b: U32) -> U32:
  witness.pick(Bool.not(U32.is_lt(a, b)), a, b)

def witness.cost(+a: U32, +b: U32) -> U32:
  witness.pick(U32.is_eq(a, b), 0, 1)

def witness.observe(+a: U32, +b: U32) -> IO(Unit):
  IO.print(U32.show(witness.minimum(a, b)) ++ ":" ++ U32.show(witness.maximum(a, b)) ++ ":" ++ U32.show(witness.cost(a, b)) ++ ":" ++ U32.show(U32.add(witness.minimum(a, b), 1)))

def main() -> IO(Unit):
  do IO<Unit>:
'''
values=[0,1,2147483647,2147483648,4294967295];pairs=[(a,b) for a in values for b in values]
source+='\n'.join('    '+('Unit <- ' if i+1<len(pairs) else '')+f'witness.observe({a}, {b})' for i,(a,b) in enumerate(pairs))+'\n'
stdout=''.join(f'{min(a,b)}:{max(a,b)}:{int(a!=b)}:{(min(a,b)+1)&0xffffffff}\n' for a,b in pairs)
s=save(HERE/'ordinary.bend',source);e=save(HERE/'ordinary.expected.json',json.dumps(dict(stdout=stdout,stderr='',status=0),indent=2)+'\n')
save(HERE/'ordinary.json',json.dumps(dict(inputs=[pin(Path(__file__))],cases=[dict(name='predicate-ordinary',source=s,expected=e,expectedStdoutEvidence=e)]),indent=2)+'\n')
