// Root-supervised diagnostic. Subject source and generator API are independent.
// No source mutation, compiler cache, changed export policy or hidden fallback.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
import {identity,verify,list,array,hash} from '../../phase54/bootstrap/adapter.mjs';
import {exposeStages} from './expose-stages.mjs';

const [configFile,generatorDirectory,outArg,qualificationFile]=process.argv.slice(2);
assert.ok(configFile&&generatorDirectory&&outArg,'emit-split.mjs CONFIG GENERATOR_ATTEMPT NEW_DIRECTORY [TINY_PASS_REPORT]');
const config=JSON.parse(fs.readFileSync(configFile,'utf8')),out=path.resolve(outArg);
assert.ok(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const report={kind:'phase55-split-compiler-emission',complete:false,pass:false,
  config:identity(configFile),producer:identity(import.meta.filename),inputs:[],phases:[],
  timingScope:'Diagnostic phase times: extra forcing and progress IO may affect timing/GC; not ordinary compiler throughput.'};
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
  report.inputs=[report.config,report.producer,...Object.values(report.subject),...Object.values(report.generator),
    ...config.exactInputs,identity(new URL('./expose-stages.mjs',import.meta.url)),
    identity(new URL('../../phase54/bootstrap/adapter.mjs',import.meta.url)),identity(new URL('../../../development/workflow.mjs',import.meta.url))];
  const core=identity(path.join(generator.snapshot.root,'src/back/js/direct/core.bend'));
  assert.equal(core.sha256,config.core.sha256);report.inputs.push(core);
  if(!config.compareUnsplit) {
    assert.ok(qualificationFile,'Full split run requires a passed tiny equality report');
    const qid=identity(qualificationFile),q=JSON.parse(fs.readFileSync(qualificationFile,'utf8'));
    assert.equal(q.kind,report.kind);assert.equal(q.pass,true);assert.equal(q.complete,true);assert.equal(q.splitEqualsUnsplit,true);
    assert.deepEqual(q.subject,report.subject);assert.deepEqual(q.generator,report.generator);
    const qc=JSON.parse(fs.readFileSync(q.config.file,'utf8'));verify(q.config);assert.equal(qc.compareUnsplit,true);
    assert.deepEqual(q.roots,config.qualificationRoots);assert.equal(q.producer.sha256,report.producer.sha256);
    for(const x of q.inputs)verify(x);verify(q.derivation);report.qualification=qid;report.inputs.push(qid);
  }
  const derived=exposeStages(report.generator.api,core,out);report.derivation=derived.receipt;
  report.inputs.push(derived.api,derived.receipt);
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
  process.env.BEND_TYPED_API=derived.api.file;process.env.BEND_TYPED_RUNTIME=generator.runtime.file;process.env.BEND_BASE=generator.base.file;
  const driver=identity(path.join(generator.snapshot.root,'tools/typed-driver.mjs'));
  assert.equal(driver.sha256,config.driver.sha256);report.inputs.push(driver);
  const D=await import(pathToFileURL(driver.file)),api=await D.loadApi();
  const module=await import(pathToFileURL(derived.api.file)),stages=module.$phase55Stages;
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
  assert.equal(api.jd_reach_error(reachable),'');selected=api.jd_reach_defs(reachable);
  progress('emitted-reachability','counts',bookSize(selected));report.selected=bookSize(selected);
  assert.equal(step('layout-proof',()=>api.j_layout_error(context,selected,roots,stops)),'');
  assert.equal(api.jd_foreign_error(selected),'');assert.deepEqual(array(api.jd_foreign_paths(selected)),[]);
  const overlaid=step('library-selected-context',()=>stages.selectedContext(context,selected),bookSize);
  const calls=step('library-callgraph',()=>stages.callgraph(overlaid,selected),bookSize);
  const valid=step('library-validity',()=>stages.valid(calls));
  let emitted;
  if(valid) {
    const definitions=step('library-definitions',()=>stages.definitions(calls,selected),textSize);
    const exports=step('library-exports',()=>stages.exports(calls,selected),textSize);
    emitted='// Direct JavaScript prototype: native functions and live arguments.\n'+definitions+exports;
  } else emitted=stages.failure('direct tail-call analysis refused');
  assert.ok(!emitted.includes('\n/*JD_UNSUPPORTED:'),'Explicit unsupported direct construct');
  report.emitted={...textSize(emitted),sha256:hash(Buffer.from(emitted))};
  if(config.compareUnsplit) {
    const original=step('tiny-unsplit-equivalence',()=>api.jd_library_selected(context,selected),textSize);
    assert.equal(emitted,original,'Split pipeline changed emitted bytes');report.splitEqualsUnsplit=true;
  }
  const runtime=identity(D.directRuntimePath);assert.equal(runtime.sha256,config.directRuntime.sha256);report.inputs.push(runtime);
  const modules=step('foreign-modules',()=>api.jd_modules(selected,list([])),textSize);
  const code=fs.readFileSync(runtime.file,'utf8')+'\n'+modules+'\n'+emitted;
  for(const x of report.inputs)verify(x);await verifyAttempt(config.subjectAttempt);await verifyAttempt(generatorDirectory);
  fs.writeFileSync(path.join(out,'compiler.mjs'),code,{flag:'wx'});report.module=identity(path.join(out,'compiler.mjs'));
  report.module.bytes=Buffer.byteLength(code);report.directRuntime=runtime;report.pass=true;report.complete=true;
} catch(error) {report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1;}
finally {
  report.seconds=(performance.now()-started)/1000;
  progress('emitter',report.pass?'complete':'error',{pass:report.pass,error:report.error?.message});report.progress=identity(progressFile);
  fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
  console.log(JSON.stringify({pass:report.pass,seconds:report.seconds,error:report.error?.message,report:path.join(out,'report.json')}));
}
