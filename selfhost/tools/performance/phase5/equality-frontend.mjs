// ABBA full-frontend workflow comparison. Compiler/oracle/probe logic is reused
// unchanged; the derivative always retains separate verified lineage.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
import {verifyAttempt,identity,verifyIdentity,validatedCache,observationHealth} from '../../development/workflow.mjs';
import {verifyEqualityDerivation} from '../../development/equality.mjs';
import {supervise,requireExecution} from '../../development/process.mjs';
const read=f=>JSON.parse(fs.readFileSync(f)),write=(f,x)=>fs.writeFileSync(f,JSON.stringify(x,null,2)+'\n',{flag:'wx'}),hash=x=>createHash('sha256').update(x).digest('hex');
const walk=d=>fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(d,e.name)):[path.join(d,e.name)]),key=r=>r.id+'::'+r.lane;
export function exactRows(previous,current){
 const old=new Map(previous.map(r=>[key(r),r]));assert.equal(old.size,previous.length);assert.equal(new Set(current.map(key)).size,current.length);assert.equal(current.length,previous.length);
 const differences=[];for(const row of current){const prior=old.get(key(row));try{assert.ok(prior);assert.deepEqual(row.result,prior.result);for(const field of ['status','reason','evidence'])assert.equal(row[field],prior[field]);}catch(error){differences.push({key:key(row),previous:prior,current:row,error:String(error)});}}
 return differences;
}
function healthy(raw){assert.ok(observationHealth(raw),'Incomplete/failed infrastructure observations');assert.equal(raw.inventory.total,1378);assert.equal(raw.results.length,2756);assert.equal(raw.workers.length,4);assert.ok(raw.workers.every(w=>w.stats.failures===0&&w.stats.timeouts===0));}
const fixtures=r=>r.inventory.tests.map(t=>[t.id,t.sha256]).sort((a,b)=>a[0].localeCompare(b[0]));
const helperNames=['workflow','equality','process'];
async function prepare(configArg,outArg){
 const file=fs.realpathSync(configArg),config=read(file),relative=f=>fs.realpathSync(path.resolve(path.dirname(file),f)),out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
 assert.deepEqual(Object.keys(config).sort(),['attempt','comparison'].sort(),'Only verified attempt and completed small comparison are accepted');
 const attempt=relative(config.attempt),m=await verifyAttempt(attempt),comparisonFile=relative(config.comparison),comparison=read(comparisonFile);assert.equal(m.artifactKind,'checked-b1');assert.equal(comparison.kind,'phase5-maintained-equality-comparison');assert.equal(comparison.complete,true);assert.equal(comparison.inputsUnchanged,true);comparison.inputs.forEach(verifyIdentity);
 const derived=verifyEqualityDerivation(comparison.derivation.file);assert.equal(derived.metadata.original.api.sha256,m.api.sha256);assert.equal(derived.metadata.original.bootstrapReport.sha256,m.bootstrapReport.sha256);assert.equal(comparison.original.api.sha256,m.api.sha256);
 const historical=path.join(attempt,'validation-001/frontend.json'),raw=read(historical);healthy(raw);assert.equal(raw.identity.artifacts.compiler.sha256,m.api.sha256);assert.equal(raw.identity.artifacts.runtime.sha256,m.runtime.sha256);assert.equal(raw.identity.artifacts.base.sha256,m.base.sha256);
 const inputs=[],add=f=>{const item=identity(f);if(!inputs.some(x=>x.file===item.file))inputs.push(item);return item;};
 for(const f of [file,comparisonFile,historical,path.join(attempt,'attempt.json'),import.meta.filename,process.execPath,comparison.derivation.file,derived.api,derived.metadata.toolSnapshot.file,m.api.file,m.base.file,m.runtime.file,m.bootstrapReport.file])add(f);
 for(const name of helperNames)add(new URL('../../development/'+name+'.mjs',import.meta.url).pathname);add(new URL('../../conformance/inventory.mjs',import.meta.url).pathname);
 for(const item of derived.metadata.original.inputs){verifyIdentity(item);add(item.file);}
 const project=path.join(out,'project');fs.mkdirSync(project);
 for(const dir of ['src','tools']){
  const source=path.join(m.snapshot.root,dir),destination=path.join(project,dir);fs.cpSync(source,destination,{recursive:true});
  for(const f of walk(source)){const original=add(f),copy=add(path.join(destination,path.relative(source,f)));assert.equal(copy.sha256,original.sha256);}
 }
 const cacheDir=path.join(project,'build/typed/cache');fs.mkdirSync(cacheDir,{recursive:true});const caches=[];
 for(const api of [m.api.file,derived.api]){
  const prior=validatedCache(path.join(path.dirname(comparisonFile),'host/build/typed/cache'),api,m.base.file);add(prior.file);const target=path.join(cacheDir,path.basename(prior.file));fs.copyFileSync(prior.file,target);caches.push(validatedCache(cacheDir,api,m.base.file));add(target);
 }
 // Capture the actual launch/audit sources rather than a mutable future version.
 const launch=path.join(out,'equality-frontend.mjs.source');fs.copyFileSync(import.meta.filename,launch);add(launch);
 const report={kind:'phase5-equality-frontend-snapshot',complete:true,newBootstrap:false,created:new Date().toISOString(),attempt,project,upstream:m.config.upstream,base:m.base,runtime:m.runtime,checked:m.api,derived:identity(derived.api),derivation:identity(derived.report),originalBootstrap:m.bootstrapReport,historical:identity(historical),comparison:identity(comparisonFile),caches,inputs,node:{...identity(process.execPath),version:process.version},cachePolicy:'Untimed copies of separately validated API-specific Base caches from the completed small comparison; identical immutable cache bytes across all four schedules.'};
 inputs.forEach(verifyIdentity);await verifyAttempt(attempt);verifyEqualityDerivation(derived.report);write(path.join(out,'snapshot.json'),report);return report;
}
async function histories(file,observed,project){
 const byWorker=new Map(observed.results.map(r=>[r.worker.session+'::'+r.worker.index,r]));assert.equal(byWorker.size,2756);
 const replay=await import(pathToFileURL(path.join(project,'tools/conformance/persistent-probe.mjs')));let total=0;
 const rows=walk(file+'.artifacts').filter(f=>/\/worker-\d+\/session-\d+\.json$/.test(f)).map(f=>{
  const s=read(f);assert.equal(s.closed,true);assert.ok(s.requests.length>=1&&s.requests.length<=64);
  for(let i=0;i<s.requests.length;i++){const entry=s.requests[i],row=byWorker.get(f+'::'+i);assert.ok(row);assert.equal(entry.request.test.id,row.id);assert.equal(entry.request.lane,row.lane);assert.equal(entry.resultDigest,hash(JSON.stringify(row.result)));total++;}
  const index=s.requests.length-1,request={...s.requests[index].request,workerSession:{file:f,index,prefixDigest:s.requests[index].prefixDigest}};assert.equal(replay.validatePersistentReplay(request,s,observed.host.workerNodeArgs),index);
  return {identity:identity(f),requests:s.requests.length,closed:s.closed};
 });assert.equal(total,2756);return rows;
}
async function run(snapshotArg,outArg){
 const snapshotFile=fs.realpathSync(path.join(snapshotArg,'snapshot.json')),s=read(snapshotFile),out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
 assert.equal(s.kind,'phase5-equality-frontend-snapshot');assert.equal(s.complete,true);assert.equal(process.execPath,s.node.file);assert.equal(process.version,s.node.version);
 const inputs=[...s.inputs,identity(snapshotFile),identity(import.meta.filename),...helperNames.map(name=>identity(new URL('../../development/'+name+'.mjs',import.meta.url).pathname)),identity(new URL('../../conformance/inventory.mjs',import.meta.url).pathname)];
 const verify=async()=>{inputs.forEach(verifyIdentity);await verifyAttempt(s.attempt);verifyEqualityDerivation(s.derivation.file);};await verify();
 const topology=[0,1,2,3].map(cpu=>({cpu,core:fs.readFileSync(`/sys/devices/system/cpu/cpu${cpu}/topology/core_id`,'utf8').trim(),package:fs.readFileSync(`/sys/devices/system/cpu/cpu${cpu}/topology/physical_package_id`,'utf8').trim()}));assert.equal(new Set(topology.map(t=>t.package+':'+t.core)).size,4);
 const expected=read(s.historical.file),report={kind:'phase5-equality-full-frontend-comparison',complete:false,newBootstrap:false,started:new Date().toISOString(),inputs,topology,order:['checked','derived','derived','checked'],rows:[],scope:'Four-worker shared four-core full frontend workflow, exact raw results and known failures retained. No diagnostic normalization or claim of full language conformance.',resourceScope:'Per-worker request-reported RSS high water and harness statistics; not exact OS peak or aggregate process-tree RSS. Wall is the actual finite harness process, excluding preparation and post-run audit.'};
 const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
 try{
  for(let index=0;index<report.order.length;index++){
   await verify();const variant=report.order[index],api=s[variant],directory=path.join(out,index+'-'+variant);fs.mkdirSync(directory);const observedFile=path.join(directory,'observations.json');
   const env={...process.env};for(const k of Object.keys(env))if(k.startsWith('BEND_')||k==='NODE_OPTIONS')delete env[k];Object.assign(env,{BEND_UPSTREAM:s.upstream,BEND_BASE:s.base.file,BEND_TYPED_RUNTIME:s.runtime.file,BEND_TYPED_API:api.file,BEND_TYPED_TRACE:''});
   const args=['-c','0,1,2,3',process.execPath,'--stack-size=4096','--max-old-space-size=4096',path.join(s.project,'tools/conformance/run.mjs'),'--upstream',s.upstream,'--jobs','4','--timeout','300000','--worker-mode','persistent','--recycle-after','64','--rss-limit-mb','4096','--stack-kb','4096','--heap-mb','4096','--lanes','parse,check','--retain','failed','--adapter',path.join(s.project,'tools/conformance/adapters/typed.mjs'),'--output',observedFile];
   const row={index,variant,api,started:new Date().toISOString(),complete:false};report.rows.push(row);save();
   row.execution=await supervise('taskset',args,{directory:path.join(directory,'process'),env,timeoutMs:900000});save();requireExecution(row.execution,[0,1]);
   const observed=read(observedFile);row.observations=identity(observedFile);healthy(observed);assert.equal(observed.identity.artifacts.compiler.sha256,api.sha256);assert.equal(observed.identity.artifacts.base.sha256,s.base.sha256);assert.equal(observed.identity.artifacts.runtime.sha256,s.runtime.sha256);
   assert.deepEqual(fixtures(observed),fixtures(expected));assert.deepEqual(observed.inputHashes,expected.inputHashes);assert.deepEqual(observed.inputPaths,expected.inputPaths);
   row.differences=exactRows(expected.results,observed.results);row.summary=observed.summary;row.fullConformance=observed.complete;row.workerStats=observed.workers;row.maxWorkerRssBytes=Math.max(...observed.workers.map(w=>w.stats.maxRssBytes));save();assert.equal(row.differences.length,0,'Changed exact frontend observations');
   row.histories=await histories(observedFile,observed,s.project);row.workerHistoriesVerified=true;row.histories.forEach(h=>verifyIdentity(h.identity));await verify();row.complete=true;row.finished=new Date().toISOString();save();
  }
  for(const row of report.rows){verifyIdentity(row.observations);row.histories.forEach(h=>verifyIdentity(h.identity));}await verify();
  const wall=v=>report.rows.filter(r=>r.variant===v).map(r=>r.execution.wallMs),checked=wall('checked'),derived=wall('derived');
  report.measurement={checkedWallMs:checked,derivedWallMs:derived,checkedMeanWallMs:(checked[0]+checked[1])/2,derivedMeanWallMs:(derived[0]+derived[1])/2,pairReductionPercent:[100*(1-derived[0]/checked[0]),100*(1-derived[1]/checked[1])],wallReductionPercent:100*(1-(derived[0]+derived[1])/(checked[0]+checked[1]))};
  report.inputsVerified=true;report.complete=true;report.finished=new Date().toISOString();save();return report;
 }catch(error){report.error=String(error.stack??error);report.finished=new Date().toISOString();save();throw error;}
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){const [mode,input,out,...extra]=process.argv.slice(2);if(!out||extra.length||!['prepare','run'].includes(mode))throw Error('Usage: equality-frontend.mjs prepare CONFIG NEW_SNAPSHOT | run SNAPSHOT NEW_RUN');const report=await(mode==='prepare'?prepare(input,out):run(input,out));console.log(JSON.stringify({complete:report.complete,measurement:report.measurement}));}
