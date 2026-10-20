#!/usr/bin/env python3
"""Freeze ordinary recursion-table controls and independent literal outputs."""
from pathlib import Path
import datetime,hashlib,json
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[5]
def pin(path):
    data=path.read_bytes()
    return dict(file=str(path.relative_to(ROOT)),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
CASES={
    'expression-two-children':('0\n63\n58\n36\n192\n192\n',['three binary operations with nested two-child recursion','same owner resumed then descended again','ordered subtraction and multiplication','shared tree, depth at most six']),
    'owned-scan-caller':('empty[.#0]empty\nouter[λ#1]outer\npre[(α,(.,β🙂))#2]pre\nkeyλ[(left,β🙂)#2]keyλ\nkeyλ\n(left,β🙂)\nkeyλ[(left,β🙂)#2]keyλ\ndepth:64\nempty-result\n',['owning first-child result survives second recursive descent','rebuilt owned Tree plus scalar count','owned caller String retained outside recursive region','shared external tree and label aliases','empty/nested/Unicode/depth-six observations']),
}
assert (7+5)*(9-3)-(4*3+2)==58
assert 3*(4+5)+(21-2*6)==36
assert (2**6)*3==192
assert 2**6==64
rows=[];inputs=[pin(Path(__file__))]
for name,(stdout,purposes) in CASES.items():
    source=HERE/'fixtures'/f'{name}.bend'
    expected=HERE/'expected'/f'{name}.json'
    literal=HERE/'expected'/f'{name}.stdout'
    expected.write_text(json.dumps(dict(status=0,stdout=stdout,stderr=''),ensure_ascii=False,indent=2)+'\n')
    literal.write_text(stdout)
    observed_comments=''.join(line[2:]+'\n' for line in source.read_text().splitlines() if line.startswith('#|'))
    assert observed_comments==stdout
    row=dict(name=name,source=str(source.relative_to(ROOT)),sourcePin=pin(source),expected=pin(expected),stdout=pin(literal),purposes=purposes,sourceChecked=False)
    rows.append(row);inputs.extend([row['sourcePin'],row['expected'],row['stdout']])
manifest=dict(kind='phase114-ordinary-recursive-table-controls',version=1,targetsRun=False,frozenUtc=datetime.datetime.now(datetime.timezone.utc).isoformat(),cases=rows,fastOrder=list(CASES),inputs=inputs,scope='Ordinary positive source controls only; independent complete expected stdout. Finite maximum constructed depth six, no stress or custom failure cases. Source checks, continuation count/admission and native complete-output comparison remain separate root-run gates.')
output=HERE/'manifest01.json'
if output.exists():raise SystemExit('Manifest already frozen')
output.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(dict(manifest=pin(output),cases=len(rows),targetsRun=False)))
