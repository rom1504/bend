// Transport/oracles only. Both composition routes execute checked Bend helpers.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../../..');
const [apiFile,referenceFile,outArg]=process.argv.slice(2),out=path.resolve(outArg);
assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase135/'));
const read=f=>JSON.parse(fs.readFileSync(f));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const digest=s=>({bytes:Buffer.byteLength(s),sha256:crypto.createHash('sha256').update(s).digest('hex')});
const inputs=new Map(),add=p=>{assert.deepEqual(pin(p.file),p);inputs.set(p.file,p);return p},file=f=>add(pin(f));
const receipt=read(apiFile),reference=read(referenceFile);
file(apiFile);file(referenceFile);file(import.meta.filename);file(process.execPath);
assert(receipt.complete&&receipt.checked&&receipt.status===0&&reference.complete);
receipt.inputs.forEach(add);add(receipt.api);
const selectionFile=path.join(root,'implementation/phase131/final/candidate.json'),selected=read(selectionFile);
file(selectionFile);assert(selected.nativeQualified);assert.deepEqual(selected.source,reference.source);
add(selected.preferredCarrierReceipt);add(selected.preferredCarrier);
const compact=read(selected.preferredCarrierReceipt.file);compact.inputs.forEach(add);
const base=compact.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));assert(base);
const cases=reference.cases.filter(c=>['lexer','coverage-closures-256'].includes(c.name));assert.equal(cases.length,2);
for(const c of cases){add(c.source);add(c.expectedQbe)}
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase135-native-stage-pure-composition-bridge',complete:false,rows:[],refusals:[],
 scope:'The exact pure factory/completion used by the new IO clock route versus unchanged p134ns_planned, for A and a real edited B with each route retaining its own genuine cache. Frozen old QBE and fresh independently compiled edited QBE are oracles. No native timing claim; IO boundaries require later native smoke checks.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
const tag=(v,t)=>{assert.equal(v?.$,t);return v};
const list=v=>{const a=[];while(v?.$==='Con'){a.push(v.head);v=v.tail}tag(v,'Nil');return a};
const empty=()=>({$:'P134UCache',inline:{$:'Nil'},ranges:{$:'Nil'}});
const begin=performance.now();
try{
 const api=(await import(pathToFileURL(receipt.api.file))).default;
 const prepared=tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(selected.preferredCarrier.file,'utf8'),selected.preferredStamp),'P86PreparationReady');
 const text=e=>{const result=tag(api.p134e_collect(e),'P111Emission');assert.equal(result.error,'');return list(result.chunks).map(s=>s+'\n').join('')};
 let lastPlan,lastCache;
 for(const c of cases){
  const source=fs.readFileSync(c.source.file,'utf8');
  const needle=c.name==='lexer'?'U32.shln(x, 13n)':'bench(256, 123)',replacement=c.name==='lexer'?'U32.shln(x, 12n)':'bench(256, 124)';
  assert.equal(source.split(needle).length,2);const edited=source.replace(needle,replacement),editFile=path.join(out,c.name+'-edited.bend');
  fs.writeFileSync(editFile,edited);file(editFile);
  const a=tag(api.p86_plan(prepared.seed,c.source.file,source),'P86PlanReady');
  const b=tag(api.p86_plan(prepared.seed,c.source.file,edited),'P86PlanReady');
  const old=tag(api.p134ns_planned(a,empty()),'P134UEmission');
  const next=tag(api.p135t_pure_plan(a,empty()),'P134UEmission');
  assert.deepEqual(next.stats,old.stats);assert.deepEqual(next.cache,old.cache);
  const oldText=text(old.emission),nextText=text(next.emission),frozen=fs.readFileSync(c.expectedQbe.file,'utf8');
  assert.equal(oldText,frozen);assert.equal(nextText,frozen);
  const beforeB=tag(api.p134ns_planned(b,old.cache),'P134UEmission');
  const afterB=tag(api.p135t_pure_plan(b,next.cache),'P134UEmission');
  assert.deepEqual(afterB.stats,beforeB.stats);assert.deepEqual(afterB.cache,beforeB.cache);
  const beforeText=text(beforeB.emission),afterText=text(afterB.emission);
  const fresh=text(api.p111_emit_admitted(b.request,api.p111_runtime_admission(b.request)));
  assert.equal(beforeText,fresh);assert.equal(afterText,fresh);assert.notEqual(fresh,frozen);
  report.rows.push({name:c.name,edit:{needle,replacement,source:pin(editFile)},oldOutput:digest(oldText),editedOutput:digest(fresh),oldStats:list(old.stats),editedStats:list(afterB.stats),exactFrozenOld:true,exactFreshEdited:true,exactReturnedCaches:true,complete:true});save();
  lastPlan=b;lastCache=afterB.cache;
 }
 for(const [name,cache] of [['empty-cache',empty()],['actual-returned-cache',lastCache]]){
  const errorPlan={$:'P86PlanError',error:'phase135-stage-bridge-refusal'};
  assert.deepEqual(api.p135t_pure_plan(errorPlan,cache),api.p134ns_planned(errorPlan,cache));
  report.refusals.push({name:'plan-error-'+name,complete:true});
 }
 const denied='phase135-stage-bridge-admission-refusal';
 assert.deepEqual(api.p135t_result(api.p135t_prepare(lastPlan.request,denied,lastCache)),api.p134u_request(lastPlan.request,denied,lastCache));
 report.refusals.push({name:'nonempty-admission-preserves-original-short-circuit',complete:true});
 for(const p of inputs.values())add(p);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1}finally{
 report.seconds=(performance.now()-begin)/1000;report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();
 console.log(JSON.stringify({complete:report.complete,seconds:report.seconds,rows:report.rows.length,refusals:report.refusals.length,error:report.error}));
}
