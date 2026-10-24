// Host supplies exact files and serializes counters. All query semantics,
// row selection and instrumentation execute in the checked Bend module.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../../..');
const [apiFile,referenceFile,outArg]=process.argv.slice(2),out=path.resolve(outArg);
assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase136/'));
const pin=f=>{f=path.resolve(f);const d=fs.readFileSync(f);return {file:f,bytes:d.length,sha256:crypto.createHash('sha256').update(d).digest('hex')}};
const read=f=>JSON.parse(fs.readFileSync(f));
const inputs=new Map(),add=p=>{assert.deepEqual(pin(p.file),p);inputs.set(p.file,p);return p};
const receipt=read(apiFile),reference=read(referenceFile);
assert(receipt.complete&&receipt.checked&&receipt.status===0&&reference.complete);
for(const f of [apiFile,referenceFile,import.meta.filename,process.execPath])add(pin(f));
receipt.inputs.forEach(add);add(receipt.api);
assert(receipt.inputs.some(p=>p.sha256==='c1e89dfd6b664da0634995f4e305e027ade0ddf1aaa747269227fcc46fb1930a'));
const selected=read(path.join(root,'implementation/phase134/final/candidate.json'));
add(pin(path.join(root,'implementation/phase134/final/candidate.json')));add(selected.preferredCarrierReceipt);add(selected.preferredCarrier);
const carrier=read(selected.preferredCarrierReceipt.file);carrier.inputs.forEach(add);
const base=carrier.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));assert(base);add(base);
const tag=(x,t)=>{assert.equal(x?.$,t);return x};
const list=x=>{const r=[];while(x?.$==='Con'){r.push(x.head);x=x.tail}tag(x,'Nil');return r};
const report={kind:'phase136-checked-query-scaling-census',complete:false,rows:[],
 scope:'Logical list visits on actual source/erased KDef books from three checked requests. Appended Bend wrappers preserve original query outputs. Diagnostic wrappers and equivalence checks add work: elapsed time is diagnostic cost, not candidate performance or measured whole-request call frequency. Delegated index work is opaque and explicitly counted; absence of list visits is not zero cost.'};
fs.mkdirSync(out);const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();const begin=performance.now();
try{
 const api=(await import(pathToFileURL(receipt.api.file))).default;
 report.controls=list(api.p136q_controls());assert.equal(report.controls.length,14);assert(report.controls.every(s=>s.startsWith('PASS ')));
 const seed=tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(selected.preferredCarrier.file,'utf8'),selected.preferredStamp),'P86PreparationReady').seed;
 for(const c of reference.cases){
  add(c.source);const plan=tag(api.p86_plan(seed,c.source.file,fs.readFileSync(c.source.file,'utf8')),'P86PlanReady');
  for(const role of ['source','book']){
   const book=plan.request[role],raw=api.p136q_raw(book);const sizes=[16,64,256];
   for(const size of sizes){
    const result=tag(api.p136q_prefix(raw,size),'P136QSummary');assert.equal(result.exact,true);
    report.rows.push({case:c.name,book:role,querySet:'all names in actual raw prefix',prefixLimit:size,result});save();
   }
   const names=api.p136q_take_names(api.p136q_ctor_names(raw,{$:'Nil'}),16);
   for(const policy of ['raw','actual']){
    const result=tag(api.p136q_queries(policy==='raw'?raw:book,names,api.p136q_zero()),'P136QSummary');assert.equal(result.exact,true);
    report.rows.push({case:c.name,book:role,querySet:'first16 actual direct constructor names',bookPolicy:policy,names:list(names),result});save();
   }
  }
 }
 for(const p of inputs.values())add(p);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1}
finally{report.seconds=(performance.now()-begin)/1000;report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,seconds:report.seconds,error:report.error}));}
