// Ordinary complete native requests. Instrumented modes never supply clean clocks.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [planFile,jobName,outArg]=process.argv.slice(2),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const hash=b=>createHash('sha256').update(b).digest('hex');
const pin=file=>{file=fs.realpathSync(file);const bytes=fs.readFileSync(file);return {file,sha256:hash(bytes),bytes:bytes.length};};
const verify=p=>{assert.deepEqual(pin(p.file),p);return p;};
const plan=JSON.parse(fs.readFileSync(planFile,'utf8')),job=plan.jobs.find(j=>j.name===jobName);
assert(job);const role=plan.roles[job.role],source=plan.cases[job.case];
const report={kind:'phase85-v8-compiler-request',complete:false,pass:false,plan:pin(planFile),method:pin(import.meta.filename),job,
  execution:{node:process.version,v8:process.versions.v8,execArgv:process.execArgv},calls:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const marker=(phase,call=0)=>{if(job.mode!=='clean')console.log('P85 '+JSON.stringify({phase,call,ms:performance.now()}));};
const cacheFiles=project=>{const dir=path.join(project,'build/typed/cache');return fs.readdirSync(dir).sort().map(n=>pin(path.join(dir,n)));};
save();let session;
try {
  assert.equal(plan.kind,'phase85-v8-compiler-plan');
  for(const item of plan.inputs)verify(item);
  assert.equal(fs.realpathSync(process.execPath),role.node.file);
  verify(source.input);verify(source.expected[job.role]);
  let D,B,C,prepared;
  if(job.role==='b2'){
    prepared=JSON.parse(fs.readFileSync(role.preparation,'utf8'));
    assert(prepared.complete&&prepared.pass);assert.equal(prepared.job.role,'b2');assert.equal(prepared.job.action,'prepare');
    assert.deepEqual(prepared.plan,verify(role.preparationPlan));
    prepared.cache.forEach(verify);prepared.products.forEach(verify);
    assert.deepEqual(cacheFiles(role.project),prepared.cache);
    report.preparation=pin(role.preparation);
  }
  marker('import-start');const imports=performance.now();
  if(job.role==='typescript'){
    B=await import(pathToFileURL(role.bend.file));C=await import(pathToFileURL(role.compiler.file));
  }else{
    process.env.BEND_TYPED_API=role.api.file;process.env.BEND_TYPED_RUNTIME=role.runtime.file;process.env.BEND_BASE=role.base.file;
    D=await import(pathToFileURL(role.driver.file));const api=await D.loadApi();assert.equal(await D.loadApi(),api);
  }
  report.importsMs=performance.now()-imports;marker('import-end');
  if(job.profileCalls?.length){const {Session}=await import('node:inspector/promises');session=new Session();session.connect();await session.post('Profiler.enable');await session.post('Profiler.setSamplingInterval',{interval:1000});}
  for(let call=1;call<=job.calls;call++){
    const row={call},profile=job.profileCalls?.includes(call);
    if(profile)await session.post('Profiler.start');
    marker('request-start',call);const start=performance.now();let code,observation;
    if(job.role==='typescript'){
      const book=B.book_nil();await B.book_load(book,source.input.file,'',new Map());B.book_valid(book);assert.equal(book.hols,0);
      row.loadCheckMs=performance.now()-start;const emit=performance.now();code=C.compile_book(book);row.emitMs=performance.now()-emit;
      observation={status:'ok',checked:true};
    }else{
      const result=await D.inspect(source.input.file,{mode:'native',withReport:true});({code,...observation}=result);
    }
    row.requestMs=performance.now()-start;marker('request-end',call);
    if(profile){const {profile:p}=await session.post('Profiler.stop');const file=path.join(out,`call${call}.cpuprofile`);fs.writeFileSync(file,JSON.stringify(p),{flag:'wx'});row.profile=pin(file);}
    row.observation=observation;assert.equal(observation.status,'ok');assert.equal(observation.checked,true);
    row.sha256=hash(code);row.bytes=Buffer.byteLength(code);
    if(call===1||row.sha256!==source.expected[job.role].sha256){const file=path.join(out,`call${call}.c`);fs.writeFileSync(file,code,{flag:'wx'});row.actual=pin(file);}
    assert.equal(row.sha256,source.expected[job.role].sha256,'Complete C output changed');row.exactC=true;
    if(job.role==='b2'){
      row.requestInputs=(observation.files??[]).map(pin);
      for(const p of row.requestInputs)assert(plan.inputs.some(i=>i.file===p.file&&i.sha256===p.sha256),'Unfrozen request input '+p.file);
      assert.deepEqual(cacheFiles(role.project),prepared.cache,'Request changed prepared cache');
    }
    row.memory=process.memoryUsage();report.calls.push(row);marker('validation-end',call);
  }
  if(session){session.disconnect();session=null;}
  for(const item of plan.inputs)verify(item);
  report.inputsUnchanged=true;report.complete=true;report.pass=true;
}catch(e){report.error=e.stack??String(e);process.exitCode=1;if(session)session.disconnect();}
save();console.log(JSON.stringify({job:jobName,complete:report.complete,pass:report.pass,importsMs:report.importsMs,requestsMs:report.calls.map(c=>c.requestMs),error:report.error}));
