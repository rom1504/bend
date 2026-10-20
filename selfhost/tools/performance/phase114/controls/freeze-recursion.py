#!/usr/bin/env python3
"""Add ordinary recursive fixtures without changing the prior frozen manifest."""
from pathlib import Path
import datetime,hashlib,json
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
def pin(p):
 p=Path(p);b=p.read_bytes();return dict(file=str(p.relative_to(ROOT)),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
prior=HERE/'manifest02.json';obj=json.loads(prior.read_text())
new={
 'append-owned-suffix':('\nliteralλsuffix🙂\nαβ🙂\nα\nβ🙂\nβ🙂\nα\nαβ🙂\n262\nliatλ🙂\n',['String.append empty/literal/allocated roots','shared suffix and retained aliases','257-codepoint prefix','Unicode reversal']),
 'recursive-fallback-shapes':('11\nα:β🙂:end\n1\n0\n',['two recursive children','recursive first constructor field','post-call selector','ordinary fallback semantics']),
}
for name,(stdout,purposes) in new.items():
 source=HERE/'fixtures'/f'{name}.bend';expected=HERE/'expected'/f'{name}.json';out=HERE/'expected'/f'{name}.stdout'
 expected.write_text(json.dumps(dict(status=0,stdout=stdout,stderr=''),ensure_ascii=False,indent=2)+'\n');out.write_text(stdout)
 c=dict(name=name,source=str(source.relative_to(ROOT)),sourcePin=pin(source),expected=pin(expected),stdout=pin(out),purposes=purposes,provenance='new ordinary source; root frontend preflight required')
 obj['cases'].append(c);obj['inputs'].extend([c['sourcePin'],c['expected'],c['stdout']])
obj.update(version=3,frozenUtc=datetime.datetime.now(datetime.timezone.utc).isoformat(),prior=pin(prior),recursiveOrder=['append-owned-suffix','non-tail-reconstruction','recursive-fallback-shapes','nested-owned-fields'])
obj['inputs'].extend([pin(prior),pin(Path(__file__))]);(HERE/'manifest03.json').write_text(json.dumps(obj,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(dict(manifest=pin(HERE/'manifest03.json'),cases=len(obj['cases']),targetsRun=False)))
