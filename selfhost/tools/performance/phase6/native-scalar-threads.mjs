// Reexecute the actual retained compiler outputs with two scheduler settings.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {identity,verifyIdentity} from '../../development/workflow.mjs';
import {supervise,requireExecution} from '../../development/process.mjs';
const [pairedDirectory,destination]=process.argv.slice(2),paired=fs.realpathSync(pairedDirectory),out=path.resolve(destination);
fs.mkdirSync(out,{recursive:false});
const inputs=[identity(import.meta.filename)],jobs=[];
for(const variant of ['reference','candidate']) {
  const file=path.join(paired,variant+'.json'),r=JSON.parse(fs.readFileSync(file));inputs.push(identity(file));
  assert.ok(r.finished);assert.equal(r.changedInputs.length,0);assert.equal(r.identity.changedArtifacts.length,0);
  for(const row of r.results) {
    assert.equal(row.lane,'native');assert.equal(row.status,'pass');assert.equal(row.result.status,'ok');assert.equal(row.result.checked,true);
    const binary=path.join(row.artifacts,'program'),source=path.join(row.artifacts,'program.c');
    inputs.push(identity(binary),identity(source));
    for(const threads of [1,4])jobs.push({variant,id:row.id,threads,binary,expected:row.result.output??row.result.stdout});
  }
}
const report={kind:'phase6-native-scalar-thread-reexecution',started:new Date().toISOString(),complete:false,pass:false,inputs,rows:[],
  scope:'Actual retained binaries, one/four scheduler workers, CPU3 affinity; no performance or GPU claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();const start=performance.now();
try {
  for(const [i,job] of jobs.entries()) {
    const remaining=300000-(performance.now()-start);assert.ok(remaining>0);
    const execution=await supervise('taskset',['-c','3',job.binary,'--threads',String(job.threads),'--gpu','off'],
      {directory:path.join(out,String(i)),env:process.env,timeoutMs:Math.min(10000,Math.floor(remaining))});
    const actual=fs.readFileSync(execution.stdout,'utf8'),stderr=fs.readFileSync(execution.stderr,'utf8');
    report.rows.push({...job,execution,actual,stderr});save();requireExecution(execution);assert.equal(actual,job.expected);assert.equal(stderr,'');
  }
  inputs.forEach(verifyIdentity);report.complete=true;report.pass=true;report.inputsVerified=true;report.finished=new Date().toISOString();save();
  console.log(JSON.stringify({report:path.join(out,'report.json'),executions:report.rows.length,pass:true}));
} catch(error) {report.error=String(error.stack??error);report.finished=new Date().toISOString();save();throw error;}
