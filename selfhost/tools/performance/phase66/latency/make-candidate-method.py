#!/usr/bin/env python3
"""Admit the selected host's explicit Base-ineligible optional-product fallback."""
import argparse, ast, hashlib, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
RAW=ROOT/'selfhost/build/phase66';PARENT=RAW/'latency-method02'
def identity(p):
    p=Path(p).resolve(strict=True);return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
p=argparse.ArgumentParser(description=__doc__);p.add_argument('out',type=Path)
a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(RAW) and not out.exists()
parent=identity(PARENT/'derivation.json');assert parent['sha256']=='ff77d6a030b3f509eb5b1eef386db7f5e354ac6bffeb66a45dce4700d5bbc276'
manifest=json.loads((PARENT/'derivation.json').read_text());parents={Path(r['output']['file']).name:r['output'] for r in manifest['derivations']}
rows=[];texts={}
for name in ['profile.mjs','setup.mjs','worker.mjs','run.py']:
    before=identity(PARENT/name);assert before==parents[name];text=(PARENT/name).read_text();edits=[]
    def edit(old,new,count=1):
        global text
        assert text.count(old)==count,(name,old,text.count(old),count)
        text=text.replace(old,new);edits.append(dict(old=old,new=new,count=count))
    count=text.count(str(PARENT))
    if count:edit(str(PARENT),str(out),count)
    if name=='setup.mjs':
        edit("    const declared=D.baseAnnotationDirectory!==undefined;", """    // APIs establish capability; the pinned host's exact Base gate establishes eligibility.
    // State65 and the reviewed Phase66 host intentionally gate both producer and consumer.
    let productEligibility=null;
    if(supported) {
      const driverText=fs.readFileSync(image.driver.file,'utf8');
      const marker="const BASE_ANNOTATION_BASE_SHA256='c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661';";
      assert.equal(driverText.split(marker).length-1,1,'Unadmitted Base product policy');
      for(const outcome of ['null','false'])assert.equal(driverText.split('if(info.baseSha256!==BASE_ANNOTATION_BASE_SHA256)return '+outcome+';').length-1,1,'Missing exact producer/consumer Base gate');
      const allowedBaseSha256='c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661';
      productEligibility={driver:image.driver,allowedBaseSha256,actualBaseSha256:selected.attempt.base.sha256,
        eligible:selected.attempt.base.sha256===allowedBaseSha256,policy:'Exact source-backed producer AND consumer SHA gate; new Base is deliberately ineligible'};
    }
    const eligible=supported&&productEligibility.eligible;
    const declared=D.baseAnnotationDirectory!==undefined;""")
        edit("    if(supported) {\n      assert.equal(cacheBindings.length,1);", "    if(eligible) {\n      assert.equal(cacheBindings.length,1);")
        edit("'Unexpected product directory for an unsupported image'", "'Unexpected product directory for an unsupported or Base-ineligible image'")
        edit("exists:productExists,declared,supported,files:productFiles", "exists:productExists,declared,supported,eligible,eligibility:productEligibility,files:productFiles")
        edit("Explicit preparation generated and decoder-validated optional products; this verifier binds exact metadata/digests and directory inventory. No-hit workers preserve the same dependency.", "Explicit preparation generates products only for the source-backed eligible Base hash. Eligible images require one fully bound file; unsupported/ineligible images require absence. Every worker preserves that inventory outside clocks.")
    if name=='run.py':ast.parse(text)
    texts[name]=text;rows.append(dict(parent=before,output=dict(file=str(out/name),sha256=hashlib.sha256(text.encode()).hexdigest()),edits=edits))
out.mkdir(parents=True)
for name,text in texts.items():(out/name).write_text(text)
result=dict(kind='phase61-candidate-fast-loop-method',complete=True,**{'pass':True},dataOnly=True,targetExecuted=False,
    producer=identity(__file__),parentDerivation=parent,derivations=rows,
    explicitCacheAdmission=manifest['explicitCacheAdmission'],immutableAuditSnapshot=manifest['immutableAuditSnapshot'],
    optionalProductAdmission=dict(parent=manifest['optionalProductAdmission'],eligibleBaseSha256='c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661',
        policy='Require capability AND exact host producer/consumer Base gate. Eligible singleton required; ineligible absence required. No silent missing eligible product.'),
    scope='Only explicit reviewed Base eligibility distinction; clocks, compiler inputs, complete raw output checks, frame admission and every-worker sidecar inventory stay unchanged.')
(out/'derivation.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(method=identity(out/'derivation.json'))))
