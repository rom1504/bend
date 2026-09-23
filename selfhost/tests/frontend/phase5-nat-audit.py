from pathlib import Path
import json,hashlib,sys
root=Path(sys.argv[1]).resolve();out=Path(sys.argv[2]).resolve();assert not out.exists()
def read(p):return json.loads(p.read_text())
def id(p):return {'file':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
rels={'before':'before/paired.json','focused':'candidate-v3/validation-001/selected/paired.json','executionBefore':'before-execution-v2/paired.json','execution':'execution-v3/selected/paired.json','boundaries':'boundaries-v3/selected/paired.json','boundariesBefore':'before-boundaries/paired.json','orderBefore':'before-error-order/paired.json','orderV2':'error-order-v2/selected/paired.json','rawBaseline':'raw-baseline-v3.json','rawV1':'raw-v1-v3.json'};paths={k:root/v for k,v in rels.items()};x={k:read(v)for k,v in paths.items()}
assert x['focused']['selectedComplete'] and len(x['focused']['rows'])==19
assert all(r['semanticAgreement']and r['candidateVerdict']=='pass'and r['referenceVerdict']=='pass'for r in x['focused']['rows'])
assert x['execution']['selectedComplete'] and len(x['execution']['rows'])==14 and all(r['exactAgreement']and r['candidate']['status']=='ok'for r in x['execution']['rows'])
wrong=[r for r in x['executionBefore']['rows']if not r['exactAgreement']];assert len(wrong)==2
for r in wrong:assert r['id'].endswith('/execute-multiply-prefix') and r['reference']['output'].strip()=='8' and r['candidate']['output'].strip()=='5'
fixed=[];after={r['id']:r for r in x['focused']['rows']}
for r in x['before']['rows']:
 if r['reference']['status']=='error'and r['candidate']['status']=='ok':assert after[r['id']]['candidate']['phase']=='parse';fixed.append(r['id'])
assert len(fixed)==6
bs={r['id'].split('/')[-1]:r for r in x['boundaries']['rows']};assert len(bs)==7
assert all(r['candidateVerdict']=='pass'and r['referenceVerdict']=='pass'for n,r in bs.items()if n!='semicolon-after-prefix')
assert bs['semicolon-after-prefix']['candidate']['status']=='ok' and bs['semicolon-after-prefix']['reference']['phase']=='parse'
old=next(r for r in x['boundariesBefore']['rows']if r['id'].endswith('/semicolon-after-prefix'));assert old['candidate']['status']=='ok'
def row(report,name):return next(r for r in report['rows']if r['id'].endswith('/'+name))
before=row(x['orderBefore'],'overflow-before-rhs-error')['candidate']['diagnostic'];v2=row(x['orderV2'],'overflow-before-rhs-error')['candidate']['diagnostic'];v3=bs['overflow-before-rhs-error']['candidate']['diagnostic'];assert 'numeric literal'in before and 'lambda binder'in v2 and v3==before
assert bs['malformed-before-rhs-error']['candidate']['diagnostic']==row(x['orderBefore'],'malformed-before-rhs-error')['candidate']['diagnostic']
for key,n in [('rawBaseline',14),('rawV1',11)]:assert x[key]['complete']and len(x[key]['rows'])==n and all(r['exact']for r in x[key]['rows'])
p=root/'candidate-v3/api.mjs.bootstrap.json';proof=read(p);assert proof['stage']=='upstream-bootstrap'and proof['provenance']['verifiedAfterBuild'];assert id(Path(proof['apiPath']))['sha256']==proof['apiSha256'];assert id(Path(proof['source']))['sha256']==proof['sourceSha256']
for i in proof['provenance']['inputs']:assert id(Path(i['file']))['sha256']==i['sha256']
r={'kind':'phase5-nat-prefix-selected-audit','complete':True,'scope':'25 acceptance/phase checks,14 exact executions,14 unchanged baseline raw graphs and11 v1-v3 raw graphs; no full-conformance claim','inputs':{k:id(v)for k,v in paths.items()},'bootstrap':id(p),'api':id(Path(proof['apiPath'])),'source':id(Path(proof['source'])),'fixedInvalidAcceptances':fixed,'wrongResult':{'source':'(2n * 1n+3n : Nat)','reference':8,'baseline':5,'candidateV3':8,'lanes':['interpreter','js']},'firstErrorRegression':{'v2':'RHS lambda error masks overflowing literal','v3':'restores original numeric-literal error before RHS','preserved':True},'residuals':['1n+;2n remains invalid acceptance due generic semicolon skipping','Malformed float-n suffix diagnostics/first-rule mismatch remains unchanged from baseline'],'exactFocusedDiagnosticDifferences':sum(not r['exactAgreement']for r in x['focused']['rows']),'retainedSetupFailure':'Initial before-execution used persistent mode unsupported for execution lanes. Corrected separate isolated config/run; no overwritten rows.','baselineScope':'Integration03 genuine checked build, not a claim its combined selected gate passed (273/274 at experiment start).','auditor':id(Path(__file__).resolve())};out.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({'complete':True,'checks':25,'executions':14,'fixedInvalidAcceptances':6,'wrongResultRepaired':True}))
