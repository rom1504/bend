// Native executable transport only. No JavaScript compiler API is imported.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {spawnSync} from 'node:child_process';

const planPath=path.resolve(process.env.BEND_NATIVE_CONFORMANCE_PLAN||'');
const role=process.env.BEND_NATIVE_CONFORMANCE_ROLE;
export const plan=JSON.parse(fs.readFileSync(planPath,'utf8'));
assert.equal(plan.kind,'phase92-native-conformance-plan');
assert.equal(plan.targetReady,true);
assert.ok(['b1','b2'].includes(role));
const selected=plan.roles[role];
const executionInputs=plan.executionInputs[role];
assert.ok(Array.isArray(executionInputs)&&executionInputs.length>0);
export const name='phase92-native-host-'+role;
export const capabilities={parse:false,check:false,interpreter:false,js:false,native:true,
  metal:false,cuda:false,modules:false,foreign:'pinned-nine-Base-providers',
  dependentTypes:true,affine:true,termination:true,proofs:true,proofKernel:false};
export const artifacts=Object.fromEntries([
  ['plan',planPath],...executionInputs.map((p,i)=>['input/'+i,p.file])]);
export const inputFiles=executionInputs.map(p=>p.file);
const hash=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
export function pin(file) {
  const bytes=fs.readFileSync(file);
  return {file:path.resolve(file),sha256:hash(bytes),bytes:bytes.length};
}
const initialPlan=pin(planPath);
export function verifyInputs() {
  assert.deepEqual(pin(planPath),initialPlan,'Plan changed');
  for(const p of executionInputs)assert.deepEqual(pin(p.file),p,'Input changed: '+p.file);
}
verifyInputs();

function capture(command,cwd,stem,timeoutMs,combined=false) {
  const stdout=path.join(cwd,stem+'.stdout'),stderr=path.join(cwd,stem+'.stderr');
  const a=fs.openSync(stdout,'wx'),b=combined?a:fs.openSync(stderr,'wx');
  let job;
  try { job=spawnSync(command[0],command.slice(1),{cwd,env:plan.environment,
    timeout:Math.max(1,Math.floor(timeoutMs)),stdio:['ignore',a,b]}); }
  finally { fs.closeSync(a);if(b!==a)fs.closeSync(b); }
  const files=[stdout,...combined?[]:[stderr]];
  const oversized=files.some(f=>fs.statSync(f).size>2**20);
  return {command,status:job.status,signal:job.signal,error:job.error?.message||null,
    timedOut:job.error?.code==='ETIMEDOUT',oversized,
    stdout:oversized?'':fs.readFileSync(stdout,'utf8'),
    stderr:combined||oversized?'':fs.readFileSync(stderr,'utf8'),
    captures:files.map(pin)};
}
function abnormal(job,phase) {
  return job.timedOut?{status:'timeout',phase,reason:'Native-host '+phase+' timed out.'}:
    job.error||job.signal||job.oversized?{status:'crash',phase,
      reason:job.error||job.signal||'Capture exceeded 1MiB.'}:null;
}
export function compileNative(file,workdir,timeoutMs) {
  const disk=fs.statfsSync(workdir);
  assert.ok(disk.bavail*disk.bsize>=160*2**20,'Less than 160MiB free; preserve evidence and stop');
  const source=pin(file),prefix=path.join(workdir,'compiler-output');
  const argv=selected.argv.map(x=>x===plan.sourceMarker?source.file:x===plan.outputMarker?prefix:x);
  assert.ok(!fs.existsSync(prefix+'.1.c'));
  const job=capture(argv,workdir,'compiler',timeoutMs);
  const output=fs.existsSync(prefix+'.1.c')?pin(prefix+'.1.c'):null;
  if(output)assert.ok(output.bytes>0&&output.bytes<=64*2**20,'Invalid C output size');
  assert.deepEqual(pin(file),source,'Fixture changed');
  verifyInputs();
  return {role,source,job,output,outputAbsent:output===null};
}

export async function probe({test,lane,workdir,timeoutMs}) {
  if(lane!=='native')return {status:'unsupported',reason:'Frozen D04 entry exposes only checked C compilation.'};
  const fixture=plan.eligible.find(x=>x.id===test.id);
  if(!fixture)return {status:'unsupported',reason:'Outside the frozen Base-only native69 selection.'};
  assert.deepEqual(pin(test.file),fixture.source);
  const before=performance.now();
  const remaining=()=>Math.max(1,timeoutMs-(performance.now()-before)-250);
  const emission=compileNative(test.file,workdir,remaining());
  let failure=abnormal(emission.job,'compile');
  if(failure)return {...failure,nativeHost:emission};
  if(emission.job.status!==0||!emission.output)return {status:'error',phase:'compile',
    checked:false,exitCode:emission.job.status??1,
    diagnostic:emission.job.stderr||'Native compiler returned no complete C',nativeHost:emission};
  const file=path.join(workdir,path.basename(test.file,'.bend')+'.c');
  fs.renameSync(emission.output.file,file);emission.output=pin(file);
  const binary=path.join(workdir,'program');
  const build=capture([plan.clang.file,...plan.clangArgs,file,'-lpthread','-lm','-o',binary],workdir,'clang',remaining());
  failure=abnormal(build,'compile');
  if(failure)return {...failure,checked:true,nativeHost:emission,build};
  if(build.status!==0)return {status:'error',phase:'compile',checked:true,exitCode:build.status??1,
    diagnostic:build.stderr||build.stdout,nativeHost:emission,build};
  const executable=pin(binary);
  const run=capture([binary,'--threads','1','--gpu','off'],workdir,'program',remaining(),true);
  failure=abnormal(run,'runtime');
  verifyInputs();assert.deepEqual(pin(test.file),fixture.source);
  if(failure)return {...failure,checked:true,nativeHost:emission,build,run};
  return {status:run.status===0?'ok':'error',phase:'runtime',checked:true,typeAccepted:true,
    proofTrust:'not-assessed',kernelChecked:false,exitCode:run.status??1,signal:run.signal,
    stdout:run.stdout,stderr:'',output:run.stdout,nativeHost:emission,
    nativeBuild:{target:'cpu',clang:plan.clang,args:plan.clangArgs,executable},build,run};
}
