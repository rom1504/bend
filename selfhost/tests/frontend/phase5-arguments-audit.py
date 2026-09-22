#!/usr/bin/env python3
"""Audit P5-008's distinct grammar and message-correction artifacts."""
import hashlib,json,pathlib,sys
root=pathlib.Path(sys.argv[1]).resolve();out=pathlib.Path(sys.argv[2]).resolve();assert not out.exists()
def read(p):return json.loads(p.read_text())
def ident(p):return {'file':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
gates={}
for name,relative,count in [('grammar-v2','regression-v2/selected/paired.json',124),('final-v3','candidate-v3/validation-001/selected/paired.json',28),('execution-v3','execution-v3/selected/paired.json',16)]:
 p=root/relative;v=read(p);assert v['selectedComplete'] and not v['missing'] and len(v['rows'])==count
 assert all(r['referenceVerdict']=='pass' and r['candidateVerdict']=='pass' and r['semanticAgreement'] for r in v['rows']);gates[name]=(p,v)
assert all(r['exactAgreement'] and r['candidate']['status']=='ok' and r['reference']['status']=='ok' for r in gates['execution-v3'][1]['rows'])
v2=read(root/'candidate-v2/api.mjs.bootstrap.json');v3=read(root/'candidate-v3/api.mjs.bootstrap.json')
for version,proof in [('v2',v2),('v3',v3)]:
 assert proof['stage']=='upstream-bootstrap' and proof['provenance']['verifiedAfterBuild']
 assert proof['apiSha256']==ident(root/('candidate-'+version)/'api.mjs')['sha256'] and proof['sourceSha256']==ident(pathlib.Path(proof['source']))['sha256']
 for i in proof['provenance']['inputs']:assert ident(pathlib.Path(i['file']))['sha256']==i['sha256'] and str(pathlib.Path(i['file']).resolve())==i['canonicalPath']
mods2={i['file']:i['sha256']for i in v2['modules']};mods3={i['file']:i['sha256']for i in v3['modules']};assert set(mods2)==set(mods3)
assert [k for k in mods2 if mods2[k]!=mods3[k]]==['src/front/parser.bend']
a=(root/'project-v2/src/front/parser.bend').read_bytes();b=(root/'project-v3/src/front/parser.bend').read_bytes();assert a.count(b'argumenspaced')==1 and a.replace(b'argumenspaced',b'arguments')==b
before=read(root/'before/paired.json');after={r['id']:r for r in gates['final-v3'][1]['rows']};fixes=[]
for row in before['rows']:
 if row['referenceVerdict']=='pass' and row['reference']['status']=='error' and row['candidate']['status']=='ok':
  now=after[row['id']];assert now['candidate']['phase']=='parse' and now['candidateVerdict']=='pass'
  if '/family-' in row['id']:assert 'line 0:0: expected term; got <eof>' in now['candidate']['diagnostic']
  else:assert 'arguments do not use semicolon separators' in now['candidate']['diagnostic']
  fixes.append(row['id'])
assert len(fixes)==13
bad=next(r for r in read(root/'candidate-v1/validation-001/selected/paired.json')['rows'] if r['id'].endswith('nested-angle-newline'));assert bad['reference']['status']=='error' and bad['candidate']['status']=='ok'
assert after[bad['id']]['reference']['phase']==after[bad['id']]['candidate']['phase']=='parse'
res=read(root/'residual-v3/selected/paired.json');assert len(res['rows'])==1
assert res['rows'][0]['reference']['phase']=='parse' and res['rows'][0]['candidate']['status']=='ok' and not res['selectedComplete']
report={'kind':'phase5-argument-boundary-selected-audit','complete':True,'scope':'Distinct frozen v2 grammar regression and genuine final v3 message-correction/selected execution gates; residual operator-RHS failure retained; not full conformance or performance','gates':{k:{'report':ident(p),'observations':len(v['rows']),'exactDifferences':sum(not r['exactAgreement']for r in v['rows'])}for k,(p,v)in gates.items()},'fixedInvalidAcceptances':fixes,'specificArgumentDiagnostics':9,'familyDiagnosticsStillGeneric':4,'v1IntroducedOveracceptanceRejected':True,'v2ToV3OnlyDiagnosticTypo':True,'api':ident(root/'candidate-v3/api.mjs'),'bootstrap':ident(root/'candidate-v3/api.mjs.bootstrap.json'),'source':ident(pathlib.Path(v3['source'])),'residual':ident(root/'residual-v3/selected/paired.json'),'auditor':ident(pathlib.Path(__file__).resolve())}
out.write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({'complete':True,'fixedInvalidAcceptances':len(fixes)}))
