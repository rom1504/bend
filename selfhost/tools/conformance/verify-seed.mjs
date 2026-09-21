#!/usr/bin/env node
// Prove B = H(B, S): a checked compiler library reproduces its own bytes from
// frozen source. The host that originally produced B is recorded as provenance.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {spawn,spawnSync} from 'node:child_process';
import {project,runtimePath,basePath} from '../typed-driver.mjs';

if(process.argv.length!==5)throw Error('Usage: verify-seed.mjs SOURCE.bend SEED.mjs OUTPUT_DIRECTORY');
const [source,seed,directory]=process.argv.slice(2).map(file=>path.resolve(file));
const driver=path.resolve(process.env.BEND_SELFHOST_DRIVER||path.join(project,'tools/typed-driver.mjs'));
const timeoutMs=Number(process.env.BEND_SELFHOST_TIMEOUT||10800000);
const stackKB=Number(process.env.BEND_SELFHOST_STACK_KB??4096);
const heapMB=Number(process.env.BEND_SELFHOST_HEAP_MB||12288);
if(!Number.isInteger(timeoutMs)||timeoutMs<1||!Number.isInteger(stackKB)||stackKB<0||!Number.isInteger(heapMB)||heapMB<0)throw Error('Invalid self-host resource configuration');
const osStackKB=process.platform==='win32'?null:spawnSync('sh',['-c','ulimit -s'],{encoding:'utf8'}).stdout?.trim();
if(stackKB&&osStackKB!=='unlimited'&&!(Number(osStackKB)>=stackKB*2))throw Error('OS stack limit must be verified and at least twice the requested V8 stack');
const nodeArgs=[...(stackKB?[`--stack-size=${stackKB}`]:[]),...(heapMB?[`--max-old-space-size=${heapMB}`]:[])];
const hash=file=>crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const artifact=file=>({file,sha256:hash(file)});
fs.mkdirSync(directory,{recursive:true});
const output=path.join(directory,'stage3.mjs'),logFile=output+'.log',reportFile=path.join(directory,'report.json');
if(fs.existsSync(reportFile)||fs.existsSync(output))throw Error('Use a new output directory to preserve prior verification evidence');
const dependencies=['compiler-abi.mjs','native-build.mjs','assemble.mjs'].map(name=>path.join(path.dirname(driver),name));
const inputs={source:artifact(source),seed:artifact(seed),runtime:artifact(runtimePath),base:artifact(basePath),driver:artifact(driver),dependencies:dependencies.map(artifact)};
const provenanceFile=process.env.BEND_SELFHOST_SEED_REPORT&&path.resolve(process.env.BEND_SELFHOST_SEED_REPORT);
if(!provenanceFile)throw Error('BEND_SELFHOST_SEED_REPORT must identify the successful seed emission report');
const provenance=JSON.parse(fs.readFileSync(provenanceFile,'utf8'));
const seedStage=provenance.stages?.find(stage=>stage.code===0&&stage.outputSha256===inputs.seed.sha256);
if(!seedStage||provenance.sourceSha256!==inputs.source.sha256||provenance.runtimeSha256!==inputs.runtime.sha256)throw Error('Seed provenance does not match the frozen source/runtime/seed');
const report={schemaVersion:1,started:new Date().toISOString(),complete:false,fixedPoint:false,
  validationPolicy:{decidedBeforeExecution:true,condition:'B = H(B, S): the generated seed compiler fully checks and emits the same frozen source, and its output must be byte-identical to the seed.',
    seedGenerationHostMayDiffer:true,reason:'Equality of the generated compiler with its own checked self-emission establishes the fixed point; repeating the original seed emission is unnecessary.'},
  inputs,seedProvenance:{report:artifact(provenanceFile),successfulStage:seedStage,originalDriver:provenance.driver},
  resourceConfiguration:{node:process.version,nodeArgs,osStackKB,timeoutMs},output,logFile};
const save=()=>fs.writeFileSync(reportFile,JSON.stringify(report,null,2)+'\n');
const verifyInputs=()=>{
  for(const input of [...Object.values(inputs).filter(value=>!Array.isArray(value)),...inputs.dependencies])if(hash(input.file)!==input.sha256)throw Error('Frozen input changed: '+input.file);
};
let child;
for(const signal of ['SIGINT','SIGTERM'])process.on(signal,()=>{
  report.interrupted=signal;save();
  if(child)try{if(process.platform!=='win32')process.kill(-child.pid,signal);else child.kill(signal);}catch{}
});
save();
const log=fs.openSync(logFile,'w'),start=performance.now();
try {
  verifyInputs();
  child=spawn(process.execPath,[...nodeArgs,driver,source,'--library','-o',output],{cwd:project,detached:process.platform!=='win32',stdio:['ignore',log,log],
    env:{...process.env,BEND_TYPED_API:seed,BEND_TYPED_RUNTIME:runtimePath,BEND_BASE:basePath,BEND_TYPED_TRACE:'1'}});
  const alarm=setTimeout(()=>{report.timedOut=true;try{if(process.platform!=='win32')process.kill(-child.pid,'SIGKILL');else child.kill('SIGKILL');}catch{}},timeoutMs);
  try {report.exit=await new Promise((resolve,reject)=>{child.once('error',reject);child.once('exit',(code,signal)=>resolve({code,signal}));});}
  finally {clearTimeout(alarm);}
  report.ms=Math.round(performance.now()-start);verifyInputs();
  if(report.exit.code!==0)throw Error('Seed self-emission failed; inspect '+logFile);
  report.outputSha256=hash(output);report.fixedPoint=report.outputSha256===inputs.seed.sha256;report.complete=report.fixedPoint;
  if(!report.fixedPoint)throw Error('Checked self-emission differs from the seed compiler');
  console.log('Checked compiler fixed point: '+report.outputSha256);
} catch(error) {report.error=error.message;process.exitCode=1;console.error(error.message);}
finally {fs.closeSync(log);report.finished=new Date().toISOString();report.ms??=Math.round(performance.now()-start);save();}
