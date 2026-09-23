from pathlib import Path
import json,hashlib,sys
root=Path(sys.argv[1]).resolve();out=Path(sys.argv[2]).resolve();assert not out.exists()
def read(p):return json.loads(p.read_text())
def id(p):return {'file':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
a=read(root/'candidate-v3/api.mjs.bootstrap.json');p=root/'candidate-v4/api.mjs.bootstrap.json';b=read(p);original=read(root/'final-audit.json');assert original['complete'];assert b['stage']=='upstream-bootstrap'and b['provenance']['verifiedAfterBuild'];assert hash!=None
assert id(Path(b['apiPath']))['sha256']==b['apiSha256'];assert id(Path(b['source']))['sha256']==b['sourceSha256']
for i in b['provenance']['inputs']:assert id(Path(i['file']))['sha256']==i['sha256']
am={i['file']:i['sha256']for i in a['modules']};bm={i['file']:i['sha256']for i in b['modules']};assert set(am)==set(bm);changed=[n for n in am if am[n]!=bm[n]];assert changed==['src/front/literals_arrays.bend']
for f in (root/'candidate-v4/snapshot/src').rglob('*.bend'):assert 'f_ends_nat'not in f.read_text()and'f_nat_plus'not in f.read_text()
rp=root/'raw-v3-v4.json';r=read(rp);assert r['complete']and len(r['rows'])==11 and all(x['exact']for x in r['rows']);fp=root/'candidate-v4/validation-001/selected/paired.json';f=read(fp);assert f['selectedComplete']and len(f['rows'])==19 and all(x['semanticAgreement']for x in f['rows'])
assert not(set(b['exports'])&{'f_ends_nat','f_nat_plus'})
report={'kind':'phase5-nat-prefix-cleanup-audit','complete':True,'scope':'Final v4 removes two unreachable helpers; parser byte-identical to v3. Fresh full checked build,19 focused checks,11 exact accepted raw graphs.14 execution observations and overflow-order checks belong to v3; not rerun on v4.','priorSemanticAudit':id(root/'final-audit.json'),'bootstrap':id(p),'api':id(Path(b['apiPath'])),'source':id(Path(b['source'])),'focused':id(fp),'raw':id(rp),'changedModulesFromV3':changed,'maintainedExports':b['exports'],'allSourceReferencesAbsent':True,'auditor':id(Path(__file__).resolve())};out.write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({'complete':True,'sourceSha256':b['sourceSha256'],'apiSha256':b['apiSha256']}))
