// Honest checked/emitted/diagnostic images; no bootstrap sidecar is synthesized.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
import {identity,verify,hash,directCompilerApi} from '../../phase54/bootstrap/adapter.mjs';

const root=path.resolve(import.meta.dirname,'../../../../..');
const walk=dir=>fs.readdirSync(dir,{withFileTypes:true}).sort((a,b)=>a.name.localeCompare(b.name))
  .flatMap(x=>x.isDirectory()?walk(path.join(dir,x.name)):[path.join(dir,x.name)]);
export async function setup(bindingsFile,freshOut,{role,progress=()=>{}}={}) {
  const inputs=[],copies=[],seen=new Map(),attempts=new Map();
  function pin(value) {
    const actual=identity(typeof value==='string'||value instanceof URL?value:value.file);
    if(typeof value==='object'&&!(value instanceof URL)) {
      assert.equal(actual.sha256,value.sha256,actual.file);
      if(value.bytes!==undefined)assert.equal(fs.statSync(actual.file).size,value.bytes);
    }
    if(!seen.has(actual.file)){seen.set(actual.file,actual);inputs.push(actual)}
    else assert.deepEqual(seen.get(actual.file),actual);
    return actual;
  }
  const read=value=>JSON.parse(fs.readFileSync(pin(value).file,'utf8'));
  const binding=read(bindingsFile);assert.equal(binding.kind,'phase58-compiler-image-bindings');
  assert.equal(binding.version,1);assert.ok(['fixed-source','changed-source'].includes(binding.comparison));
  async function checked(value) {
    const id=pin(value),directory=path.dirname(id.file);assert.equal(path.basename(id.file),'attempt.json');
    if(!attempts.has(directory))attempts.set(directory,await verifyAttempt(directory));
    const a=attempts.get(directory);assert.equal(a.checked,true);assert.equal(typeof a.config.strictExact,'boolean');
    const boot=read(a.bootstrapReport),source=pin(boot.source);
    assert.equal(source.sha256,boot.sourceSha256);
    pin(a.api);pin(a.checkedApi);pin(a.runtime);pin(a.base);
    return {attempt:a,attemptId:id,subject:{attempt:id,bootstrap:pin(a.bootstrapReport),source},roots:boot.exports};
  }
  async function resolve(name,depth=0) {
    assert.ok(depth<3,'Image derivation depth');const spec=binding.roles[name];assert.ok(spec);
    if(spec.kind==='syntax') {
      assert.notEqual(spec.parentRole,name);const parent=await resolve(spec.parentRole,depth+1);
      assert.equal(parent.kind,'direct','Syntax experiments derive a genuine direct emission');
      const id=pin(spec.derivation),d=read(id);
      assert.equal(d.complete,true);assert.equal(d.pass,true);assert.equal(typeof d.scope,'string');
      assert.equal(pin(d.parent).sha256,parent.api.sha256);pin(d.producer);
      return {...parent,kind:'syntax',api:pin(d.output),diagnosticDerivation:id,scope:d.scope};
    }
    assert.ok(['checked','direct'].includes(spec.kind));const generator=await checked(spec.attempt);
    if(spec.kind==='checked')return {...generator,kind:'checked',api:pin(generator.attempt.api),emission:null};
    const id=pin(spec.emission),e=read(id);
    assert.equal(e.kind,'phase55-split-compiler-emission');assert.equal(e.complete,true);assert.equal(e.pass,true);
    assert.deepEqual(pin(e.generator.attempt),generator.subject.attempt);
    assert.deepEqual(pin(e.generator.api),pin(generator.attempt.api));
    assert.deepEqual(pin(e.generator.bootstrap),pin(generator.attempt.bootstrapReport));
    assert.deepEqual(pin(e.generator.runtime),pin(generator.attempt.runtime));
    const subject=await checked(e.subject.attempt);assert.deepEqual(subject.subject,e.subject);
    assert.equal(e.checking.lane,'inherited-exact-bootstrap');assert.equal(e.checking.freshSelfCheck,false);
    assert.equal(e.checking.sourceSha256,subject.subject.source.sha256);
    assert.deepEqual(e.roots,subject.roots);assert.equal(new Set(e.roots).size,e.roots.length);
    for(const x of e.inputs)pin(x);pin(e.producer);pin(e.config);pin(e.progress);
    const config=read(e.config);assert.deepEqual(config.subjectSource,subject.subject.source);
    assert.deepEqual(config.roots,e.roots);
    const derivation=read(e.derivation);assert.equal(derivation.kind,'phase55-append-only-api-stages');
    assert.deepEqual(pin(derivation.source),pin(generator.attempt.api));
    const original=fs.readFileSync(derivation.source.file),derived=fs.readFileSync(pin(derivation.output).file);
    assert.equal(derivation.originalPrefixBytes,original.length);assert.ok(derived.subarray(0,original.length).equals(original));
    assert.equal(hash(derived.subarray(original.length)),derivation.suffixSha256);pin(derivation.producer);pin(derivation.core);
    const tiny=read(e.qualification);assert.equal(tiny.complete,true);assert.equal(tiny.pass,true);
    assert.equal(tiny.splitEqualsUnsplit,true);assert.deepEqual(tiny.subject,e.subject);assert.deepEqual(tiny.generator,e.generator);
    const runtime=pin(path.join(generator.attempt.snapshot.root,'src/runtime/js/direct.mjs'));
    assert.deepEqual(pin(e.directRuntime),runtime);
    return {...generator,subject:subject.subject,kind:'direct',api:pin(e.module),emission:id,roots:e.roots};
  }
  progress('verify-image','start');const selected=await resolve(role);progress('verify-image','complete');
  const out=path.resolve(freshOut),boundary=path.join(root,'selfhost/build/phase58');
  assert.ok(out.startsWith(boundary+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
  assert.ok(fs.realpathSync(out).startsWith(fs.realpathSync(boundary)+path.sep));
  const project=path.join(out,'project'),snapshot=selected.attempt.snapshot.root;
  function copy(file,relative) {
    const before=pin(file),target=path.join(project,relative);fs.mkdirSync(path.dirname(target),{recursive:true});
    fs.copyFileSync(before.file,target,fs.constants.COPYFILE_EXCL);const after=identity(target);
    assert.equal(before.sha256,after.sha256);copies.push({before,after});return after;
  }
  for(const name of ['typed-driver','assemble','compiler-abi','node-resource-args','native-build'])
    copy(path.join(snapshot,'tools',name+'.mjs'),'tools/'+name+'.mjs');
  copy(path.join(snapshot,'src/compiler.json'),'src/compiler.json');
  const runtime=copy(selected.attempt.runtime.file,'src/runtime.mjs');
  for(const file of walk(path.join(snapshot,'src/runtime')))copy(file,path.relative(snapshot,file));
  const apiFile=copy(selected.api.file,'dist/api.mjs');assert.ok(!fs.existsSync(apiFile.file+'.bootstrap.json'));
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
  process.env.BEND_TYPED_API=apiFile.file;process.env.BEND_TYPED_RUNTIME=runtime.file;process.env.BEND_BASE=selected.attempt.base.file;
  const D=await import(pathToFileURL(path.join(project,'tools/typed-driver.mjs')));
  const api=await D.loadApi(),mod=await import(pathToFileURL(apiFile.file));assert.equal(api,mod.default);
  if(selected.kind!=='checked')directCompilerApi(mod,selected.roots);
  for(const name of selected.roots)assert.equal(typeof api[name],'function',name);
  const image={kind:selected.kind,role,api:apiFile,source:selected.subject.source,emission:selected.emission,
    checkedGenerator:selected.attemptId,strictExact:selected.attempt.config.strictExact,
    diagnosticDerivation:selected.diagnosticDerivation??null,productionQualified:false,
    runtime,base:pin(selected.attempt.base),directRuntime:identity(D.directRuntimePath),driver:identity(path.join(project,'tools/typed-driver.mjs'))};
  for(const file of [import.meta.filename,new URL('../../phase54/bootstrap/adapter.mjs',import.meta.url),
    new URL('../../../development/workflow.mjs',import.meta.url),new URL('../../../development/process.mjs',import.meta.url),
    new URL('../../../conformance/inventory.mjs',import.meta.url),process.execPath])pin(file);
  async function verifyFinal() {
    for(const x of inputs)verify(x);for(const x of copies)verify(x.after);
    const cache=path.join(project,'build/typed/cache'),cacheFiles=fs.existsSync(cache)?walk(cache).map(identity):[];
    for(const item of cacheFiles) {
      const c=JSON.parse(fs.readFileSync(item.file,'utf8'));
      assert.equal(c.compilerSha256,apiFile.sha256);assert.equal(c.baseSha256,selected.attempt.base.sha256);
      assert.equal(c.sourcePath,fs.realpathSync(selected.attempt.base.file));assert.equal(c.validatedBy,'check_book');
      assert.equal(c.bookSha256,hash(Buffer.from(JSON.stringify(c.book))));
    }
    return {inputsUnchanged:true,copiesUnchanged:true,cacheFiles};
  }
  return {api,D,subject:selected.subject,inputs,copies,image,project,verifyFinal};
}
