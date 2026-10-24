// Transport and exact independent oracles only. Checked Bend executes each route.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../../..');
const [apiFile,referenceFile,outArg]=process.argv.slice(2),out=path.resolve(outArg);
assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase136/'));
const read=f=>JSON.parse(fs.readFileSync(f));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const digest=s=>({bytes:Buffer.byteLength(s),sha256:crypto.createHash('sha256').update(s).digest('hex')});
const inputs=new Map(),add=p=>{assert.deepEqual(pin(p.file),p);inputs.set(p.file,p);return p},file=f=>add(pin(f));
const receipt=read(apiFile),reference=read(referenceFile);
for(const f of [apiFile,referenceFile,import.meta.filename,process.execPath])file(f);
assert(receipt.complete&&receipt.checked&&receipt.status===0&&reference.complete);
receipt.inputs.forEach(add);add(receipt.api);
const selectedFile=path.join(root,'implementation/phase134/final/candidate.json'),selected=read(selectedFile);
file(selectedFile);assert(selected.complete&&selected.nativeQualified);
assert.equal(selected.source.sha256,'a00019246b5181b288ab4d3e09e616bd41415fe6381e89a96185c05efa19fb57');
const inherited=read(path.join(root,'implementation/phase131/final/candidate.json'));
file(path.join(root,'implementation/phase131/final/candidate.json'));
assert.deepEqual(inherited.source,reference.source);
add(inherited.preferredCarrierReceipt);add(inherited.preferredCarrier);
const carrier=read(inherited.preferredCarrierReceipt.file);carrier.inputs.forEach(add);
const base=carrier.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));assert(base);
assert.equal(reference.cases.length,3);for(const c of reference.cases){add(c.source);add(c.expectedQbe)}
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase136-uncached-stages-pure-bridge',complete:false,rows:[],refusals:[],
 scope:'Diagnostic transitions versus the unchanged qualified-core frontend and ordinary uncached backend. Complete frontend plan/request/verdict structural equality, then two complete products against independent frozen QBE. No IO execution or native timing inference.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
const tag=(v,t)=>{assert.equal(v?.$,t);return v};
const list=v=>{const a=[];while(v?.$==='Con'){a.push(v.head);v=v.tail}tag(v,'Nil');return a};
const begin=performance.now();
try{
 const api=(await import(pathToFileURL(receipt.api.file))).default;
 const prepared=tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(inherited.preferredCarrier.file,'utf8'),inherited.preferredStamp),'P86PreparationReady');
 const text=e=>{tag(e,'P111Emission');assert.equal(e.error,'');return list(e.chunks).map(s=>s+'\n').join('')};
 let last;
 for(const c of reference.cases){
  const source=fs.readFileSync(c.source.file,'utf8');
  const ordinary=tag(api.p86_plan(prepared.seed,c.source.file,source),'P86PlanReady');
  const staged=tag(api.p136s_pure_plan(prepared.seed,c.source.file,source),'P86PlanReady');
  assert.deepEqual(staged,ordinary);
  const left=text(api.p111_emit_plan(ordinary)),right=text(api.p136s_pure_backend(staged));
  const expected=fs.readFileSync(c.expectedQbe.file,'utf8');
  assert.equal(left,expected);assert.equal(right,expected);
  report.rows.push({name:c.name,output:digest(right),exactFrontendPlan:true,exactFrozenOrdinary:true,exactFrozenStaged:true,complete:true});save();last=ordinary;
 }
 for(const [name,source] of [['parse-error','import Base\n\ndef main(\n'],['type-error','import Base\n\ndef main() -> U32:\n  "wrong"\n']]){
  const target=path.join(out,name+'.bend');fs.writeFileSync(target,source);file(target);
  const ordinary=tag(api.p86_plan(prepared.seed,target,source),'P86PlanError');
  const staged=tag(api.p136s_pure_plan(prepared.seed,target,source),'P86PlanError');
  assert.deepEqual(staged,ordinary);
  assert.deepEqual(api.p136s_pure_backend(staged),api.p111_emit_plan(ordinary));
  report.refusals.push({name,error:ordinary.error,complete:true});save();
 }
 const denied='phase136-admission-refusal';
 assert.deepEqual(api.p136s_pure_emit(api.p136b_admitted(last.request,denied)),api.p111_emit_admitted(last.request,denied));
 report.refusals.push({name:'runtime-admission-short-circuit',complete:true});
 for(const p of inputs.values())add(p);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1}finally{
 report.seconds=(performance.now()-begin)/1000;report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();
 console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,refusals:report.refusals.length,seconds:report.seconds,error:report.error}));
}
