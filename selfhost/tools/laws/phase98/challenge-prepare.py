#!/usr/bin/env python3
"""Freeze independent challenges against existing finite suites; no targets."""
import argparse
import copy
import importlib.util
import json
from pathlib import Path
import re
import shutil
import sys
sys.dont_write_bytecode = True
from common import ROOT, BUILD, pin, read, save, verify

HERE = Path(__file__).resolve().parent
CHALLENGE = HERE/'challenge'
BASE = ROOT/'selfhost/build/phase97/challenge-base01'
STRINGS = ROOT/'selfhost/tools/performance/phase88/strings'
COMPARISON = ROOT/'selfhost/tools/performance/phase98/comparison'


def chars(text):
    return list(map(ord, text))


def load_recipes():
    manifest = read(CHALLENGE/'all-manifest01.json')
    rows = []
    for item in manifest['cases']:
        path = ROOT/item['path']; actual = pin(path)
        assert (actual['bytes'], actual['sha256']) == (item['bytes'], item['sha256'])
        row = read(path); source = row['source']; actual = pin(ROOT/source['path'])
        assert (actual['bytes'], actual['sha256']) == (source['bytes'], source['sha256'])
        rows.append(row)
    return rows


def helpers():
    serializer = (BASE/'methods/serialize.bend').read_text()
    # Reuse the exact old complete character/Bool observers; only new compound
    # result shapes need adapters. No expected value is read from generated code.
    prefix = serializer[:serializer.index('@unsafe\ndef p96.strings_body')]
    extra = '''
@unsafe
def p98.cmp(c: Cmp) -> String:
  match c:
    case LT{}: "0"
    case EQ{}: "1"
    case GT{}: "2"

@unsafe
def p98.held(value: P98EqHeld) -> String:
  match value:
    case P98EqHeld{same, left, right}:
      "[" ++ p96.bool(same) ++ "," ++ p96.string(left) ++ "," ++ p96.string(right) ++ "]"

@unsafe
def p98.bools_body(values: List<&2,Bool>) -> String:
  match values:
    case Nil{}: ""
    case Con{head, Nil{}}: p96.bool(head)
    case Con{head, Con{next, rest}}: p96.bool(head) ++ "," ++ p98.bools_body(Con{next, rest})

@unsafe
def p98.bools(values: List<&2,Bool>) -> String:
  "[" ++ p98.bools_body(values) ++ "]"

@unsafe
def p98.check_branch(value: P98CheckNode) -> String:
  match value:
    case P98CheckNode0{}: "0"
    case P98CheckNode1{}: "1"
    case P98CheckNode2{}: "2"
    case P98CheckNode3{}: "3"
    case P98CheckNode4{}: "4"
    case P98CheckNode5{}: "5"
    case P98CheckNode6{}: "6"
    case P98CheckNodeDefault{}: "7"
'''
    return serializer, prefix, extra


def targeted(recipes, mutation=None):
    sys.path.insert(0, str(BASE/'methods'))
    spec = importlib.util.spec_from_file_location('p98_p96_extract', BASE/'methods/prepare.py')
    module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
    sources = {name:(BASE/'production-source'/name).read_text() for name in module.SOURCES}
    sources.update({str(STRINGS/'helpers.bend'):(STRINGS/'helpers.bend').read_text(),
                    str(COMPARISON/'held-helpers01.bend'):(COMPARISON/'held-helpers01.bend').read_text(),
                    str(COMPARISON/'literal-helpers01.bend'):(COMPARISON/'literal-helpers01.bend').read_text()})
    selector = ROOT/'selfhost/build/phase98/dispatch-frozen02/selectors.canonical.bend'
    sources[str(selector)] = selector.read_text()
    if mutation:
        file=mutation['file']
        key=str(Path(file).relative_to('selfhost/src')) if file.startswith('selfhost/src/') else str(ROOT/file)
        assert sources[key].count(mutation['before'])==1
        sources[key]=sources[key].replace(mutation['before'],mutation['after'],1)
    child = [0, chars('Var'), chars('x'), 2147483649, 1, [], [chars('hidden')], 31, 47]
    expected = {'bad01-logical-literal-is-constructor':False,
        'bad02-lambda-observation-loses-variant':[1, chars('bound'), 17, 2, [child], [chars('A'), chars('B')], 11, 53, False],
        'bad03-equality-forgets-last-mismatch':False, 'bad04-order-forgets-earlier-mismatch':2,
        'bad05-equality-truncates-characters':False, 'bad06-literal-recognizer-accepts-prefix':False,
        'bad07-dispatch-loses-alternative':2,
        'bad08-held-observation-repeats-left':[False, chars('left'), chars('right')],
        'good01-reconstruct-literal-exactly':[2, chars('U32'), 37, chars('retained'), 13, 29],
        'good02-character-equality-by-codepoint':[False, True, False]}
    observers = {'Bool':'p96.bool', 'KTerm':'p96.term', 'Cmp':'p98.cmp',
                 'P98EqHeld':'p98.held', 'P98CheckNode':'p98.check_branch', 'List<&2, Bool>':'p98.bools'}
    cases = [dict(id=r['id'],family='independent-targeted-followup',expectedWire=expected[r['id']],
                  exportName=f'p98_case_{i:03}',
                  expression=observers[r['witness']['returnType']]+'('+r['witness']['expression']+')')
             for i,r in enumerate(recipes)]
    serializer, _, extra = helpers()
    harness = serializer+extra+'\n'+'\n'.join('@unsafe\ndef '+c['exportName']+'() -> String:\n  '+c['expression']+'\n' for c in cases)
    extracted, closure = module.extract(sources, harness)
    return extracted+'\n'+harness, cases, closure


def string_adapter(type_name, fields, field_formats):
    row = '@unsafe\ndef p98.row(value: '+type_name+') -> String:\n  match value:\n    case '+type_name+'{'+', '.join(fields)+'}:\n      '
    row += '"[" ++ '+ ' ++ "," ++ '.join(f+'('+name+')' for name,f in zip(fields,field_formats))+' ++ "]"\n'
    row += '\n@unsafe\ndef p98.rows(values: List<&2,'+type_name+'>) -> String:\n  match values:\n    case Nil{}: ""\n    case Con{head, Nil{}}: p98.row(head)\n    case Con{head, Con{next, rest}}: p98.row(head) ++ "," ++ p98.rows(Con{next, rest})\n'
    row += '\n@unsafe\ndef p98_case_000() -> String:\n  "[" ++ p98.rows(main()) ++ "]"\n'
    return row


def suite_source(suite, recipes):
    if suite == 'production':
        old = read(BASE/'manifest.json')
        return (BASE/'library.bend').read_text(), old['cases'], old['extraction'], [BASE/'manifest.json']
    if suite == 'targeted':
        source, cases, closure = targeted(recipes)
        return source, cases, closure, [BASE/'methods/prepare.py',BASE/'methods/reference.py',BASE/'methods/serialize.bend']
    if suite in ['strings', 'held']:
        path = STRINGS/'controls-v5.bend' if suite == 'strings' else COMPARISON/'held-controls01.bend'
        oracle = read(STRINGS/'controls-v5.json'); corpus = oracle['corpus']
        source = path.read_text()
        # The exact original corpus constructor is retained by the held wrapper.
        original = (STRINGS/'controls-v5.bend').read_text()
        for text in [source, original]:
            actual = [json.loads(x) for x in re.findall(r'p88_codes\((\[[\d, ]*\])\)', text)]
            assert actual == corpus
        expected = []
        for i,a in enumerate(corpus):
            for j,b in enumerate(corpus):
                eq=int(a==b);order=0 if a<b else 1 if a==b else 2
                expected.append([i,j,eq,eq,eq,order,order,order,len(a),len(b),sum(a)%2**32,sum(b)%2**32])
        expected.reverse()  # Existing p88_rows/columns prepend each observation.
        fields=['a','b','oldEq','sharedEq','ownedEq','oldOrder','sharedOrder','ownedOrder','lenA','lenB','sumA','sumB']
        source += string_adapter('P88StringCheck', fields, ['U32.show']*12)
        return source, [dict(id='existing-1444-string-pairs',family='existing-string-controls',expectedWire=expected,exportName='p98_case_000')], [], [path,STRINGS/'controls-v5.json',STRINGS/'compare-output.py']
    path=COMPARISON/'literal-smoke01.bend';source=path.read_text()
    values=[json.loads(x) for x in re.findall(r'p98_compare\(("(?:\\.|[^"\\])*")\)',source)]
    assert len(values)==10
    expected=[[chars(v),v=='Var',v=='Var',v=='',v=='',v=='λ🙂',v=='λ🙂'] for v in values]
    _,prefix,_=helpers()
    source += '\n'+prefix+string_adapter('P98Comparison',['input','oldVar','newVar','oldEmpty','newEmpty','oldUnicode','newUnicode'],['p96.string']+['p96.bool']*6)
    return source,[dict(id='existing-10-literal-inputs',family='existing-literal-controls',expectedWire=expected,exportName='p98_case_000')],[],[path,BASE/'methods/serialize.bend']


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out',type=Path,required=True)
    parser.add_argument('--suite',choices=['production','strings','held','literal','targeted'],required=True)
    args=parser.parse_args();out=args.out.resolve();assert out.is_relative_to(BUILD) and not out.exists()
    recipes=load_recipes();base=read(BASE/'manifest.json')
    for item in base['frozenInputs']+list(base['b2'].values()):verify(item)
    source,cases,closure,dependencies=suite_source(args.suite,recipes)
    out.mkdir(parents=True)
    inputs=[pin(__file__),pin(HERE/'common.py'),pin(CHALLENGE/'all-manifest01.json'),pin(BASE/'manifest.json'),
            pin(BASE/'methods/run.mjs'),*map(pin,dependencies)]
    inputs += [pin(CHALLENGE/(r['id']+'.json')) for r in recipes]
    receipt=dict(complete=False,targetsRun=False,suite=args.suite,inputs=inputs,cases=len(cases),roles=[],excluded=[],
                 scope='Existing cases unchanged; adapters serialize all original output fields. Targeted mode is separately labeled and must follow frozen-suite outcomes.')
    functions=set(re.findall(r'(?m)^def ([\w.]+)\b',source))
    for recipe in [None,*recipes]:
        role='baseline' if recipe is None else recipe['id'];body=source;mapping=None
        if recipe:
            function=recipe['function'];before,after=recipe['before'],recipe['after']
            if args.suite=='held' and function=='p88_string_eq_go':
                before=before.replace('p88_string_eq_go','p98_eq_walk');after=after.replace('p88_string_eq_go','p98_eq_walk')
                function='p98_eq_walk';mapping='Exact identifier rename p88_string_eq_go -> p98_eq_walk; original semantic edit unchanged.'
            if function not in functions:
                receipt['excluded'].append(dict(id=role,classification='outside-extracted-closure',targetExecuted=False));continue
            if args.suite=='targeted':
                body,role_cases,closure=targeted(recipes,recipe)
                assert role_cases==cases
                mapping='Dependency closure recomputed after the exact frozen module edit.'
            else:
                assert body.count(before)==1,(args.suite,role,'ambiguous or missing frozen edit')
                body=body.replace(before,after,1)
        folder=out/role;folder.mkdir();(folder/'methods').mkdir()
        shutil.copyfile(BASE/'methods/run.mjs',folder/'methods/run.mjs')
        (folder/'library.bend').write_text(body)
        manifest=dict(kind='phase98-independent-finite-challenge',complete=True,targetsRun=False,
                      b2=base['b2'],cases=copy.deepcopy(cases),library=pin(folder/'library.bend'),
                      frozenInputs=[pin(folder/'library.bend'),pin(folder/'methods/run.mjs')],extraction=closure,
                      suite=args.suite,baseline=pin(BASE/'manifest.json'),
                      mutation=None if recipe is None else dict(id=role,kind=recipe['kind'],recipe=pin(CHALLENGE/(role+'.json')),mapping=mapping))
        save(folder/'manifest.json',manifest)
        receipt['roles'].append(dict(id=role,kind='baseline' if recipe is None else recipe['kind'],manifest=pin(folder/'manifest.json'),mapping=mapping))
    for item in inputs:verify(item)
    receipt['complete']=True;receipt['inputsUnchanged']=True;save(out/'receipt.json',receipt)
    print(json.dumps(dict(suite=args.suite,roles=len(receipt['roles']),excluded=len(receipt['excluded']),targetsRun=False)))


if __name__=='__main__':main()
