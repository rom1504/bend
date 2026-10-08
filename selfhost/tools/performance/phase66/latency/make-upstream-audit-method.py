#!/usr/bin/env python3
"""Select the immutable checked snapshot verifier for the explicitly new upstream pin."""
import argparse, ast, hashlib, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5];RAW=ROOT/'selfhost/build/phase66';PARENT=RAW/'latency-method03'
def identity(p):
    p=Path(p).resolve(strict=True);return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
p=argparse.ArgumentParser(description=__doc__);p.add_argument('out',type=Path)
a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(RAW) and not out.exists()
parent=identity(PARENT/'derivation.json');assert parent['sha256']=='0911c1fc0af3a736b5521836ccd1403c677de1ee5412d83dbb76d377a73db43c'
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
        edit("    if(!attempts.has(directory))attempts.set(directory,await verifyAttempt(directory));", """    if(!attempts.has(directory)) {
      const metadata=read(id),bootstrap=read(metadata.bootstrapReport);
      if(bootstrap.revision==='018751270e800bc222a93dad7f257083ee53a5f7') {
        attempts.set(directory,await verifyAttempt(directory));
      } else {
        assert.equal(bootstrap.revision,'059266225b77c8ca256ac6b25ee5c21449bab151','Unadmitted compiler target');
        assert.equal(metadata.kind,'bend-development-attempt');assert.equal(metadata.version,1);assert.equal(metadata.checked,true);
        const snapshot=metadata.snapshot.root;
        assert.ok(path.resolve(snapshot).startsWith(path.join(root,'selfhost/build/phase66')+path.sep));
        const frozen=new Map();
        for(const row of metadata.snapshot.sources) {
          assert.ok(row.frozen.file.startsWith(snapshot+path.sep));assert.equal(row.frozen.file,row.frozen.canonicalPath);
          assert.equal(row.original.sha256,row.frozen.sha256);assert.ok(!frozen.has(row.frozen.file));
          frozen.set(row.frozen.file,pin(row.frozen));
        }
        const audit=path.join(snapshot,'tools/development/workflow.mjs');
        for(const name of ['src/compiler.json','tools/development/workflow.mjs','tools/development/process.mjs','tools/conformance/inventory.mjs','tools/typed-driver.mjs','tools/base-cache-graph.mjs'])assert.ok(frozen.has(path.join(snapshot,name)),name);
        assert.equal(read(path.join(snapshot,'src/compiler.json')).upstream,bootstrap.revision);
        const verifier=await import(pathToFileURL(audit));
        const checked=await verifier.verifyAttempt(directory);
        assert.deepEqual(checked,metadata);attempts.set(directory,checked);
        historicalMappings.push({attempt:id,actual:frozen.get(audit),scope:'New upstream uses its exact checked snapshot verifier and pinned dependency closure; old images retain the old immutable verifier. No revision check is removed.'});
      }
    }""")
    if name=='run.py':ast.parse(text)
    texts[name]=text;rows.append(dict(parent=before,output=dict(file=str(out/name),sha256=hashlib.sha256(text.encode()).hexdigest()),edits=edits))
out.mkdir(parents=True)
for name,text in texts.items():(out/name).write_text(text)
result=dict(kind='phase61-candidate-fast-loop-method',complete=True,**{'pass':True},dataOnly=True,targetExecuted=False,
    producer=identity(__file__),parentDerivation=parent,derivations=rows,explicitCacheAdmission=manifest['explicitCacheAdmission'],
    immutableAuditSnapshot=manifest['immutableAuditSnapshot'],optionalProductAdmission=manifest['optionalProductAdmission'],
    newUpstreamAudit='Exact HEAD checked snapshot workflow with all frozen source identities verified before import. Actual verifyAttempt and bootstrap revision/Base/API/source checks execute unchanged.',
    scope='Admit the new upstream through its independently frozen verifier; keep every old audit and all clocks, guards, sidecar and raw-output checks unchanged.')
(out/'derivation.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(method=identity(out/'derivation.json'))))
