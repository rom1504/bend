// Phase 2 runtime boundary regressions, using unmodified pinned fixtures.
// Run with --stack-size=4096 --max-old-space-size=4096 and an explicit
// BEND_TYPED_API; BEND_UPSTREAM and CC select the reference tree/toolchain.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {execute,inspect,apiPath,runtimePath,driverPath,project} from '../tools/typed-driver.mjs';
import {nodeResourceArgs} from '../tools/node-resource-args.mjs';

const output=path.resolve(process.argv[2]||'build/phase2/runtime-regressions');
if(fs.existsSync(output))throw Error('Use a fresh output directory: '+output);
fs.mkdirSync(output,{recursive:true});
const upstream=path.resolve(process.env.BEND_UPSTREAM||'.bootstrap/upstream');
const sha=file=>crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const artifactFiles={compiler:apiPath,runtime:runtimePath,driver:driverPath,
  resourceArgs:path.join(project,'tools/node-resource-args.mjs'),
  nativeRuntime:path.join(project,'src/runtime/native/runtime.c')};
const identity=Object.fromEntries(Object.entries(artifactFiles).map(([k,file])=>[k,{file,sha256:sha(file)}]));
const rows=[];
const report={started:new Date().toISOString(),complete:false,node:process.version,
  runtimeNodeArgs:nodeResourceArgs(),identity,rows};
const save=()=>fs.writeFileSync(path.join(output,'report.json'),JSON.stringify(report,null,2)+'\n');
save();
for(const [id,expected,exitCode] of [
  ['reg/borrow_fork_hold.bend','2003000\n',0],
  ['io/stack_fault_trap.bend','bend: memory fault (machine stack overflow?)\n',1],
])for(const lane of ['interpreter','js','native']) {
  const file=path.join(upstream,'tests',id),workdir=path.join(output,id.replaceAll('/','-')+'-'+lane);
  fs.mkdirSync(workdir);
  const started=performance.now();
  const result=lane==='interpreter'?await inspect(file,{mode:lane,combinedOutput:true,timeoutMs:60000}):
    await execute(file,{backend:lane,workdir,combinedOutput:true,timeoutMs:60000});
  const row={id,lane,sourceSha256:sha(file),milliseconds:performance.now()-started,result};
  row.pass=result.checked===true&&result.phase==='runtime'&&result.exitCode===exitCode&&
    result.output===expected&&result.signal===null;
  rows.push(row);save();console.log(JSON.stringify({id,lane,pass:row.pass,milliseconds:row.milliseconds}));
}
for(const {file,sha256} of Object.values(identity))assert.equal(sha(file),sha256,'Artifact changed during validation: '+file);
report.complete=rows.every(r=>r.pass);report.finished=new Date().toISOString();save();
assert.equal(report.complete,true,'See retained report for failing probes.');
