#!/usr/bin/env python3
"""Admit the exact independently qualified new-Base annotation host transition."""
import argparse, ast, hashlib, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5];RAW=ROOT/'selfhost/build/phase66';PARENT=RAW/'latency-method04'
def identity(p):
    p=Path(p).resolve(strict=True);return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
p=argparse.ArgumentParser(description=__doc__);p.add_argument('out',type=Path)
a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(RAW) and not out.exists()
parent=identity(PARENT/'derivation.json');assert parent['sha256']=='b4aa77b97b7f080f2ce098b4edf0e17da178ae5ba8de5e699262f50154e3f9cb'
permission=identity(RAW/'integration-base-annotations01.json');assert permission['sha256']=='afd0620aa25fc4e030c8a95fb0a605af4c93a4eb464f392bda8ebf3265ae5511'
proof=json.loads(Path(permission['file']).read_text());assert proof['complete'] and proof['pass']
for row in proof['controls']:
    assert identity(ROOT/row['file'])['sha256']==row['sha256']
    receipt=json.loads((ROOT/row['file']).read_text());assert receipt['complete'] and receipt['pass'] and receipt['inputsUnchanged']
manifest=json.loads((PARENT/'derivation.json').read_text());parents={Path(r['output']['file']).name:r['output'] for r in manifest['derivations']}
texts={};rows=[]
for name in ['profile.mjs','setup.mjs','worker.mjs','run.py']:
    before=identity(PARENT/name);assert before==parents[name];text=(PARENT/name).read_text();edits=[]
    def edit(old,new,count=1):
        global text
        assert text.count(old)==count,(name,old,text.count(old),count)
        text=text.replace(old,new);edits.append(dict(old=old,new=new,count=count))
    count=text.count(str(PARENT))
    if count:edit(str(PARENT),str(out),count)
    if name=='setup.mjs':
        edit("      const marker=\"const BASE_ANNOTATION_BASE_SHA256='c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661';\";", """      let allowedBaseSha256='c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661',permission=null;
      if(image.driver.sha256==='e093483d5103a8e833b6ca710246b1ec3c579b7fac5060c8e42f626c5e25ec85') {
        permission=pin({file:path.join(root,'selfhost/build/phase66/integration-base-annotations01.json'),sha256:'afd0620aa25fc4e030c8a95fb0a605af4c93a4eb464f392bda8ebf3265ae5511'});
        const qualified=read(permission);assert.equal(qualified.kind,'phase66-qualified-base-annotation-permission-integration');assert.equal(qualified.complete,true);assert.equal(qualified.pass,true);
        assert.equal(qualified.proposal.afterSha256,image.driver.sha256);assert.equal(qualified.controls.length,2);
        for(const control of qualified.controls){const result=read({file:path.join(root,control.file),sha256:control.sha256});assert.equal(result.complete,true);assert.equal(result.pass,true);assert.equal(result.inputsUnchanged,true);}
        allowedBaseSha256='99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf';
      }
      const marker="const BASE_ANNOTATION_BASE_SHA256='"+allowedBaseSha256+"';";""")
        edit("      const allowedBaseSha256='c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661';\n", "")
        edit("productEligibility={driver:image.driver,allowedBaseSha256", "productEligibility={driver:image.driver,permission,allowedBaseSha256")
        edit("Exact source-backed producer AND consumer SHA gate; new Base is deliberately ineligible", "Exact source-backed producer AND consumer SHA gate; new Base permission requires the pinned independent owned/custom qualification and exact integrated host")
    if name=='run.py':ast.parse(text)
    texts[name]=text;rows.append(dict(parent=before,output=dict(file=str(out/name),sha256=hashlib.sha256(text.encode()).hexdigest()),edits=edits))
out.mkdir(parents=True)
for name,text in texts.items():(out/name).write_text(text)
result=dict(kind='phase61-candidate-fast-loop-method',complete=True,**{'pass':True},dataOnly=True,targetExecuted=False,
    producer=identity(__file__),parentDerivation=parent,derivations=rows,explicitCacheAdmission=manifest['explicitCacheAdmission'],
    immutableAuditSnapshot=manifest['immutableAuditSnapshot'],optionalProductAdmission=dict(parent=manifest['optionalProductAdmission'],qualifiedNewPermission=permission),
    scope='Only exact qualified newBase/driver eligibility addition. Prior03 mandatory-only timings retain their original method. Eligible images still require actual positive artifact creation/full binding; no fallback is timed as a hit.')
(out/'derivation.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(method=identity(out/'derivation.json'))))
