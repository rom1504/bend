// Focused real corpus comparison, not a full conformance claim. Captures every
// fresh process to files and compares exact observations across all variants.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {spawn} from 'node:child_process';import {fileURLToPath} from 'node:url';
import {identity,verifyIdentity,verifyImage,readJson,writeJson,digest} from '../common.mjs';
const [configFile,outArg]=process.argv.slice(2);if(!outArg)throw Error('Usage: batch-compare.mjs CONFIG NEW_DIRECTORY');
const cfg=readJson(configFile),resolve=file=>fs.realpathSync(path.resolve(path.dirname(configFile),file)),image=resolve(cfg.image),out=path.resolve(outArg),manifest=verifyImage(image);fs.mkdirSync(out);
const casesFile=resolve(cfg.cases),cases=readJson(casesFile).map(c=>({...c,input:fs.realpathSync(path.resolve(path.dirname(casesFile),c.file))}));if(cases.length<1||cases.length>256)throw Error('Focused corpus size exceeds finite bound');
const inputs=[identity(process.execPath),identity(configFile),identity(casesFile),...cases.map(c=>identity(c.input)),identity(new URL(import.meta.url)),identity(new URL('./reference-batch-worker.mjs',import.meta.url)),identity(new URL('./control-worker.mjs',import.meta.url)),...['batch','run','common','transport','input-audit','publish'].map(n=>identity(new URL('../'+n+'.mjs',import.meta.url)))];
const report={kind:'private-finite-batch-comparison',complete:false,started:new Date().toISOString(),scope:'Same-source private H vs ordinary public H vs checked B1; unchanged copied host/Base/runtime, validated warm API-specific caches, serial alternating fresh processes. Persistent reference calls use the ordinary host directly; private batch includes its supervisor/IPC/input-audit/publication costs.',manifest:manifest.manifestIdentity,cases,inputs,prime:[],rows:[]};
const flush=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');flush();
async function execute(argv,prefix,timeoutMs=180000){
 const a=fs.openSync(prefix+'.stdout','wx'),b=fs.openSync(prefix+'.stderr','wx'),start=performance.now();let timedOut=false;
 const result=await new Promise(resolve=>{const p=spawn('taskset',['-c',String(cfg.cpu??0),process.execPath,'--stack-size=4096','--max-old-space-size=3072',...argv],{stdio:['ignore',a,b],detached:true,env:{...process.env,NODE_OPTIONS:''}});const timer=setTimeout(()=>{timedOut=true;try{process.kill(-p.pid,'SIGKILL');}catch{}},timeoutMs);p.once('error',e=>{clearTimeout(timer);resolve({error:String(e)});});p.once('close',(status,signal)=>{clearTimeout(timer);resolve({status,signal});});});fs.closeSync(a);fs.closeSync(b);return {...result,command:'taskset',args:['-c',String(cfg.cpu??0),process.execPath,'--stack-size=4096','--max-old-space-size=3072',...argv],timedOut,wallMs:performance.now()-start,stdout:identity(prefix+'.stdout'),stderr:identity(prefix+'.stderr')};
}
async function sample(variant,requests,name){
 const file=path.join(out,name+'.requests.json'),directory=path.join(out,name);writeJson(file,requests);let argv;
 if(variant==='b1-single'||variant==='private-single'){
  fs.mkdirSync(directory);const started=performance.now(),executions=[],observations=[];
  for(const [i,request] of requests.entries()){const sub=path.join(directory,String(i));fs.mkdirSync(sub);const input=path.join(sub,'request.json');writeJson(input,request);let execution,observed;
   if(variant==='private-single'){const privateOut=path.join(sub,'private');execution=await execute([fileURLToPath(new URL('../run.mjs',import.meta.url)),image,request.input,request.mode,privateOut,'--cpu='+String(cfg.cpu??0)],path.join(directory,String(i)));observed=readJson(path.join(privateOut,'launch.json'));assert.equal(observed.complete,true);assert.equal(execution.status,observed.result.status==='ok'?0:1);}
   else{execution=await execute([fileURLToPath(new URL('./control-worker.mjs',import.meta.url)),image,input,sub,'b1'],path.join(directory,String(i)));assert.equal(execution.status,0);observed=readJson(path.join(sub,'control.json'));}
   assert.equal(execution.timedOut,false);executions.push(execution);observations.push(observed);}
  return {variant,execution:{status:0,signal:null,timedOut:false,wallMs:performance.now()-started,children:executions},observations};
 }
 if(variant==='private')argv=[fileURLToPath(new URL('../batch.mjs',import.meta.url)),image,file,directory,'--cpu='+String(cfg.cpu??0)];
 else{fs.mkdirSync(directory);argv=[fileURLToPath(new URL('./reference-batch-worker.mjs',import.meta.url)),image,file,directory,variant];}
 const execution=await execute(argv,path.join(out,name)),result=readJson(path.join(directory,variant==='private'?'batch.json':'reference.json'));
 assert.equal(execution.timedOut,false);assert.equal(execution.signal,null);assert.equal(result.complete,true);assert.equal(execution.status,variant==='private'&&result.rows.some(r=>r.observation.result.status!=='ok')?1:0);
 return {variant,execution,result,observations:result.rows.map(r=>variant==='private'?r.observation:r)};
}
try{
 const reference=cfg.referenceReport?readJson(resolve(cfg.referenceReport)):null;if(reference){assert.equal(reference.complete,true);assert.deepEqual(reference.cases,cases);assert.equal(reference.manifest.sha256,manifest.manifestIdentity.sha256);const file=identity(resolve(cfg.referenceReport));inputs.push(file);report.referenceReport=file;}
 const variants=cfg.variants??['private','public','b1','b1-single'];if(!variants.length||variants.some(v=>!['private','public','b1','b1-single','private-single'].includes(v)))throw Error('Unknown comparison variant');
 const positive=cases.find(c=>c.accept===true);if(!positive)throw Error('Need a positive cache-prime control');
 for(const variant of ['private','public','b1']){
  const row=await sample(variant,[{input:positive.input,mode:'check'}],'prime-'+variant);assert.equal(row.observations[0].result.status,'ok');report.prime.push(row);flush();
 }
 const cache=path.join(image,'host/build/typed/cache'),expected=new Set(['image.mjs','provenance/public-api.mjs','provenance/initial-compiler.mjs'].map(f=>identity(path.join(image,f)).sha256));report.caches=[];
 for(const name of fs.readdirSync(cache)){const file=path.join(cache,name),c=readJson(file);if(!expected.has(c.compilerSha256))continue;assert.equal(c.validatedBy,'check_book');assert.equal(c.baseSha256,manifest.manifest.base.sha256);assert.equal(c.sourcePath,manifest.manifest.base.canonicalPath);assert.equal(c.bookSha256,digest(JSON.stringify(c.book)));report.caches.push(identity(file));expected.delete(c.compilerSha256);}
 assert.equal(expected.size,0);flush();
 for(let repetition=0;repetition<(cfg.repetitions??3);repetition++)for(const variant of repetition%2?[...variants].reverse():variants){
  const row=await sample(variant,cases.map(c=>({input:c.input,mode:'check'})),repetition+'-'+variant);row.repetition=repetition;row.passed=false;report.rows.push(row);flush();
  for(let i=0;i<cases.length;i++){const c=cases[i],actual=row.observations[i].result;assert.equal(actual.status,c.accept?'ok':'error');assert.equal(actual.phase,c.accept?'check':c.rejectPhase);assert.equal(actual.checked,c.accept||c.rejectPhase==='check'||c.rejectPhase==='compile');for(const other of [...report.rows.filter(x=>x!==row),...(reference?.rows??[])])assert.deepEqual(actual,other.observations[i].result);}
  row.passed=true;flush();
 }
 for(const input of [...inputs,...report.caches])verifyIdentity(input);verifyIdentity(manifest.manifestIdentity);verifyImage(image);report.complete=true;
 const median=xs=>xs.toSorted((a,b)=>a-b)[Math.floor(xs.length/2)];report.summary=Object.fromEntries(variants.map(variant=>{const rows=report.rows.filter(r=>r.variant===variant);return [variant,{samples:rows.length,requestsPerProcess:variant.endsWith('-single')?1:cases.length,requestsPerSample:cases.length,medianProcessWallMs:median(rows.map(r=>r.execution.wallMs)),medianSummedRequestMs:median(rows.map(r=>r.observations.reduce((n,x)=>n+x.requestMs,0)))}];}));
}catch(error){report.error=error.stack;process.exitCode=1;}report.finished=new Date().toISOString();flush();console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,summary:report.summary,error:report.error}));
