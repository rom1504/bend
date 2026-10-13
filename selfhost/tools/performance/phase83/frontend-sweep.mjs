// Root runs this bounded diagnostic through ExecutionGuard; no inspector/targets here.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [planFile,jobName,outArg]=process.argv.slice(2),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const hash=b=>createHash('sha256').update(b).digest('hex');
const pin=file=>{file=fs.realpathSync(file);const bytes=fs.readFileSync(file);return {file,sha256:hash(bytes),bytes:bytes.length};};
const verify=p=>{const actual=pin(p.file);assert.deepEqual(actual,p);return actual;};
const plan=JSON.parse(fs.readFileSync(planFile,'utf8')),job=plan.jobs.find(j=>j.name===jobName);
assert(job,'Unknown frozen job');
const role=plan.roles[job.role],source=plan.cases[job.case];
const report={kind:'phase83-frontend-sweep',complete:false,pass:false,plan:pin(planFile),
  method:pin(import.meta.filename),job,source:source.input,scope:plan.scope,iterations:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();
let current=null;
const stack=[];
const stages=['f_source_header','f_prefix_complete_ready_seed','f_prefix_complete_source',
 'f_source_completed','f_prefix_graph_trace','check_program_diagnostic_world',
 'check_program_diagnostic_prefix','check_program_diagnostic','driver_report_data',
 'driver_report','driver_bad_names'];
function instrument(api){
  for(const name of stages){
    if(typeof api[name]!=='function')continue;
    const original=api[name];
    api[name]=function(...args){
      if(!current)return original(...args);
      const frame={start:performance.now(),children:0};stack.push(frame);
      try{return original(...args);}finally{
        const elapsed=performance.now()-frame.start;assert.equal(stack.pop(),frame);
        if(stack.length)stack.at(-1).children+=elapsed;
        const row=current.stages[name]??={calls:0,inclusiveMs:0,exclusiveMs:0};
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
  assert.equal(plan.kind,'phase83-frontend-sweep');
  for(const p of plan.inputs)verify(p);
  const old=JSON.parse(fs.readFileSync(verify(plan.parentPlan).file,'utf8'));
  for(const p of old.inputs)verify(p);
  assert.equal(fs.realpathSync(process.execPath),role.node.file);
  assert.equal(plan.repetitions,3);
  let D,api,B,R,prepared;
  const imports=performance.now();
  if(job.role==='typescript'){
    B=await import(pathToFileURL(role.bend.file));
    R=await import(pathToFileURL(plan.upstreamReport.file));
  }else{
    assert.equal(job.role,'b2');
    process.env.BEND_TYPED_API=role.api.file;process.env.BEND_TYPED_RUNTIME=role.runtime.file;
    process.env.BEND_BASE=role.base.file;
    D=await import(pathToFileURL(role.driver.file));api=await D.loadApi();
    assert.equal(await D.loadApi(),api);
    prepared=JSON.parse(fs.readFileSync(verify(plan.preparation).file,'utf8'));
    assert(prepared.complete&&prepared.pass);assert.equal(prepared.job.role,'b2');
    assert.deepEqual(prepared.plan,plan.parentPlan);
    assert.deepEqual(cacheFiles(role.project),prepared.cache);
    prepared.cache.forEach(verify);prepared.products.forEach(verify);
    instrument(api);
  }
  report.importsMs=performance.now()-imports;
  for(let i=0;i<plan.repetitions;i++){
    const row={iteration:i,freshProcess:i===0,stages:{}};
    current=row;
    const start=performance.now();
    if(job.role==='typescript'){
      const book=B.book_nil(),load=performance.now();
      await B.book_load(book,source.input.file,'',new Map());row.loadMs=performance.now()-load;
      const check=performance.now();B.book_valid(book);assert.equal(book.hols,0);row.checkMs=performance.now()-check;
      const proof=performance.now(),bad=R.book_promises(book);row.reportMs=performance.now()-proof;
      row.observation={status:'ok',checked:true,unsafeDefinitions:bad};
    }else{
      row.observation=await D.inspect(source.input.file,{mode:'check',withReport:true});
    }
    row.requestMs=performance.now()-start;current=null;
    assert.equal(row.observation.status,'ok');assert.equal(row.observation.checked,true);
    assert.deepEqual(row.observation.unsafeDefinitions,[]);
    if(job.role==='b2'){
      assert.equal(row.observation.proofTrust,'passed');
      for(const name of ['f_prefix_complete_source','check_program_diagnostic_world','driver_report_data'])
        assert(row.stages[name]?.calls>0,'Missing stage '+name);
      for(const file of row.observation.files??[]){
        const p=pin(file);assert(plan.inputs.some(x=>x.file===p.file&&x.sha256===p.sha256),'Unfrozen input '+file);
      }
      assert.deepEqual(cacheFiles(role.project),prepared.cache);
    }
    report.iterations.push(row);save();
  }
  for(const p of plan.inputs)verify(p);
  for(const p of old.inputs)verify(p);
  report.inputsUnchanged=true;report.complete=true;report.pass=true;
}catch(error){current=null;report.error=error.stack??String(error);process.exitCode=1;}
save();
console.log(JSON.stringify({job:jobName,complete:report.complete,pass:report.pass,
 requestMs:report.iterations.map(x=>x.requestMs),error:report.error}));
