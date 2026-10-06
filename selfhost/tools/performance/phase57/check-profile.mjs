// One ordinary own-source check; preparation/import are outside CPU sampling.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {profile} from './profile-v2.mjs';
import {identity,hash} from '../phase54/bootstrap/adapter.mjs';
import {verifyAttempt} from '../../development/workflow.mjs';

const [pinsFile,preparationFile,role,outArgument]=process.argv.slice(2);
assert(pinsFile&&preparationFile&&outArgument&&['raw','source','direct'].includes(role),
 'check-profile.mjs IMAGE_PINS PREPARATION_REPORT raw|source|direct NEW_OUT');
const rawRoot=fs.realpathSync(path.resolve(import.meta.dirname,'../../../build/phase57'));
const out=path.resolve(outArgument);assert(out.startsWith(rawRoot+path.sep));assert(!fs.existsSync(out));
fs.mkdirSync(out,{recursive:true});assert(fs.realpathSync(out).startsWith(rawRoot+path.sep));
const started=performance.now(),inputs=new Map();
const report={kind:'phase57-one-own-source-cpu-check',complete:false,pass:false,role,
 cleanTiming:false,executed:false,producer:identity(import.meta.filename),inputs:[],
 scope:'One ordinary D.inspect exact compiler source mode=check, through the prepared private image. Base cache is reused, import is outside sampling, and no warm compiler request precedes the capture. Inspector includes the complete request and source-trust oracle. Diagnostic durations are not benchmark ratios or proof validity.',
 sourceTrustMethod:identity(new URL('../phase56/qualification/self-check-v2.mjs',import.meta.url)),
 node:identity(process.execPath),nodeVersion:process.version,execArgv:process.execArgv};
function pin(item){
 const actual=identity(typeof item==='string'||item instanceof URL?item:item.file);
 if(typeof item==='object'&&!(item instanceof URL)){
  assert.equal(actual.sha256,item.sha256,actual.file);
  if(item.bytes!==undefined)assert.equal(fs.statSync(actual.file).size,item.bytes);
 }
 if(inputs.has(actual.file))assert.deepEqual(inputs.get(actual.file),actual);
 else inputs.set(actual.file,actual);return actual;
}
const read=item=>JSON.parse(fs.readFileSync(pin(item).file,'utf8'));
function files(dir){return !fs.existsSync(dir)?[]:fs.readdirSync(dir,{withFileTypes:true}).sort((a,b)=>a.name.localeCompare(b.name)).flatMap(e=>{
 assert(!e.isSymbolicLink());const f=path.join(dir,e.name);return e.isDirectory()?files(f):[f];});}
const checkpoint=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');
try{
 pin(report.producer);pin(report.node);pin(report.sourceTrustMethod);
 assert.equal(report.sourceTrustMethod.sha256,'fb7c322231cda3f5c59ee99be4c6d43b37387c07785ca165cbee59dad11b609e');
 const profiler=pin(new URL('./profile-v2.mjs',import.meta.url));
 assert.equal(profiler.sha256,'f472c5e565827e7a8cfc4181e19dffe61f4485c63a3d137c1315c82e388064f6');
 pin(new URL('../programs/profile.mjs',import.meta.url));pin(new URL('../phase54/bootstrap/adapter.mjs',import.meta.url));
 pin(new URL('../../development/workflow.mjs',import.meta.url));
 report.imagePins=pin(pinsFile);assert.equal(report.imagePins.sha256,'11c5e4982678ac88e86f7d304ba8c3fc12c22ec756b0b2fa43f615a23ab77619');
 const binding=read(report.imagePins);assert.equal(binding.kind,'phase56-direct-image-pins');
 for(const key of ['producer','plan','attempt','emission','comparison','source','b1','b2','runtime','rootsReference'])pin(binding[key]);
 report.preparation=pin(preparationFile);let prep=read(report.preparation);
 if(prep.kind==='phase57-four-image-library-latency'){
  assert(prep.complete&&prep.pass);for(const item of prep.inputs)pin(item);
  const entry=prep.preparations.find(x=>x.observation.role===role);assert(entry);
  report.preparedResult=pin(entry.result);const actual=read(entry.result);assert.deepEqual(actual,entry.observation);prep=actual;
 }
 assert.equal(prep.kind,'phase57-four-image-library-worker');assert.equal(prep.stage,'prepare');
 assert.equal(prep.role,role);assert(prep.complete&&prep.pass);
 const config=read(prep.config);assert.equal(config.kind,'phase57-four-image-library-plan');
 assert.deepEqual(config.imagePins,report.imagePins);for(const item of config.inputs)pin(item);
 for(const item of prep.inputs)pin(item);for(const item of prep.copies)pin(item.after);
 const image=prep.image;assert.equal(image.role,role);assert.deepEqual(image.pins,report.imagePins);
 const project=fs.realpathSync(prep.project);assert(project.startsWith(rawRoot+path.sep),'Prepared project must be within Phase57');
 assert.equal(project,path.resolve(prep.project),'Canonical private project required');
 assert.equal(fs.realpathSync(image.api.file),path.join(project,'dist/api.mjs'),'Exact private API path required');
 assert.deepEqual(image.source,binding.source);assert.deepEqual(image.checkedSubject,binding.attempt);
 assert.deepEqual(prep.subject.source,binding.source);assert.deepEqual(prep.subject.attempt,binding.attempt);
 const emission=read(binding.emission);assert(emission.complete&&emission.pass);
 assert.deepEqual(emission.subject,prep.subject);assert.deepEqual(emission.generator.api,binding.b1);
 assert.deepEqual(pin(emission.module),pin(binding.b2));assert.deepEqual(pin(emission.directRuntime),pin(binding.runtime));
 const attempt=await verifyAttempt(path.dirname(binding.attempt.file));
 assert.equal(image.api.sha256,(role==='raw'?attempt.checkedApi:role==='source'?binding.b1:binding.b2).sha256);
 for(const key of ['api','runtime','base','directRuntime','driver'])pin(image[key]);
 for(const name of ['typed-driver','assemble','compiler-abi','node-resource-args','native-build']){
  const original=pin(path.join(attempt.snapshot.root,'tools',name+'.mjs'));
  const copied=pin(path.join(prep.project,'tools',name+'.mjs'));assert.equal(copied.sha256,original.sha256);
 }
 assert.equal(image.driver.file,fs.realpathSync(path.join(prep.project,'tools/typed-driver.mjs')));
 assert.equal(image.runtime.sha256,attempt.runtime.sha256);assert.equal(image.base.sha256,attempt.base.sha256);
 assert.equal(image.directRuntime.sha256,binding.runtime.sha256);
 assert(!fs.existsSync(image.api.file+'.bootstrap.json'),'No fabricated image sidecar');
 const cache=path.join(prep.project,'build/typed/cache');
 report.cacheBefore=files(cache).map(pin);assert.deepEqual(report.cacheBefore,prep.verification.cacheFiles);
 assert.equal(report.cacheBefore.length,1);
 for(const item of report.cacheBefore){const c=read(item);
  assert.equal(c.compilerSha256,image.api.sha256);assert.equal(c.baseSha256,image.base.sha256);
  assert.equal(c.sourcePath,fs.realpathSync(image.base.file));assert.equal(c.validatedBy,'check_book');
  assert.equal(c.bookSha256,hash(Buffer.from(JSON.stringify(c.book))));}
 report.image=image;report.subject=prep.subject;report.source=pin(binding.source);
 const text=fs.readFileSync(report.source.file,'utf8');
 const definitions=[...text.matchAll(/^def\s+([^\s(:]+)/gm)].map(m=>m[1]);
 const unsafe=[...text.matchAll(/^@unsafe\s*\ndef\s+([^\s(:]+)/gm)].map(m=>m[1]);
 assert.equal(definitions.length,3012);assert.equal(new Set(definitions).size,3012);
 assert.deepEqual([...unsafe].sort(),[...definitions].sort());
 report.sourceTrustOracle={definitions:3012,explicitlyUnsafe:3012,mathematicalProof:false,
  method:'Exact Phase56 self-check-v2 declaration/unsafe-name/diagnostic oracle; Base may contribute additional unsafe declarations.'};
 for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
 process.env.BEND_TYPED_API=image.api.file;process.env.BEND_TYPED_RUNTIME=image.runtime.file;process.env.BEND_BASE=image.base.file;
 const importAt=performance.now(),D=await import(pathToFileURL(image.driver.file));report.hostImportMs=performance.now()-importAt;
 assert.equal(D.apiPath,image.api.file);assert.equal(D.directRuntimePath,image.directRuntime.file);
 const apiAt=performance.now();await D.loadApi();report.apiLoadMs=performance.now()-apiAt;
 report.warmRequests=[];report.executed=true;checkpoint();
 report.profile=await profile({mode:'cpu',targetMs:100,maxRequests:1,out:path.join(out,'cpu'),
  moduleUrl:pathToFileURL(image.api.file).href,run:async()=>{
   const result=await D.inspect(report.source.file,{mode:'check'});
   report.observation={...result};if(result.files)report.observation.files=result.files.map(pin);
   assert.equal(result.checked,true);assert.equal(result.typeAccepted,true);assert.equal(result.kernelChecked,false);
   assert.equal(result.status,'error');assert.equal(result.exitCode,1);assert.equal(result.phase,'verdict');assert.equal(result.proofTrust,'failed');
   assert(Array.isArray(result.unsafeDefinitions));const names=new Set(result.unsafeDefinitions);
   assert.equal(names.size,result.unsafeDefinitions.length);for(const name of unsafe)assert(names.has(name),'Missing unsafe declaration: '+name);
   const expected='SOME PROOFS FAIL\nError: '+result.unsafeDefinitions.length+' defs rely on unsafe or foreign code:\n'+result.unsafeDefinitions.map(n=>'- '+n+'\n').join('');
   assert.equal(result.diagnostic,expected);
   report.additionalUnsafeDeclarations=result.unsafeDefinitions.filter(n=>!unsafe.includes(n));
  }});
 assert.equal(report.profile.calls,1);assert(report.profile.complete&&report.profile.pass);
 report.cacheAfter=files(cache).map(pin);assert.deepEqual(report.cacheAfter,report.cacheBefore);
 await verifyAttempt(path.dirname(binding.attempt.file));for(const item of [...inputs.values()])pin(item);
 report.expectedProofTrustFailure=true;report.freshOwnSourceRequest=true;report.freshBaseCheck=false;
 report.complete=report.pass=true;
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};if(error.profileReceipt)report.failedProfileReceipt=error.profileReceipt;process.exitCode=1;}
finally{report.wallMs=performance.now()-started;report.resourceUsage=process.resourceUsage();checkpoint();
 console.log(JSON.stringify({complete:report.complete,pass:report.pass,role,error:report.error?.message}));}
