// No compiler or emitted program execution: exercise the actual CLI router with spies.
import fs from 'node:fs';import os from 'node:os';import path from 'node:path';
import assert from 'node:assert/strict';import {createHash} from 'node:crypto';
import {javascriptBackendForMode} from '../../typed-driver.mjs';
const driver=new URL('../../typed-driver.mjs',import.meta.url),source=fs.readFileSync(driver,'utf8');
const body=source.slice(source.indexOf('export async function main(args) {'),source.indexOf('function printResult(result)'));
assert.ok(body.startsWith('export async function main(args)'));
const directory=fs.mkdtempSync(path.join(os.tmpdir(),'bend-default-routing-')),calls=[];
const inspect=async(input,options)=>{calls.push({kind:'inspect',options});return {status:'ok',code:'',files:[],exitCode:0};};
const execute=async(input,options)=>{calls.push({kind:'execute',options});return {status:'ok',exitCode:0};};
const main=new Function('path','fs','inspect','execute','printResult','apiPath','basePath','runtimePath','directRuntimePath',
  body.replace('export async function main','async function main')+';return main;')(path,fs,inspect,execute,()=>{},...Array(4).fill(path.join(directory,'absent')));
const rows=[];
async function run(name,args,wanted){calls.length=0;await main([path.join(directory,'input.bend'),...args]);assert.deepEqual(calls.map(x=>[x.kind,x.options.mode??'run',x.options.backend]),wanted);rows.push(name);}
try{
  for(const mode of ['compile','library','interpreter'])assert.equal(javascriptBackendForMode(mode),'direct');
  for(const mode of ['parse','check','native'])assert.equal(javascriptBackendForMode(mode),'js');
  for(const mode of ['compile','library','native'])assert.equal(javascriptBackendForMode(mode,'js'),'js');
  await run('default callable library',['--library'],[['inspect','library','direct']]);
  await run('legacy descriptor library',['--legacy-js','--library'],[['inspect','library','js']]);
  await run('explicit direct',['--direct-js','--library'],[['inspect','library','direct']]);
  await run('default run',['--run'],[['execute','run','direct']]);
  await run('legacy run',['--legacy-js','--run'],[['execute','run','js']]);
  for(const flag of ['--native','--cpu','--metal','--cuda'])await run(flag+' run',[flag,'--run'],[['execute','run',flag.slice(2)]]);
  await run('mixed JS/C output',['-o',path.join(directory,'a.mjs'),'-o',path.join(directory,'a.c')],[['inspect','compile','direct'],['inspect','native','js']]);
  await run('legacy JS output',['--legacy-js','-o',path.join(directory,'b.mjs')],[['inspect','compile','js']]);
  for(const selectors of [['--direct-js','--legacy-js'],['--legacy-js','--direct-js']])await assert.rejects(main(['input',...selectors]),/mutually exclusive/);
  for(const selector of ['--legacy-js','--direct-js'])await assert.rejects(main(['input',selector,'--cpu','--run']),/requires JavaScript output/);
  const executeHeader=source.match(/export async function execute\(input,([^\n]*)/)[1];assert.match(executeHeader,/backend='direct'/);
  const stage0=fs.readFileSync(new URL('../../stage0-library.mjs',import.meta.url),'utf8');assert.match(stage0,/C\.js_lib\(/);
  for(const name of ['worker.mjs','session.mjs','tests/control-worker.mjs','tests/reference-batch-worker.mjs']) {
    const worker=fs.readFileSync(new URL('../../private-compiler/'+name,import.meta.url),'utf8');
    const calls=worker.match(/D\.inspect\(request\.input,\{[^}]+\}\)/g);assert.equal(calls?.length,1,name);
    assert.match(calls[0],/backend:'js'/,name+' compiler-image route must stay legacy');
  }
  console.log(JSON.stringify({kind:'phase53-default-routing-tests',pass:true,scope:'routing only; compiler and targets not executed',driverSha256:createHash('sha256').update(source).digest('hex'),rows}));
}finally{fs.rmSync(directory,{recursive:true,force:true});}
