// Observe checked Bend exports. No host-side checking, admission or lowering.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const ROOT=path.resolve(import.meta.dirname,'../../../../..');
const [receiptArg,outArg]=process.argv.slice(2),out=path.resolve(outArg);
assert(receiptArg&&!fs.existsSync(out)&&out.startsWith(ROOT+'/selfhost/build/phase143/'));
const read=f=>JSON.parse(fs.readFileSync(f));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const inputs=new Map(),add=p=>{assert.deepEqual(pin(p.file),p);inputs.set(p.file,p);return p};
const file=f=>add(pin(f));
const receipt=read(receiptArg),carrierPath=ROOT+'/selfhost/build/phase130/base-carrier01/receipt.json';
const carrier=read(carrierPath),refsPath=ROOT+'/selfhost/build/phase134/reference03.json',refs=read(refsPath);
assert(receipt.complete&&receipt.checked&&carrier.complete&&refs.complete);
for(const f of [import.meta.filename,process.execPath,receiptArg,carrierPath,refsPath])file(f);
receipt.inputs.forEach(add);add(receipt.api);carrier.inputs.forEach(add);add(carrier.carrier);
const base=carrier.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));assert(base);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const report={kind:'phase143-prepared-checker-screen',complete:false,controls:[],rows:[],
 scope:'Actual authenticated Base and unedited frozen Lexer/Map/closures sources. Checked Bend executes original, scheduled and deferred-publication checking. Complete DChecking and DResult comparison; hosted timings only. Private loads are reconstructed without prior revision state.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');
const tag=(v,t)=>{assert.equal(v?.$,t,JSON.stringify({expected:t,actual:v?.$,error:v?.error}));return v};
const list=v=>{const a=[];while(v?.$==='Con'){a.push(v.head);assert(a.length<100000);v=v.tail}tag(v,'Nil');return a};
const timed=f=>{const t=performance.now(),value=f();return{value,seconds:(performance.now()-t)/1000}};
const begin=performance.now();save();
try{
 const api=(await import(pathToFileURL(receipt.api.file))).default;
 const preparation=timed(()=>tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(carrier.carrier.file,'utf8'),carrier.stamp),'P86PreparationReady'));
 report.baseSeconds=preparation.seconds;const seed=preparation.value.seed;
 report.controls=list(api.p143cbc_controls(seed));assert.equal(report.controls.length,10);save();
 assert(report.controls.every(r=>/^[^\n]+:pass$/.test(r)),JSON.stringify(report.controls.filter(r=>!r.endsWith(':pass'))));
 for(const name of ['lexer','coverage-map-churn-128','coverage-closures-256']){
  const reference=refs.cases.find(r=>r.name===name);assert(reference);add(reference.source);add(reference.expectedQbe);
  const parsed=timed(()=>tag(api.p140pl_load(seed,reference.source.file,fs.readFileSync(reference.source.file,'utf8'),{$:'None'},0),'P140PLoadReady'));
  const load=parsed.value.load,route=api.p143cbc_route(seed.world,load),row={name,source:reference.source,parseSeconds:parsed.seconds,route,rounds:[],complete:false};report.rows.push(row);save();
  assert.equal(route,1,'Real workload must exercise the optimized checker');
  const modes=['original','schedule','publication'];
  for(let round=0;round<3;round++){
   const order=modes.slice(round).concat(modes.slice(0,round)),results={},calls=[];
   for(const mode of order){const r=timed(()=>mode==='original'?api.base_prefix_check_world_load(seed.world,load):api.p143cb_check_load(seed.world,load,mode==='publication'));results[mode]=r.value;calls.push({mode,seconds:r.seconds});}
   assert.equal(api.p140ce_checked(results.original,results.schedule),true);
   assert.equal(api.p140ce_checked(results.original,results.publication),true);
   tag(results.original,'DChecking');assert.equal(results.original.result.error,'');
   row.rounds.push({round,order,calls,completeStateEqual:true,successful:true});save();
  }
  const before=api.check_program_diagnostic_world(load,{$:'Nil'},seed.world);
  const after=api.p143cb_program(load,{$:'Nil'},seed.world,true);
  assert.equal(api.p140ce_result(before,after),true);tag(before,'DResult');assert.equal(before.error,'');
  row.finalizedResultEqual=true;row.complete=true;save();
 }
 for(const p of inputs.values())add(p);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1}
finally{report.seconds=(performance.now()-begin)/1000;report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,controls:report.controls.length,rows:report.rows.length,error:report.error}));}
