// Root-supervised diagnostic. Subject source and generator API are independent.
// No source mutation, compiler cache, changed export policy or hidden fallback.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from "file:///home/ai/bend2/build/publish/bend/selfhost/tools/development/workflow.mjs";
import {identity,verify,list,array,hash} from "file:///home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase54/bootstrap/adapter.mjs";
import {exposeReach} from './expose-reach01.mjs';

const [configFile,generatorDirectory,outArg]=process.argv.slice(2);
assert.ok(configFile&&generatorDirectory&&outArg,'reach-diagnostic01.mjs CONFIG GENERATOR_ATTEMPT NEW_DIRECTORY');
const config=JSON.parse(fs.readFileSync(configFile,'utf8')),out=path.resolve(outArg);
const rawRoot=fs.realpathSync(path.resolve(import.meta.dirname,'../../../../build/phase58'));
assert.ok(out.startsWith(rawRoot+path.sep),'Output must be a fresh Phase58 descendant');
assert.ok(!fs.existsSync(out));
let ancestor=path.dirname(out);while(!fs.existsSync(ancestor))ancestor=path.dirname(ancestor);
assert.ok(fs.realpathSync(ancestor)===rawRoot||fs.realpathSync(ancestor).startsWith(rawRoot+path.sep),'Output ancestor escapes Phase58');
fs.mkdirSync(out,{recursive:true});assert.ok(fs.realpathSync(out).startsWith(rawRoot+path.sep));
const report={kind:'phase58-reach-duplicate-diagnostic',complete:false,pass:false,
  config:identity(configFile),producer:identity(import.meta.filename),inputs:[],phases:[],
  timingScope:'Diagnostic phase times: counter traversal and progress IO may affect timing/GC; not ordinary compiler throughput.'};
report.scope='Diagnostic derivative, not a checked image or emission qualification. Exact original source inheritance and pre-reach stages retained; no cap, scanner, source, or returned reach result changed. No compiler output emitted.';
const started=performance.now(),progressFile=path.join(out,'progress.jsonl');fs.writeFileSync(progressFile,'',{flag:'wx'});
let sequence=0;
const progress=(phase,event,extra={})=>fs.appendFileSync(progressFile,JSON.stringify({sequence:sequence++,phase,event,
  elapsedSeconds:(performance.now()-started)/1000,...extra})+'\n');
const textSize=text=>({characters:text.length,utf8Bytes:Buffer.byteLength(text)});
const bookSize=book=>{const xs=array(book);return {entries:xs.length,definitions:xs.filter(d=>d.kind==='Def').length};};
function step(name,fn,describe=()=>({})) {
  const start=performance.now();progress(name,'start');
  try {const result=fn(),seconds=(performance.now()-start)/1000,counts=describe(result);
    report.phases.push({name,seconds,...counts});progress(name,'complete',{seconds,...counts});return result;
  } catch(error) {progress(name,'error',{seconds:(performance.now()-start)/1000,error:error.message});throw error;}
}
progress('emitter','start');
try {
  const parentProducer=identity(new URL('file:///home/ai/bend2/build/publish/bend/selfhost/build/phase58/final-choice02/bootstrap/tools/emit-split.mjs'));
  assert.equal(parentProducer.sha256,'5775cd570dbd5504994aaf6808e34b82530c27febd2290c31980500fe49b1ad2');report.parentProducer=parentProducer;
  assert.equal(config.kind,'phase55-fixed-subject-emission');
  assert.equal(config.checking,'inherited-exact-bootstrap');assert.equal(typeof config.compareUnsplit,'boolean');
  const subject=await verifyAttempt(config.subjectAttempt),generator=await verifyAttempt(generatorDirectory);
  const subjectBoot=JSON.parse(fs.readFileSync(subject.bootstrapReport.file,'utf8'));
  assert.equal(subjectBoot.sourceSha256,config.subjectSource.sha256);assert.deepEqual(identity(subjectBoot.source),config.subjectSource);
  assert.equal(subject.base.sha256,generator.base.sha256);assert.equal(subject.runtime.sha256,generator.runtime.sha256);
  for(const input of config.exactInputs)verify(input);
  report.subject={attempt:identity(path.join(config.subjectAttempt,'attempt.json')),bootstrap:identity(subject.bootstrapReport.file),source:config.subjectSource};
  report.generator={attempt:identity(path.join(generatorDirectory,'attempt.json')),api:identity(generator.api.file),
    bootstrap:identity(generator.bootstrapReport.file),runtime:identity(generator.runtime.file)};
  report.inputs=[parentProducer,report.config,report.producer,...Object.values(report.subject),...Object.values(report.generator),
    ...config.exactInputs,identity(new URL('./expose-reach01.mjs',import.meta.url)),
    identity(new URL("file:///home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase54/bootstrap/adapter.mjs")),identity(new URL("file:///home/ai/bend2/build/publish/bend/selfhost/tools/development/workflow.mjs"))];
  const core=identity(path.join(generator.snapshot.root,'src/back/js/direct/core.bend'));
  assert.equal(core.sha256,config.core.sha256);report.inputs.push(core);
  const derived=exposeReach(report.generator.api,core,out);report.derivation=derived.receipt;
  report.inputs.push(derived.api,derived.receipt);
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
  process.env.BEND_TYPED_API=derived.api.file;process.env.BEND_TYPED_RUNTIME=generator.runtime.file;process.env.BEND_BASE=generator.base.file;
  const driver=identity(path.join(generator.snapshot.root,'tools/typed-driver.mjs'));
  assert.equal(driver.sha256,config.driver.sha256);report.inputs.push(driver);
  const D=await import(pathToFileURL(driver.file)),api=await D.loadApi();
  const module=await import(pathToFileURL(derived.api.file));
  assert.equal(api,module.default,'Diagnostic route must retain the named checked API');
  const graph=step('load-fixed-compiler-source',()=>D.discoverSources(api,config.subjectSource.file));
  report.inputs.push(...graph.files.map(identity));assert.equal(graph.loadTrace.result.error,'');
  let book=graph.loadTrace.result.book;
  assert.equal(step('remaining-todos',()=>api.driver_todos(book)),0);
  const specialized=step('specialize-loaded-book',()=>api.specialize_book(book));
  assert.equal(api.specialized_error(specialized),'');book=api.specialized_book(specialized);
  assert.equal(step('owned-layout-identity',()=>api.driver_emit_owned(book)),'');
  report.checking={lane:config.checking,freshSelfCheck:false,sourceSha256:config.subjectSource.sha256,
    scope:'Exact subject source proof inherited; current generator still performs frontend completion and emission proofs.'};
  const names=new Set(array(book).filter(d=>d.kind==='Def').map(d=>d.name));
  assert.ok(config.roots.length>0&&new Set(config.roots).size===config.roots.length);
  for(const name of config.roots)assert.ok(names.has(name),'Missing root '+name);report.roots=config.roots;
  const context=step('context',()=>api.book_context(book),bookSize),roots=list(config.roots);
  const stops=step('native-stops',()=>api.jd_stops(context));
  let selected=step('source-reachability',()=>api.reach_book(context,roots,stops),bookSize);
  selected=step('annotate-selected',()=>api.annotate_selected(context,selected,stops),bookSize);
  const reachable=step('emitted-reachability',()=>api.jd_reach_selected(context,selected,roots));
  report.counters=module.$phase58ReachSnapshot();
  report.reachError=api.jd_reach_error(reachable);
  report.expectedFailure=report.reachError==='direct reachability edge budget';
  assert.equal(report.expectedFailure,true,'Expected unchanged original edge-budget failure');
  for(const x of report.inputs)verify(x);
  await verifyAttempt(config.subjectAttempt);await verifyAttempt(generatorDirectory);
  report.pass=true;report.complete=true;
} catch(error) {report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1;}
finally {
  report.seconds=(performance.now()-started)/1000;
  progress('emitter',report.pass?'complete':'error',{pass:report.pass,error:report.error?.message});report.progress=identity(progressFile);
  fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
  console.log(JSON.stringify({pass:report.pass,seconds:report.seconds,error:report.error?.message,report:path.join(out,'report.json')}));
}
