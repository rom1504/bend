// Root runs this controller under the single Phase63 process-tree guard.
// Usage: node frontend-controls.mjs CHECKED_ATTEMPT SOURCE [SOURCE...] NEW_OUT
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../development/workflow.mjs';

const [attemptArg,...args]=process.argv.slice(2),outArg=args.pop(),sourceArgs=args;
assert(attemptArg&&sourceArgs.length&&outArg);
const out=path.resolve(outArg),raw=path.resolve(import.meta.dirname,'../../../build/phase63');
assert(out.startsWith(raw+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=b=>createHash('sha256').update(b).digest('hex'),digest=x=>hash(JSON.stringify(x)),inputs=new Map();
const list=a=>a.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
function array(xs){const a=[];while(xs?.$==='Con'){assert(a.length<65536);a.push(xs.head);xs=xs.tail;}assert.equal(xs?.$,'Nil');return a;}
function pin(file,want){const b=fs.readFileSync(file),r={file:fs.realpathSync(file),sha256:hash(b),bytes:b.length};if(want)assert.equal(r.sha256,want.sha256);if(inputs.has(r.file))assert.deepEqual(r,inputs.get(r.file));inputs.set(r.file,r);return r;}
function freeze(value){const todo=[value],seen=new Set();while(todo.length){const x=todo.pop();if(x===null||typeof x!=='object'||seen.has(x))continue;seen.add(x);Object.freeze(x);todo.push(...Object.values(x));}return value;}
const report={kind:'phase63-ready-frontend-controls',complete:false,pass:false,scope:'Exact old/full versus ready carrier traces, parser outcomes, indexes and immutable state. Private prepared-state/Base coupling is a host obligation; public forged seed metadata must not select ready APIs. No compiler-speed or checker-soundness claim.',rows:[],producerControls:[],indexControls:[],publicControls:[],inputs:[]};
function save(){report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');}
save();
try{
  pin(import.meta.filename);pin(process.execPath);pin(new URL('../../development/workflow.mjs',import.meta.url).pathname);
  const directory=fs.realpathSync(attemptArg),attempt=pin(path.join(directory,'attempt.json')),m=await verifyAttempt(directory);
  assert(m.checked&&m.config.strictExact);for(const key of ['api','runtime','base','node'])pin(m[key].file,m[key]);assert.equal(pin(process.execPath).sha256,m.node.sha256);
  for(const file of ['src/load/prefix.bend','src/load/modules.bend','src/load/graph.bend','src/front/validate.bend','src/core/index.bend'])pin(path.join(m.snapshot.root,file));
  const driver=pin(path.join(m.snapshot.root,'tools/typed-driver.mjs'));pin(path.join(m.snapshot.root,'tools/base-cache-graph.mjs'));
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
  process.env.BEND_TYPED_API=m.api.file;process.env.BEND_TYPED_RUNTIME=m.runtime.file;process.env.BEND_BASE=m.base.file;
  const D=await import(pathToFileURL(driver.file)),api=await D.loadApi();
  for(const name of ['f_ready_prefix_prepare','f_prefix_complete_ready_seed','f_prefix_graph_empty','f_prefix_complete_seed','f_prefix_complete_source','f_prefix_graph_trace'])assert.equal(typeof api[name],'function',name);
  const rawBase={$:'FSource',name:'Base',path:m.base.file,text:fs.readFileSync(m.base.file,'utf8')};
  const located=api.f_source_located(rawBase,1,rawBase.text.length+2),base=api.f_load_graph('Base',list([located]));assert.equal(base.error,'');freeze(base.book);
  const prefix=array(base.book),state=freeze(api.f_ready_prefix_prepare(base.book)),fresh=freeze(api.f_fresh_prefix_prepare(base.book));
  assert(state.ready&&fresh.ready);assert.equal(state.count,prefix.length);const immutableBefore=digest({book:base.book,state,fresh});
  report.candidate={attempt,api:m.api,runtime:m.runtime,base:m.base,node:m.node,driver};report.prepared={sha256:digest(state),count:state.count,bookSha256:digest(base.book),freshSha256:digest(fresh)};save();
  function entries(tree){const found=new Map(),todo=[tree];while(todo.length){const x=todo.pop();if(x.$==='KIndexNode'){todo.push(x.right,x.left);continue;}if(x.$==='KIndexLeaf'){for(const d of array(x.bucket)){assert(!found.has(d.name));found.set(d.name,d);}continue;}assert.equal(x.$,'KDef');assert.equal(x.kind,'Absent');}return found;}
  function names(book){const found=new Map();for(const d of array(book))found.set(d.name,d);return found;}
  function ctors(book){const found=new Map(),todo=[...array(book)].reverse();while(todo.length){const d=todo.pop();if(d.kind==='Ctr'&&!found.has(d.name))found.set(d.name,d);todo.push(...array(d.ctors).reverse());}return found;}
  function sameIndex(actual,expected,label){const got=entries(actual);assert.equal(got.size,expected.size,label+' size');for(const [name,d]of expected)assert.deepEqual(got.get(name),d,label+' '+name);}
  sameIndex(state.names,names(base.book),'prepared names');sameIndex(state.ctors,ctors(base.book),'prepared ctors');
  const seed={book:base.book,sourcePath:m.base.file,sourceText:rawBase.text,spanAbi:api.compiler_span_abi(),sourceBegin:1,sourceEnd:rawBase.text.length+2};
  function observation(error){return {phase:error.phase??null,message:error.message,sourceFile:error.sourceFile??null};}
  function load(file,ready){let carrier=api.f_prefix_graph_empty(),steps=0,readySteps=0;const completed=[];
    const wrapped={...api,
      f_source_header:source=>{pin(sourcePath(source));return api.f_source_header(source);},
      f_complete_seed:(source,prior,p,t,b)=>{assert.deepEqual(prior,carrier.graph);const c=ready?api.f_prefix_complete_ready_seed(source,'',carrier,p,t,b,state):api.f_prefix_complete_seed(source,'',carrier,p,t,b);carrier=c.carrier;steps++;return {$:'FCompletion',graph:carrier.graph,parsed:c.parsed};},
      f_complete_source:(source,ns,header,sources,prior,root)=>{assert.deepEqual(prior,carrier.graph);const c=api.f_prefix_complete_source(source,ns,header,sources,carrier,root);carrier=c.carrier;steps++;if(carrier.$==='FReadyPrefixGraph'){readySteps++;sameIndex(carrier.names,names(carrier.graph.book),'carried names');sameIndex(carrier.ctors,ctors(carrier.graph.book),'carried ctors');}completed.push({source:sourcePath(source),ns,parsed:c.parsed,graph:carrier.graph});return {$:'FCompletion',graph:carrier.graph,parsed:c.parsed};}};
    try{const graph=D.discoverSources(wrapped,file,{seed});for(const f of graph.files)pin(f);const trace=api.f_prefix_graph_trace(carrier,graph.sources,fresh);assert.deepEqual(trace.trace,graph.loadTrace,'full graph versus private prefix trace');return {ok:true,carrier,trace:trace.trace,steps,readySteps,completed};}
    catch(error){if(error.name==='AssertionError')throw error;return {ok:false,error:observation(error),carrier,steps,readySteps,completed};}
  }
  function sourcePath(source){while(source.$==='FLocatedSource')source=source.source;return source.path;}
  const tests=path.resolve(import.meta.dirname,'../../../tests/frontend');
  const fixtures=[
    ['phase5-imported-freshness/ordinary-law-fill.bend',true],['phase5-imported-freshness/imported-law-fill.bend',true],
    ['phase5-imported-freshness/local-shadow.bend',true],['phase5-imported-freshness/ctor-top-name.bend',true],
    ['phase5-freshness/distinct-module-constructors.bend',true],['phase5-freshness/namespaced-base-shadow.bend',true],
    ['phase5-freshness/namespaced-base-constructor.bend',true],['phase5-final-backends/imported-positive.bend',true],
    ['phase5-imported-freshness/base-law-shadow.bend',false],['phase5-imported-freshness/base-type-shadow.bend',false],
    ['phase5-imported-freshness/malformed-imported-law-fill.bend',false],['phase5-imported-freshness/earlier-parse-error.bend',false],
    ['phase5-imported-freshness/later-parse-error.bend',false],['phase5-imported-freshness/native-open-law.bend',false]];
  const cases=[...sourceArgs.map(file=>[path.resolve(file),true]),...fixtures.map(([file,ok])=>[path.join(tests,file),ok])];
  for(const [file,expected]of cases){pin(file);const old=load(file,false),ready=load(file,true);assert.equal(old.ok,expected,file+' expected parser result');assert.equal(ready.ok,old.ok);assert.deepEqual(ready.error,old.error,file+' diagnostic');assert.deepEqual(ready.completed,old.completed,file+' every contextual completion');assert.deepEqual(ready.carrier.graph,old.carrier.graph,file+' graph');if(old.ok){assert.deepEqual(ready.trace,old.trace,file+' complete trace');assert.equal(ready.readySteps>0,old.carrier.ready,file+' ready path iff admitted leading prefix');}report.rows.push({file,pass:true,accepted:ready.ok,steps:ready.steps,readySteps:ready.readySteps,eligible:old.carrier.ready,error:ready.error??null,observationSha256:digest(ready.ok?ready.trace:ready.error)});save();}

  // Producer refusals use actual old fallback, not an imagined error marker.
  const initial=api.f_prefix_graph_empty(),notLeading={$:'FPrefixGraph',graph:{$:'FGraph',book:list([prefix[0]]),error:'',done:list([])},prefix:list([]),suffix:list([]),count:0,ready:false};
  const priorError={...initial,graph:{...initial.graph,error:'existing graph error'}};
  const producerCases=[['ordinary',initial,'',m.base.file,rawBase.text,state,true],['namespace',initial,'qualified',m.base.file,rawBase.text,state,false],['changed-path',initial,'',m.base.file+'.changed',rawBase.text,state,false],['changed-text',initial,'',m.base.file,rawBase.text+' ',state,false],['nonleading',notLeading,'',m.base.file,rawBase.text,state,false],['existing-error',priorError,'',m.base.file,rawBase.text,state,false],['ready-false',initial,'',m.base.file,rawBase.text,{...state,ready:false},false],['count-mismatch',initial,'',m.base.file,rawBase.text,{...state,count:state.count+1},false]];
  for(const [id,c,ns,p,t,s,admitted]of producerCases){const old=api.f_prefix_complete_seed(located,ns,c,p,t,base.book),next=api.f_prefix_complete_ready_seed(located,ns,c,p,t,base.book,s);assert.equal(next.carrier.$==='FReadyPrefixGraph',admitted,id);assert.deepEqual(next.carrier.graph,old.carrier.graph,id+' graph');assert.deepEqual(next.parsed,old.parsed,id+' parsed');for(const fsState of [fresh,{...fresh,ready:false}]){const a=api.f_prefix_graph_trace(next.carrier,list([located]),fsState),b=api.f_prefix_graph_trace(old.carrier,list([located]),fsState);assert.deepEqual(a.trace,b.trace,id+' trace');}report.producerControls.push({id,admitted,pass:true});save();}

  // Constructor order is first depth-first; names are latest top-level events.
  const atom=(tag,name='')=>({$:'KTerm',tag,name,id:0,quant:0,kids:list([]),removed:list([]),originBegin:0,originEnd:0});
  const def=(name,kind='Def',children=[],value=atom('Absent'))=>({$:'KDef',name,kind,arity:0,templates:0,typ:atom('Typ'),value,ctors:list(children),native:false,unsafe:false});
  const first={...def('Same','Ctr'),arity:1},later={...def('Same','Ctr'),arity:2},nested={...def('Deep','Ctr'),arity:3};
  const law=def('fill'),filled=def('fill','Def',[],atom('Ref','value'));
  const custom=list([def('A','ADT',[first,def('Nested','ADT',[nested])]),def('B','ADT',[later]),law,filled]);
  const customState=freeze(api.f_ready_prefix_prepare(custom));assert(customState.ready);sameIndex(customState.names,names(custom),'synthetic names');sameIndex(customState.ctors,ctors(custom),'synthetic ctors');assert.deepEqual(entries(customState.names).get('fill'),filled);assert.deepEqual(entries(customState.ctors).get('Same'),first);
  const customSource={$:'FSource',name:'Base',path:'/phase63/base.bend',text:'synthetic private prefix'},newDefs=list([def('C','ADT',[{...later,arity:4},def('New','Ctr')])]);
  const cs=api.f_prefix_complete_ready_seed(customSource,'',api.f_prefix_graph_empty(),customSource.path,customSource.text,custom,customState);
  const supplied=api.f_source_completed('module','/phase63/module.bend','synthetic private module',{$:'FResult',book:newDefs,error:'',imports:list([])}),header=api.f_source_header(supplied);
  for(const ns of ['','qualified']){const c=api.f_prefix_complete_source(supplied,ns,header,list([customSource,supplied]),cs.carrier,'/phase63');assert.equal(c.carrier.$,'FReadyPrefixGraph');sameIndex(c.carrier.names,names(c.carrier.graph.book),'extended synthetic names');sameIndex(c.carrier.ctors,ctors(c.carrier.graph.book),'extended synthetic ctors');assert.deepEqual(entries(c.carrier.ctors).get('Same'),first);report.indexControls.push({id:'constructor-order-'+(ns||'global'),pass:true,names:entries(c.carrier.names).size,ctors:entries(c.carrier.ctors).size});save();}

  // Callers cannot turn source-only or malformed raw seeds into private facts.
  const reordered=[...prefix];[reordered[0],reordered[1]]=[reordered[1],reordered[0]];
  const malformed=[{...prefix[0],value:atom('Error','phase63 malformed prefix')},...prefix.slice(1)];
  for(const [id,book]of [['original',prefix],['dropped',prefix.slice(1)],['reordered',reordered],['malformed',malformed]]){let selected=0;const deny={...api};for(const name of ['f_prefix_graph_empty','f_prefix_complete_seed','f_prefix_complete_ready_seed','f_prefix_complete_source','f_prefix_graph_trace'])deny[name]=()=>{selected++;throw Error('public seed selected private carrier');};const rawSeed={...seed,book:list(book)};const forged={...rawSeed,freshPrefixState:fresh,readyPrefixState:state,frontendState:state,frontendReadyState:state};const capture=s=>{try{return {ok:true,trace:D.discoverSources(deny,path.resolve(sourceArgs[0]),{seed:s,freshPrefixPermission:{},nativePrefixPermission:{}}).loadTrace};}catch(error){return {ok:false,error:observation(error)};}};const ordinary=capture(rawSeed),fake=capture(forged);assert.deepEqual(fake,ordinary,id+' public observation');assert.equal(selected,0,id+' private permission');report.publicControls.push({id,pass:true,accepted:fake.ok,observationSha256:digest(fake)});save();}
  assert.equal(digest({book:base.book,state,fresh}),immutableBefore,'prepared objects remain unchanged');
  for(const r of inputs.values())pin(r.file,r);report.complete=true;report.pass=true;save();
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};save();throw error;}
