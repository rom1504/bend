// Root owns the only resource guard. Diagnostic checkpoint, not public ABI.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
const [attemptArg,...args]=process.argv.slice(2),outArg=args.pop(),sourceArgs=args;assert(attemptArg&&sourceArgs.length&&outArg);
const historical=path.resolve(import.meta.dirname,'../../phase64/controls');
const focused=process.env.PHASE65_CTOR_ONLY==='1';
const legacy=path.resolve(import.meta.dirname,'../../phase61/prefix-state');
const raw=path.resolve(import.meta.dirname,'../../../../build/phase65'),out=path.resolve(outArg);
assert(out.startsWith(raw+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=b=>createHash('sha256').update(b).digest('hex'),inputs=new Map();
function pin(f,want){const b=fs.readFileSync(f),r={file:fs.realpathSync(f),sha256:hash(b),bytes:b.length};if(want){assert.equal(r.sha256,want.sha256);if(Object.hasOwn(want,'canonicalPath'))assert.equal(want.canonicalPath,r.file);if(Object.hasOwn(want,'bytes'))assert.equal(want.bytes,r.bytes);}if(inputs.has(r.file))assert.deepEqual(r,inputs.get(r.file));inputs.set(r.file,r);return r;}
const stringify=x=>JSON.stringify(x,(_,v)=>typeof v==='bigint'?{$bigint:String(v)}:v),digest=x=>hash(stringify(x));
const list=a=>a.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const array=xs=>{const a=[];while(xs?.$==='Con'){assert(a.length<20000);a.push(xs.head);xs=xs.tail;}assert.equal(xs?.$,'Nil');return a;};
const report={kind:'phase65-prefix-constructor-index-controls',complete:false,pass:false,scope:'Checked candidate full-check versus original prefix replay versus shared immutable Base world. Exact entire DChecking and completion on actual carriers and differential admission/fallback controls; same deep-frozen world survives alternating sources. Fifteen constructor membership controls additionally compare the original predicate; PHASE65_CTOR_ONLY=1 skips the inherited full matrix. Private authenticated state/prefix coupling remains a host obligation; this is not a public raw-state authenticity, clean latency, or release claim.',roles:{},rows:[],inputs:[]};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};save();
try{
 pin(import.meta.filename);pin(path.join(import.meta.dirname,'prefix-world-constructor-v1.derivation.json'));const candidate=pin(path.resolve(import.meta.dirname,'../cache-contract/constructor-index-v1.json'));const candidateMetadata=JSON.parse(fs.readFileSync(candidate.file,'utf8'));pin(path.resolve(import.meta.dirname,'../../../../..',candidateMetadata.patch),{sha256:candidateMetadata.patchSha256});report.focusedOnly=focused;report.fullMatrix=!focused;pin(path.join(historical,'derivation.json'));pin(path.join(historical,'prefix-world-todos-v2.derivation.json'));pin(path.join(historical,'prefix-world-todos-v3.derivation.json'));pin(path.join(historical,'prefix-world-context-v4.derivation.json'));pin(path.join(historical,'prefix-world-context-v5.derivation.json'));pin(path.resolve(import.meta.dirname,'../../phase63/controls/prefix-world-v1.mjs'));pin(path.join(legacy,'cold-controls-v1.mjs'));pin(path.join(legacy,'carrier-controls-v1.mjs'));pin(path.join(legacy,'carrier-controls-v2.mjs'));pin(path.join(legacy,'prefix-maximum-reuse-v1.patch'));pin(process.execPath);pin(new URL('../../../development/workflow.mjs',import.meta.url).pathname);
 const directory=fs.realpathSync(attemptArg),attempt=pin(path.join(directory,'attempt.json')),m=await verifyAttempt(directory);assert(m.checked&&m.config.strictExact);
 for(const k of ['api','runtime','base','node'])pin(m[k].file,m[k]);assert.equal(pin(process.execPath).sha256,m.node.sha256);
 const prefixSource=pin(path.join(m.snapshot.root,'src/check/prefix-state.bend'));assert.equal(prefixSource.sha256,candidateMetadata.files['selfhost/src/check/prefix-state.bend'].afterSha256,'Actual snapshot must contain the reviewed H5 source');const loaderPrefixSource=pin(path.join(m.snapshot.root,'src/load/prefix.bend'));pin(path.join(m.snapshot.root,'src/load/modules.bend'));pin(path.join(m.snapshot.root,'src/load/graph.bend'));pin(path.join(m.snapshot.root,'src/load/seed.bend'));
 const driverFile=pin(path.join(m.snapshot.root,'tools/typed-driver.mjs'));
 for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
 process.env.BEND_TYPED_API=m.api.file;process.env.BEND_TYPED_RUNTIME=m.runtime.file;process.env.BEND_BASE=m.base.file;
 const D=await import(pathToFileURL(driverFile.file)),api=await D.loadApi();assert.equal(D.apiPath,m.api.file);
 const original=fs.readFileSync(m.api.file,'utf8'),P={exports:{}};const parserText=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'];new Function('module','exports',parserText)(P,P.exports);
 const parse=s=>P.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'}),ast=parse(original),names=['run_loop','$base_prefix_prepare$','$base_prefix_check$','$base_prefix_admitted_bound$','$base_prefix_final$','$prefix_state_exact_defs$','$norm_max_book$','$norm_max$','$prefix_state_join$','$dg_check_world$','$base_prefix_resume_saved$','$check_definition_world$','$driver_program_checked$','$base_prefix_check_load$','$f_fresh_prefix_exact_terms$','$base_prefix_world_prepare$','$check_program_diagnostic_world$','$driver_program_checked_prefix$','$base_prefix_resume_world$','$index_hash$','$driver_todos$','$book_context$','$book_context_world$','$base_prefix_constructor_index$','$base_prefix_ctor_index_disjoint$','$base_prefix_ctor_disjoint$','$constructor_exists$','$missing$','$base_prefix_names$'];
 const edits=[];for(const name of names){const hits=ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id?.name===name);assert.equal(hits.length,1,name);if(['$dg_check_world$','$base_prefix_resume_saved$','$check_definition_world$','$prefix_state_exact_defs$','$f_fresh_prefix_exact_terms$','$base_prefix_resume_world$'].includes(name))edits.push({at:hits[0].body.start+1,text:'$p61PrefixCounts['+JSON.stringify(name)+']++;'});}
 let text=original;for(const e of [...edits].sort((a,b)=>b.at-a.at))text=text.slice(0,e.at)+e.text+text.slice(e.at);
 const suffix='\nlet $p64WorldActive=false,$p64CapturedWorld=null;const $p64OldComplete=$driver_program_checked$,$p64OldPrefixComplete=$driver_program_checked_prefix$;$driver_program_checked$=(book,origins,checked)=>{if($p64WorldActive){if($p64CapturedWorld!==null)throw Error("Multiple captured worlds");$p64CapturedWorld=checked;}return $p64OldComplete(book,origins,checked);};$driver_program_checked_prefix$=(suffix,todos,origins,checked)=>{if($p64WorldActive){if($p64CapturedWorld!==null)throw Error("Multiple captured worlds");$p64CapturedWorld=checked;}return $p64OldPrefixComplete(suffix,todos,origins,checked);};function $p64CaptureWorld(prepared,load){if($p64WorldActive)throw Error("Nested capture");$p64WorldActive=true;$p64CapturedWorld=null;try{run_loop($check_program_diagnostic_world$(load,{$:"Nil"},prepared));if($p64CapturedWorld===null)throw Error("Missing captured world");return $p64CapturedWorld;}finally{$p64WorldActive=false;$p64CapturedWorld=null;}}\nconst $p64TodoBooks=[],$p64PriorTodos=$driver_todos$;$driver_todos$=(book)=>{$p64TodoBooks.push(book);return $p64PriorTodos(book);};\nconst $p61PrefixCounts={"$dg_check_world$":0,"$base_prefix_resume_saved$":0,"$check_definition_world$":0,"$prefix_state_exact_defs$":0,"$f_fresh_prefix_exact_terms$":0,"$base_prefix_resume_world$":0};\nconst $p64ContextBooks=[],$p64OldNormMaxBook=$norm_max_book$;let $p64ContextActive=false;$norm_max_book$=(book)=>{if($p64ContextActive)$p64ContextBooks.push(book);return $p64OldNormMaxBook(book);};function $p64Context(book,load,prepared){if($p64ContextActive)throw Error("Nested context capture");$p64ContextActive=true;try{return run_loop($book_context_world$(book,load,prepared));}finally{$p64ContextActive=false;}}\nexport const phase61Prefix={ctorIndex:b=>run_loop($base_prefix_constructor_index$(b,run_loop($missing$()))),ctorIndexed:(s,i)=>run_loop($base_prefix_ctor_index_disjoint$(s,i)),ctorOld:(s,b)=>run_loop($base_prefix_ctor_disjoint$(s,b)),ctorExists:(b,n)=>run_loop($constructor_exists$(b,n)),ctorNames:b=>run_loop($base_prefix_names$(b)),context:(b,l,p)=>$p64Context(b,l,p),contextBooks:$p64ContextBooks,todos:b=>run_loop($driver_todos$(b)),todoBooks:$p64TodoBooks,hash:n=>run_loop($index_hash$(n,2166136261)),counts:$p61PrefixCounts,checkLoad:(s,l)=>run_loop($base_prefix_check_load$(s,l)),prepareWorld:(p,s)=>run_loop($base_prefix_world_prepare$(p,s)),worldLoad:(p,l)=>$p64CaptureWorld(p,l),prepare:p=>run_loop($base_prefix_prepare$(p)),resume:(c,b,p)=>run_loop($base_prefix_check$(c,b,p)),bound:b=>run_loop($norm_max_book$(b)),admitted:(c,p,s,n)=>run_loop($base_prefix_admitted_bound$(c,p,s,n,run_loop($base_prefix_final$(p)),run_loop($norm_max_book$(p)))),maxJoin:(p,s)=>run_loop($norm_max_book$(run_loop($prefix_state_join$(p,s)))),maxPair:(p,s)=>run_loop($norm_max$(run_loop($norm_max_book$(p)),run_loop($norm_max_book$(s)))),exact:(a,b)=>run_loop($prefix_state_exact_defs$(a,b)),full:b=>run_loop($dg_check_world$(b)),complete:(b,r)=>run_loop($driver_program_checked$(b,{$:"Nil"},r))};\n';
 text+=suffix;parse(text);const derivative=path.join(out,'diagnostic-api.mjs');fs.writeFileSync(derivative,text,{flag:'wx'});pin(derivative);
 let recovered=text.slice(0,-suffix.length);for(const e of [...edits].sort((a,b)=>a.at-b.at)){assert.equal(recovered.slice(e.at,e.at+e.text.length),e.text);recovered=recovered.slice(0,e.at)+recovered.slice(e.at+e.text.length);}assert.equal(recovered,original);
 const freeze=value=>{const todo=[value],seen=new Set();while(todo.length){const x=todo.pop();if(x===null||typeof x!=='object'||seen.has(x))continue;seen.add(x);Object.freeze(x);todo.push(...Object.values(x));}return value;};
 const mod=await import(pathToFileURL(derivative));assert.equal(mod.G,undefined);const Q=mod.phase61Prefix,native=mod.default;assert(native&&typeof native==='object');
 // Same Base interval and ordinary loader as prepareBase, without writing cache.
 const rawBase={$:'FSource',name:'Base',path:m.base.file,text:fs.readFileSync(m.base.file,'utf8')};
 const located=api.f_source_located(rawBase,1,rawBase.text.length+2),base=api.f_load_graph('Base',list([located]));assert.equal(base.error,'');
 const prefix=array(base.book);assert(prefix.length>0);for(const name of ['f_prefix_graph_empty','f_prefix_complete_seed','f_prefix_complete_source','f_prefix_graph_trace'])assert.equal(typeof native[name],'function',name);const freshState=native.f_fresh_prefix_prepare(base.book);assert(freshState.ready);
 report.roles.candidate={attempt,api:m.api,runtime:m.runtime,base:m.base,node:m.node,driver:driverFile,prefixSource,loaderPrefixSource,derivative:pin(derivative),suffixSha256:hash(suffix),edits,prefixSha256:digest(prefix),prefixCount:prefix.length};save();
 const counts=()=>({...Q.counts}),delta=(a,b)=>Object.fromEntries(Object.keys(a).map(k=>[k,b[k]-a[k]]));
 // Pure bound distributivity: actual prefix fragments plus raw ordinary KDef
 // fields/constructors. These do not rely on checker admission or cache trust.
 const maxAtom=(tag,id,kids=[])=>({$:'KTerm',tag,name:'',id,quant:0,kids:list(kids),removed:list([]),originBegin:0,originEnd:0});
 const maxDef=(name,typ,value,ctors=[])=>({$:'KDef',name,kind:'Def',arity:0,templates:0,typ,value,ctors:list(ctors),native:false,unsafe:false});
 const zero=maxAtom('Typ',0),dType=maxDef('max.type',maxAtom('Unknown',4294967295),zero),dBody=maxDef('max.body',zero,maxAtom('Ref',65537));
 const nested=maxDef('max.nested',zero,zero,[maxDef('max.child',zero,zero,[maxDef('max.grandchild',zero,maxAtom('App',7,[maxAtom('Var',1048577)]))])]);
 const half=Math.floor(prefix.length/2),prefixBound=Q.bound(base.book);
 const maxCases=[['empty',[],[],0],['base-empty',prefix,[],prefixBound],['empty-base',[],prefix,prefixBound],['split-base',prefix.slice(0,half),prefix.slice(half),prefixBound],['reverse-fragments',prefix.slice(half),prefix.slice(0,half),prefixBound],['maximum-type',[dType],[dBody],4294967295],['maximum-body',[],[dBody],65537],['nested-constructors',[dBody],[nested],1048577]];
 report.maximumControls=[];
 for(const [id,p,s,expected] of maxCases){const before=digest({p,s}),joined=Q.maxJoin(list(p),list(s)),separate=Q.maxPair(list(p),list(s));assert.equal(joined,expected,id+' original maximum');assert.equal(separate,expected,id+' distributed maximum');assert.equal(digest({p,s}),before,id+' immutable inputs');report.maximumControls.push({id,expected,joined,separate,pass:true});}assert.equal(report.maximumControls.length,8);save();

 let before=counts();const state=Q.prepare(base.book),prepareCounts=delta(before,counts()),stateHash=digest(state);assert.equal(state.$,'KBasePrefixState');
 report.prepared={ready:state.ready,bound:state.bound,delta:state.delta,stamp:state.stamp,patches:array(state.patches).map(d=>d.name),sha256:stateHash};save();assert(state.ready,'Prepared Base certificate refused; preserve report and diagnose invariant');
 const prepared=freeze(Q.prepareWorld(base.book,state)),preparedHash=digest(prepared);assert.equal(prepared.$,'KBasePreparedWorld');
 assert.deepEqual(prepared.constructorIndex,Q.ctorIndex(prepared.final),'Actual prepared constructor index equals its original final-prefix producer');
 report.immutableWorld={tag:prepared.$,sha256:preparedHash,todos:prepared.todos};assert.equal(prepared.todos,Q.todos(base.book),'Original Base TODO fact');save();

 // Standalone exact membership controls on the producer's allowed name domain.
 // An outer BookCache row is tested only for its documented builder skip rule.
 const ciDef=(name,kind='Def',ctors=[])=>({...maxDef(name,zero,zero,ctors),kind});
 const ciCollision=pin(path.resolve(import.meta.dirname,'../../phase63/controls/base-collision-v1.json'));
 const ciPair=JSON.parse(fs.readFileSync(ciCollision.file,'utf8'));
 assert.equal(Q.hash(ciPair.first),ciPair.hash);assert.equal(Q.hash(ciPair.second),ciPair.hash);
 const ciA=ciDef('phase65.child.a','Ctr'),ciB=ciDef('phase65.child.b','Def'),ciC=ciDef('phase65.child.c','ADT');
 const ciNested=ciDef('phase65.middle','ADT',[ciDef('phase65.grandchild','Ctr')]);
 const ciCases=[
  ['empty',[],[],true,true],
  ['empty-prefix-query',[],[ciA],true,true],
  ['immediate-Ctr',[ciDef('outer','ADT',[ciA])],[ciA],false,true],
  ['immediate-Def',[ciDef('outer','ADT',[ciB])],[ciB],false,true],
  ['immediate-ADT',[ciDef('outer','ADT',[ciC])],[ciC],false,true],
  ['outer-name-only',[ciA],[ciA],true,true],
  ['grandchild-only',[ciDef('outer','ADT',[ciNested])],[ciDef('phase65.grandchild')],true,true],
  ['middle-is-immediate',[ciDef('outer','ADT',[ciNested])],[ciDef('phase65.middle')],false,true],
  ['nested-suffix-capture',[ciDef('outer','ADT',[ciA])],[ciDef('suffix','ADT',[ciDef('suffix.inner','ADT',[ciA])])],false,true],
  ['duplicate-child-names',[ciDef('outer.a','ADT',[ciA]),ciDef('outer.b','Def',[{...ciA,kind:'Def'}])],[ciA],false,true],
  ['full-hash-collision-first',[ciDef('outer','ADT',[ciDef(ciPair.first),ciDef(ciPair.second)])],[ciDef(ciPair.first)],false,true],
  ['full-hash-collision-second',[ciDef('outer','ADT',[ciDef(ciPair.first),ciDef(ciPair.second)])],[ciDef(ciPair.second)],false,true],
  ['full-hash-collision-absent',[ciDef('outer','ADT',[ciDef(ciPair.first)])],[ciDef(ciPair.second)],true,true],
  ['outer-BookCache-skipped',[ciDef('cache','BookCache',[ciA])],[ciA],true,false],
  ['nonempty-disjoint',[ciDef('outer','ADT',[ciA,ciB,ciC])],[ciDef('absent')],true,true],
 ];
 report.constructorControls=[];
 for(const [id,defs,queries,want,admittedDomain]of ciCases){
  const defsList=freeze(list(defs)),queryList=freeze(list(queries)),before=digest({defsList,queryList}),index=freeze(Q.ctorIndex(defsList));
  if(admittedDomain){assert.equal(Q.ctorNames(defsList),true,id+' admitted prefix name domain');assert.equal(Q.ctorNames(queryList),true,id+' admitted suffix name domain');}
  const expected=Q.ctorOld(queryList,defsList),actual=Q.ctorIndexed(queryList,index);assert.equal(expected,want,id+' independent original predicate');assert.equal(actual,expected,id+' indexed membership');
  for(const query of queries){const direct=Q.ctorExists(defsList,query.name),indexed=!Q.ctorIndexed(list([{...query,ctors:list([])}]),index);assert.equal(indexed,direct,id+' exact immediate lookup');}
  assert.equal(digest({defsList,queryList}),before,id+' immutable inputs');report.constructorControls.push({id,pass:true,admittedDomain,disjoint:actual,indexSha256:digest(index)});
 }
 assert.equal(report.constructorControls.length,15);report.immutableWorld.constructorIndexSha256=digest(prepared.constructorIndex);save();
 if(!focused){
 assert.equal(typeof native.book_context_world,'function');assert.equal(typeof native.book_context,'function');assert.equal(prepared.checkedBound,Q.bound(prepared.checked),'Exact checked Base maximum');report.immutableWorld.checkedBound=prepared.checkedBound;report.contextControls=[];
 function contextRow(id,program,load,pw,optimized){
  if(program.error)return;
  const book=program.book,before=digest({book,load,pw}),expected=native.book_context(book),at=Q.contextBooks.length;
  const actual=Q.context(book,load,pw),scans=Q.contextBooks.slice(at),assembled=array(book),saved=array(pw.checked),tail=assembled.slice(saved.length);
  assert.deepEqual(actual,expected,id+' entire context/index/bound');assert.equal(digest({book,load,pw}),before,id+' immutable context inputs');
  if(optimized){assert.deepEqual(assembled.slice(0,saved.length),[...saved].reverse(),id+' exact leading checked Base');assert.equal(scans.length,2,id+' raw suffix and checked suffix maximum only');assert.deepEqual(scans[0],load.suffix,id+' source-suffix admission maximum');assert.deepEqual(scans[1],list(tail),id+' actual assembled suffix maximum');}
  if(!optimized){const skipsFullScan=assembled.length===0||assembled[0]?.kind==='BookCache';assert.equal(scans.length,skipsFullScan?1:2,id+' generic fallback scan count');assert.deepEqual(scans[0],load.suffix,id+' unchanged admission scan');if(!skipsFullScan)assert.deepEqual(scans[1],book,id+' full assembled fallback scan');}
  const cache=array(actual)[0];assert.equal(cache.kind,'BookCache',id+' context sentinel');assert.equal(cache.arity,Q.bound(book),id+' exact full-book bound');
  report.contextControls.push({id,pass:true,optimized,definitionCount:assembled.length,checkedPrefixCount:saved.length,scannedDefinitionCounts:scans.map(b=>array(b).length),bound:cache.arity,syntheticDefinitions:tail.filter(d=>d.name.includes('~')).map(d=>d.name),contextSha256:digest(actual)});save();
 }

 function row(id,book,validated,expected,checkpoint=state){const p=validated,s=book.slice(p.length),beforeInput=digest({checkpoint,book,p}),matched=Q.exact(list(book.slice(0,p.length)),list(p)),admitted=matched&&Q.admitted(checkpoint,list(p),list(s),Q.bound(list(book)));if(expected!==null)assert.equal(admitted,expected,id);let c=counts();const full=Q.full(list(book)),fullCounts=delta(c,counts());c=counts();const resumed=Q.resume(checkpoint,list(book),list(p)),resumeCounts=delta(c,counts());assert.deepEqual(resumed,full,id+' whole world/diagnostic');
 const load={$:'FPrefixLoad',trace:{$:'FLoadTrace',result:{$:'FResult',book:list(book),error:'',imports:list([])},done:list([]),sources:list([])},prefix:list(p),suffix:list(s),ready:matched};
 const readyWorld=checkpoint===state?prepared:freeze(Q.prepareWorld(list(p),checkpoint));
 c=counts();const direct=Q.worldLoad(readyWorld,load),worldCounts=delta(c,counts());assert.deepEqual(direct,full,id+' immutable-world entire DChecking');const program=native.check_program_diagnostic_world(load,list([]),readyWorld);assert.deepEqual(program,Q.complete(list(book),full),id+' optimized complete program');contextRow(id,program,load,readyWorld,worldCounts['$base_prefix_resume_world$']===1);
 assert.deepEqual(Q.complete(list(book),direct),Q.complete(list(book),full),id+' immutable-world completion');
 assert.equal(digest(prepared),preparedHash,id+' shared world remained unchanged');if(expected===true){assert.equal(full.result.error,'',id+' positive checker outcome');assert.equal(Q.complete(list(book),full).error,'',id+' positive complete outcome');}assert.deepEqual(Q.complete(list(book),resumed),Q.complete(list(book),full),id+' full completion');assert.equal(digest({checkpoint,book,p}),beforeInput,id+' immutable input');assert.equal(resumeCounts['$base_prefix_resume_saved$'],admitted?1:0);assert.equal(resumeCounts['$dg_check_world$'],admitted?0:1);report.rows.push({id,admitted,pass:true,outcome:digest(full),error:full.result.error,fullCounts,resumeCounts,worldCounts});save();return {fullCounts,resumeCounts,worldCounts};}
 for(const sourceArg of sourceArgs){const sourceFile=pin(sourceArg),graph=D.discoverSources(api,sourceFile.file);for(const f of graph.files)pin(f);assert.equal(graph.loadTrace.result.error,'');const all=array(graph.loadTrace.result.book);assert(all.length>prefix.length);assert(Q.exact(list(all.slice(0,prefix.length)),base.book),'Loaded graph is not exact Base prefix');
  // Exercise the actual native completion calls made by the ordinary loader.
  // The JS adapter only threads native carrier values; it does not construct a
  // prefix/suffix proof. Raw discoverSources still selects its old finalizer.
  let carrier=native.f_prefix_graph_empty();
  const wrapped={...native,
   f_complete_seed:(source,prior,p,t,b)=>{assert.deepEqual(prior,carrier.graph);const c=native.f_prefix_complete_seed(source,'',carrier,p,t,b);carrier=c.carrier;return {$:'FCompletion',graph:carrier.graph,parsed:c.parsed};},
   f_complete_source:(source,ns,header,sources,prior,root)=>{assert.deepEqual(prior,carrier.graph);const c=native.f_prefix_complete_source(source,ns,header,sources,carrier,root);carrier=c.carrier;return {$:'FCompletion',graph:carrier.graph,parsed:c.parsed};}};
  const seededGraph=D.discoverSources(wrapped,sourceFile.file,{seed:{book:base.book,sourcePath:m.base.file,sourceText:rawBase.text,spanAbi:api.compiler_span_abi(),sourceBegin:1,sourceEnd:rawBase.text.length+2}});
  assert(carrier.ready,'actual leading Base carrier');
  for(const iteration of [0,1]){const before=counts(),load=native.f_prefix_graph_trace(carrier,seededGraph.sources,freshState);assert(load.ready);assert.deepEqual(load.trace,seededGraph.loadTrace,'complete freshened trace');const resumed=Q.checkLoad(state,load),resumedCounts=delta(before,counts());const full=Q.full(load.trace.result.book);assert.equal(full.result.error,'');assert.deepEqual(resumed,full,'carrier entire world');const directBefore=counts(),direct=Q.worldLoad(prepared,load),directCounts=delta(directBefore,counts());assert.deepEqual(direct,full,'native carrier immutable world');const program=native.check_program_diagnostic_world(load,list([]),prepared);assert.deepEqual(program,Q.complete(load.trace.result.book,full),'native carrier optimized completion');contextRow('native-carrier-'+iteration+'-'+path.basename(sourceFile.file),program,load,prepared,directCounts['$base_prefix_resume_world$']===1);assert.deepEqual(Q.complete(load.trace.result.book,direct),Q.complete(load.trace.result.book,full),'native carrier completion');assert.equal(digest(prepared),preparedHash,'same state reused across iterations/sources');assert.deepEqual(Q.complete(load.trace.result.book,resumed),Q.complete(load.trace.result.book,full));assert.equal(resumedCounts['$prefix_state_exact_defs$'],0);assert.equal(resumedCounts['$f_fresh_prefix_exact_terms$'],0);assert.equal(resumedCounts['$base_prefix_resume_saved$'],1);assert.equal(resumedCounts['$dg_check_world$'],0);report.rows.push({id:'native-carrier-'+iteration+'-'+path.basename(sourceFile.file),admitted:true,pass:true,outcome:digest(full),error:full.result.error,resumeCounts:resumedCounts});save();}
  const ordinary=row('actual-'+path.basename(sourceFile.file),all,prefix,true);assert.equal(ordinary.fullCounts['$check_definition_world$'],prepareCounts['$check_definition_world$']+ordinary.resumeCounts['$check_definition_world$']);assert(ordinary.fullCounts['$check_definition_world$']>ordinary.resumeCounts['$check_definition_world$']);
  row('repeat-'+path.basename(sourceFile.file),all,prefix,true);assert.equal(digest(state),stateHash);
  const atom=(tag,name='',id=0,kids=[])=>({$:'KTerm',tag,name,id,quant:0,kids:list(kids),removed:list([]),originBegin:0,originEnd:0});
  for(const shift of [1,17,1024]){const id=Q.bound(list(all))+shift,type=atom('Ref','U32');const d={$:'KDef',name:'prefix61.floor.'+shift,kind:'Def',arity:1,templates:0,typ:{...atom('All','floor',id,[type,type]),quant:1},value:{...atom('Lam','floor',id,[atom('Var','floor',id)]),quant:1},ctors:list([]),native:false,unsafe:false};row('moved-floor-'+shift+'-'+path.basename(sourceFile.file),[...all,d],prefix,true);}

  const suffix=all.slice(prefix.length),term=prefix[0].typ;
  const changedPrefix=[{...prefix[0],typ:{...term,originBegin:term.originBegin===0?1:term.originBegin+1}},...prefix.slice(1)];row('changed-prefix-span-'+sourceArg,[...changedPrefix,...suffix],prefix,false);
  row('dropped-prefix-'+sourceArg,[...prefix.slice(1),...suffix],prefix,false);
  const reordered=[...prefix],other=reordered.findIndex((d,i)=>i>0&&d.name!==reordered[0].name);assert(other>0);[reordered[0],reordered[other]]=[reordered[other],reordered[0]];row('reordered-prefix-'+sourceArg,[...reordered,...suffix],prefix,false);
  row('cross-prefix-fill-'+sourceArg,[...prefix,prefix[0],...suffix],prefix,false);
  row('reserved-name-'+sourceArg,[...prefix,{...suffix[0],name:suffix[0].name+'~probe'},...suffix.slice(1)],prefix,false);
  row('high-bound-'+sourceArg,[...prefix,{...suffix[0],typ:{...suffix[0].typ,id:1048577}},...suffix.slice(1)],prefix,false);
  const adt=prefix.find(d=>d.kind==='ADT'&&array(d.ctors).length>0);assert(adt);row('constructor-capture-'+sourceArg,[...prefix,{...adt,name:'prefix61.collision'},...suffix],prefix,false);
 }
 report.producerControls=[];
 const initial=native.f_prefix_graph_empty();
 const seeds=[['ordinary',initial,'',m.base.file,rawBase.text,true],['namespace',initial,'qualified',m.base.file,rawBase.text,false],['changed-path',initial,'',m.base.file+'.wrong',rawBase.text,false],['changed-text',initial,'',m.base.file,rawBase.text+' ',false],['nonleading',{$:'FPrefixGraph',graph:{$:'FGraph',book:list([prefix[0]]),error:'',done:list([])},prefix:list([]),suffix:list([]),count:0,ready:false},'',m.base.file,rawBase.text,false]];
 for(const [id,c,ns,p,t,expected] of seeds){const produced=native.f_prefix_complete_seed(located,ns,c,p,t,base.book);assert.equal(produced.carrier.ready,expected,id);const loaded=native.f_prefix_graph_trace(produced.carrier,list([located]),freshState),old=native.f_graph_trace(produced.carrier.graph,list([located]));assert.deepEqual(loaded.trace,old,id+' fallback/trace');assert.equal(loaded.ready,expected,id);report.producerControls.push({id,ready:loaded.ready,pass:true,traceSha256:digest(old)});}
 row('empty-suffix',prefix,prefix,true);
 const collisionFile=pin(path.resolve(import.meta.dirname,'../../phase63/controls/base-collision-v1.json')),collision=JSON.parse(fs.readFileSync(collisionFile.file));assert(prefix.some(d=>d.name===collision.first));assert.equal(Q.hash(collision.first),collision.hash);assert.equal(Q.hash(collision.second),collision.hash);
 const collisionDef={$:'KDef',name:collision.second,kind:'Def',arity:0,templates:0,typ:{$:'KTerm',tag:'Ref',name:'U32',id:0,quant:0,kids:list([]),removed:list([]),originBegin:0,originEnd:0},value:{$:'KLiteral',kind:'U32',number:7,text:'',originBegin:0,originEnd:0},ctors:list([]),native:false,unsafe:false};
 const collisionResult=row('Base-full-hash-collision',[...prefix,collisionDef],prefix,true);assert.equal(collisionResult.worldCounts['$base_prefix_resume_saved$'],1,'Base hash collision selects original replay');assert.equal(collisionResult.worldCounts['$base_prefix_resume_world$'],0,'collision must not enter saved-world reorder');
 row('state-not-ready',prefix,prefix,false,{...state,ready:false});
 row('delta-over-admission-bound',prefix,prefix,false,{...state,delta:1048577});
 row('stamp-over-delta',prefix,prefix,false,{...state,stamp:state.delta+1});
 assert.equal(digest(prepared),preparedHash,'final immutable world');

 report.todoControls=[];
 const atom64=(tag,name='',id=0,kids=[])=>({$:'KTerm',tag,name,id,quant:0,kids:list(kids),removed:list([]),originBegin:23,originEnd:29});
 const literal64=n=>({$:'KLiteral',kind:'U32',number:n,text:'',originBegin:31,originEnd:32});
 const def64=(name,value,nativeFlag=false)=>({$:'KDef',name,kind:'Def',arity:0,templates:0,typ:atom64('Ref','U32'),value,ctors:list([]),native:nativeFlag,unsafe:nativeFlag});
 const hole64=()=>atom64('Hol','TODO'),suffixHole=def64('phase64.suffix.todo',hole64());
 function todoRow(id,p,s,pw,expectedTodos,visibleError='',ready=true){
  const whole=list([...p,...s]),full=Q.full(whole),expected=Q.complete(whole,full),before=digest(pw);
  const load={$:'FPrefixLoad',trace:{$:'FLoadTrace',result:{$:'FResult',book:whole,error:'',imports:list([])},done:list([]),sources:list([])},prefix:list(p),suffix:list(s),ready};
  assert.equal(Q.todos(whole),expectedTodos,id+' independent TODO count');
  const at=Q.todoBooks.length,actual=native.check_program_diagnostic_world(load,list([]),pw),counted=Q.todoBooks.slice(at);
  assert.deepEqual(actual,expected,id+' complete result');assert.equal(digest(pw),before,id+' immutable prepared world');contextRow(id,actual,load,pw,ready);
  if(visibleError){assert(actual.error.includes(visibleError),id+' selected first error');assert(!actual.error.includes('TODO'),id+' checker error before TODO');assert.equal(counted.length,0,id+' failed check must not count TODO');}
  else{assert.equal(full.result.error,'',id+' checker accepted');assert.equal(counted.length,1,id+' one final count');assert.deepEqual(counted[0],ready?list(s):whole,id+' only actual suffix counted on admitted completion');if(expectedTodos)assert(actual.error.includes(expectedTodos+' TODO'),id+' TODO completion diagnostic');else assert.equal(actual.error,'',id+' complete');}
  report.todoControls.push({id,pass:true,ready,expectedTodos,error:actual.error,outcome:digest(actual),countCalls:counted.length});save();
 }
 todoRow('suffix-TODO',prefix,[suffixHole],prepared,1);
 todoRow('suffix-law-fill',prefix,[def64('phase64.claim',atom64('Absent')),def64('phase64.claim',literal64(7))],prepared,0);
 todoRow('duplicate-before-TODO',prefix,[def64('phase64.duplicate',literal64(7)),def64('phase64.duplicate',literal64(8)),suffixHole],prepared,1,'duplicate declaration');
 todoRow('undefined-before-TODO',prefix,[def64('phase64.broken',atom64('Ref','phase64.missing')),suffixHole],prepared,1,'undefined name');
 todoRow('false-ready-full-completion',prefix,[suffixHole],prepared,1,'',false);
 const todoPrefix=[...prefix,def64('phase64.prefix.todo',hole64(),true)],todoState=Q.prepare(list(todoPrefix));
 assert(todoState.ready,'Actual prefix TODO producer must admit; a refusal is not a TODO-fact pass');
 const todoWorld=freeze(Q.prepareWorld(list(todoPrefix),todoState));assert.equal(todoWorld.todos,1,'Nonzero original prefix TODO fact');
 todoRow('prefix-TODO',todoPrefix,[],todoWorld,1);
 todoRow('prefix-and-suffix-TODO',todoPrefix,[suffixHole],todoWorld,2);
 const actualTodoSources=[['typed-suffix-TODO','selfhost/tests/phase8-bootstrap/fixtures/todo.bend',1],['typed-law-fill','selfhost/tests/frontend/phase5-imported-freshness/ordinary-law-fill.bend',0]];
 for(const [id,relative,want]of actualTodoSources){const source=pin(path.resolve(import.meta.dirname,'../../../../..',relative)),graph=D.discoverSources(api,source.file);for(const f of graph.files)pin(f);assert.equal(graph.loadTrace.result.error,'',id+' frontend');const all=array(graph.loadTrace.result.book);assert(Q.exact(list(all.slice(0,prefix.length)),base.book),id+' exact Base');todoRow(id,prefix,all.slice(prefix.length),prepared,want);}

 // Real source specializations must contribute their generated IDs and terms.
 const templateSources=[['dependent-template','tests/comptime/dep_params.bend'],['nested-template','tests/comptime/nested_arg.bend']];
 for(const [id,relative]of templateSources){const source=pin(path.resolve(import.meta.dirname,'../../../../..',relative)),graph=D.discoverSources(api,source.file);for(const f of graph.files)pin(f);assert.equal(graph.loadTrace.result.error,'',id+' frontend');const all=array(graph.loadTrace.result.book);assert(Q.exact(list(all.slice(0,prefix.length)),base.book),id+' exact Base');row(id,all,prefix,true);const evidence=report.contextControls.find(x=>x.id===id);assert(evidence&&evidence.optimized&&evidence.syntheticDefinitions.length>0,id+' generated specialization covered');}
 // These deliberately malformed books only exercise explicit refusal guards.
 // Arbitrary same-length forged books are outside the private owned API contract.
 const emptyLoad={$:'FPrefixLoad',trace:{$:'FLoadTrace',result:{$:'FResult',book:base.book,error:'',imports:list([])},done:list([]),sources:list([])},prefix:base.book,suffix:list([]),ready:true};
 const arbitrary=list([dType,nested]);
 contextRow('fallback-raw-unready',{book:arbitrary,error:''},{...emptyLoad,ready:false},prepared,false);
 contextRow('fallback-load-error',{book:arbitrary,error:''},{...emptyLoad,trace:{...emptyLoad.trace,result:{...emptyLoad.trace.result,error:'fixture loader error'}}},prepared,false);
 contextRow('fallback-short-assembled',{book:list([]),error:''},emptyLoad,prepared,false);
 contextRow('fallback-cached-assembled',{book:native.book_context(arbitrary),error:''},emptyLoad,prepared,false);
 const refusedWorld=freeze(Q.prepareWorld(base.book,{...state,ready:false}));
 contextRow('fallback-refused-world',{book:arbitrary,error:''},emptyLoad,refusedWorld,false);
 assert(report.contextControls.some(x=>x.optimized),'No checked-context admission exercised');assert(report.contextControls.some(x=>!x.optimized),'No checked-context fallback exercised');

 }
 report.prepareCounts=prepareCounts;report.checkpointSha256=stateHash;report.counts={actualSources:focused?0:sourceArgs.length,rows:report.rows.length,admitted:report.rows.filter(r=>r.admitted).length,fallback:report.rows.filter(r=>!r.admitted).length};
 for(const r of inputs.values())pin(r.file,r);report.complete=true;report.pass=true;save();
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};save();throw error;}
