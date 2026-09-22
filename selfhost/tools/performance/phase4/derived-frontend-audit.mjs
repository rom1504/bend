// Read-only audit: no compiler import, request execution, or new timing claim.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {nativeB1Equality} from './analysis-b1-equality.mjs';
const hash=x=>createHash('sha256').update(x).digest('hex');
const identity=file=>({file:path.resolve(file),canonicalPath:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))});
const verify=i=>assert.deepEqual(identity(i.file),i,'Changed input: '+i.file);
const read=file=>JSON.parse(fs.readFileSync(file));
const [runArg,outArg]=process.argv.slice(2);
if(!outArg||process.argv.length!==4)throw Error('Usage: derived-frontend-audit.mjs DERIVED_FRONTEND_REPORT NEW_AUDIT_REPORT');
const output=path.resolve(outArg);assert.ok(!fs.existsSync(output));
const report={kind:'experimental-derived-frontend-audit',complete:false,newBootstrap:false,started:new Date().toISOString(),inputs:[identity(runArg),identity(import.meta.filename),identity(process.execPath),identity(path.join(import.meta.dirname,'analysis-b1-equality.mjs')),identity(path.join(import.meta.dirname,'../../private-compiler/common.mjs'))]};
try{
 const run=read(runArg);assert.equal(run.kind,'experimental-derived-frontend');assert.equal(run.complete,true);assert.equal(run.newBootstrap,false);assert.equal(run.inputsVerified,true);assert.equal(run.workerHistoriesVerified,true);assert.equal(run.probeCount,2756);assert.deepEqual(run.differences,[]);
 run.inputs.forEach(verify);verify(run.originalCheckedProof);verify(run.control);verify(run.candidate);verify(run.cache);verify(run.observations);report.inputs.push(...run.inputs,run.originalCheckedProof,run.control,run.candidate,run.cache,run.observations);
 const proof=read(run.originalCheckedProof.file);assert.equal(proof.kind,'phase4-checked-overlay');assert.equal(proof.complete,true);assert.equal(proof.inputsUnchanged,true);assert.equal(proof.api.sha256,run.control.sha256);verify(proof.source);proof.inputs.forEach(verify);report.inputs.push(proof.source,...proof.inputs);
 assert.equal(hash(nativeB1Equality(fs.readFileSync(run.control.file,'utf8')).source),run.candidate.sha256,'Derived bytes are not the exact reviewed transformation');
 const snapshotEntry=run.inputs.find(i=>path.basename(i.file)==='snapshot.json');assert.ok(snapshotEntry);const snapshot=read(snapshotEntry.file);const historicalIdentity=identity(snapshot.historical);report.inputs.push(historicalIdentity);
 const expected=read(snapshot.historical),observed=read(run.observations.file);assert.equal(observed.results.length,2756);assert.equal(observed.inventory.total,1378);assert.equal(observed.workers.length,4);assert.deepEqual(observed.summary,expected.summary);
 assert.equal(observed.identity.artifacts.compiler.sha256,run.candidate.sha256);assert.equal(observed.identity.artifacts.base.sha256,identity(snapshot.base).sha256);assert.equal(observed.identity.artifacts.runtime.sha256,identity(snapshot.runtime).sha256);
 assert.equal(observed.identity.adapterChangedDuringRun,false);assert.deepEqual(observed.identity.changedArtifacts,[]);assert.deepEqual(observed.changedInputs,[]);assert.ok(observed.workers.every(w=>w.errors.length===0&&w.stats.failures===0&&w.stats.timeouts===0));
 assert.deepEqual(observed.inputHashes,expected.inputHashes);assert.deepEqual(observed.inputPaths,expected.inputPaths);
 for(const [file,sha256]of Object.entries(observed.inputHashes)){assert.equal(hash(fs.readFileSync(file)),sha256,'Changed corpus input '+file);assert.equal(fs.realpathSync(file),observed.inputPaths[file]);report.inputs.push(identity(file));}
 const fixtures=r=>r.inventory.tests.map(t=>[t.id,t.sha256]).sort((a,b)=>a[0].localeCompare(b[0]));assert.deepEqual(fixtures(observed),fixtures(expected));
 const key=r=>r.id+'::'+r.lane,prior=new Map(expected.results.map(r=>[key(r),r]));assert.equal(prior.size,2756);
 const rows=new Map(observed.results.map(r=>[r.worker.session+'::'+r.worker.index,r]));assert.equal(rows.size,2756);assert.equal(new Set(observed.results.map(key)).size,2756);
 for(const row of observed.results){const old=prior.get(key(row));assert.ok(old);assert.deepEqual(row.result,old.result,key(row));for(const field of ['status','reason','evidence'])assert.equal(row[field],old[field],key(row)+' '+field);}
 const root=path.dirname(path.resolve(runArg)),replayFile=path.join(root,'harness/tools/conformance/persistent-probe.mjs');report.inputs.push(identity(replayFile));const replay=await import(pathToFileURL(replayFile));let requests=0;
 for(const h of run.histories){verify(h.identity);report.inputs.push(h.identity);const session=read(h.identity.file);assert.equal(session.closed,true);assert.ok(session.requests.length>=1&&session.requests.length<=64);
  for(let index=0;index<session.requests.length;index++){const entry=session.requests[index],row=rows.get(h.identity.file+'::'+index);assert.ok(row);assert.equal(entry.request.test.id,row.id);assert.equal(entry.request.lane,row.lane);assert.equal(entry.resultDigest,hash(JSON.stringify(row.result)));requests++;}
  const index=session.requests.length-1,request={...session.requests[index].request,workerSession:{file:h.identity.file,index,prefixDigest:session.requests[index].prefixDigest}};assert.equal(replay.validatePersistentReplay(request,session,observed.host.workerNodeArgs),index);
 }assert.equal(requests,2756);
 const affinity=text=>text.split(',').flatMap(x=>{const[a,b=a]=x.split('-').map(Number);assert.ok(Number.isSafeInteger(a)&&Number.isSafeInteger(b)&&b>=a&&b-a<65536);return Array.from({length:b-a+1},(_,i)=>a+i);}).sort((a,b)=>a-b);
 assert.ok(run.execution.resourceObservation.samples>0);for(const p of run.execution.resourceObservation.processes)assert.deepEqual(affinity(p.allowed),[0,1,2,3]);
 assert.ok([0,1].includes(run.execution.status)&&!run.execution.error&&!run.execution.signal&&!run.execution.timedOut&&!run.execution.overflow);
 report.inputs.forEach(verify);Object.assign(report,{complete:true,inputsVerified:true,probeCount:2756,inputMappings:Object.keys(observed.inputHashes).length,historyCount:run.histories.length,workerHistoriesVerified:true,summary:observed.summary,fullConformance:observed.complete,control:run.control,candidate:run.candidate,originalCheckedProof:run.originalCheckedProof,scope:'Exact raw results/verdicts, corpus inputs and actual worker histories. Candidate remains an experimental derived image; the original checked proof covers the control only. No compiler was executed and no performance ratio is asserted.'});
}catch(error){report.error=String(error.stack);process.exitCode=1;}
report.finished=new Date().toISOString();fs.writeFileSync(output,JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:report.complete,newBootstrap:false,probes:report.probeCount,histories:report.historyCount,error:report.error}));
