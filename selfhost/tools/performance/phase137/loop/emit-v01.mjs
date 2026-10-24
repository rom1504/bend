// Host orchestration only: the checked Bend compiler executes its ordinary path.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../../..');
const [apiFile,sourceManifestFile,casesFile,outArg,...names]=process.argv.slice(2);
const out=path.resolve(outArg);
assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase137/'));
const read=p=>JSON.parse(fs.readFileSync(p));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const inputs=new Map(),add=p=>{assert.deepEqual(pin(p.file),p);inputs.set(p.file,p);return p},file=f=>add(pin(f));
const ar=read(apiFile),sm=read(sourceManifestFile),cm=read(casesFile);
assert(ar.complete&&ar.checked&&ar.status===0&&sm.complete&&cm.complete!==false);
assert(ar.inputs.some(p=>p.file===sm.source.file&&p.sha256===sm.source.sha256));
for(const f of [apiFile,sourceManifestFile,casesFile,import.meta.filename,process.execPath])file(f);
ar.inputs.forEach(add);add(ar.api);add(sm.source);(sm.inputs||[]).forEach(add);(cm.inputs||[]).forEach(add);
const selectionFile=path.join(root,'implementation/phase134/final/candidate.json');
file(selectionFile);const selected=read(selectionFile);assert(selected.nativeQualified);
add(selected.runtime);add(selected.preferredCarrierReceipt);add(selected.preferredCarrier);
const carrier=read(selected.preferredCarrierReceipt.file);carrier.inputs.forEach(add);
const base=carrier.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));assert(base);
const cases=names.length?names.map(n=>{const c=cm.cases.find(c=>c.name===n);assert(c,'Unknown case '+n);return c}):cm.cases;
assert(cases.length>0&&cases.length<=45);
for(const c of cases){add(c.source);if(c.expectedStdoutEvidence)add(c.expectedStdoutEvidence);if(c.expectedQbe)add(c.expectedQbe)}
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase137-ordinary-checked-emission',complete:false,producerSource:sm.source,api:ar.api,runtime:selected.runtime,cases:[],scope:'Checked p86_plan, runtime admission and ordinary p111_emit_admitted path. Existing original/derived/final verification runs in Bend. No historical alternate lowering path or installed selection change.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');
const tag=(v,t)=>{assert.equal(v?.$,t);return v};
const text=e=>{tag(e,'P111Emission');assert.equal(e.error,'');let xs=e.chunks;const a=[];while(xs?.$==='Con'){assert.equal(typeof xs.head,'string');a.push(xs.head+'\n');xs=xs.tail}tag(xs,'Nil');return a.join('')};
const started=performance.now();save();
try{
 const api=(await import(pathToFileURL(ar.api.file))).default;
 let t=performance.now();
 const prep=tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(selected.preferredCarrier.file,'utf8'),selected.preferredStamp),'P86PreparationReady');
 report.prepareSeconds=(performance.now()-t)/1000;
 for(const c of cases){
  const row={name:c.name,source:c.source,expectedStdoutEvidence:c.expectedStdoutEvidence};report.cases.push(row);save();
  t=performance.now();const plan=tag(api.p86_plan(prep.seed,c.source.file,fs.readFileSync(c.source.file,'utf8')),'P86PlanReady');row.frontendSeconds=(performance.now()-t)/1000;
  t=performance.now();assert.equal(api.p111_runtime_admission(plan.request),'');row.admissionSeconds=(performance.now()-t)/1000;
  t=performance.now();const output=text(api.p111_emit_admitted(plan.request,''));row.emitSeconds=(performance.now()-t)/1000;
  assert(output.includes('export function'),'No complete QBE');
  const product=path.join(out,c.name+'.ssa');fs.writeFileSync(product,output);row.qbe=pin(product);row.verified=true;
  if(c.expectedQbe){row.byteExact=output===fs.readFileSync(c.expectedQbe.file,'utf8');assert(row.byteExact,'Independent QBE differs: '+c.name)}
  save();console.log(JSON.stringify({name:c.name,bytes:row.qbe.bytes,frontendSeconds:row.frontendSeconds,emitSeconds:row.emitSeconds,byteExact:row.byteExact}));
 }
 for(const p of inputs.values())add(p);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1}
finally{report.seconds=(performance.now()-started)/1000;report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,cases:report.cases.length,seconds:report.seconds,error:report.error}));}
