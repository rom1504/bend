#!/usr/bin/env python3
"""Audit recorded P5-010 observations without normalizing diagnostics."""
import hashlib,json,pathlib,sys
root=pathlib.Path(__file__).resolve().parents[2]
run=root/'build/phase5/declaration-freshness'
output=pathlib.Path(sys.argv[1])
assert not output.exists()
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
inputs=[]
def read(p):
 p=pathlib.Path(p);inputs.append({'file':str(p.resolve()),'sha256':sha(p)});return json.loads(p.read_text())
report={'kind':'phase5-declaration-freshness-audit','complete':False,'inputs':inputs,'scope':'Selected local freshness, order, separate namespaces and explicit remaining imported/rendering limitations; no full-suite claim.'}
try:
 b=read(root/'build/phase5/integration/attempt-01/api.mjs.bootstrap.json');a=read(run/'candidate-02/api.mjs.bootstrap.json')
 bm={x['file']:x['sha256'] for x in b['modules']};am={x['file']:x['sha256'] for x in a['modules']}
 assert bm.keys()==am.keys()
 delta=[k for k in bm if bm[k]!=am[k]];assert delta==['src/front/declarations.bend'],delta
 assert a['provenance']['verifiedAfterBuild'] is True
 report['sourceDelta']=delta;report['apiSha256']=a['apiSha256'];report['sourceSha256']=a['sourceSha256']
 pairs=[('local',run/'baseline-01/paired.json',run/'candidate-02/validation-001/selected/paired.json'),('upstream',run/'upstream-before/paired.json',run/'upstream-exact-after/paired.json'),('neighbors',run/'neighbors-exact-before/paired.json',run/'neighbors-exact-after/paired.json'),('scope',run/'scope-exact-before/paired.json',run/'scope-exact-after/paired.json')]
 repaired={'phase5/freshness/same-family','phase5/freshness/cross-family','phase5/freshness/duplicate-before-bad-fields','phase5/freshness/duplicate-before-bad-later-body','check/book_prefix_arity.bend','check/ctor_shared_tag.bend','compile/ctor_tag_dispatch_000.bend','compile/ctor_tag_dispatch_001.bend','parse/duplicate_ctor_name.bend'}
 report['rows']=[]
 for group,before,after in pairs:
  old=read(before);new=read(after);oi={(r['id'],r['lane']):r for r in old['rows']}
  assert len(new['rows'])==len(oi)
  for p in [old,new]:
   assert not p.get('error') and not p['missing']
   for name in ['candidate','reference']:
    raw=read(p['attempts'][name]['file'])
    assert raw['finished'] and not raw.get('changedInputs')
    assert not raw['identity']['changedArtifacts'] and raw['identity']['adapterChangedDuringRun'] is False
    assert all(r['status'] not in ['crash','timeout','unsupported'] for r in raw['results'])
  for r in new['rows']:
   o=oi[(r['id'],r['lane'])];assert r['reference']==o['reference'],r['id']
   if r['id'] in repaired:
    assert r['semanticAgreement'],r['id']
    assert 'a fresh constructor name (duplicate declaration:' in r['reference']['diagnostic']
    assert 'a fresh constructor name (duplicate declaration:' in r['candidate']['diagnostic']
    assert r['candidate']['phase']=='parse' and r['candidate']['checked'] is False
   else:
    assert r['candidate']==o['candidate'],r['id']
   if group=='neighbors':assert r['exactAgreement'] and r['candidateVerdict']=='pass' and r['referenceVerdict']=='pass',r
   assert not o['exactAgreement'] or r['exactAgreement'],'New exact difference: '+r['id']
   report['rows'].append({'group':group,'id':r['id'],'lane':r['lane'],'semanticBefore':o['semanticAgreement'],'semanticAfter':r['semanticAgreement'],'exactBefore':o['exactAgreement'],'exactAfter':r['exactAgreement'],'reference':r['reference'],'candidate':r['candidate']})
 report['pairedObservationsPerVariant']=len(report['rows'])
 report['resolvedSemantic']=len([r for r in report['rows'] if not r['semanticBefore'] and r['semanticAfter']])
 report['resolvedExact']=len([r for r in report['rows'] if not r['exactBefore'] and r['exactAfter']])
 report['remainingSemantic']=len([r for r in report['rows'] if not r['semanticAfter']])
 report['remainingExact']=len([r for r in report['rows'] if not r['exactAfter']])
 for item in inputs:assert sha(pathlib.Path(item['file']))==item['sha256']
 report['complete']=True
except Exception as error:
 import traceback
 report['error']=traceback.format_exc()
output.write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({k:v for k,v in report.items() if k not in ['rows','inputs']}))
if not report['complete']:sys.exit(1)
