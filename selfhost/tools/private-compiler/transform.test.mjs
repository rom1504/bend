import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {transformPrivateCalls} from './calls.mjs';
import {validateInspectRequest} from './transport.mjs';
const runtime=fs.readFileSync(new URL('../../src/runtime.mjs',import.meta.url),'utf8');
const exports=['pair','sum','go','nested','partial','over','factory_order','malformed','apply_partial'];
const defs=`
const events=[];
G["pair"]=fn(2,function(a){return [a[0],a[1]];});
G["sum"]=fn(2,function(a){return call(get(G,"U32.add"),[a[0],a[1]]);});
G["go"]=fn(2,function(a){const n=a[0],v=a[1];if(n===0)return v;return jump(get(G,"go"),[n-1,call(get(G,"sum"),[v,1])]);});
G["nested"]=fn(1,function(a){const value=a[0];return call(fn(1,function(a){return call(get(G,"pair"),[value,a[0]]);}),[7]);});
G["partial"]=fn(1,function(a){return call(get(G,"sum"),[a[0]]);});
G["apply_partial"]=fn(1,function(a){return call(call(get(G,"partial"),[a[0]]),[8]);});
G["over"]=fn(1,function(a){return call(get(G,"sum"),[a[0],1,2]);});
G["factory"]=fn(0,function(a){events.push('factory');return fn(2,function(a){return a;});});
G["factory_order"]=fn(1,function(a){events.length=0;call(get(G,"factory"),[(events.push('left'),1),(events.push('right'),2)]);return events.slice();});
G["malformed"]=fn(1,function(a){return call(get(G,"U32.mod"),[a[0],0]);});
export {G,call,list,ctor};
export default Object.fromEntries(Object.keys(G).map(k=>[k,(...args)=>call(get(G,k),args)]));
`;
const directory=fs.mkdtempSync(path.join(os.tmpdir(),'bend-private-'));
let serial=0;
async function load(source){const file=path.join(directory,serial+++'.mjs');fs.writeFileSync(file,source);return import(pathToFileURL(file));}
const observe=f=>{try{return {value:f()}}catch(e){return {error:String(e)}}};
test.after(()=>fs.rmSync(directory,{recursive:true,force:true}));
test('private positional/tail and scalar modes preserve ordinary values and failure boundaries',async()=>{
 const source=runtime+defs,base=await load(source);
 for(const mode of ['control','calls','scalars','combined']) {
  const t=transformPrivateCalls(source,{exports,mode}),m=await load(t.source);
  assert.deepEqual(Object.keys(m).sort(),['G','ctor','default']);assert.deepEqual(Object.keys(m.G),['privateCompilerImage']);
  assert.equal(Object.isFrozen(m.G),true);assert.equal(m.call,undefined);assert.equal(m.G.sum,undefined);
  for(const values of [[0,1],[4294967295,1],[-1,4],[NaN,3],[Infinity,1],[null,4],['x',1],[1n,2n]])assert.deepEqual(observe(()=>m.default.sum(...values)),observe(()=>base.default.sum(...values)),mode);
  for(const name of ['nested','apply_partial','over','factory_order'])assert.deepEqual(observe(()=>m.default[name](6)),observe(()=>base.default[name](6)),mode+' '+name);
  assert.equal(m.default.go(100000,0),100000,'tail trampoline must remain stack safe');
  assert.deepEqual(m.default.pair(2,3),[2,3]);
  // A malformed primitive returning a bounce still has the original force.
  const bounce={bounce:true,f:{arity:0,code:()=>17,env:null,bound:[]},args:[]};
  assert.equal(m.default.malformed(bounce),17);
 }
});
test('runtime primitive override is not specialized; zero-arity factory stays lazy',async()=>{
 const source=runtime+defs.replace('export {G,call,list,ctor};','G["U32.add"]=fn(2,function(a){return 123;});\nexport {G,call,list,ctor};');
 const t=transformPrivateCalls(source,{exports,mode:'combined'}),m=await load(t.source);
 assert.equal(m.default.sum(1,2),123);assert.deepEqual(m.default.factory_order(null),['factory','left','right']);
});
test('old public getter counterexample remains observable in untouched public image',async()=>{
 const m=await load(runtime+defs),f=m.G['U32.add'],code=f.code;let reads=0;
 Object.defineProperty(f,'code',{get(){if(++reads===3)throw Error('third code read');return code;}});
 assert.throws(()=>m.default.sum(1,2),/third code read/);assert.equal(reads,3);
});
test('inspect transport rejects function/graph/global/mode injection without invoking hooks',()=>{
 const valid={input:'/tmp/main.bend',mode:'compile'};assert.deepEqual(validateInspectRequest(valid),{...valid,withReport:false});
 let touched=0;const getter={mode:'compile'};Object.defineProperty(getter,'input',{get(){touched++;return '/tmp/main.bend';},enumerable:true});
 const proxy=new Proxy(valid,{getPrototypeOf(){touched++;throw Error('trap');}});
 for(const value of [getter,proxy,{...valid,api:()=>0},{...valid,G:{}},{...valid,mode:'interpreter'},{...valid,input:()=>0},{...valid,input:{toString(){touched++;return 'x';}}},JSON.parse('{"input":"/tmp/a","mode":"compile","__proto__":{}}')])assert.throws(()=>validateInspectRequest(value));
 assert.equal(touched,0);
});
test('private branded application keeps partial/overapplication and tail semantics',async()=>{
 const {transformPrivateRuntime}=await import('./runtime.mjs');
 const original=await load(runtime+defs),result=transformPrivateRuntime(transformPrivateCalls(runtime+defs,{exports,mode:'combined'}).source),m=await load(result.source);
 assert.equal(m.default.go(100000,0),100000);for(const name of ['nested','apply_partial','over','factory_order'])assert.deepEqual(observe(()=>m.default[name](8)),observe(()=>original.default[name](8)));
 assert.throws(()=>transformPrivateRuntime(runtime+defs),/isolated image/);
});
test('private projection leaf inlining preserves immutable compiler record slots',async()=>{
 const {transformPrivateProjections}=await import('./runtime.mjs');
 const source=runtime+`\nconstructors.KTerm=['tag','name','id','quant','kids','removed'];\nG["tg"]=fn(1,function(a){return project("KTerm",a[0]).slice()[0];});\nG["read"]=fn(1,function(a){return call(get(G,"tg"),[a[0]]);});\n`+defs;
 const p=transformPrivateProjections(source),base=await load(source),m=await load(transformPrivateCalls(p.source,{exports:['read'],mode:'combined'}).source);
 for(const value of ['App','Ref','Ctr','🙂','\ud800'])assert.equal(m.default.read({$:'KTerm',a:[value,'',0,0,{$:'Nil',a:[]},false]}),base.default.read({$:'KTerm',a:[value,'',0,0,{$:'Nil',a:[]},false]}));
});
test('private missing constant requires exact closed-body proof; arbitrary fn0 stays fresh',async()=>{
 const {preparePrivateConstants}=await import('./constants.mjs');
 const definitions="G[\"missing\"]=fn(0,function(){return build(\"KDef\",[()=>\"\",()=>\"Absent\",()=>0,()=>0,()=>jump(get(G,\"atom\"),[\"Absent\"]),()=>jump(get(G,\"atom\"),[\"Absent\"]),()=>build(\"Nil\",[]),()=>build(\"False\",[]),()=>build(\"False\",[]),]);});\nG[\"atom\"]=fn(1,function(a){const x6433=a[0];return jump(get(G,\"kt\"),[x6433,\"\",0,0,ctor(\"Nil\",[]),]);});\nG[\"kt\"]=fn(5,function(a){const x6427=a[0];const x6428=a[1];const x6429=a[2];const x6430=a[3];const x6431=a[4];return build(\"KTerm\",[()=>x6427,()=>x6428,()=>x6429,()=>x6430,()=>x6431,()=>build(\"Nil\",[]),]);});";
 const source=runtime+'\n'+definitions+'\n'+defs,original=await load(source),prepared=preparePrivateConstants(source),m=await load(transformPrivateCalls(prepared.source,{exports:['missing','factory_order'],mode:'combined'}).source);
 assert.deepEqual(m.default.missing(),original.default.missing());assert.notEqual(original.default.missing(),original.default.missing());
 assert.equal(m.default.missing(),m.default.missing(),'worker-only immutable constant can share internally');
 assert.deepEqual(m.default.factory_order(null),['factory','left','right']);assert.deepEqual(m.default.factory_order(null),['factory','left','right']);
 assert.throws(()=>preparePrivateConstants(source.replace('()=>"Absent",()=>0','()=>"Changed",()=>0')),/purity proof/);
 assert.throws(()=>preparePrivateConstants(source.replace('G["missing"]=fn(0,function(){return','G["missing"]=fn(0,function(){events.push(1);return')),/purity proof/);
});
