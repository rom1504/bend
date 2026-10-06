// Successor of emission-profile.mjs d2c240b45d130732a99c8310605b7e5cce66ee88edcf1813911ecaa3b030e4df.
// Same exact B2 -> B3 reproduction; only emitted reach and unsplit emission use 25ms CPU sampling.
// Root must supply the external CPU3 / 420s / 2GiB RSS / 4GiB available guard.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {setup} from './setup.mjs';
import {profile} from './profile-v3.mjs';
import {identity,verify,list,array,hash} from '../phase54/bootstrap/adapter.mjs';

const [pinsFile,outArg]=process.argv.slice(2);
assert.ok(pinsFile&&outArg,'emission-profile.mjs IMAGE_PINS NEW_PHASE57_DIRECTORY');
const out=path.resolve(outArg),root=path.resolve(import.meta.dirname,'../../../..');
const phase57=fs.realpathSync(path.join(root,'selfhost/build/phase57'));
assert.ok(out.startsWith(phase57+path.sep));assert.ok(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
assert.ok(fs.realpathSync(out).startsWith(phase57+path.sep));
const report={kind:'phase57-b2-own-source-emission-profile-v2',pass:false,complete:false,cleanTiming:false,
  producer:identity(import.meta.filename),checking:{lane:'inherited-exact-bootstrap',freshSelfCheck:false},
  phases:[],inputs:[],copies:[],node:identity(process.execPath),nodeVersion:process.version,execArgv:process.execArgv,
  scope:'One complete unsplit reproduction using the frozen Phase56 pipeline and exact B2/B3 byte oracle. Independent 25ms inspector sessions enclose only emitted-reachability and unsplit-library, not other stages/setup/import/counting/byte-oracle/final hashing. No compiler warmup or repeated request. These diagnostic times are not benchmark ratios.',
  attribution:'A separate raw profile per stage avoids cross-clock phase alignment. Captures include marker IO and async wrapper overhead. Each capture deliberately invokes the stage exactly once; the shared profiler duration target is not a request for repeated work. Stage clocks exclude inspector startup/stop/serialization, which remain in captureSeconds and total worker time.',
  limitations:'Emitted reachability includes rendering definitions to collect JD_REF metadata. Unsplit emission includes internal call facts, all selected definitions and host exports. No internal substage cost is inferred from their names. Inspector can perturb tiering/allocation; inclusive frame totals overlap.'};
const started=performance.now(),progressFile=path.join(out,'progress.jsonl');fs.writeFileSync(progressFile,'',{flag:'wx'});
let sequence=0,apiUrl;
const checkpoint=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
function progress(phase,event,extra={}) {
  fs.appendFileSync(progressFile,JSON.stringify({sequence:sequence++,phase,event,
    elapsedSeconds:(performance.now()-started)/1000,...extra})+'\n');
}
async function step(name,fn,describe=()=>({})) {
  const captureStart=performance.now();progress(name,'start');
  let value,seconds;
  try {
    if(!['emitted-reachability','unsplit-library'].includes(name)) {
      progress(name,'invoke');const begin=performance.now();
      try {value=fn();} finally {seconds=(performance.now()-begin)/1000;progress(name,'returned',{seconds});}
      const row={name,seconds,captureSeconds:(performance.now()-captureStart)/1000,cpuCaptured:false,profile:null,...describe(value)};
      report.phases.push(row);progress(name,'complete',{seconds,cpuCaptured:false});checkpoint();return value;
    }
    const captured=await profile({mode:'cpu',samplingIntervalUs:25000,targetMs:100,maxRequests:1,
      out:path.join(out,'cpu',name),moduleUrl:apiUrl,run:async()=>{
        progress(name,'invoke');const begin=performance.now();
        try {value=fn();} finally {seconds=(performance.now()-begin)/1000;progress(name,'returned',{seconds});}
      }});
    assert.equal(captured.calls,1);assert.ok(captured.complete&&captured.pass);
    const row={name,seconds,captureSeconds:(performance.now()-captureStart)/1000,cpuCaptured:true,
      profile:captured,...describe(value)};
    report.phases.push(row);progress(name,'complete',{seconds,profile:captured.receipt});checkpoint();return value;
  } catch(error) {
    report.phases.push({name,seconds,captureSeconds:(performance.now()-captureStart)/1000,
      complete:false,failedProfileReceipt:error.profileReceipt,message:error.message});
    progress(name,'error',{message:error.message});checkpoint();throw error;
  }
}
const bookSize=b=>{const rows=array(b);return {entries:rows.length,definitions:rows.filter(d=>d.kind==='Def').length};};
progress('reproduction','start');checkpoint();
try {
  assert.equal(process.version,'v24.18.0');assert.ok(process.execArgv.includes('--max-old-space-size=1024'));
  assert.ok(process.execArgv.includes('--stack-size=4096'));
  report.affinity=fs.readFileSync('/proc/self/status','utf8').split('\n').find(x=>x.startsWith('Cpus_allowed_list:'));
  assert.equal(report.affinity.split(':',2)[1].trim(),'3');
  const parents=[
    [new URL('../phase56/bootstrap/reproduce-v2.mjs',import.meta.url),'da4e4448de2004464409c745e81a20e1847d0054ec5cbfe89774607cd3f6ab24'],
    [new URL('./setup.mjs',import.meta.url),'b31568cd06d8a5b725ad6f1ce92808bb0a407f29764b807db96f9ca4f4b68985'],
    [new URL('./profile-v3.mjs',import.meta.url),'d5044de9f3e056fb300b7fbdc93afe9820164fe87830efd366d72b6a8ed39a69'],
    [new URL('./emission-profile.mjs',import.meta.url),'d2c240b45d130732a99c8310605b7e5cce66ee88edcf1813911ecaa3b030e4df']
  ].map(([file,sha256])=>{const pin=identity(file);assert.equal(pin.sha256,sha256);return pin;});
  const s=await setup(pinsFile,path.join(out,'private'),{role:'direct',progress});
  const {api,D,subject,emission,roots}=s;apiUrl=pathToFileURL(s.image.api.file).href;
  Object.assign(report,{image:s.image,subject,b2:identity(emission.module.file),roots,
    inputs:[...s.inputs,report.producer,...parents],copies:s.copies});
  report.checking.sourceSha256=subject.source.sha256;
  const graph=await step('load-own-source',()=>D.discoverSources(api,subject.source.file));
  report.inputs.push(...graph.files.map(identity));assert.equal(graph.loadTrace.result.error,'');
  let book=graph.loadTrace.result.book;
  assert.equal(await step('remaining-todos',()=>api.driver_todos(book)),0);
  const specialized=await step('specialize-loaded-book',()=>api.specialize_book(book));
  assert.equal(api.specialized_error(specialized),'');book=api.specialized_book(specialized);
  assert.equal(await step('owned-layout-identity',()=>api.driver_emit_owned(book)),'');
  const names=new Set(array(book).filter(d=>d.kind==='Def').map(d=>d.name));
  for(const name of roots)assert.ok(names.has(name),'Missing root '+name);
  const context=await step('context',()=>api.book_context(book),bookSize),rootList=list(roots);
  const stops=await step('native-stops',()=>api.jd_stops(context));
  let selected=await step('source-reachability',()=>api.reach_book(context,rootList,stops),bookSize);
  selected=await step('annotate-selected',()=>api.annotate_selected(context,selected,stops),bookSize);
  const reachable=await step('emitted-reachability',()=>api.jd_reach_selected(context,selected,rootList));
  assert.equal(api.jd_reach_error(reachable),'');selected=api.jd_reach_defs(reachable);report.selected=bookSize(selected);
  assert.deepEqual(report.selected,emission.selected);
  assert.equal(await step('layout-proof',()=>api.j_layout_error(context,selected,rootList,stops)),'');
  assert.equal(api.jd_foreign_error(selected),'');assert.deepEqual(array(api.jd_foreign_paths(selected)),[]);
  const emitted=await step('unsplit-library',()=>api.jd_library_selected(context,selected),
    text=>({characters:text.length,bytes:Buffer.byteLength(text)}));
  assert.ok(!emitted.includes('\n/*JD_UNSUPPORTED:'),'Explicit unsupported direct construct');
  const modules=await step('foreign-modules',()=>api.jd_modules(selected,list([])));
  const code=fs.readFileSync(D.directRuntimePath,'utf8')+'\n'+modules+'\n'+emitted;
  const b3=path.join(out,'compiler.mjs');fs.writeFileSync(b3,code,{flag:'wx'});
  report.b3={...identity(b3),bytes:Buffer.byteLength(code)};
  report.emitted={characters:emitted.length,bytes:Buffer.byteLength(emitted),sha256:hash(Buffer.from(emitted))};
  report.byteEquality=fs.readFileSync(b3).equals(fs.readFileSync(emission.module.file));
  assert.equal(report.byteEquality,true,'Complete B2/B3 bytes differ');assert.equal(report.emitted.sha256,emission.emitted.sha256);
  report.verification=await s.verifyFinal();for(const input of report.inputs)verify(input);verify(report.b2);
  for(const phase of report.phases)if(phase.profile)for(const key of ['receipt','raw','summary','sampleCountSummary']) {
    const pin=phase.profile[key];verify({file:pin.file,sha256:pin.sha256});
    if(pin.bytes!==undefined)assert.equal(fs.statSync(pin.file).size,pin.bytes);
  }
  assert.equal(identity(b3).sha256,report.b3.sha256);
  report.pass=report.complete=true;
} catch(error) {report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1;}
finally {
  report.seconds=(performance.now()-started)/1000;report.resourceUsage=process.resourceUsage();
  progress('reproduction',report.pass?'complete':'error',{pass:report.pass,error:report.error?.message});
  report.progress=identity(progressFile);checkpoint();
  console.log(JSON.stringify({pass:report.pass,seconds:report.seconds,byteEquality:report.byteEquality,error:report.error?.message}));
}
