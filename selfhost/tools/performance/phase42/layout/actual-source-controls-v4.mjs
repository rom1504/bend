// Diagnostic scalar-owned adapters inspect exact emitted lexical workers; never admit host ADTs.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
import {warp,flow,summary,deepFlowExpected,u32} from '../review/oracles.mjs';
const[baseArg,candidateArg,attemptArg,outArg]=process.argv.slice(2);assert(baseArg&&candidateArg&&attemptArg&&outArg);assert(!fs.existsSync(outArg));
const sha=x=>createHash('sha256').update(x).digest('hex'),identity=p=>({path:fs.realpathSync(p),sha256:sha(fs.readFileSync(p))});
const producer=identity(import.meta.filename),attempt=await verifyAttempt(path.resolve(attemptArg));assert.equal(attempt.checked,true);
const natives=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],am={exports:{}};new Function('module','exports',natives)(am,am.exports);const parse=s=>am.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
function walk(n,fn){if(!n||typeof n!=='object')return;fn(n);for(const[k,v]of Object.entries(n))if(!['start','end'].includes(k)){if(Array.isArray(v))v.forEach(x=>walk(x,fn));else if(v&&typeof v==='object')walk(v,fn);}}
const encoded=n=>'$R_'+[...n].map(c=>c.charCodeAt(0)).join('_')+'$tree',workers=['warp','warp_node','flow','bsort','scan'];
const out=path.resolve(outArg);fs.mkdirSync(out);const mods={},inputs=[identity(path.join(attemptArg,'attempt.json')),identity(new URL('../review/oracles.mjs',import.meta.url))],staticRows={},originalGlobals=new Map();let guardNames;
for(const[role,arg]of[['original',baseArg],['complete',candidateArg]]){
 const source=fs.readFileSync(arg,'utf8'),receipt=JSON.parse(fs.readFileSync(arg+'.json'));assert.equal(receipt.complete,true);assert.equal(receipt.observation.checked,true);assert.equal(receipt.observation.status,'ok');assert.equal(receipt.output.sha256,sha(source));
 for(const row of[receipt.input,receipt.compiler.api,receipt.compiler.runtime,receipt.compiler.base,receipt.compiler.driver])assert.equal(identity(row.canonicalPath??row.file).sha256,row.sha256);
 if(role==='complete'){assert.equal(receipt.attempt.sha256,identity(path.join(attemptArg,'attempt.json')).sha256);for(const key of['api','runtime','base'])assert.equal(receipt.compiler[key].sha256,attempt[key].sha256);assert.equal(receipt.input.sha256,staticRows.original.input);}
 const ast=parse(source),globals=new Map(ast.body.filter(n=>n.type==='FunctionDeclaration').map(n=>[n.id.name,n]));let bench;
 walk(ast,n=>{if(n.type==='AssignmentExpression'&&n.left.type==='MemberExpression'&&n.left.object.name==='G'&&n.left.property.value==='bench')bench=n;});assert(bench);
 const flatBlocks=[];walk(bench,n=>{if(n.type==='BlockStatement'&&source.slice(n.start,n.start+60).startsWith('{/* private flat closed graph */'))flatBlocks.push(n);});assert.equal(flatBlocks.length,role==='complete'?1:0);
 const gs=[];walk(bench,n=>{if(n.type==='VariableDeclarator'&&n.id.name==='$guards'&&n.init.type==='ArrayExpression')gs.push(n.init.elements.map(x=>x.value));});assert.equal(gs.length,1);if(role==='original')guardNames=gs[0];else assert.deepEqual(gs[0],guardNames);assert.equal(guardNames.length,15);
 const scoped=role==='complete'?new Map(flatBlocks[0].body.filter(n=>n.type==='FunctionDeclaration').map(n=>[n.id.name,n])):globals,edits=[];
 let privateWorkerBodies=0,hybridWorkers=0;
 for(const name of workers){
  const workerName=encoded(name),global=globals.get(workerName);assert(global,name+' global worker');
  const text=source.slice(global.start,global.end);if(role==='original')originalGlobals.set(name,text);else assert.equal(text,originalGlobals.get(name),'public worker byte identity '+name);
  assert(name==='bsort'?text.includes('a:['):text.includes('.a['),'public tagged-array representation '+name);
  const fn=scoped.get(workerName);assert(fn,'exact scoped worker '+name);
  const hybrid=role==='complete'?scoped.get(workerName+'$hybrid'):undefined,stack=role==='complete'?scoped.get(workerName+'$stack'):undefined;
  assert.equal(Boolean(hybrid),Boolean(stack),'paired hybrid/stack workers '+name);
  const bodies=hybrid?[fn,hybrid,stack]:[fn];privateWorkerBodies+=bodies.length;
  if(hybrid){++hybridWorkers;assert.equal(fn.body.body.length,1,'hybrid wrapper contains only return '+name);const ret=fn.body.body[0];assert.equal(ret.type,'ReturnStatement');assert.equal(ret.argument?.type,'CallExpression');assert.equal(ret.argument.callee?.name,workerName+'$hybrid');assert.equal(ret.argument.arguments.at(-1)?.value,16,'bounded hybrid budget '+name);}
  if(role==='complete')for(const body of bodies){
   const calls=[];walk(body,n=>{if(n.type==='CallExpression'&&n.callee.type==='Identifier'){if(n.callee.name==='ctor'&&['False','True'].includes(n.arguments[0]?.value)){assert.equal(n.arguments[1]?.type,'ArrayExpression');assert.equal(n.arguments[1].elements.length,0);}else calls.push(n.callee.name);}});
   assert(!calls.some(n=>['callOwned','invokeExact','get','regionProofCovers','ctor','build','project','call','jump','apply','fields','arraydata'].includes(n)),'no generic bridges '+body.id.name);assert(!source.slice(body.start,body.end).includes('WeakSet'));
  }
  if(['bsort','scan'].includes(name)){
   let arg;
   if(hybrid)arg=fn.body.body[0].argument;
   else{const returns=[];walk(fn,n=>{if(n.type==='ReturnStatement'&&n.argument?.type==='Identifier'&&n.argument.name==='$value')returns.push(n);});assert.equal(returns.length,1);arg=returns[0].argument;}
   edits.push({start:arg.start,end:arg.end,text:'($p42Saved'+(name==='bsort'?'Tree':'Stat')+'='+source.slice(arg.start,arg.end)+')'});
  }
 }
 assert([0,4].includes(hybridWorkers),'all four eligible hybrid workers or unchanged stack graph');
 assert.equal(privateWorkerBodies,workers.length+2*hybridWorkers);
 // Build all diagnostic inputs inside the lexical private component, from scalar arguments.
 const constructor=role==='complete'?`const L=v=>({$:"Leaf",_0:v}),N=(l,r)=>({$:"Node",_0:l,_1:r});`:`const L=v=>({$:"Leaf",a:[v]}),N=(l,r)=>({$:"Node",a:[l,r]});`;
 const slots=role==='complete'?['t._0','t._1']:['t.a[0]','t.a[1]'];
 const adapter=`$p42OwnedCode=(mode,n,d,x,s,shared,uneven)=>{${constructor}const make=(d,x)=>{if(d===0)return L(x);const l=make(d-1,(Math.imul(x,3)+1)>>>0);return N(l,shared?l:make(uneven&&d%2===0?0:d-1,(Math.imul(x,5)+7)>>>0));};if(mode==='deep'){const leaf=L(7);let t=leaf;for(let i=0;i<d;i++)t=N(t,leaf);return ${encoded('flow')}(1n,false,N(N(t,t),leaf));}if(mode==='fresh'){const l=L(7),t=N(l,l),a=${encoded('flow')}(0n,false,l),b=${encoded('flow')}(0n,false,t);return [a!==l,b!==t,${role==='complete'?'b._0':'b.a[0]'}===l,${role==='complete'?'b._1':'b.a[1]'}===l];}const t=make(d,x);return ${encoded('flow')}(BigInt(n),s,t);};`;
 if(role==='complete')edits.push({start:flatBlocks[0].start+1,end:flatBlocks[0].start+1,text:'++$p42TestPrivateEntries;'+adapter});
 let diagnostic=source;for(const e of edits.sort((a,b)=>b.start-a.start))diagnostic=diagnostic.slice(0,e.start)+e.text+diagnostic.slice(e.end);
 assert.equal(diagnostic.split('function regionProofOpen(names){').length,2);diagnostic=diagnostic.replace('function regionProofOpen(names){','function regionProofOpen(names){++$p42TestProofEntries;');
 diagnostic+='\nlet $p42TestProofEntries=0,$p42TestPrivateEntries=0,$p42SavedTree,$p42SavedStat,$p42OwnedCode;'+(role==='original'?adapter:'')+`export function p42EntryCounts(){return {proof:$p42TestProofEntries,private:$p42TestPrivateEntries};}export function p42ProofActive(){return regionProof!==null;}export function p42ForceForTest(x){return force(x);}export function p42Saved(){return {tree:$p42SavedTree,stat:$p42SavedStat};}export function p42Owned(mode,n,d,x,s,shared=false,uneven=false){if(!Number.isInteger(d)||d<0||d>30000||!Number.isInteger(n)||n<0||n>8)throw Error('diagnostic scalar bound');const names=${JSON.stringify(gs[0])};if(!regionHostGuard()||!localGuard(names))throw Error('diagnostic guard refused');const p=regionProofOpen(names);try{return $p42OwnedCode(mode,n,d,x,s,shared,uneven);}finally{regionProofClose(p);}}\n`;
 parse(diagnostic);const file=path.join(out,role+'.instrumented.mjs');fs.writeFileSync(file,diagnostic,{flag:'wx'});inputs.push(identity(arg),identity(arg+'.json'),identity(file));mods[role]=await import(pathToFileURL(file));staticRows[role]={input:receipt.input.sha256,privateWorkers:workers.length,privateWorkerBodies,hybridWorkers,flatBlocks:flatBlocks.length,guards:gs[0],publicWorkerByteIdentity:role==='complete'};
}
function difference(a,b){return{proof:a.proof-b.proof,private:a.private-b.private};}
function decode(t){const root=[],todo=[[t,root,0]];while(todo.length){const[t,parent,slot]=todo.pop();assert(['Leaf','Node'].includes(t.$));const a=t.a??[t._0,t._1];if(t.$==='Leaf')parent[slot]=[a[0]];else{const r=[];parent[slot]=r;todo.push([a[1],r,1],[a[0],r,0]);}}return root[0];}
function stat(t){assert.equal(t.$,'St');return t.a??[t._0,t._1,t._2,t._3];}
const key=x=>{let a=u32((BigInt(x)+1n)*2654435761n);a=u32(BigInt(a)^BigInt(a)<<13n);a=u32(BigInt(a)^BigInt(a)>>17n);return u32(BigInt(a)^BigInt(a)<<5n);};
function bsort(d,s,x){if(d===0)return[key(x)];const a=bsort(d-1,false,u32(2n*BigInt(x)+1n)),b=bsort(d-1,true,u32(2n*BigInt(x)));return flow(d-1,s,warp(a,b,s));}
function scan(t){if(t.length===1)return[t[0],t[0],1,t[0]];const a=scan(t[0]),b=scan(t[1]);return[a[0],b[1],a[1]<=b[0]?(a[2]&b[2]):0,u32(BigInt(a[3])*2654435761n+BigInt(b[3]))];}
function outStat(a){return u32((BigInt(u32(BigInt(a[3])*2654435761n))^BigInt(u32(BigInt(a[1])+BigInt(a[0])*340573321n)))+BigInt(a[2])*2246822519n);}
let completeValues=0,ownedOracles=0,boundaries=0,deepCases=0;
for(const d of[0,1,2,3,5])for(const x of[0,17,123,4294967295]){const tree=bsort(d,false,x),stats=scan(tree),value=outStat(stats);for(const role of Object.keys(mods)){const mod=mods[role],before=mod.p42EntryCounts();assert.equal(mod.default.bench(d,x),value);assert.deepEqual(decode(mod.p42Saved().tree),tree);assert.deepEqual(stat(mod.p42Saved().stat),stats);assert.deepEqual(difference(mod.p42EntryCounts(),before),{proof:1,private:role==='complete'?1:0});assert.equal(mod.p42ProofActive(),false);}++completeValues;}
function make(d,x,shared,uneven){if(d===0)return[x];const l=make(d-1,(Math.imul(x,3)+1)>>>0,shared,uneven);return[l,shared?l:make(uneven&&d%2===0?0:d-1,(Math.imul(x,5)+7)>>>0,shared,uneven)];}
for(const d of[0,1,2,4])for(const n of[0,1,2,3])for(const s of[false,true])for(const[shared,uneven]of[[false,false],[true,false],[false,true]]){const expected=flow(n,s,make(d,17,shared,uneven));for(const mod of Object.values(mods)){assert.deepEqual(decode(mod.p42Owned('flow',n,d,17,s,shared,uneven)),expected);assert.equal(mod.p42ProofActive(),false);}++ownedOracles;}
for(const mod of Object.values(mods)){assert.deepEqual(mod.p42Owned('fresh',0,0,0,false),[true,true,true,true]);++ownedOracles;assert.deepEqual(summary(decode(mod.p42Owned('deep',1,30000,0,false))),deepFlowExpected(30000));assert.equal(mod.p42ProofActive(),false);++deepCases;}
const names=guardNames;
for(const name of names)for(const mode of ['binding','getter','throw','reentry']){
 const observations=[];for(const role of Object.keys(mods)){
  const mod=mods[role],saved=Object.getOwnPropertyDescriptor(mod.G,name),events=[],before=mod.p42EntryCounts();let didReenter=false;
  const wrapped={...saved.value,code:function(...args){events.push('code');return saved.value.code.apply(this,args);}};
  if(mode==='binding')Object.defineProperty(mod.G,name,{...saved,value:wrapped});
  else Object.defineProperty(mod.G,name,{configurable:true,enumerable:true,get(){events.push('get');if(mode==='throw')throw Error('layout sentinel');if(mode==='reentry'&&!didReenter){didReenter=true;events.push(['inner',mod.default.bench(0,17)]);}return wrapped;}});
  let value,error;try{value=mod.default.bench(2,17);}catch(e){error=e.message;}finally{Object.defineProperty(mod.G,name,saved);}
  assert.equal(mod.p42ProofActive(),false);const entries=difference(mod.p42EntryCounts(),before);assert.deepEqual(entries,{proof:0,private:0},name+' '+mode+' must refuse guarded entry');if(mode==='reentry')assert.equal(events.filter(e=>Array.isArray(e)&&e[0]==='inner').length,didReenter?1:0);observations.push({value,error,events,entries});
 }assert.deepEqual(observations[1],observations[0],name+' '+mode+' trace mismatch');++boundaries;
}
for(const role of Object.keys(mods)){
 const mod=mods[role],events=[],leaf=mod.ctor('Leaf',[7]);
 assert.deepEqual(leaf,{$:'Leaf',a:[7]});
 const host={$:'Node',get a(){events.push('a');return[leaf,leaf];},get _p42(){throw Error('must not demand marker');},get _0(){throw Error('must not demand private slot');}};
 const result=mod.default.flow(0n,false,host);assert.deepEqual(result,{$:'Node',a:[leaf,leaf]});
 assert.deepEqual(mod.default.flow(1n,false,host),{$:'Node',a:[{$:'Leaf',a:[7]},{$:'Leaf',a:[7]}]});
 assert.deepEqual(decode(mod.default.warp_node(host,false)),[[7],[7]]);assert(events.length>0);assert.equal(mod.p42ProofActive(),false);++boundaries;
}
// Noncanonical counts preserve host coercion/error order and raw entry refusal.
for(const mode of ['coerce','throw','reentry','symbol']){
 const observations=[];for(const role of Object.keys(mods)){const mod=mods[role],events=[];let count;
  if(mode==='symbol')count=Symbol('count');else count={get [Symbol.toPrimitive](){events.push('get-coercion');return()=>{events.push('coerce');if(mode==='throw')throw Error('count sentinel');if(mode==='reentry')events.push(['inner',mod.default.bench(0,17)]);return 0;};}};
  let value,error;try{value=mod.default.bench(count,17);}catch(e){error={name:e.name,message:e.message};}assert.equal(mod.p42ProofActive(),false);observations.push({value,error,events});
 }assert.deepEqual(observations[1],observations[0]);++boundaries;
}
for(const args of [[2,17],[0,17]]){
 const expected=mods.original.default.bench(...args),observations=[];
 for(const role of Object.keys(mods)){
  const mod=mods[role],before=mod.p42EntryCounts();let value,error,bounced;
  try{const raw=mod.G.bench.code.call(null,args);bounced=raw?.bounce===true;value=mod.p42ForceForTest(raw);assert.equal(value,expected,'raw fallback forced complete scalar value');}
  catch(e){error={name:e.name,message:e.message};}
  assert.equal(mod.p42ProofActive(),false);const entries=difference(mod.p42EntryCounts(),before);assert.deepEqual(entries,{proof:0,private:0});observations.push({value,error,entries,bounced});
 }assert.deepEqual(observations[1],observations[0]);assert.equal(observations[0].error,undefined);++boundaries;
}

for(const input of inputs)assert.equal(identity(input.path).sha256,input.sha256);assert.equal(identity(producer.path).sha256,producer.sha256);
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-actual-source-controls-v4.mjs'));
const report={kind:'phase42-actual-flat-source-controls',complete:true,checked:true,producer,attempt:identity(path.join(attemptArg,'attempt.json')),inputs,staticRows,completeValues,ownedOracles,boundaries,deepCases,deepDepth:30000,scope:'Exact emitted scalar-root lexical clones; complete intermediate Tree and Stat independent oracles, scalar-owned mismatch/shared/uneven/freshness adapters, bounded hybrid recursion with exact stack fallback where emitted, private stack frames depth30000, unchanged global public array workers and guarded fallback traces. Diagnostic exports are not public flat-value admission.'};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:true,completeValues,ownedOracles,boundaries,deepCases,out}));
