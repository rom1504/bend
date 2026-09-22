#!/usr/bin/env python3
"""Audit the completed P5-006 selected gates; never invoke a compiler."""
import hashlib,json,pathlib,sys
root=pathlib.Path(sys.argv[1]).resolve();out=pathlib.Path(sys.argv[2]).resolve()
assert not out.exists()
def read(p):return json.loads(p.read_text())
def identity(p):return {'file':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
reports={}
for name,count in [('regression-v1',92),('execution-v1',14),('review-boundary-v2',4)]:
 p=root/name/'selected/paired.json';v=read(p)
 assert v['selectedComplete'] is True and len(v['rows'])==count
 assert not v['missing']
 assert all(r['referenceVerdict']=='pass' and r['candidateVerdict']=='pass' and r['semanticAgreement'] for r in v['rows'])
 reports[name]=(p,v)
execution=reports['execution-v1'][1]['rows'];assert all(r['exactAgreement'] and r['reference']['status']=='ok' and r['candidate']['status']=='ok' for r in execution)
before=read(root/'before-v2/paired.json');beforeRows={r['id']:r for r in before['rows']};afterRows={r['id']:r for r in reports['regression-v1'][1]['rows']}
repaired=[]
for name in ['parallel-outer-ungrouped','parallel-parenthesized-ref','parallel-ref-then-annotation','constructor-space','constructor-parenthesized']:
 key='phase5-adjacency/'+name;b=beforeRows[key];a=afterRows[key]
 assert b['referenceVerdict']=='pass' and b['candidateVerdict']=='fail' and not b['semanticAgreement']
 assert a['candidateVerdict']=='pass' and a['semanticAgreement'];repaired.append(key)
key='phase5-adjacency/parallel-bad-binder-first';assert 'expected term' in beforeRows[key]['candidate']['diagnostic'];a=afterRows[key]
assert 'a braced constructor pattern' in a['reference']['diagnostic'] and 'a constructor pattern requires braces: AdjOn' in a['candidate']['diagnostic']
api=root/'candidate-v1/api.mjs';p=root/'candidate-v1/api.mjs.bootstrap.json';proof=read(p)
assert proof['stage']=='upstream-bootstrap' and proof['provenance']['verifiedAfterBuild'] is True
assert proof['apiSha256']==identity(api)['sha256'];assert proof['sourceSha256']==identity(pathlib.Path(proof['source']))['sha256']
for i in proof['provenance']['inputs']:
 q=pathlib.Path(i['file']);assert str(q.resolve())==i['canonicalPath'] and identity(q)['sha256']==i['sha256']
for i in proof['modules']:assert identity(pathlib.Path(proof['source']).parent/i['file'])['sha256']==i['sha256']
v={'kind':'phase5-adjacency-selected-audit','complete':True,'scope':'96 paired acceptance/phase checks and14 exact interpreter/JS observations; not full conformance/native/fixedpoint or a performance comparison','gates':{k:{'report':identity(p),'observations':len(x['rows']),'exactDiagnosticOrOutputDifferences':sum(not r['exactAgreement'] for r in x['rows'])}for k,(p,x) in reports.items()},'repairedAcceptanceCases':repaired,'intendedBinderRuleRestored':True,'api':identity(api),'genuineBootstrap':identity(root/'candidate-v1/api.mjs.bootstrap.json'),'source':identity(pathlib.Path(proof['source'])),'auditor':identity(pathlib.Path(__file__).resolve()),'retainedFailures':['before: two attempted positive controls destructure a known constructor and are invalid upstream','before-v2 and candidate-v1 initial validation: inline #| oracles correctly override attempted acceptance-metadata correction','review-boundary-v1: bare constructor used as inferred parallel value requires an annotation in both compilers; corrected fixture is separate']}
out.write_text(json.dumps(v,indent=2)+'\n');print(json.dumps({'complete':True,'observations':110,'repairedAcceptanceCases':len(repaired)}))
