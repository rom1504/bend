#!/usr/bin/env python3
"""Offline fused tag comparison derivative, replayable from the original D04."""
import argparse, bisect, collections, hashlib, json, re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
TOKEN = re.compile(r'#[^\n]*|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|[A-Za-z_][\w.]*|[^\s]')

def pin(path):
    path = path.resolve(); data = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))

def replay(source, changes):
    for change in changes:
        old, new, offset = change['old'], change['new'], change['offset']
        assert source[offset:offset+len(old)] == old
        source = source[:offset]+new+source[offset+len(old):]
    return source

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--parent-recipe', type=Path, default=ROOT/'selfhost/build/phase98/held-source02/changes.json')
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    parent = json.loads(args.parent_recipe.read_text())
    assert parent['complete'] and parent['walkerBodyUnchanged']
    origin = Path(parent['source']['file']); source = Path(parent['candidate']['file'])
    assert pin(origin) == parent['source'] and pin(source) == parent['candidate']
    original = origin.read_text(); text = source.read_text()
    assert replay(original, parent['changes']) == text
    assert 'def p98_tag_eq(' not in text
    tokens = [m for m in TOKEN.finditer(text) if not m[0].startswith('#')]
    ends = {}; stack = []
    for i, token in enumerate(tokens):
        value = token[0]
        if value in ('(', '[', '{'): stack.append((value, i))
        elif value in (')', ']', '}'):
            opening, start = stack.pop()
            assert opening == {')':'(', ']':'[', '}':'{'}[value]
            ends[start] = i
    assert not stack
    changes = []; counts = collections.Counter()
    modules = list(re.finditer(r'^# Module: (.+)$', text, re.M))
    module_offsets = [m.start() for m in modules]
    for i, token in enumerate(tokens[:-3]):
        if token[0] != 'p88_string_eq' or tokens[i+1][0] != '(':
            continue
        if i and tokens[i-1][0] == 'def': continue
        # Keep operand evaluation order: only an exact first-argument tg(...).
        if tokens[i+2][0] != 'tg' or tokens[i+3][0] != '(': continue
        tag_end = ends[i+3]; outer_end = ends[i+1]
        if tokens[tag_end+1][0] != ',': continue
        begin, end = token.start(), tokens[outer_end].end()
        term = text[tokens[i+3].end():tokens[tag_end].start()]
        key = text[tokens[tag_end+1].end():tokens[outer_end].start()]
        old, new = text[begin:end], 'p98_tag_eq('+term+','+key+')'
        changes.append(dict(old=old, new=new, offset=begin, line=text.count('\n',0,begin)+1))
        module_index = bisect.bisect_right(module_offsets, begin)-1
        module = modules[module_index][1].rsplit(':',1)[0] if module_index >= 0 else 'native-entry'
        counts[module] += 1
    changes.sort(key=lambda item:item['offset'], reverse=True)
    assert all(b['offset']+len(b['old']) <= a['offset'] for a,b in zip(changes,changes[1:])), 'Nested selected call requires a new explicit recipe'
    candidate = replay(text, changes)
    helper = HERE/'tag-helpers05.bend'; helper_text = helper.read_text()
    addition = '\n# Phase98 fused scalar tag observation.\n'+helper_text+'\n'
    changes.append(dict(old='', new=addition, offset=len(candidate)))
    candidate += addition
    all_changes = parent['changes']+changes
    assert replay(original, all_changes) == candidate
    reverse = candidate
    for change in reversed(all_changes):
        offset = change['offset']; assert reverse[offset:offset+len(change['new'])] == change['new']
        reverse = reverse[:offset]+change['old']+reverse[offset+len(change['new']):]
    assert reverse == original
    out = args.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase98')
    out.mkdir(parents=True); target = out/'compiler.bend'; target.write_text(candidate)
    receipt = dict(kind='phase98-held-simple-fused-tag-v5-source-derivative', complete=True, targetsRun=False,
        source=pin(origin), parentSource=pin(source), parentRecipe=pin(args.parent_recipe),
        method=pin(Path(__file__)), helper=pin(helper), candidate=pin(target), changes=all_changes,
        parentChanges=len(parent['changes']), selectedSites=len(changes)-1, sitesByModule=dict(counts),
        physicalLineDelta=len(candidate.splitlines())-len(original.splitlines()),
        additionalLinesOverHeldSimple=len(candidate.splitlines())-len(text.splitlines()),
        walkerBodyUnchanged=True, forwardReplayExact=True, inverseRecoversSource=True,
        scope='Only left-operand tg comparisons are fused; exact operands and their order are retained. Whole term stays live until scalar observation. No global borrowing permission, source proof, generated C or runtime edit is inferred.')
    assert pin(origin) == parent['source'] and pin(source) == parent['candidate']
    (out/'changes.json').write_text(json.dumps(receipt,indent=2)+'\n')
    print(json.dumps({k:receipt[k] for k in ['candidate','selectedSites','physicalLineDelta','additionalLinesOverHeldSimple']}))

if __name__ == '__main__': main()
