// Existing checked Bend operations on held real annotation products. Preparation
// and controls are outside paired gate timers; the original gate is the oracle.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';
import assert from 'node:assert/strict';import{pathToFileURL}from'node:url';
const ROOT=path.resolve(import.meta.dirname,'../../../../..'),[apiArg,outArg]=process.argv.slice(2);
assert(apiArg&&outArg);const out=path.resolve(outArg);assert(!fs.existsSync(out)&&out.startsWith(ROOT+'/selfhost/build/phase142/'));
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const read=f=>JSON.parse(fs.readFileSync(f)),verify=p=>assert.deepEqual(pin(p.file),p),rec=read(apiArg),selPath=ROOT+'/implementation/phase137/candidate.json',sel=read(selPath),refPath=ROOT+'/selfhost/build/phase134/reference03.json',refs=read(refPath),carrier=read(sel.preferredCarrierReceipt.file);
assert(rec.complete&&rec.checked&&sel.nativeQualified&&refs.complete);rec.inputs.forEach(verify);verify(rec.api);
const base=carrier.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));assert(base);verify(base);verify(sel.preferredCarrier);
const required=['p88_cache_prepare','f_source_end','p140f_named','p140f_empty','nc_annotation_stops','jl_checked_error','p142j_checked_error','p142jt_controls'];for(const e of required)assert(rec.exports.includes(e),'Missing export '+e);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const report={kind:'phase142-indexed-membership-component-screen-v02',complete:false,diagnostic:true,inputs:[pin(import.meta.filename),pin(apiArg),rec.api,...rec.inputs,pin(selPath),pin(refPath),pin(sel.preferredCarrierReceipt.file),base,sel.preferredCarrier,pin(process.execPath)],rows:[],scope:'Same checked hosted API, original and indexed layout gate on held actual compiler annotation products. Original result is the semantic oracle. Paired times include original book preparation; optional direct visit pair excludes it. No native or whole-request speed claim. No extra codegen/full compiler qualification campaign.',limitations:['Repeated ordered hosted observations are affected by JIT/GC and are descriptive, not confidence intervals.','Definition/stop counts are static input cardinalities, not dynamic query counts.','Optional synthetic graph is a bounded constructed annotated AST, not a source-typechecked corpus workload.']};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
const tag=(x,t)=>{assert.equal(x?.$,t,JSON.stringify({expected:t,actual:x?.$,error:x?.error}));return x},nil=()=>({$:'Nil'}),list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil());
const arr=l=>{const a=[];while(l.$==='Con'){assert(a.length<1000000);a.push(l.head);l=l.tail;}tag(l,'Nil');return a};
const time=f=>{const t=performance.now(),value=f();return{value,seconds:(performance.now()-t)/1000}};
function exact(a,b){const todo=[[a,b]],seen=new WeakMap();while(todo.length){const[x,y]=todo.pop();if(Object.is(x,y))continue;if(!x||!y||typeof x!=='object'||typeof y!=='object'){assert.deepEqual(x,y);continue;}let z=seen.get(x);if(z?.has(y))continue;if(!z){z=new WeakSet();seen.set(x,z);}z.add(y);const keys=Object.keys(x).sort();assert.deepEqual(keys,Object.keys(y).sort());for(const k of keys)todo.push([x[k],y[k]]);}}
const started=performance.now();
try{
 const api=(await import(pathToFileURL(rec.api.file))).default;
 const controls=arr(api.p142jt_controls());report.controls=controls;save();assert.equal(controls.length,26);assert(controls.every(x=>x.startsWith('PASS ')));
 if(typeof api.p142rt_controls==='function'){const r=arr(api.p142rt_controls());report.reachControls=r;save();assert.equal(r.length,28);assert(r.every(x=>x.startsWith('PASS ')));}save();
 const seedT=time(()=>tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(sel.preferredCarrier.file,'utf8'),sel.preferredStamp),'P86PreparationReady').seed),seed=seedT.value,origin=api.f_source_end(seed.source);report.seedSeconds=seedT.seconds;
 const direct=['jl_visit','p142j_visit','book_context','book_cached','missing'].every(x=>typeof api[x]==='function');report.directTraversalAvailable=direct;
 const reach=['reach_book','kr_visit','p142r_reach','p142r_kr_visit','book_context'].every(x=>typeof api[x]==='function');report.reachComparisonAvailable=reach;
 const measure=(row,book,defs,roots,stops)=>{
  row.cardinality={definitions:arr(defs).length,roots:arr(roots).length,stops:arr(stops).length};row.pairs=[];report.rows.push(row);save();
  const expected=api.jl_checked_error(book,defs,roots,stops);assert.equal(expected,'');row.expected=expected;
  let context,cached;if(direct){const p=time(()=>({context:api.book_context(book),cached:api.book_cached(defs,0)}));context=p.value.context;cached=p.value.cached;row.directPreparationSeconds=p.seconds;}
  let reachContext,expectedReached,expectedSeen;
  if(reach){
   const p=time(()=>api.book_context(book));reachContext=p.value;row.reachContextPreparationSeconds=p.seconds;
   expectedReached=api.reach_book(reachContext,roots,stops);expectedSeen=api.kr_visit(reachContext,roots,nil(),stops);
   const names=arr(expectedSeen);row.reachCardinality={seenEntries:names.length,distinctSeenNames:new Set(names).size,reachedDefinitions:arr(expectedReached).length,scope:'Actual original returned outputs; seen entries preserve duplicates and resolved names. These are not counts of popped todo queries.'};
  }
  for(let round=0;round<5;round++){
   let old,next;if(round%2){next=time(()=>api.p142j_checked_error(book,defs,roots,stops));old=time(()=>api.jl_checked_error(book,defs,roots,stops));}else{old=time(()=>api.jl_checked_error(book,defs,roots,stops));next=time(()=>api.p142j_checked_error(book,defs,roots,stops));}
   assert.equal(old.value,expected);assert.equal(next.value,expected);const pair={round,order:round%2?'indexed/original':'original/indexed',originalSeconds:old.seconds,indexedSeconds:next.seconds,ratio:next.seconds/old.seconds,exactResult:true};
   if(direct){let a,b;if(round%2){b=time(()=>api.p142j_visit(context,cached,roots,api.missing(),stops));a=time(()=>api.jl_visit(context,cached,roots,nil(),stops));}else{a=time(()=>api.jl_visit(context,cached,roots,nil(),stops));b=time(()=>api.p142j_visit(context,cached,roots,api.missing(),stops));}assert.equal(a.value,false);assert.equal(b.value,a.value);pair.direct={originalSeconds:a.seconds,indexedSeconds:b.seconds,ratio:b.seconds/a.seconds,exactResult:true,scope:'Nested traversal category with book preparation excluded; do not add to gate interval.'};}
   if(reach){
    let reachedOld,reachedNew,seenOld,seenNew;
    if(round%2){reachedNew=time(()=>api.p142r_reach(reachContext,roots,stops));reachedOld=time(()=>api.reach_book(reachContext,roots,stops));seenNew=time(()=>api.p142r_kr_visit(reachContext,roots,nil(),stops));seenOld=time(()=>api.kr_visit(reachContext,roots,nil(),stops));}
    else{reachedOld=time(()=>api.reach_book(reachContext,roots,stops));reachedNew=time(()=>api.p142r_reach(reachContext,roots,stops));seenOld=time(()=>api.kr_visit(reachContext,roots,nil(),stops));seenNew=time(()=>api.p142r_kr_visit(reachContext,roots,nil(),stops));}
    exact(reachedOld.value,expectedReached);exact(reachedNew.value,expectedReached);exact(seenOld.value,expectedSeen);exact(seenNew.value,expectedSeen);
    const count=row.reachCardinality.distinctSeenNames;
    pair.reach={originalSeconds:reachedOld.seconds,indexedSeconds:reachedNew.seconds,ratio:reachedNew.seconds/reachedOld.seconds,exactOrderedDefinitions:true,visit:{originalSeconds:seenOld.seconds,indexedSeconds:seenNew.seconds,ratio:seenNew.seconds/seenOld.seconds,exactOrderedNamesIncludingDuplicates:true,originalSecondsPerDistinctOutputName:count?seenOld.seconds/count:null,indexedSecondsPerDistinctOutputName:count?seenNew.seconds/count:null,scope:'Direct visited-list traversal excluding final filter; normalization uses actual distinct returned names, not sampled CPU or dynamic pop count.'}};
   }
   row.pairs.push(pair);save();
  }
  console.log(JSON.stringify({name:row.name,kind:row.kind,cardinality:row.cardinality,pairs:row.pairs}));
 };
 for(const[name,owner,needle,replacement]of[['lexer','prng','U32.shln(x, 13n)','U32.shln(x, 12n)'],['coverage-map-churn-128','p37.map.update','U32.mul(i, 31)','U32.mul(i, 29)']]){
  const fixture=refs.cases.find(x=>x.name===name);assert(fixture);verify(fixture.source);report.inputs.push(fixture.source);const a=fs.readFileSync(fixture.source.file,'utf8');assert.equal(a.split(needle).length,2);const b=a.replace(needle,replacement),hint=origin+a.indexOf(needle),bp=out+'/'+name+'-B.bend';fs.writeFileSync(bp,b);report.inputs.push(pin(bp));
  const old=time(()=>tag(api.p140f_named(seed,fixture.source.file,a,api.p140f_empty(),hint,owner),'P140FResult'));tag(old.value.plan,'P86PlanReady');
  const next=time(()=>tag(api.p140f_named(seed,fixture.source.file,b,old.value.cache,hint,owner),'P140FResult'));tag(next.value.plan,'P86PlanReady');
  const owners=next.value.cache.owners,defs=list(arr(owners.annotations).map(x=>x.product)),book=owners.book,stops=api.nc_annotation_stops(book);
  measure({name,kind:'actual-held-warm-annotation-products',preparation:{coldASeconds:old.seconds,warmBSeconds:next.seconds},edit:{owner,needle,replacement,hint,logicalPath:fixture.source.file},frontendStats:arr(next.value.stats)},book,defs,list(['main']),stops);
 }
 report.syntheticAvailable=typeof api.p142jg_fixture==='function';
 if(report.syntheticAvailable)for(const n of[128,512,2048]){const prepared=time(()=>tag(api.p142jg_fixture(n),'P142JGFixture')),g=prepared.value;measure({name:'double-reference-chain-'+n,kind:'synthetic-annotated-AST-scaling',fixturePreparationSeconds:prepared.seconds,constructedDefinitions:n,structuralReferenceEdges:2*n,dynamicVisitsMeasured:false},g.defs,g.defs,g.roots,g.stops);}
 report.inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}finally{report.totalSeconds=(performance.now()-started)/1000;report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,totalSeconds:report.totalSeconds,error:report.error}));}
