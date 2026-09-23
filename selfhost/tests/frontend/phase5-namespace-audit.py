from pathlib import Path
import hashlib,json,sys
root=Path(sys.argv[1]).resolve();out=Path(sys.argv[2]).resolve();assert not out.exists()
def read(p):return json.loads(p.read_text())
def id(p):return {'file':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
paths={k:root/v for k,v in {'before':'before/paired.json','focused':'focused-v1/selected/paired.json','execution':'execution-v1/selected/paired.json','order':'error-order-v1/selected/paired.json','raw':'raw-v1.json','nested':'raw-error-order-v2.json','residual':'residual-v1/selected/paired.json'}.items()}
x={k:read(v)for k,v in paths.items()}
for key,n in [('focused',15),('execution',14),('order',1)]:
 assert x[key]['selectedComplete'] and len(x[key]['rows'])==n
 assert all(r['referenceVerdict']=='pass' and r['candidateVerdict']=='pass' and r['semanticAgreement']for r in x[key]['rows'])
assert all(r['exactAgreement']for r in x['execution']['rows'])
assert x['raw']['complete'] and len(x['raw']['rows'])==9 and x['nested']['complete'] and len(x['nested']['rows'])==1
now={r['id']:r for r in x['focused']['rows']};fixed=[]
for row in x['before']['rows']:
 if row['reference']['status']=='error' and row['reference']['phase']=='parse' and row['candidate']['status']=='ok':
  a=now[row['id']];assert a['candidate']['status']=='error' and a['candidate']['phase']=='parse';fixed.append(row['id'])
assert len(fixed)==6
res={r['id'].split('/')[-1]:r for r in x['residual']['rows']};assert not res['operator-invalid-namespace']['semanticAgreement'];assert res['literal-nonname-namespace']['semanticAgreement'];assert res['operator-invalid-namespace-wrong-close']['semanticAgreement'] and not res['operator-invalid-namespace-wrong-close']['exactAgreement']
p=root/'candidate-v1/api.mjs.bootstrap.json';proof=read(p);assert proof['stage']=='upstream-bootstrap' and proof['provenance']['verifiedAfterBuild'];assert id(Path(proof['apiPath']))['sha256']==proof['apiSha256'];assert id(Path(proof['source']))['sha256']==proof['sourceSha256']
for i in proof['provenance']['inputs']:assert id(Path(i['file']))['sha256']==i['sha256']
r={'kind':'phase5-namespace-selected-audit','complete':True,'scope':'16 selected acceptance/phase checks,14 exact executions,7 accepted raw graphs and3 earlier-error controls; not full conformance','inputs':{k:id(v)for k,v in paths.items()},'bootstrap':id(p),'api':id(Path(proof['apiPath'])),'source':id(Path(proof['source'])),'fixedInvalidAcceptances':fixed,'exactFocusedDiagnosticDifferences':sum(not r['exactAgreement']for r in x['focused']['rows']),'residual':'Operator namespace head validity is separate; wrong-close case agrees only on parse phase, not first intended rule. Literal non-name namespace remains accepted.','retainedFailedAttempts':['Initial local-body positive lacked an annotation and failed both compilers. Separate corrected fixture used.','Original nested raw audit incorrectly required a nonempty top-level error field; exact nested Error lives in book, verified by separate v2 helper.'],'auditor':id(Path(__file__).resolve())};out.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({'complete':True,'fixedInvalidAcceptances':len(fixed),'selectedChecks':16,'executions':14}))
