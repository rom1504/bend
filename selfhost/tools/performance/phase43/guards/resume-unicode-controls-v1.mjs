// Explicitly fenced private worker diagnostics; ordinary entry is checked by
// the unchanged full String owner controller. No timing.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
const dir=path.resolve(process.argv[2]);const mods=await Promise.all(['original','full'].map(n=>import(pathToFileURL(path.join(dir,n+'.mjs')))));const rows=[];
const templates=['','literal 😃','i 😃 n','😃 i o 💩','i\ud800','\ud800'];
function observe(m,tpl,seed,k){try{return {value:m.privateResumeGenerate(tpl,seed,k)};}catch(e){return {error:{name:e.name,message:e.message}};}}
for(const tpl of templates)for(const seed of [0,17,4294967295])for(const k of [0,4294967295]){const observations=mods.map(m=>observe(m,tpl,seed,k));assert.deepEqual(observations[1],observations[0]);for(const m of mods)assert.equal(m.privateActive(),false);rows.push({tpl,seed,k,observations});}
for(const key of ['codePointAt','slice'])for(const tpl of templates){const observations=mods.map(m=>{const old=String.prototype[key],events=[];try{Object.defineProperty(String.prototype,key,{configurable:true,writable:true,value:function(...args){events.push(key);return Reflect.apply(old,this,args);}});return {...observe(m,tpl,17,0),events};}finally{Object.defineProperty(String.prototype,key,{configurable:true,writable:true,value:old});}});assert.deepEqual(observations[1],observations[0]);rows.push({key,tpl,observations});}
console.log(JSON.stringify({complete:true,pass:true,scope:'Fenced private Unicode worker diagnostics; no ordinary-source-root claim',cases:rows},null,2));
