// Exact transport oracle; all preparation, key decisions and verification in Bend.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import assert from 'node:assert/strict';import{pathToFileURL}from'node:url';
const root=path.resolve(import.meta.dirname,'../../../../..'),[apiFile,outArg]=process.argv.slice(2),out=path.resolve(outArg);assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase134/'));
const pin=f=>{f=path.resolve(f);let b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const read=f=>JSON.parse(fs.readFileSync(f));const inputs=new Map(),add=p=>{assert.deepEqual(pin(p.file),p);inputs.set(p.file,p);return p},file=f=>add(pin(f));
const ar=read(apiFile),selected=read(root+'/implementation/phase131/final/candidate.json');file(apiFile);file(root+'/implementation/phase131/final/candidate.json');file(import.meta.filename);file(process.execPath);assert(ar.complete&&ar.checked);ar.inputs.forEach(add);add(ar.api);add(selected.preferredCarrierReceipt);const cr=read(selected.preferredCarrierReceipt.file);cr.inputs.forEach(add);add(selected.preferredCarrier);const base=cr.inputs.find(x=>x.file.endsWith('/bend2/base.bend'));assert(base);
const list=x=>{const r=[];while(x?.$==='Con'){r.push(x.head);x=x.tail;}assert.equal(x?.$,'Nil');return r};
const empty=()=>({$:'P134UCache',inline:{$:'Nil'},ranges:{$:'Nil'}});const digest=s=>({bytes:Buffer.byteLength(s),sha256:crypto.createHash('sha256').update(s).digest('hex')});
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');let r={complete:false,rows:[],scope:'Hosted raw-plan adapter and same-session typed cache only; no native IO/executable qualification or speed claim.'};const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify({...r,inputs:[...inputs.values()]},null,2)+'\n');save();
try{
 const api=(await import(pathToFileURL(ar.api.file))).default;const prepared=api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(selected.preferredCarrier.file,'utf8'),selected.preferredStamp);assert.equal(prepared.$,'P86PreparationReady');let previous=empty();
 const text=e=>{assert.equal(e.$,'P111Emission');assert.equal(e.error,'');return list(e.chunks).map(x=>x+'\n').join('')};
 for(const rev of['a','b']){
  const source=path.resolve(import.meta.dirname,'../reuse/revision-'+rev+'.bend');file(source);const plan=api.p86_plan(prepared.seed,source,fs.readFileSync(source,'utf8'));assert.equal(plan.$,'P86PlanReady',plan.error);
  const expected=api.p111_emit_admitted(plan.request,api.p111_runtime_admission(plan.request));
  const warm=api.p134ns_planned(plan,previous),cold=api.p134ns_planned(plan,empty());assert.equal(warm.$,'P134UEmission');assert.equal(cold.$,'P134UEmission');assert.equal(warm.emission.$,'P134Planned');assert.equal(cold.emission.$,'P134Planned');
  const reference=text(expected),actual=text(api.p134e_collect(warm.emission)),fresh=text(api.p134e_collect(cold.emission));assert.equal(actual,reference);assert.equal(fresh,reference);fs.writeFileSync(out+'/'+rev+'.ssa',reference);
  r.rows.push({revision:rev,source:pin(source),rawPlanned:true,exactFresh:true,warmStats:list(warm.stats),coldStats:list(cold.stats),output:digest(actual)});previous=warm.cache;save();
 }
 assert.notDeepEqual(r.rows[0].output,r.rows[1].output);for(const p of inputs.values())add(p);r.complete=true;
}catch(e){r.error=String(e.stack||e);process.exitCode=1}finally{save();console.log(JSON.stringify(r))}
