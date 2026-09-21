import fs from 'node:fs';import os from 'node:os';import path from 'node:path';
import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
import {transformMatcherWorkers} from './matcher-workers.mjs';
const runtime=fs.readFileSync(new URL('../../../dist/phase1/runtime.mjs',import.meta.url),'utf8');
const fixture=`
const events=[];
constructorNative["R"]=false;constructors["R"]=["left","right"];
constructorNative["Z"]=false;constructors["Z"]=[];
G["sum"]=matcher1("R",()=>fn(2,function(a){events.push("sum");return a[0]+a[1];}));
G["identity"]=matcher1("R",()=>fn(2,function(a){return a;}));
G["mutate"]=matcher1("R",()=>fn(2,function(a){a[0]=99;a.push(8);return a;}));
G["zero"]=matcher1("Z",()=>fn(2,function(a){return a[0]+a[1];}));
G["partial"]=matcher1("R",()=>fn(3,function(a){return a;}));
G["over"]=matcher1("R",()=>fn(1,function(a){events.push("first body");return fn(1,function(b){events.push("second body");return a[0]+b[0];});}));
G["throws"]=matcher1("R",()=>fn(1,function(a){throw Error("first body failed");}));
G["matched"]=matcher("R",()=>fn(2,function(a){events.push("chosen");return a[0]+a[1];}),()=>{events.push("other");return fn(1,a=>a[0].$);});
G["nested"]=fn(1,function(a){const capture=a[0];return matcher1("R",()=>fn(2,function(a){return capture+a[0]+a[1];}));});
G["env"]=matcher1("R",()=>fn(2,function(a){return this.base+a[0]+a[1];},{base:10}));
G["computed"]=matcher1("R",()=>{events.push("factory");return fn(2,a=>a[0]+a[1]);});
G["zeroArity"]=matcher1("Z",()=>fn(0,function(a){return 17;}));
G["char"]=matcher1("Chr",()=>fn(1,function(a){return a[0];}));
G["loop"]=matcher("Zero",()=>17,()=>matcher1("Succ",()=>fn(1,function(a){return jump(get(G,"loop"),[a[0]]);})));
G["chain"]=matcher("A",()=>1,()=>matcher("B",()=>2,()=>matcher1("R",()=>fn(2,function(a){return a[0]+a[1];}))));
G["computedChain"]=matcher("A",()=>1,()=>matcher("B",()=>2,()=>{events.push("fallback factory");return fn(1,a=>a[0].$);}));
G["lazyChain"]=matcher("A",()=>{events.push("A arm");return 1;},()=>matcher("B",()=>{events.push("B arm");return 2;},()=>matcher1("R",()=>fn(2,function(a){events.push("R arm");return a[0]+a[1];}))));
G["factoryChain"]=fn(1,function(a){const capture=a[0];return matcher("A",()=>capture,()=>matcher1("R",()=>fn(2,function(a){return capture+a[0]+a[1];})));});
G["effectBeforeChain"]=matcher("A",()=>1,()=>{events.push("before inner");return matcher("B",()=>2,()=>matcher1("R",()=>fn(2,function(a){return a[0]+a[1];})));});
export {G,call,fn,events,force,build,jump};
`;
const source=runtime+fixture,transformed=transformMatcherWorkers(source,{chains:process.argv.includes('--chains')});
assert.equal(transformed.stats.matchers,1);assert.equal(transformed.stats.matcher1,14);
assert.match(transformed.source,/G\["env"\]=matcher1\(/);assert.match(transformed.source,/G\["computed"\]=matcher1\(/);assert.match(transformed.source,/G\["zeroArity"\]=matcher1\(/);
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'bend-matcher-test-'));let serial=0;
const load=async text=>{const file=path.join(dir,'api'+serial+++'.mjs');fs.writeFileSync(file,text);return import(pathToFileURL(file));};
const observe=run=>{try{return {value:run()}}catch(e){return {error:e.name+': '+e.message}}};
let cases=0;
try{
 const original=await load(source),candidate=await load(transformed.source);
 const invoke=(api,name,value)=>api.call(api.G[name],[value]);
 for(const api of [original,candidate]){
  const fields=[2,3],r={$:'R',a:fields};assert.equal(invoke(api,'sum',r),5);cases++;
  assert.deepEqual(invoke(api,'identity',r),fields);assert.notEqual(invoke(api,'identity',r),fields);cases++;
  assert.deepEqual(invoke(api,'mutate',r),[99,3,8]);assert.deepEqual(fields,[2,3]);cases++;
  const left=invoke(api,'zero',{$:'Z',a:[]}),right=invoke(api,'zero',{$:'Z',a:[]});
  assert.equal(left.arity,2);assert.notEqual(left,right);assert.notEqual(left.code,right.code);assert.equal(api.call(left,[4,5]),9);cases++;
  const partial=invoke(api,'partial',r);fields[0]=7;assert.deepEqual(api.call(partial,[4]),[2,3,4]);assert.deepEqual(partial.bound,[2,3]);fields[0]=2;cases++;
  api.events.length=0;assert.equal(invoke(api,'over',r),5);assert.deepEqual(api.events,['first body','second body']);cases++;
  assert.throws(()=>invoke(api,'throws',r),/first body failed/);cases++;
  api.events.length=0;assert.equal(invoke(api,'matched',r),5);assert.deepEqual(api.events,['chosen']);cases++;
  api.events.length=0;assert.equal(invoke(api,'matched',{$:'Else',a:[]}),"Else");assert.deepEqual(api.events,['other']);cases++;
  assert.equal(api.call(api.call(api.G.nested,[10]),[r]),15);assert.equal(invoke(api,'env',r),15);cases+=2;
  api.events.length=0;assert.equal(invoke(api,'computed',r),5);assert.deepEqual(api.events,['factory']);cases++;
  assert.equal(api.call(invoke(api,'zeroArity',{$:'Z',a:[]}),[]),17);cases++;
  assert.throws(()=>invoke(api,'char',{request:true}),/runtime fail-stop/);cases++;
  const read=[];const watched=[];Object.defineProperty(watched,0,{get(){read.push(0);return 2},enumerable:true});Object.defineProperty(watched,1,{get(){read.push(1);return 3},enumerable:true});
  assert.equal(invoke(api,'sum',{$:'R',a:watched}),5);assert.deepEqual(read,[0,1]);cases++;
  api.events.length=0;assert.deepEqual(api.force(api.build('Tuple',[()=>api.jump(api.G.sum,[r]),()=>{api.events.push('right');return 9}])),[5,9]);assert.deepEqual(api.events,['sum','right']);cases++;
  assert.equal(invoke(api,'loop',50000n),17);cases++;
  for(const [value,want] of [[{$:'A',a:[]},1],[{$:'B',a:[]},2],[r,5]]){assert.equal(invoke(api,'chain',value),want);cases++;}
  api.events.length=0;assert.equal(invoke(api,'computedChain',{$:'Other',a:[]}),"Other");assert.deepEqual(api.events,['fallback factory']);cases++;
  api.events.length=0;assert.equal(invoke(api,'lazyChain',{$:'B',a:[]}),2);assert.deepEqual(api.events,['B arm']);cases++;
  assert.equal(api.call(api.call(api.G.factoryChain,[10]),[r]),15);cases++;
  api.events.length=0;assert.equal(invoke(api,'effectBeforeChain',r),5);assert.deepEqual(api.events,['before inner']);cases++;
  const order=[];const record={get request(){order.push('request');return false},get $(){order.push('tag');return 'B'},a:[]};
  assert.equal(invoke(api,'chain',record),2);assert.deepEqual(order,['request','tag','request','tag']);cases++;

 }
 // Malformed field vectors and custom slice results must retain the original
 // errors/partial/overapplication, not be assumed to have constructor arity.
 const records=[{$:'R',a:[]},{$:'R',a:[1]},{$:'R',a:[1,2,3]},{$:'R',a:null},{$:'R',a:{}},{$:'R',a:{length:2,slice:()=>null}},{$:'R',a:{length:2,slice:()=>[1,2,3]}}];
 for(const r of records){
  const summarize=api=>{const result=invoke(api,'sum',r);return result?.code?{arity:result.arity,bound:result.bound}:result};
  assert.deepEqual(observe(()=>summarize(candidate)),observe(()=>summarize(original)));cases++;
 }
 const traces=[];
 for(const api of [original,candidate]){
  const trace=[];const fields={get length(){trace.push('length');return 2},get slice(){trace.push('slice getter');return ()=>{trace.push('slice body');return [1]}}};
  const partial=invoke(api,'sum',{$:'R',a:fields});assert.equal(api.call(partial,[2]),3);traces.push(trace);cases++;
 }
 assert.deepEqual(traces[1],traces[0]);
 const report={matchers:transformed.stats.matchers,matcher1:transformed.stats.matcher1,chainFusion:transformed.stats.chainFusion,cases,deepTailCalls:50000,customSliceMismatch:true,publicZeroFieldFunctionIdentity:true};console.log(JSON.stringify(report));
 if(process.env.BEND_MATCHER_REPORT)fs.writeFileSync(process.env.BEND_MATCHER_REPORT,JSON.stringify(report,null,2)+'\n');
}finally{fs.rmSync(dir,{recursive:true,force:true});}
