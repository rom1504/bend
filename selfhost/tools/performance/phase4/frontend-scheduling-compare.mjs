// Compare complete scheduling attempts and audit their actual worker histories.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const digest=x=>createHash('sha256').update(x).digest('hex');
const identity=file=>({file:path.resolve(file),canonicalPath:fs.realpathSync(file),sha256:digest(fs.readFileSync(file))});
const verify=i=>assert.deepEqual(identity(i.file),i,'Input changed: '+i.file);
const read=file=>JSON.parse(fs.readFileSync(file));
const [serialArg,parallelArg,outputArg]=process.argv.slice(2);
if(!outputArg||process.argv.length!==5)throw Error('Usage: frontend-scheduling-compare.mjs SERIAL_REPORT FOUR_WORKER_REPORT NEW_OUTPUT_JSON');
const output=path.resolve(outputArg);assert.ok(!fs.existsSync(output));
const inputs=[identity(serialArg),identity(parallelArg),identity(import.meta.filename),identity(process.execPath)];
const report={kind:'phase4-frontend-scheduling-comparison',complete:false,started:new Date().toISOString(),inputs,
 scope:'One-worker/one-core versus four-worker/four-core persistent workflow. Exact observations and worker histories required. Not a per-core compiler optimization or full conformance claim.'};
try{
 const attempts=[read(serialArg),read(parallelArg)],observations=[],focused=attempts[0].selection!==null;
 assert.equal(attempts[1].selection,attempts[0].selection);
 const expectedCount=focused?attempts[0].probeCount:2756;
 for(let i=0;i<attempts.length;i++){
  const run=attempts[i],jobs=i===0?1:4;
  assert.equal(run.kind,'phase4-frontend-scheduling-run');assert.equal(run.complete,true);assert.equal(run.inputsVerified,true);
  assert.equal(run.jobs,jobs);assert.equal(run.cpus.length,focused?1:jobs);assert.equal(run.recycle,focused?4:64);assert.equal(run.probeCount,expectedCount);assert.deepEqual(run.differences,[]);
  assert.equal(new Set(run.topology.map(c=>c.package+':'+c.core)).size,focused?1:jobs,'Repeated physical core');
  const affinity=text=>text.split(',').flatMap(part=>{const [first,last=first]=part.split('-').map(Number);assert.ok(Number.isSafeInteger(first)&&Number.isSafeInteger(last)&&last>=first&&last-first<65536);return Array.from({length:last-first+1},(_,n)=>first+n);}).sort((a,b)=>a-b);
  assert.ok(run.execution.resourceObservation.samples>0&&run.execution.resourceObservation.processes.length>0);
  for(const process of run.execution.resourceObservation.processes)assert.deepEqual(affinity(process.allowed),[...run.cpus].sort((a,b)=>a-b),'Observed worker CPU mask differs');
  run.inputs.forEach(verify);verify(run.observations);inputs.push(run.observations);
  assert.deepEqual(run.inputs,attempts[0].inputs,'Scheduling attempts consumed different artifacts');
  const observed=read(run.observations.file),rows=new Map(observed.results.map(r=>[r.worker.session+'::'+r.worker.index,r]));
  assert.equal(rows.size,expectedCount);assert.equal(observed.changedInputs.length,0);assert.equal(observed.identity.changedArtifacts.length,0);
  assert.ok(observed.workers.every(w=>w.errors.length===0&&w.stats.failures===0&&w.stats.timeouts===0));
  const snapshotPath=run.inputs[0].file;assert.equal(path.basename(snapshotPath),'snapshot.json');
  const historical=read(read(snapshotPath).historical);
  assert.deepEqual(observed.inputHashes,historical.inputHashes,'Historical imported/foreign/upstream inputs differ');
  assert.deepEqual(observed.inputPaths,historical.inputPaths,'Historical input resolutions differ');
  const replay=await import(pathToFileURL(path.join(path.dirname(snapshotPath),'harness/tools/conformance/persistent-probe.mjs')));
  let requests=0;
  for(const h of run.histories){
   verify(h.identity);inputs.push(h.identity);const s=read(h.identity.file);
   assert.equal(s.closed,true);assert.ok(s.requests.length>=1&&s.requests.length<=run.recycle);
   for(let index=0;index<s.requests.length;index++){
    const entry=s.requests[index],row=rows.get(h.identity.file+'::'+index);assert.ok(row,'Missing session observation');
    assert.equal(entry.request.test.id,row.id);assert.equal(entry.request.lane,row.lane);
    assert.equal(entry.resultDigest,digest(JSON.stringify(row.result)),'Session result differs from reported observation');requests++;
   }
   const index=s.requests.length-1,request={...s.requests[index].request,workerSession:{file:h.identity.file,index,prefixDigest:s.requests[index].prefixDigest}};
   assert.equal(replay.validatePersistentReplay(request,s,observed.host.workerNodeArgs),index);
  }
  assert.equal(requests,expectedCount);observations.push(new Map(observed.results.map(r=>[r.id+'::'+r.lane,r])));
 }
 assert.deepEqual([...observations[0].keys()].sort(),[...observations[1].keys()].sort());
 for(const [key,a] of observations[0]){const b=observations[1].get(key);assert.deepEqual(a.result,b.result,key);for(const field of ['status','reason','evidence'])assert.equal(a[field],b[field],key+' '+field);}
 report.fixtureCount=focused?new Set([...observations[0].values()].map(r=>r.id)).size:1378;report.probeCount=expectedCount;report.workerHistoriesVerified=true;
 report.attempts=attempts.map((r,i)=>({schedule:i===0?'one-worker-one-core':'four-workers-four-cores',jobs:r.jobs,cpus:r.cpus,topology:r.topology,started:r.execution.started,finished:r.execution.finished,wallMs:r.execution.wallMs,peakSampledLiveRssKiB:r.execution.resourceObservation.peakSampledLiveRssKiB,workerStats:r.workerStats,historyCount:r.histories.length,summary:r.summary,fullConformance:r.fullConformance}));
 if(focused)report.scope='Focused schedule/recycling parity with both schedules on one CPU. No speed ratio is asserted.';
 else {report.wallSpeedRatio=attempts[0].execution.wallMs/attempts[1].execution.wallMs;report.wallReductionPercent=100*(1-attempts[1].execution.wallMs/attempts[0].execution.wallMs);}
 inputs.forEach(verify);report.inputsVerified=true;report.complete=true;report.finished=new Date().toISOString();
}catch(error){report.error=String(error.stack);fs.writeFileSync(output,JSON.stringify(report,null,2)+'\n',{flag:'wx'});throw error;}
fs.writeFileSync(output,JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:true,wallSpeedRatio:report.wallSpeedRatio,probeCount:report.probeCount,workerHistoriesVerified:true}));
