// Source observer: all parsing, completion, renaming and exact comparison are
// checked Bend exports. Host composition is an experiment, not a compiler path.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';
import assert from 'node:assert/strict';import{pathToFileURL}from'node:url';
const ROOT=path.resolve(import.meta.dirname,'../../../..'),[apiArg,outArg,sizesArg='128,512,1024']=process.argv.slice(2);
assert(apiArg&&outArg);const out=path.resolve(outArg);assert(!fs.existsSync(out)&&out.startsWith(ROOT+'/selfhost/build/phase142/'));
const sizes=sizesArg==='none'?[]:sizesArg.split(',').map(Number);assert(sizes.every(n=>Number.isInteger(n)&&n>0&&n<=2048));
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=p=>assert.deepEqual(pin(p.file),p),read=f=>JSON.parse(fs.readFileSync(f));
const rec=read(apiArg),selPath=ROOT+'/implementation/phase137/candidate.json',sel=read(selPath),refPath=ROOT+'/selfhost/build/phase134/reference03.json',refs=read(refPath),carrier=read(sel.preferredCarrierReceipt.file);
assert(rec.complete&&rec.checked&&sel.nativeQualified&&refs.complete);rec.inputs.forEach(verify);verify(rec.api);verify(sel.source);
const base=carrier.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));assert(base);verify(base);verify(sel.preferredCarrier);
const required=['p88_cache_prepare','f_source_end','f_prefix_complete_ready_seed','f_prefix_graph_empty','f_source_path','f_source_text','f_source_located','p86_width','f_source_header','p140pl_load','p140pl_parse','f_graph_aliases','f_path_dir','f_source_begin','f_graph_finish_indexed','f_prefix_ready_source_completed','f_prefix_ready_validate','f_fresh_defs','f_prefix_trace_fresh','p140cp_split','norm_defs_join','f_fresh_prefix_exact_defs'];
for(const e of required)assert(rec.exports.includes(e),'Missing export '+e);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const report={kind:'phase142-actual-completed-freshening-probe',complete:false,diagnostic:true,inputs:[pin(import.meta.filename),pin(apiArg),rec.api,...rec.inputs,pin(selPath),pin(refPath),pin(sel.preferredCarrierReceipt.file),base,sel.preferredCarrier,sel.source,pin(process.execPath)],rows:[],scope:'Hosted checked Bend on actual pre-fresh completion products. Full next counter and complete FPrefixLoad differential equality. Guarded splice pays exact completed-prefix comparison; unguarded reuse is only a ceiling. Compiler prefixes are parser/freshener workloads, not fully checked runnable compiler variants.',limitations:['No native timing, promotion, full compiler speedup or claim that parser-prefix identity alone proves completed-prefix identity.','Prepared-prefix acquisition and original full-loader oracle are paid separately. Timing orders alternate; three observations give no confidence interval.','Full source/header import validity is established by the original loader oracle; experimental decomposition is restricted to successful Base-only inputs.','The finite original-method outputs remain the oracle; component timers overlap and must not be added to parent intervals.']};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
const tag=(x,t)=>{assert.equal(x?.$,t,JSON.stringify({expected:t,actual:x?.$,error:x?.error}));return x};
const truth=x=>{assert.equal(typeof x,'boolean');return x;},nil=()=>({$:'Nil'}),list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil());
const count=l=>{let n=0;while(l.$==='Con'){n++;assert(n<1000000);l=l.tail;}tag(l,'Nil');return n;};
const time=f=>{const t=performance.now(),value=f();return{value,seconds:(performance.now()-t)/1000}};
function exact(a,b){const todo=[[a,b]],seen=new WeakMap();while(todo.length){const[x,y]=todo.pop();if(Object.is(x,y))continue;if(!x||!y||typeof x!=='object'||typeof y!=='object'){assert.deepEqual(x,y);continue;}let z=seen.get(x);if(z?.has(y))continue;if(!z){z=new WeakSet();seen.set(x,z);}z.add(y);const keys=Object.keys(x).sort();assert.deepEqual(keys,Object.keys(y).sort());for(const k of keys)todo.push([x[k],y[k]]);}}
const started=performance.now();
try{
 const api=(await import(pathToFileURL(rec.api.file))).default;
 const seedT=time(()=>tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(sel.preferredCarrier.file,'utf8'),sel.preferredStamp),'P86PreparationReady').seed),seed=seedT.value;report.seedSeconds=seedT.seconds;assert(truth(seed.fresh.ready));
 const baseT=time(()=>tag(api.f_prefix_complete_ready_seed(seed.source,'',api.f_prefix_graph_empty(),api.f_source_path(seed.source),api.f_source_text(seed.source),seed.book,seed.ready),'FPrefixCompletion')),baseCarrier=tag(baseT.value.carrier,'FReadyPrefixGraph');assert.equal(baseT.value.parsed.error,'');report.baseCompletionSeconds=baseT.seconds;
 const origin=api.f_source_end(seed.source),fixtures=[];
 for(const[name,needle,replacement]of[['lexer','U32.shln(x, 13n)','U32.shln(x, 12n)'],['coverage-map-churn-128','U32.mul(i, 31)','U32.mul(i, 29)']]){const c=refs.cases.find(x=>x.name===name);assert(c);verify(c.source);report.inputs.push(c.source);fixtures.push({name,kind:'frozen',logicalPath:c.source.file,a:fs.readFileSync(c.source.file,'utf8'),needle,replacement});}
 const compiler=fs.readFileSync(sel.source.file,'utf8'),declarations=[...compiler.matchAll(/^(?:@unsafe\n)?(?:type|def|law) [^\s(]+/gm)];assert(!compiler.includes('p142fresh_tail'));
 for(const n of sizes){assert(n<declarations.length);const prefix=compiler.slice(0,declarations[n].index),tail='\ndef p142fresh_tail(x: U32) -> U32:\n  U32.add(x, 314159)\n';assert(Buffer.byteLength(prefix)<1024*1024);const name='compiler-prefix-'+n;fixtures.push({name,kind:'literal-selected-compiler-prefix',declarations:n,prefixBytes:Buffer.byteLength(prefix),sourceCompiler:sel.source,logicalPath:out+'/'+name+'-A.bend',a:prefix+tail,needle:'U32.add(x, 314159)',replacement:'U32.add(x, 314160)'});}
 const prepared=(file,text,checkpoint,hint)=>{
  const src=api.f_source_located({$:'FSource',name:file,path:file,text},origin,origin+api.p86_width(text,0)+1),header=api.f_source_header(src);assert.equal(header.error,'');
  const sources=list([src,seed.source]),aliases=api.f_graph_aliases(header.imports,src,sources,api.f_path_dir(file));
  const scope={$:'FParseScope',prior:baseCarrier.graph.book,index:baseCarrier.names,ctors:baseCarrier.ctors,ns:'',aliases};
  const parsed=tag(api.p140pl_parse(text,header,scope,api.f_source_begin(src),hint,checkpoint),'P140PParsed');assert.equal(parsed.result.error,'');
  const indexed=api.f_graph_finish_indexed(src,'',aliases,baseCarrier.graph,sources,baseCarrier.names,parsed.result);
  const completed=tag(api.f_prefix_ready_source_completed(baseCarrier.prefix,baseCarrier.suffix,baseCarrier.count,baseCarrier.baseNames,baseCarrier.names,baseCarrier.ctors,indexed),'FPrefixCompletion'),carrier=tag(completed.carrier,'FReadyPrefixGraph');assert(truth(carrier.ready));
  const validated=api.f_prefix_ready_validate(carrier.graph.book,carrier.suffix,carrier.graph.error,carrier.baseNames);assert.equal(validated.error,'');
  return{src,sources,parsed,carrier,validated};
 };
 const traced=(p,fresh)=>api.f_prefix_trace_fresh(p.carrier.graph,p.sources,p.carrier.prefix,p.validated.imports,fresh);
 for(const f of fixtures){
  assert.equal(f.a.split(f.needle).length,2);const b=f.a.replace(f.needle,f.replacement),hint=origin+f.a.indexOf(f.needle);
  const ap=out+'/'+f.name+'-A.bend',bp=out+'/'+f.name+'-B.bend';fs.writeFileSync(ap,f.a);fs.writeFileSync(bp,b);report.inputs.push(pin(ap),pin(bp));
  const row={name:f.name,kind:f.kind,compilerDeclarations:f.declarations??null,compilerPrefixBytes:f.prefixBytes??null,inputBytes:Buffer.byteLength(f.a),edit:{needle:f.needle,replacement:f.replacement,hint,logicalPath:f.logicalPath},pairs:[]};report.rows.push(row);save();
  const AT=time(()=>prepared(f.logicalPath,f.a,{$:'None'},hint)),A=AT.value,checkpoint=tag(A.parsed.cache,'Some').value,cut=count(checkpoint.book);
  const BT=time(()=>prepared(f.logicalPath,b,A.parsed.cache,hint)),B=BT.value;assert(truth(B.parsed.hit),'Expected actual parser prefix reuse');
  const splitA=tag(api.p140cp_split(A.carrier.suffix,cut,nil()),'P140CPSplit'),splitB=tag(api.p140cp_split(B.carrier.suffix,cut,nil()),'P140CPSplit');assert(truth(splitA.complete)&&truth(splitB.complete));
  const freshA=time(()=>api.f_fresh_defs(A.carrier.suffix,seed.fresh.next)),capture=time(()=>api.f_fresh_defs(splitA.prefix,seed.fresh.next)),FP=tag(capture.value,'FFreshDefs');
  const combine=tail=>({$:'FFreshDefs',defs:api.norm_defs_join(FP.defs,tail.defs),next:tail.next});
  exact(combine(api.f_fresh_defs(splitA.suffix,FP.next)),freshA.value);
  const fullInitial=time(()=>api.f_fresh_defs(B.carrier.suffix,seed.fresh.next)),expectedFresh=tag(fullInitial.value,'FFreshDefs'),expectedLoad=traced(B,expectedFresh);
  const oracle=time(()=>tag(api.p140pl_load(seed,f.logicalPath,b,A.parsed.cache,hint),'P140PLoadReady'));exact(expectedLoad,oracle.value.load);exact(B.parsed.cache,oracle.value.cache);assert.equal(B.parsed.hit,oracle.value.hit);
  row.preparation={ASeconds:AT.seconds,BSeconds:BT.seconds,fullAFresheningSeconds:freshA.seconds,fullBFresheningSeconds:fullInitial.seconds,retainedPrefixAcquisitionSeconds:capture.seconds,independentLoaderOracleSeconds:oracle.seconds};
  row.cardinality={cutEvents:cut,currentEvents:count(B.carrier.suffix),remainingEvents:count(splitB.suffix),startingNext:seed.fresh.next,nextAtCut:FP.next,finalNext:expectedFresh.next};row.exactOriginalLoad=true;save();
  for(let round=0;round<3;round++){
   const full=()=>time(()=>api.f_fresh_defs(B.carrier.suffix,seed.fresh.next));
   const guarded=()=>time(()=>{if(!truth(api.f_fresh_prefix_exact_defs(splitA.prefix,splitB.prefix)))return api.f_fresh_defs(B.carrier.suffix,seed.fresh.next);return combine(api.f_fresh_defs(splitB.suffix,FP.next));});
   let ordinary,reused;if(round%2){reused=guarded();ordinary=full();}else{ordinary=full();reused=guarded();}
   exact(ordinary.value,expectedFresh);exact(reused.value,expectedFresh);
   const guard=time(()=>api.f_fresh_prefix_exact_defs(splitA.prefix,splitB.prefix));assert(truth(guard.value));
   const tail=time(()=>api.f_fresh_defs(splitB.suffix,FP.next)),assembly=time(()=>combine(tail.value));exact(assembly.value,expectedFresh);
   const withoutGuard=time(()=>combine(api.f_fresh_defs(splitB.suffix,FP.next)));exact(withoutGuard.value,expectedFresh);
   const fullGraph=time(()=>traced(B,ordinary.value)),reuseGraph=time(()=>traced(B,reused.value));exact(fullGraph.value,oracle.value.load);exact(reuseGraph.value,oracle.value.load);
   row.pairs.push({round,order:round%2?'guarded/full':'full/guarded',fullFresheningSeconds:ordinary.seconds,guardedSpliceSeconds:reused.seconds,guardedRatio:reused.seconds/ordinary.seconds,prefixGuardReplaySeconds:guard.seconds,suffixReplaySeconds:tail.seconds,assemblyReplaySeconds:assembly.seconds,unguardedCeilingSeconds:withoutGuard.seconds,fullGraphAssemblySeconds:fullGraph.seconds,reusedGraphAssemblySeconds:reuseGraph.seconds,allDefinitionsAndNextExact:true,completeOriginalLoadExact:true});save();
  }
  console.log(JSON.stringify({name:row.name,cardinality:row.cardinality,preparation:row.preparation,pairs:row.pairs}));
 }
 report.inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}finally{report.totalSeconds=(performance.now()-started)/1000;report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,totalSeconds:report.totalSeconds,error:report.error}));}
