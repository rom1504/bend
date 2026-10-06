// Shared Phase56 admission/staging. No checked metadata is created for B2.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
import {identity,verify,hash,directCompilerApi} from '../../phase54/bootstrap/adapter.mjs';

const root=path.resolve(import.meta.dirname,'../../../../..');
const closed=path.join(root,'selfhost/build/phase55');
const defaultComparison=path.join(closed,'bootstrap-own-host02-driver-comparison01.json');
const pins={emission:'654af8869256b3a9367f2ad98b5006c7791623790a25196a8a00fe8fb730531a',
  comparison:'69c556e987d3cbe4812911238b244b9613dbdf0dc3d63aac1f47a77f612f4f7e',
  source:'e4383fa08d621716acac437224de182af52e0b16c32b3f29b2614fc1ad1d6710',
  b1:'cfde1ebf44d958e593331cfd9af77f7b6ee657441dbd582db8d27f3928815a62',
  b2:'ae5abd461c24f707747f37b187cedcecd86f5d3c727950f8f8a332fd9dca4091',
  runtime:'c328b77360c98489343d4752d4644d93f64de9d697d2c964f5fbae6442a77d23'};
const walk=dir=>fs.readdirSync(dir,{withFileTypes:true}).sort((a,b)=>a.name.localeCompare(b.name))
  .flatMap(x=>x.isDirectory()?walk(path.join(dir,x.name)):[path.join(dir,x.name)]);

export async function setup(emissionFile,freshOut,{role='direct',comparisonFile=defaultComparison,progress=()=>{}}={}) {
  assert.ok(['source','direct'].includes(role));
  const out=path.resolve(freshOut),phase56=fs.realpathSync(path.join(root,'selfhost/build/phase56'));
  assert.ok(out.startsWith(phase56+path.sep),'Fresh output must be inside Phase56');
  assert.ok(!fs.existsSync(out),'Staging must be fresh');fs.mkdirSync(out,{recursive:true});
  assert.ok(fs.realpathSync(out).startsWith(phase56+path.sep),'No historical-output symlink');
  const inputs=[],copies=[],seen=new Map();
  function pin(value) {
    const actual=identity(typeof value==='string'||value instanceof URL?value:value.file);
    if(typeof value==='object'&&!(value instanceof URL)) {
      assert.equal(actual.sha256,value.sha256,actual.file);
      if(value.bytes!==undefined)assert.equal(fs.statSync(actual.file).size,value.bytes);
    }
    if(seen.has(actual.file))assert.deepEqual(seen.get(actual.file),actual);
    else {seen.set(actual.file,actual);inputs.push(actual);}
    return actual;
  }
  function read(value) {return JSON.parse(fs.readFileSync(pin(value).file,'utf8'));}
  const emissionId=pin(emissionFile),comparisonId=pin(comparisonFile);
  assert.equal(emissionId.sha256,pins.emission);assert.equal(comparisonId.sha256,pins.comparison);
  const emission=read(emissionId),comparison=read(comparisonId);
  assert.equal(emission.kind,'phase55-split-compiler-emission');assert.equal(emission.pass,true);assert.equal(emission.complete,true);
  assert.equal(emission.checking.lane,'inherited-exact-bootstrap');assert.equal(emission.checking.freshSelfCheck,false);
  assert.equal(emission.subject.source.sha256,pins.source);assert.equal(emission.module.sha256,pins.b2);
  assert.equal(emission.directRuntime.sha256,pins.runtime);assert.equal(emission.generator.api.sha256,pins.b1);
  assert.deepEqual(emission.subject.attempt,emission.generator.attempt);
  progress('verify-checked-subject','start');
  const attemptDirectory=path.dirname(emission.subject.attempt.file),attempt=await verifyAttempt(attemptDirectory);
  assert.deepEqual(pin(emission.subject.attempt),identity(path.join(attemptDirectory,'attempt.json')));
  assert.deepEqual(pin(emission.subject.bootstrap),identity(attempt.bootstrapReport.file));
  assert.deepEqual(pin(emission.generator.api),identity(attempt.api.file));
  assert.deepEqual(pin(emission.generator.runtime),identity(attempt.runtime.file));
  const bootstrap=read(emission.subject.bootstrap),config=read(emission.config);
  assert.deepEqual(pin(bootstrap.source),emission.subject.source);assert.equal(bootstrap.sourceSha256,pins.source);
  assert.deepEqual(config.subjectSource,emission.subject.source);assert.equal(config.subjectAttempt,attemptDirectory);
  assert.deepEqual(config.roots,emission.roots);assert.equal(emission.roots.length,77);assert.equal(new Set(emission.roots).size,77);
  for(const x of emission.inputs)pin(x);pin(emission.producer);pin(emission.progress);pin(emission.module);pin(emission.directRuntime);
  const derivation=read(emission.derivation);
  assert.equal(derivation.kind,'phase55-append-only-api-stages');assert.deepEqual(derivation.source,emission.generator.api);
  for(const key of ['source','core','output','producer'])pin(derivation[key]);
  const original=fs.readFileSync(derivation.source.file),derived=fs.readFileSync(derivation.output.file);
  assert.equal(derivation.originalPrefixBytes,original.length);assert.ok(derived.subarray(0,original.length).equals(original));
  assert.equal(hash(derived.subarray(original.length)),derivation.suffixSha256);
  const tiny=read(emission.qualification);
  assert.equal(tiny.pass,true);assert.equal(tiny.complete,true);assert.equal(tiny.splitEqualsUnsplit,true);
  assert.deepEqual(tiny.subject,emission.subject);assert.deepEqual(tiny.generator,emission.generator);
  for(const x of tiny.inputs)pin(x);pin(tiny.derivation);pin(tiny.module);pin(tiny.progress);
  progress('verify-checked-subject','complete');
  assert.equal(comparison.kind,'phase55-direct-compiler-driver-comparison');assert.equal(comparison.pass,true);
  assert.equal(comparison.complete,true);assert.equal(comparison.observations,8);pin(comparison.producer);pin(comparison.helper);
  const drivers=[read(comparison.source),read(comparison.direct)];
  for(const [i,r] of drivers.entries()) {
    assert.equal(r.kind,'phase55-direct-compiler-driver');assert.equal(r.complete,true);assert.equal(r.pass,true);
    assert.equal(r.role,i?'direct':'source');assert.deepEqual(r.emission,emissionId);
    assert.deepEqual(r.subject,emission.subject);assert.deepEqual(r.generator,emission.generator);
    assert.equal(r.api.sha256,i?pins.b2:pins.b1);assert.equal(r.observations.length,8);
    for(const x of r.inputs)pin(x);for(const x of r.copies)pin(x.after);for(const x of r.outputs||[])pin(x);
    pin(r.api);pin(r.progress);
  }
  assert.deepEqual(drivers[0].config,drivers[1].config);
  assert.deepEqual(drivers[0].observations.map(x=>({id:x.id,value:x.value})),drivers[1].observations.map(x=>({id:x.id,value:x.value})));
  for(const file of [import.meta.filename,new URL('../../phase54/bootstrap/adapter.mjs',import.meta.url),
    new URL('../../../development/workflow.mjs',import.meta.url),new URL('../../../development/process.mjs',import.meta.url),
    new URL('../../../conformance/inventory.mjs',import.meta.url),process.execPath])pin(file);
  const project=path.join(out,'project'),snapshot=attempt.snapshot.root;
  function copy(file,relative) {
    const before=pin(file),target=path.join(project,relative);fs.mkdirSync(path.dirname(target),{recursive:true});
    fs.copyFileSync(before.file,target,fs.constants.COPYFILE_EXCL);const after=identity(target);
    assert.equal(before.sha256,after.sha256);copies.push({before,after});return after;
  }
  for(const name of ['typed-driver','assemble','compiler-abi','node-resource-args','native-build'])
    copy(path.join(snapshot,'tools',name+'.mjs'),'tools/'+name+'.mjs');
  copy(path.join(snapshot,'src/compiler.json'),'src/compiler.json');
  const runtime=copy(attempt.runtime.file,'src/runtime.mjs');
  for(const file of walk(path.join(snapshot,'src/runtime')))copy(file,path.relative(snapshot,file));
  const actualApi=copy(role==='direct'?emission.module.file:attempt.api.file,'dist/api.mjs');
  assert.ok(!fs.existsSync(actualApi.file+'.bootstrap.json'),'No synthetic checked sidecar');
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
  process.env.BEND_TYPED_API=actualApi.file;process.env.BEND_TYPED_RUNTIME=runtime.file;process.env.BEND_BASE=attempt.base.file;
  const D=await import(pathToFileURL(path.join(project,'tools/typed-driver.mjs')));
  assert.equal(D.apiPath,actualApi.file);assert.equal(identity(D.runtimePath).sha256,attempt.runtime.sha256);
  assert.equal(identity(D.directRuntimePath).sha256,pins.runtime);
  assert.ok(!fs.existsSync(path.join(project,'build/typed/cache')),'No inherited Base cache');
  progress('load-image','start');const api=await D.loadApi();progress('load-image','complete');
  const raw=await import(pathToFileURL(actualApi.file));assert.equal(api,raw.default,'Ordinary named API route');
  if(role==='direct')directCompilerApi(raw,emission.roots);
  for(const name of emission.roots)assert.equal(typeof api[name],'function',name);
  const image={kind:role==='direct'?'direct-self-emitted-image':'checked-subject-api',api:actualApi,
    source:emission.subject.source,emission:emissionId,driverQualification:comparisonId,checkedSubject:emission.subject.attempt,
    runtime,base:pin(attempt.base),directRuntime:identity(D.directRuntimePath),driver:identity(path.join(project,'tools/typed-driver.mjs'))};
  async function verifyFinal() {
    for(const x of inputs)verify(x);for(const x of copies)verify(x.after);await verifyAttempt(attemptDirectory);
    const cache=path.join(project,'build/typed/cache'),cacheFiles=fs.existsSync(cache)?walk(cache).map(identity):[];
    for(const item of cacheFiles) {
      const c=JSON.parse(fs.readFileSync(item.file,'utf8'));
      assert.equal(c.compilerSha256,actualApi.sha256);assert.equal(c.baseSha256,attempt.base.sha256);
      assert.equal(c.sourcePath,fs.realpathSync(attempt.base.file));assert.equal(c.validatedBy,'check_book');
      assert.equal(c.bookSha256,hash(Buffer.from(JSON.stringify(c.book))));
    }
    assert.ok(!fs.existsSync(actualApi.file+'.bootstrap.json'));
    return {inputsUnchanged:true,copiesUnchanged:true,cacheFiles};
  }
  return {api,D,subject:emission.subject,emission,roots:emission.roots,inputs,copies,image,project,verifyFinal};
}
