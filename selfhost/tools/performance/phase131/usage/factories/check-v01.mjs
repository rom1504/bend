// Test-only transport: all reduction/admission executes the checked Bend API.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../../../..');
const [apiFile,outArg]=process.argv.slice(2),out=path.resolve(outArg);assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase131/'));
const read=f=>JSON.parse(fs.readFileSync(f));const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const inputs=new Map();const add=p=>{assert.deepEqual(pin(p.file),p);inputs.set(p.file,p);return p;};const file=f=>add(pin(f));
const selectedFile=path.join(root,'implementation/phase130/candidate.json'),selected=read(selectedFile);file(selectedFile);assert(selected.complete&&selected.nativeQualified);
const r=read(apiFile);file(apiFile);assert(r.complete&&r.checked&&r.status===0);r.inputs.forEach(add);add(r.api);
const smFile=path.join(path.dirname(r.command.find(x=>x.endsWith('.bend'))),'manifest.json'),sm=read(smFile);file(smFile);sm.inputs.forEach(add);add(sm.source);assert.deepEqual(sm.overrides,[]);
const compact=read(selected.preferredCarrierReceipt.file),legacy=read(selected.legacyCarrierReceipt.file);add(selected.preferredCarrierReceipt);add(selected.legacyCarrierReceipt);assert(compact.complete&&compact.inverseByteIdentity&&legacy.complete);compact.inputs.forEach(add);Object.values(legacy.inputPins).forEach(add);add(compact.carrier);
const base=add(legacy.inputPins.base),source=file(path.join(import.meta.dirname,'workload-v01.bend'));file(import.meta.filename);file(process.execPath);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));const report={complete:false,source:sm.source,fixture:source,controls:[],comparisons:[],scope:'Data-only checked Bend closed-factory evaluator. No production override, static-pool mutation, emitted program or performance claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
try{
 const api=(await import(pathToFileURL(r.api.file))).default;let xs=api.p131cf_controls();while(xs?.$==='Con'){report.controls.push(xs.head);assert(report.controls.length<=17);xs=xs.tail;}assert.equal(xs?.$,'Nil');assert.equal(report.controls.length,17);save();assert(report.controls.every(x=>x.endsWith(':pass')));
 const prepared=api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(compact.carrier.file,'utf8'),compact.stamp);assert.equal(prepared.$,'P86PreparationReady');
 const plan=api.p86_plan(prepared.seed,source.file,fs.readFileSync(source.file,'utf8'));assert.equal(plan.$,'P86PlanReady',plan.error);
 for(const [a,b] of [['original_missing','direct_missing'],['original_packet','direct_packet']]){
  const actual=api.p131cf_request(plan.request,a),expected=api.p131cf_request(plan.request,b);
  fs.writeFileSync(path.join(out,a+'.json'),JSON.stringify(actual,null,2)+'\n');fs.writeFileSync(path.join(out,b+'.json'),JSON.stringify(expected,null,2)+'\n');
  assert.equal(actual.$,'P131CFValue',a);assert.equal(expected.$,'P131CFValue',b);assert.deepEqual(actual,expected);
  report.comparisons.push({factory:a,literal:b,wholeResultEqual:true,result:file(path.join(out,a+'.json')),literalResult:file(path.join(out,b+'.json'))});save();
 }
 for(const p of inputs.values())add(p);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}finally{save();console.log(JSON.stringify({complete:report.complete,controls:report.controls,comparisons:report.comparisons.length,error:report.error}));}
