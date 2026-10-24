// Checked Bend owns all transformations; this driver measures complete requests.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../../..');
const [apiFile,referenceFile,outArg]=process.argv.slice(2),out=path.resolve(outArg);
assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase134/'));
const read=f=>JSON.parse(fs.readFileSync(f));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const digest=s=>({bytes:Buffer.byteLength(s),sha256:crypto.createHash('sha256').update(s).digest('hex')});
const inputs=new Map(),add=p=>{assert.deepEqual(pin(p.file),p);inputs.set(p.file,p);return p},file=f=>add(pin(f));
const ar=read(apiFile),reference=read(referenceFile);file(apiFile);file(referenceFile);file(import.meta.filename);file(process.execPath);assert(ar.checked&&ar.complete&&reference.complete);ar.inputs.forEach(add);add(ar.api);
const selectedFile=path.join(root,'implementation/phase131/final/candidate.json'),selected=read(selectedFile);file(selectedFile);assert(selected.nativeQualified);assert.deepEqual(selected.source,reference.source);
add(selected.preferredCarrierReceipt);add(selected.preferredCarrier);const compact=read(selected.preferredCarrierReceipt.file);compact.inputs.forEach(add);const base=compact.inputs.find(x=>x.file.endsWith('/bend2/base.bend'));assert(base);
for(const c of reference.cases){add(c.source);add(c.expectedQbe);}
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase134-exact-inner-range-reuse-screen',complete:false,rows:[],scope:'Hosted one-pair screen per family. Baseline already includes verified-function reuse. Candidate adds exact inner-range input/output memo reuse; all products must match independently frozen native QBE. Census runs separately and is charged in total experimental cost. No native or cross-revision cache speedup claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
const tag=(v,n)=>{assert.equal(v?.$,n);return v};
const list=v=>{const a=[];while(v?.$==='Con'){a.push(v.head);v=v.tail}tag(v,'Nil');return a};
const text=e=>{tag(e,'P111Emission');assert.equal(e.error,'');return list(e.chunks).map(x=>x+'\n').join('')};
const timed=f=>{const s=performance.now(),result=f();return{result,seconds:(performance.now()-s)/1000}};
const begin=performance.now();
try{
 const api=(await import(pathToFileURL(ar.api.file))).default;
 const prep=tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(selected.preferredCarrier.file,'utf8'),selected.preferredStamp),'P86PreparationReady');
 for(const [i,c] of reference.cases.entries()){
  const req=tag(api.p86_plan(prep.seed,c.source.file,fs.readFileSync(c.source.file,'utf8')),'P86PlanReady').request;assert.equal(api.p111_runtime_admission(req),'');
  let before,after;if(i%2){after=timed(()=>api.p134rk_emit(req,''));before=timed(()=>api.p111_emit_admitted(req,''));}
  else{before=timed(()=>api.p111_emit_admitted(req,''));after=timed(()=>api.p134rk_emit(req,''));}
  const expected=fs.readFileSync(c.expectedQbe.file,'utf8'),baseline=text(before.result),actual=text(after.result);assert.equal(baseline,expected);assert.equal(actual,expected);
  const census=timed(()=>{const raw=tag(api.p128raw_lower_request(req),'P128RawLowering');const open=tag(api.p114s_open_lowered(raw.lowered),'P114SLowered');return api.p134rk_counts(api.p134rk_inline(open.boundary));});
  report.rows.push({name:c.name,order:i%2?'range-reuse/verification-only':'verification-only/range-reuse',verificationOnlySeconds:before.seconds,rangeReuseSeconds:after.seconds,ratio:after.seconds/before.seconds,exactFrozenOutput:true,output:digest(actual),counts:list(census.result),censusSeconds:census.seconds});save();
 }
 for(const p of inputs.values())add(p);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}finally{report.seconds=(performance.now()-begin)/1000;report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,rows:report.rows,error:report.error}));}
