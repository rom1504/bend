// Root-supervised target job. Exercise the unchanged driver with one exact API.
// Each role owns a private byte-identical driver/runtime copy and its Base cache.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
import {identity,verify,hash,directCompilerApi} from './adapter.mjs';

const [configFile,emissionFile,role,outArg]=process.argv.slice(2);
assert.ok(configFile&&emissionFile&&['source','direct'].includes(role)&&outArg,
  'driver-probe.mjs CONFIG EMISSION_REPORT source|direct NEW_DIRECTORY');
const config=JSON.parse(fs.readFileSync(configFile,'utf8')),out=path.resolve(outArg);
assert.ok(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const report={kind:'phase54-direct-compiler-driver',pass:false,complete:false,role,
  config:identity(configFile),producer:identity(import.meta.filename),inputs:[],copies:[],observations:[]};
const started=performance.now();
function copy(file,target) {
  const before=identity(file);fs.mkdirSync(path.dirname(target),{recursive:true});fs.copyFileSync(file,target,fs.constants.COPYFILE_EXCL);
  const after=identity(target);assert.equal(before.sha256,after.sha256);report.inputs.push(before);report.copies.push({before,after});
}
function walk(dir) {return fs.readdirSync(dir,{withFileTypes:true}).sort((a,b)=>a.name.localeCompare(b.name))
  .flatMap(x=>x.isDirectory()?walk(path.join(dir,x.name)):[path.join(dir,x.name)]);}
function compact(result,id) {
  const value={...result};
  if(value.code!==undefined) {
    const target=path.join(out,id+(id==='native-c'?'.c':'.mjs'));
    fs.writeFileSync(target,value.code,{flag:'wx'});report.outputs??=[];report.outputs.push(identity(target));
    value.codeSha256=hash(Buffer.from(value.code));value.codeBytes=Buffer.byteLength(value.code);delete value.code;
  }
  if(value.files) {report.inputs.push(...value.files.map(identity));value.fileHashes=value.files.map(f=>identity(f).sha256);delete value.files;}
  return value;
}
try {
  const attempt=await verifyAttempt(config.attempt);
  for(const x of config.exactInputs)verify(x);
  const emissionIdentity=identity(emissionFile),emission=JSON.parse(fs.readFileSync(emissionFile,'utf8'));
  assert.equal(emission.kind,'phase54-direct-compiler-emission');assert.equal(emission.complete,true);assert.equal(emission.pass,true);
  assert.deepEqual(emission.attempt,identity(path.join(config.attempt,'attempt.json')));
  assert.deepEqual(emission.roots,config.roots);
  const full={file:emission.module.file,sha256:emission.module.sha256};verify(full);
  report.inputs.push(report.config,report.producer,identity(new URL('./adapter.mjs',import.meta.url)),
    identity(new URL('../../../development/workflow.mjs',import.meta.url)),emissionIdentity,full,...config.exactInputs);
  const original=attempt.snapshot.root,project=path.join(out,'project');
  for(const name of ['typed-driver','assemble','compiler-abi','node-resource-args','native-build'])
    copy(path.join(original,'tools',name+'.mjs'),path.join(project,'tools',name+'.mjs'));
  copy(path.join(original,'src/compiler.json'),path.join(project,'src/compiler.json'));
  copy(attempt.runtime.file,path.join(project,'src/runtime.mjs'));
  for(const file of walk(path.join(original,'src/runtime')))
    copy(file,path.join(project,path.relative(original,file)));
  const apiFile=role==='direct'?full.file:attempt.api.file;
  const apiIdentity=identity(apiFile);report.api=apiIdentity;report.emission=emissionIdentity;
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
  process.env.BEND_TYPED_API=apiFile;process.env.BEND_TYPED_RUNTIME=path.join(project,'src/runtime.mjs');process.env.BEND_BASE=attempt.base.file;
  const D=await import(pathToFileURL(path.join(project,'tools/typed-driver.mjs')));
  assert.equal(D.apiPath,apiFile);assert.equal(identity(D.runtimePath).sha256,attempt.runtime.sha256);
  assert.equal(identity(D.directRuntimePath).sha256,emission.directRuntime.sha256);
  const api=await D.loadApi();
  const raw=await import(pathToFileURL(apiFile));
  if(role==='direct') {
    const facade=directCompilerApi(raw,config.roots);
    for(const name of config.roots)assert.equal(api[name],facade[name]);
    report.rawExports=Object.keys(raw.default).sort();
  } else for(const name of config.roots)assert.equal(typeof api[name],'function',name);
  for(const test of config.tests) {
    verify(test.source);report.inputs.push(test.source);const begin=performance.now();
    const result=test.mode==='run'?
      await D.execute(test.source.file,{backend:'direct',timeoutMs:10000,workdir:fs.mkdtempSync(path.join(out,'run-'))}):
      await D.inspect(test.source.file,{mode:test.mode,backend:test.mode==='native'?'js':'direct'});
    const value=compact(result,test.id);
    report.observations.push({id:test.id,seconds:(performance.now()-begin)/1000,value});
    assert.equal(value.status,test.status,test.id+': '+JSON.stringify(value));
    if(test.phase)assert.equal(value.phase,test.phase,test.id);
    if(test.stdout!==undefined)assert.equal(value.stdout,test.stdout,test.id);
    if(test.status==='error')assert.ok(value.diagnostic?.length>0,'Missing rejection diagnostic');
    if(['compile','native'].includes(test.mode))assert.ok(value.codeBytes>0,'Empty emitted program');
  }
  // A second successful request follows rejected inputs; no stale failure state.
  assert.equal(report.observations.at(-1).id,'check-replay');
  report.cacheFiles=walk(path.join(project,'build/typed/cache')).map(identity);
  for(const x of report.inputs)verify(x);for(const x of report.copies)verify(x.after);verify(apiIdentity);
  await verifyAttempt(config.attempt);report.pass=true;report.complete=true;
} catch(error) {report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1;}
finally {
  report.seconds=(performance.now()-started)/1000;
  fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
  console.log(JSON.stringify({pass:report.pass,role,observations:report.observations.length,seconds:report.seconds,error:report.error?.message}));
}
