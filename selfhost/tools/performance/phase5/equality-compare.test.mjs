import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {settings,summarize} from './equality-compare.mjs';
import {identity} from '../../development/workflow.mjs';
import {supervise,requireExecution} from '../../development/process.mjs';

test('comparison requires full alternating pairs and bounded settings',()=>{
 assert.equal(settings({attempt:'a',coreLibrary:'b'}).repetitions,2);
 for(const value of [{repetitions:1},{repetitions:3},{cpu:-1},{timeoutMs:900001},{unexpected:true}])assert.throws(()=>settings({attempt:'a',coreLibrary:'b',...value}));
});
test('a failed or missing row withholds the whole cell, not only that sample',()=>{
 const rows=[];for(let repetition=0;repetition<2;repetition++)for(const workload of ['core','list'])for(const variant of workload==='core'?['checked','derived']:['checked','derived','typescript'])rows.push({workload,variant,repetition,passed:true,observation:{requestMs:10+repetition,maxRssKiB:20},execution:{wallMs:30+repetition}});
 assert.equal(summarize(rows,2).core.variants.checked.medianRequestMs,10.5);
 rows.find(r=>r.workload==='core'&&r.variant==='derived').passed=false;
 const result=summarize(rows,2);assert.equal(result.core.validComparison,false);assert.equal(result.core.variants.checked.medianRequestMs,undefined);assert.equal(result.list.validComparison,true);
 assert.equal(summarize(rows.slice(0,-1),2).list.validComparison,false);
 const duplicates=rows.map(r=>({...r,passed:true,variant:r.workload==='list'?'checked':r.variant}));assert.equal(summarize(duplicates,2).list.validComparison,false);
});
test('file-backed worker preserves exact rejection and refuses source drift',async()=>{
 const dir=fs.mkdtempSync(path.join(os.tmpdir(),'bend-equality-worker-'));try{
  const input=path.join(dir,'source.bend'),api=path.join(dir,'api.mjs'),runtime=path.join(dir,'runtime.mjs'),host=path.join(dir,'host.mjs');
  fs.writeFileSync(input,'source');fs.writeFileSync(api,'export default {};');fs.writeFileSync(runtime,'');
  fs.writeFileSync(host,`export async function loadApi(){return {}};export async function inspect(){return {status:'error',phase:'check',checked:true,exitCode:1,diagnostic:'exact malformed diagnostic \\ud800'}};`);
  const worker=new URL('./equality-worker.mjs',import.meta.url).pathname;
  const request={variant:'checked',api,runtime,host,base:input,upstream:dir,input,mode:'compile',output:path.join(dir,'out.mjs'),inputs:[input,api,runtime,host,worker].map(identity)};
  const req=path.join(dir,'request.json'),result=path.join(dir,'result.json');fs.writeFileSync(req,JSON.stringify(request));
  const run=await supervise(process.execPath,[worker,req,result],{directory:path.join(dir,'good'),env:process.env,timeoutMs:3000});requireExecution(run);
  const got=JSON.parse(fs.readFileSync(result));assert.equal(got.result.diagnostic,'exact malformed diagnostic \ud800');assert.equal(got.result.checked,true);assert.equal(got.emitted,undefined);assert.equal(got.inputsVerified,true);
  fs.writeFileSync(input,'changed');const rejected=path.join(dir,'rejected.json'),bad=await supervise(process.execPath,[worker,req,rejected],{directory:path.join(dir,'bad'),env:process.env,timeoutMs:3000});assert.notEqual(bad.exitCode,0);assert.equal(fs.existsSync(rejected),false);
 }finally{fs.rmSync(dir,{recursive:true,force:true});}
});
test('bounded fresh child deadline is a retained failure',async()=>{
 const dir=fs.mkdtempSync(path.join(os.tmpdir(),'bend-equality-deadline-'));try{const result=await supervise(process.execPath,['-e','setInterval(()=>{},1000)'],{directory:path.join(dir,'process'),env:process.env,timeoutMs:100});assert.equal(result.timedOut,true);assert.throws(()=>requireExecution(result));assert.ok(fs.existsSync(result.stderr));}finally{fs.rmSync(dir,{recursive:true,force:true});}
});
