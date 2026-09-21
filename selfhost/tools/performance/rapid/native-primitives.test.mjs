import fs from 'node:fs';import os from 'node:os';import path from 'node:path';
import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
import {primitiveExpressions,transformNativePrimitives} from './native-primitives.mjs';
import {transformPositionalWorkers} from './positional-workers.mjs';
const runtime=fs.readFileSync(new URL('../../../dist/phase1/runtime.mjs',import.meta.url),'utf8');
let definitions='\nconst events=[];\n';
for(const [name,[arity]] of Object.entries(primitiveExpressions))definitions+=`G[${JSON.stringify('test_'+name)}]=fn(${arity},function(a){return call(get(G,${JSON.stringify(name)}),[a[0]${arity===2?',a[1]':''}]);});\n`;
definitions+=`
G["partial"]=fn(1,function(a){return call(get(G,"String.append"),[a[0]]);});
G["over"]=fn(1,function(a){return call(get(G,"String.append"),[a[0],"y","z"]);});
G["effects"]=fn(1,function(a){return call(get(G,"String.append"),[(events.push("left"),"a"),(events.push("right"),"b")]);});
G["capture"]=fn(1,function(a){return call(get(G,"String.append"),[(G["String.append"]=fn(2,a=>"replacement"),"a"),"b"]);});
G["mutate"]=fn(1,function(a){return call(get(G,"String.append"),[(G["String.append"].code=a=>"changed", "a"),"b"]);});
export {G,call,fn,events};
`;
const source=runtime+definitions,result=transformNativePrimitives(source);
assert.equal(result.stats.calls,31);assert.equal(result.stats.tailsOptimized,false);
assert.match(result.source,/return call\(get\(G,"String.append"\),\[a\[0\]\]\)/);
const directory=fs.mkdtempSync(path.join(os.tmpdir(),'bend-native-test-'));
let serial=0;
async function load(text){const file=path.join(directory,'api'+serial+++'.mjs');fs.writeFileSync(file,text);return import(pathToFileURL(file));}
const observe=run=>{try{return {value:run()}}catch(error){return {error:error.name+': '+error.message}}};
const report={primitiveNames:Object.keys(primitiveExpressions),differentialCases:0,guards:[],compositionCalls:0};
try{
 const original=await load(source),candidate=await load(result.source);
 const numbers=[-Infinity,-1,-0,0,1,3.5,2147483648,4294967295,4294967296,NaN,Infinity,0n,1n,33n,null,undefined,true,false,'4',{}];
 const strings=['','a','é','🙂','a🙂','\ud800','\udc00','a\ud800',null,undefined,0,{}];
 for(const [name,[arity]] of Object.entries(primitiveExpressions)){
  const values=name.startsWith('String.')?strings:numbers;
  for(const a of values)for(const b of arity===2?values:[undefined]){
   const args=arity===2?[a,b]:[a],want=observe(()=>original.call(original.G['test_'+name],args)),got=observe(()=>candidate.call(candidate.G['test_'+name],args));
   assert.deepEqual(got,want,name+' '+String(a)+' '+String(b));report.differentialCases++;
  }
 }
 for(const api of [original,candidate]){
  assert.equal(api.call(api.call(api.G.partial,['a']),['b']),'ab');assert.throws(()=>api.call(api.G.over,['a']),/non-function/);
  assert.equal(api.call(api.G.effects,[null]),'ab');assert.deepEqual(api.events,['left','right']);api.events.length=0;
  // A primitive may return a bounce/build only through malformed host inputs;
  // domain guards must preserve force in those fallback cases.
  const bounce={bounce:true,f:api.fn(0,()=>17),args:[]};
  assert.equal(api.call(api.G['test_Bool.or'],[bounce,false]),17);
  assert.equal(api.call(api.G['test_U32.mod'],[bounce,0]),17);
  const saved=api.G['String.append'];
  api.G['String.append']=api.fn(0,()=>{api.events.push('init');return api.fn(2,a=>a.join(''))});
  assert.equal(api.call(api.G.effects,[null]),'ab');assert.deepEqual(api.events,['init','left','right']);api.events.length=0;
  api.G['String.append']=saved;
  assert.equal(api.call(api.G.capture,[null]),'ab');assert.equal(api.call(api.G.effects,[null]),'replacement');api.G['String.append']=saved;
  const savedCode=saved.code;assert.equal(api.call(api.G.mutate,[null]),'changed');saved.code=savedCode;
  api.G['String.append']=api.fn(3,function(a){return this.prefix+a.join('')},{prefix:'env:'},['bound']);
  assert.equal(api.call(api.G.effects,[null]),'env:boundab');api.G['String.append']=saved;
  saved.env={changed:true};assert.equal(api.call(api.G.effects,[null]),'ab');saved.env=null;
  saved.arity=3;const partial=api.call(api.G.effects,[null]);assert.equal(api.call(partial,['c']),'ab');saved.arity=2;
  saved.io=()=>{};const io=api.call(api.G['test_String.append'],[null,api.fn(1,a=>a[0])]);assert.equal(io.request,true);delete saved.io;
  saved.typeName='T';assert.deepEqual(api.call(api.G['test_String.append'],[1,2]),{typeName:'T',typeArgs:[1,2]});delete saved.typeName;
 }
 report.guards=['partial','overapplication','eager argument effects','malformed bounce force','fn0 before arguments','callee captured before rebinding','mutated code','bound arguments','environment','arity','IO','type application'];
 const composed=transformNativePrimitives(transformPositionalWorkers(source).source);const combo=await load(composed.source);assert.equal(combo.call(combo.G['test_U32.add'],[4294967295,1]),0);report.compositionCalls=composed.stats.calls;
 // A same-named definition emitted after runtime registration is excluded.
 const custom=source.replace('export {G,call,fn,events};','G["U32.add"]=fn(2,function(a){return 123;});\nexport {G,call,fn,events};');
 const customResult=transformNativePrimitives(custom);assert.ok(customResult.stats.overriddenSkipped.includes('U32.add'));
 const customApi=await load(customResult.source);assert.equal(customApi.call(customApi.G['test_U32.add'],[1,2]),123);
 console.log(JSON.stringify(report));if(process.env.BEND_NATIVE_REPORT)fs.writeFileSync(process.env.BEND_NATIVE_REPORT,JSON.stringify(report,null,2)+'\n');
}finally{fs.rmSync(directory,{recursive:true,force:true});}
