// Schedule the existing frozen harness; do not alter compiler or probe logic.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {spawn} from 'node:child_process';

const sha=value=>createHash('sha256').update(value).digest('hex');
const identity=file=>({file:path.resolve(file),canonicalPath:fs.realpathSync(file),sha256:sha(fs.readFileSync(file))});
const verify=i=>assert.deepEqual(identity(i.file),i,'Changed input: '+i.file);
const write=(file,value)=>fs.writeFileSync(file,JSON.stringify(value,null,2)+'\n',{flag:'wx'});
const read=file=>JSON.parse(fs.readFileSync(file));
const walk=dir=>fs.readdirSync(dir,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(dir,e.name)):[path.join(dir,e.name)]);
const key=r=>r.id+'::'+r.lane;
const masks=text=>{assert.match(text,/^\d+(,\d+)*$/);const ids=text.split(',').map(Number);assert.equal(new Set(ids).size,ids.length);return ids;};
function processTree(pid){
 const result=[];
 function visit(id){try{const status=fs.readFileSync(`/proc/${id}/status`,'utf8'),stat=fs.readFileSync(`/proc/${id}/stat`,'utf8'),fields=stat.slice(stat.lastIndexOf(')')+2).split(' ');
  result.push({pid:id,startTicks:fields[19],rssKiB:Number(/^VmRSS:\s+(\d+)/m.exec(status)?.[1]??0),allowed:/^Cpus_allowed_list:\s+(.*)/m.exec(status)?.[1]??null});
  for(const child of fs.readFileSync(`/proc/${id}/task/${id}/children`,'utf8').trim().split(/\s+/).filter(Boolean))visit(Number(child));
 }catch(error){if(!['ENOENT','ESRCH'].includes(error.code))throw error;}}
 visit(pid);return result;
}
async function execute(command,args,{env,output,deadlineMs=3600000}={}){
 const stdout=fs.openSync(path.join(output,'stdout'),'wx'),stderr=fs.openSync(path.join(output,'stderr'),'wx');
 const started=new Date().toISOString(),clock=performance.now(),seen=new Map();let timedOut=false,overflow=false,peakLiveRssKiB=0,samples=0;
 const child=await new Promise(resolve=>{
  const p=spawn(command,args,{env,stdio:['ignore',stdout,stderr],detached:true});
  const sample=()=>{if(!p.pid)return;const rows=processTree(p.pid);samples++;peakLiveRssKiB=Math.max(peakLiveRssKiB,rows.reduce((n,r)=>n+r.rssKiB,0));for(const row of rows)seen.set(row.pid+':'+row.startTicks,row);};
  const kill=()=>{sample();for(const item of [...seen.values()].reverse()){const live=processTree(item.pid)[0];if(live?.startTicks===item.startTicks){try{process.kill(-item.pid,'SIGKILL');}catch{}try{process.kill(item.pid,'SIGKILL');}catch{}}}};
  const timer=setTimeout(()=>{timedOut=true;kill();},deadlineMs);
  const interval=setInterval(()=>{sample();if(fs.fstatSync(stdout).size+fs.fstatSync(stderr).size>4*1024*1024){overflow=true;kill();}},500);
  let settled=false;const done=value=>{if(settled)return;settled=true;clearTimeout(timer);clearInterval(interval);resolve(value);};
  p.once('error',error=>done({error:String(error),status:null,signal:null}));p.once('close',(status,signal)=>done({status,signal}));
 });
 const bytes=fs.fstatSync(stdout).size+fs.fstatSync(stderr).size;overflow ||= bytes>4*1024*1024;fs.closeSync(stdout);fs.closeSync(stderr);
 return {command,args,...child,started,finished:new Date().toISOString(),wallMs:performance.now()-clock,timedOut,overflow,logBytes:bytes,
  resourceObservation:{sampleIntervalMs:500,samples,peakSampledLiveRssKiB:peakLiveRssKiB,processes:[...seen.values()],scope:'Sampled sum of live runner/descendant RSS, excluding this supervisor; not an exact OS peak.'}};
}
function assertHealthy(report){
 assert.equal(report.changedInputs.length,0);assert.equal(report.identity.changedArtifacts.length,0);assert.equal(report.identity.adapterChangedDuringRun,false);
 assert.ok(report.workers?.length&&report.workers.every(w=>w.errors.length===0));
 assert.ok(report.results.every(r=>!['crash','timeout','unsupported'].includes(r.status)&&!['crash','timeout','unsupported'].includes(r.result?.status)));
 assert.equal(new Set(report.results.map(key)).size,report.results.length);
}
const [mode,...args]=process.argv.slice(2);
if(mode==='prepare'){
 const [configArg,outputArg]=args;if(!outputArg||args.length!==2)throw Error('Usage: frontend-scheduling.mjs prepare CONFIG NEW_SNAPSHOT');
 const configFile=fs.realpathSync(configArg),config=read(configFile),resolve=p=>fs.realpathSync(path.resolve(path.dirname(configFile),p));
 const out=path.resolve(outputArg);fs.mkdirSync(out,{recursive:false});
 const source=resolve(config.completedSweep),historical=resolve(config.historicalReport),api=resolve(config.api),provenance=resolve(config.provenance),base=resolve(config.base),runtime=resolve(config.runtime),upstream=resolve(config.upstream);
 const prior=read(historical);assertHealthy(prior);assert.equal(prior.inventory.total,1378);assert.equal(prior.results.length,2756);
 const proof=read(provenance);assert.equal(proof.kind,'phase4-checked-overlay');assert.equal(proof.complete,true);assert.equal(proof.inputsUnchanged,true);verify(proof.source);proof.inputs.forEach(verify);assert.equal(proof.api.sha256,identity(api).sha256);
 assert.equal(prior.identity.artifacts.compiler.sha256,identity(api).sha256);assert.equal(prior.identity.artifacts.runtime.sha256,identity(runtime).sha256);assert.equal(prior.identity.artifacts.base.sha256,identity(base).sha256);
 assert.equal(base,fs.realpathSync(path.join(upstream,'bend2/base.bend')));
 const originals=[configFile,import.meta.filename,process.execPath,historical,api,provenance,base,runtime,...walk(path.join(source,'harness')),...walk(path.join(source,'host/tools')),path.join(source,'frontend-adapter.mjs')].map(identity);
 fs.cpSync(path.join(source,'harness'),path.join(out,'harness'),{recursive:true});fs.cpSync(path.join(source,'host/tools'),path.join(out,'host/tools'),{recursive:true});
 fs.copyFileSync(path.join(source,'frontend-adapter.mjs'),path.join(out,'frontend-adapter.mjs'));fs.copyFileSync(import.meta.filename,path.join(out,'frontend-scheduling.mjs'));
 const cacheDirectory=path.join(out,'host/build/typed/cache');fs.mkdirSync(cacheDirectory,{recursive:true});let caches=0;
 for(const file of walk(resolve(config.seedCacheDirectory))){if(!path.basename(file).startsWith('base-')||!file.endsWith('.json'))continue;const c=read(file);
  if(c.compilerSha256!==identity(api).sha256||c.baseSha256!==identity(base).sha256)continue;
  assert.equal(c.version,2);assert.equal(c.sourcePath,base);assert.equal(c.validatedBy,'check_book');assert.equal(c.bookSha256,sha(JSON.stringify(c.book)));
  originals.push(identity(file));fs.copyFileSync(file,path.join(cacheDirectory,path.basename(file)));caches++;
 }assert.equal(caches,1,'Require exactly one matching validated cache');
 const frozen=walk(out).map(identity);originals.forEach(verify);frozen.forEach(verify);
 write(path.join(out,'snapshot.json'),{kind:'phase4-frontend-scheduling-snapshot',complete:true,created:new Date().toISOString(),config,api,provenance,base,runtime,upstream,historical,originals,frozen,
  node:{...identity(process.execPath),version:process.version},cachePolicy:'Same validated immutable warm cache for every schedule; any before/after byte or identity drift fails.',proofInputs:[proof.source,...proof.inputs]});
 console.log(JSON.stringify({complete:true,snapshot:out,frozen:frozen.length}));
}else if(mode==='run'){
 const [snapshotArg,jobsArg,cpuArg,outputArg,selectionArg,recycleArg]=args;if(!outputArg||args.length>6)throw Error('Usage: frontend-scheduling.mjs run SNAPSHOT JOBS CPU_LIST NEW_RUN [SELECTION_JSON|-] [RECYCLE]');
 const root=fs.realpathSync(snapshotArg),snapshotFile=path.join(root,'snapshot.json'),snapshot=read(snapshotFile),jobs=Number(jobsArg),cpus=masks(cpuArg),recycle=Number(recycleArg??64);
 assert.ok([1,4].includes(jobs));assert.ok([4,64].includes(recycle));assert.ok(cpus.length===1||cpus.length===4);assert.equal(snapshot.complete,true);assert.equal(process.version,snapshot.node.version);assert.equal(process.execPath,snapshot.node.file);
 const selection=selectionArg&&selectionArg!=='-'?fs.realpathSync(selectionArg):null;
 if(!selection){assert.equal(recycle,64);assert.equal(cpus.length,jobs,'Full scheduling comparison requires one physical CPU per worker');}
 const out=path.resolve(outputArg);fs.mkdirSync(out,{recursive:false});const inputs=[identity(snapshotFile),identity(import.meta.filename),...snapshot.originals,...snapshot.frozen,...snapshot.proofInputs,...(selection?[identity(selection)]:[])];inputs.forEach(verify);
 const expected=read(snapshot.historical),expectedMap=new Map(expected.results.map(r=>[key(r),r]));
 const env={...process.env,BEND_UPSTREAM:snapshot.upstream,BEND_BASE:snapshot.base,BEND_TYPED_API:snapshot.api,BEND_TYPED_RUNTIME:snapshot.runtime,BEND_TYPED_TRACE:'',NODE_OPTIONS:''};
 const reportFile=path.join(out,'observations.json'),common=['--upstream',snapshot.upstream,'--jobs',String(jobs),'--timeout','300000','--worker-mode','persistent','--recycle-after',String(recycle),'--rss-limit-mb','4096','--stack-kb','4096','--heap-mb','4096','--lanes','parse,check','--retain','failed','--adapter',path.join(root,'frontend-adapter.mjs'),'--output',reportFile,...(selection?['--selection',selection]:[])];
 const commandArgs=['-c',cpuArg,process.execPath,'--stack-size=4096','--max-old-space-size=4096',path.join(root,'harness/tools/conformance/run.mjs'),...common];
 const report={kind:'phase4-frontend-scheduling-run',complete:false,started:new Date().toISOString(),jobs,cpus,recycle,selection,inputs,
  scope:selection?'Focused schedule/history correctness, not a speed comparison.':'One-core versus four-core persistent frontend workflow; compiler algorithms unchanged. Complete observations do not imply full conformance.',
  topology:cpus.map(cpu=>({cpu,core:fs.readFileSync(`/sys/devices/system/cpu/cpu${cpu}/topology/core_id`,'utf8').trim(),package:fs.readFileSync(`/sys/devices/system/cpu/cpu${cpu}/topology/physical_package_id`,'utf8').trim()}))};
 write(path.join(out,'launch.json'),report);
 try{
  report.execution=await execute('taskset',commandArgs,{env,output:out,deadlineMs:3600000});write(path.join(out,'execution.json'),report.execution);
  assert.ok([0,1].includes(report.execution.status)&&!report.execution.error&&!report.execution.signal&&!report.execution.timedOut&&!report.execution.overflow,'Incomplete runner execution');
  const observed=read(reportFile);assertHealthy(observed);assert.equal(observed.workers.length,jobs);
  const fixtures=r=>r.inventory.tests.map(t=>[t.id,t.sha256]).sort((a,b)=>a[0].localeCompare(b[0]));
  assert.deepEqual(fixtures(observed),fixtures(expected),'Historical fixture bytes differ');
  const expectedCount=selection?(Array.isArray(read(selection))?read(selection):read(selection).cases).reduce((n,r)=>n+(r.lanes??[r.lane]).length,0):2756;
  assert.equal(observed.results.length,expectedCount);assert.equal(observed.inventory.total,1378);
  const differences=[];for(const row of observed.results){const old=expectedMap.get(key(row));assert.ok(old,'Unknown observation '+key(row));try{assert.deepEqual(row.result,old.result);assert.equal(row.status,old.status);assert.equal(row.reason,old.reason);assert.equal(row.evidence,old.evidence);}catch(error){differences.push({key:key(row),previous:old,current:row,error:String(error)});}}
  report.differences=differences;report.observations=identity(reportFile);report.probeCount=observed.results.length;report.summary=observed.summary;report.workerStats=observed.workers;report.fullConformance=observed.complete;
  report.histories=walk(reportFile+'.artifacts').filter(f=>/\/worker-\d+\/session-\d+\.json$/.test(f)).map(file=>{const s=read(file);return {identity:identity(file),requests:s.requests.length,closed:s.closed,closeReason:s.closeReason};});
  assert.ok(report.histories.every(s=>s.closed&&s.requests<=recycle));
  assert.equal(report.histories.reduce((n,s)=>n+s.requests,0),expectedCount);
  inputs.forEach(verify);report.inputsVerified=true;assert.equal(differences.length,0,'Worker scheduling changed exact observations');report.complete=true;report.finished=new Date().toISOString();
 }catch(error){report.error=String(error.stack);write(path.join(out,'report.json'),report);throw error;}
 write(path.join(out,'report.json'),report);console.log(JSON.stringify({complete:true,jobs,observations:report.probeCount,wallMs:report.execution.wallMs,peakSampledLiveRssKiB:report.execution.resourceObservation.peakSampledLiveRssKiB}));
}else throw Error('Expected prepare or run');
