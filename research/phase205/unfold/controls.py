"""Source-only admission, refusal and residual effect checks. These do not execute Bend."""
import json
from pathlib import Path
from stage import transform
HERE=Path(__file__).resolve().parent


def sample(value, step='fold(rest, U32.add(s, c))',arg='tpl',base='s'):
    return 'import Base\n\ndef fold(tpl: String, +s: U32) -> U32:\n  match '+arg+':\n    case SNil{}: '+base+'\n    case SCon{Chr{c}, rest}: '+step+'\n\ndef use(+x: U32, +dynamic: String) -> U32:\n  fold('+value+', x)\n'

def check():
    tests={}
    def run(name,src,expected,count=None,contains=()):
        out,r=transform(src);assert bool(r)==expected and (out!=src)==expected,(name,r)
        if expected:
            body=out.split('def p205unfold_fn0(',1)[1].split('\ndef use',1)[0]
            assert r[0]['characters']==count and all(x in body for x in contains),(name,r,body)
        tests[name]=dict(admitted=bool(r),sites=r)
    run('dynamic-template',sample('dynamic'),False)
    run('over-budget',sample('"'+'x'*65+'"'),False)
    run('at-budget',sample('"'+'x'*64+'"'),True,64)
    run('empty',sample('""'),True,0)
    run('unicode',sample('"Ω🌈"'),True,2,('937','127752'))
    run('original-on-nondecreasing-recursion',sample('"xy"','fold(tpl, s)'),False)
    run('duplicate-tail-visits',sample('"xy"','U32.add(fold(rest,s),fold(rest,s))'),False)
    run('shadowed-primitive',sample('"x"')+'\ndef U32.add(x: U32, y: U32) -> U32:\n  y\n',False)
    run('shadowed-argument',sample('"x"').replace('use(+x:', 'use(+fold:').replace('fold("x", x)', 'fold("x", fold)'),False)
    run('qualified-import-refusal',sample('"x"').replace('import Base','import Else'),False)
    # A potentially nonterminating call discarded by a known branch must still
    # be present in the generated bindings, in original evaluation order.
    src='''import Base

def diverge(x: U32) -> U32:
  diverge(x)

def choose(k: Bool, ignored: U32, +s: U32) -> U32:
  match k:
    case True{}: s
    case False{}: U32.add(ignored,s)

'''+sample('"abc"','choose(True{}, diverge(s), fold(rest,s))').split('import Base\n\n',1)[1]
    run('unused-opaque-call-preserved',src,True,3,('diverge(s)',));out,_=transform(src);mid=out.split('def p205unfold_fn0(',1)[1].split('\ndef use',1)[0];assert mid.count('diverge(s)')==3
    return tests

if __name__=='__main__':print(json.dumps(check(),indent=2))
