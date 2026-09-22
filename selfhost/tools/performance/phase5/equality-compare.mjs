// Controlled comparison of a genuine checked build and its explicitly derived
// equality image. This composes maintained lineage checks, not fake sidecars.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {verifyAttempt,identity,verifyIdentity,validatedCache} from '../../development/workflow.mjs';
import {deriveEquality,verifyEqualityDerivation} from '../../development/equality.mjs';
import {supervise,requireExecution} from '../../development/process.mjs';

export function settings(value){
 const known=['attempt','coreLibrary','cpu','repetitions','timeoutMs'];for(const key of Object.keys(value))assert.ok(known.includes(key),'Unknown setting: '+key);
 assert.ok(typeof value.attempt==='string'&&typeof value.coreLibrary==='string');
 const cpu=value.cpu??3,repetitions=value.repetitions??2,timeoutMs=value.timeoutMs??180000;
 assert.ok(Number.isSafeInteger(cpu)&&cpu>=0);assert.ok(Number.isSafeInteger(repetitions)&&repetitions>=2&&repetitions<=6&&repetitions%2===0,'Use complete forward/reverse pairs');
 assert.ok(Number.isSafeInteger(timeoutMs)&&timeoutMs>=1000&&timeoutMs<=900000);
 return {...value,cpu,repetitions,timeoutMs};
}
export const outcome=r=>({status:r.status,phase:r.phase,checked:r.checked,exitCode:r.exitCode??null,diagnostic:r.diagnostic??null});
export function summarize(rows,repetitions){
 const median=xs=>{const s=[...xs].sort((a,b)=>a-b),n=s.length;return n%2?s[n>>1]:(s[n/2-1]+s[n/2])/2;};
 const result={};
 for(const workload of ['core','list']){
  const cell=rows.filter(r=>r.workload===workload),variants=workload==='core'?['checked','derived']:['checked','derived','typescript'];
  const valid=cell.length===repetitions*variants.length&&cell.every(r=>r.passed)&&variants.every(v=>{const samples=cell.filter(r=>r.variant===v);return samples.length===repetitions&&new Set(samples.map(r=>r.repetition)).size===repetitions&&samples.every(r=>Number.isSafeInteger(r.repetition)&&r.repetition>=0&&r.repetition<repetitions);});
  result[workload]={validComparison:valid,variants:Object.fromEntries(variants.map(variant=>{const samples=cell.filter(r=>r.variant===variant);return [variant,{samples:samples.length,passed:samples.filter(r=>r.passed).length,...valid?{medianRequestMs:median(samples.map(r=>r.observation.requestMs)),medianProcessWallMs:median(samples.map(r=>r.execution.wallMs)),medianMaxRssKiB:median(samples.map(r=>r.observation.maxRssKiB))}:{timingsWithheld:'The entire comparison cell must pass.'}}];}))};
 }
 return result;
}

export async function compare(configArg,outArg){
 const configFile=fs.realpathSync(configArg),config=settings(JSON.parse(fs.readFileSync(configFile))),relative=file=>fs.realpathSync(path.resolve(path.dirname(configFile),file)),out=path.resolve(outArg);
 fs.mkdirSync(out,{recursive:false});
 const report={kind:'phase5-maintained-equality-comparison',complete:false,newBootstrap:false,started:new Date().toISOString(),config:identity(configFile),inputs:[],prime:[],rows:[],scope:'Genuine checked B1 versus maintained verified derivative using one frozen host and output runtime. Pinned TS compared on list_sort only; its generated runtime and checking route differ. No TypeScript core-library comparison or full-language claim.',cachePolicy:'Separate API-specific validated Base caches, primed in separate processes before timing. TypeScript loads/checks Base in each fresh process and has no equivalent serialized Base cache. OS caches are not flushed.',order:'Forward variants then reverse variants in each complete pair; fresh process for every sample. API phase timings are nested instrumentation and must not be added to request time.',timingBoundary:'Request excludes module import, provenance hashing and writing emitted/result files. It includes normal driver input/cache reads and the compiler pipeline. Process wall and maxRSS include startup, verification and output capture; these are measured wrapper costs, not a production CLI claim.'};
 const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
 const add=file=>{const item=identity(file);if(!report.inputs.some(i=>i.file===item.file))report.inputs.push(item);return item.file;};
 const verify=()=>report.inputs.forEach(verifyIdentity);
 try{
  const attempt=relative(config.attempt),m=await verifyAttempt(attempt);assert.equal(m.artifactKind,'checked-b1','Benchmark starts with the original checked API');
  report.original={attempt:identity(path.join(attempt,'attempt.json')),api:m.api,bootstrap:m.bootstrapReport,source:identity(JSON.parse(fs.readFileSync(m.bootstrapReport.file)).source)};
  add(configFile);add(path.join(attempt,'attempt.json'));add(m.api.file);add(m.bootstrapReport.file);add(m.base.file);add(m.runtime.file);add(process.execPath);
  for(const name of ['workflow','equality','process'])add(new URL('../../development/'+name+'.mjs',import.meta.url).pathname);
  add(new URL('../../conformance/inventory.mjs',import.meta.url).pathname);add(import.meta.filename);
  const derived=await deriveEquality({api:m.api.file,bootstrapReport:m.bootstrapReport.file,outputDirectory:path.join(out,'derived')});report.derivation=identity(derived.report);add(derived.api);add(derived.report);add(derived.metadata.toolSnapshot.file);
  for(const i of derived.metadata.original.inputs){verifyIdentity(i);add(i.file);}
  const upstream=m.config.upstream,base=m.base.file,runtime=m.runtime.file;
  assert.equal(fs.realpathSync(base),fs.realpathSync(path.join(upstream,'bend2/base.bend')));
  for(const name of ['bend.ts','comp.ts','base.bend','main.ts'])add(path.join(upstream,'bend2',name));
  const env={...process.env};for(const key of Object.keys(env))if(key.startsWith('BEND_')||key==='NODE_OPTIONS')delete env[key];
  const git=await supervise('git',['-C',upstream,'diff','--quiet','HEAD','--','bend2','tests'],{directory:path.join(out,'upstream-clean'),env,timeoutMs:10000});requireExecution(git);report.upstream={directory:upstream,pin:derived.metadata.original.revision,clean:git};
  const head=await supervise('git',['-C',upstream,'rev-parse','HEAD'],{directory:path.join(out,'upstream-head'),env,timeoutMs:10000});requireExecution(head);assert.equal(fs.readFileSync(head.stdout,'utf8').trim(),report.upstream.pin);report.upstream.head=head;
  const hostDir=path.join(out,'host/tools');fs.mkdirSync(hostDir,{recursive:true});report.hostCopies=[];
  for(const name of ['typed-driver','compiler-abi','native-build','node-resource-args','assemble']){const original=add(path.join(m.snapshot.root,'tools',name+'.mjs')),copy=path.join(hostDir,name+'.mjs');fs.copyFileSync(original,copy);add(copy);assert.equal(identity(original).sha256,identity(copy).sha256);report.hostCopies.push({original:identity(original),copy:identity(copy)});}
  const host=path.join(hostDir,'typed-driver.mjs'),worker=path.join(out,'worker.mjs'),workerSource=add(new URL('./equality-worker.mjs',import.meta.url).pathname);fs.copyFileSync(workerSource,worker);add(worker);
  const workloads=[{id:'core',input:add(relative(config.coreLibrary)),mode:'library'},{id:'list',input:add(path.join(upstream,'tests/base/list_sort.bend')),mode:'compile',expectedStdout:'6\n'}];
  const variants=[{id:'checked',api:m.api.file},{id:'derived',api:derived.api},{id:'typescript'}];
  report.workloads=workloads;report.variants=variants;report.cpu=config.cpu;report.repetitions=config.repetitions;report.node={...identity(process.execPath),version:process.version,args:['--stack-size=4096','--max-old-space-size=4096']};save();
  async function sample(variant,work,label,prime=false){
   verify();const request=path.join(out,label+'.request.json'),result=path.join(out,label+'.result.json'),output=path.join(out,label+(variant.id==='typescript'?'.cjs':'.mjs'));
   fs.writeFileSync(request,JSON.stringify({variant:variant.id,api:variant.api,upstream,base,runtime,host,input:work.input,mode:work.mode,output,prime,workloads,inputs:report.inputs},null,2)+'\n',{flag:'wx'});
   const execution=await supervise('taskset',['-c',String(config.cpu),process.execPath,...report.node.args,worker,request,result],{directory:path.join(out,label+'-process'),env,timeoutMs:config.timeoutMs});
   const row={label,variant:variant.id,workload:work.id,request:identity(request),execution,passed:false};(prime?report.prime:report.rows).push(row);save();requireExecution(execution);
   row.result=identity(result);row.observation=JSON.parse(fs.readFileSync(result));assert.equal(row.observation.inputsVerified,true);assert.equal(row.observation.node.path,process.execPath);assert.equal(row.observation.affinity.split(':')[1].trim(),String(config.cpu));verify();save();return row;
  }
  for(const variant of variants.filter(v=>v.api)){
   const row=await sample(variant,workloads[0],'prime-'+variant.id,true),cache=row.observation.cache;
   assert.equal(cache.validatedBy,'check_book');assert.equal(cache.compilerSha256,identity(variant.api).sha256);assert.equal(cache.baseSha256,m.base.sha256);
   const c=validatedCache(path.join(out,'host/build/typed/cache'),variant.api,base);add(c.file);row.cache=c;
   for(const file of row.observation.dependencies)add(file);row.passed=true;save();
  }
  // A fixed input capsule with no dependencies beyond Base makes the TS request
  // input set auditable without a handwritten import parser.
  assert.ok(report.inputs.some(i=>i.file===base));
  for(let repetition=0;repetition<config.repetitions;repetition++)for(const work of workloads){
   const selected=variants.filter(v=>work.id!=='core'||v.api),order=repetition%2?[...selected].reverse():selected;
   for(const variant of order){
    const row=await sample(variant,work,work.id+'-'+repetition+'-'+variant.id);row.repetition=repetition;
    assert.deepEqual(outcome(row.observation.result),{status:'ok',phase:'compile',checked:true,exitCode:0,diagnostic:null});
    assert.ok(row.observation.emitted);verifyIdentity(row.observation.emitted);
    for(const peer of report.rows.filter(p=>p!==row&&p.workload===work.id)){
     assert.deepEqual(outcome(row.observation.result),outcome(peer.observation.result));
     if(variant.api&&peer.variant!=='typescript')assert.deepEqual(fs.readFileSync(row.observation.emitted.file),fs.readFileSync(peer.observation.emitted.file),'Original/derived emitted bytes differ');
    }
    const program=row.observation.emitted.file,execArgs=work.id==='list'?[...report.node.args,program]:['--check',program];
    row.programExecution=await supervise('taskset',['-c',String(config.cpu),process.execPath,...execArgs],{directory:path.join(out,row.label+'-program'),env,timeoutMs:30000,maxBytes:1048576});requireExecution(row.programExecution);
    assert.equal(fs.readFileSync(row.programExecution.stdout,'utf8'),work.expectedStdout??'');assert.equal(fs.readFileSync(row.programExecution.stderr,'utf8'),'');row.passed=true;save();
   }
  }
  await verifyAttempt(attempt);verifyEqualityDerivation(derived.report);verify();
  report.inputsUnchanged=true;report.summary=summarize(report.rows,config.repetitions);assert.ok(Object.values(report.summary).every(c=>c.validComparison));report.complete=true;report.finished=new Date().toISOString();save();return report;
 }catch(error){report.error=String(error.stack??error);report.summary=summarize(report.rows,config.repetitions);report.finished=new Date().toISOString();save();throw error;}
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){const [config,out,...extra]=process.argv.slice(2);if(!out||extra.length)throw Error('Usage: equality-compare.mjs CONFIG NEW_DIRECTORY');const report=await compare(config,out);console.log(JSON.stringify({complete:report.complete,summary:report.summary}));}
