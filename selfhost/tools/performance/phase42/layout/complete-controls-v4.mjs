import fs from 'node:fs';
import assert from 'node:assert/strict';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [arg,outArg]=process.argv.slice(2);assert(arg&&outArg);assert(!fs.existsSync(outArg));
const sha=x=>createHash('sha256').update(x).digest('hex');
const identity=p=>({path:fs.realpathSync(p),sha256:sha(fs.readFileSync(p))});
const derivePath=path.resolve(arg,'derive.json'),derive=JSON.parse(fs.readFileSync(derivePath));
assert.equal(derive.kind,'phase42-complete-private-ceiling');assert.equal(derive.complete,true);
for(const row of derive.modules)assert.equal(identity(path.resolve(arg,row.file)).sha256,row.sha256);
const inputs=[identity(derivePath),...derive.modules.map(row=>identity(path.resolve(arg,row.file)))],producer=identity(import.meta.filename);
const instrumented=path.resolve(outArg+'.modules');assert(!fs.existsSync(instrumented));fs.mkdirSync(instrumented,{recursive:false});
const mods={},instrumentation=[];for(const role of ['original','complete']){
 const originalPath=path.resolve(arg,role+'.mjs'),source=fs.readFileSync(originalPath,'utf8');
 assert.equal(source.split('function regionProofOpen(names){').length,2);
 let diagnostic=source.replace('function regionProofOpen(names){','function regionProofOpen(names){++$p42TestProofEntries;');
 if(role==='complete'){assert.equal(diagnostic.split('function $p42Bench(d,x){').length,2);diagnostic=diagnostic.replace('function $p42Bench(d,x){','function $p42Bench(d,x){++$p42TestPrivateEntries;');}
 diagnostic+='\nlet $p42TestProofEntries=0,$p42TestPrivateEntries=0;export function p42EntryCounts(){return {proof:$p42TestProofEntries,private:$p42TestPrivateEntries};}export function p42ForceForTest(x){return force(x);}\n';
 const file=path.join(instrumented,role+'.instrumented.mjs');fs.writeFileSync(file,diagnostic,{flag:'wx'});instrumentation.push({role,parent:identity(originalPath),module:identity(file)});mods[role]=await import(pathToFileURL(file));
}
function difference(after,before){return{proof:after.proof-before.proof,private:after.private-before.private};}

function decode(x){if(!x||typeof x!=='object')return x;if(x.$==='Leaf')return {tag:'Leaf',v:x.a?x.a[0]:x.v};if(x.$==='Node')return {tag:'Node',l:decode(x.a?x.a[0]:x.l),r:decode(x.a?x.a[1]:x.r)};if(x.$==='St')return {tag:'St',values:x.a??[x.lo,x.hi,x.ok,x.mx]};throw Error('unexpected ADT');}
let completeValues=0,boundaries=0,ownedOracles=0;
const L=v=>({$:'Leaf',v}),N=(l,r)=>({$:'Node',l,r});
function oracleWarp(a,b,s){if(a.$==='Leaf'&&b.$==='Leaf')return s!==(a.v>b.v)?N(L(b.v),L(a.v)):N(L(a.v),L(b.v));if(a.$!=='Node'||b.$!=='Node')return L(0);const l=oracleWarp(a.l,b.l,s),r=oracleWarp(a.r,b.r,s);return l.$==='Node'&&r.$==='Node'?N(N(l.l,r.l),N(l.r,r.r)):L(0);}
function oracleFlow(n,t,s){if(t.$==='Leaf')return L(t.v);if(n===0)return N(t.l,t.r);const wn=t=>t.$==='Leaf'?L(t.v):oracleWarp(t.l,t.r,s);return N(oracleFlow(n-1,wn(t.l),s),oracleFlow(n-1,wn(t.r),s));}
function make(d,x,shared,uneven){if(d===0)return L(x);const l=make(d-1,(Math.imul(x,3)+1)>>>0,shared,uneven);return N(l,shared?l:make(uneven&&d%2===0?0:d-1,(Math.imul(x,5)+7)>>>0,shared,uneven));}
for(const d of [0,1,2,4])for(const n of [0,1,2,3])for(const s of [false,true])for(const [shared,uneven]of [[false,false],[true,false],[false,true]]){const t=make(d,17,shared,uneven);assert.deepEqual(mods.complete.p42FlowOwned(n,t,s),oracleFlow(n,t,s));++ownedOracles;}
for(const a of [L(7),N(L(7),L(11))])for(const b of [L(13),N(L(13),L(17))])for(const s of [false,true]){assert.deepEqual(mods.complete.p42WarpOwned(a,b,s),oracleWarp(a,b,s));++ownedOracles;}
const leaf=L(7),node=N(leaf,leaf),freshLeaf=mods.complete.p42FlowOwned(0,leaf,false),freshNode=mods.complete.p42FlowOwned(0,node,false);assert.notEqual(freshLeaf,leaf);assert.notEqual(freshNode,node);assert.equal(freshNode.l,leaf);assert.equal(freshNode.r,leaf);ownedOracles+=2;

for(const d of [0,1,2,3,5])for(const x of [0,17,123,4294967295])for(const s of [false,true]){
 const expected=mods.original.p42Complete(d,x,s);for(const role of ['complete']){assert.deepEqual(decode(mods[role].p42Complete(d,x,s).tree),decode(expected.tree));assert.deepEqual(decode(mods[role].p42Complete(d,x,s).stat),decode(expected.stat));assert.equal(mods[role].p42ProofActive(),false);}++completeValues;
}
for(const role of Object.keys(mods)){const before=mods[role].p42EntryCounts();assert.equal(mods[role].default.bench(8,0),971629740);assert.deepEqual(difference(mods[role].p42EntryCounts(),before),{proof:1,private:role==='complete'?1:0});}
const names=['bsort','warp','warp_zip','warp_leaf','Bool.xor','warp_leaf.go','flow','warp_node','key','prng','scan','stat_join','stat_join.go','stat_out'];
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
 assert.deepEqual(decode(mod.default.warp_node(host,false)),{tag:'Node',l:{tag:'Leaf',v:7},r:{tag:'Leaf',v:7}});assert(events.length>0);assert.equal(mod.p42ProofActive(),false);++boundaries;
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

for(const input of inputs)assert.equal(identity(input.path).sha256,input.sha256);
for(const item of instrumentation)for(const key of ['parent','module'])assert.equal(identity(item[key].path).sha256,item[key].sha256);
assert.equal(identity(producer.path).sha256,producer.sha256);
const consumed=path.resolve(outArg+'.controls.mjs');assert(!fs.existsSync(consumed));fs.copyFileSync(import.meta.filename,consumed);
const report={producer,inputs,consumed:identity(consumed),instrumentation,kind:'phase42-complete-private-controls',complete:true,checked:false,completeValues,boundaries,ownedOracles,knownChecksum:971629740,scope:'Selected full trees/statistics, independent mismatch/uneven/shared private flow oracles and public fallback traces. Native recursion ceiling bounded to depth12; no deep-stack or compiler representation proof.'};
fs.writeFileSync(outArg,JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify(report));
