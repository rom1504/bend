import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import test from 'node:test';
test('paired native graph requires the selected source and canonical pinned Base',async()=>{
  const directory=fs.mkdtempSync(path.join(os.tmpdir(),'bend-native-adapter-'));
  const keys=['BEND_NATIVE_BINARY','BEND_NATIVE_RUNTIME','BEND_NATIVE_MANIFEST_DIRECTORY'],previous=Object.fromEntries(keys.map(key=>[key,process.env[key]]));
  try{
    const binary=path.join(directory,'binary'),runtime=path.join(directory,'runtime'),source=path.join(directory,'main.bend'),base=path.join(directory,'bend2/base.bend'),copy=path.join(directory,'copy.bend');
    fs.mkdirSync(path.dirname(base));for(const file of [binary,runtime,source,base,copy])fs.writeFileSync(file,'same bytes');
    process.env.BEND_NATIVE_BINARY=binary;process.env.BEND_NATIVE_RUNTIME=runtime;process.env.BEND_NATIVE_MANIFEST_DIRECTORY=directory;
    const adapter=await import(pathToFileURL(path.resolve(import.meta.dirname,'../../tools/conformance/adapters/native-graph.mjs')));
    const graph={main:source,modules:[{name:source,path:source},{name:'Base',path:base}]};
    assert.doesNotThrow(()=>adapter.validateGraphFixture(graph,{file:source},directory));
    assert.throws(()=>adapter.validateGraphFixture({...graph,modules:[graph.modules[0],{name:'Base',path:copy}]},{file:source},directory),/Base differs/);
    assert.throws(()=>adapter.validateGraphFixture(graph,{file:copy},directory),/main differs/);
    assert.equal(adapter.capabilities.js,true);for(const lane of ['parse','check','interpreter','native','metal','cuda'])assert.equal(adapter.capabilities[lane],false);
  }finally{for(const key of keys)if(previous[key]===undefined)delete process.env[key];else process.env[key]=previous[key];fs.rmSync(directory,{recursive:true,force:true});}
});
