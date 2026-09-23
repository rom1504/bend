// Final artifact validation through the maintained full-inventory harness.
// H uses its actual completed fixed point; derivatives retain separate lineage.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {verifyAttempt,identity,verifyIdentity,validatedCache,observationHealth} from '../../development/workflow.mjs';
import {verifyEqualityDerivation} from '../../development/equality.mjs';
import {supervise,requireExecution} from '../../development/process.mjs';
import {exactRows} from './equality-frontend.mjs';

const read=file=>JSON.parse(fs.readFileSync(file));
const hash=bytes=>createHash('sha256').update(bytes).digest('hex');
const walk=directory=>fs.readdirSync(directory,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(directory,e.name)):[path.join(directory,e.name)]);
const key=row=>row.id+'::'+row.lane;
const fixtures=raw=>raw.inventory.tests.map(t=>[t.id,t.sha256]).sort((a,b)=>a[0].localeCompare(b[0]));
function healthy(raw){
 assert.ok(observationHealth(raw),'Incomplete or unhealthy observations');
 assert.equal(raw.inventory.total,1378);assert.equal(raw.results.length,2756);
 assert.equal(raw.workers.length,4);assert.equal(new Set(raw.results.map(key)).size,2756);
 assert.ok(raw.workers.every(w=>w.stats.failures===0&&w.stats.timeouts===0));
 assert.deepEqual([...new Set(raw.results.map(r=>r.lane))].sort(),['check','parse']);
}
export function settings(value){
 for(const k of Object.keys(value))assert.ok(['attempt','proof','comparison','cpus','hTimeoutMs','derivedTimeoutMs','deadline'].includes(k),'Unknown setting: '+k);
 for(const k of ['attempt','proof','comparison'])assert.ok(typeof value[k]==='string'&&value[k].length);
 const cpus=value.cpus??'0,1,2,3';assert.match(cpus,/^\d+(,\d+){3}$/);assert.equal(new Set(cpus.split(',')).size,4);
 const hTimeoutMs=value.hTimeoutMs??1800000,derivedTimeoutMs=value.derivedTimeoutMs??900000;
 for(const n of [hTimeoutMs,derivedTimeoutMs])assert.ok(Number.isSafeInteger(n)&&n>=1000&&n<=3600000);
 assert.ok(typeof value.deadline==='string'&&/^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d(?:\.\d{3})?Z$/.test(value.deadline)&&Number.isFinite(Date.parse(value.deadline)));
 return {...value,cpus,hTimeoutMs,derivedTimeoutMs};
}
export async function validate(configArg,outArg){
 const configFile=fs.realpathSync(configArg),config=settings(read(configFile)),out=path.resolve(outArg),relative=f=>fs.realpathSync(path.resolve(path.dirname(configFile),f));
 fs.mkdirSync(out,{recursive:false});
 const report={kind:'phase5-final-artifact-frontend',complete:false,newBootstrap:false,started:new Date().toISOString(),inputs:[],rows:[],priming:[],
  scope:'Public checked H and maintained equality-derived B1, each complete 1378-fixture/2756-observation parse/check inventory, compared with final checked B1. Exact diagnostics and known strict failures remain visible. No fabricated bootstrap, full-language conformance or controlled timing claim.',
  resourceScope:'Four persistent workers on four assigned physical cores. Per-request timeout300s, Node stack4MiB, heap/RSS4GiB, recycling64 requests. Setup/priming/audit separate from finite harness wall; concurrent host activity makes these validation workflow observations.'};
 const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
 const add=f=>{const item=identity(f);if(!report.inputs.some(x=>x.file===item.file))report.inputs.push(item);return item;};
 const verify=()=>report.inputs.forEach(verifyIdentity);
 const remaining=maximum=>{const n=Math.min(maximum,Date.parse(config.deadline)-Date.now());assert.ok(n>=1,'Validation campaign deadline exhausted');return Math.floor(n);};
 try{
  remaining(1000);
  const attempt=relative(config.attempt),m=await verifyAttempt(attempt);assert.equal(m.artifactKind,'checked-b1');
  const comparisonFile=relative(config.comparison),comparison=read(comparisonFile),proofFile=relative(config.proof),proof=read(proofFile);
  assert.equal(comparison.kind,'phase5-final-full-source-comparison');assert.equal(comparison.complete,true);assert.equal(comparison.inputsUnchanged,true);assert.equal(comparison.decodedBaseEqual,true);
  assert.equal(comparison.rows.length,6);assert.ok(comparison.rows.every(r=>r.passed));comparison.inputs.forEach(verifyIdentity);
  assert.equal(comparison.original.api.sha256,m.api.sha256);assert.equal(comparison.original.bootstrap.sha256,m.bootstrapReport.sha256);
  const derived=verifyEqualityDerivation(comparison.derivation.file);assert.equal(derived.metadata.original.api.sha256,m.api.sha256);assert.equal(derived.metadata.original.bootstrapReport.sha256,m.bootstrapReport.sha256);
  const bootstrap=read(m.bootstrapReport.file);
  assert.equal(proof.complete,true);assert.equal(proof.sourceSha256,identity(bootstrap.source).sha256);assert.equal(proof.sourceIdentity.canonicalPath,fs.realpathSync(bootstrap.source));
  assert.equal(proof.initialCompiler.sha256,m.api.sha256);assert.equal(proof.base.sha256,m.base.sha256);assert.equal(proof.base.canonicalPath,m.base.canonicalPath);assert.equal(proof.runtimeSha256,m.runtime.sha256);
  assert.equal(proof.driver.sha256,identity(path.join(m.snapshot.root,'tools/typed-driver.mjs')).sha256);
  for(const item of [proof.sourceIdentity,proof.initialCompiler,proof.base,proof.driver,...proof.hostHelpers]){verifyIdentity(item);add(item.file);}
  const stage2=proof.stages.find(s=>path.basename(s.output)==='stage2.mjs'),stage3=proof.stages.find(s=>path.basename(s.output)==='stage3.mjs');assert.ok(stage2&&stage3);
  for(const s of [stage2,stage3]){assert.equal(s.code,0);assert.equal(s.signal,null);assert.equal(s.inputsVerified,true);assert.equal(identity(s.output).sha256,s.outputSha256);add(s.output);}
  assert.equal(stage2.compilerSha256,m.api.sha256);assert.equal(stage3.compilerSha256,stage2.outputSha256);assert.equal(stage2.outputSha256,stage3.outputSha256);
  assert.deepEqual(fs.readFileSync(stage2.output),fs.readFileSync(stage3.output));
  for(const row of comparison.rows.filter(r=>r.variant!=='typescript')){verifyIdentity(row.observation.emitted);assert.equal(row.observation.emitted.sha256,stage2.outputSha256);}
  assert.equal(comparison.source.sha256,proof.sourceSha256);
  const historical=path.join(attempt,'validation-001/frontend.json'),expected=read(historical);healthy(expected);
  assert.equal(expected.identity.artifacts.compiler.sha256,m.api.sha256);assert.equal(expected.identity.artifacts.base.sha256,m.base.sha256);assert.equal(expected.identity.artifacts.runtime.sha256,m.runtime.sha256);
  for(const f of [configFile,import.meta.filename,process.execPath,path.join(attempt,'attempt.json'),historical,proofFile,comparisonFile,comparison.derivation.file,derived.api,derived.metadata.toolSnapshot.file,m.api.file,m.bootstrapReport.file,m.runtime.file,m.base.file])add(f);
  for(const name of ['workflow','equality','process'])add(new URL('../../development/'+name+'.mjs',import.meta.url).pathname);
  add(new URL('../../conformance/inventory.mjs',import.meta.url).pathname);add(new URL('./equality-frontend.mjs',import.meta.url).pathname);
  for(const i of derived.metadata.original.inputs){verifyIdentity(i);add(i.file);}
  report.lineage={originalCheckedAttempt:identity(path.join(attempt,'attempt.json')),originalBootstrap:m.bootstrapReport,source:identity(bootstrap.source),proof:add(proofFile),stage2:add(stage2.output),stage3:add(stage3.output),comparison:add(comparisonFile),derivation:add(derived.report)};
  const project=path.join(out,'project');
  for(const rel of ['tools/conformance','src/runtime/native']){
   const source=path.join(m.snapshot.root,rel),target=path.join(project,rel);fs.mkdirSync(path.dirname(target),{recursive:true});fs.cpSync(source,target,{recursive:true});
   for(const file of walk(source)){const original=add(file),copy=add(path.join(target,path.relative(source,file)));assert.equal(original.sha256,copy.sha256);}
  }
  for(const name of ['typed-driver','compiler-abi','native-build','node-resource-args','assemble']){
   const source=path.join(m.snapshot.root,'tools',name+'.mjs'),target=path.join(project,'tools',name+'.mjs');fs.copyFileSync(source,target);assert.equal(add(source).sha256,add(target).sha256);
  }
  const cpus=config.cpus.split(',').map(Number);report.topology=cpus.map(cpu=>({cpu,package:fs.readFileSync(`/sys/devices/system/cpu/cpu${cpu}/topology/physical_package_id`,'utf8').trim(),core:fs.readFileSync(`/sys/devices/system/cpu/cpu${cpu}/topology/core_id`,'utf8').trim()}));assert.equal(new Set(report.topology.map(t=>t.package+':'+t.core)).size,4);
  const variants=[{id:'h',api:identity(stage2.output),deadlineMs:config.hTimeoutMs},{id:'derived',api:identity(derived.api),deadlineMs:config.derivedTimeoutMs}];report.variants=variants;report.config=config;report.historical=identity(historical);report.node={...identity(process.execPath),version:process.version};save();
  const environment=api=>{const env={...process.env};for(const k of Object.keys(env))if(k.startsWith('BEND_')||k==='NODE_OPTIONS')delete env[k];return {...env,BEND_UPSTREAM:m.config.upstream,BEND_BASE:m.base.file,BEND_TYPED_RUNTIME:m.runtime.file,BEND_TYPED_API:api.file,BEND_TYPED_TRACE:''};};
  const verifyShared=async()=>{verify();await verifyAttempt(attempt);verifyEqualityDerivation(derived.report);};
  for(const variant of variants){
   await verifyShared();const row={variant:variant.id,api:variant.api,started:new Date().toISOString(),complete:false};report.priming.push(row);save();
   try {
    row.execution=await supervise('taskset',['-c',String(cpus[0]),process.execPath,'--stack-size=4096','--max-old-space-size=4096',path.join(project,'tools/typed-driver.mjs'),'--prepare-base'],{directory:path.join(out,'prime-'+variant.id),env:environment(variant.api),timeoutMs:remaining(180000)});save();requireExecution(row.execution);
    row.cache=validatedCache(path.join(project,'build/typed/cache'),variant.api.file,m.base.file);add(row.cache.file);row.complete=true;
   }catch(error){row.error=String(error.stack??error);}
   row.finished=new Date().toISOString();save();await verifyShared();
  }
  const replay=await import(pathToFileURL(path.join(project,'tools/conformance/persistent-probe.mjs')));
  for(const variant of variants){
   await verifyShared();
   const row={variant:variant.id,api:variant.api,started:new Date().toISOString(),complete:false};report.rows.push(row);save();
   if(!report.priming.find(p=>p.variant===variant.id).complete){row.error='Not launched: this artifact Base priming failed; no implicit retry.';row.finished=new Date().toISOString();save();continue;}
   try {
   const directory=path.join(out,variant.id);fs.mkdirSync(directory);const observedFile=path.join(directory,'observations.json');
   const args=['-c',config.cpus,process.execPath,'--stack-size=4096','--max-old-space-size=4096',path.join(project,'tools/conformance/run.mjs'),'--upstream',m.config.upstream,'--jobs','4','--timeout','300000','--worker-mode','persistent','--recycle-after','64','--rss-limit-mb','4096','--stack-kb','4096','--heap-mb','4096','--lanes','parse,check','--retain','failed','--adapter',path.join(project,'tools/conformance/adapters/typed.mjs'),'--output',observedFile];
   row.execution=await supervise('taskset',args,{directory:path.join(directory,'process'),env:environment(variant.api),timeoutMs:remaining(variant.deadlineMs)});save();requireExecution(row.execution,[0,1]);
   const observed=read(observedFile);row.observations=identity(observedFile);healthy(observed);
   assert.equal(observed.identity.artifacts.compiler.sha256,variant.api.sha256);assert.equal(observed.identity.artifacts.base.sha256,m.base.sha256);assert.equal(observed.identity.artifacts.runtime.sha256,m.runtime.sha256);
   assert.deepEqual(fixtures(observed),fixtures(expected));assert.deepEqual(observed.inputHashes,expected.inputHashes);assert.deepEqual(observed.inputPaths,expected.inputPaths);
   row.differences=exactRows(expected.results,observed.results);row.summary=observed.summary;row.fullConformance=observed.complete;row.workerStats=observed.workers;save();assert.equal(row.differences.length,0,'Artifact changed frontend observations or exact verdicts');
   const byWorker=new Map(observed.results.map(r=>[r.worker.session+'::'+r.worker.index,r]));assert.equal(byWorker.size,2756);let total=0;
   row.histories=walk(observedFile+'.artifacts').filter(f=>/\/worker-\d+\/session-\d+\.json$/.test(f)).map(file=>{
    const s=read(file);assert.equal(s.closed,true);assert.ok(s.requests.length>=1&&s.requests.length<=64);
    for(let i=0;i<s.requests.length;i++){const entry=s.requests[i],actual=byWorker.get(file+'::'+i);assert.ok(actual);assert.equal(entry.request.test.id,actual.id);assert.equal(entry.request.lane,actual.lane);assert.equal(entry.resultDigest,hash(JSON.stringify(actual.result)));total++;}
    const index=s.requests.length-1,request={...s.requests[index].request,workerSession:{file,index,prefixDigest:s.requests[index].prefixDigest}};assert.equal(replay.validatePersistentReplay(request,s,observed.host.workerNodeArgs),index);
    return {identity:identity(file),requests:s.requests.length,closed:true};
   });assert.equal(total,2756);row.histories.forEach(h=>verifyIdentity(h.identity));row.workerHistoriesVerified=true;verify();row.complete=true;
   }catch(error){row.error=String(error.stack??error);}
   row.finished=new Date().toISOString();save();await verifyShared();
  }
  await verifyShared();for(const row of report.rows){if(row.observations)verifyIdentity(row.observations);for(const h of row.histories??[])verifyIdentity(h.identity);}
  report.inputsVerified=true;report.complete=report.rows.length===2&&report.rows.every(row=>row.complete);if(!report.complete)report.error='At least one artifact did not pass the complete frontend gate; see retained per-artifact failures.';report.finished=new Date().toISOString();save();return report;
 }catch(error){report.error=String(error.stack??error);report.finished=new Date().toISOString();save();throw error;}
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){const [config,out,...extra]=process.argv.slice(2);if(!out||extra.length)throw Error('Usage: final-artifact-frontend.mjs CONFIG NEW_DIRECTORY');const r=await validate(config,out);if(!r.complete)process.exitCode=1;console.log(JSON.stringify({complete:r.complete,rows:r.rows.map(x=>({variant:x.variant,complete:x.complete,differences:x.differences?.length,wallMs:x.execution?.wallMs}))}));}
