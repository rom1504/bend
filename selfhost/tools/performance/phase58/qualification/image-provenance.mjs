// Receipt validation only; never import or execute the compiler image.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {identity,verify} from '../../phase54/bootstrap/adapter.mjs';

export function readImage(row,base='.') {
 const file=path.resolve(base,row.file??row.path);assert.equal(identity(file).sha256,row.sha256);
 const record=JSON.parse(fs.readFileSync(file,'utf8')),inputs=[identity(file)];
 const pin=item=>{verify(item);inputs.push(item);return item;};
 assert.equal(record.kind,'phase56-staged-direct-image');assert.equal(record.complete,true);
 assert.equal(record.freshSelfCheck,false);assert.equal(record.checked,undefined);
 const image=record.image;assert.equal(image.kind,'direct-self-emitted-image');
 pin(image.pins);const binding=JSON.parse(fs.readFileSync(image.pins.file,'utf8'));
 assert.equal(binding.kind,'phase56-direct-image-pins');
 for(const key of ['producer','plan','attempt','emission','comparison','source','b1','b2','runtime','rootsReference'])pin(binding[key]);
 assert.deepEqual(image.emission,binding.emission);assert.deepEqual(image.driverQualification,binding.comparison);
 assert.equal(image.api.sha256,binding.b2.sha256);assert.deepEqual(image.source,binding.source);
 assert.deepEqual(image.checkedSubject,binding.attempt);assert.equal(image.directRuntime.sha256,binding.runtime.sha256);
 const plan=JSON.parse(fs.readFileSync(binding.plan.file,'utf8'));assert.equal(plan.kind,'phase56-candidate-image-plan');assert.deepEqual(plan.attempt,binding.attempt);
 for(const item of [...plan.inputs,...plan.configs])pin(item);
 for(const derivative of plan.derivations){let text=fs.readFileSync(pin(derivative.parent).file,'utf8');for(const edit of derivative.edits){assert(text.includes(edit.old));text=text.split(edit.old).join(edit.new);}assert.equal(fs.readFileSync(pin(derivative.output).file,'utf8'),text);}
 const comparison=JSON.parse(fs.readFileSync(binding.comparison.file,'utf8'));assert(comparison.complete&&comparison.pass);assert.equal(comparison.kind,'phase55-direct-compiler-driver-comparison');assert.equal(comparison.observations,8);
 const driverReports=[comparison.source,comparison.direct].map(row=>JSON.parse(fs.readFileSync(pin(row).file,'utf8')));
 for(const [i,r]of driverReports.entries()){assert(r.complete&&r.pass);assert.equal(r.kind,'phase55-direct-compiler-driver');assert.equal(r.role,i?'direct':'source');assert.deepEqual(r.emission,binding.emission);assert.equal(r.api.sha256,i?binding.b2.sha256:binding.b1.sha256);assert.equal(r.observations.length,8);for(const row of r.inputs)pin(row);for(const row of r.copies){pin(row.before);pin(row.after);}for(const row of r.outputs??[])pin(row);}
 assert.deepEqual(driverReports[0].config,driverReports[1].config);assert.deepEqual(driverReports[0].observations.map(x=>({id:x.id,value:x.value})),driverReports[1].observations.map(x=>({id:x.id,value:x.value})));
 for(const item of Object.values(image))if(item&&typeof item==='object'&&item.file&&item.sha256)pin(item);
 const emission=JSON.parse(fs.readFileSync(image.emission.file,'utf8'));
 assert(emission.complete&&emission.pass);assert.equal(emission.kind,'phase55-split-compiler-emission');
 assert.equal(emission.checking.freshSelfCheck,false);assert.deepEqual(emission.subject,record.subject);
 assert.deepEqual(emission.generator,record.generator);assert.deepEqual(emission.generator.api,binding.b1);assert.deepEqual(emission.config,plan.configs[1]);assert.deepEqual(record.roots,binding.roots);assert.deepEqual(binding.roots,JSON.parse(fs.readFileSync(binding.rootsReference.file,'utf8')).roots);for(const r of driverReports){assert.deepEqual(r.subject,emission.subject);assert.deepEqual(r.generator,emission.generator);}assert.deepEqual(record.roots,emission.roots);assert.equal(record.roots.length,77);
 assert.deepEqual(image.source,emission.subject.source);assert.deepEqual(image.checkedSubject,emission.subject.attempt);
 assert.equal(image.api.sha256,emission.module.sha256);assert.equal(image.directRuntime.sha256,emission.directRuntime.sha256);
 const subject=JSON.parse(fs.readFileSync(image.checkedSubject.file,'utf8'));assert(subject.checked);
 assert.equal(subject.api.sha256,emission.generator.api.sha256);assert.equal(image.runtime.sha256,subject.runtime.sha256);assert.equal(image.base.sha256,subject.base.sha256);
 const frozen=new Map(subject.snapshot.sources.map(r=>[r.frozen.file,r.frozen.sha256]));
 assert.equal(image.driver.sha256,frozen.get(path.join(subject.snapshot.root,'tools/typed-driver.mjs')));
 assert.equal(image.directRuntime.sha256,frozen.get(path.join(subject.snapshot.root,'src/runtime/js/direct.mjs')));
 for(const item of record.inputs)pin(item);
 for(const copy of record.copies){assert.equal(copy.before.sha256,copy.after.sha256);pin(copy.before);pin(copy.after);}
 const copied=new Map(record.copies.map(r=>[r.after.file,r.after.sha256]));
 for(const key of ['api','runtime','driver','directRuntime'])assert.equal(copied.get(image[key].file),image[key].sha256);
 assert.equal(fs.realpathSync(record.project),path.dirname(path.dirname(image.driver.file)));
 const phase56=path.resolve(import.meta.dirname,'../../../../build/phase58');
 assert(fs.realpathSync(record.project).startsWith(fs.realpathSync(phase56)+path.sep),'Caches must stay in Phase58');
 assert.equal(path.relative(record.project,image.api.file),'dist/api.mjs');
 assert.equal(path.relative(record.project,image.runtime.file),'src/runtime.mjs');
 assert.equal(path.relative(record.project,image.directRuntime.file),'src/runtime/js/direct.mjs');
 assert.equal(fs.existsSync(image.api.file+'.bootstrap.json'),false,'No invented checked-image sidecar');
 return {record,image,identity:identity(file),inputs};
}

export function sameImage(left,right) {
 for(const key of ['api','runtime','base','driver','directRuntime','source','emission','driverQualification','checkedSubject','pins'])
  assert.equal(left.image[key].sha256,right.image[key].sha256,'Different B2 lineage: '+key);
}

export function verifyImageEmission(receipt,expected,onInput=()=>{}) {
 const selected=readImage(receipt.image);sameImage(selected,expected);
 assert.equal(receipt.attempt,undefined,'B2 is not a checked-development attempt');
 assert.equal(receipt.compiler.kind,'direct-self-emitted-image');
 assert.equal(receipt.compiler.backend,'direct');assert.equal(receipt.compiler.callingContract,'upstream-compatible-direct-v1');
 assert.equal(receipt.observation.checked,true);assert.equal(receipt.observation.status,'ok');assert.equal(receipt.observation.exitCode,0);
 for(const key of ['api','runtime','base','driver','directRuntime']){
  assert.deepEqual(receipt.compiler[key],selected.image[key]);verify(receipt.compiler[key]);onInput(receipt.compiler[key]);
 }
 assert(Array.isArray(receipt.emissionInputs)&&receipt.emissionInputs.length>=3);
 assert(receipt.emissionInputs.some(r=>r.file===selected.image.directRuntime.file&&r.sha256===selected.image.directRuntime.sha256));
 for(const item of [...selected.inputs,...receipt.emissionInputs]){verify(item);onInput(item);}
 return selected;
}
