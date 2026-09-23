// Correctness-only routing smoke before spending a full frontend sweep.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {identity,verifyIdentity,verifyAttempt,observationHealth} from '../../development/workflow.mjs';
import {supervise,requireExecution} from '../../development/process.mjs';
import {compareHostRows,semanticRow} from './base-memo-frontend.mjs';
const [snapshotArg,outArg]=process.argv.slice(2);if(!outArg)throw Error('Usage: base-memo-frontend-smoke.mjs SNAPSHOT NEW_OUTPUT');
const file=fs.realpathSync(path.join(snapshotArg,'snapshot.json')),s=JSON.parse(fs.readFileSync(file)),out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
const report={kind:'phase5-base-memo-frontend-routing-smoke',complete:false,timingClaim:false,started:new Date().toISOString(),inputs:[...s.inputs,identity(file),identity(import.meta.filename),identity(new URL('./base-memo-frontend.mjs',import.meta.url).pathname)],rows:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try{
 report.inputs.forEach(verifyIdentity);await verifyAttempt(s.attempt);
 const selection=path.join(out,'selection.json');fs.writeFileSync(selection,JSON.stringify({cases:['base/list_sort.bend','import/duplicate_name.bend','parse/invalid_assign_target.bend'].map(id=>({id,lanes:['parse','check']}))},null,2)+'\n');
 let original=null;
 for(const variant of ['control','memo']){
  const project=s.projects[variant],directory=path.join(out,variant);fs.mkdirSync(directory);const output=path.join(directory,'observations.json'),env={...process.env};
  for(const k of Object.keys(env))if(k.startsWith('BEND_')||k==='NODE_OPTIONS')delete env[k];Object.assign(env,{BEND_UPSTREAM:s.upstream,BEND_BASE:s.base.file,BEND_TYPED_RUNTIME:s.runtime.file,BEND_TYPED_API:s.api.file,BEND_TYPED_TRACE:''});
  const args=['-c','3',process.execPath,'--stack-size=4096','--max-old-space-size=4096',path.join(project,'tools/conformance/run.mjs'),'--upstream',s.upstream,'--jobs','1','--timeout','300000','--worker-mode','persistent','--recycle-after','64','--rss-limit-mb','4096','--stack-kb','4096','--heap-mb','4096','--selection',selection,'--lanes','parse,check','--retain','all','--adapter',path.join(project,'tools/conformance/adapters/typed.mjs'),'--output',output];
  const execution=await supervise('taskset',args,{directory:path.join(directory,'process'),env,timeoutMs:120000});requireExecution(execution,[0,1]);const raw=JSON.parse(fs.readFileSync(output));
  assert.ok(observationHealth(raw));assert.equal(raw.results.length,6);assert.equal(raw.workers.length,1);assert.equal(raw.workers[0].stats.starts,1);assert.equal(raw.workers[0].stats.requests,6);
  for(const row of raw.results)semanticRow(row,s.hostProvenance[variant]);
  if(original)assert.deepEqual(compareHostRows(original.results,raw.results,s.hostProvenance.control,s.hostProvenance.memo),[]);else original=raw;
  report.rows.push({variant,execution,observations:identity(output),summary:raw.summary,workerStats:raw.workers,hostProvenanceVerified:s.hostProvenance[variant]});save();
 }
 report.inputs.forEach(verifyIdentity);await verifyAttempt(s.attempt);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
report.finished=new Date().toISOString();save();console.log(JSON.stringify({complete:report.complete,error:report.error,timingClaim:false}));
