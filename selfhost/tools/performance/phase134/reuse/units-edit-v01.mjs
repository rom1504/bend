// Trusted returned cache only; checked Bend owns keys, transforms and verifiers.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../../..');
const [apiFile,referenceFile,outArg,family='lexer',roundsArg='2']=process.argv.slice(2),out=path.resolve(outArg),rounds=Number(roundsArg);
assert(['lexer','coverage-map-churn-128'].includes(family));assert(Number.isInteger(rounds)&&rounds>=1&&rounds<=2);
assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase134/'));
const read=f=>JSON.parse(fs.readFileSync(f));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const digest=s=>({bytes:Buffer.byteLength(s),sha256:crypto.createHash('sha256').update(s).digest('hex')});
const inputs=new Map(),add=p=>{assert.deepEqual(pin(p.file),p);inputs.set(p.file,p);return p},file=f=>add(pin(f));
const ar=read(apiFile),reference=read(referenceFile);file(apiFile);file(referenceFile);file(import.meta.filename);file(process.execPath);assert(ar.checked&&ar.complete&&reference.complete);ar.inputs.forEach(add);add(ar.api);
const selectedFile=path.join(root,'implementation/phase131/final/candidate.json'),selected=read(selectedFile);file(selectedFile);assert(selected.nativeQualified);assert.deepEqual(selected.source,reference.source);
add(selected.preferredCarrierReceipt);add(selected.preferredCarrier);const compact=read(selected.preferredCarrierReceipt.file);compact.inputs.forEach(add);const base=compact.inputs.find(x=>x.file.endsWith('/bend2/base.bend'));assert(base);
const sample=reference.cases.find(c=>c.name===family);assert(sample);add(sample.source);add(sample.expectedQbe);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase134-cross-edit-optimization-unit-cache',complete:false,family,rounds,rows:[],
 scope:'Hosted complete checked-backend requests. Baseline already includes same-request verification reuse. Candidate caches actual inline/range transforms across revisions under exact original IR and consumed full/absent callee facts. Fresh independent QBE is authoritative. Both source revisions are parsed/checked again. No native, persistent, untrusted-artifact or compiler-self-build speedup claim.',
 statsFields:['inlineHits','inlineMisses','priorRangeHits','sameRequestRangeHits','rangeMisses'],apiAcquisitionSeconds:ar.seconds};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
const tag=(v,n)=>{assert.equal(v?.$,n,JSON.stringify({expected:n,actual:v?.$,error:v?.error}));return v};
const list=v=>{const a=[];while(v?.$==='Con'){a.push(v.head);v=v.tail}tag(v,'Nil');return a};
const text=e=>{tag(e,'P111Emission');assert.equal(e.error,'');return list(e.chunks).map(x=>x+'\n').join('')};
const timed=f=>{const s=performance.now(),result=f();return{result,seconds:(performance.now()-s)/1000}};
const empty=()=>({$:'P134UCache',inline:{$:'Nil'},ranges:{$:'Nil'}});
const census=value=>{const seen=new Set(),todo=[value];let fields=0,stringPropertyBytes=0;while(todo.length){const v=todo.pop();if(v===null||typeof v!=='object'||seen.has(v))continue;seen.add(v);for(const x of Object.values(v)){fields++;if(typeof x==='string')stringPropertyBytes+=Buffer.byteLength(x);else if(x!==null&&typeof x==='object')todo.push(x);}}return{uniqueHostObjects:seen.size,fields,stringPropertyBytes,scope:'Identity-aware graph census, not native heap bytes or a serialized cache format.'}};
const begin=performance.now();
try{
 const api=(await import(pathToFileURL(ar.api.file))).default;
 const prepared=timed(()=>api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(selected.preferredCarrier.file,'utf8'),selected.preferredStamp));
 const prep=tag(prepared.result,'P86PreparationReady');report.basePreparationSeconds=prepared.seconds;
 const original=fs.readFileSync(sample.source.file,'utf8');
 const needle=family==='lexer'?'U32.shln(x, 13n)':'U32.mul(i, 31)',replacement=family==='lexer'?'U32.shln(x, 12n)':'U32.mul(i, 29)';
 assert.equal(original.split(needle).length,2);const edited=original.replace(needle,replacement),editFile=path.join(out,'edited.bend');fs.writeFileSync(editFile,edited);file(editFile);
 report.edit={needle,replacement,semanticPath:sample.source.file,original:sample.source,edited:pin(editFile)};
 const pa=timed(()=>api.p86_plan(prep.seed,sample.source.file,original)),pb=timed(()=>api.p86_plan(prep.seed,sample.source.file,edited));
 const old=tag(pa.result,'P86PlanReady').request,current=tag(pb.result,'P86PlanReady').request;
 assert.equal(api.p111_runtime_admission(old),'');assert.equal(api.p111_runtime_admission(current),'');
 report.frontendOldSeconds=pa.seconds;report.frontendEditedSeconds=pb.seconds;save();
 for(let round=0;round<rounds;round++){
  let freshOld,cold,warm,freshEdited;
  if(round%2){cold=timed(()=>api.p134u_request(old,'',empty()));freshOld=timed(()=>api.p111_emit_admitted(old,''));}
  else{freshOld=timed(()=>api.p111_emit_admitted(old,''));cold=timed(()=>api.p134u_request(old,'',empty()));}
  tag(cold.result,'P134UEmission');tag(cold.result.cache,'P134UCache');
  if(round%2){warm=timed(()=>api.p134u_request(current,'',cold.result.cache));freshEdited=timed(()=>api.p111_emit_admitted(current,''));}
  else{freshEdited=timed(()=>api.p111_emit_admitted(current,''));warm=timed(()=>api.p134u_request(current,'',cold.result.cache));}
  tag(warm.result,'P134UEmission');
  const oldText=text(freshOld.result),coldText=text(cold.result.emission),freshText=text(freshEdited.result),warmText=text(warm.result.emission);
  assert.equal(oldText,fs.readFileSync(sample.expectedQbe.file,'utf8'));assert.equal(coldText,oldText);assert.equal(warmText,freshText);assert.notEqual(warmText,oldText);
  const front=pa.seconds+pb.seconds,row={round,order:round%2?'cache-first':'fresh-first',freshOldSeconds:freshOld.seconds,coldCacheSeconds:cold.seconds,warmCacheSeconds:warm.seconds,freshEditedSeconds:freshEdited.seconds,
   warmRatio:warm.seconds/freshEdited.seconds,coldRatio:cold.seconds/freshOld.seconds,
   twoRevisionFreshSeconds:front+freshOld.seconds+freshEdited.seconds,twoRevisionCachedSeconds:front+cold.seconds+warm.seconds,
   coldStats:list(cold.result.stats),warmStats:list(warm.result.stats),exactFrozenOld:true,exactIndependentEdited:true,oldOutput:digest(oldText),editedOutput:digest(warmText),
   oldCache:census(cold.result.cache),newCache:census(warm.result.cache)};
  row.twoRevisionRatio=row.twoRevisionCachedSeconds/row.twoRevisionFreshSeconds;report.rows.push(row);save();console.log(JSON.stringify(row));
 }
 for(const p of inputs.values())add(p);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}finally{report.seconds=(performance.now()-begin)/1000;report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,seconds:report.seconds,error:report.error}));}
