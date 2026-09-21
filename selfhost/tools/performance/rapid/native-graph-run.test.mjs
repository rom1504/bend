import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {runNativeGraph, loadNativeGraphManifest} from './native-graph-run.mjs';
const dir = fs.mkdtempSync(path.join(os.tmpdir(),'bend-native-graph-test-'));
let checks = 0;
try {
  const files = Object.fromEntries(['binary','main.bend','base.bend','runtime.mjs','helper 🐈.bend','foreign.js','unused.bend'].map(name => { const file=path.join(dir,name);fs.writeFileSync(file,name);return [name,file]; }));
  const manifest=path.join(dir,'manifest.json'),output=path.join(dir,'out.mjs');
  const write = extra => fs.writeFileSync(manifest,JSON.stringify({version:1,main:'main.bend',base:'base.bend',modules:['helper 🐈.bend','unused.bend'],assets:['foreign.js','missing-unused.js'],...extra}));
  const config={binary:files.binary,manifest,runtime:files['runtime.mjs'],output};
  const success = (command,args) => {
    const start=args.indexOf('--graph'),wire=args[start+1],out=args[start+3];
    const fields=fs.readFileSync(wire,'utf8').split('\0');
    assert.equal(fields[0],'BEND_GRAPH_1');assert.equal(fields.at(-2),'E');assert.equal(fields.at(-1),'');
    fs.writeFileSync(out,'compiled');
    return {status:0,signal:null,stdout:'',stderr:'asset_used=0\ncompile_ms=1\nconsumed_chars=8\n'};
  };
  write(); const report=runNativeGraph(config,{spawn:success});
  assert.equal(report.published,true);assert.equal(report.usedAssetIds.length,1);assert.ok(report.assets[0].sha256);assert.equal(report.assets[1].missing,true);assert.equal(report.assets[1].sha256,undefined);checks++;
  assert.equal(fs.readFileSync(output,'utf8'),'compiled');checks++;
  const alias=path.join(dir,'alias.bend');fs.symlinkSync(files['helper 🐈.bend'],alias);
  write({modules:['alias.bend','helper 🐈.bend']});const graph=loadNativeGraphManifest(manifest);
  assert.equal(graph.modules[2].path,graph.modules[3].path);assert.notEqual(graph.modules[2].name,graph.modules[3].name);checks++;
  write({modules:[{name:'same',path:'main.bend'},{name:'same',path:'helper 🐈.bend'}]});assert.throws(()=>loadNativeGraphManifest(manifest),/collision/);checks++;
  write({assets:['foreign.js','foreign.js']});assert.throws(()=>loadNativeGraphManifest(manifest),/Duplicate/);checks++;
  write({version:2});assert.throws(()=>loadNativeGraphManifest(manifest),/version/);checks++;
  write({main:'main\0.bend'});assert.throws(()=>loadNativeGraphManifest(manifest),/Invalid/);checks++;
  write({main:'\ud800.bend'});assert.throws(()=>loadNativeGraphManifest(manifest),/Invalid/);checks++;
  write();for(const file of [manifest,files.binary,files['main.bend'],files['base.bend'],files['runtime.mjs'],files['helper 🐈.bend'],files['foreign.js']]){assert.throws(()=>runNativeGraph({...config,output:file},{spawn:success}),/aliases/);checks++;}
  const hardlink=path.join(dir,'hardlink-output');fs.linkSync(files['foreign.js'],hardlink);assert.throws(()=>runNativeGraph({...config,output:hardlink},{spawn:success}),/aliases/);checks++;
  const symlink=path.join(dir,'symlink-output');fs.symlinkSync(output,symlink);assert.throws(()=>runNativeGraph({...config,output:symlink},{spawn:success}),/symbolic link/);checks++;
  fs.writeFileSync(output,'previous');const failed=runNativeGraph(config,{spawn:()=>({status:1,stderr:'phase=compile checked=True: missing asset\n'})});assert.equal(failed.checked,true);assert.equal(failed.phase,'compile');assert.equal(failed.published,false);assert.equal(fs.readFileSync(output,'utf8'),'previous');checks++;
  const timeout=runNativeGraph(config,{spawn:()=>({status:null,signal:'SIGTERM',error:new Error('timeout')})});assert.equal(timeout.published,false);assert.equal(fs.readFileSync(output,'utf8'),'previous');checks++;
  const drift=runNativeGraph(config,{spawn:(...args)=>{const result=success(...args);fs.appendFileSync(files['main.bend'],'changed');return result;}});assert.match(drift.error,/Input changed/);assert.equal(drift.published,false);assert.equal(drift.phase,'host');assert.equal(drift.compileMs,1);assert.ok(drift.unpublishedOutput.sha256);assert.equal(fs.readFileSync(output,'utf8'),'previous');checks++;
  assert.match(runNativeGraph(config,{spawn:(...args)=>{const result=success(...args);fs.appendFileSync(files['foreign.js'],'changed');return result;}}).error,/Input changed/);checks++;
  const second=path.join(dir,'second-alias.bend');fs.symlinkSync(files['helper 🐈.bend'],second);
  write({modules:[{name:'logical.bend',path:'helper 🐈.bend'},{name:'logical.bend',path:'second-alias.bend'}]});
  assert.equal(loadNativeGraphManifest(manifest).moduleAliases.length,1);checks++;
  assert.match(runNativeGraph(config,{spawn:(...args)=>{const result=success(...args);fs.unlinkSync(second);fs.symlinkSync(files['main.bend'],second);return result;}}).error,/Input changed/);checks++;
  write({modules:[{name:'other.bend',path:'helper 🐈.bend'},{name:'helper 🐈.bend',path:'unused.bend'}]});assert.throws(()=>loadNativeGraphManifest(manifest),/logical\/physical identity collision/);checks++;
  assert.equal(fs.readdirSync(dir).some(name=>name.startsWith('.bend-native-graph-')),false);checks++;
  console.log(JSON.stringify({passed:true,checks}));
} finally {fs.rmSync(dir,{recursive:true,force:true});}
