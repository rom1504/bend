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
 assert.equal(image.api.sha256,'ae5abd461c24f707747f37b187cedcecd86f5d3c727950f8f8a332fd9dca4091');
 assert.equal(image.emission.sha256,'654af8869256b3a9367f2ad98b5006c7791623790a25196a8a00fe8fb730531a');
 assert.equal(image.driverQualification.sha256,'69c556e987d3cbe4812911238b244b9613dbdf0dc3d63aac1f47a77f612f4f7e');
 for(const item of Object.values(image))if(item&&typeof item==='object'&&item.file&&item.sha256)pin(item);
 const emission=JSON.parse(fs.readFileSync(image.emission.file,'utf8'));
 assert(emission.complete&&emission.pass);assert.equal(emission.kind,'phase55-split-compiler-emission');
 assert.equal(emission.checking.freshSelfCheck,false);assert.deepEqual(emission.subject,record.subject);
 assert.deepEqual(emission.generator,record.generator);assert.deepEqual(record.roots,emission.roots);assert.equal(record.roots.length,77);
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
 const phase56=path.resolve(import.meta.dirname,'../../../../build/phase56');
 assert(fs.realpathSync(record.project).startsWith(fs.realpathSync(phase56)+path.sep),'Caches must stay in Phase56');
 assert.equal(path.relative(record.project,image.api.file),'dist/api.mjs');
 assert.equal(path.relative(record.project,image.runtime.file),'src/runtime.mjs');
 assert.equal(path.relative(record.project,image.directRuntime.file),'src/runtime/js/direct.mjs');
 assert.equal(fs.existsSync(image.api.file+'.bootstrap.json'),false,'No invented checked-image sidecar');
 return {record,image,identity:identity(file),inputs};
}

export function sameImage(left,right) {
 for(const key of ['api','runtime','base','driver','directRuntime','source','emission','driverQualification','checkedSubject'])
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
