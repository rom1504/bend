#!/usr/bin/env python3
"""Lexical declaration/delimiter preflight; no compiler or target execution."""
from pathlib import Path
import json
import re
ROOT=Path(__file__).resolve().parent
rows=[]; issues=[]
for name in ['layout.bend','proof.bend','evaluator.bend','bst-fixture.bend']:
    text=(ROOT/name).read_text()
    starts=list(re.finditer(r'(?m)^(def|law|type) ([A-Za-z_][\w.]*)',text))
    for i,m in enumerate(starts):
        block=text[m.start():starts[i+1].start() if i+1<len(starts) else len(text)]
        clean=re.sub(r'"(?:\\.|[^"\\])*"|#[^\n]*','',block)
        stack=[]; errors=[]
        for ch in clean:
            if ch in '([{':stack.append(ch)
            elif ch in ')]}':
                if not stack or stack.pop()!={')':'(',']':'[','}':'{'}[ch]:errors.append('mismatched '+ch)
        if stack:errors.append('unclosed '+''.join(stack))
        header=block.splitlines()[0]
        if m[1] in ['def','law'] and not header.endswith(':'):errors.append('missing header colon')
        if m[1]=='law':
            body=block.splitlines()[1:]
            for line in body:
                if line.lstrip().startswith('for ') and ':' not in line: errors.append('untyped law binder')
        row=dict(file=name,line=text.count('\n',0,m.start())+1,kind=m[1],name=m[2],errors=errors)
        rows.append(row)
        if errors:issues.append(row)
    for a in re.finditer(r'(?m)^@unsafe\s*\n',text):
        tail=text[a.end():].lstrip()
        if not tail.startswith('def '):issues.append(dict(file=name,error='unsafe not followed by def'))
report=dict(kind='phase195-static-syntax-audit',compilerExecuted=False,
    scope='Lexical balanced delimiters, declaration/law headers and annotation adjacency. Not a language parser or source-check certificate.',
    declarations=len(rows),issues=issues,rows=rows)
(ROOT/'syntax-audit.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({k:v for k,v in report.items() if k!='rows'}));assert not issues
