#!/usr/bin/env python3
"""File-only audit of the bounded erased-name experiment; runs no compiler."""
import hashlib, json, sys
from pathlib import Path
root=Path(__file__).resolve().parents[2]
base=root/'selfhost/build/phase6/erased-name'
read=lambda p:json.loads(p.read_text())
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
key=lambda r:r['id']+'::'+r['lane']
old=read(base/'baseline-v2/paired.json')
new=read(base/'validation-02/selected/paired.json')
first=read(base/'attempt-01/validation-001/selected/paired.json')
# Paired target.complete requires exact agreement; selectedComplete records
# declared oracles. Verify completed coverage separately, retaining residuals.
for report in [old,new,first]:
 assert report.get('finished') and not report.get('missing') and len(report['rows'])==28
 for attempt in report['attempts'].values():
  assert attempt['exitCode'] in [0,1] and not attempt.get('error') and not attempt.get('signal')
  raw=read(Path(attempt['file']))
  assert len(raw['results'])==28 and not raw['changedInputs']
  assert all(r['result']['status'] in ['ok','error'] for r in raw['results'])
assert new['selectedComplete'] and not first['selectedComplete']
a={key(r):r for r in old['rows']};b={key(r):r for r in new['rows']}
assert len(a)==len(b)==28 and a.keys()==b.keys()
assert all(a[k]['reference']==b[k]['reference'] for k in a)
assert all(r['semanticAgreement'] for r in b.values())
assert all(b[k]['exactAgreement'] for k in a if a[k]['exactAgreement'])
assert all(b['parse/prefix_operator_dead.bend::'+lane]['exactAgreement'] for lane in ['parse','check'])
api=base/'attempt-01/api.mjs';proof=read(base/'attempt-01/api.mjs.bootstrap.json')
assert proof['stage']=='upstream-bootstrap' and proof['apiSha256']==sha(api)
assert proof['provenance']['verifiedAfterBuild'] and proof['provenance']['upstream']['trackedSourcesClean']
source=Path(proof['source']);assert sha(source)==proof['sourceSha256']
assert len(proof['modules'])==59
for m in proof['modules']:assert sha(source.parent/m['file'])==m['sha256']
prep=read(base/'preparation.json')
assert sha(Path(prep['productionSugar']['path']))==prep['productionSugar']['sha256']
changed=[]
original=root/'selfhost/build/phase5/integration/attempt-05/snapshot/src'
for m in proof['modules']:
 rel=Path(m['file']).relative_to('src')
 if sha(original/rel)!=m['sha256']:changed.append(str(rel))
assert changed==['front/sugar.bend'],changed
reports=[base/'attempt-01/build.json',base/'attempt-01/api.mjs.bootstrap.json',base/'attempt-01/validation-001/report.json',base/'attempt-01/validation-001/selected/paired.json',base/'validation-02/report.json',base/'validation-02/selected/paired.json',base/'baseline-v2/paired.json',base/'preparation.json']
out={'kind':'phase6-erased-name-file-audit','complete':True,'scope':'isolated checked B1, selected parser/checker evidence only; no promotion or timing claim','apiSha256':sha(api),'sourceSha256':sha(source),'changedModules':changed,'productionSugarUnchanged':True,'rows':28,'baselineSemanticAgreement':sum(r['semanticAgreement'] for r in a.values()),'candidateSemanticAgreement':28,'baselineExactAgreement':sum(r['exactAgreement'] for r in a.values()),'candidateExactAgreement':sum(r['exactAgreement'] for r in b.values()),'newExact':[k for k in a if not a[k]['exactAgreement'] and b[k]['exactAgreement']],'lostExact':[],'changedResidual':[k for k in a if a[k]['candidate']!=b[k]['candidate'] and not b[k]['exactAgreement']],'residual':[k for k in b if not b[k]['exactAgreement']],'referenceUnchanged':True,'firstIncorrectFixtureGateRetained':True,'reports':[{'file':str(p.relative_to(root)),'sha256':sha(p)} for p in reports],'observations':[{'key':k,'before':a[k]['candidate'],'after':b[k]['candidate'],'reference':b[k]['reference']} for k in a]}
Path(sys.argv[1]).write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps({k:v for k,v in out.items() if k not in ['reports','observations']},indent=2))
