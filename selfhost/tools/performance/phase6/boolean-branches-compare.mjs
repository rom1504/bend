// Bounded P6-002 comparison; unchanged phase5 worker and frozen final05 host.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
import {verifyAttempt,identity,verifyIdentity,validatedCache} from '../../development/workflow.mjs';
import {verifyEqualityDerivation} from '../../development/equality.mjs';
import {supervise,requireExecution} from '../../development/process.mjs';
const read=f=>JSON.parse(fs.readFileSync(f));const save=(f,x)=>fs.writeFileSync(f,JSON.stringify(x,null,2)+'\n');
const controlSha='e2b5463678a26558e8fea1d585782e0863f1046067949a374f0469080281b15a',candidateSha='603086e8792030d2a3f044131bbb251c17747f06296ed6cc9157e01f2ef62cdc',oracle='016a5cedeb7e285adeabdad19388d99d3d9070668c15776ccc10fab8ea7b7186';
const nodeArgs=['--stack-size=4096','--max-old-space-size=4096'];
function environment(){const env={...process.env};for(const k of Object.keys(env))if(k.startsWith('BEND_')||k==='NODE_OPTIONS')delete env[k];return env;}
function verify(s){s.inputs.forEach(verifyIdentity);assert.equal(process.execPath,s.node.file);assert.equal(process.version,s.node.version);}
async function worker(s,variant,label,out,{prime=false}={}){
 verify(s);const request=path.join(out,label+'.request.json'),result=path.join(out,label+'.result.json'),output=path.join(out,label+'.mjs');
 save(request,{variant:variant.id,api:variant.api.file,upstream:s.upstream,base:s.base.file,runtime:s.runtime.file,host:s.host,input:s.core.file,mode:'library',output,prime,workloads:[{input:s.core.file}],inputs:s.inputs});
 const ms=Math.min(90000,Date.parse(s.deadline)-Date.now());assert.ok(ms>0,'Absolute campaign deadline exhausted');
 const execution=await supervise('taskset',['-c','2',process.execPath,...nodeArgs,s.worker,request,result],{directory:path.join(out,label+'-process'),env:environment(),timeoutMs:Math.floor(ms)});
 const row={variant:variant.id,request:identity(request),execution,passed:false};
 if(fs.existsSync(result)){row.result=identity(result);row.observation=read(result);}return row;
}
function accepted(row){requireExecution(row.execution);const o=row.observation;assert.equal(o.inputsVerified,true);assert.equal(o.node.path,process.execPath);assert.equal(o.affinity.split(':')[1].trim(),'2');assert.deepEqual({status:o.result.status,phase:o.result.phase,checked:o.result.checked,exitCode:o.result.exitCode},{status:'ok',phase:'compile',checked:true,exitCode:0});assert.equal(o.emitted.sha256,oracle);verifyIdentity(o.emitted);}
export async function prepare(configFile,out){
 configFile=fs.realpathSync(configFile);out=path.resolve(out);fs.mkdirSync(out,{recursive:false});const cfg=read(configFile);assert.equal(cfg.cpu,2);assert.equal(cfg.timeoutMs,90000);assert.equal(cfg.deadline,'2026-09-23T03:32:00Z');
 const report={kind:'phase6-boolean-branches-preparation',complete:false,started:new Date().toISOString(),newBootstrap:false,inputs:[],priming:[],deadline:cfg.deadline};const write=()=>save(path.join(out,'report.json'),report);write();
 const add=f=>{const x=identity(f);if(!report.inputs.some(i=>i.file===x.file))report.inputs.push(x);return x;};
 try{
  const original=await verifyAttempt(cfg.attempt),candidate=await verifyAttempt(cfg.candidateAttempt),control=verifyEqualityDerivation(cfg.controlDerivation),derived=verifyEqualityDerivation(candidate.derivationReport.file);
  assert.equal(original.artifactKind,'checked-b1');assert.equal(candidate.artifactKind,'derived-b1');assert.equal(control.metadata.original.api.sha256,original.api.sha256);assert.equal(control.metadata.original.bootstrapReport.sha256,original.bootstrapReport.sha256);
  assert.equal(identity(control.api).sha256,controlSha);assert.equal(identity(derived.api).sha256,candidateSha);assert.equal(original.base.sha256,candidate.base.sha256);assert.equal(original.base.canonicalPath,candidate.base.canonicalPath);assert.equal(original.runtime.sha256,candidate.runtime.sha256);
  report.attempts=[cfg.attempt,cfg.candidateAttempt];report.derivations=[control.report,derived.report];
  for(const f of [configFile,import.meta.filename,process.execPath,path.join(cfg.attempt,'attempt.json'),path.join(cfg.candidateAttempt,'attempt.json'),control.report,derived.report,control.metadata.toolSnapshot.file,derived.metadata.toolSnapshot.file])add(f);
  for(const d of [control,derived]){for(const x of d.metadata.original.inputs){verifyIdentity(x);add(x.file);}add(d.metadata.original.api.file);add(d.metadata.original.bootstrapReport.file);}
  for(const name of ['workflow','equality','process'])add(new URL('../../development/'+name+'.mjs',import.meta.url).pathname);add(new URL('../../conformance/inventory.mjs',import.meta.url).pathname);
  const tools=path.join(out,'host/tools');fs.mkdirSync(tools,{recursive:true});
  for(const name of ['typed-driver','compiler-abi','native-build','node-resource-args','assemble']){const source=path.join(original.snapshot.root,'tools',name+'.mjs'),target=path.join(tools,name+'.mjs');fs.copyFileSync(source,target);assert.equal(add(source).sha256,add(target).sha256);}
  const workerSource=new URL('../phase5/equality-worker.mjs',import.meta.url).pathname;report.worker=path.join(out,'worker.mjs');fs.copyFileSync(workerSource,report.worker);assert.equal(add(workerSource).sha256,add(report.worker).sha256);
  Object.assign(report,{host:path.join(tools,'typed-driver.mjs'),base:add(original.base.file),runtime:add(original.runtime.file),upstream:original.config.upstream,core:add(cfg.core),node:{...add(process.execPath),version:process.version},variants:[{id:'control',api:add(control.api)},{id:'candidate',api:add(derived.api)}],oracle,cpu:2});assert.equal(fs.statSync(cfg.core).size,60909);write();
  for(const variant of report.variants){const row=await worker(report,variant,'prime-'+variant.id,out,{prime:true});report.priming.push(row);write();requireExecution(row.execution);assert.equal(row.observation.inputsVerified,true);assert.equal(row.observation.cache.validatedBy,'check_book');row.cache=validatedCache(path.join(out,'host/build/typed/cache'),variant.api.file,report.base.file);add(row.cache.file);for(const f of row.observation.dependencies)add(f);row.passed=true;write();}
  assert.deepEqual(read(report.priming[0].cache.file).book,read(report.priming[1].cache.file).book);report.decodedBaseEqual=true;
  report.preflight=await worker(report,report.variants[1],'candidate-correctness-preflight',out);write();accepted(report.preflight);report.preflight.passed=true;report.preflight.scope='Untimed correctness preparation; not a controlled performance observation';
  verify(report);for(const a of report.attempts)await verifyAttempt(a);for(const d of report.derivations)verifyEqualityDerivation(d);report.complete=true;
 }catch(e){report.error=String(e.stack??e);process.exitCode=1;}report.finished=new Date().toISOString();write();return report;
}
export async function run(prepared,out){
 const preparation=path.resolve(prepared,'report.json'),s=read(preparation);assert.equal(s.complete,true);out=path.resolve(out);fs.mkdirSync(out,{recursive:false});
 const report={kind:'phase6-boolean-branches-ABBA',complete:false,started:new Date().toISOString(),newBootstrap:false,preparation:identity(preparation),inputs:[...s.inputs,identity(preparation),identity(import.meta.filename)],rows:[],order:['control','candidate','candidate','control'],scope:'Four fresh processes, same frozen final05 host/runtime/Base/core and equality profile; separately primed equal decoded Base caches. Request excludes import/hash/output write; process and RSS include them. No full-source or public H claim.',deadline:s.deadline};const write=()=>save(path.join(out,'report.json'),report);write();
 try{
  report.inputs.forEach(verifyIdentity);verify(s);
  for(const [index,id]of report.order.entries()){const variant=s.variants.find(x=>x.id===id),row=await worker(s,variant,'sample-'+index+'-'+id,out);row.index=index;report.rows.push(row);write();accepted(row);assert.deepEqual(fs.readFileSync(row.observation.emitted.file),fs.readFileSync(s.preflight.observation.emitted.file),'Exact emitted bytes differ');row.passed=true;write();}
  report.pairs=[[0,1],[3,2]].map(([a,b])=>{const control=report.rows[a],candidate=report.rows[b];return {control:a,candidate:b,requestReduction:1-candidate.observation.requestMs/control.observation.requestMs,processReduction:1-candidate.execution.wallMs/control.execution.wallMs};});
  report.material=report.pairs.every(p=>p.requestReduction>=.05&&p.processReduction>=.05);report.inputs.forEach(verifyIdentity);for(const a of s.attempts)await verifyAttempt(a);for(const d of s.derivations)verifyEqualityDerivation(d);report.inputsVerified=true;report.complete=true;
 }catch(e){report.error=String(e.stack??e);process.exitCode=1;}report.finished=new Date().toISOString();write();return report;
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){const [mode,input,out,...extra]=process.argv.slice(2);if(!out||extra.length||!['prepare','run'].includes(mode))throw Error('Usage: boolean-branches-compare.mjs prepare CONFIG NEW_PREPARATION | run PREPARATION NEW_RUN');const r=await (mode==='prepare'?prepare(input,out):run(input,out));console.log(JSON.stringify({complete:r.complete,material:r.material,error:r.error,pairs:r.pairs}));}
