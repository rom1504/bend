"""Use the repository's checked Cmp/thunk pattern; no forward law/computed match."""
import hashlib
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent
def pin(path):
    path=path.resolve();b=path.read_bytes()
    return dict(file=str(path),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
old=json.loads((HERE/'cases-v04.json').read_text());rows=[]
body='''def p131l_cmp_rec(ha: U32, hb: U32, rr: (P131List & P131List) & Cmp) ->
  (P131List & P131List) & Cmp:
  ((ta,tb),c) = rr
  ((P131Cons{ha,ta},P131Cons{hb,tb}),c)

def p131l_cmp_choose(less: Unit -> (P131List & P131List) & Cmp,
  equal: Unit -> (P131List & P131List) & Cmp,
  greater: Unit -> (P131List & P131List) & Cmp,
  order: Cmp) -> (P131List & P131List) & Cmp:
  match order:
    case LT{}: less(Unit{})
    case EQ{}: equal(Unit{})
    case GT{}: greater(Unit{})

def p131l_cmp(a: P131List, b: P131List) -> (P131List & P131List) & Cmp:
  match a b:
    case P131Nil{} P131Nil{}: ((P131Nil{},P131Nil{}),EQ{})
    case P131Nil{} P131Cons{h,t}: ((P131Nil{},P131Cons{h,t}),LT{})
    case P131Cons{h,t} P131Nil{}: ((P131Cons{h,t},P131Nil{}),GT{})
    case P131Cons{+ha,+ta} P131Cons{+hb,+tb}:
      p131l_cmp_choose(
        u => ((P131Cons{ha,ta},P131Cons{hb,tb}),LT{}),
        u => p131l_cmp_rec(ha,hb,p131l_cmp(ta,tb)),
        u => ((P131Cons{ha,ta},P131Cons{hb,tb}),GT{}),
        U32.cmp(ha,hb))

'''
for c in old['cases']:
    if c['name']=='projection-string':rows.append(c);continue
    source=Path(c['source']['file']);assert pin(source)==c['source'];text=source.read_text()
    text=text[:text.index('def p131l_cmp(')]+body+text[text.index('def p131l_query('):]
    target=HERE/'projection-list-v05.bend';assert not target.exists();target.write_text(text)
    rows.append(dict(c,source=pin(target)))
out=HERE/'cases-v05.json';assert not out.exists()
out.write_text(json.dumps(dict(complete=True,targetsRun=False,cases=rows,
    inputs=[pin(Path(__file__)),pin(HERE/'cases-v04.json'),pin(HERE.parent/'laws/merge-production-v01.bend')],
    scope='String unchanged. List comparator uses checked parameter-Cmp/Unit-thunk selector pattern, preserving one comparison and selected reconstruction branch; direct structural self recursion replaces unresolved forward law. Same source and independent oracle for both compilers.'),indent=2)+'\n')
print(str(out))
