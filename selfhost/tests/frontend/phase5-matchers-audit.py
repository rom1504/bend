#!/usr/bin/env python3
"""Keep matcher phase repairs separate from strict diagnostic failures/residuals."""
import pathlib,json,hashlib,sys
root=pathlib.Path(sys.argv[1]).resolve();out=pathlib.Path(sys.argv[2]).resolve();assert not out.exists()
def read(p):return json.loads(p.read_text())
def ident(p):return {'file':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
f=root/'focused-v1/selected/paired.json';e=root/'execution-v1/selected/paired.json';p=root/'pinned-residual-v1/selected/paired.json'
focused=read(f);execution=read(e);mixed=read(p);before=read(root/'before/paired.json')
assert focused['selectedComplete'] and len(focused['rows'])==16 and all(r['referenceVerdict']=='pass' and r['candidateVerdict']=='pass' and r['semanticAgreement'] for r in focused['rows'])
assert execution['selectedComplete'] and len(execution['rows'])==12 and all(r['exactAgreement'] and r['candidate']['status']=='ok' and r['reference']['status']=='ok' for r in execution['rows'])
after={r['id']:r for r in focused['rows']};fixed=[]
for row in before['rows']:
 if row['id'].startswith('phase5-matchers/') and not row['semanticAgreement']:
  now=after[row['id']];assert now['candidate']['phase']=='parse' and 'expected }' in now['candidate']['diagnostic'] and 'got :' in now['candidate']['diagnostic'];fixed.append(row['id'])
assert len(fixed)==6
pinned=[r for r in mixed['rows'] if not r['id'].startswith('phase5-matchers/')];assert len(pinned)==6
assert all(r['semanticAgreement'] and r['reference']['phase']==r['candidate']['phase']=='parse' and r['candidate']['status']=='error' and not r['candidate']['checked'] for r in pinned)
assert sum(r['lane']=='check' and r['candidateVerdict']=='fail' for r in pinned)==3
residual=[r for r in mixed['rows'] if r['id'].startswith('phase5-matchers/')];assert len(residual)==3 and all(not r['semanticAgreement'] and r['candidateVerdict']=='fail' for r in residual)
proofPath=root/'candidate-v1/api.mjs.bootstrap.json';proof=read(proofPath)
assert proof['stage']=='upstream-bootstrap' and proof['provenance']['verifiedAfterBuild']
assert proof['apiSha256']==ident(root/'candidate-v1/api.mjs')['sha256'] and proof['sourceSha256']==ident(pathlib.Path(proof['source']))['sha256']
for i in proof['provenance']['inputs']:assert ident(pathlib.Path(i['file']))['sha256']==i['sha256'] and str(pathlib.Path(i['file']).resolve())==i['canonicalPath']
report={'kind':'phase5-matcher-head-selected-audit','complete':True,'scope':'16 custom acceptance/phase checks and12 exact executions pass; six pinned phases repaired but three strict diagnostic checks still fail; three sibling grammar residuals retained','api':ident(root/'candidate-v1/api.mjs'),'bootstrap':ident(proofPath),'source':ident(pathlib.Path(proof['source'])),'focused':ident(f),'execution':ident(e),'pinnedAndResidual':ident(p),'fixedFreshBaselineCases':fixed,'pinnedPhaseRepairs':6,'pinnedStrictCheckFailures':3,'unfixedSiblingCases':[r['id'] for r in residual],'exactFocusedDiagnosticDifferences':sum(not r['exactAgreement']for r in focused['rows']),'auditor':ident(pathlib.Path(__file__).resolve()),'initialOracleCorrection':'(MatcherOn : MatcherBit) is namespace syntax preserving raw Ref, so it is a valid key; initial negative oracle retained and revised in separate cases-v2.json'}
out.write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({'complete':True,'passingCustomChecks':16,'passingExecutions':12,'pinnedPhaseRepairs':6,'strictPinnedCheckFailures':3,'siblingResiduals':3}))
