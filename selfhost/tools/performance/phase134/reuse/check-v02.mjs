// Supervision and exact-byte oracle only; all cache decisions/lowering are Bend.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../../..');
const [receiptArg,outArg,mode='finite']=process.argv.slice(2),out=path.resolve(outArg);
assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase134/'));
assert(['finite','requests','census','lexer-edit'].includes(mode));
const read=f=>JSON.parse(fs.readFileSync(f));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const inputs=new Map(),add=p=>{assert.deepEqual(pin(p.file),p);inputs.set(p.file,p);return p;},file=f=>add(pin(f));
const receipt=read(receiptArg);file(receiptArg);assert(receipt.complete&&receipt.checked&&receipt.status===0);receipt.inputs.forEach(add);add(receipt.api);file(import.meta.filename);file(process.execPath);
const manifestFile=path.join(path.dirname(receipt.command.find(x=>x.endsWith('.bend'))),'manifest.json'),manifest=read(manifestFile);file(manifestFile);manifest.inputs.forEach(add);assert.deepEqual(manifest.overrides,[]);
const list=xs=>{const a=[];while(xs?.$==='Con'){a.push(xs.head);assert(a.length<100000);xs=xs.tail;}assert.equal(xs?.$,'Nil');return a;};
const nil={$:'Nil'};
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase134-checked-owner-reuse',complete:false,mode,source:manifest.source,controls:[],rows:[],scope:'Checked Bend pre-p111_entry memo, conservative closed grammar; generic owner reuse only. No native speed claim or producer/selection change.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
const timed=f=>{const t=performance.now(),result=f();return{result,seconds:(performance.now()-t)/1000};};
const text=e=>{assert.equal(e.$,'P111Emission');assert.equal(e.error,'');return list(e.chunks).join('');};
const digest=s=>({bytes:Buffer.byteLength(s),sha256:crypto.createHash('sha256').update(s).digest('hex')});
try{
 const api=(await import(pathToFileURL(receipt.api.file))).default;
 if(mode==='finite'){
  const r=timed(()=>api.p134ur_controls());report.controls=list(r.result);report.seconds=r.seconds;save();
  assert.equal(report.controls.length,29);assert(report.controls.every(x=>x.endsWith(':pass')),JSON.stringify(report.controls));
 }else{
  const selectedFile=path.join(root,'implementation/phase131/final/candidate.json'),selected=read(selectedFile);file(selectedFile);assert(selected.nativeQualified);
  const legacy=read(selected.legacyCarrierReceipt.file),compact=read(selected.preferredCarrierReceipt.file);add(selected.legacyCarrierReceipt);add(selected.preferredCarrierReceipt);assert(legacy.complete&&compact.complete&&compact.inverseByteIdentity);Object.values(legacy.inputPins).forEach(add);compact.inputs.forEach(add);add(compact.carrier);
  const base=legacy.inputPins.base,prepared=timed(()=>api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(compact.carrier.file,'utf8'),compact.stamp));assert.equal(prepared.result.$,'P86PreparationReady');report.basePreparationSeconds=prepared.seconds;
  if(mode==='census'){
   const referenceFile=path.join(root,'selfhost/build/phase134/reference02.json'),reference=read(referenceFile);file(referenceFile);assert(reference.complete);
   for(const c of reference.cases){add(c.source);const plan=timed(()=>api.p86_plan(prepared.result.seed,c.source.file,fs.readFileSync(c.source.file,'utf8')));assert.equal(plan.result.$,'P86PlanReady',plan.result.error);const found=timed(()=>api.p134ur_request_inventory(plan.result.request));const counts=list(found.result);assert.equal(counts.length,2);report.rows.push({name:c.name,source:c.source,frontendSeconds:plan.seconds,staticPreparationAndInventorySeconds:found.seconds,eligible:counts[0],refused:counts[1]});save();}
  }else{
   let beforeFile,afterFile;
   if(mode==='lexer-edit'){
    const referenceFile=path.join(root,'selfhost/build/phase134/reference02.json'),reference=read(referenceFile);file(referenceFile);assert(reference.complete);
    const lexer=reference.cases.find(c=>c.name==='lexer');assert(lexer);add(lexer.source);beforeFile=lexer.source.file;
    const original=fs.readFileSync(beforeFile,'utf8'),needle='U32.shln(x, 13n)';assert.equal(original.split(needle).length,2);
    afterFile=path.join(out,'lexer-edited.bend');fs.writeFileSync(afterFile,original.replace(needle,'U32.shln(x, 12n)'));
   }else{beforeFile=path.join(import.meta.dirname,'revision-a.bend');afterFile=path.join(import.meta.dirname,'revision-b.bend');}
   file(beforeFile);file(afterFile);
   // Same semantic path in both revisions: path identity is intentionally fixed.
   const a=timed(()=>api.p86_plan(prepared.result.seed,beforeFile,fs.readFileSync(beforeFile,'utf8'))),b=timed(()=>api.p86_plan(prepared.result.seed,beforeFile,fs.readFileSync(afterFile,'utf8')));assert.equal(a.result.$,'P86PlanReady',a.result.error);assert.equal(b.result.$,'P86PlanReady',b.result.error);
   const cold=timed(()=>api.p134ur_emit_request(a.result.request,nil));assert.equal(cold.result.$,'P134UREmission');
   const warm=timed(()=>api.p134ur_emit_request(b.result.request,cold.result.slots));assert.equal(warm.result.$,'P134UREmission');
   const fresh=timed(()=>api.p111_emit_admitted(b.result.request,api.p111_runtime_admission(b.result.request)));
   const coldText=text(cold.result.emission),warmText=text(warm.result.emission),freshText=text(fresh.result);assert.equal(warmText,freshText);assert.notEqual(coldText,warmText);
   fs.writeFileSync(path.join(out,'warm.ssa'),warmText);fs.writeFileSync(path.join(out,'fresh.ssa'),freshText);
   const cachedOwners=list(cold.result.slots).filter(s=>s.$==='P134URCached').map(s=>({name:s.key.owner,native:s.key.native,arity:s.key.arity}));
   report.rows.push({name:mode==='lexer-edit'?'frozen-lexer-prng-body-edit':'real-checked-owner-body-edit',before:file(beforeFile),after:file(afterFile),frontendBeforeSeconds:a.seconds,frontendAfterSeconds:b.seconds,coldRequestSeconds:cold.seconds,warmRequestSeconds:warm.seconds,independentFreshRequestSeconds:fresh.seconds,coldStats:cold.result.stats,warmStats:warm.result.stats,cachedOwners,wholeFreshByteEquality:true,coldOutput:digest(coldText),newOutput:digest(warmText),warmArtifact:file(path.join(out,'warm.ssa')),freshArtifact:file(path.join(out,'fresh.ssa')),timingScope:'single hosted observation, not calibrated native performance'});save();
  }
 }
 for(const p of inputs.values())add(p);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}finally{save();console.log(JSON.stringify({complete:report.complete,mode,controls:report.controls,rows:report.rows,error:report.error}));}
