import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import test from 'node:test';

const tool=path.resolve(import.meta.dirname,'../../tools/conformance/selfhost.mjs');
function fixture(){
  const directory=fs.mkdtempSync(path.join(os.tmpdir(),'bend-selfhost-provenance-'));
  const file=name=>path.join(directory,name);
  for(const name of ['source.bend','base.bend','api.mjs','runtime.mjs','compiler-abi.mjs','node-resource-args.mjs','native-build.mjs','assemble.mjs'])fs.writeFileSync(file(name),name+'\n');
  fs.writeFileSync(file('driver.mjs'),`import fs from 'node:fs';
const output=process.argv[process.argv.indexOf('-o')+1];
if(process.env.MUTATE_INPUT)fs.appendFileSync(process.env.MUTATE_INPUT,'changed\\n');
if(process.env.RETARGET_SOURCE){fs.unlinkSync(process.argv[2]);fs.symlinkSync(process.env.RETARGET_SOURCE,process.argv[2]);}
fs.writeFileSync(output,'// fixed point\\n');
`);
  const env={...process.env,BEND_TYPED_API:file('api.mjs'),BEND_TYPED_RUNTIME:file('runtime.mjs'),BEND_BASE:file('base.bend'),BEND_SELFHOST_DRIVER:file('driver.mjs'),BEND_SELFHOST_STACK_KB:'0',BEND_SELFHOST_TIMEOUT:'5000',BEND_SELFHOST_RESUME:'2',BEND_SELFHOST_REPEAT:'0'};
  delete env.MUTATE_INPUT;
  delete env.RETARGET_SOURCE;
  return {file,run:extra=>spawnSync(process.execPath,[tool,file('source.bend'),file('result')],{env:{...env,...extra},encoding:'utf8',timeout:15000}),report:()=>JSON.parse(fs.readFileSync(file('result/report.json'),'utf8')),close:()=>fs.rmSync(directory,{recursive:true,force:true})};
}
test('self-host proof records Base and actual-driver helper identities for every stage',()=>{
  const f=fixture();try{
    const result=f.run();assert.equal(result.status,0,result.stderr);
    const report=f.report();assert.equal(report.complete,true);assert.equal(report.base.canonicalPath,f.file('base.bend'));
    assert.equal(report.hostHelpers.length,4);assert.ok(report.hostHelpers.every(input=>input.file.startsWith(path.dirname(f.file('driver.mjs'))+path.sep)));
    assert.ok(report.stages.every(stage=>stage.inputsVerified));
    const resumed=f.run({BEND_SELFHOST_RESUME:'3'});assert.equal(resumed.status,0,resumed.stderr);assert.equal(f.report().complete,true);
  }finally{f.close();}
});
for(const [name,label] of [['base.bend','Base'],['compiler-abi.mjs','host helper']])test('self-host rejects '+label+' drift during a stage',()=>{
  const f=fixture();try{
    const result=f.run({MUTATE_INPUT:f.file(name)});assert.notEqual(result.status,0);
    const report=f.report();assert.equal(report.complete,false);assert.match(report.error,new RegExp(label+' changed'));
    assert.equal(report.stages.length,1);assert.equal(report.stages[0].inputsVerified,false);
  }finally{f.close();}
});
test('self-host refuses legacy resume without Base/helper identity',()=>{
  const f=fixture();try{
    assert.equal(f.run().status,0);const report=f.report();delete report.base;delete report.hostHelpers;
    fs.writeFileSync(f.file('result/report.json'),JSON.stringify(report));
    const result=f.run({BEND_SELFHOST_RESUME:'3'});assert.notEqual(result.status,0);assert.match(result.stderr,/Legacy self-host report lacks verified Base\/helper provenance/);
  }finally{f.close();}
});
test('self-host refuses resume after Base or helper changes',()=>{
  for(const name of ['base.bend','assemble.mjs']){const f=fixture();try{
    assert.equal(f.run().status,0);fs.appendFileSync(f.file(name),'changed');
    const result=f.run({BEND_SELFHOST_RESUME:'3'});assert.notEqual(result.status,0);assert.match(result.stderr,/Resume Base or host helper inputs differ/);
  }finally{f.close();}}
});
test('restoring a changed Base does not validate the preceding tainted stage',()=>{
  const f=fixture();try{
    assert.notEqual(f.run({MUTATE_INPUT:f.file('base.bend')}).status,0);
    fs.writeFileSync(f.file('base.bend'),'base.bend\n');
    const result=f.run({BEND_SELFHOST_RESUME:'3'});assert.notEqual(result.status,0);assert.match(result.stderr,/Resume requires every preceding verified stage output/);
  }finally{f.close();}
});
test('fresh self-host attempt preserves an existing report and runtime snapshot',()=>{
  const f=fixture();try{
    assert.equal(f.run().status,0);const report=fs.readFileSync(f.file('result/report.json')),runtime=fs.readFileSync(f.file('result/runtime.mjs'));
    fs.appendFileSync(f.file('runtime.mjs'),'new external runtime');
    const result=f.run();assert.notEqual(result.status,0);assert.match(result.stderr,/Fresh self-host attempt refuses an existing report/);
    assert.deepEqual(fs.readFileSync(f.file('result/report.json')),report);assert.deepEqual(fs.readFileSync(f.file('result/runtime.mjs')),runtime);
  }finally{f.close();}
});
test('self-host rejects same-byte source symlink retarget during a stage and on resume',()=>{
  for(const during of [true,false]){const f=fixture();try{
    fs.renameSync(f.file('source.bend'),f.file('first.bend'));fs.copyFileSync(f.file('first.bend'),f.file('second.bend'));fs.symlinkSync(f.file('first.bend'),f.file('source.bend'));
    if(during){
      const result=f.run({RETARGET_SOURCE:f.file('second.bend')});assert.notEqual(result.status,0);assert.match(f.report().error,/Self-host source changed/);assert.equal(f.report().complete,false);
    }else{
      assert.equal(f.run().status,0);fs.unlinkSync(f.file('source.bend'));fs.symlinkSync(f.file('second.bend'),f.file('source.bend'));
      const result=f.run({BEND_SELFHOST_RESUME:'3'});assert.notEqual(result.status,0);assert.match(result.stderr,/Resume source identity differs/);
    }
  }finally{f.close();}}
});
