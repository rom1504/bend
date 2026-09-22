import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawn} from 'node:child_process';

const tool=path.resolve(import.meta.dirname,'../tools/performance/rapid/native-compiler-cache.mjs');
// A deterministic compiler fixture validates publication and invalidation without
// pretending to establish Clang semantics or native compiler performance.
test('native cache publishes reusable binaries and invalidates consumed inputs',async()=>{
  const root=fs.mkdtempSync(path.join(os.tmpdir(),'bend-native-cache-'));
  const source=path.join(root,'compiler.c'),header=path.join(root,'value.h'),cc=path.join(root,'clang-fixture'),cache=path.join(root,'cache');
  fs.writeFileSync(source,'#include "value.h"\nint main(void) { return VALUE; }\n');fs.writeFileSync(header,'#define VALUE 0\n');
  fs.writeFileSync(cc,`#!${process.execPath}\nimport fs from 'node:fs';\nconst args=process.argv.slice(2);\nif(args.includes('--version'))console.log('clang version 18.1.0 (cache test fixture)');\nelse{const output=args[args.indexOf('-o')+1];const source=args.find(arg=>arg.endsWith('.c'));const bytes=fs.readFileSync(source,'utf8')+fs.readFileSync(${JSON.stringify(header)},'utf8');fs.writeFileSync(output,args.includes('-E')?bytes:'binary:'+bytes+args.find(arg=>/^-O[0-3]$/.test(arg)));fs.chmodSync(output,0o755);}\n`,{mode:0o755});
  let sequence=0;
  async function run(...options){
    const output=path.join(root,'outputs','result-'+sequence++);
    const status=await new Promise((resolve,reject)=>{
      const child=spawn(process.execPath,[tool,source,output,cache,...options],{env:{...process.env,CC:cc},stdio:'ignore'});
      child.on('error',reject);child.on('close',resolve);
    });
    return {status,output,report:JSON.parse(fs.readFileSync(output+'.build.json','utf8'))};
  }
  try{
    const miss=await run();assert.equal(miss.status,0,miss.report.error);assert.equal(miss.report.cacheHit,false);
    assert(fs.existsSync(path.join(cache,miss.report.key+'.bin')));assert(fs.statSync(miss.output).mode&0o111);
    const hit=await run();assert.equal(hit.status,0,hit.report.error);assert.equal(hit.report.cacheHit,true);assert.equal(hit.report.key,miss.report.key);
    assert.deepEqual(fs.readFileSync(hit.output),fs.readFileSync(miss.output));
    fs.writeFileSync(header,'#define VALUE 1\n');const changedHeader=await run();assert.equal(changedHeader.status,0,changedHeader.report.error);assert.equal(changedHeader.report.cacheHit,false);assert.notEqual(changedHeader.report.key,hit.report.key);
    const changedFlags=await run('--opt=O2');assert.equal(changedFlags.status,0,changedFlags.report.error);assert.notEqual(changedFlags.report.key,changedHeader.report.key);
    fs.appendFileSync(cc,'\n// New compiler executable, same advertised version.\n');const changedCompiler=await run();assert.equal(changedCompiler.status,0,changedCompiler.report.error);assert.notEqual(changedCompiler.report.key,changedHeader.report.key);
    fs.writeFileSync(path.join(cache,changedCompiler.report.key+'.lock'),'');const locked=await run();assert.equal(locked.status,1);assert.match(locked.report.error,/locked/);assert(!fs.existsSync(locked.output));fs.unlinkSync(path.join(cache,changedCompiler.report.key+'.lock'));
    fs.writeFileSync(path.join(cache,changedCompiler.report.key+'.bin'),'corrupt');const corrupt=await run();assert.equal(corrupt.status,1);assert.match(corrupt.report.error,/Corrupt/);assert(!fs.existsSync(corrupt.output));
  }finally{fs.rmSync(root,{recursive:true,force:true});}
});
