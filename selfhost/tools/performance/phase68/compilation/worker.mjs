// One fresh native request, or explicit cache preparation. Root executes targets.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {Session} from 'node:inspector/promises';

const [planFile,jobName,outArg]=process.argv.slice(2),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const hash=b=>createHash('sha256').update(b).digest('hex');
const pin=file=>{file=fs.realpathSync(file);const bytes=fs.readFileSync(file);return {file,sha256:hash(bytes),bytes:bytes.length};};
const verify=p=>{const actual=pin(p.file);assert.equal(actual.sha256,p.sha256,p.file);if(p.bytes!==undefined)assert.equal(actual.bytes,p.bytes,p.file);return actual;};
const plan=JSON.parse(fs.readFileSync(planFile,'utf8')),job=plan.jobs.find(j=>j.name===jobName);
assert(job,'Unknown frozen job');
const role=plan.roles[job.role],report={kind:'phase68-native-request',complete:false,pass:false,
  plan:pin(planFile),method:pin(import.meta.filename),job,role:job.role,timings:{},stages:{},inputs:plan.inputs};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();
let session,active=false;
const stack=[];
const stages=['f_source_header','f_prefix_complete_ready_seed','f_prefix_complete_seed','f_prefix_complete_source',
  'f_prefix_graph_trace','f_graph_trace','f_load_graph','f_source_completed',
  'check_program_diagnostic_world','check_program_diagnostic_prefix','check_program_diagnostic',
  'driver_report','driver_bad_names','driver_emit_owned','j_compile_error','nc_annotation_stops',
  'reach_book','annotate_selected','nc_annotated_context','j_layout_error','nc_foreign_paths',
  'nc_foreign_scope','kf_source','nc_foreign_source','nc_compile'];
function instrument(api){
  for(const name of stages){
    if(typeof api[name]!=='function')continue;
    const original=api[name];
    api[name]=function(...args){
      if(!active)return original(...args);
      const frame={start:performance.now(),children:0};stack.push(frame);
      try{return original(...args);}finally{
        const elapsed=performance.now()-frame.start;assert.equal(stack.pop(),frame);
        if(stack.length)stack.at(-1).children+=elapsed;
        const row=report.stages[name]??={calls:0,inclusiveMs:0,exclusiveMs:0};
        row.calls++;row.inclusiveMs+=elapsed;row.exclusiveMs+=elapsed-frame.children;
      }
    };
  }
}
function cacheFiles(project){
  const dir=path.join(project,'build/typed/cache');
  return fs.existsSync(dir)?fs.readdirSync(dir).sort().map(n=>pin(path.join(dir,n))):[];
}
try{
  assert.equal(plan.kind,'phase68-native-compilation-plan');
  for(const item of plan.inputs)verify(item);
  assert.equal(fs.realpathSync(process.execPath),role.node.file);
  report.execution={node:process.version,execArgv:process.execArgv};
  let D,api,B,C;
  const imports=performance.now();
  if(job.role==='typescript'){
    assert.equal(job.action,'request');
    B=await import(pathToFileURL(role.bend.file));C=await import(pathToFileURL(role.compiler.file));
  }else{
    process.env.BEND_TYPED_API=role.api.file;process.env.BEND_TYPED_RUNTIME=role.runtime.file;
    process.env.BEND_BASE=role.base.file;
    D=await import(pathToFileURL(role.driver.file));api=await D.loadApi();
    assert.equal(await D.loadApi(),api,'Instrumentation must retain the actual owned API object');
    assert.equal(typeof api.nc_compile,'function');
  }
  report.timings.importsMs=performance.now()-imports;
  if(job.action==='prepare'){
    assert(!job.profile);assert.equal(cacheFiles(role.project).length,0,'Preparation must own a fresh cache');
    const start=performance.now(),prepared=await D.prepareBase(undefined,{backendProducts:false});
    report.timings.prepareBaseMs=performance.now()-start;
    assert.equal(prepared?.preparedWorld?.state?.ready,true,'A genuinely ready prepared world is required');
    report.cache=cacheFiles(role.project);assert.equal(report.cache.length,1);
    assert(!fs.existsSync(path.join(role.project,'build/typed/base-products')));
  }else{
    const source=plan.cases[job.case];
    report.source=verify(source.input);report.oracle=verify(source.expected[job.role]);
    if(job.role!=='typescript'){
      const prepared=JSON.parse(fs.readFileSync(role.preparation,'utf8'));
      assert(prepared.complete&&prepared.pass);assert.equal(prepared.job.role,job.role);
      assert.equal(prepared.job.action,'prepare');assert.deepEqual(prepared.plan,report.plan);
      prepared.cache.forEach(verify);assert.deepEqual(cacheFiles(role.project),prepared.cache);
      report.preparation=pin(role.preparation);report.cacheBefore=prepared.cache;
    }
    if(job.profile){
      assert(job.role!=='typescript');instrument(api);
      session=new Session();session.connect();await session.post('Profiler.enable');
      await session.post('Profiler.setSamplingInterval',{interval:1000});await session.post('Profiler.start');
    }
    let code,observation;
    active=true;
    const start=performance.now();
    if(job.role==='typescript'){
      const book=B.book_nil();await B.book_load(book,source.input.file,'',new Map());B.book_valid(book);assert.equal(book.hols,0);
      report.timings.loadCheckMs=performance.now()-start;
      const emit=performance.now();code=C.compile_book(book);report.timings.emitMs=performance.now()-emit;
      observation={status:'ok',checked:true};
    }else{
      const result=await D.inspect(source.input.file,{mode:'native',withReport:true});
      ({code,...observation}=result);
    }
    report.timings.requestMs=performance.now()-start;active=false;
    if(session){
      const {profile}=await session.post('Profiler.stop');session.disconnect();session=null;
      fs.writeFileSync(path.join(out,'request.cpuprofile'),JSON.stringify(profile),{flag:'wx'});
      report.profile=pin(path.join(out,'request.cpuprofile'));
    }
    report.observation=observation;assert.equal(observation.status,'ok');assert.equal(observation.checked,true);
    assert.equal(code,fs.readFileSync(source.expected[job.role].file,'utf8'),'Complete C output changed');
    fs.writeFileSync(path.join(out,'program.c'),code,{flag:'wx'});report.output=pin(path.join(out,'program.c'));
    report.exactC=true;
    if(job.role!=='typescript'){
      report.requestInputs=(observation.files??[]).map(pin);
      for(const item of report.requestInputs)assert(plan.inputs.some(p=>p.file===item.file&&p.sha256===item.sha256),'Unfrozen request input: '+item.file);
      assert.deepEqual(cacheFiles(role.project),report.cacheBefore,'A measured request changed prepared state');
    }
    if(job.profile){
      for(const name of ['check_program_diagnostic_world','annotate_selected','nc_annotated_context','nc_foreign_paths','nc_compile'])assert(report.stages[name]?.calls>0,'Missing stage '+name);
      report.stageScope='Public driver-entry calls only; internal recursive calls do not re-enter exported wrappers. V8 profile retains inner erase/lower/render stacks. Instrumented clocks are diagnostic, not clean samples.';
    }
  }
  for(const item of plan.inputs)verify(item);
  report.inputsUnchanged=true;report.complete=true;report.pass=true;
}catch(error){active=false;if(session){try{session.disconnect();}catch{}}report.error=error.stack??String(error);process.exitCode=1;}
save();console.log(JSON.stringify({job:jobName,complete:report.complete,pass:report.pass,timings:report.timings,error:report.error}));
