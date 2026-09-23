from pathlib import Path
import hashlib,json,datetime
root=Path.cwd();base=root/'selfhost/build/phase6/campaign/semantics'
read=lambda p:json.loads(p.read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
paths=['baseline-combined-v1/paired.json','validation-combined-v1/selected/paired.json','runtime-combined-v1/selected/paired.json','graph-controls-combined-v1/report.json']
a,b,r,g=[read(base/p)for p in paths];old={(x['id'],x['lane']):x for x in a['rows']};new={(x['id'],x['lane']):x for x in b['rows']};assert set(old)==set(new)and len(new)==140
assert not a['missing']and not b['missing'];assert all(x['semanticAgreement']for x in new.values());assert all(old[k]['reference']==new[k]['reference']for k in old);assert not[k for k in old if old[k]['exactAgreement']and not new[k]['exactAgreement']]
assert len(r['rows'])==36 and not r['missing']and all(x['semanticAgreement']and x['exactAgreement']and x['candidateVerdict']=='pass'and x['referenceVerdict']=='pass'and x['candidate']['phase']=='runtime'and x['candidate']['checked']for x in r['rows']);assert g['complete']and len(g['cases'])==20
for path in ['baseline-combined-v1','validation-combined-v1/selected','runtime-combined-v1/selected']:
 for side in ['candidate','reference']:
  report=read(base/path/(side+'.json'));assert not report['changedInputs'];assert report['finished'];assert all(x.get('result',{}).get('status')not in ['timeout','crash','unsupported']for x in report['results'])
sessions=list(base.rglob('session-*.json'))
for p in sessions:
 j=read(p)
 if 'closed'in j:assert j['closed']and j['finished'],str(p)
manifest=read(base/'attempt-combined-v1/attempt.json');assert manifest['checked']and manifest['artifactKind']=='derived-b1';assert sha(Path(manifest['api']['file']))==manifest['api']['sha256'];proof=read(Path(manifest['bootstrapReport']['file']));assert proof['provenance']['verifiedAfterBuild']
original=root/'selfhost/build/phase5/integration/attempt-05/snapshot';snapshot=Path(manifest['snapshot']['root']);modules=read(snapshot/'src/compiler.json')['modules'];changed=[s for s in modules if sha(snapshot/s)!=sha(original/s)];assert set(changed)=={'src/front/parser.bend','src/front/sugar.bend','src/front/families.bend','src/front/fresh_work.bend','src/load/modules.bend'}
for s in modules:assert sha(root/'selfhost'/s)==sha(original/s),'Production source changed; coordinate audit: '+s
strict=[k for k,x in new.items()if x['candidateVerdict']=='fail'];assert sorted(strict)==sorted([('comptime/err_plus_term.bend','check'),('parse/plus_binder_term.bend','check')]);assert all(new['parse/prefix_operator_dead.bend',lane]['exactAgreement']and new['parse/prefix_operator_dead.bend',lane]['candidateVerdict'] in ['pass','observed']for lane in ['parse','check'])
out={'kind':'phase6-prefix-semantics-audit','created':datetime.datetime.now(datetime.timezone.utc).isoformat(),'complete':True,'decision':'isolated-gates-pass; ready for root integration; not promoted','sourceSha256':proof['sourceSha256'],'checkedApiSha256':manifest['checkedApi']['sha256'],'derivedApiSha256':manifest['api']['sha256'],'changedModules':changed,'productionSourceUnchanged':True,'frontend':{'observations':len(new),'baselineClassificationAgreement':sum(x['semanticAgreement']for x in old.values()),'candidateClassificationAgreement':sum(x['semanticAgreement']for x in new.values()),'baselineExact':sum(x['exactAgreement']for x in old.values()),'candidateExact':sum(x['exactAgreement']for x in new.values()),'newExact':sum(not old[k]['exactAgreement']and new[k]['exactAgreement']for k in old),'lostExact':0,'referenceUnchanged':True,'strictFailures':[{'id':k[0],'lane':k[1]}for k in strict]},'runtime':{'observationsPerCompiler':36,'lanes':['interpreter','js','native'],'fixtures':12,'exactAgreement':36},'graphControls':20,'closedPersistentHistories':len(sessions),'reports':[{'file':str((base/p).relative_to(root)),'sha256':sha(base/p)}for p in paths]}
(root/'implementation/phase6/prefix-semantics-audit.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out,indent=2))
