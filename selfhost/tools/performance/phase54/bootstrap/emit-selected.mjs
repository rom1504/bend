// Root-supervised target job. No installed files or ordinary driver are changed.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
import {identity,verify,list,array} from './adapter.mjs';

const [configFile,outArg]=process.argv.slice(2);
assert.ok(configFile&&outArg,'emit-selected.mjs CONFIG NEW_DIRECTORY');
const config=JSON.parse(fs.readFileSync(configFile,'utf8')),out=path.resolve(outArg);
assert.ok(!fs.existsSync(out),'Output exists');fs.mkdirSync(out,{recursive:true});
const report={kind:'phase54-direct-compiler-emission',complete:false,pass:false,
  producer:identity(import.meta.filename),config:identity(configFile),inputs:[],phases:[]};
const started=performance.now();
const step=(name,fn)=>{const t=performance.now();const r=fn();report.phases.push({name,seconds:(performance.now()-t)/1000});return r;};
try {
  assert.ok(['fresh','inherited-exact-bootstrap'].includes(config.checking));
  const attempt=await verifyAttempt(config.attempt);assert.equal(attempt.checked,true);
  const boot=JSON.parse(fs.readFileSync(attempt.bootstrapReport.file,'utf8'));
  assert.equal(boot.stage,'upstream-bootstrap');assert.equal(boot.provenance.verifiedAfterBuild,true);
  const source=identity(boot.source);assert.equal(source.sha256,boot.sourceSha256);
  assert.equal(identity(attempt.base.file).sha256,boot.baseSha256);
  for(const expected of config.exactInputs)verify(expected);
  report.attempt=identity(path.join(config.attempt,'attempt.json'));
  report.bootstrap=identity(attempt.bootstrapReport.file);report.source=source;
  report.inputs=[report.attempt,report.bootstrap,source,identity(attempt.api.file),identity(attempt.runtime.file),identity(attempt.base.file),
    identity(new URL('./adapter.mjs',import.meta.url)),identity(new URL('../../../development/workflow.mjs',import.meta.url)),...config.exactInputs];
  assert.ok(Array.isArray(config.roots)&&config.roots.length>0&&new Set(config.roots).size===config.roots.length);
  report.roots=config.roots;
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
  process.env.BEND_TYPED_API=attempt.api.file;process.env.BEND_TYPED_RUNTIME=attempt.runtime.file;process.env.BEND_BASE=attempt.base.file;
  const driver=path.join(attempt.snapshot.root,'tools/typed-driver.mjs');report.inputs.push(identity(driver));
  const D=await import(pathToFileURL(driver));const api=await D.loadApi();
  const graph=step('load-exact-compiler-source',()=>D.discoverSources(api,source.file));
  report.inputs.push(...graph.files.map(identity));
  let book=graph.loadTrace.result.book;
  assert.equal(graph.loadTrace.result.error,'');
  assert.ok(array(book).length>0);
  if(config.checking==='fresh') {
    const checked=step('fresh-self-check',()=>api.check_program_diagnostic(book,list([]),list([])));
    assert.equal(checked.error,'');book=checked.book;
  } else {
    // Inherited source checking does not replace current frontend completion.
    assert.equal(step('remaining-todos',()=>api.driver_todos(book)),0);
    const specialized=step('specialize-loaded-book',()=>api.specialize_book(book));
    assert.equal(api.specialized_error(specialized),'');book=api.specialized_book(specialized);
  }
  assert.equal(step('owned-layout-identity',()=>api.driver_emit_owned(book)),'');
  report.checking={lane:config.checking,freshSelfCheck:config.checking==='fresh',
    inheritedSourceSha256:source.sha256,scope:'Inherited lane reuses exact complete-source bootstrap proof; it does not claim a fresh self-check.'};
  const names=new Set(array(book).filter(d=>d.kind==='Def').map(d=>d.name));
  for(const name of config.roots)assert.ok(names.has(name),'Missing source root '+name);
  const context=step('context',()=>api.book_context(book));
  const roots=list(config.roots),stops=step('native-stops',()=>api.jd_stops(context));
  let selected=step('source-reachability',()=>api.reach_book(context,roots,stops));
  report.sourceReachable=array(selected).length;
  selected=step('annotate-selected',()=>api.annotate_selected(context,selected,stops));
  const reachable=step('emitted-reachability',()=>api.jd_reach_selected(context,selected,roots));
  assert.equal(api.jd_reach_error(reachable),'');selected=api.jd_reach_defs(reachable);
  report.emittedReachable=array(selected).length;
  assert.equal(step('layout-proof',()=>api.j_layout_error(context,selected,roots,stops)),'');
  assert.equal(api.jd_foreign_error(selected),'');assert.deepEqual(array(api.jd_foreign_paths(selected)),[]);
  const emitted=step('emit-library',()=>api.jd_library_selected(context,selected));
  assert.ok(!emitted.includes('\n/*JD_UNSUPPORTED:'),'Explicit unsupported direct construct');
  const runtime=identity(D.directRuntimePath);report.inputs.push(runtime);
  const code=fs.readFileSync(runtime.file,'utf8')+'\n'+api.jd_modules(selected,list([]))+'\n'+emitted;
  for(const input of [report.config,report.producer,...report.inputs])verify(input);await verifyAttempt(config.attempt);
  fs.writeFileSync(path.join(out,'compiler.mjs'),code,{flag:'wx'});
  report.module=identity(path.join(out,'compiler.mjs'));report.module.bytes=Buffer.byteLength(code);
  report.directRuntime=runtime;report.pass=true;report.complete=true;
} catch(error) {report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1;}
finally {
  report.seconds=(performance.now()-started)/1000;
  fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
  // Probe binding is written only after the complete report exists.
  if(report.pass)fs.writeFileSync(path.join(out,'probe.json'),JSON.stringify({image:{file:report.module.file,sha256:report.module.sha256},
    required:config.roots,emission:identity(path.join(out,'report.json'))},null,2)+'\n',{flag:'wx'});
  console.log(JSON.stringify({pass:report.pass,report:path.join(out,'report.json'),seconds:report.seconds,error:report.error?.message}));
}
