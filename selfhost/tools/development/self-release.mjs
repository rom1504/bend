// A B2 release keeps the checked B1 generator and the original self-hosting receipts.
// Verification joins local artifact hashes; historical absolute paths are metadata.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const hash=file=>createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const good=(r,kind)=>{assert.equal(r.kind,kind);assert.equal(r.complete,true);assert.equal(r.pass,true);};
const same=(a,b,label)=>assert.equal(a?.sha256,b?.sha256,label);
const evidence={pins:'self-image-pins.json',emission:'self-emission.json',comparison:'self-driver-comparison.json',selfCheck:'self-check.json',fixedPoint:'self-fixed-point.json'};

export function verifySelfRelease(manifest,root,resolve=name=>path.join(root,name)){
 const files=Object.fromEntries(manifest.files.map(x=>[x.path,x]));
 const item=name=>{const x=files['dist/release-lineage/'+name];assert.ok(x,'Missing B2 lineage: '+name);return x;};
 const data=name=>read(resolve(item(name).path));
 const p=data(evidence.pins),e=data(evidence.emission),c=data(evidence.comparison),s=data(evidence.selfCheck),f=data(evidence.fixedPoint);
 assert.equal(p.kind,'phase56-direct-image-pins');
 good(e,'phase55-split-compiler-emission');good(c,'phase55-direct-compiler-driver-comparison');
 good(s,'phase56-b2-fresh-own-source-check');good(f,'phase56-direct-self-emission-v2');
 const api=files['dist/typed-api.mjs'],generator=item('generator-api.mjs'),source=item('self-source.bend'),attempt=item('self-attempt.json'),boot=item('checked-bootstrap.json');
 same(p.b2,api,'B2 image differs');same(p.b1,generator,'B1 generator differs');same(p.source,source,'B2 source differs');same(p.attempt,attempt,'B2 checked attempt differs');
 assert.equal(source.sha256,manifest.sourceSha256);same(p.emission,item(evidence.emission));same(p.comparison,item(evidence.comparison));
 const bootData=data('checked-bootstrap.json'),checkout=Object.fromEntries(manifest.checkout.map(x=>[x.path,x]));
 const modules=read(path.join(root,'src/compiler.json'));
 assert.equal(modules.upstream,bootData.revision);assert.deepEqual(modules.modules,bootData.modules.map(x=>x.file));
 for(const m of bootData.modules)assert.equal(checkout[m.file]?.sha256,m.sha256,'Unbound B2 source module: '+m.file);
 for(const n of ['release','self-release'])assert.ok(checkout['tools/development/'+n+'.mjs'],'Unbound B2 packager');
 assert.deepEqual(p.roots,bootData.exports);assert.equal(p.runtime.sha256,manifest.directRuntimeSha256);assert.equal(e.directRuntime.sha256,manifest.directRuntimeSha256);
 assert.equal(e.generator.runtime.sha256,manifest.runtimeSha256);assert.equal(f.image.runtime.sha256,manifest.runtimeSha256);same(f.image.base,files['dist/base.bend']);
 for(const [role,name] of [['source','self-driver-source.json'],['direct','self-driver-direct.json']]){
  const r=data(name);good(r,'phase55-direct-compiler-driver');assert.equal(r.role,role);same(c[role],item(name));same(r.api,role==='source'?generator:api);same(r.subject.attempt,attempt);same(r.subject.source,source);
 }
 same(e.module,api);same(e.generator.api,generator);same(e.generator.attempt,attempt);same(e.generator.bootstrap,boot);
 for(const r of [e,s,f]){same(r.subject.attempt,attempt);same(r.subject.bootstrap,boot);same(r.subject.source,source);assert.deepEqual(r.roots,p.roots);}
 same(s.image,api);same(s.generator.api,generator);same(s.imagePins,item(evidence.pins));same(s.source,source);
 assert.equal(s.freshTypeCheck,true);assert.equal(s.freshSelfCheck,true);assert.equal(s.observation.typeAccepted,true);
 assert.equal(s.expectedProofTrustFailure,true);assert.equal(s.mathematicalProof,false);
 same(f.b2,api);same(f.b3,api);assert.equal(f.byteEquality,true);same(f.image.pins,item(evidence.pins));same(f.image.emission,item(evidence.emission));same(f.image.driverQualification,item(evidence.comparison));
 const a=data('self-attempt.json');assert.equal(a.checked,true);assert.equal(a.artifactKind,'derived-b1');same(a.api,generator);same(a.bootstrapReport,boot);same(a.checkedApi,item('checked-api.mjs'));assert.equal(a.runtime.sha256,manifest.runtimeSha256);same(a.base,files['dist/base.bend']);
 assert.equal(manifest.lineage.selfEmittedSha256,api.sha256);assert.equal(manifest.lineage.generatorSha256,generator.sha256);
 return manifest;
}

export function prepareSelfRelease(attemptDirectory,pinsFile,qualificationDirectory){
 const attemptFile=path.join(attemptDirectory,'attempt.json'),a=read(attemptFile),p=read(pinsFile);
 const checked=(file,pin)=>{assert.equal(hash(file),pin.sha256,'Changed B2 input: '+file);return file;};
 checked(attemptFile,p.attempt);checked(a.api.file,p.b1);checked(p.b2.file,p.b2);checked(p.source.file,p.source);
 const copies=[[p.b2.file,'typed-api.mjs'],[a.api.file,'release-lineage/generator-api.mjs'],[attemptFile,'release-lineage/self-attempt.json'],[p.source.file,'release-lineage/self-source.bend'],[pinsFile,'release-lineage/'+evidence.pins]];
 for(const [key,file] of [['emission',p.emission.file],['comparison',p.comparison.file],['selfCheck',path.join(qualificationDirectory,'self-check/report.json')],['fixedPoint',path.join(qualificationDirectory,'fixed-point/report.json')]]){
  if(p[key])checked(file,p[key]);
  copies.push([file,'release-lineage/'+evidence[key]]);
 }
 const comparison=read(checked(p.comparison.file,p.comparison));
 for(const role of ['source','direct'])copies.push([checked(comparison[role].file,comparison[role]),'release-lineage/self-driver-'+role+'.json']);
 return {copies,apiSha256:p.b2.sha256,generatorSha256:p.b1.sha256,provenanceScope:'B2 is the exact self-emitted image of the installed checked B1 generator. Original checked, equality, self-emission, own-source and fixed-point receipts remain byte-for-byte; local verification joins their hashes without accessing historical absolute paths. No new bootstrap or mathematical proof is claimed.'};
}
