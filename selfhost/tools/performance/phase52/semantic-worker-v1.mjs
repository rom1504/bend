// One fresh process observes one default-callable scenario. No legacy G API.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [moduleFile,testFile,outFile]=process.argv.slice(2);
assert(moduleFile&&testFile&&outFile);
const test=JSON.parse(fs.readFileSync(testFile,'utf8')),events=[];
const original={keys:Object.keys,is:Object.is,define:Object.defineProperty,descriptor:Object.getOwnPropertyDescriptor};
function decode(x){
 if(x&&typeof x==='object'){
  if(Object.hasOwn(x,'$bigint'))return BigInt(x.$bigint);
  if(Object.hasOwn(x,'$number'))return ({NaN:NaN,Infinity:Infinity,'-Infinity':-Infinity,'-0':-0})[x.$number];
  if(Object.hasOwn(x,'$callback')){assert.equal(x.$callback,'plus7');return n=>{events.push(['callback',n]);return (n+7)>>>0;};}
  if(Object.hasOwn(x,'$getters')){const o={...decode(x.value)};for(const [k,v]of Object.entries(x.$getters))original.define(o,k,{enumerable:true,configurable:true,get(){events.push(['get',k]);if(v.throw)throw new Error(v.throw);return decode(v.value);}});return o;}
  if(Array.isArray(x))return x.map(decode);
  return Object.fromEntries(Object.entries(x).map(([k,v])=>[k,decode(v)]));
 }
 return x;
}
function encode(x,seen=new Set()){
 if(typeof x==='bigint')return {$bigint:String(x)};
 if(typeof x==='number'&&(!Number.isFinite(x)||original.is(x,-0)))return {$number:original.is(x,-0)?'-0':String(x)};
 if(x===undefined)return {$undefined:true};
 if(typeof x==='function')return {$function:true};
 if(x&&typeof x==='object'){
  if(seen.has(x))return {$cycle:true};seen.add(x);
  const out=Array.isArray(x)?x.map(v=>encode(v,seen)):Object.fromEntries(original.keys(x).map(k=>[k,encode(x[k],seen)]));seen.delete(x);return out;
 }
 return x;
}
let restore=()=>{};const result={kind:'phase52-direct-semantic-observation',complete:false,test:test.id,events};
try{
 const mod=await import(pathToFileURL(moduleFile));
 assert(mod.default&&typeof mod.default==='object','requires the default callable library');
 if(test.mutation){
  const {target,style}=test.mutation;assert(['Math.floor','Math.fround','String.fromCodePoint','Array.isArray'].includes(target));
  const [owner,key]=target.split('.'),object=globalThis[owner],desc=original.descriptor(object,key);assert(desc&&typeof desc.value==='function');
  restore=()=>original.define(object,key,desc);
  const hook=function(...args){events.push(['builtin',target,encode(args)]);if(style==='throw')throw new Error('phase52-hook:'+target);return Reflect.apply(desc.value,this,args);};
  if(style==='getter')original.define(object,key,{configurable:true,get(){events.push(['builtin-get',target]);return hook;}});
  else original.define(object,key,{...desc,value:hook});
 }
 const args=test.groups.map(group=>group.map(decode));let value=mod.default[test.exportName];assert.equal(typeof value,'function','missing export '+test.exportName);
 for(const group of args){assert.equal(typeof value,'function','overapplication result must remain callable');value=value(...group);}
 result.value=encode(value);result.outcome='return';
 if(test.expected!==undefined)assert.deepEqual(result.value,test.expected,'independent expected value');
 if(test.expectedError)throw new Error('expected error was not observed');
 result.complete=true;
}catch(error){
 result.outcome='throw';result.error={type:typeof error,name:error?.name??null,message:error?.message??String(error)};
 if(test.expectedError){assert(result.error.message.includes(test.expectedError),'independent expected error');result.complete=true;}
 else if(test.mutation||test.differentialOnly)result.complete=true;
 else {result.failure=error?.stack??String(error);process.exitCode=1;}
}finally{restore();}
fs.writeFileSync(outFile,JSON.stringify(result,null,2)+'\n',{flag:'wx'});
