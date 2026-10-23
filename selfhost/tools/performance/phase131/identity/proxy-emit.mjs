// Orchestration only: source checking, semantics and QBE verification remain
// inside the independently qualified, checked Bend compiler API.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [manifestArg,outArg]=process.argv.slice(2);
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(manifestArg && out.startsWith(root+'/selfhost/build/phase131/')&&!fs.existsSync(out));
const read=f=>JSON.parse(fs.readFileSync(f));
const pin=f=>{const file=path.resolve(f),b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const inputs=new Map();
const add=p=>{assert.deepEqual(pin(p.file),p);inputs.set(p.file,p);return p;};
const file=f=>add(pin(f));
file(import.meta.filename);file(process.execPath);file(manifestArg);
const manifest=read(manifestArg);assert(manifest.complete&&!manifest.targetsRun);manifest.inputs.forEach(add);
const selectionFile=path.join(root,'implementation/phase130/candidate.json');file(selectionFile);
const selected=read(selectionFile);assert(selected.complete&&selected.nativeQualified);
for(const key of ['source','api','checkedApi','sourceManifest','preferredCarrier','preferredCarrierReceipt','legacyCarrierReceipt'])add(selected[key]);
const receipt=read(selected.checkedApi.file);assert(receipt.complete&&receipt.checked&&receipt.status===0);receipt.inputs.forEach(add);
const compact=read(selected.preferredCarrierReceipt.file);assert(compact.complete&&compact.inverseByteIdentity);compact.inputs.forEach(add);add(compact.carrier);assert.deepEqual(compact.carrier,selected.preferredCarrier);
const legacy=read(selected.legacyCarrierReceipt.file);assert(legacy.complete);Object.values(legacy.inputPins).forEach(add);
const base=add(legacy.inputPins.base),baseText=fs.readFileSync(base.file,'utf8'),carrier=fs.readFileSync(compact.carrier.file,'utf8');
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={complete:false,rows:[],scope:'Qualified checked Bend API checks source and verifies complete emitted QBE. Static code inspection only; no runtime/correctness output or native performance claim.'};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};save();
try{
  const api=(await import(pathToFileURL(selected.api.file))).default;
  for(const row of manifest.cases){
    add(row.source);add(row.expected);const start=performance.now();
    const result=api.p111_compile_source(row.source.file,fs.readFileSync(row.source.file,'utf8'),base.file,baseText,carrier,compact.stamp,true);
    assert.equal(result.$,'P111Emission');assert.equal(result.error,'');
    const target=path.join(out,row.name+'.ssa'),fd=fs.openSync(target,'wx');let count=0,chunks=result.chunks;
    try{while(chunks?.$==='Con'){assert(++count<2000000);fs.writeSync(fd,chunks.head+'\n');chunks=chunks.tail;}assert.equal(chunks?.$,'Nil');}finally{fs.closeSync(fd);}
    report.rows.push({name:row.name,source:row.source,product:file(target),diagnosticSeconds:(performance.now()-start)/1000});save();
  }
  for(const p of inputs.values())add(p);report.complete=true;
}catch(error){report.error=String(error);process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));}
