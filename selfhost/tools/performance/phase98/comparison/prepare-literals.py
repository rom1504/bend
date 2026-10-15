#!/usr/bin/env python3
"""Offline exact-literal equality specialization; emits Bend source only."""
import argparse, collections, hashlib, json, re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
TOKEN = re.compile(r'#[^\n]*|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|[A-Za-z_][\w.]*|[^\s]')

def pin(path):
    path = path.resolve(); data = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=ROOT/'selfhost/tools/performance/phase90/observation/noindent01/compiler-noindent.bend')
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--minimum-count', type=int, default=2)
    parser.add_argument('--maximum-codepoints', type=int, default=16)
    args = parser.parse_args()
    assert args.minimum_count >= 1 and 0 <= args.maximum_codepoints <= 64
    source = args.source.resolve(); original = source.read_text()
    assert original.startswith('import Base\n') and 'def p98_eq_literal_' not in original
    tokens = [m for m in TOKEN.finditer(original) if not m[0].startswith('#')]
    sites = []
    for i, token in enumerate(tokens[:-1]):
        if token[0] != 'p88_string_eq' or tokens[i+1][0] != '(' or (i and tokens[i-1][0] == 'def'):
            continue
        stack, start, arguments = [], i+2, []
        for j in range(i+1, len(tokens)):
            value = tokens[j][0]
            if value in ('(', '[', '{'): stack.append(value)
            elif value in (')', ']', '}'):
                assert stack.pop() == {')':'(', ']':'[', '}':'{'}[value]
                if not stack:
                    arguments.append((start,j)); break
            elif value == ',' and len(stack) == 1:
                arguments.append((start,j)); start = j+1
        assert len(arguments) == 2
        literals = [k for k,(a,b) in enumerate(arguments) if b-a == 1 and tokens[a][0].startswith('"')]
        if not literals: continue
        literal_position = literals[-1]
        a,b = arguments[literal_position]
        raw = tokens[a][0]
        # Current eligible literals have no escapes. Leave every escaped string
        # on the original helper rather than inventing a Bend escape decoder.
        if '\\' in raw: continue
        literal = raw[1:-1]
        a,b = arguments[1-literal_position]
        sites.append(dict(start=token.start(), stop=tokens[j].end(), literal=literal,
                          argumentStart=tokens[a].start(), argumentStop=tokens[b-1].end(),
                          line=original.count('\n',0,token.start())+1))
    counts = collections.Counter(x['literal'] for x in sites)
    chosen = sorted(k for k,v in counts.items() if v >= args.minimum_count and len(k) <= args.maximum_codepoints)
    names = {literal:'p98_eq_literal_'+hashlib.sha256(literal.encode()).hexdigest()[:12] for literal in chosen}
    assert len(set(names.values())) == len(names)
    selected = [x for x in sites if x['literal'] in names]
    # A selected comparison's argument may contain another selected comparison.
    # Rewrite complete source intervals recursively, preserving all other bytes.
    def rewrite(begin,end):
        result=[]; cursor=begin
        for item in selected:
            if item['start'] < cursor or item['stop'] > end: continue
            result += [original[cursor:item['start']], names[item['literal']], '(',
                       rewrite(item['argumentStart'],item['argumentStop']), ')']
            cursor=item['stop']
        result.append(original[cursor:end]); return ''.join(result)
    helpers=[]
    for literal in chosen:
        pattern='SNil{}'
        for codepoint in reversed(literal): pattern='SCon{Chr{'+str(ord(codepoint))+'}, '+pattern+'}'
        helpers.append('def '+names[literal]+'(value: String) -> Bool:\n  match value:\n    case '+pattern+': True{}\n    case other: False{}\n')
    helper_text='\n'.join(helpers)
    rewritten=rewrite(0,len(original))
    # Replay independently with innermost offset replacements. This deliberately
    # rejects nested selected sites for a simple inverse transport receipt.
    ordered=sorted(selected,key=lambda x:x['start'])
    assert all(a['stop'] <= b['start'] for a,b in zip(ordered,ordered[1:])), 'Nested selected comparisons require a new explicit receipt version'
    changes=[]; replay=original
    for item in reversed(ordered):
        before=original[item['start']:item['stop']]
        after=names[item['literal']]+'('+original[item['argumentStart']:item['argumentStop']]+')'
        replay=replay[:item['start']]+after+replay[item['stop']:]
        changes.append(dict(offset=item['start'],old=before,new=after,line=item['line'],literal=item['literal']))
    assert replay==rewritten
    insertion='\n# Phase98 exact-literal comparison helpers, safe Bend source.\n'+helper_text+'\n'
    result=rewritten.replace('import Base\n','import Base\n'+insertion,1)
    reverse=result.replace(insertion,'',1)
    for change in reversed(changes):
        offset=change['offset']; assert reverse[offset:offset+len(change['new'])]==change['new']
        reverse=reverse[:offset]+change['old']+reverse[offset+len(change['new']):]
    assert reverse==original
    out=args.out.resolve(); assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase98')
    out.mkdir(parents=True)
    (out/'compiler.bend').write_text(result); (out/'helpers.bend').write_text(helper_text)
    report=dict(kind='phase98-literal-equality-source-derivative',complete=True,targetsRun=False,
                source=pin(source),method=pin(Path(__file__)),options=vars(args)|{'source':str(source),'out':str(out)},
                candidate=pin(out/'compiler.bend'),helpers=pin(out/'helpers.bend'),
                literalSites=len(sites),selectedSites=len(selected),distinctLiterals=len(chosen),
                physicalLineDelta=len(result.splitlines())-len(original.splitlines()),
                counts=dict(counts),helperNames=names,changes=changes,insertion=insertion,
                forwardReplayExact=True,inverseRecoversSource=True,
                scope='Source-only exact literal specialization; dynamic/dynamic comparisons and escaped literals unchanged. No borrowing permission or generated C rewrite.')
    assert source.read_text()==original
    (out/'changes.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n')
    print(json.dumps({k:report[k] for k in ['candidate','selectedSites','distinctLiterals','physicalLineDelta']}))

if __name__=='__main__': main()
