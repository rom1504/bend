#!/usr/bin/env python3
"""Source-transformer controls only. This does not run Bend or prove semantics."""
import collections
import importlib.util
import json
import sys
from pathlib import Path

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('p144_predicate_canon',HERE/'canonicalize-v01.py')
C=importlib.util.module_from_spec(spec);sys.modules[spec.name]=C;spec.loader.exec_module(C)


def normalized(s):return [t.text for t in C.lex(s)]


def case(name,expression,expected,accepted,protected=(),extra=''):
    source='def test(x: Bool) -> Bool:\n  '+expression+'\n'+extra
    rows=[{'raw':source,'kind':'def','name':'test','line':1}]
    after,yes,no=C.transform(source,rows,set(protected))
    assert len(yes)==accepted,(name,yes,no)
    assert normalized(after)==normalized('def test(x: Bool) -> Bool:\n  '+expected+'\n'+extra),name
    return {'name':name,'accepted':len(yes),'refused':[r['reason']for r in no]}


def main():
    rows=[]
    rows.append(case('simple','kc(Bool,Bool.not(x),u=>True{},v=>False{})','kc(Bool,x,v=>False{},u=>True{})',1))
    rows.append(case('nested','kc(Bool,Bool.not(x),u=>kc(Bool,Bool.not(x),a=>True{},b=>False{}),v=>False{})',
      'kc(Bool,x,v=>False{},u=>kc(Bool,x,b=>False{},a=>True{}))',2))
    rows.append(case('generic-and-delimiters',
      'kc(List<&2,String>,Bool.not(test("#,)",\'(\',P{a,b})),u=>["x,y"],v=>["{z}"])',
      'kc(List<&2,String>,test("#,)",\'(\',P{a,b}),v=>["{z}"],u=>["x,y"])',1))
    for name,s in [
      ('nonlambda','kc(Bool,Bool.not(x),make_thunk(),v=>False{})'),
      ('partial-negated-condition','kc(Bool,Bool.not(x) && True{},u=>True{},v=>False{})'),
      ('negation-has-two-arguments','kc(Bool,Bool.not(x,x),u=>True{},v=>False{})'),
      ('block-thunk','kc(Bool,Bool.not(x),u=>do IO<Bool>: x,v=>False{})'),
      ('qualified-chooser','Other.kc(Bool,Bool.not(x),u=>True{},v=>False{})')]:
        rows.append(case(name,s,s,0))
    expr='kc(Bool,Bool.not(x),u=>True{},v=>False{})'
    rows.append(case('protected',expr,expr,0,protected=['test']))
    rows.append(case('local-shadow',expr,expr,0,extra='  kc = y\n'))
    rows.append(case('comment-is-not-a-call','True{} # '+expr,'True{} # '+expr,0))
    rows.append(case('literal-is-not-a-call','"'+expr+'"','"'+expr+'"',0))
    # Whole-source independent token multiset conservation: each accepted site
    # removes only the Bool.not callee and its single parenthesis pair. All
    # string/char tokens and all other spelling multiplicities are retained.
    root=C.ROOT/'selfhost/build/phase144/predicate-canonical-source01'
    manifest=json.loads((root/'manifest.json').read_text())
    before=collections.Counter(normalized(Path(manifest['parent']['file']).read_text()))
    after=collections.Counter(normalized(Path(manifest['source']['file']).read_text()))
    expected=before.copy();n=len(manifest['accepted'])
    for token in ('Bool.not','(',')'):expected[token]-=n
    assert after==+expected
    report={'complete':True,'targetsRun':False,'rows':rows,'wholeSourceAccepted':n,
      'wholeSourceTokenMultisetConserved':True,'inputs':[C.pin(__file__),C.pin(HERE/'canonicalize-v01.py'),C.pin(root/'manifest.json')],
      'scope':'Independent finite host lexer/rewrite controls and whole-source token conservation, not Bend sourcechecking or semantic proof.'}
    out=root/'transformer-controls.json';assert not out.exists();out.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({'complete':True,'rows':len(rows),'wholeSourceAccepted':n}))


if __name__=='__main__':main()
