// Serial file-backed integration gate and CLI-wall observation. Not a full
// conformance suite; every configured observation must pass before medians exist.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {spawn} from 'node:child_process';import {fileURLToPath} from 'node:url';
import {identity,verifyIdentity,verifyImage,readJson,writeJson} from '../common.mjs';
const [configFile,output]=process.argv.slice(2);if(!output)throw Error('Usage: cli-validation.mjs CONFIG NEW_OUTPUT_DIRECTORY');
const cfg=readJson(configFile),out=path.resolve(output),image=fs.realpathSync(path.resolve(path.dirname(configFile),cfg.image)),manifest=verifyImage(image).manifest;fs.mkdirSync(out,{recursive:false});
const resolve=file=>fs.realpathSync(path.resolve(path.dirname(configFile),file)),inputs=[identity(configFile),identity(process.execPath),identity(new URL(import.meta.url)),identity(new URL('./control-worker.mjs',import.meta.url)),...['run','common','transport','input-audit','publish'].map(n=>identity(new URL('../'+n+'.mjs',import.meta.url)))];
const workloads=cfg.workloads.map(w=>({...w,input:resolve(w.input)}));for(const w of workloads)inputs.push(identity(w.input));for(const file of cfg.dependencies??[])inputs.push(identity(resolve(file)));
const report={kind:'private-compiler-cli-validation',complete:false,started:new Date().toISOString(),scope:'Canonical fresh-process CLI vs original public H with identical copied host/Base/runtime. Per-image Base caches initially as recorded; no OS-cache flush.',imageManifest:identity(path.join(image,'manifest.json')),buildMs:manifest.buildMs,proofStatus:manifest.proofStatus,inputs,rows:[],initialCaches:[]};
const cache=path.join(image,'host/build/typed/cache');if(fs.existsSync(cache))report.initialCaches=fs.readdirSync(cache).map(n=>identity(path.join(cache,n)));
const flush=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');flush();
async function execute(argv,prefix,timeout=120000){
 const a=fs.openSync(prefix+'.stdout','wx'),b=fs.openSync(prefix+'.stderr','wx'),start=performance.now();let timedOut=false;
 const r=await new Promise(resolve=>{const p=spawn('taskset',['-c',String(cfg.cpu??0),process.execPath,'--stack-size=4096','--max-old-space-size=3072',...argv],{stdio:['ignore',a,b],detached:true,env:{...process.env,NODE_OPTIONS:''}});const timer=setTimeout(()=>{timedOut=true;try{process.kill(-p.pid,'SIGKILL');}catch{}},timeout);p.once('error',error=>{clearTimeout(timer);resolve({error:String(error)});});p.once('close',(status,signal)=>{clearTimeout(timer);resolve({status,signal});});});fs.closeSync(a);fs.closeSync(b);return {...r,timedOut,wallMs:performance.now()-start,stdout:identity(prefix+'.stdout'),stderr:identity(prefix+'.stderr')};
}
try{
 for(let repetition=0;repetition<(cfg.repetitions??1);repetition++)for(const w of workloads)for(const variant of repetition%2?['public','private']:['private','public']){
  const name=w.id+'-'+repetition+'-'+variant,dir=path.join(out,name),prefix=path.join(out,name),request={input:w.input,mode:w.mode??'compile',withReport:w.withReport??false};
  let r,observed;
  if(variant==='private'){
   r=await execute([fileURLToPath(new URL('../run.mjs',import.meta.url)),image,w.input,request.mode,dir,'--cpu='+String(cfg.cpu??0),...(request.withReport?['--report']:[])],prefix);
   observed=fs.existsSync(path.join(dir,'launch.json'))?readJson(path.join(dir,'launch.json')):null;
  }else{
   fs.mkdirSync(dir);writeJson(path.join(dir,'request.json'),request);
   r=await execute([fileURLToPath(new URL('./control-worker.mjs',import.meta.url)),image,path.join(dir,'request.json'),dir],prefix);
   observed=fs.existsSync(path.join(dir,'control.json'))?readJson(path.join(dir,'control.json')):null;
  }
  const row={name,workload:w.id,repetition,variant,execution:r,observation:observed,passed:false};report.rows.push(row);flush();
  assert.ok(observed,'Missing worker observation');assert.equal(r.timedOut,false);assert.equal(r.signal,null);assert.equal(r.status,variant==='private'?(w.status==='error'?1:0):0);
  if(variant==='private')assert.equal(observed.complete,true);
  assert.equal(observed.result.status,w.status??'ok');assert.equal(observed.result.phase,w.phase??(request.mode==='library'?'compile':request.mode));assert.equal(observed.result.checked,w.checked??request.mode!=='parse');
  const peers=report.rows.filter(x=>x!==row&&x.workload===w.id);for(const peer of peers){assert.deepEqual(observed.result,peer.observation.result);assert.equal(observed.emitted?.sha256,peer.observation.emitted?.sha256);}
  if(w.expectedStdout!==undefined){assert.ok(observed.emitted);row.program=await execute([observed.emitted.file],prefix+'-program',10000);assert.equal(row.program.status,0);assert.equal(fs.readFileSync(row.program.stdout.file,'utf8'),w.expectedStdout);assert.equal(fs.statSync(row.program.stderr.file).size,0);}
  if(w.forbiddenFile)assert.equal(fs.existsSync(path.resolve(path.dirname(configFile),w.forbiddenFile)),false,'Compiler executed foreign source');
  row.passed=true;flush();
 }
 for(const input of inputs)verifyIdentity(input);verifyIdentity(report.imageManifest);verifyImage(image);
 report.complete=true;report.finished=new Date().toISOString();
 const median=xs=>xs.toSorted((a,b)=>a-b)[Math.floor(xs.length/2)];report.summary={};
 for(const w of workloads){const rows=report.rows.filter(r=>r.workload===w.id);report.summary[w.id]=Object.fromEntries(['private','public'].map(v=>{const values=rows.filter(r=>r.variant===v);return [v,{samples:values.length,medianRequestMs:median(values.map(r=>r.observation.requestMs)),medianProcessWallMs:median(values.map(r=>r.execution.wallMs))}];}));}
}catch(error){report.error=error.stack;process.exitCode=1;}flush();console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error,summary:report.summary}));
