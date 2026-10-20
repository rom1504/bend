#!/usr/bin/env python3
"""Freeze four ordinary positive sources and independent literal stdout."""
from pathlib import Path
import datetime,hashlib,json
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[5]
def pin(p):
 p=Path(p);b=p.read_bytes();return dict(file=str(p.relative_to(ROOT)),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
expected={
 'unary-scalars':('0\n0\n1\n1\n2147483647\n2147483647\n2147483648\n2147483648\n4294967295\n4294967295\n11\n29\n955\n128578\n1.5\n-2.5\n',['U32 zero/one/signed-boundary/max','unsigned identities','two constructor identities','Char and F32 fields']),
 'unary-nat-boundaries':('0\n1099511627775\n1099511627776\n281474976710655\n1099511627775\n1099511627775\n1099511627776\n1099511627776\n',['exact low40 boundary','larger Nat heap fallback','shared duplicate extraction','runtime scalar arithmetic']),
 'unary-owned-strings':('\nliteralλ\nβ🙂\nβ🙂\nβ🙂\nβ🙂\nλtfel\nright\n',['empty/literal/allocated owning String child','two nested unary constructor identities','retained outside alias','repeated shared extraction and release']),
 'unary-nested-tree-list':('0\n202\n108\n13184\n13184\n',['unary leaves nested in List and binary tree','constructor-sensitive numeric results','U32 wrap','shared recursively built tree']),
}
rows=[];inputs=[pin(Path(__file__))]
for name,(stdout,purposes) in expected.items():
 source=HERE/'fixtures'/f'{name}.bend';expect=HERE/'expected'/f'{name}.json';out=HERE/'expected'/f'{name}.stdout'
 expect.write_text(json.dumps(dict(status=0,stdout=stdout,stderr=''),ensure_ascii=False,indent=2)+'\n');out.write_text(stdout)
 row=dict(name=name,source=str(source.relative_to(ROOT)),sourcePin=pin(source),expected=pin(expect),stdout=pin(out),purposes=purposes,sourceChecked=False)
 rows.append(row);inputs.extend([row['sourcePin'],row['expected'],row['stdout']])
prior=[ROOT/'implementation/phase68/constructor-packing.md',ROOT/'implementation/phase68/evidence/packing14-focused-controls.json',ROOT/'selfhost/tools/performance/phase68/constructor-packing/controls-v1/raw-controls-v2.mjs']
manifest=dict(kind='phase114-ordinary-unary-packing-controls',version=1,targetsRun=False,frozenUtc=datetime.datetime.now(datetime.timezone.utc).isoformat(),cases=rows,fastOrder=list(expected),inputs=inputs,priorResearch=[pin(p) for p in prior],scope='Four ordinary positive Bend sources with independently literal complete stdout. Root must frontend-check before backend qualification. Based on Phase68 payload boundaries and alias questions; no raw-core/C instrumentation or old failure probes reused. Correct output alone does not prove packed representation or measured gain.')
(HERE/'manifest01.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(dict(manifest=pin(HERE/'manifest01.json'),cases=len(rows),targetsRun=False)))
