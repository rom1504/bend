// Host transport only: a bounded call to the checked Bend frontend, no lowering.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../../..');
const [apiFile,manifestFile,outArg,...names]=process.argv.slice(2);
const out=path.resolve(outArg);assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase131/'));
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const read=f=>JSON.parse(fs.readFileSync(f));
const verify=p=>{const q=pin(p.file);assert.equal(q.bytes,p.bytes);assert.equal(q.sha256,p.sha256);};
const receipt=read(apiFile),manifest=read(manifestFile);
assert(receipt.complete&&receipt.checked&&receipt.exports.includes('p86_plan'));
const selectedFile=path.join(root,'implementation/phase130/candidate.json'),selected=read(selectedFile);
assert(selected.complete&&selected.nativeQualified);
const legacy=read(selected.legacyCarrierReceipt.file),compact=read(selected.preferredCarrierReceipt.file);
assert(legacy.complete&&compact.complete&&compact.inverseByteIdentity);
assert.deepEqual(compact.parentCarrier,legacy.carrier);assert.equal(compact.stamp,selected.preferredStamp);
const base=legacy.inputPins.base;
const cases=manifest.cases.filter(c=>names.includes(c.name));assert.equal(cases.length,names.length);
const inputs=[pin(import.meta.filename),pin(apiFile),pin(manifestFile),pin(selectedFile),receipt.api,...receipt.inputs,
  selected.legacyCarrierReceipt,selected.preferredCarrierReceipt,...Object.values(legacy.inputPins),
  compact.carrier,...compact.inputs,...cases.map(c=>c.source),pin(process.execPath)];
inputs.forEach(verify);fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={complete:false,inputs,rows:[],lowering:false,nativeExecution:false,
  scope:'Checked Bend p88_cache_prepare and p86_plan only. No code generation, benchmark, native qualification or production change.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try {
  const api=(await import(pathToFileURL(receipt.api.file))).default;
  const t=performance.now();const prep=api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(compact.carrier.file,'utf8'),compact.stamp);
  report.prepareSeconds=(performance.now()-t)/1000;assert.equal(prep.$,'P86PreparationReady');
  for(const c of cases){const start=performance.now();const p=api.p86_plan(prep.seed,c.source.file,fs.readFileSync(c.source.file,'utf8'));
    const row={name:c.name,source:c.source,result:p.$,error:p.error??'',seconds:(performance.now()-start)/1000};report.rows.push(row);save();
    assert.equal(p.$,'P86PlanReady',JSON.stringify(row));}
  inputs.forEach(verify);report.complete=true;
} catch(error){report.error=String(error);process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,rows:report.rows,error:report.error}));}
