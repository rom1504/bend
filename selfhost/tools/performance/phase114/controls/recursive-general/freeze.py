#!/usr/bin/env python3
"""Freeze two ordinary recursive-continuation controls; no compiler execution."""
from pathlib import Path
import datetime, hashlib, json
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[5]
def pin(p):
    b=p.read_bytes()
    return dict(file=str(p.relative_to(ROOT)),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
cases={
    'zero-capture-length': ('0\n1\n4\n4\n257\n', ['zero captured fields across post-recursive increment', 'empty/singleton/deep ordinary list', 'shared list and allocated String heads']),
    'multiple-owned-captures': ('\nA|B|A|\nY|\nα|β🙂|α|α|tail|\nα\nβ🙂\nα|β🙂|α|α|tail|\nα/β🙂:3>1;β🙂/α:1>2;end/tail:0>0;\n', ['two owned and two scalar fields across recursion', 'post-recursive predicate and conditional reconstruction', 'duplicated selected field and discarded unselected field', 'external aliases survive repeated traversal', 'unsigned scalar limits and Unicode']),
}
rows=[];inputs=[pin(Path(__file__))]
for name,(stdout,purposes) in cases.items():
    source=HERE/'fixtures'/f'{name}.bend'
    expected=HERE/'expected'/f'{name}.json'
    literal=HERE/'expected'/f'{name}.stdout'
    expected.write_text(json.dumps(dict(status=0,stdout=stdout,stderr=''),ensure_ascii=False,indent=2)+'\n')
    literal.write_text(stdout)
    row=dict(name=name,source=str(source.relative_to(ROOT)),sourcePin=pin(source),expected=pin(expected),stdout=pin(literal),purposes=purposes,sourceChecked=False)
    rows.append(row);inputs.extend([row['sourcePin'],row['expected'],row['stdout']])
manifest=dict(kind='phase114-ordinary-general-recursive-controls',version=1,targetsRun=False,frozenUtc=datetime.datetime.now(datetime.timezone.utc).isoformat(),cases=rows,fastOrder=list(cases),inputs=inputs,scope='Two ordinary positive source controls. Exact independent stdout checks finite semantics and aliases; separate checked lowering inspection must establish actual capture count and general-spine admission. Root must source-check then compare baseline/candidate native outputs. No raw ABI, malformed-memory or custom failure experiment.')
path=HERE/'manifest01.json'
if path.exists(): raise SystemExit('Manifest already frozen')
path.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(dict(manifest=pin(path),cases=len(cases),targetsRun=False)))
