import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {globalArities} from './direct-calls.mjs';
import {transformBooleanIntrinsics} from './boolean-intrinsics.mjs';
const input=new URL('../../../dist/phase1/selfhost-api.mjs',import.meta.url);
const original=await import(input.href),source=fs.readFileSync(input,'utf8'),arities=globalArities(original.G);
const directory=fs.mkdtempSync(path.join(os.tmpdir(),'bend-bool-prototype-'));
const report={canonicalCases:0,malformedDifferences:[],provenanceRejections:0};
const observe=run=>{try{return {value:run()}}catch(error){return {error:error.message}}};
const options={arities,assumeTypedBooleans:true,assumeImmutableGlobals:true};
try{
 const variants=[];
 for(const [name,extra] of [['native',{}],['flatten',{flatten:true}],['staged',{mode:'staged'}]]){
  const r=transformBooleanIntrinsics(source,{...options,...extra}),file=path.join(directory,name+'.mjs');fs.writeFileSync(file,r.source);
  variants.push([name,await import(pathToFileURL(file))]);
 }
 for(const [name,api] of variants){
  for(const a of [false,true]){
   assert.equal(api.default['Bool.not'](a),original.default['Bool.not'](a));report.canonicalCases++;
   for(const b of [false,true]){
    assert.equal(api.default['Bool.and'](a,b),original.default['Bool.and'](a,b));
    assert.equal(api.call(api.default['Bool.and'](a),[b]),original.call(original.default['Bool.and'](a),[b]));report.canonicalCases+=2;
    const trace=[];const value=api.call(api.default['Bool.and'](a),[(trace.push('second argument'),b)]);
    assert.equal(value,a&&b);assert.deepEqual(trace,['second argument']);report.canonicalCases++;
    assert.deepEqual(observe(()=>api.default['Bool.and'](a,b,1)),observe(()=>original.default['Bool.and'](a,b,1)));report.canonicalCases++;
   }
  }
  // Argument evaluation errors stay before subsequent argument effects.
  let later=false;
  assert.throws(()=>api.default['Bool.and']((()=>{throw Error('bad first argument')})(),(later=true)),/bad first argument/);assert.equal(later,false);
  for(const value of [null,undefined,0,'',1,{}, {request:true}])for(const operation of ['Bool.and','Bool.not']){
   const args=operation==='Bool.and'?[value,true]:[value];
   const want=observe(()=>original.default[operation](...args)),got=observe(()=>api.default[operation](...args));
   if(name==='staged')assert.deepEqual(got,want,'staged compatibility '+operation+' '+String(value));
   else if(JSON.stringify(got)!==JSON.stringify(want))report.malformedDifferences.push({mode:name,operation,input:value===undefined?'undefined':value,original:want,candidate:got});
  }
  const trace=[];
  const result=observe(()=>{const partial=api.default['Bool.and']({request:true});return api.call(partial,[(trace.push('second argument'),true)])});
  if(name==='staged'){assert.deepEqual(result,{error:'runtime fail-stop'});assert.deepEqual(trace,[]);}
  else{assert.deepEqual(trace,['second argument']);report.malformedDifferences.push({mode:name,operation:'staged request fail-stop',original:{error:'runtime fail-stop',trace:[]},candidate:{...result,trace}});}
 }
 for(const altered of [
  source.replace('constructorNative["False"]=true;','constructorNative["False"]=false;'),
  source.replace(/^G\["Bool.and"\]=.*$/m,'G["Bool.and"]=fn(2,a=>true);'),
  source.replace(/^G\["Bool.not"\]=.*$/m,'G["Bool.not"]=fn(1,a=>a[0]);')
 ]){assert.throws(()=>transformBooleanIntrinsics(altered,options),/provenance|verified/);report.provenanceRejections++;}
 assert.ok(report.malformedDifferences.length>0,'native-only prototype must retain its discovered negative evidence');
 console.log(JSON.stringify(report,null,2));
 if(process.env.BEND_BOOL_REPORT)fs.writeFileSync(process.env.BEND_BOOL_REPORT,JSON.stringify(report,null,2)+'\n');
}finally{fs.rmSync(directory,{recursive:true,force:true});}
