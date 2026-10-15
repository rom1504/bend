#!/usr/bin/env python3
"""Prepare exact ix/qt held-root readers, full-value controls and a source derivative."""
import argparse, hashlib, json
from pathlib import Path
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]

def pin(path):
    path = path.resolve(); b = path.read_bytes()
    return dict(file=str(path), bytes=len(b), sha256=hashlib.sha256(b).hexdigest())

def replay(text, changes):
    for item in changes:
        at, old, new = item['offset'], item['old'], item['new']
        assert text[at:at+len(old)] == old
        text = text[:at]+new+text[at+len(old):]
    return text

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--parent-recipe', type=Path, default=ROOT/'selfhost/build/phase98/held-source02/changes.json')
    args = parser.parse_args()
    production = ROOT/'selfhost/src/core/term.bend'; text = production.read_text()
    types = text[text.index('type KTerm is Data:'):text.index('type KDef is Data:')]
    old = {name:text[text.index('def '+name+'('):text.index('\n@unsafe\ndef '+following+'(')] for name,following in [('ix','qt'),('qt','ks')]}
    readers = '\n'.join(old[name].replace('def '+name+'(', 'def p98_'+name+'_read(',1) for name in ['ix','qt'])
    finish = 'def p98_term_scalar_finish(value: U32, term: KTerm) -> U32:\n  value\n'
    wrappers = {name:'def '+name+'(+t: KTerm) -> U32:\n  p98_term_scalar_finish(p98_'+name+'_read(t), t)\n' for name in ['ix','qt']}
    private = finish+'\n'+readers+'\n'
    helpers = private+'\n'+wrappers['ix']+'\n'+wrappers['qt']
    helper_path = HERE/'scalar-helpers01.bend'; assert not helper_path.exists(); helper_path.write_text(helpers)
    reference = '\n'.join(old[name].replace('def '+name+'(', 'def p98_'+name+'_reference(',1) for name in ['ix','qt'])
    tag_tail = (HERE/'tag-controls.tail.bend').read_text()
    terms = tag_tail[tag_tail.index('def p98_tag_child('):tag_tail.index('\ndef main(')]
    tail = '''type P98ScalarCase is Data:
  P98ScalarCase{term: KTerm, oldIx: U32, newIx: U32, oldQt: U32, newQt: U32, ownedIx: U32, ownedQt: U32}

def p98_scalar_copy(term: KTerm) -> KTerm:
  match term:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}: KTerm{tag, name, id, quant, kids, removed, begin, end}
    case KLambda{name, id, quant, kids, removed, begin, end, present}: KLambda{name, id, quant, kids, removed, begin, end, present}
    case KLiteral{kind, number, text, begin, end}: KLiteral{kind, number, text, begin, end}

def p98_scalar_case(+term: KTerm) -> P98ScalarCase:
  P98ScalarCase{term, p98_ix_reference(term), ix(term), p98_qt_reference(term), qt(term), ix(p98_scalar_copy(term)), qt(p98_scalar_copy(term))}

def p98_scalar_cases(terms: List<&2,KTerm>) -> List<&2,P98ScalarCase>:
  match terms:
    case Nil{}: Nil{}
    case Con{term, rest}: Con{p98_scalar_case(term), p98_scalar_cases(rest)}

def main() -> List<&2,P98ScalarCase>:
  p98_scalar_cases(Con{KTerm{"wide", "λ🙂", 4294967295, 4294967295, [p98_tag_child()], ["a", "a", ""], 4294967295, 0}, Con{KLambda{"wide", 4294967295, 4294967295, [p98_tag_child()], ["λ"], 0, 4294967295, True{}}, p98_tag_terms()}})
'''
    control = 'import Base\n\n'+types+reference+'\n'+helpers+'\n'+terms+'\n'+tail
    baseline_tail = tail.replace(' ix(', ' p98_ix_reference(').replace(' qt(', ' p98_qt_reference(')
    assert baseline_tail != tail
    baseline = control[:-len(tail)]+baseline_tail
    control_dir = HERE/'scalar-controls01'; assert not control_dir.exists(); control_dir.mkdir()
    (control_dir/'candidate.bend').write_text(control); (control_dir/'baseline.bend').write_text(baseline)
    parent = json.loads(args.parent_recipe.read_text()); assert parent['complete']
    origin = Path(parent['source']['file']); source = Path(parent['candidate']['file'])
    assert pin(origin) == parent['source'] and pin(source) == parent['candidate']
    original = origin.read_text(); current = source.read_text()
    assert replay(original,parent['changes']) == current
    changes = list(parent['changes'])
    for name in ['ix','qt']:
        assert current.count(old[name]) == 1
        change = dict(old=old[name],new=wrappers[name],offset=current.index(old[name]))
        changes.append(change); current = replay(current,[change])
    append = '\n# Phase98 retained-root scalar observation helpers.\n'+private
    changes.append(dict(old='',new=append,offset=len(current))); current += append
    assert replay(original,changes) == current
    reverse = current
    for change in reversed(changes):
        at = change['offset']; assert reverse[at:at+len(change['new'])] == change['new']
        reverse = reverse[:at]+change['old']+reverse[at+len(change['new']):]
    assert reverse == original
    out = args.out.resolve(); assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase98'); out.mkdir()
    (out/'compiler.bend').write_text(current)
    inputs = [pin(Path(__file__)),pin(production),pin(HERE/'tag-controls.tail.bend'),pin(args.parent_recipe),pin(helper_path)]
    common = dict(complete=True,targetsRun=False,inputs=inputs,referenceBodiesExactExceptName=True,
                  scope='Exact U32 projections with retained original root. No children, metadata, source order, quantity or value range changes. Source law and native ownership/code-shape/timing are separate gates.')
    receipt = dict(common,kind='phase98-held-scalar-controls',cases=10,
        outputs=[pin(control_dir/'candidate.bend'),pin(control_dir/'baseline.bend')],
        oracle='Complete stdout equality; records preserve original full term, old/new ix/qt, and two fresh-expression observations. Covers all3variants, U32max IDs/quantities, Unicode, children, duplicates, spans and payloads.')
    (control_dir/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
    receipt = dict(common,kind='phase98-held-simple-scalar-source-derivative',source=pin(origin),parentSource=pin(source),
        parentRecipe=pin(args.parent_recipe),candidate=pin(out/'compiler.bend'),changes=changes,
        physicalLineDelta=len(current.splitlines())-len(original.splitlines()),additionalLinesOverHeldSimple=len(current.splitlines())-len(source.read_text().splitlines()),
        forwardReplayExact=True,inverseRecoversSource=True)
    (out/'changes.json').write_text(json.dumps(receipt,indent=2)+'\n')
    print(json.dumps({k:receipt[k] for k in ['candidate','physicalLineDelta','additionalLinesOverHeldSimple']}))

if __name__ == '__main__': main()
