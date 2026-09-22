// Experimental derived-B1 gate: preserve the original proof, never fabricate one.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {spawn} from 'node:child_process';
import {pathToFileURL} from 'node:url';
import {nativeB1Equality,reviewedB1} from './analysis-b1-equality.mjs';
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

const [preparationArg,snapshotArg,outputArg,cpuArg='0,1,2,3']=process.argv.slice(2);
if(!outputArg||process.argv.length>6)throw Error('Usage: derived-frontend.mjs PREPARATION_REPORT CHECKED_SCHEDULER_SNAPSHOT NEW_OUTPUT [CPU_LIST]');
const out=path.resolve(outputArg);fs.mkdirSync(out,{recursive:false});
const preparationFile=fs.realpathSync(preparationArg),snapshotFile=fs.realpathSync(path.join(snapshotArg,'snapshot.json'));
const report={kind:'experimental-derived-frontend',complete:false,newBootstrap:false,started:new Date().toISOString(),
 scope:'Exact full frontend gate for a guarded experimental JavaScript-derived B1. The original checked proof covers only the unmodified control. No new bootstrap or performance claim.',
 inputs:[identity(preparationFile),identity(snapshotFile),identity(import.meta.filename),identity(path.join(import.meta.dirname,'analysis-b1-equality.mjs')),identity(path.join(import.meta.dirname,'../../private-compiler/common.mjs')),identity(process.execPath)]};
try{
 const preparation=read(preparationFile),snapshot=read(snapshotFile),root=path.dirname(snapshotFile),cpus=masks(cpuArg);
 assert.equal(cpus.length,4);assert.equal(new Set(cpus.map(cpu=>fs.readFileSync(`/sys/devices/system/cpu/cpu${cpu}/topology/physical_package_id`,'utf8').trim()+':'+fs.readFileSync(`/sys/devices/system/cpu/cpu${cpu}/topology/core_id`,'utf8').trim())).size,4);
 assert.equal(preparation.kind,'phase4-b1-native-equality-preparation');assert.equal(preparation.complete,true);assert.equal(preparation.newBootstrap,false);assert.equal(preparation.inputsUnchanged,true);
 preparation.inputs.forEach(verify);assert.equal(preparation.variants.length,2);
 const control=preparation.variants.find(v=>v.id==='control'),candidate=preparation.variants.find(v=>v.id==='candidate');assert.ok(control&&candidate);
 for(const item of [control,candidate])assert.deepEqual(identity(item.file),{file:item.file,canonicalPath:item.canonicalPath,sha256:item.sha256});
 assert.equal(control.sha256,reviewedB1);assert.equal(sha(nativeB1Equality(fs.readFileSync(control.file,'utf8')).source),candidate.sha256,'Derived API does not reproduce exact reviewed transformation');
 assert.equal(snapshot.complete,true);assert.equal(identity(snapshot.api).sha256,control.sha256);assert.equal(process.execPath,snapshot.node.file);assert.equal(process.version,snapshot.node.version);
 const proof=read(snapshot.provenance);assert.equal(proof.kind,'phase4-checked-overlay');assert.equal(proof.complete,true);assert.equal(proof.inputsUnchanged,true);assert.equal(proof.api.sha256,control.sha256);
 report.originalCheckedProof=identity(snapshot.provenance);report.control=identity(control.file);report.candidate=identity(candidate.file);report.transformation=preparation.stats;
 report.inputs.push(...preparation.inputs,...snapshot.originals,...snapshot.frozen,...snapshot.proofInputs,report.control,report.candidate);report.inputs.forEach(verify);
 const historical=read(snapshot.historical);assertHealthy(historical);assert.equal(historical.results.length,2756);
 fs.cpSync(path.join(root,'harness'),path.join(out,'harness'),{recursive:true});fs.cpSync(path.join(root,'host/tools'),path.join(out,'host/tools'),{recursive:true});fs.copyFileSync(path.join(root,'frontend-adapter.mjs'),path.join(out,'frontend-adapter.mjs'));
 const copies=[...walk(path.join(out,'harness')),...walk(path.join(out,'host/tools')),path.join(out,'frontend-adapter.mjs')].map(identity);report.inputs.push(...copies);
 const env={...process.env,BEND_UPSTREAM:snapshot.upstream,BEND_BASE:snapshot.base,BEND_TYPED_API:candidate.file,BEND_TYPED_RUNTIME:snapshot.runtime,BEND_TYPED_TRACE:'',NODE_OPTIONS:''};
 const primeDir=path.join(out,'prime');fs.mkdirSync(primeDir);report.priming=await execute('taskset',['-c',String(cpus[0]),process.execPath,'--stack-size=4096','--max-old-space-size=4096',path.join(out,'host/tools/typed-driver.mjs'),'--prepare-base'],{env,output:primeDir,deadlineMs:180000});
 assert.equal(report.priming.status,0);assert.ok(!report.priming.error&&!report.priming.signal&&!report.priming.timedOut&&!report.priming.overflow);
 const caches=walk(path.join(out,'host/build/typed/cache')).filter(f=>path.basename(f).startsWith('base-')&&f.endsWith('.json'));assert.equal(caches.length,1);
 const cache=read(caches[0]);assert.equal(cache.version,2);assert.equal(cache.compilerSha256,candidate.sha256);assert.equal(cache.baseSha256,identity(snapshot.base).sha256);assert.equal(cache.sourcePath,fs.realpathSync(snapshot.base));assert.equal(cache.validatedBy,'check_book');assert.equal(cache.bookSha256,sha(JSON.stringify(cache.book)));
 report.cache=identity(caches[0]);report.inputs.push(report.cache);report.inputs.forEach(verify);
 const runDir=path.join(out,'run');fs.mkdirSync(runDir);const observationsFile=path.join(runDir,'observations.json');
 const args=['-c',cpuArg,process.execPath,'--stack-size=4096','--max-old-space-size=4096',path.join(out,'harness/tools/conformance/run.mjs'),'--upstream',snapshot.upstream,'--jobs','4','--timeout','300000','--worker-mode','persistent','--recycle-after','64','--rss-limit-mb','4096','--stack-kb','4096','--heap-mb','4096','--lanes','parse,check','--retain','failed','--adapter',path.join(out,'frontend-adapter.mjs'),'--output',observationsFile];
 write(path.join(out,'launch.json'),report);report.execution=await execute('taskset',args,{env,output:runDir,deadlineMs:900000});
 assert.ok([0,1].includes(report.execution.status)&&!report.execution.error&&!report.execution.signal&&!report.execution.timedOut&&!report.execution.overflow);
 const observed=read(observationsFile);assertHealthy(observed);assert.equal(observed.identity.artifacts.compiler.sha256,candidate.sha256);assert.equal(observed.identity.artifacts.base.sha256,identity(snapshot.base).sha256);assert.equal(observed.identity.artifacts.runtime.sha256,identity(snapshot.runtime).sha256);assert.equal(observed.results.length,2756);assert.equal(observed.inventory.total,1378);assert.equal(observed.workers.length,4);assert.ok(observed.workers.every(w=>w.stats.failures===0&&w.stats.timeouts===0));
 const fixtureRows=r=>r.inventory.tests.map(t=>[t.id,t.sha256]).sort((a,b)=>a[0].localeCompare(b[0]));assert.deepEqual(fixtureRows(observed),fixtureRows(historical));assert.deepEqual(observed.inputHashes,historical.inputHashes);assert.deepEqual(observed.inputPaths,historical.inputPaths);
 const old=new Map(historical.results.map(r=>[key(r),r]));report.differences=[];
 for(const row of observed.results){try{const prior=old.get(key(row));assert.ok(prior);assert.deepEqual(row.result,prior.result);for(const field of ['status','reason','evidence'])assert.equal(row[field],prior[field]);}catch(error){report.differences.push({key:key(row),previous:old.get(key(row)),current:row,error:String(error)});}}
 const rows=new Map(observed.results.map(r=>[r.worker.session+'::'+r.worker.index,r]));assert.equal(rows.size,2756);
 const replay=await import(pathToFileURL(path.join(out,'harness/tools/conformance/persistent-probe.mjs')));let requests=0;
 report.histories=walk(observationsFile+'.artifacts').filter(f=>/\/worker-\d+\/session-\d+\.json$/.test(f)).map(file=>{
  const session=read(file);assert.equal(session.closed,true);assert.ok(session.requests.length>=1&&session.requests.length<=64);
  for(let index=0;index<session.requests.length;index++){const entry=session.requests[index],row=rows.get(file+'::'+index);assert.ok(row);assert.equal(entry.request.test.id,row.id);assert.equal(entry.request.lane,row.lane);assert.equal(entry.resultDigest,sha(JSON.stringify(row.result)));requests++;}
  const index=session.requests.length-1,request={...session.requests[index].request,workerSession:{file,index,prefixDigest:session.requests[index].prefixDigest}};assert.equal(replay.validatePersistentReplay(request,session,observed.host.workerNodeArgs),index);
  return {identity:identity(file),requests:session.requests.length,closed:true};
 });assert.equal(requests,2756);
 report.observations=identity(observationsFile);report.summary=observed.summary;report.fullConformance=observed.complete;report.workerStats=observed.workers;report.probeCount=2756;report.workerHistoriesVerified=true;
 report.inputs.forEach(verify);verify(report.observations);report.histories.forEach(h=>verify(h.identity));report.inputsVerified=true;assert.equal(report.differences.length,0,'Derived API changed full frontend observations');report.complete=true;
}catch(error){report.error=String(error.stack);process.exitCode=1;}
report.finished=new Date().toISOString();write(path.join(out,'report.json'),report);console.log(JSON.stringify({kind:report.kind,complete:report.complete,newBootstrap:false,probeCount:report.probeCount,error:report.error}));
