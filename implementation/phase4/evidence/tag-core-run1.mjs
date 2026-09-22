// Controlled disposable private-image experiment. Actual Bend compiler bodies
// remain generated code; no parsing/checking/emission algorithm lives here.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {spawn} from 'node:child_process';import {createHash} from 'node:crypto';
import {fileURLToPath} from 'node:url';
import {transformPrivateCalls} from './private-calls.mjs';
import {transformPrivateRuntime,transformPrivateProjections} from './private-runtime.mjs';
import {preparePrivateConstants} from './private-constants.mjs';
const [configFile,outArg]=process.argv.slice(2);if(!outArg)throw Error('Usage: private-benchmark.mjs CONFIG NEW_DIRECTORY');
const cfg=JSON.parse(fs.readFileSync(configFile)),resolve=s=>fs.realpathSync(path.resolve(path.dirname(configFile),s)),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const sha=file=>createHash('sha256').update(fs.readFileSync(file)).digest('hex'),identity=file=>({path:fs.realpathSync(file),sha256:sha(file)}),save=(file,value)=>fs.writeFileSync(file,JSON.stringify(value,null,2)+'\n');
const baseline=resolve(cfg.baseline),manifestFile=path.join(baseline,'manifest.json'),manifest=JSON.parse(fs.readFileSync(manifestFile)),inputs={};
const record=file=>{inputs[file]=identity(file);return file;},verify=()=>{for(const [file,id] of Object.entries(inputs))assert.deepEqual(identity(file),id,'Input drift '+file);};
record(manifestFile);record(fs.realpathSync(configFile));record(process.execPath);
for(const [name,entry] of Object.entries(manifest.files)){const file=record(path.join(baseline,name));assert.equal(sha(file),entry.sha256);}
const base=record(manifest.base.file);assert.equal(sha(base),manifest.base.sha256);
const hostDir=path.join(out,'host/tools');fs.mkdirSync(hostDir,{recursive:true});
for(const name of ['typed-driver','compiler-abi','node-resource-args','assemble','native-build']){const dest=path.join(hostDir,name+'.mjs');fs.copyFileSync(path.join(baseline,'tools',name+'.mjs'),dest);record(dest);}
if(cfg.seedCacheDirectory){const seed=resolve(cfg.seedCacheDirectory),target=path.join(out,'host/build/typed/cache');fs.mkdirSync(target,{recursive:true});for(const name of fs.readdirSync(seed).filter(n=>/^base-.*\.json$/.test(n))){const original=record(path.join(seed,name));fs.copyFileSync(original,path.join(target,name));}}
const sourceFile=path.join(baseline,'api/h.mjs'),source=fs.readFileSync(sourceFile,'utf8'),runtime=path.join(baseline,'src/runtime.mjs');
const integration=JSON.parse(fs.readFileSync(record(resolve(cfg.integrationReport))));assert.equal(integration.complete,true);assert.equal(integration.apiSha256,sha(path.join(baseline,'api/b1.mjs')));
const toolsDir=path.dirname(fileURLToPath(import.meta.url));
for(const name of ['tag-core.mjs','private-worker.mjs','private-calls.mjs','private-runtime.mjs','private-constants.mjs'])record(path.join(toolsDir,name));
for(const name of ['direct-calls.mjs','native-primitives.mjs'])record(path.join(toolsDir,'../rapid',name));
const worker=path.join(out,'private-worker.mjs');fs.copyFileSync(path.join(toolsDir,'private-worker.mjs'),worker);record(worker);
const prepared=JSON.parse(fs.readFileSync(record(resolve(cfg.preparedReport))));
assert.equal(prepared.complete,true);
const variants=prepared.variants.map(v=>({...v,api:record(v.file)}));
for(const v of variants){const recorded=prepared.artifacts?.find?.(x=>x.file===v.api);if(recorded)assert.equal(sha(v.api),recorded.sha256);}
const works=cfg.workloads.map(x=>({...x,input:record(resolve(x.input))}));
const cpu=cfg.cpu??0,timeoutMs=cfg.timeoutMs??180000,repetitions=cfg.repetitions??3,args=['--stack-size=4096','--max-old-space-size=4096'];
const report={kind:'private-tag-core-comparison',started:new Date().toISOString(),complete:false,baselineManifest:manifestFile,scope:'Dedicated data-only inspect worker. This specialized image is NOT a drop-in public library. Original H G/call ABI and emitted runtime remain unchanged. Same host/output runtime; independently validated warm Base caches; serial alternating fresh processes; no OS cache flush.',variants,inputs,cpu,repetitions,seedCacheDirectory:cfg.seedCacheDirectory??null,node:{file:process.execPath,version:process.version,args},prime:[],rows:[],failures:[]};
const flush=()=>save(path.join(out,'report.json'),report);
const consumed=path.join(out,'consumed-tools');fs.mkdirSync(consumed);report.toolSnapshots=[];for(const [file,id] of Object.entries(inputs))if(file.includes('/tools/performance/')){const copied=path.join(consumed,path.basename(file));fs.copyFileSync(file,copied);report.toolSnapshots.push({original:file,snapshot:copied,...identity(copied)});}
flush();
async function run(command,argv,prefix,deadline=timeoutMs){const a=fs.openSync(prefix+'.stdout','wx'),b=fs.openSync(prefix+'.stderr','wx'),start=performance.now();let timedOut=false,error=null;const result=await new Promise(resolve=>{const p=spawn(command,argv,{env:{...process.env,NODE_OPTIONS:''},stdio:['ignore',a,b],detached:true});const t=setTimeout(()=>{timedOut=true;try{process.kill(-p.pid,'SIGKILL');}catch{}},deadline);p.once('error',e=>{error=String(e);clearTimeout(t);resolve({status:null,signal:null});});p.once('close',(status,signal)=>{clearTimeout(t);resolve({status,signal});});});fs.closeSync(a);fs.closeSync(b);return {...result,error,timedOut,wallMs:performance.now()-start,stdout:{file:prefix+'.stdout',bytes:fs.statSync(prefix+'.stdout').size,sha256:sha(prefix+'.stdout')},stderr:{file:prefix+'.stderr',bytes:fs.statSync(prefix+'.stderr').size,sha256:sha(prefix+'.stderr')}};}
const common={host:path.join(hostDir,'typed-driver.mjs'),runtime,base};
async function child(variant,request,name,prime=false){const configuration=path.join(out,name+'.config.json'),requestFile=path.join(out,name+'.request.json'),resultFile=path.join(out,name+'.result.json');save(configuration,{...common,api:variant.api,identities:{...inputs}});save(requestFile,request);const execution=await run('taskset',['-c',String(cpu),process.execPath,...args,worker,configuration,requestFile,resultFile,...(prime?['--prime']:[])],path.join(out,name));return{execution,resultFile,...(execution.status===0&&fs.existsSync(resultFile)?{observation:JSON.parse(fs.readFileSync(resultFile))}:{})};}
try{
 for(const variant of variants){console.error('prime '+variant.id);const r=await child(variant,{input:works[0].input,mode:'check'},'prime-'+variant.id,true);report.prime.push({variant:variant.id,...r});assert.equal(r.execution.status,0);assert.equal(r.observation.validatedBy,'check_book');assert.equal(r.observation.compilerSha256,sha(variant.api));flush();}
 const cacheDir=path.join(out,'host/build/typed/cache');for(const name of fs.readdirSync(cacheDir))record(path.join(cacheDir,name));
 for(let repetition=0;repetition<repetitions;repetition++)for(const work of works)for(const variant of repetition%2?[...variants].reverse():variants){
  const name=work.id+'-'+repetition+'-'+variant.id;console.error('sample '+name);const row={name,workload:work.id,repetition,variant:variant.id,...await child(variant,{input:work.input,mode:work.mode??'compile'},name),passed:false};report.rows.push(row);
  if(row.observation){const result=row.observation.result,peers=report.rows.filter(x=>x!==row&&x.workload===work.id&&x.observation);const expectedPhase=work.phase??(work.mode==='check'||work.mode==='parse'?work.mode:'compile');row.expected=result.status===(work.status??'ok')&&result.phase===expectedPhase&&result.checked===(work.checked??!['parse','load'].includes(expectedPhase));row.sameResult=peers.every(x=>JSON.stringify(x.observation.result)===JSON.stringify(result));row.sameBytes=peers.every(x=>x.observation.emitted?.sha256===row.observation.emitted?.sha256);row.passed=row.expected&&row.sameResult&&row.sameBytes;
   if(row.observation.emitted&&work.expectedStdout!==undefined){row.run=await run(process.execPath,args.concat(row.observation.emitted.file),path.join(out,name+'-run'));row.executed=row.run.status===0&&row.run.stderr.bytes===0&&fs.readFileSync(row.run.stdout.file,'utf8')===work.expectedStdout;row.passed&&=row.executed;}
  }
  if(!row.passed)report.failures.push(name);flush();
 }
 verify();report.inputsUnchanged=true;const median=xs=>xs.toSorted((a,b)=>a-b)[Math.floor(xs.length/2)];report.summary={};
 for(const work of works){const cells=report.rows.filter(x=>x.workload===work.id),valid=cells.length===variants.length*repetitions&&cells.every(x=>x.passed);report.summary[work.id]={valid,variants:Object.fromEntries(variants.map(v=>{const rows=cells.filter(x=>x.variant===v.id);return[v.id,{samples:rows.length,...(valid?{medianRequestMs:median(rows.map(x=>x.observation.requestMs)),medianWallMs:median(rows.map(x=>x.execution.wallMs))}:{})}];}))};}
 report.complete=report.failures.length===0;report.finished=new Date().toISOString();flush();console.log(JSON.stringify({complete:report.complete,summary:report.summary}));if(!report.complete)process.exitCode=1;
}catch(error){report.error=error.stack;flush();throw error;}
