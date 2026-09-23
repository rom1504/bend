// Supervise the unchanged paired harness with a verified isolated candidate.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {verifyAttempt,identity,verifyIdentity} from '../../development/workflow.mjs';
import {supervise,requireExecution} from '../../development/process.mjs';
const read=f=>JSON.parse(fs.readFileSync(f));
const [attempt,selection,destination]=process.argv.slice(2),out=path.resolve(destination);
const m=await verifyAttempt(path.resolve(attempt));fs.mkdirSync(out,{recursive:false});
const config={upstream:m.config.upstream,selection:fs.realpathSync(selection),jobs:1,
  workerMode:'isolated',rssLimitMb:4096,heapMb:4096,stackKb:4096,timeoutMs:60000,
  retain:'all',cpu:3,candidateAdapter:path.join(m.snapshot.root,'tools/conformance/adapters/typed.mjs')};
const configFile=path.join(out,'target.json');fs.writeFileSync(configFile,JSON.stringify(config,null,2)+'\n',{flag:'wx'});
const inputs=[identity(import.meta.filename),identity(configFile),identity(selection),m.api,m.runtime,m.base,
  ...m.snapshot.sources.map(x=>x.frozen)];
const env={...process.env};for(const k of Object.keys(env))if(k.startsWith('BEND_')||k==='NODE_OPTIONS')delete env[k];
Object.assign(env,{BEND_UPSTREAM:m.config.upstream,BEND_BASE:m.base.file,BEND_TYPED_API:m.api.file,
  BEND_TYPED_RUNTIME:m.runtime.file,BEND_TYPED_TRACE:'1'});
const report={kind:'phase6-native-scalar-paired-gate',started:new Date().toISOString(),complete:false,
  pass:false,api:m.api,inputs,scope:'Selected actual JS/native execution. Concurrent correctness; no controlled speed claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try {
  const paired=path.join(out,'paired');
  report.execution=await supervise('taskset',['-c','3',process.execPath,'--stack-size=4096','--max-old-space-size=4096',
    path.join(m.snapshot.root,'tools/conformance/target.mjs'),configFile,paired],
    {directory:path.join(out,'process'),env,timeoutMs:900000});save();
  requireExecution(report.execution,[0,1]);
  report.paired=identity(path.join(paired,'paired.json'));
  const p=read(report.paired.file);report.observations=p.rows.length;report.missing=p.missing;
  report.exactDifferences=p.rows.filter(x=>!x.exactAgreement).length;
  report.verdictCounts=Object.fromEntries(['referenceVerdict','candidateVerdict'].map(k=>[k,p.rows.reduce((a,x)=>(a[x[k]]=(a[x[k]]||0)+1,a),{})]));
  inputs.forEach(verifyIdentity);await verifyAttempt(path.resolve(attempt));report.inputsVerified=true;
  report.complete=Boolean(p.finished)&&p.missing.length===0;report.pass=report.complete&&p.selectedComplete;
  report.finished=new Date().toISOString();save();assert.equal(report.pass,true);
  console.log(JSON.stringify({report:path.join(out,'report.json'),observations:report.observations,exactDifferences:report.exactDifferences}));
} catch(error) {report.error=String(error.stack??error);report.finished=new Date().toISOString();save();throw error;}
