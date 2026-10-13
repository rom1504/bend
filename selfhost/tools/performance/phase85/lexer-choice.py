#!/usr/bin/env python3
"""Disposable lexer-only IIFE/ternary diagnostic; never executes compiler code.
Default is an offline preview. --output writes only a new Phase85 build artifact.
The parser accepts sole if/else statements with return-expression leaves and
extra braces. It rejects declarations and any other statements. Exact source
hash guards the input; this is not a production JavaScript transformation.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re

IMAGE_SHA = '098320e8f3e40894156790d740ad205e386f375195b3c6741d67cca96e94e092'
FUNCTION = '$jd$f_95_lex_95_scanned$scc'

def sha(data):
    return hashlib.sha256(data).hexdigest()

def transform(source, lexical):
    match = re.search(r'^function '+re.escape(FUNCTION)+r'\(', source, re.M)
    assert match, 'Missing exact lexer dispatcher'
    start = match.start()
    end = source.index('\nfunction ', start+1)
    text = source[start:end]
    ts = lexical.tokens(text)
    values = [t[0] for t in ts]
    stack, pairs = [], {}
    for i, token in enumerate(values):
        if token in ('(', '[', '{'):
            stack.append(i)
        elif token in (')', ']', '}'):
            j = stack.pop()
            assert values[j]+token in ('()', '[]', '{}')
            pairs[j] = i
    assert not stack
    def raw(lo, hi):
        assert lo < hi
        return text[ts[lo][1]:ts[hi-1][2]]
    def statement(lo, hi):
        # Bounds are half-open; unwrap only blocks containing one statement.
        if lo < hi and values[lo] == '{' and pairs[lo] == hi-1:
            return statement(lo+1, hi-1)
        if lo+2 < hi and values[lo] == 'return' and values[hi-1] == ';':
            if '\n' in text[ts[lo][2]:ts[lo+1][1]]:
                return None  # Preserve automatic-semicolon-insertion semantics.
            j = lo+1
            while j < hi-1:
                if values[j] == ';':
                    return None
                j = pairs[j]+1 if j in pairs else j+1
            return '('+raw(lo+1, hi-1)+')'
        if lo+5 < hi and values[lo:lo+2] == ['if', '(']:
            close = pairs[lo+1]
            yes = close+1
            if values[yes] != '{':
                return None
            split = pairs[yes]+1
            if split+1 >= hi or values[split:split+2] != ['else', '{'] or pairs[split+1] != hi-1:
                return None
            a, b = statement(yes, split), statement(split+1, hi)
            if a is not None and b is not None:
                return '(('+raw(lo+2, close)+')?'+a+':'+b+')'
        return None
    changes, rejected = [], []
    for i in range(len(ts)-8):
        if values[i:i+5] != ['(', '(', ')', '=>', '{']:
            continue
        close = pairs[i+4]
        if values[close+1:close+4] != [')', '(', ')']:
            continue
        value = statement(i+4, close+1)
        lo, hi = ts[i][1], ts[close+3][2]
        item = dict(relativeStart=lo, relativeEnd=hi,
                    sourceLine=source.count('\n',0,start+lo)+1,
                    before=text[lo:hi], after=value)
        (changes if value is not None else rejected).append(item)
    # Do not silently compose overlapping nested transformations.
    changes.sort(key=lambda x:x['relativeStart'])
    assert all(a['relativeEnd'] <= b['relativeStart'] for a,b in zip(changes,changes[1:])), 'Overlapping choices need separate proof'
    result = text
    for change in reversed(changes):
        result = result[:change['relativeStart']]+change['after']+result[change['relativeEnd']:]
    return source[:start]+result+source[end:], dict(function=FUNCTION,
        originalFunctionSha256=sha(text.encode()), candidateFunctionSha256=sha(result.encode()),
        originalFunctionBytes=len(text.encode()), candidateFunctionBytes=len(result.encode()),
        changedCount=len(changes), rejectedCount=len(rejected), changes=changes, rejected=rejected,
        originalFunction=text, candidateFunction=result)

def main():
    root = Path(__file__).resolve().parents[4]
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--input',type=Path,default=root/'selfhost/build/phase82/compiler04-b2/full/compiler.mjs')
    p.add_argument('--output',type=Path)
    p.add_argument('--report',type=Path)
    a = p.parse_args()
    data = a.input.read_bytes()
    assert sha(data) == IMAGE_SHA, 'Source image hash changed'
    helper=root/'selfhost/tools/performance/phase53/generated-shape.py'
    spec=importlib.util.spec_from_file_location('lexical',helper)
    lexical=importlib.util.module_from_spec(spec);spec.loader.exec_module(lexical)
    output,details=transform(data.decode(),lexical)
    report=dict(kind='phase85-disposable-lexer-choice',targetExecution=False,
                input=dict(file=str(a.input.resolve()),sha256=sha(data),bytes=len(data)),
                producerSha256=sha(Path(__file__).read_bytes()),lexicalHelperSha256=sha(helper.read_bytes()),
                candidateSha256=sha(output.encode()),candidateBytes=len(output.encode()),**details)
    for path,content in [(a.output,output),(a.report,json.dumps(report,indent=2)+'\n')]:
        if path:
            path=path.resolve()
            assert path.is_relative_to(root/'selfhost/build/phase85'), 'Only disposable Phase85 build output is allowed'
            assert path != a.input.resolve() and not path.exists(), 'Refuse overwrite'
            path.parent.mkdir(parents=True,exist_ok=True)
            with path.open('x') as f:f.write(content)
    print(json.dumps({k:report[k] for k in ['kind','targetExecution','changedCount','rejectedCount','originalFunctionSha256','candidateFunctionSha256','candidateSha256']}))

if __name__ == '__main__':
    main()
