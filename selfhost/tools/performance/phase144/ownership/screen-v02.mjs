// Checked Bend owns all preparation, queries, erasure and catalogue generation.
// Host code only pins, observes, compares complete data and schedules measurements.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const ROOT=path.resolve(import.meta.dirname,'../../../../..');
const [receiptArg,outArg]=process.argv.slice(2);
assert(receiptArg&&outArg,'API_REPORT FRESH_PHASE144_OUT');
const out=path.resolve(outArg);assert(!fs.existsSync(out)&&out.startsWith(ROOT+'/selfhost/build/phase144/'));
const read=f=>JSON.parse(fs.readFileSync(f,'utf8'));
const pin=f=>{f=fs.realpathSync(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const inputs=new Map(),add=p=>{assert.deepEqual(pin(p.file),p);const prior=inputs.get(p.file);if(prior)assert.deepEqual(prior,p);inputs.set(p.file,p);return p};
const file=f=>add(pin(f));
const tag=(v,k)=>{assert.equal(v?.$,k,JSON.stringify({expected:k,actual:v?.$,error:v?.error}));return v};
const list=l=>{const out=[];while(l?.$==='Con'){assert(out.length<100000);out.push(l.head);l=l.tail}tag(l,'Nil');return out};
const time=f=>{const start=performance.now(),value=f();return{value,seconds:(performance.now()-start)/1000}};
const median=xs=>[...xs].sort((a,b)=>a-b)[Math.floor(xs.length/2)];
const rec=read(receiptArg),selectionFile=ROOT+'/implementation/phase143/candidate.json',selection=read(selectionFile);
const refsFile=ROOT+'/selfhost/build/phase134/reference03.json',refs=read(refsFile),carrier=read(selection.preferredCarrierReceipt.file);
assert(rec.complete&&rec.checked&&selection.nativeQualified&&carrier.complete&&refs.complete);
const required=['p88_cache_prepare','p86_plan','p144o_controls','p144o_build','p144o_index','missing','p144ow_names',
 'p144ot_original_batch','p144ot_list_batch','p144ot_index_batch','p144o_original_constructors','p144o_constructors',
 'p144o_prepare_annotated','p144o_payload','p144ow_original','p144ow_list','p144ow_index'];
for(const name of required)assert(rec.exports.includes(name),'Missing checked export '+name);
for(const f of [import.meta.filename,process.execPath,receiptArg,selectionFile,refsFile,selection.preferredCarrierReceipt.file])file(f);
rec.inputs.forEach(add);add(rec.api);carrier.inputs.forEach(add);add(selection.preferredCarrier);
const base=carrier.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));assert(base);add(base);
assert.equal(typeof Bun.gc,'function','Synchronous hosted cleanup observation requires Bun.gc');
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const started=performance.now(),budgetSeconds=150;
const report={kind:'phase144-real-constructor-ownership-screen',complete:false,rows:[],controls:[],budgetSeconds,
 scope:'One checked API; unchanged frozen Lexer/Map/closures through real prepared-Base p86_plan. Complete ownership Bool vectors and constructor catalogues, early prepared-request equivalence except one authenticated metadata field. Build/use checksum kernels with one/four/sixteen full catalogue-name sweeps. No host checking/lowering, native teardown, integrated QBE or qualification claim.',
 limitations:['Four/sixteen sweeps are hypothetical reuse sensitivities, not observed compiler query counts. One sweep is the actual constructor-catalogue name list, including repetitions.',
 'All temporary summary construction is inside each kernel invocation. Forced synchronous Bun GC after each batch is reported separately and charged in inclusive totals; it is not Bend native reference-count teardown.',
 'API03 leaves nc_ctor_owned unchanged. Early-view erasure checks carrier and existing constructor-index behavior but does not exercise the optional optimized ownership override. Full integrated QBE remains required.',
 'Three rotated orders are a bounded screen, not confidence intervals. JIT/GC and sub-20ms batches can limit inference. All observations and calibration costs are retained.']};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
const budget=()=>assert((performance.now()-started)/1000<budgetSeconds,'Observer soft budget; external guard required');
function exact(a,b){
 const todo=[[a,b,'root']],seen=new WeakMap();let objects=0,scalars=0;
 while(todo.length){const[x,y,at]=todo.pop();if(Object.is(x,y))continue;
  if(!x||!y||typeof x!=='object'||typeof y!=='object'){assert(Object.is(x,y),at+' scalar mismatch');scalars++;continue}
  assert.equal(Array.isArray(x),Array.isArray(y),at);let set=seen.get(x);if(set?.has(y))continue;
  if(!set){set=new WeakSet();seen.set(x,set)}set.add(y);assert(++objects<=1000000,'Graph comparison bound');
  const keys=Object.keys(x).sort();assert.deepEqual(keys,Object.keys(y).sort(),at);
  for(const k of keys)todo.push([x[k],y[k],at.length<120?at+'.'+k:k]);
 }return{exact:true,objectPairs:objects,scalarChecks:scalars};
}
function nativeContext(book){
 const root=tag(book,'Con'),head=tag(root.head,'KDef');assert.equal(head.kind,'BookCache');
 const children=tag(head.ctors,'Con'),contextCell=tag(children.tail,'Con'),context=tag(contextCell.head,'KDef');
 assert.equal(context.kind,'NativeStaticContext');assert.equal(context.name,'$native.static');
 const parts=tag(context.ctors,'Con'),ctorCell=tag(parts.tail,'Con'),ctor=tag(ctorCell.head,'KDef');
 assert.equal(ctor.kind,'NativeCtorIndex');assert.equal(ctor.name,'$native.ctors');
 return{root,head,children,contextCell,context,parts,ctorCell,ctor};
}
function normalizeOnlyOwnershipMetadata(before,after,facts,api){
 const old=nativeContext(before.book),now=nativeContext(after.book);
 assert.equal(tag(old.ctor.typ,'KTerm').tag,'Absent');
 const payload=tag(api.p144o_payload(now.ctor),'P144OFacts');assert.equal(payload.valid,true);exact(payload,facts);
 const term=tag(now.ctor.typ,'KTerm');assert.equal(term.tag,'P144Ownership');
 assert.equal(term.name,'');assert.equal(term.id,0);assert.equal(term.quant,1);assert.equal(term.originBegin,0);assert.equal(term.originEnd,0);tag(term.kids,'Nil');
 const ctor={...now.ctor,typ:old.ctor.typ};
 const context={...now.context,ctors:{...now.parts,tail:{...now.ctorCell,head:ctor}}};
 const head={...now.head,ctors:{...now.children,tail:{...now.contextCell,head:context}}};
 return{...after,book:{...now.root,head}};
}
// Complete graph snapshot preserves sharing without exponentially expanding ASTs.
function snapshot(value,target){
 const ids=new Map(),pending=[],nodes=[],maxNodes=100000,maxBytes=8*1024*1024;
 const ref=x=>{if(x===null||typeof x!=='object'){assert(x===null||['string','number','boolean'].includes(typeof x));return{value:x}}
  if(!ids.has(x)){assert(ids.size<maxNodes,'SNAPSHOT_NODE_LIMIT');ids.set(x,ids.size);pending.push(x)}return{node:ids.get(x)}};
 try{const root=ref(value);for(let i=0;i<pending.length;i++){const x=pending[i];nodes.push({array:Array.isArray(x),fields:Object.keys(x).sort().map(k=>[k,ref(x[k])])})}
  const text=JSON.stringify({format:'phase144-checked-bend-data-graph-v1',root,nodes})+'\n',bytes=Buffer.byteLength(text);
  if(bytes>maxBytes)return{retained:false,reason:'over8MiB',nodes:nodes.length,bytes};
  fs.writeFileSync(target,text,{flag:'wx'});return{retained:true,graph:pin(target),nodes:nodes.length,complete:true};
 }catch(e){if(e.message==='SNAPSHOT_NODE_LIMIT')return{retained:false,reason:'over100000nodes'};throw e}
}
try{
 const importStart=performance.now();const api=(await import(pathToFileURL(rec.api.file))).default;report.apiImportSeconds=(performance.now()-importStart)/1000;
 const prep=time(()=>tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(selection.preferredCarrier.file,'utf8'),selection.preferredStamp),'P86PreparationReady'));
 report.basePreparationSeconds=prep.seconds;const seed=prep.value.seed;
 const controls=time(()=>list(api.p144o_controls()));report.controls=controls.value;report.controlSeconds=controls.seconds;
 assert.equal(report.controls.length,35);assert(report.controls.every(x=>x.startsWith('PASS ')),JSON.stringify(report.controls.filter(x=>!x.startsWith('PASS '))));save();
 for(const [familyIndex,name] of ['lexer','coverage-map-churn-128','coverage-closures-256'].entries()){
  budget();const reference=refs.cases.find(x=>x.name===name);assert(reference);add(reference.source);add(reference.expectedQbe);
  const front=time(()=>tag(api.p86_plan(seed,reference.source.file,fs.readFileSync(reference.source.file,'utf8')),'P86PlanReady'));
  const request=tag(front.value.request,'NR_Request'),source=request.source;
  const row={name,sourceFile:reference.source,frontendSeconds:front.seconds,blocks:[],complete:false};report.rows.push(row);save();
  const names=time(()=>api.p144ow_names(source,{$:'Nil'})),facts=time(()=>tag(api.p144o_build(source),'P144OFacts'));
  assert.equal(facts.value.valid,true,'Real workload must admit ownership facts');
  const queries=list(names.value),positive=list(facts.value.names),index=time(()=>api.p144o_index(facts.value.names,api.missing()));
  row.census={topLevelRows:list(source).length,queryNames:queries.length,uniqueQueryNames:new Set(queries).size,
   positiveNames:positive.length,positiveNameList:positive,positiveFractionOfUniqueQueries:positive.length/Math.max(1,new Set(queries).size)};
  row.componentDiagnostics={queryDiscoverySeconds:names.seconds,factConstructionSeconds:facts.seconds,additionalPositiveIndexSeconds:index.seconds};
  const original=api.p144ot_original_batch(source,names.value),candidate=api.p144ot_list_batch(source,facts.value,names.value),indexed=api.p144ot_index_batch(source,true,index.value,names.value);
  row.listQueryEquality=exact(original,candidate);row.indexQueryEquality=exact(original,indexed);
  const answers=list(original);assert(answers.every(x=>typeof x==='boolean'));const truePerSweep=answers.filter(Boolean).length;
  const originalTable=time(()=>api.p144o_original_constructors(source,source)),sharedTable=time(()=>api.p144o_constructors(source,source,facts.value));
  row.catalogueEquality=exact(originalTable.value,sharedTable.value);row.catalogueCount=list(originalTable.value).length;
  row.catalogueDiagnosticSeconds={original:originalTable.seconds,prepared:sharedTable.seconds,preparedPlusFacts:sharedTable.seconds+facts.seconds};
  const reconstructed=time(()=>tag(api.p144o_prepare_annotated(source,{$:'Nil'}),'NR_Request'));
  row.preparedRequestSeconds=reconstructed.seconds;
  row.requestEqualityExceptOwnershipPayload=exact(request,normalizeOnlyOwnershipMetadata(request,reconstructed.value,facts.value,api));
  row.preparedRequestScope='Replays already merged/annotated source with empty additional annotation. Source/bound/paths/scope/names and all erased facts exact; only NativeCtorIndex.typ may carry the verified summary. Optional nc_ctor_owned override is not installed in this API.';
  row.nativeData=snapshot(source,out+'/'+name+'-source.graph.json');
  const queryFile=out+'/'+name+'-queries.json';fs.writeFileSync(queryFile,JSON.stringify({queries,expected:answers,positive},null,2)+'\n');row.queryData=pin(queryFile);save();
  const methods={original:api.p144ow_original,list:api.p144ow_list,index:api.p144ow_index};
  const run=(mode,sweeps,iterations)=>{
   const expected=(17+truePerSweep*sweeps)>>>0,start=performance.now();let result=0;
   for(let i=0;i<iterations;i++){result=methods[mode](source,sweeps);assert.equal(result,expected,mode+' checksum')}
   const callSeconds=(performance.now()-start)/1000,gc=time(()=>Bun.gc(true));
   return{mode,iterations,sweeps,checksum:result,callSeconds,forcedCleanupSeconds:gc.seconds,chargedSeconds:callSeconds+gc.seconds,
    callSecondsPerAcquisition:callSeconds/iterations,chargedSecondsPerAcquisition:(callSeconds+gc.seconds)/iterations,
    callBatchAbove20ms:callSeconds>=.020};
  };
  for(const sweeps of [1,4,16]){
   budget();const block={sweeps,reuseScope:sweeps===1?'one actual catalogue query-name sweep':'hypothetical repeated sweeps; not observed actual query multiplicity',calibration:[],rounds:[]};row.blocks.push(block);save();
   block.preCalibrationCleanupSeconds=time(()=>Bun.gc(true)).seconds;
   for(const mode of ['original','list','index']){budget();block.calibration.push(run(mode,sweeps,1))}
   const baseline=block.calibration.find(x=>x.mode==='original').callSeconds;
   const iterations=Math.max(1,Math.min(64,Math.ceil(.040/Math.max(baseline,.000001))));block.iterations=iterations;save();
   const modes=['original','list','index'];
   for(let round=0;round<3;round++){
    budget();const offset=(round+familyIndex)%3,order=modes.slice(offset).concat(modes.slice(0,offset));
    const result={round,order,calls:[]};block.rounds.push(result);
    for(const mode of order){budget();result.calls.push(run(mode,sweeps,iterations));save()}
    const old=result.calls.find(x=>x.mode==='original');
    result.ratios=Object.fromEntries(['list','index'].map(mode=>{const x=result.calls.find(y=>y.mode===mode);return[mode,{call:x.callSeconds/old.callSeconds,charged:x.chargedSeconds/old.chargedSeconds}]}));save();
   }
   block.summary=Object.fromEntries(['list','index'].map(mode=>[mode,{
    medianCallRatio:median(block.rounds.map(x=>x.ratios[mode].call)),medianChargedRatio:median(block.rounds.map(x=>x.ratios[mode].charged)),
    allThreeCallRatiosBelowOne:block.rounds.every(x=>x.ratios[mode].call<1),allThreeChargedRatiosBelowOne:block.rounds.every(x=>x.ratios[mode].charged<1),
    allCallBatchesAbove20ms:block.rounds.every(x=>x.calls.filter(y=>y.mode===mode||y.mode==='original').every(y=>y.callBatchAbove20ms))}]));block.complete=true;save();
  }
  row.crossover=Object.fromEntries(['list','index'].map(mode=>[mode,{
   smallestTestedMedianCallWinSweeps:row.blocks.find(x=>x.summary[mode].medianCallRatio<1)?.sweeps??null,
   smallestTestedAllThreeCallWinSweeps:row.blocks.find(x=>x.summary[mode].allThreeCallRatiosBelowOne)?.sweeps??null,
   smallestTestedMedianChargedWinSweeps:row.blocks.find(x=>x.summary[mode].medianChargedRatio<1)?.sweeps??null,
   smallestTestedAllThreeChargedWinSweeps:row.blocks.find(x=>x.summary[mode].allThreeChargedRatiosBelowOne)?.sweeps??null,
   interpretation:'Tested crossover only at1/4/16 sweeps; null means none established. No interpolation, measured production-call-count or native inference.'}]));
  row.complete=true;save();console.log(JSON.stringify({name,census:row.census,crossover:row.crossover}));
 }
 for(const p of inputs.values())add(p);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1}
finally{report.seconds=(performance.now()-started)/1000;report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}))}
