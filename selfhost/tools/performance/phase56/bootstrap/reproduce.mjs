// Unsplit B2 -> B3 emission, retaining inherited checking as a separate claim.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {setup} from './setup.mjs';
import {identity,verify,list,array,hash} from '../../phase54/bootstrap/adapter.mjs';

const [emissionFile,outArg]=process.argv.slice(2);
assert.ok(emissionFile&&outArg,'reproduce.mjs B2_EMISSION_REPORT NEW_PHASE56_DIRECTORY');
const out=path.resolve(outArg),root=path.resolve(import.meta.dirname,'../../../../..');
const phase56=path.join(root,'selfhost/build/phase56');fs.mkdirSync(phase56,{recursive:true});
assert.ok(out.startsWith(fs.realpathSync(phase56)+path.sep));assert.ok(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const report={kind:'phase56-direct-self-emission',pass:false,complete:false,producer:identity(import.meta.filename),
  checking:{lane:'inherited-exact-bootstrap',freshSelfCheck:false},phases:[],inputs:[],copies:[],
  timingScope:'Bounded diagnostic request with progress IO and identity checks, not warmed compiler throughput.'};
const start=performance.now(),progressFile=path.join(out,'progress.jsonl');fs.writeFileSync(progressFile,'',{flag:'wx'});
let sequence=0;
function progress(phase,event,extra={}) {fs.appendFileSync(progressFile,JSON.stringify({sequence:sequence++,phase,event,
  elapsedSeconds:(performance.now()-start)/1000,...extra})+'\n');}
function step(name,fn,describe=()=>({})) {
  const begin=performance.now();progress(name,'start');
  try {const value=fn(),row={name,seconds:(performance.now()-begin)/1000,...describe(value)};
    report.phases.push(row);progress(name,'complete',row);return value;
  } catch(error) {progress(name,'error',{message:error.message});throw error;}
}
const bookSize=b=>{const rows=array(b);return {entries:rows.length,definitions:rows.filter(d=>d.kind==='Def').length};};
progress('reproduction','start');
try {
  const s=await setup(emissionFile,path.join(out,'private'),{progress});
  const {api,D,subject,emission,roots}=s;
  Object.assign(report,{image:s.image,subject,b2:identity(emission.module.file),roots,inputs:s.inputs,copies:s.copies});
  report.inputs.push(report.producer);report.checking.sourceSha256=subject.source.sha256;
  const graph=step('load-own-source',()=>D.discoverSources(api,subject.source.file));
  report.inputs.push(...graph.files.map(identity));assert.equal(graph.loadTrace.result.error,'');
  let book=graph.loadTrace.result.book;
  assert.equal(step('remaining-todos',()=>api.driver_todos(book)),0);
  const specialized=step('specialize-loaded-book',()=>api.specialize_book(book));
  assert.equal(api.specialized_error(specialized),'');book=api.specialized_book(specialized);
  assert.equal(step('owned-layout-identity',()=>api.driver_emit_owned(book)),'');
  const names=new Set(array(book).filter(d=>d.kind==='Def').map(d=>d.name));
  for(const name of roots)assert.ok(names.has(name),'Missing root '+name);
  const context=step('context',()=>api.book_context(book),bookSize),rootList=list(roots);
  const stops=step('native-stops',()=>api.jd_stops(context));
  let selected=step('source-reachability',()=>api.reach_book(context,rootList,stops),bookSize);
  selected=step('annotate-selected',()=>api.annotate_selected(context,selected,stops),bookSize);
  const reachable=step('emitted-reachability',()=>api.jd_reach_selected(context,selected,rootList));
  assert.equal(api.jd_reach_error(reachable),'');selected=api.jd_reach_defs(reachable);report.selected=bookSize(selected);
  assert.deepEqual(report.selected,emission.selected);
  assert.equal(step('layout-proof',()=>api.j_layout_error(context,selected,rootList,stops)),'');
  assert.equal(api.jd_foreign_error(selected),'');assert.deepEqual(array(api.jd_foreign_paths(selected)),[]);
  const emitted=step('unsplit-library',()=>api.jd_library_selected(context,selected),text=>({characters:text.length,bytes:Buffer.byteLength(text)}));
  assert.ok(!emitted.includes('\n/*JD_UNSUPPORTED:'),'Explicit unsupported direct construct');
  const modules=step('foreign-modules',()=>api.jd_modules(selected,list([])));
  const code=fs.readFileSync(D.directRuntimePath,'utf8')+'\n'+modules+'\n'+emitted;
  const b3=path.join(out,'compiler.mjs');fs.writeFileSync(b3,code,{flag:'wx'});report.b3={...identity(b3),bytes:Buffer.byteLength(code)};
  report.emitted={characters:emitted.length,bytes:Buffer.byteLength(emitted),sha256:hash(Buffer.from(emitted))};
  report.byteEquality=fs.readFileSync(b3).equals(fs.readFileSync(emission.module.file));
  assert.equal(report.byteEquality,true,'Complete B2/B3 bytes differ');assert.equal(report.emitted.sha256,emission.emitted.sha256);
  report.verification=await s.verifyFinal();for(const input of report.inputs)verify(input);verify(report.b2);
  assert.equal(identity(b3).sha256,report.b3.sha256);
  report.scope='Exact emission fixed point on the checked host02 source and 77-root closure. No fresh compiler-source self-check, new bootstrap trust, or installation claim.';
  report.pass=true;report.complete=true;
} catch(error) {report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1;}
finally {
  report.seconds=(performance.now()-start)/1000;progress('reproduction',report.pass?'complete':'error',{pass:report.pass,error:report.error?.message});
  report.progress=identity(progressFile);fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
  console.log(JSON.stringify({pass:report.pass,seconds:report.seconds,byteEquality:report.byteEquality,error:report.error?.message}));
}
