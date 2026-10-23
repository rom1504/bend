"""Inline transfer-only helpers to avoid ordinary-source forward-law admission.

The original String comparison is untouched. Both compiler variants consume the
same list definition and the same independently computed ordinary oracle.
"""
import hashlib
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent
def pin(path):
    path=path.resolve();data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
old=json.loads((HERE/'cases-v03.json').read_text());rows=[]
body='''def p131l_cmp(a: P131List, b: P131List) -> (P131List & P131List) & Cmp:
  match a b:
    case P131Nil{} P131Nil{}: ((P131Nil{},P131Nil{}),EQ{})
    case P131Nil{} P131Cons{h,t}: ((P131Nil{},P131Cons{h,t}),LT{})
    case P131Cons{h,t} P131Nil{}: ((P131Cons{h,t},P131Nil{}),GT{})
    case P131Cons{+ha,ta} P131Cons{+hb,tb}:
      match U32.cmp(ha,hb):
        case LT{}: ((P131Cons{ha,ta},P131Cons{hb,tb}),LT{})
        case EQ{}:
          ((ra,rb),c) = p131l_cmp(ta,tb)
          ((P131Cons{ha,ra},P131Cons{hb,rb}),c)
        case GT{}: ((P131Cons{ha,ta},P131Cons{hb,tb}),GT{})

'''
for c in old['cases']:
    if c['name']=='projection-string':rows.append(c);continue
    source=Path(c['source']['file']);assert pin(source)==c['source'];text=source.read_text()
    start=text.index('def p131l_cmp_rec(');end=text.index('def p131l_query(')
    text=text[:start]+body+text[end:]
    target=HERE/'projection-list-v04.bend';assert not target.exists();target.write_text(text)
    rows.append(dict(c,source=pin(target)))
out=HERE/'cases-v04.json';assert not out.exists()
out.write_text(json.dumps(dict(complete=True,targetsRun=False,cases=rows,
    inputs=[pin(Path(__file__)),pin(HERE/'cases-v03.json')],
    scope='String exact qualified baseline-v05 unchanged; list transfer uses one directly recursive comparator instead of forward-law helpers, with identical retained-root algorithm and independent oracle. Same sources under both compilers.'),indent=2)+'\n')
print(str(out))
