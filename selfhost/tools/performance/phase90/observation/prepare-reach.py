#!/usr/bin/env python3
"""Prepare exact reachability products and a private entry derivative offline."""
import argparse
import importlib.util
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('p90_prepare', HERE / 'prepare.py')
shared = importlib.util.module_from_spec(spec)
spec.loader.exec_module(shared)
ROOT = shared.ROOT


def blocks(text):
    starts = list(re.finditer(r'(?m)^(?:@unsafe\n)?(type|law|def)\s+([^\s(<:]+)', text))
    result = []
    for at, match in enumerate(starts):
        end = starts[at + 1].start() if at + 1 < len(starts) else len(text)
        result.append((match[1], match[2], text[match.start():end].rstrip() + '\n'))
    return result


def native_eq(text):
    return re.sub(shared.TOKEN, lambda m: 'p88_string_eq' if m[0] == 'String.eq' else m[0], text)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--out', required=True, type=Path)
    parser.add_argument('--compiler', type=Path)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    paths = [ROOT / 'selfhost/src/core/term.bend', ROOT / 'selfhost/src/core/index.bend',
             ROOT / 'selfhost/src/core/reach.bend', HERE / 'reach-indexed.bend',
             HERE / 'controls-tail.bend', ROOT / 'selfhost/tools/performance/phase88/strings/helpers.bend']
    term, index, reach, proposed, flat_tail, equality = [p.read_text() for p in paths]
    term = term.split('\nlaw subst_terms:')[0]
    index = index.split('\n# A cached name miss')[0]
    reach = reach.split('\n# Foreign sources')[0]
    flat_tail = flat_tail.split('\n@unsafe\ndef p90_case(')[0]
    # Types first, then original law headers, then definitions: same assembly rule.
    declarations = blocks(term) + blocks(index) + blocks(reach) + blocks(flat_tail)
    prefix = 'import Base\n\n' + equality.split('\ndef p88_string_order_go')[0] + '\n\n'
    common = prefix + '\n'.join(native_eq(s) for kind in ('type', 'law', 'def') for k, n, s in declarations if k == kind)
    false, true = shared.ctor('False'), shared.ctor('True')
    absent = shared.ctor('KTerm', 'Absent', '', 0, 0, [], [], 0, 0)
    def edge(name, tag='Ref'):
        return shared.ctor('KTerm', tag, name, 0, 0, [], [], 3, 9)
    def body(names):
        return shared.ctor('KTerm', 'App', '', 7, 2, [edge(n) for n in names], ['retained'], 4, 13)
    def definition(name, refs=(), types=(), kind='Def', ctors=()):
        return shared.ctor('KDef', name, kind, 2, 1, body(types), body(refs), list(ctors), false, true)
    a, b, c = definition('a', ['b']), definition('b', ['c']), definition('c')
    diamond = [definition('a', ['b', 'c']), definition('b', ['d']), definition('c', ['d']), definition('d')]
    cycle = [definition('a', ['b']), definition('b', ['a'])]
    ctor = definition('Make', [], ['fieldType'], 'Ctr')
    adt = definition('Family', [], ['kindType'], 'ADT', [ctor])
    constructor_book = [definition('main', ['Make']), adt, definition('fieldType'), definition('kindType')]
    empty = definition('')
    collisions = [definition('costarring'), definition('liquid')]
    cases = [
        ('empty', [], ['main'], [], []),
        ('missing', [a,b,c], ['missing'], [], []),
        ('chain', [a,b,c], ['a'], [], [0,1,2]),
        ('late-root', [a,b,c], ['c'], [], [2]),
        ('diamond', diamond, ['a'], [], [0,1,2,3]),
        ('cycle', cycle, ['a'], [], [0,1]),
        ('stopped-body', [a,b,c], ['a'], ['a'], [0]),
        ('stopped-type-remains', [definition('a',['b'],['c']),b,c], ['a'], ['a'], [0,2]),
        ('constructor-parent', constructor_book, ['main'], [], [0,1,2,3]),
        ('constructor-root', constructor_book, ['Make'], [], [1,2,3]),
        ('ordinary-name-wins', [definition('Make'),adt,definition('fieldType'),definition('kindType')], ['Make'], [], [0]),
        ('duplicate-first-resolves', [a,definition('a',['c']),b,c], ['a'], ['b'], [0,1,2]),
        ('empty-name-present', [empty,a,b,c], [''], [], [0]),
        ('empty-name-absent', [a,b,c], [''], [], []),
        ('unicode', [definition('é😀',['é😁']),definition('é😁')], ['é😀'], [], [0,1]),
        ('collision-one', collisions, ['costarring'], [], [0]),
        ('collision-other', collisions, ['liquid'], [], [1]),
        ('collision-both', collisions, ['costarring','liquid'], [], [0,1]),
        ('duplicate-roots', diamond, ['a','a','missing','b'], [], [0,1,2,3]),
        ('duplicate-edges', [definition('a',['b','b','b']),b,c], ['a'], [], [0,1,2]),
    ]
    def flattened(value):
        if isinstance(value, list): return [flattened(x) for x in value]
        if not isinstance(value, dict): return value
        tag = dict(KDef='P90FlatDef', KIndexLeaf='P90FlatLeaf', KIndexNode='P90FlatNode').get(value['tag'],value['tag'])
        return shared.ctor(tag,*[flattened(x) for x in value['fields']])
    helper = '''
type P90ReachCase is Data:
  P90ReachCase{+id: U32, +label: String, +found: List<&2,P90FlatDef>, +retained: List<&2,P90FlatDef>}

@unsafe
def p90_reach_case(id: U32, label: String, +book: List<&2,KDef>, roots: List<&2,String>, stops: List<&2,String>) -> P90ReachCase:
  P90ReachCase{id, label, p90_flat_list(REACH(book, roots, stops)), p90_flat_list(book)}

@unsafe
def main() -> List<&2,P90ReachCase>:
  [
ROWS
  ]
'''
    rows, expected = [], []
    for number,(label,book,roots,stops,selected) in enumerate(cases):
        rows.append('    p90_reach_case(' + ', '.join(shared.literal(x) for x in (number,label,book,roots,stops)) + ')')
        expected.append(shared.ctor('P90ReachCase',number,label,flattened([book[i] for i in selected]),flattened(book)))
    helper = helper.replace('ROWS',',\n'.join(rows))
    baseline = args.out / 'legacy.bend'
    candidate = args.out / 'indexed.bend'
    baseline.write_text(common + helper.replace('REACH','reach_book'))
    candidate.write_text(common + native_eq(proposed) + helper.replace('REACH','p90_reach_book'))
    manifest = dict(kind='phase90-indexed-reach-controls',complete=True,targetExecuted=False,cases=len(cases),
                    expected=expected,labels=[c[0] for c in cases],
                    inputs=[shared.pin(Path(__file__)),shared.pin(HERE/'prepare.py')]+[shared.pin(p) for p in paths],
                    outputs=[shared.pin(baseline),shared.pin(candidate)],
                    oracle='Explicit fixture-selected row indices; compare all fields and retained original book, including order/duplicates.')
    def fnv(s):
        h=2166136261
        for c in s: h=((h^ord(c))*16777619)&0xffffffff
        return h
    assert fnv('costarring') == fnv('liquid')
    manifest['collision'] = dict(names=['costarring','liquid'],hash=fnv('costarring'))
    if args.compiler:
        source=args.compiler.read_text()
        old='annotate_selected(context, reach_book(context, ["main"], stops), stops)'
        new='annotate_selected(context, p90_reach_book(context, ["main"], stops), stops)'
        assert source.count(old)==1 and 'def p90_reach_book(' not in source
        marker='@unsafe\ndef p86_plan_context('
        assert source.count(marker)==1
        derivative=source.replace(old,new).replace(marker,native_eq(proposed)+'\n'+marker,1)
        path=args.out/'compiler-reach.bend';path.write_text(derivative)
        manifest['inputs'].append(shared.pin(args.compiler));manifest['outputs'].append(shared.pin(path))
        manifest['compilerLineDelta']=len(derivative.splitlines())-len(source.splitlines())
    (args.out/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps(dict(complete=True,targetExecuted=False,cases=len(cases),collision=manifest['collision'])))


if __name__ == '__main__':main()
