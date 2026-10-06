// Narrow derivative of frozen setup.mjs b31568cd06d8a5b725ad6f1ce92808bb0a407f29764b807db96f9ca4f4b68985.
// Existing raw/equality/choice/tail-choice stages; no new checked metadata.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../development/workflow.mjs';
import {identity,verify,hash} from '../phase54/bootstrap/adapter.mjs';

const root=path.resolve(import.meta.dirname,'../../../..');
const walk=dir=>fs.readdirSync(dir,{withFileTypes:true}).sort((a,b)=>a.name.localeCompare(b.name))
  .flatMap(x=>x.isDirectory()?walk(path.join(dir,x.name)):[path.join(dir,x.name)]);

export async function setup(pinsFile,freshOut,{role='source',stagesFile,progress=()=>{}}={}) {
  assert.ok(['raw','equality','choices','source'].includes(role));
  assert.ok(stagesFile,'An exact intermediate-transform receipt is required');
  const out=path.resolve(freshOut),phase57=fs.realpathSync(path.join(root,'selfhost/build/phase57'));
  assert.ok(out.startsWith(phase57+path.sep),'Fresh output must be inside Phase57');
  assert.ok(!fs.existsSync(out),'Staging must be fresh');fs.mkdirSync(out,{recursive:true});
  assert.ok(fs.realpathSync(out).startsWith(phase57+path.sep),'No historical-output symlink');
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
  assert.equal(pin(pinsFile).sha256,'11c5e4982678ac88e86f7d304ba8c3fc12c22ec756b0b2fa43f615a23ab77619','Exact string01 image pins');
  const binding=read(pinsFile);assert.equal(binding.kind,'phase56-direct-image-pins');
  for(const key of ['producer','plan','attempt','emission','comparison','source','b1','b2','runtime','rootsReference'])pin(binding[key]);
  const reference=read(binding.rootsReference);assert.deepEqual(binding.roots,reference.roots);
  const plan=read(binding.plan);assert.equal(plan.kind,'phase56-candidate-image-plan');assert.deepEqual(plan.attempt,binding.attempt);
  for(const item of [...plan.inputs,...plan.configs])pin(item);
  for(const derivative of plan.derivations) {
    let text=fs.readFileSync(pin(derivative.parent).file,'utf8');
    for(const edit of derivative.edits) {assert.ok(text.includes(edit.old));text=text.split(edit.old).join(edit.new);}
    assert.equal(fs.readFileSync(pin(derivative.output).file,'utf8'),text,'Unrecorded diagnostic tool change');
  }
  const pins={emission:binding.emission.sha256,comparison:binding.comparison.sha256,source:binding.source.sha256,
    b1:binding.b1.sha256,b2:binding.b2.sha256,runtime:binding.runtime.sha256};
  const emissionId=pin(binding.emission),comparisonId=pin(binding.comparison);
  assert.equal(emissionId.sha256,pins.emission);assert.equal(comparisonId.sha256,pins.comparison);
  const emission=read(emissionId),comparison=read(comparisonId);
  assert.deepEqual(emission.subject.attempt,binding.attempt);assert.deepEqual(emission.subject.source,binding.source);
  assert.deepEqual(emission.generator.api,binding.b1);assert.deepEqual(identity(emission.module.file),binding.b2);
  assert.deepEqual(emission.directRuntime,binding.runtime);assert.deepEqual(emission.roots,binding.roots);
  assert.deepEqual(emission.config,plan.configs[1]);
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
  assert.equal(pin(attempt.checkedApi).sha256,'1498f6758c1ce713225209cc6ad9e0c27a0d5aee2ed674c4ae35990cf945cf52');
  assert.equal(bootstrap.apiSha256,attempt.checkedApi.sha256,'Raw API is the genuinely checked upstream emission');
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
  for(const file of [import.meta.filename,new URL('../phase54/bootstrap/adapter.mjs',import.meta.url),
    new URL('../../development/workflow.mjs',import.meta.url),new URL('../../development/process.mjs',import.meta.url),
    new URL('../../conformance/inventory.mjs',import.meta.url),process.execPath])pin(file);
  assert.equal(pin(new URL('./setup.mjs',import.meta.url)).sha256,'b31568cd06d8a5b725ad6f1ce92808bb0a407f29764b807db96f9ca4f4b68985','Frozen staging parent');
  const stagesId=pin(stagesFile),stages=read(stagesId);
  assert.equal(stages.kind,'phase57-existing-b1-intermediates');
  assert.equal(stages.complete,true);assert.equal(stages.pass,true);assert.equal(stages.newBootstrap,false);
  for(const item of stages.inputs)pin(item);
  const derivationId=pin(path.join(attemptDirectory,'equality/api.mjs.derivation.json'));
  assert.equal(derivationId.sha256,'5b0e2ecf90c7127cb122b6e56a119b7ca647216f804520fc202519388416308e');
  const derivedProof=read(derivationId);
  assert.equal(derivedProof.complete,true);assert.equal(derivedProof.newBootstrap,false);assert.equal(derivedProof.transform.version,6);
  assert.equal(pin(derivedProof.original.api).sha256,attempt.checkedApi.sha256);
  assert.equal(pin(derivedProof.original.source).sha256,emission.subject.source.sha256);
  assert.equal(pin(derivedProof.original.bootstrapReport).sha256,emission.subject.bootstrap.sha256);
  assert.equal(pin(derivedProof.output).sha256,attempt.api.sha256);
  assert.equal(stages.scope,derivedProof.scope);
  const tool=fs.readFileSync(pin(derivedProof.tool).file,'utf8');
  assert.equal(pin(stages.helper.original).sha256,derivedProof.tool.sha256);
  assert.equal(stages.helper.appended,'\nexport {transformChoices,transformTailChoices};\n');
  assert.equal(fs.readFileSync(pin(stages.helper).file,'utf8'),tool+stages.helper.appended);
  // Only the frozen source transformer is imported here, never a compiler image.
  const transformer=await import(pathToFileURL(stages.helper.file));
  const rawText=fs.readFileSync(attempt.checkedApi.file,'utf8'),sourceText=fs.readFileSync(attempt.api.file,'utf8');
  const body=text=>{const xs=[...text.matchAll(/^function \$String\$eq\$\([^\n]*\) \{\n[\s\S]*?^\}/gm)];assert.equal(xs.length,1);return xs[0];};
  const oldBody=body(rawText),newBody=body(sourceText);
  const equality=rawText.slice(0,oldBody.index)+newBody[0]+rawText.slice(oldBody.index+oldBody[0].length);
  assert.equal(hash(Buffer.from(equality)),derivedProof.transform.choices.inputSha256);
  const choices=transformer.transformChoices(equality,true);
  assert.deepEqual(choices.report,derivedProof.transform.choices);
  const source=transformer.transformTailChoices(choices.source);
  assert.deepEqual(source.report,derivedProof.transform.tailChoices);assert.equal(source.source,sourceText);
  const texts={raw:rawText,equality,choices:choices.source,source:source.source};
  assert.deepEqual(stages.outputs.map(x=>x.role),Object.keys(texts));
  for(const item of stages.outputs)assert.equal(fs.readFileSync(pin(item).file,'utf8'),texts[item.role]);
  const selectedStage=stages.outputs.find(x=>x.role===role);assert.ok(selectedStage);
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
  const actualApi=copy(selectedStage.file,'dist/api.mjs');
  assert.ok(!fs.existsSync(actualApi.file+'.bootstrap.json'),'No synthetic checked sidecar');
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
  process.env.BEND_TYPED_API=actualApi.file;process.env.BEND_TYPED_RUNTIME=runtime.file;process.env.BEND_BASE=attempt.base.file;
  const D=await import(pathToFileURL(path.join(project,'tools/typed-driver.mjs')));
  assert.equal(D.apiPath,actualApi.file);assert.equal(identity(D.runtimePath).sha256,attempt.runtime.sha256);
  assert.equal(identity(D.directRuntimePath).sha256,pins.runtime);
  assert.ok(!fs.existsSync(path.join(project,'build/typed/cache')),'No inherited Base cache');
  progress('load-image','start');const api=await D.loadApi();progress('load-image','complete');
  const raw=await import(pathToFileURL(actualApi.file));assert.equal(api,raw.default,'Ordinary named API route');
  for(const name of emission.roots)assert.equal(typeof api[name],'function',name);
  const image={kind:'diagnostic-derived-bootstrap-image',role,api:actualApi,
    rawCheckedApi:pin(attempt.checkedApi),rawSourceProof:emission.subject.bootstrap,
    transformStages:stagesId,derivation:derivationId,selectedStage,scope:derivedProof.scope,
    source:emission.subject.source,emission:emissionId,driverQualification:comparisonId,driverQualificationApplies:role==='source',checkedSubject:emission.subject.attempt,
    pins:identity(pinsFile),runtime,base:pin(attempt.base),directRuntime:identity(D.directRuntimePath),driver:identity(path.join(project,'tools/typed-driver.mjs'))};
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
