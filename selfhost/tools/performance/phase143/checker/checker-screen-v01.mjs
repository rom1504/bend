// Host observation only. All parsing/checking/scheduling/publication uses the
// pinned checked Bend API. Full result comparison is outside timed calls.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';

const [receiptArg,outArg,sizesArg='100,500,1000',secondsArg='25'] = process.argv.slice(2);
assert(receiptArg && outArg,'Usage: checker-screen-v01.mjs API_REPORT OUT [100,500,1000] [SOFT_SECONDS=25]');
const ROOT=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(!fs.existsSync(out)&&out.startsWith(ROOT+'/selfhost/build/phase143/'),'Fresh Phase143 output required');
const sizes=sizesArg.split(',').map(Number),budget=Number(secondsArg);
assert(sizes.length>0&&sizes.length<=6&&sizes.every(n=>Number.isInteger(n)&&n>0&&n<=2000));
assert(new Set(sizes).size===sizes.length&&Number.isFinite(budget)&&budget>0&&budget<=120);
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=p=>assert.deepEqual(pin(p.file),p,'Pinned input changed: '+p.file);
const rec=JSON.parse(fs.readFileSync(receiptArg));assert(rec.complete&&rec.checked&&rec.api&&Array.isArray(rec.inputs));
const required=['p143cc_many','p143cp_check','dg_check_world'];
for(const name of required)assert(rec.exports.includes(name),'Required checked export absent: '+name);
const inputs=[pin(import.meta.filename),pin(receiptArg),rec.api,...rec.inputs,pin(process.execPath)];inputs.forEach(verify);
const source=rec.inputs.find(p=>p.file.endsWith('/compiler.bend'));assert(source,'Checked compiler source pin required');
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const report={kind:'phase143-private-checker-hosted-screen',complete:false,diagnostic:true,source,api:rec.api,inputs,requestedSizes:sizes,rounds:3,softBudgetSeconds:budget,rows:[],
 scope:'One parsed synthetic book per size reused unchanged by original, schedule-only, and schedule+publication checked Bend functions. Complete DChecking comparison outside timing. JS-hosted JIT/GC-sensitive discriminator, not native or prepared-Base throughput.',
 modes:{original:'dg_check_world(book)',schedule:'p143cp_check(book,false): schedule plus original publication',publication:'p143cp_check(book,true): schedule plus private publication and final canonicalization'},
 limitations:['Soft deadline is checked between synchronous operations; external guard must enforce hard limits.','No warm-up removal, outlier rejection or forced GC. All attempts retained.','Synthetic Bit helpers do not establish actual compiler event cost or template/collision correctness.','Schedule-only plan timing is a nested diagnostic category, not additive to checking time.','Complete data equality does not require identical object-sharing topology.']};
const save=()=>{const tmp=out+'/report.json.tmp';fs.writeFileSync(tmp,JSON.stringify(report,null,2)+'\n');fs.renameSync(tmp,out+'/report.json')};save();
const start=performance.now(),elapsed=()=>(performance.now()-start)/1000;
const bounded=()=>{if(elapsed()>budget){report.stoppedForBudget=true;throw new Error('Soft time budget reached before next operation')}};
const time=f=>{const t=performance.now(),value=f();return{value,seconds:(performance.now()-t)/1000}};
function equal(a,b){
 const todo=[[a,b,'root']],seen=new WeakMap();let objects=0,values=0;
 while(todo.length){const[x,y,where]=todo.pop();if(Object.is(x,y)){values++;continue}
  assert(x!==null&&y!==null&&typeof x==='object'&&typeof y==='object','Scalar mismatch at '+where);
  assert.equal(Object.getPrototypeOf(x),Object.getPrototypeOf(y),'Prototype mismatch at '+where);
  assert([Object.prototype,Array.prototype,null].includes(Object.getPrototypeOf(x)),'Unsupported non-data object at '+where);
  let ys=seen.get(x);if(ys?.has(y))continue;if(!ys){ys=new WeakSet();seen.set(x,ys)}ys.add(y);objects++;
  const kx=Reflect.ownKeys(x),ky=Reflect.ownKeys(y);assert(kx.every(k=>typeof k==='string')&&ky.every(k=>typeof k==='string'),'Unsupported symbol keys');
  kx.sort();ky.sort();assert.deepEqual(kx,ky,'Field mismatch at '+where);
  for(const k of kx){const dx=Object.getOwnPropertyDescriptor(x,k),dy=Object.getOwnPropertyDescriptor(y,k);assert('value'in dx&&'value'in dy,'Accessor is not compiler data');todo.push([dx.value,dy.value,where.length<180?where+'.'+k:where])}
 }return{equal:true,comparedObjects:objects,comparedValues:values};
}
function snapshot(root){
 const memo=new WeakMap(),pending=[];
 const copy=x=>{if(x===null||typeof x!=='object')return x;if(memo.has(x))return memo.get(x);const proto=Object.getPrototypeOf(x);assert([Object.prototype,Array.prototype,null].includes(proto));const y=Array.isArray(x)?[]:Object.create(proto);memo.set(x,y);pending.push([x,y]);return y};
 const result=copy(root);
 while(pending.length){const[x,y]=pending.pop();for(const key of Reflect.ownKeys(x)){const d=Object.getOwnPropertyDescriptor(x,key);assert('value'in d);Object.defineProperty(y,key,{...d,value:copy(d.value)})}}
 return result;
}
const length=xs=>{let n=0;while(xs?.$==='Con'){n++;assert(n<100000);xs=xs.tail}assert.equal(xs?.$,'Nil');return n};
const median=xs=>{const a=[...xs].sort((x,y)=>x-y);return a[Math.floor(a.length/2)]};
try{
 const api=(await import(pathToFileURL(rec.api.file))).default;
 for(const name of required)assert.equal(typeof api[name],'function',name);
 report.bendFullComparatorAvailable=typeof api.p140ce_checked==='function';
 report.scheduleObserverAvailable=typeof api.p143cs_plan==='function'&&typeof api.p143cc_schedule==='function';
 for(const n of sizes){
  bounded();const row={n,complete:false,fixture:'p143cc_many('+n+')',rounds:[]};report.rows.push(row);report.activeOperation={n,mode:'parse'};save();
  const prepared=time(()=>api.p143cc_many(n));assert.equal(prepared.value?.$,'FResult');assert.equal(prepared.value.error,'');
  const book=prepared.value.book,bookSnapshot=snapshot(book);row.parseSeconds=prepared.seconds;row.declarations=length(book);assert.equal(row.declarations,n+1);
  if(report.scheduleObserverAvailable){bounded();report.activeOperation={n,mode:'schedule-plan-only'};save();const plan=time(()=>api.p143cs_plan(book));row.schedulePlanSeconds=plan.seconds;assert.equal(api.p143cc_schedule(book,plan.value),true);row.exactSuffixSchedule=true}
  const modes=['original','schedule','publication'];
  for(let round=0;round<3;round++){
   const order=modes.slice(round).concat(modes.slice(0,round)),r={round,order,calls:[],complete:false};row.rounds.push(r);const results={};
   for(const mode of order){bounded();const call={mode,complete:false};r.calls.push(call);report.activeOperation={n,round,mode};save();
    const got=time(()=>mode==='original'?api.dg_check_world(book):api.p143cp_check(book,mode==='publication'));
    call.seconds=got.seconds;results[mode]=got.value;assert.equal(got.value?.$,'DChecking');assert.equal(got.value.result.error,'','Synthetic checker failed: '+mode);call.complete=true;save();
   }
   const checkStart=performance.now();r.fullState={schedule:equal(results.schedule,results.original),publication:equal(results.publication,results.original)};
   if(report.bendFullComparatorAvailable){assert.equal(api.p140ce_checked(results.schedule,results.original),true);assert.equal(api.p140ce_checked(results.publication,results.original),true);r.bendFullState=true}
   r.inputUnchanged=equal(book,bookSnapshot);r.comparisonSeconds=(performance.now()-checkStart)/1000;r.complete=true;save();
  }
  row.medians=Object.fromEntries(modes.map(mode=>[mode,median(row.rounds.flatMap(r=>r.calls.filter(c=>c.mode===mode).map(c=>c.seconds)))]));
  row.ratios={scheduleOverOriginal:row.medians.schedule/row.medians.original,publicationOverSchedule:row.medians.publication/row.medians.schedule,publicationOverOriginal:row.medians.publication/row.medians.original};
  row.complete=true;save();console.log(JSON.stringify({n,medians:row.medians,ratios:row.ratios,fullState:true}));
 }
 inputs.forEach(verify);report.activeOperation=null;report.complete=true;
}catch(error){report.error=String(error.stack||error);process.exitCode=report.stoppedForBudget?2:1}
finally{report.totalObservedSeconds=elapsed();report.peakHostedProcessRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,stoppedForBudget:report.stoppedForBudget,rows:report.rows.map(r=>({n:r.n,complete:r.complete,ratios:r.ratios})),error:report.error}))}
