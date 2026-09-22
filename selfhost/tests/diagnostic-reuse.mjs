// End-to-end parity of suffix diagnostics and request-local loader provenance.
// Usage: node --stack-size=4096 tests/diagnostic-reuse.mjs CANDIDATE_B1 BASELINE_B1 NEW_OUTPUT
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {pathToFileURL,fileURLToPath} from 'node:url';import {createHash} from 'node:crypto';import {spawnSync} from 'node:child_process';
const root=path.resolve(import.meta.dirname,'..');
if(process.argv[2]==='--host-worker'){
 const request=JSON.parse(fs.readFileSync(process.argv[3]));process.env.BEND_TYPED_API=request.api;process.env.BEND_BASE=request.base;process.env.BEND_TYPED_RUNTIME=request.runtime;
 const D=await import('../tools/typed-driver.mjs'),api=await D.loadApi();const calls={};for(const [name,fn] of Object.entries(api))if(typeof fn==='function'){api[name]=(...args)=>{const start=performance.now();try{return fn(...args)}finally{const item=calls[name]??={count:0,milliseconds:0};item.count++;item.milliseconds+=performance.now()-start;}};}
 const cache=await D.prepareBase(api),rows=[];for(const file of request.files){const start=performance.now(),result=await D.inspect(file,{mode:'check',api});rows.push({file,milliseconds:performance.now()-start,result});}fs.writeFileSync(request.output,JSON.stringify({rows,calls,cache:{compilerSha256:cache.compilerSha256,baseSha256:cache.baseSha256,bookSha256:cache.bookSha256,sourcePath:cache.sourcePath}},null,2));
}else{
 const [candidateArg,baselineArg,outputArg]=process.argv.slice(2);if(!outputArg)throw Error('Expected CANDIDATE_B1 BASELINE_B1 NEW_OUTPUT_DIRECTORY');
 const candidate=fs.realpathSync(candidateArg),baseline=fs.realpathSync(baselineArg),out=path.resolve(outputArg);fs.mkdirSync(out,{recursive:false});
 const upstream=fs.realpathSync(process.env.BEND_UPSTREAM||path.join(root,'.bootstrap/upstream')),base=path.join(upstream,'bend2/base.bend'),runtime=path.join(root,'src/runtime.mjs'),driver=path.join(root,'tools/typed-driver.mjs');
 const hash=file=>createHash('sha256').update(fs.readFileSync(file)).digest('hex'),valueHash=value=>createHash('sha256').update(JSON.stringify(value)).digest('hex');
 const files=[candidate,baseline,base,runtime,driver,fileURLToPath(import.meta.url),...['assemble','compiler-abi','node-resource-args','native-build'].map(n=>path.join(root,'tools',n+'.mjs'))];
 const identity=Object.fromEntries(files.map(file=>[file,{canonicalPath:fs.realpathSync(file),sha256:hash(file)}]));
 const report={kind:'diagnostic-and-loader-trace-equivalence',started:new Date().toISOString(),complete:false,node:{path:process.execPath,version:process.version,args:process.execArgv},identity,checks:0,rows:[],failures:[],scope:'Checked emitted Bend API candidate versus frozen B1 and independent legacy diagnostic/origin entry points. No correctness inferred from timing.'};
 const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
 const K=(await import(pathToFileURL(candidate))).default,B=(await import(pathToFileURL(baseline))).default;
 for(const name of ['check_book_diagnostic_from_exact_prefix','f_load_graph_trace','f_load_graph_seed_trace','f_loaded_origins_for'])assert.equal(typeof K[name],'function','Required candidate export '+name);
 const nil={$:'Nil'},list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil),array=x=>{const xs=[];for(;x.$==='Con';x=x.tail)xs.push(x.head);assert.equal(x.$,'Nil');return xs;};
 const eq=(actual,wanted,label)=>{report.checks++;assert.deepEqual(actual,wanted,label);};
 const run=(id,fn)=>{const start=performance.now();try{const data=fn();report.rows.push({id,pass:true,milliseconds:performance.now()-start,...data});}catch(error){report.rows.push({id,pass:false,milliseconds:performance.now()-start,error:error.message});report.failures.push({id,error:error.stack});}save();};
 const fixture=(id,text)=>{const file=path.join(out,'fixtures',id);fs.mkdirSync(path.dirname(file),{recursive:true});fs.writeFileSync(file,text);identity[file]={canonicalPath:fs.realpathSync(file),sha256:hash(file)};return file;};
 const source=(file,text,name=file)=>({$:'FSource',name,path:file,text});
 const prelude='type Flag is Data:\n  On{}\n  Off{}\n\n';
 const samples=[
 ['undefined','def main() -> Flag:\n  absent\n'],
 ['context','def use(x: Flag) -> Flag:\n  absent\n'],
 ['wrong-family','type Other is Data:\n  Other{}\ndef main() -> Flag:\n  Other{}\n'],
 ['unknown-constructor','def main() -> Flag:\n  Never{}\n'],
 ['field-arity','type Box is Data:\n  Mk{value: Flag}\ndef main() -> Box:\n  Mk{}\n'],
 ['termination','def loop(x: Flag) -> Flag:\n  loop(x)\n'],
 ['dependent','def wrong(x: Flag) -> Type:\n  x\n'],
 ['affine','type Pair is Data:\n  Pair{first: Flag, second: Flag}\ndef dup(x: Flag) -> Pair:\n  Pair{x, x}\n'],
 ['law-fill','law main:\n  Flag\ndef main():\n  missing\n'],
 ['open-law','law main:\n  Flag\n'],
 ['positive','def main() -> Flag:\n  On{}\n'],
 ['unicode','def value() -> Flag:\n  # 😀 UTF16 source offset\n  absent\n'],
 ['first-error-order','def first() -> Flag:\n  missing_first\ndef later() -> Flag:\n  missing_later\n'],
 ];
 const hostFixtures=[];
 for(const [id,body] of samples){const text=prelude+body,file=fixture(id+'.bend',text);hostFixtures.push(file);run(id,()=>{
  const sources=list([source(file,text)]),trace=K.f_load_graph_trace(file,sources),old=B.f_load_graph(file,sources);eq(trace.result,old,'loaded graph');eq(trace.result.error,'','case must reach checker');
  const prefix=K.f_load_graph(file,list([source(file,prelude)])).book;eq(K.check_book(prefix),'','prefix independently valid');eq(K.exact_prefix(trace.result.book,prefix),true,'exact parsed prefix');
  const reference=B.check_book_diagnostic(old.book,nil),legacy=K.check_book_diagnostic(trace.result.book,nil),fast=K.check_book_diagnostic_from_exact_prefix(trace.result.book,prefix,nil);
  eq(legacy,reference,'unchanged legacy detailed result');eq(fast,legacy,'independent suffix detailed result');eq(fast.error,K.check_from_exact_prefix(trace.result.book,prefix),'authoritative exact-prefix verdict');
  assert.equal(!!fast.error,id!=='positive','expected acceptance');
  const name=fast.diagnostic.definition,origins=K.f_loaded_origins_for(trace,name),prior=B.f_load_origins_for(file,sources,name);eq(origins,prior,'origins including final freshened terms');
  const located=K.diagnostic_result_locate(fast,origins.origins),locatedReference=B.diagnostic_result_locate(reference,prior.origins);eq(located,locatedReference,'full located diagnostic');eq(K.diagnostic_render(located),B.diagnostic_render(locatedReference),'exact rendered diagnostic');
  const parsed=K.f_source_parsed(file,file,text,K.f_parse(text));eq(K.f_load_graph_trace(file,list([parsed])),{...trace,sources:list([parsed])},'parsed source trace equivalent');
  return {error:fast.error,definition:name,resultSha256:valueHash(located),origins:array(origins.origins).length};
 });}
 // Mutate every KDef and KTerm prefix field: diagnostics must take legacy fallback.
 run('complete-prefix-mismatch-guards',()=>{const file=fixture('prefix-guards.bend',prelude+'def main() -> Flag:\n  missing\n'),sources=list([source(file,fs.readFileSync(file,'utf8'))]),book=K.f_load_graph(file,sources).book,prefix=K.f_load_graph(file,list([source(file,prelude)])).book,head=prefix.head,wanted=K.check_book_diagnostic(book,nil);
 const mutations=Object.entries({name:'Other',kind:'Def',arity:1,templates:1,native:true,unsafe:true,typ:{...head.typ,id:999},value:{...head.value,tag:'Ctr',name:'On'},ctors:nil}).map(([field,value])=>[field,{...prefix,head:{...head,[field]:value}}]);
 for(const [field,value] of Object.entries({tag:'Ref',name:'Other',id:999,quant:1,kids:nil,removed:list(['On'])}))mutations.push(['term.'+field,{...prefix,head:{...head,typ:{...head.typ,[field]:value}}}]);
 for(const [field,changed] of mutations){eq(K.exact_prefix(book,changed),false,field);eq(K.check_book_diagnostic_from_exact_prefix(book,changed,nil),wanted,'fallback '+field);}return {mutations:mutations.length};
 });
 run('duplicate-core-event-guard',()=>{const file=fixture('duplicate-core.bend',prelude+'def value() -> Flag:\n  On{}\n'),loaded=K.f_load_graph(file,list([source(file,fs.readFileSync(file,'utf8'))])),events=array(loaded.book),book=list([...events,events.at(-1)]),prefix=list(events.slice(0,1));eq(K.check_book(prefix),'');const want=B.check_book_diagnostic(book,nil),actual=K.check_book_diagnostic_from_exact_prefix(book,prefix,nil);assert.match(want.error,/duplicate|already|redefin/);eq(actual,want,'first duplicate event guard');eq(actual.error,K.check_from_exact_prefix(book,prefix));return {diagnosticError:actual.error};});
 // Diamond imports, qualified aliases, beta substitution, repeated law/fill events.
 run('diamond-import-origin-trace',()=>{const directory=path.join(out,'fixtures/graph'),dep=fixture('graph/shared.bend',prelude+'law broken:\n  Flag\ndef broken():\n  (x => x)(Missing)\n'),left=fixture('graph/left.bend','import ./shared.bend as S\ndef left() -> S.Flag:\n  S.On{}\n'),right=fixture('graph/right.bend','import ./shared.bend as S\ndef right() -> S.Flag:\n  S.On{}\n'),main=fixture('graph/main.bend','import ./left.bend as L\nimport ./right.bend as R\ndef main() -> L.Flag:\n  L.left()\n');
 const sources=list([main,left,right,dep].map(file=>source(file,fs.readFileSync(file,'utf8')))),trace=K.f_load_graph_trace(main,sources);eq(trace.result,B.f_load_graph(main,sources),'diamond loaded book');eq(trace.result.error,'','diamond must load');eq(array(trace.done).reduce((n,e)=>n+e.id,0),array(trace.result.book).length,'exact declaration event counts');
 const names=[...new Set(array(trace.result.book).map(d=>d.name)),'not-present'];for(const name of names)eq(K.f_loaded_origins_for(trace,name),B.f_load_origins_for(main,sources,name),'diamond origins '+name);
 return {modules:array(trace.done).length,names};
 });
 // Errors must retain the actual loader's verdict and avoid inventing origins.
 for(const [id,text] of [['parse-error','def main(\n'],['missing-import','import ./absent.bend as Missing\n'],['cycle','import ./cycle.bend as Cycle\n'],['duplicate-source',prelude+'def value() -> Flag:\n  On{}\ndef value() -> Flag:\n  Off{}\n']])run(id,()=>{const file=fixture(id+'.bend',text),sources=list([source(file,text)]),trace=K.f_load_graph_trace(file,sources),old=B.f_load_graph(file,sources);eq(trace.result,old);assert.ok(old.error);if(id==='missing-import')assert.match(old.error,/module source was not supplied/);if(id==='cycle')assert.match(old.error,/cyclic import/);eq(K.f_loaded_origins_for(trace,'main'),B.f_load_origins_for(file,sources,'main'));return {error:old.error};});
 let baseBook;
 run('base-seed-and-targeted-origins',()=>{const text=fs.readFileSync(base,'utf8'),baseSource=source(base,text,'Base');baseBook=K.f_load_graph('Base',list([baseSource])).book;eq(K.check_book(baseBook),'','real Base independently validated');
 const input=path.join(upstream,'tests/base/bytes_ops.bend'),sources=list([source(input,fs.readFileSync(input,'utf8')),baseSource]);identity[input]={canonicalPath:input,sha256:hash(input)};hostFixtures.push(input);
 const before=valueHash({baseBook,sources}),trace=K.f_load_graph_seed_trace(input,sources,base,text,baseBook),old=B.f_load_graph(input,sources);eq(trace.result,old,'seeded versus original unseeded graph');eq(K.exact_prefix(old.book,baseBook),true,'Base exact prefix');
 const fast=K.check_book_diagnostic_from_exact_prefix(old.book,baseBook,nil),legacy=B.check_book_diagnostic(old.book,nil);eq(fast,legacy,'real Base suffix detailed result');eq(fast.error,K.check_from_exact_prefix(old.book,baseBook),'independent authoritative error');assert.ok(fast.error);
 const provenance=K.f_loaded_origins_for(trace,fast.diagnostic.definition),prior=B.f_load_origins_for(input,sources,fast.diagnostic.definition);eq(provenance,prior,'seeded actual trace origins');eq(K.diagnostic_render(K.diagnostic_result_locate(fast,provenance.origins)),B.diagnostic_render(B.diagnostic_result_locate(legacy,prior.origins)),'seeded final diagnostic');eq(valueHash({baseBook,sources}),before,'calls must not mutate caller graph/prefix');
 return {error:fast.error,bookSha256:valueHash(baseBook),origins:array(provenance.origins).length};
 });
 run('seed-source-and-canonical-path-invalidation',()=>{assert.ok(baseBook);const text=fs.readFileSync(base,'utf8'),input=fixture('seed-mutation.bend','import Base\ndef main() -> U32:\n  1\n');for(const [id,changed] of [['text',source(base,text+'\ndef trace_extra() -> U32:\n  7\n','Base')],['path',source(base+'.different',text,'Base')]]){const sources=list([source(input,fs.readFileSync(input,'utf8')),changed]);eq(K.f_load_graph_seed_trace(input,sources,base,text,baseBook).result,K.f_load_graph(input,sources),'invalidate '+id);}return {changed:['text','canonical path']};});
 // Real host selection: exact diagnostics, status, phase and checked flag, with
 // separate compiler-keyed validated Base caches for baseline and candidate.
 const hostResults={};for(const [variant,api] of [['candidate',candidate],['baseline',baseline]]){const request={api,base,runtime,files:hostFixtures,output:path.join(out,'host-'+variant+'.json')},file=path.join(out,'host-'+variant+'-request.json');fs.writeFileSync(file,JSON.stringify(request));const child=spawnSync(process.execPath,['--stack-size=4096','--max-old-space-size=4096',fileURLToPath(import.meta.url),'--host-worker',file],{encoding:'utf8',timeout:120000,maxBuffer:1024*1024});assert.equal(child.status,0,child.stderr);hostResults[variant]=JSON.parse(fs.readFileSync(request.output));}
 run('host-exact-rejection-parity',()=>{eq(hostResults.candidate.rows.map(r=>r.result),hostResults.baseline.rows.map(r=>r.result),'all full inspect results');assert.ok(hostResults.candidate.calls.f_load_graph_seed_trace?.count>0,'host uses seeded trace');assert.ok(hostResults.candidate.calls.check_book_diagnostic_from_exact_prefix?.count>0,'host uses validated prefix diagnostic');assert.ok(hostResults.candidate.calls.f_loaded_origins_for?.count>0,'host uses original trace');return {cases:hostFixtures.length,candidateCalls:hostResults.candidate.calls,baselineCalls:hostResults.baseline.calls};});
 report.host=hostResults;
 for(const [file,old] of Object.entries(identity)){assert.equal(fs.realpathSync(file),old.canonicalPath);assert.equal(hash(file),old.sha256,'Consumed artifact changed: '+file);}report.complete=report.failures.length===0;report.finished=new Date().toISOString();save();console.log(JSON.stringify({output:out,checks:report.checks,rows:report.rows.map(r=>({id:r.id,pass:r.pass,error:r.error})),complete:report.complete}));assert.equal(report.complete,true,'See retained exact parity failures');
}
