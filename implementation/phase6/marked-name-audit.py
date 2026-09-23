#!/usr/bin/env python3
"""Read-only compiler evidence audit; no compiler or oracle execution."""
import hashlib,json,sys
from pathlib import Path
root=Path(__file__).resolve().parents[2]
base=root/'selfhost/build/phase6/marked-name'
read=lambda p:json.loads(p.read_text())
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
key=lambda r:r['id']+'::'+r['lane']
paths=['baseline/paired.json','attempt-01/validation-001/selected/paired.json','call-baseline/paired.json','call-gate/selected/paired.json']
reports=[read(base/p) for p in paths]
for report,n in zip(reports,[19,19,3,3]):
 assert report.get('finished') and not report.get('missing') and len(report['rows'])==n
 for attempt in report['attempts'].values():
  assert attempt['exitCode'] in [0,1] and not attempt.get('error') and not attempt.get('signal')
  raw=read(Path(attempt['file']))
  assert len(raw['results'])==n and not raw['changedInputs']
  assert not raw['identity']['adapterChangedDuringRun'] and not raw['identity']['changedArtifacts']
  assert all(r['result']['status'] in ['ok','error'] for r in raw['results'])
a,b,c,d=[{key(r):r for r in x['rows']} for x in reports]
assert a.keys()==b.keys() and c.keys()==d.keys()
assert all(a[k]['reference']==b[k]['reference'] for k in a)
assert all(c[k]['reference']==d[k]['reference'] for k in c)
assert c['phase6-plus-call/direct::check']['semanticAgreement']
assert not d['phase6-plus-call/direct::check']['semanticAgreement']
assert c['phase6-plus-call/direct::check']['candidate']['phase']=='parse'
assert d['phase6-plus-call/direct::check']['candidate']['phase']=='check'
for lane in ['parse','check']:
 for fixture in ['comptime/err_plus_term.bend','parse/plus_binder_term.bend']:
  assert b[fixture+'::'+lane]['semanticAgreement']
quant=[k for k in a if 'no-quant-datatype' in k]
assert len(quant)==1 and a[quant[0]]['candidate']==b[quant[0]]['candidate']
assert b[quant[0]]['candidate']['status']=='ok' and b[quant[0]]['reference']['status']=='error'
proof=read(base/'attempt-01/api.mjs.bootstrap.json');source=Path(proof['source'])
assert proof['stage']=='upstream-bootstrap' and proof['apiSha256']==sha(base/'attempt-01/api.mjs')
assert proof['provenance']['verifiedAfterBuild'] and proof['provenance']['upstream']['trackedSourcesClean']
assert sha(source)==proof['sourceSha256'] and len(proof['modules'])==59
original=root/'selfhost/build/phase5/integration/attempt-05/snapshot/src'
changed=[]
for m in proof['modules']:
 assert sha(source.parent/m['file'])==m['sha256']
 rel=Path(m['file']).relative_to('src')
 if sha(original/rel)!=m['sha256']:changed.append(str(rel))
assert set(changed)=={'front/families.bend','front/fresh_work.bend'}
prep=read(base/'preparation.json')
for f in prep['files']:
 if '/selfhost/src/' in f['file']:assert sha(Path(f['file']))==f['sha256']
fresh=read(base/'freshness-01/report.json');assert fresh['complete'] and len(fresh['cases'])==10
for p,h in fresh['inputs'].items():assert sha(Path(p))==h
out={'kind':'phase6-marked-name-evidence-audit','complete':True,'decision':'rejected-for-promotion: introduced direct-call parse/check phase regression','apiSha256':proof['apiSha256'],'sourceSha256':proof['sourceSha256'],'changedModules':changed,'productionUnchanged':True,'selected':{'rows':19,'baselineSemantic':sum(r['semanticAgreement'] for r in a.values()),'candidateSemantic':sum(r['semanticAgreement'] for r in b.values()),'baselineExact':sum(r['exactAgreement'] for r in a.values()),'candidateExact':sum(r['exactAgreement'] for r in b.values()),'newExact':[k for k in a if not a[k]['exactAgreement'] and b[k]['exactAgreement']],'lostExact':[k for k in a if a[k]['exactAgreement'] and not b[k]['exactAgreement']]},'callFalsifier':{'rows':3,'baselineSemantic':sum(r['semanticAgreement'] for r in c.values()),'candidateSemantic':sum(r['semanticAgreement'] for r in d.values()),'introducedPhaseMismatch':'phase6-plus-call/direct::check','incorrectOriginalOracleRetained':'phase6-plus-call/global: parse expected, but live reference check rejects'},'freshnessControls':10,'referenceObservationsUnchanged':True,'preexistingFalseAcceptance':quant,'reports':[{'file':str((base/p).relative_to(root)),'sha256':sha(base/p)} for p in paths+['freshness-01/report.json','attempt-01/api.mjs.bootstrap.json','preparation.json']],'observations':[{'key':k,'before':old[k]['candidate'],'after':new[k]['candidate'],'reference':new[k]['reference']} for old,new in [(a,b),(c,d)] for k in old]}
Path(sys.argv[1]).write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps({k:v for k,v in out.items() if k not in ['reports','observations']},indent=2))
