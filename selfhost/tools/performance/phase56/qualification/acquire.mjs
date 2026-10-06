// Root-supervised checked emission by B2, with a private ordinary-driver cache.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {setup} from '../bootstrap/setup.mjs';
import {identity,verify} from '../../phase54/bootstrap/adapter.mjs';

const [emissionFile,catalogFile,referenceFile,outArg]=process.argv.slice(2);
assert(emissionFile&&catalogFile&&referenceFile&&outArg,'acquire.mjs B2_REPORT CATALOG TS_REFERENCE NEW_DIRECTORY');
const out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const started=performance.now(),progressFile=path.join(out,'progress.jsonl');fs.writeFileSync(progressFile,'',{flag:'wx'});
let sequence=0;const progress=(phase,event,extra={})=>fs.appendFileSync(progressFile,JSON.stringify({sequence:sequence++,phase,event,elapsedSeconds:(performance.now()-started)/1000,...extra})+'\n');
const report={kind:'phase56-b2-semantic-acquisition',complete:false,passed:false,executed:true,
 producer:identity(import.meta.filename),catalog:identity(catalogFile),reference:identity(referenceFile),inputs:[],cases:[],
 roles:{direct:{modules:{}},typescript:{modules:{}}},
 scope:'Each program is freshly checked and emitted by the exact B2 image through an unchanged private ordinary driver. The image inherits checked B1 source provenance; no checked attempt is synthesized. Acquisition success is not execution-oracle success.'};
try{
 const catalog=JSON.parse(fs.readFileSync(catalogFile,'utf8')),reference=JSON.parse(fs.readFileSync(referenceFile,'utf8'));
 assert.equal(catalog.kind,'phase52-direct-semantic-catalog');assert(reference.complete);
 assert.deepEqual(reference.catalog,report.catalog);assert(reference.roles.typescript);
 const selected=await setup(emissionFile,path.join(out,'image'),{progress});
 const {D,image,subject,emission,roots,inputs,copies,verifyFinal}=selected;
 assert.equal(JSON.parse(fs.readFileSync(path.join(D.project,'src/compiler.json'),'utf8')).upstream,catalog.upstreamCommit);
 report.inputs=[report.producer,report.catalog,report.reference,identity(new URL('../bootstrap/setup.mjs',import.meta.url)),...inputs];
 const imageFile=path.join(out,'image.json');
 fs.writeFileSync(imageFile,JSON.stringify({kind:'phase56-staged-direct-image',complete:true,freshSelfCheck:false,
  sourceProof:'inherited-exact-checked-B1; independent B2 self-check is a separate receipt',image,subject,generator:emission.generator,
  project:D.project,roots,inputs,copies},null,2)+'\n',{flag:'wx'});
 report.roles.direct.image=identity(imageFile);report.inputs.push(identity(imageFile));
 const modules=path.join(out,'modules');fs.mkdirSync(modules);
 const hostPrefix='import {createRequire as $jdCreateRequire} from "node:module";\nconst require=$jdCreateRequire(import.meta.url);\n';
 const runtimePrefix=fs.readFileSync(D.directRuntimePath,'utf8')+'\n';
 for(const c of catalog.cases){
  const source=path.resolve(path.dirname(catalogFile),c.source.file??c.source.path);assert.equal(identity(source).sha256,c.source.sha256);
  report.inputs.push(identity(source));for(const row of c.auxiliary??[]){const file=path.resolve(path.dirname(catalogFile),row.file??row.path);assert.equal(identity(file).sha256,row.sha256);report.inputs.push(identity(file));}
  const referenceModule=path.resolve(path.dirname(referenceFile),reference.roles.typescript.modules[c.id]);
  const referenceReceipt=JSON.parse(fs.readFileSync(referenceModule+'.json','utf8'));
  assert(referenceReceipt.complete&&referenceReceipt.observation.checked&&referenceReceipt.observation.status==='ok');
  assert.equal(referenceReceipt.compiler.kind,'checked-pinned-typescript');assert.equal(referenceReceipt.compiler.upstreamCommit,catalog.upstreamCommit);
  assert.equal(identity(referenceReceipt.output.file??referenceReceipt.output.path).sha256,referenceReceipt.output.sha256);
  assert.equal(referenceReceipt.output.sha256,identity(referenceModule).sha256);assert.equal(referenceReceipt.input.sha256,c.source.sha256);
  report.inputs.push(identity(referenceModule),identity(referenceModule+'.json'));
  for(const row of referenceReceipt.compiler.sources){const actual=identity(row.file??row.path);assert.equal(actual.sha256,row.sha256);if(row.canonicalPath)assert.equal(actual.file,row.canonicalPath);report.inputs.push(actual);}
  report.roles.typescript.modules[c.id]=referenceModule;
  const output=path.join(modules,c.id+'.mjs'),receipt={kind:'bend-program-checked-emission',complete:false,
   input:identity(source),catalog:report.catalog,producer:report.producer,image:report.roles.direct.image,
   compiler:{kind:'direct-self-emitted-image',backend:'direct',callingContract:'upstream-compatible-direct-v1',upstreamCommit:catalog.upstreamCommit,
    ...Object.fromEntries(['api','runtime','base','driver','directRuntime'].map(key=>[key,image[key]]))}};
  progress(c.id,'start');const begin=performance.now();
  try{
   const result=await D.inspect(source,{mode:c.mode==='program'?'compile':'library',backend:'direct'});
   const {code,...observation}=result;receipt.observation=observation;
   assert.equal(result.status,'ok',result.diagnostic??JSON.stringify(result));assert.equal(result.checked,true);assert.equal(result.exitCode,0);assert.equal(result.backend,'direct');
   assert.equal(typeof code,'string');assert(Array.isArray(result.files));
   receipt.emissionInputs=[...new Set(result.files)].map(identity);
   assert(receipt.emissionInputs.some(row=>row.file===image.directRuntime.file));
   const hostBytes=code.startsWith(hostPrefix)?hostPrefix.length:0;assert(code.startsWith(runtimePrefix,hostBytes));
   receipt.directPrefix={host:hostBytes?'node-create-require-v1':'none',hostBytes,runtimeBytes:Buffer.byteLength(runtimePrefix)};
   for(const row of receipt.emissionInputs)verify(row);
   fs.writeFileSync(output,code,{flag:'wx'});receipt.output=identity(output);receipt.complete=true;
  }catch(error){receipt.error=error.stack??String(error);throw error;}
  finally{receipt.elapsedSeconds=(performance.now()-begin)/1000;fs.writeFileSync(output+'.json',JSON.stringify(receipt,null,2)+'\n',{flag:'wx'});report.cases.push({id:c.id,receipt:identity(output+'.json'),complete:receipt.complete});progress(c.id,receipt.complete?'complete':'error',{seconds:receipt.elapsedSeconds,error:receipt.error});}
  report.roles.direct.modules[c.id]=output;report.inputs.push(identity(output),identity(output+'.json'));
 }
 report.finalVerification=await verifyFinal();for(const row of report.inputs)verify(row);
 report.complete=true;report.passed=report.cases.length===catalog.cases.length&&report.cases.every(row=>row.complete);
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1;}
finally{report.seconds=(performance.now()-started)/1000;report.progress=identity(progressFile);
 fs.writeFileSync(path.join(out,'manifest.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
 console.log(JSON.stringify({complete:report.complete,passed:report.passed,cases:report.cases.length,seconds:report.seconds,error:report.error?.message}));}
