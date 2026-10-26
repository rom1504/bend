#!/usr/bin/env python3
"""Prepare an unselected source candidate; never execute a compiler.

Only kc/T/Bool.not/pure lambda composition is changed. Source spelling is
tokenized, with quoted literals/comments excluded and all delimiters paired.
No arbitrary predicate-name intrinsic or thunk-producing expression rewrite.
"""
import argparse
import bisect
import hashlib
import importlib.util
import json
import re
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
CHOOSERS = {'kc', 'nt_choose', 'f_choose'}
BASE = ROOT / 'bend2/base.bend'
BASE_SHA = '99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return {'file': str(path), 'bytes': len(data), 'sha256': sha(data)}


@dataclass(frozen=True)
class Tok:
    text: str
    begin: int
    end: int
    kind: str


def lex(text):
    """Bend lexical subset sufficient to locate, never evaluate, call arguments."""
    result = []
    i = 0
    while i < len(text):
        c = text[i]
        if c.isspace():
            i += 1
            continue
        if c == '#':
            end = text.find('\n', i)
            i = len(text) if end < 0 else end
            continue
        start = i
        if c in ('"', "'"):
            quote = c
            i += 1
            while i < len(text):
                if text[i] == '\\':
                    i += 2
                elif text[i] == quote:
                    i += 1
                    break
                else:
                    i += 1
            else:
                raise ValueError('unterminated literal at ' + str(start))
            if i > len(text):
                raise ValueError('unterminated escape')
            result.append(Tok(text[start:i], start, i, 'literal'))
        elif c.isascii() and (c.isalpha() or c == '_'):
            i += 1
            while i < len(text) and text[i].isascii() and (text[i].isalnum() or text[i] in '_.'):
                i += 1
            result.append(Tok(text[start:i], start, i, 'name'))
        else:
            if text[i:i+2] in ('->', '=>', '<-', '==', '!=', '&&', '||', '<=', '>='):
                i += 2
            else:
                i += 1
            result.append(Tok(text[start:i], start, i, 'symbol'))
    return result


def brackets(tokens):
    opens = {'(': ')', '[': ']', '{': '}', '<': '>'}
    closes = set(opens.values())
    pairs = {}
    stack = []
    for i, token in enumerate(tokens):
        if token.kind == 'literal':
            continue
        if token.text in opens:
            stack.append(i)
        elif token.text in closes:
            if not stack or opens[tokens[stack[-1]].text] != token.text:
                raise ValueError('unbalanced delimiter at ' + str(token.begin))
            first = stack.pop()
            pairs[first] = i
            pairs[i] = first
    if stack:
        raise ValueError('unclosed delimiter')
    return pairs


def arguments(tokens, pairs, opening):
    assert tokens[opening].text == '('
    end = pairs[opening]
    args = []
    start = i = opening + 1
    while i < end:
        if tokens[i].text == ',' and tokens[i].kind != 'literal':
            if start == i:
                return None
            args.append((start, i))
            start = i + 1
        elif i in pairs and pairs[i] > i:
            i = pairs[i]
        i += 1
    if start != end:
        args.append((start, end))
    return args


def unparen(tokens, pairs, span):
    lo, hi = span
    while hi > lo and tokens[lo].text == '(' and pairs.get(lo) == hi - 1:
        lo, hi = lo + 1, hi - 1
    return lo, hi


def is_lambda(tokens, pairs, span):
    lo, hi = unparen(tokens, pairs, span)
    if lo < hi and tokens[lo].text == '+':
        lo += 1
    return hi > lo + 2 and tokens[lo].kind == 'name' and tokens[lo+1].text == '=>'


def values(tokens, span):
    lo, hi = span
    return tokens[lo].begin, tokens[hi-1].end


def normalized_declaration(text):
    return tuple(t.text for t in lex(text) if t.text not in ('@', 'unsafe'))


def assert_rules(rows, census):
    laws = census.parse(str(HERE / 'laws/production-v01.bend'))
    for name in CHOOSERS:
        actual = [r for r in rows if r['kind'] == 'def' and r['name'] == name]
        expected = [r for r in laws if r['kind'] == 'def' and r['name'] == name]
        assert len(actual) == len(expected) == 1
        assert normalized_declaration(actual[0]['raw']) == normalized_declaration(expected[0]['raw']), name
    assert pin(BASE)['sha256'] == BASE_SHA
    base = [r for r in census.parse(str(BASE)) if r['name'] == 'Bool.not']
    assert len(base) == 1 and base[0]['kind'] == 'def'
    expected = 'def Bool.not(b: Bool) -> Bool: match b: case False{}: True{} case True{}: False{}'
    assert normalized_declaration(base[0]['raw']) == normalized_declaration(expected)
    assert not any(r['name'] == 'Bool.not' for r in rows), 'local override of imported rule'


def transform(text, rows, protected, hot_only=False):
    tokens = lex(text)
    pairs = brackets(tokens)
    starts = [t.begin for t in tokens]
    # The existing declaration parser preserves every law/definition, not a
    # last-definition dictionary. Locate all of its raw slices exactly.
    declarations = []
    cursor = 0
    for row in rows:
        at = text.find(row['raw'], cursor)
        assert at >= cursor
        cursor = at + len(row['raw'])
        declarations.append((at, cursor, row))
    declared = [x[0] for x in declarations]
    laws = {r['name'] for r in rows if r['kind'] == 'law'}
    candidates = []
    rejected = []
    for i, token in enumerate(tokens):
        if token.text not in CHOOSERS or i+1 >= len(tokens) or tokens[i+1].text != '(':
            continue
        args = arguments(tokens, pairs, i+1)
        if args is None or len(args) != 4:
            continue
        condition = unparen(tokens, pairs, args[1])
        lo, hi = condition
        if not (hi > lo+2 and tokens[lo].text == 'Bool.not' and tokens[lo+1].text == '(' and pairs[lo+1] == hi-1):
            continue
        negated = arguments(tokens, pairs, lo+1)
        if negated is None or len(negated) != 1:
            continue
        d = bisect.bisect_right(declared, token.begin)-1
        assert d >= 0
        dstart, dend, row = declarations[d]
        record = {'owner': row['name'], 'line': text.count('\n',0,token.begin)+1, 'chooser': token.text,
                  'begin': token.begin, 'end': tokens[pairs[i+1]].end}
        reason = None
        if row['kind'] != 'def':
            reason = 'not-a-definition'
        elif row['name'] in protected:
            reason = 'protected-or-proof-root'
        elif row['name'] in laws:
            reason = 'has-attached-law'
        elif hot_only and row['name'] != 'p131i_insert':
            reason = 'outside-explicit-hot-owner'
        elif not all(is_lambda(tokens,pairs,args[j]) for j in (2,3)):
            reason = 'nonliteral-lambda-arm'
        elif any(tokens[j].kind == 'name' and tokens[j].text in ('match', 'do')
                 for a,b in args[2:] for j in range(a,b)):
            reason = 'indentation-sensitive-block-in-lambda'
        else:
            # A local binder with the callee name has an occurrence outside call
            # position. Refuse the entire owner instead of guessing resolution.
            a,b = bisect.bisect_left(starts,dstart),bisect.bisect_left(starts,dend)
            if any(tokens[j].text == token.text and (j+1 == b or tokens[j+1].text != '(')
                   for j in range(a,b)):
                reason = 'possible-local-shadowing'
        if reason:
            rejected.append(dict(record,reason=reason))
        else:
            candidates.append(dict(record,args=[values(tokens,a) for a in args],inner=values(tokens,negated[0])))
    by_begin = {c['begin']:c for c in candidates}
    assert len(by_begin) == len(candidates)
    positions = sorted(by_begin)

    def render(lo,hi):
        chunks=[];cursor=lo
        index=bisect.bisect_left(positions,lo)
        while index < len(positions) and positions[index] < hi:
            c=by_begin[positions[index]]
            assert c['end'] <= hi, 'crossing call intervals'
            chunks.append(text[cursor:c['begin']]);chunks.append(call(c));cursor=c['end']
            index=bisect.bisect_left(positions,cursor)
        chunks.append(text[cursor:hi]);return ''.join(chunks)

    def call(c):
        args=c['args'];changes=[(args[1],render(*c['inner'])),
          (args[2],render(*args[3])), (args[3],render(*args[2]))]
        cursor=c['begin'];pieces=[]
        for (start,end),replacement in changes:
            pieces.append(render(cursor,start) if cursor>c['begin'] else text[cursor:start])
            pieces.append(replacement);cursor=end
        pieces.append(text[cursor:c['end']]);return ''.join(pieces)

    result=render(0,len(text))
    # Delimiter/lexical integrity is independent of the future Bend sourcecheck.
    brackets(lex(result))
    return result,candidates,rejected


def selftest():
    text='kc(List<&2,String>, Bool.not(f("comma,(x)", \'(\', T{a, b})), u => yes("#"), v => no())'
    ts=lex(text);ps=brackets(ts);aa=arguments(ts,ps,1)
    assert len(aa)==4 and len(arguments(ts,ps,aa[1][0]+1))==1
    assert all(is_lambda(ts,ps,a) for a in aa[2:])
    text='kc(T, Bool.not(x), construct_thunk(), v => no()) # kc(T,Bool.not(x),u=>x,u=>y)\n'
    ts=lex(text);ps=brackets(ts);aa=arguments(ts,ps,1)
    assert len(aa)==4 and not is_lambda(ts,ps,aa[2])
    assert sum(t.text=='kc' for t in ts)==1


def main():
    selftest()
    ap=argparse.ArgumentParser();ap.add_argument('--manifest',required=True);ap.add_argument('--source-sha256',required=True)
    ap.add_argument('--out',required=True);ap.add_argument('--hot-only',action='store_true');args=ap.parse_args()
    manifest=(ROOT/args.manifest).resolve();parent=json.loads(manifest.read_text());source=Path(parent['source']['file'])
    assert parent['complete'] and pin(source)['sha256']==parent['source']['sha256']==args.source_sha256
    out=(ROOT/args.out).resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase144') and not out.exists()
    spec=importlib.util.spec_from_file_location('census',ROOT/'selfhost/tools/performance/phase141/census/read-onlyinventory.py')
    C=importlib.util.module_from_spec(spec);spec.loader.exec_module(C)
    rows=C.parse(str(source));assert_rules(rows,C)
    protected=set(parent['protectedDeclarations'])|set(parent['unchangedProofDeclarations'])
    text=source.read_text();result,accepted,rejected=transform(text,rows,protected,args.hot_only)
    assert accepted and any(x['owner']=='p131i_insert' for x in accepted)
    out.mkdir(parents=True);target=out/'compiler.bend';target.write_text(result)
    after=C.parse(str(target));assert [(r['name'],r['kind']) for r in rows]==[(r['name'],r['kind']) for r in after]
    changes=[]
    for a,b in zip(rows,after):
        if a['raw']!=b['raw']:
            assert a['kind']=='def' and a['name'] not in protected
            changes.append({'name':a['name'],'before':sha(a['raw'].encode()),'after':sha(b['raw'].encode())})
    assert set(x['name'] for x in changes)==set(x['owner'] for x in accepted)
    report={'kind':'phase144-lexical-predicate-canonicalization','complete':True,'checked':False,'nativeQualified':False,'selected':False,
      'source':pin(target),'parentManifest':pin(manifest),'parent':pin(source),'method':pin(__file__),
      'inputs':[pin(BASE),pin(HERE/'laws/production-v01.bend'),pin(HERE/'laws/source-bridge-v01.json'),pin(C.__file__)],
      'protectedDeclarations':parent['protectedDeclarations'],'unchangedProofDeclarations':parent['unchangedProofDeclarations'],
      'declarationsUnchangedInNumberAndOrder':True,'changes':changes,'accepted':accepted,'rejected':rejected,
      'sourceOnlyChecks':['lexical delimiters and quoted/comment commas','nonlambda arm refusal','exact chooser/Bool.not bodies',
       'full declaration order and law/proof/protected bytes','only selected definition bodies changed'],
      'scope':'Unselected source candidate. Literal lambda arms only, predicate evaluated once, exact imported Bool.not and chooser bodies. No compiler target or codegen claim. Whole-program sourcecheck and exact independent outputs remain required.'}
    (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({'complete':True,'targetsRun':False,'accepted':len(accepted),'owners':len(changes),'rejected':len(rejected),'source':pin(target)}))


if __name__=='__main__':main()
