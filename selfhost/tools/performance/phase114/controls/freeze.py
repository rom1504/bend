#!/usr/bin/env python3
"""Freeze ordinary source/output controls. Does not execute compiler targets."""
from pathlib import Path
import datetime,hashlib,json
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
def pin(p):
 p=Path(p);b=p.read_bytes();return dict(file=str(p.relative_to(ROOT)),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
rows=[]
# Expectations are independent literals, not harvested from compiler outputs.
new={
 'two-owned-fields':('staticλ/root🙂\nleft/right\nα/β🙂\nβ🙂/α\nα\nβ🙂\ntwo/one\nempty\nlive\n',['unique/shared owning fields','literal roots','partial selection/drop','field order','257-step reconstruction']),
 'nested-owned-fields':('static[one:two:]\nindexλ[α:β🙂:]\nα:β🙂:\nindexλ\nindexλ[α:β🙂:]\nempty[]\nnone\n',['nested String/List owners','shared parent','partial selection/drop','empty and nonempty recursion']),
 'same-names-other-layout':('right/middleλ/left!\nempty?\n',['independent valid request','same names with changed constructor arity','same function name with changed call arity']),
}
for name,(stdout,purposes) in new.items():
 expected=HERE/'expected'/f'{name}.json';out=HERE/'expected'/f'{name}.stdout'
 expected.write_text(json.dumps(dict(status=0,stdout=stdout,stderr=''),ensure_ascii=False,indent=2)+'\n');out.write_text(stdout)
 source=HERE/'fixtures'/f'{name}.bend'
 rows.append(dict(name=name,source=str(source.relative_to(ROOT)),sourcePin=pin(source),expected=pin(expected),stdout=pin(out),purposes=purposes,provenance='new ordinary source; root frontend preflight required before backend qualification'))
prior=ROOT/'selfhost/tools/performance/phase113/controls'
manifest=json.loads((prior/'manifest01.json').read_text())
for name in ['string-field-alias','owned-capture-call','product-escape-branch','non-tail-reconstruction','tail-argument-permutation','scalar-closed-loop']:
 c=next(c for c in manifest['fixtures'] if c['name']==name)
 for key in ['source','expected','stdout']:
  p=ROOT/c[key]['file'];assert pin(p)==c[key]
 rows.append(dict(name=name,source=c['source']['file'],sourcePin=c['source'],expected=c['expected'],stdout=c['stdout'],purposes=[c['purpose']],provenance='unchanged Phase113 ordinary positive fixture; prior qualification remains separate'))
inputs=[pin(Path(__file__)),pin(prior/'manifest01.json')]
for c in rows:inputs.extend([c['sourcePin'],c['expected'],c['stdout']])
result=dict(kind='phase114-ordinary-functional-controls',version=1,frozenUtc=datetime.datetime.now(datetime.timezone.utc).isoformat(),targetsRun=False,cases=rows,inputs=inputs,
 fastOrder=['two-owned-fields','nested-owned-fields','same-names-other-layout','string-field-alias','non-tail-reconstruction'],
 sessionSequence=['two-owned-fields','same-names-other-layout','two-owned-fields','nested-owned-fields','two-owned-fields'],
 scope='Positive complete-output Bend programs only. New sources require frontend preflight. Physical unique/shared/static fastpath admission must be observed separately; correct fallback is valid. No malformed memory or ABI probes.')
(HERE/'manifest01.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(dict(manifest=pin(HERE/'manifest01.json'),cases=len(rows),targetsRun=False)))
