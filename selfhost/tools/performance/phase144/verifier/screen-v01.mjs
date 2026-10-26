// Observer: checked Bend alone prepares and validates real IR. Hosted timings
// are a falsifier, not native teardown/ownership measurements.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [receiptArg,outArg,...names]=process.argv.slice(2);
assert(receiptArg&&outArg,'Usage: screen-v01.mjs API_REPORT FRESH_PHASE144_OUT [FAMILIES...]');
const ROOT=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(!fs.existsSync(out)&&out.startsWith(ROOT+'/selfhost/build/phase144/'));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const read=f=>JSON.parse(fs.readFileSync(f)),verify=p=>assert.deepEqual(pin(p.file),p);
const rec=read(receiptArg),selection=ROOT+'/implementation/phase143/candidate.json',selected=read(selection);
const refsFile=ROOT+'/selfhost/build/phase134/reference03.json',refs=read(refsFile),carrier=read(selected.preferredCarrierReceipt.file);
const base=carrier.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));assert(base);
assert(rec.complete&&rec.checked&&refs.complete&&selected.nativeQualified);
const required=['p88_cache_prepare','p86_plan','p140or_lower','p140or_empty','p111_verify_program','p144v_verify_program'];
for(const name of required)assert(rec.exports.includes(name),name);
const inputs=[pin(import.meta.filename),pin(receiptArg),rec.api,...rec.inputs,pin(selection),pin(refsFile),pin(selected.preferredCarrierReceipt.file),base,selected.preferredCarrier,pin(process.execPath)];inputs.forEach(verify);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const report={kind:'phase144-complete-real-raw-verifier-screen',complete:false,diagnostic:true,inputs,rows:[],scope:'Entire checked raw verifier on independently prepared real programs, including function/constructor metadata tables, local schema construction, statement flow, branch joins and returned errors. JIT/GC-sensitive hosted observations do not establish native reclamation cost, complete request gain, final-verifier replacement or promotion.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
const tag=(v,k)=>{assert.equal(v?.$,k,JSON.stringify({expected:k,actual:v?.$,error:v?.error}));return v};
const arr=l=>{const a=[];while(l.$==='Con'){a.push(l.head);l=l.tail}tag(l,'Nil');return a};
const time=f=>{const s=performance.now(),value=f();return{value,seconds:(performance.now()-s)/1000}};
const median=a=>[...a].sort((x,y)=>x-y)[Math.floor(a.length/2)];
const start=performance.now();
const checkBudget=()=>assert((performance.now()-start)<90000,'90s observer soft budget; external guard remains required');
function census(program){let statements=0,joins=0;const segments=arr(program.segments),todo=segments.flatMap(s=>arr(s.body));while(todo.length){const s=todo.pop();statements++;if(s.$==='N111If'){joins++;todo.push(...arr(s.yes),...arr(s.no))}}return{segments:segments.length,constructors:arr(program.constructors).length,statements,joins}}
try{
 const api=(await import(pathToFileURL(rec.api.file))).default;
 const preparation=time(()=>tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(selected.preferredCarrier.file,'utf8'),selected.preferredStamp),'P86PreparationReady').seed);
 report.basePreparationSeconds=preparation.seconds;
 for(const name of names.length?names:['lexer','coverage-map-churn-128','coverage-closures-256']){
  checkBudget();const fixture=refs.cases.find(x=>x.name===name);assert(fixture);verify(fixture.source);verify(fixture.expectedQbe);inputs.push(fixture.source,fixture.expectedQbe);
  const front=time(()=>tag(api.p86_plan(preparation.value,fixture.source.file,fs.readFileSync(fixture.source.file,'utf8')),'P86PlanReady'));
  const lower=time(()=>tag(api.p140or_lower(front.value.request,api.p140or_empty()),'P140ORResult'));
  assert.equal(lower.value.lowering.lowered.error,'');
  const program=tag(lower.value.lowering.lowered.program.original.program,'P111Program');
  const row={name,frontendSeconds:front.seconds,rawPreparationSeconds:lower.seconds,census:census(program),rounds:[]};report.rows.push(row);save();
  // Preserve exact data for an eventual native full-function test. This host
  // serializes accepted IR; it never implements verification or lowering.
  const data=out+'/'+name+'-raw.json';fs.writeFileSync(data,JSON.stringify(program)+'\n');row.raw=pin(data);save();
  for(let round=0;round<3;round++){
   const order=round%2?['candidate','original']:['original','candidate'],r={round,order,calls:[]};row.rounds.push(r);
   for(const mode of order){checkBudget();const call=time(()=>mode==='candidate'?api.p144v_verify_program(program):api.p111_verify_program(program));assert.equal(call.value,'',name+' '+mode);r.calls.push({mode,seconds:call.seconds,error:call.value});save()}
  }
  row.medians=Object.fromEntries(['original','candidate'].map(mode=>[mode,median(row.rounds.flatMap(r=>r.calls.filter(x=>x.mode===mode).map(x=>x.seconds)))]));
  row.ratio=row.medians.candidate/row.medians.original;row.complete=true;save();console.log(JSON.stringify(row));
 }
 inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1}
finally{report.totalObservedSeconds=(performance.now()-start)/1000;report.peakHostedRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}))}
