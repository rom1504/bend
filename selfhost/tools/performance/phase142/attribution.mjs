// Observer only: compiled, independently checked Bend implements every semantic
// operation. Replays are diagnostic hosted costs, never native attribution.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const ROOT=path.resolve(import.meta.dirname,'../../../..');
const [apiArg,outArg,...names]=process.argv.slice(2);
assert(apiArg&&outArg,'API report and fresh Phase142 output required');
const out=path.resolve(outArg),families=names.length?names:['lexer','coverage-map-churn-128'];
assert(!fs.existsSync(out)&&out.startsWith(ROOT+'/selfhost/build/phase142/'));
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const read=f=>JSON.parse(fs.readFileSync(f)),verify=p=>assert.deepEqual(pin(p.file),p);
const digest=s=>({bytes:Buffer.byteLength(s),sha256:crypto.createHash('sha256').update(s).digest('hex')});
const rec=read(apiArg),selPath=ROOT+'/implementation/phase137/candidate.json',sel=read(selPath);
const refPath=ROOT+'/selfhost/build/phase134/reference03.json',refs=read(refPath),carrier=read(sel.preferredCarrierReceipt.file);
assert(rec.complete&&rec.checked&&sel.nativeQualified&&refs.complete);rec.inputs.forEach(verify);verify(rec.api);
const base=carrier.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));assert(base);verify(base);verify(sel.preferredCarrier);
const required=['p88_cache_prepare','f_source_end','p86_plan','p134e_plan','p134e_begin','p134e_next','p140f_named','p140f_empty','p140or_lower','p140or_empty','p140b_session','p140b_empty','p111_runtime_admission','p140v_reuse','p140v_check','p140v_context','p140v_segment','p140v_metadata','p140v_raw_walk','p140v_direct_walk','missing','p126bp_complete','nc_annotation_stops','jl_checked_error','nc_context_index','nc_context_defs','norm_max_book','book_cached','nc_paths_of','kr_filter'];
for(const key of required)assert(rec.exports.includes(key),'Missing checked export: '+key);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const report={kind:'phase142-hosted-attribution',complete:false,diagnostic:true,inputs:[pin(import.meta.filename),pin(apiArg),rec.api,...rec.inputs,pin(selPath),pin(refPath),pin(sel.preferredCarrierReceipt.file),base,sel.preferredCarrier,pin(process.execPath)],rows:[],scope:'Hosted checked Bend. Cold A then real warm B; replay inputs retained. Stage intervals are disjoint within a request. Diagnostic replays overlap stages and each other and must not be summed into a request time. No native, clean-performance, dynamic instruction-count or savings claim.',limitations:['JIT, allocation and GC affect ordered observations. Three repeated component observations are descriptive, not confidence intervals.','Equality-only replay dispatches one checked comparator per segment through JavaScript; it is not an exclusive compiler timer.','Replaying final verification on final accepted IR isolates its work but may alter lifetime/cache/JIT state. Native floor remains unmeasured.','No per-node visit counter is inferred from static body size. Timing acquisition, cold preparation, replays and independent oracle work are separate.']};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
const tag=(x,t)=>{assert.equal(x?.$,t,JSON.stringify({expected:t,actual:x?.$,error:x?.error}));return x};
const nil=()=>({$:'Nil'}),bool=b=>({$:b?'True':'False'});
const arr=l=>{const a=[];while(l.$==='Con'){assert(a.length<1000000);a.push(l.head);l=l.tail;}tag(l,'Nil');return a};
const list=a=>a.reduceRight((tail,head)=>({$:'Con',head,tail}),nil());
const time=f=>{const started=performance.now(),value=f();return{value,seconds:(performance.now()-started)/1000}};
function exact(a,b){const todo=[[a,b]],seen=new WeakMap();while(todo.length){const[x,y]=todo.pop();if(Object.is(x,y))continue;if(!x||!y||typeof x!=='object'||typeof y!=='object'){assert.deepEqual(x,y);continue;}let s=seen.get(x);if(s?.has(y))continue;if(!s){s=new WeakSet();seen.set(x,s);}s.add(y);const keys=Object.keys(x).sort();assert.deepEqual(keys,Object.keys(y).sort());for(const k of keys)todo.push([x[k],y[k]]);}}
const allStarted=performance.now();
try{
 const api=(await import(pathToFileURL(rec.api.file))).default;
 const prepared=time(()=>tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(sel.preferredCarrier.file,'utf8'),sel.preferredStamp),'P86PreparationReady').seed);
 const seed=prepared.value,origin=api.f_source_end(seed.source);report.seedSeconds=prepared.seconds;
 const render=emission=>{const plan=tag(emission,'P134Planned').plan;let cursor=api.p134e_begin(plan);const pieces=[];for(let i=0;i<1000000;i++){const step=api.p134e_next(cursor);if(step.$==='P134Done')return pieces.join('');tag(step,'P134Piece');pieces.push(step.text+(step.legacy_end?'\n':''));cursor=step.next;}throw Error('cursor bound');};
 const stage=(source,text,hint,owner,prior)=>{
  const started=performance.now();
  const front=time(()=>tag(api.p140f_named(seed,source,text,prior?.front||api.p140f_empty(),hint,owner),'P140FResult'));
  const plan=tag(front.value.plan,'P86PlanReady');
  const admission=time(()=>api.p111_runtime_admission(plan.request));assert.equal(admission.value,'');
  const raw=time(()=>tag(api.p140or_lower(plan.request,prior?.raw||api.p140or_empty()),'P140ORResult'));assert.equal(raw.value.lowering.lowered.error,'');
  const back=time(()=>tag(api.p140b_session(plan.request,prior?.back||api.p140b_empty(),raw.value.lowering),'P140BResult'));tag(back.value.emission,'P134Planned');
  const totalSeconds=(performance.now()-started)/1000;
  return{front:front.value,raw:raw.value,back:back.value,request:plan.request,cache:{front:front.value.cache,raw:raw.value.cache,back:back.value.cache},timings:{frontendSeconds:front.seconds,runtimeAdmissionSeconds:admission.seconds,rawSeconds:raw.seconds,backendSeconds:back.seconds,totalBeforeRegistrySeconds:totalSeconds},counts:{frontend:arr(front.value.stats),raw:arr(raw.value.stats),backend:arr(back.value.stats)}};
 };
 const specs={lexer:['prng','U32.shln(x, 13n)','U32.shln(x, 12n)'],'coverage-map-churn-128':['p37.map.update','U32.mul(i, 31)','U32.mul(i, 29)']};
 for(const name of families){
  const fixture=refs.cases.find(x=>x.name===name);assert(fixture&&specs[name]);verify(fixture.source);verify(fixture.expectedQbe);report.inputs.push(fixture.source,fixture.expectedQbe);
  const a=fs.readFileSync(fixture.source.file,'utf8'),[owner,needle,replacement]=specs[name];assert.equal(a.split(needle).length,2);const b=a.replace(needle,replacement),hint=origin+a.indexOf(needle);
  const bFile=out+'/'+name+'-B.bend';fs.writeFileSync(bFile,b);report.inputs.push(pin(bFile));
  const row={name,edit:{owner,needle,replacement,hint,logicalPath:fixture.source.file},stages:{},replays:[],equalities:{}};report.rows.push(row);save();
  const A=stage(fixture.source.file,a,hint,owner,null);row.stages.coldA={...A.timings,counts:A.counts};save();
  const B=stage(fixture.source.file,b,hint,owner,A.cache);row.stages.warmB={...B.timings,counts:B.counts};save();
  // Independent old fresh path and complete QBE comparison are outside attribution.
  const oracle=time(()=>{const pa=api.p86_plan(seed,fixture.source.file,a),pb=api.p86_plan(seed,fixture.source.file,b);exact(pa,A.front.plan);exact(pb,B.front.plan);const qa=render(A.back.emission),qb=render(B.back.emission),fresh=render(api.p134e_plan(pb));assert.equal(qa,fs.readFileSync(fixture.expectedQbe.file,'utf8'));assert.equal(qb,fresh);assert.notEqual(qa,qb,'Substantive edit must change the generated product');return{A:digest(qa),B:digest(qb)};});
  row.oracleSeconds=oracle.seconds;row.products=oracle.value;row.equalities={frontA:true,frontB:true,frozenA:true,freshB:true,substantiveEdit:true};save();
  const program=B.raw.lowering.lowered.program,raw=program.original.program,cache=A.back.cache.opened;
  const reused=tag(api.p140v_reuse(program,cache),'P140VReuse'),metadata=tag(api.p140v_metadata(program.original,reused.metadata),'P140VMetadata');
  const rawIds={$:'N111Ids',functions:metadata.functions.index,constructors:metadata.constructors.index};
  const checked=api.p140v_check(program,cache);assert.equal(checked.error,'');
  const oldSegments=arr(reused.segments),segments=arr(raw.segments);
  row.cardinality={oldSegments:oldSegments.length,currentSegments:segments.length,currentDirectFunctions:arr(program.functions).length,contextEligible:reused.raw.$==='True',directEligible:reused.direct.$==='True'};
  const final=tag(tag(B.back.emission.plan,'P134Admitted').program,'P113AProgram');
  const owners=B.front.cache.owners,definitions=list(arr(owners.annotations).map(x=>x.product)),context=owners.book;
  const stops=api.nc_annotation_stops(context),indexed=api.nc_context_index(definitions),merged=api.nc_context_defs(context,indexed),bound=api.norm_max_book(merged);
  exact(api.book_cached(merged,bound),B.request.source);
  for(let round=0;round<3;round++){
   const replay={round,timings:{},checks:{}};
   const measured=(label,f,check)=>{const x=time(f);replay.timings[label]=x.seconds;check(x.value);};
   const tasks=[
    ['contextExact',()=>api.p140v_context(cache.program.original,program.original),v=>exact(v,reused.raw)],
    ['reuseContextAndDirectHeaders',()=>api.p140v_reuse(program,cache),v=>exact(v,reused)],
    ['rawEqualityScanWithHostDispatch',()=>{let hits=0;for(let i=0;i<segments.length;i++)if(i<oldSegments.length&&api.p140v_segment(oldSegments[i],segments[i]).$==='True')hits++;return hits;},v=>{replay.checks.equalSegmentPairs=v;}],
    ['rawAdmissionInclusive',()=>api.p140v_raw_walk(reused.segments,raw.segments,rawIds,reused.raw,0,0),v=>{assert.equal(v.error,'');replay.checks.rawCounts=[v.hits,v.misses];}],
    ['directAdmissionInclusive',()=>api.p140v_direct_walk(reused.functions,program.functions,checked.ids,api.missing(),reused.direct,0,0),v=>{assert.equal(v.error,'');replay.checks.directCounts=[v.hits,v.misses];}],
    ['firstVerifierInclusive',()=>api.p140v_check(program,cache),v=>{assert.equal(v.error,'');exact(v.counts,checked.counts);}],
    ['independentFinalVerifierReplay',()=>api.p126bp_complete(final.original.original,final.certificate,final.original.functions),v=>exact(v,B.back.emission)],
    ['frontendAnnotationEligibility',()=>api.jl_checked_error(context,definitions,list(['main']),stops),v=>assert.equal(v,'')],
    ['frontendAnnotationIndex',()=>api.nc_context_index(definitions),v=>exact(v,indexed)],
    ['frontendContextMerge',()=>api.nc_context_defs(context,indexed),v=>exact(v,merged)],
    ['frontendMaximumScan',()=>api.norm_max_book(merged),v=>assert.equal(v,bound)],
    ['frontendBookIndex',()=>api.book_cached(merged,bound),v=>exact(v,B.request.source)],
    ['frontendPaths',()=>api.nc_paths_of(B.request.source,B.request.names),v=>exact(v,B.request.paths)],
    ['frontendReachableScope',()=>api.kr_filter(B.request.source,B.request.names),v=>exact(v,B.request.scope)]
   ];
   for(const [label,f,check]of(round%2?[...tasks].reverse():tasks))measured(label,f,check);
   row.replays.push(replay);save();
  }
  console.log(JSON.stringify({name,stages:row.stages,cardinality:row.cardinality,replayRounds:row.replays.length}));
 }
 report.inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}finally{report.totalSeconds=(performance.now()-allStarted)/1000;report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,totalSeconds:report.totalSeconds,error:report.error}));}
