// Checked Bend performs preparation and compilation. Host owns timing/oracles.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../../..');
const [parentFile,candidateFile,referenceFile,outArg,roundsArg='2']=process.argv.slice(2),out=path.resolve(outArg),rounds=Number(roundsArg);
assert(Number.isInteger(rounds)&&rounds>=1&&rounds<=2);
assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase135/'));
const read=f=>JSON.parse(fs.readFileSync(f));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const digest=s=>({bytes:Buffer.byteLength(s),sha256:crypto.createHash('sha256').update(s).digest('hex')});
const inputs=new Map(),add=p=>{assert.deepEqual(pin(p.file),p);inputs.set(p.file,p);return p},file=f=>add(pin(f));
const parent=read(parentFile),candidate=read(candidateFile),reference=read(referenceFile);
for(const f of [parentFile,candidateFile,referenceFile,import.meta.filename,process.execPath])file(f);
for(const receipt of [parent,candidate]){assert(receipt.checked&&receipt.complete&&receipt.status===0);receipt.inputs.forEach(add);add(receipt.api)}
assert(reference.complete);
assert(parent.inputs.some(p=>p.sha256==='1cadf44f486825a6f161ff01b15b582eca13522585deff8415d6c8c2aea7be45'));
assert(candidate.inputs.some(p=>p.sha256==='6dbd5ad7dc7022c683a4c507442acd56d9938b83dfcb0d2aff037a800e62c8c9'));
const selectionFile=path.join(root,'implementation/phase131/final/candidate.json'),selected=read(selectionFile);
file(selectionFile);assert(selected.nativeQualified);assert.deepEqual(selected.source,reference.source);
add(selected.preferredCarrierReceipt);add(selected.preferredCarrier);
const compact=read(selected.preferredCarrierReceipt.file);compact.inputs.forEach(add);
const base=compact.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));assert(base);
assert.equal(reference.cases.length,3);for(const c of reference.cases){add(c.source);add(c.expectedQbe)}
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase135-late-constructor-ownership-comparison',complete:false,rounds,rows:[],
 scope:'Three independent checked compilation routes: unchanged parent; candidate query wrapper with no attached index; candidate explicitly prepared late index. Every complete product must equal the frozen independent QBE oracle. Frontend/backend/output transport are separated. Hosted diagnostic only, not native or real-edit acceleration. The second indexed observation retains only a genuine ownership cache from the same source; index reuse and per-query savings are distinct.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
const tag=(v,t)=>{assert.equal(v?.$,t);return v};
const list=v=>{const a=[];while(v?.$==='Con'){a.push(v.head);v=v.tail}tag(v,'Nil');return a};
const text=e=>{tag(e,'P111Emission');assert.equal(e.error,'');return list(e.chunks).map(s=>s+'\n').join('')};
const elapsed=(start)=>(performance.now()-start)/1000;
const begin=performance.now();
try{
 const apis={parent:(await import(pathToFileURL(parent.api.file))).default,candidate:(await import(pathToFileURL(candidate.api.file))).default};
 const seeds={};report.basePreparationSeconds={};
 for(const key of ['parent','candidate']){const start=performance.now();seeds[key]=tag(apis[key].p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(selected.preferredCarrier.file,'utf8'),selected.preferredStamp),'P86PreparationReady').seed;report.basePreparationSeconds[key]=elapsed(start)}
 const caches=new Map();
 for(let round=0;round<rounds;round++)for(const c of (round%2?[...reference.cases].reverse():reference.cases)){
  const source=fs.readFileSync(c.source.file,'utf8'),expected=fs.readFileSync(c.expectedQbe.file,'utf8');
  const variants=round%2?['indexed','wrapper-fallback','parent']:['parent','wrapper-fallback','indexed'];
  for(const variant of variants){
   const key=variant==='parent'?'parent':'candidate',api=apis[key],whole=performance.now();
   const front=performance.now(),plan=tag(api.p86_plan(seeds[key],c.source.file,source),'P86PlanReady'),frontendSeconds=elapsed(front);
   const back=performance.now(),error=api.p111_runtime_admission(plan.request);assert.equal(error,'');
   let emission,hit=null;
   if(variant==='indexed'){
    const result=tag(api.p135co_emit(plan.request,error,caches.get(c.name)||api.p135co_empty()),'P135COEmission');
    emission=result.emission;hit=result.hit;assert.equal(typeof hit,'boolean');caches.set(c.name,result.cache);
   }else emission=api.p111_emit_admitted(plan.request,error);
   const backendSeconds=elapsed(back),wholeComputationSeconds=elapsed(whole),transport=performance.now(),output=text(emission),transportSeconds=elapsed(transport);
   assert.equal(output,expected);
   report.rows.push({round,name:c.name,variant,frontendSeconds,backendSeconds,wholeComputationSeconds,transportSeconds,indexCacheHit:hit,actual:digest(output),exactFrozen:true,complete:true});save();
  }
 }
 report.pairs=[];
 for(let round=0;round<rounds;round++)for(const c of reference.cases){
  const row=v=>report.rows.find(r=>r.round===round&&r.name===c.name&&r.variant===v),p=row('parent'),w=row('wrapper-fallback'),i=row('indexed');
  report.pairs.push({round,name:c.name,indexedOverParentBackend:i.backendSeconds/p.backendSeconds,indexedOverWrapperBackend:i.backendSeconds/w.backendSeconds,wrapperOverParentBackend:w.backendSeconds/p.backendSeconds,indexedOverParentWhole:i.wholeComputationSeconds/p.wholeComputationSeconds});
 }
 for(const p of inputs.values())add(p);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1}finally{
 report.seconds=elapsed(begin);report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();
 console.log(JSON.stringify({complete:report.complete,seconds:report.seconds,rows:report.rows.length,error:report.error}));
}
