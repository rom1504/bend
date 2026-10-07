// Root-supervised loader differential. No installed files or historical caches are written.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
import {identity,verify,hash,list,array} from '../../phase54/bootstrap/adapter.mjs';

const [baselineArg,candidateArg,outArg]=process.argv.slice(2);
assert(baselineArg&&candidateArg&&outArg,'BASELINE_ATTEMPT CANDIDATE_ATTEMPT FRESH_OUT');
const root=path.resolve(import.meta.dirname,'../../../../..'),raw=fs.realpathSync(path.join(root,'selfhost/build/phase61'));
const out=path.resolve(outArg);assert(out.startsWith(raw+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const inputs=new Map(),copies=[];
const pin=(file,want)=>{const r=identity(file);if(want)assert.equal(r.sha256,want.sha256);if(inputs.has(r.file))assert.deepEqual(inputs.get(r.file),r);inputs.set(r.file,r);return r;};
const digest=value=>hash(JSON.stringify(value));
const report={kind:'phase61-loader-prefix-controls',version:1,complete:false,pass:false,roles:{},sources:[],structural:[],inputs:[],copies,
 scope:'Actual checked old loader on both images and optional candidate prefix entry on identical complete graphs. Diagnostic exports and counters are append-only. Full FLoadTrace value equality plus actual suffix-only freshening is required. No cache authentication, whole compiler, latency or checker-state reuse qualification.'};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};save();
const term=(tag,name='',id=0,kids=[])=>({$:'KTerm',tag,name,id,quant:0,kids:list(kids),removed:list([]),originBegin:0,originEnd:0});
const definition=name=>({$:'KDef',name,kind:'Def',arity:0,templates:0,typ:term('Typ'),value:term('Typ'),ctors:list([]),native:false,unsafe:false});
const freeze=value=>{const todo=[value],seen=new Set();while(todo.length){const x=todo.pop();if(x===null||typeof x!=='object'||seen.has(x))continue;seen.add(x);Object.freeze(x);todo.push(...Object.values(x));}return value;};
const clone=value=>JSON.parse(JSON.stringify(value));
const firstTerm=(book,predicate)=>{const todo=array(book).flatMap(d=>[d.typ,d.value,...array(d.ctors)]);while(todo.length){const t=todo.pop();if(predicate(t))return t;if(t?.$==='KDef')todo.push(t.typ,t.value,...array(t.ctors));else if(t?.kids)todo.push(...array(t.kids));}throw Error('Required structural witness absent');};

try {
 for(const f of [import.meta.filename,process.execPath,new URL('../../../development/workflow.mjs',import.meta.url),new URL('../../phase54/bootstrap/adapter.mjs',import.meta.url)])pin(f);
 const catalogId=pin(path.join(root,'selfhost/tools/performance/phase60/catalog.json')),catalog=JSON.parse(fs.readFileSync(catalogId.file));assert(catalog.complete&&catalog.pass);
 const cases=['numeric-recurrence','test-evening-program','lexer'].map(id=>{const rows=catalog.compileInputs.filter(r=>r.id===id);assert.equal(rows.length,1);pin(rows[0].source.file,rows[0].source);return rows[0];});
 const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],P={exports:{}};new Function('module','exports',parserSource)(P,P.exports);
 const parse=s=>P.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
 const roles={};
 for(const [role,dirArg]of [['baseline',baselineArg],['candidate',candidateArg]]) {
  const dir=fs.realpathSync(dirArg),a=await verifyAttempt(dir);assert(a.checked&&a.config.strictExact);
  const attempt=pin(path.join(dir,'attempt.json'));for(const k of ['api','runtime','base','node','bootstrapReport'])pin(a[k].file,a[k]);assert.equal(identity(process.execPath).sha256,a.node.sha256);
  const validation=pin(path.join(dir,'validation-001/report.json')),v=JSON.parse(fs.readFileSync(validation.file));assert(v.complete&&v.pass&&v.strictExact&&v.selected.exactDifferences===0);assert.equal(v.attempt.sha256,attempt.sha256);assert.equal(v.api.sha256,a.api.sha256);
  const project=path.join(out,role),copy=(file,relative)=>{const before=pin(file),target=path.join(project,relative);fs.mkdirSync(path.dirname(target),{recursive:true});fs.copyFileSync(before.file,target,fs.constants.COPYFILE_EXCL);const after=pin(target);assert.equal(after.sha256,before.sha256);copies.push({before,after});return after;};
  for(const name of ['typed-driver','assemble','compiler-abi','node-resource-args','native-build'])copy(path.join(a.snapshot.root,'tools',name+'.mjs'),'tools/'+name+'.mjs');
  copy(path.join(a.snapshot.root,'src/compiler.json'),'src/compiler.json');const runtime=copy(a.runtime.file,'src/runtime.mjs');copy(path.join(a.snapshot.root,'src/runtime/js/direct.mjs'),'src/runtime/js/direct.mjs');
  const original=fs.readFileSync(a.api.file,'utf8'),ast=parse(original),names=['run_loop','$f_graph_trace$','$f_fresh_defs$'];
  if(role==='candidate')names.push('$f_fresh_prefix_prepare$','$f_graph_trace_from_prefix$','$f_fresh_prefix_finish$');
  for(const name of names)assert.equal(ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id?.name===name).length,1,name);
  assert(!original.includes('phase61Fresh'));
  let suffix=`\nexport const phase61FreshOld=(g,s)=>run_loop($f_graph_trace$(g,s));\n`;
  if(role==='candidate')suffix+=`export const phase61Fresh={
prepare:p=>run_loop($f_fresh_prefix_prepare$(p)),
trace:(g,s,p,state)=>{const previous=$f_fresh_defs$,finish=$f_fresh_prefix_finish$,calls=[];let selected=0;
$f_fresh_defs$=(book,next)=>{let n=0,x=book;while(x.$==='Con'){n++;x=x.tail;}if(x.$!=='Nil')throw Error('Bad diagnostic list');calls.push({events:n,next});return previous(book,next);};
$f_fresh_prefix_finish$=(...args)=>{selected++;return finish(...args);};
try{return {trace:run_loop($f_graph_trace_from_prefix$(g,s,p,state)),calls,selected};}
finally{$f_fresh_defs$=previous;$f_fresh_prefix_finish$=finish;}}};\n`;
  parse(original+suffix);const apiFile=path.join(project,'dist/api.mjs');fs.mkdirSync(path.dirname(apiFile),{recursive:true});fs.writeFileSync(apiFile,original+suffix,{flag:'wx'});assert(fs.readFileSync(apiFile).subarray(0,Buffer.byteLength(original)).equals(fs.readFileSync(a.api.file)));
  const derived=pin(apiFile),module=await import(pathToFileURL(apiFile));assert.equal(module.G,undefined);
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];process.env.BEND_TYPED_API=apiFile;process.env.BEND_TYPED_RUNTIME=runtime.file;process.env.BEND_BASE=a.base.file;
  const D=await import(pathToFileURL(path.join(project,'tools/typed-driver.mjs'))),api=await D.loadApi();assert.equal(D.apiPath,apiFile);assert.equal(api,module.default);
  const baseText=fs.readFileSync(a.base.file,'utf8'),basePath=fs.realpathSync(a.base.file),end=baseText.length+2;
  const loaded=api.f_load_graph('Base',list([api.f_source_located({$:'FSource',name:'Base',path:basePath,text:baseText},1,end)]));assert.equal(loaded.error,'');
  const prefix=freeze(loaded.book),seed={book:prefix,sourcePath:basePath,sourceText:baseText,spanAbi:3,sourceBegin:1,sourceEnd:end};
  const state=role==='candidate'?freeze(module.phase61Fresh.prepare(prefix)):null;if(state){assert.equal(state.$,'FFreshPrefixState');assert.equal(state.ready,true);assert(Number.isInteger(state.next)&&state.next>1);}
  roles[role]={a,project,D,api,module,prefix,state,seed,graphs:new Map()};
  report.roles[role]={attempt,validation,api:a.api,derivative:derived,suffixSha256:hash(suffix),prefixEvents:array(prefix).length,prefixSha256:digest(prefix),state,productionAbiChanged:false};save();
  for(const c of cases) {
   let captured=null;const capture={...api,f_graph_trace:(g,s)=>{assert.equal(captured,null);captured={graph:g,sources:s};return api.f_graph_trace(g,s);}};
   const found=D.discoverSources(capture,c.source.file,{seed});assert(captured);for(const f of found.files)pin(f);assert.equal(found.loadTrace.result.error,'');
   assert.deepEqual(module.phase61FreshOld(captured.graph,captured.sources),found.loadTrace);freeze(captured);roles[role].graphs.set(c.id,{...captured,trace:found.loadTrace});
  }
  assert(!fs.existsSync(path.join(project,'build/typed/cache')),'Loader-only control must not write a cache');
 }
 assert.equal(roles.baseline.a.base.sha256,roles.candidate.a.base.sha256);assert.deepEqual(roles.baseline.prefix,roles.candidate.prefix);
 const C=roles.candidate,B=roles.baseline,Q=C.module.phase61Fresh;
 const compare=(name,graph,sources,prefix,state,selected,expectedNext)=>{
  freeze(graph);freeze(sources);freeze(prefix);freeze(state);const before=digest([graph,sources,prefix,state]);
  const old=C.module.phase61FreshOld(graph,sources),baseline=B.module.phase61FreshOld(graph,sources);assert.deepEqual(old,baseline,name+': original images');
  const actual=Q.trace(graph,sources,prefix,state);assert.deepEqual(actual.trace,old,name+': complete FLoadTrace');assert.equal(actual.selected,selected,name+': actual selected entry');assert.equal(actual.calls.length,1,name+': exactly one freshener call');
  assert.equal(actual.calls[0].next,expectedNext,name+': fresh ID floor');assert.equal(actual.calls[0].events,array(graph.book).length-(selected?array(prefix).length:0),name+': freshened event count');
  assert.equal(digest([graph,sources,prefix,state]),before,name+': immutable inputs');
  return {name,pass:true,resultSha256:digest(actual.trace),selected:actual.selected,fresheningCalls:actual.calls};
 };
 for(const c of cases){const b=B.graphs.get(c.id),x=C.graphs.get(c.id);assert.deepEqual(x.trace,b.trace,c.id+': actual source graph');report.sources.push({...compare(c.id,x.graph,x.sources,C.prefix,C.state,1,C.state.next),source:c.source});save();}
 const x=C.graphs.get(cases[0].id),whole=()=>clone(x.graph),sources=x.sources,add=(name,g,p=C.prefix,s=C.state,selected=0,next=1)=>{report.structural.push(compare(name,g,sources,p,s,selected,next));save();};
 add('false-ready',whole(),C.prefix,{...C.state,ready:false});
 const nonleading=whole();nonleading.book={$:'Con',head:definition('prefix_control_before'),tail:nonleading.book};add('nonleading-prefix',nonleading);
 const prefixTerms=g=>list(array(g.book).slice(0,array(C.prefix).length));
 const span=whole();firstTerm(prefixTerms(span),t=>t?.$==='KLambda').originBegin++;add('changed-prefix-span',span);
 const quantity=whole();const q=firstTerm(prefixTerms(quantity),t=>t?.$==='KLambda');q.quantityPresent=!q.quantityPresent;add('changed-prefix-quantity',quantity);
 const variant=whole();const z=firstTerm(prefixTerms(variant),t=>t?.$==='KLambda');z.$='KTerm';z.tag='Lam';delete z.quantityPresent;add('changed-prefix-variant',variant);
 const error=whole();error.error='loader prefix error control';add('prior-error',error);
 const termError=whole();termError.book.head.value=term('Error','loader prefix term error control');add('term-error',termError);
 const duplicate=whole();duplicate.book=list([...array(duplicate.book),duplicate.book.head]);add('duplicate-name',duplicate);
 const empty=list([]),emptyState=Q.prepare(empty);assert(emptyState.ready);add('empty-prefix',whole(),empty,emptyState,1,1);
 const justPrefix={...whole(),book:C.prefix};add('empty-suffix',justPrefix,C.prefix,C.state,1,C.state.next);
 const shifted=clone(C.prefix);firstTerm(shifted,t=>t?.$==='KLambda').id+=7;const refused=Q.prepare(shifted);assert.equal(refused.ready,false);add('noncanonical-preparation',whole(),shifted,refused);
 // Real grammar constructs above cover ordinary terms; this isolated canonical
 // term exercises All-domain reservation and parallel Let RHS IDs explicitly.
 const synthetic=definition('prefix_syntax');synthetic.typ=term('All','a',99,[term('Typ'),term('Typ')]);synthetic.value=term('Let','',0,[term('Bind','x',80,[term('Lam','y',70,[term('Var','y',70)])]),term('Var','x',80)]);
 const syntheticGraph={$:'FGraph',book:list([synthetic]),error:'',done:list([])},canonical=C.module.phase61FreshOld(syntheticGraph,list([])).result.book,syntheticState=Q.prepare(canonical);assert(syntheticState.ready);
 report.structural.push(compare('All-Lam-parallel-Let',{$:'FGraph',book:list([...array(canonical),definition('prefix_suffix')]),error:'',done:list([])},list([]),canonical,syntheticState,1,syntheticState.next));
 for(const r of Object.values(roles)){assert(!fs.existsSync(path.join(r.project,'build/typed/cache')));await verifyAttempt(path.dirname(report.roles[r===C?'candidate':'baseline'].attempt.file));}
 for(const input of inputs.values())verify(input);report.complete=true;report.pass=true;save();
} catch(error) {report.error={name:error.name,message:error.message,stack:error.stack};save();throw error;}
