#!/usr/bin/env node
// Rebuild the same compiler source using successively self-emitted libraries.
// Every stage invokes the ordinary source loader/checker/specializer/emitter.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {spawn,spawnSync} from 'node:child_process';
import {project,apiPath,runtimePath,basePath} from '../typed-driver.mjs';
const source=path.resolve(process.argv[2]||'');
if(!process.argv[2])throw Error('Usage: selfhost.mjs SOURCE.bend [OUTPUT_DIRECTORY]');
const driver=path.resolve(process.env.BEND_SELFHOST_DRIVER||path.join(project,'tools/typed-driver.mjs'));
const timeoutMs=Number(process.env.BEND_SELFHOST_TIMEOUT||1800000);
if(!Number.isFinite(timeoutMs)||timeoutMs<=0)throw Error('Invalid BEND_SELFHOST_TIMEOUT');
const firstStage=Number(process.env.BEND_SELFHOST_RESUME||2);
if(![2,3,4].includes(firstStage))throw Error('BEND_SELFHOST_RESUME must be 2, 3, or 4');
const repeat=process.env.BEND_SELFHOST_REPEAT==='1';
const requestedStages=repeat?[2,3,4]:[2,3];
if(firstStage===4&&!repeat)throw Error('Resuming optional stage4 requires BEND_SELFHOST_REPEAT=1');
const stackKB=Number(process.env.BEND_SELFHOST_STACK_KB??4096);
if(!Number.isInteger(stackKB)||stackKB<0)throw Error('Invalid BEND_SELFHOST_STACK_KB');
const heapMB=Number(process.env.BEND_SELFHOST_HEAP_MB||0);
if(!Number.isInteger(heapMB)||heapMB<0)throw Error('Invalid BEND_SELFHOST_HEAP_MB');
// Linux exposes this process's actual soft limit directly. Reading it avoids
// depending on shell-child stdout delivery under process supervisors.
const linuxStack=process.platform==='linux'?/^Max stack size\s+(\S+)\s+\S+\s+bytes\s*$/m.exec(fs.readFileSync('/proc/self/limits','utf8'))?.[1]:null;
const stackLimit=process.platform==='win32'?null:process.platform==='linux'?
  (linuxStack==='unlimited'?'unlimited':/^\d+$/.test(linuxStack||'')?String(Number(linuxStack)/1024):null):
  spawnSync('sh',['-c','ulimit -s'],{encoding:'utf8'}).stdout?.trim();
if(stackKB&&stackLimit!=='unlimited'&&!(Number(stackLimit)>=stackKB*2))throw Error('Self-hosting requires a verified OS stack limit at least twice BEND_SELFHOST_STACK_KB; lower that setting or increase the OS limit.');
const nodeArgs=[...(stackKB?[`--stack-size=${stackKB}`]:[]),...(heapMB?[`--max-old-space-size=${heapMB}`]:[])];
const directory=path.resolve(process.argv[3]||path.join(project,'build/typed/fixedpoint'));
const digest=file=>crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const identity=file=>({file:path.resolve(file),canonicalPath:fs.realpathSync(file),sha256:digest(file)});
const verifyIdentity=(input,label)=>{
  if(fs.realpathSync(input.file)!==input.canonicalPath||digest(input.file)!==input.sha256)throw Error('Self-host '+label+' changed during verification: '+input.file);
};
const base=identity(basePath);
const sourceIdentity=identity(source);
const hostHelpers=['compiler-abi.mjs','node-resource-args.mjs','native-build.mjs','assemble.mjs'].map(name=>identity(path.join(path.dirname(driver),name)));
const reportFile=path.join(directory,'report.json');
if(firstStage===2&&fs.existsSync(reportFile))throw Error('Fresh self-host attempt refuses an existing report; choose a new output directory or explicitly resume');
fs.mkdirSync(directory,{recursive:true});
const runtime=path.join(directory,'runtime.mjs');
if(firstStage===2)fs.copyFileSync(runtimePath,runtime);
const sourceSha256=digest(source),runtimeSha256=digest(runtime);
const report=firstStage===2?{started:new Date().toISOString(),source,sourceIdentity,sourceSha256,runtimeSha256,base,hostHelpers,initialCompiler:identity(apiPath),driver:identity(driver),stages:[],complete:false}:JSON.parse(fs.readFileSync(reportFile,'utf8'));
if(firstStage!==2) {
  if(!report.base?.canonicalPath||!Array.isArray(report.hostHelpers)||report.hostHelpers.length!==hostHelpers.length)throw Error('Legacy self-host report lacks verified Base/helper provenance; start a fresh attempt');
  if(!report.sourceIdentity?.canonicalPath)throw Error('Legacy self-host report lacks canonical source provenance; start a fresh attempt');
  if(JSON.stringify(report.sourceIdentity)!==JSON.stringify(sourceIdentity))throw Error('Resume source identity differs from the recorded self-host attempt');
  if(JSON.stringify(report.base)!==JSON.stringify(base)||JSON.stringify(report.hostHelpers)!==JSON.stringify(hostHelpers))throw Error('Resume Base or host helper inputs differ from the recorded self-host attempt');
  verifyIdentity(report.initialCompiler,'initial compiler');verifyIdentity(report.driver,'driver');
  if(report.sourceSha256!==sourceSha256||report.runtimeSha256!==runtimeSha256||digest(runtimePath)!==runtimeSha256||report.initialCompiler.sha256!==digest(apiPath)||report.driver.sha256!==digest(driver))throw Error('Resume inputs differ from the recorded self-host attempt');
  const keep=report.stages.filter(stage=>Number(path.basename(stage.output).match(/stage(\d+)/)?.[1])<firstStage);
  if(keep.length!==firstStage-2||keep.some(stage=>stage.code!==0||stage.inputsVerified!==true||digest(stage.output)!==stage.outputSha256))throw Error('Resume requires every preceding verified stage output');
  const attempt={saved:new Date().toISOString(),stages:report.stages.filter(stage=>!keep.includes(stage)),currentStage:report.currentStage,error:report.error,interrupted:report.interrupted,resourceConfiguration:report.resourceConfiguration};
  attempt.logs=[];
  for(const output of new Set([...attempt.stages.map(stage=>stage.output),...(report.currentStage?[report.currentStage.output]:[])])) {
    const log=output+'.log';
    if(fs.existsSync(log)){const preserved=log+'.attempt-'+Date.now();fs.copyFileSync(log,preserved);attempt.logs.push(preserved);}
  }
  (report.previousAttempts??=[]).push(attempt);report.stages=keep;
  for(const key of ['error','interrupted','finished','currentStage'])delete report[key];
}
report.complete=false;
report.resourceConfiguration={node:process.version,nodeArgs,osStackKB:stackLimit,timeoutMs};
report.requestedStages=requestedStages;
report.validationPolicy={required:[2,3],optionalRepeat:repeat,condition:'Stage2 and its checked self-emission stage3 must be byte-identical for the same frozen source.'};
const save=()=>fs.writeFileSync(reportFile,JSON.stringify(report,null,2)+'\n');
let activeChild=null;
for(const signal of ['SIGINT','SIGTERM'])process.on(signal,()=>{
  report.interrupted=signal;save();
  if(activeChild) {
    try {if(process.platform!=='win32')process.kill(-activeChild.pid,signal);else activeChild.kill(signal);}catch {}
  } else process.exit(signal==='SIGINT'?130:143);
});
save();
async function compile(compiler,output) {
  if(digest(source)!==sourceSha256)throw Error('Self-host source changed during verification');
  if(digest(driver)!==report.driver.sha256)throw Error('Self-host driver changed during verification');
  if(digest(runtime)!==runtimeSha256)throw Error('Self-host runtime changed during verification');
  const verifyHost=()=>{
    verifyIdentity(report.sourceIdentity,'source');
    verifyIdentity(report.base,'Base');
    for(const helper of report.hostHelpers)verifyIdentity(helper,'host helper');
    verifyIdentity(report.driver,'driver');verifyIdentity(report.initialCompiler,'initial compiler');
    if(digest(source)!==sourceSha256||digest(runtime)!==runtimeSha256)throw Error('Self-host source/runtime changed during verification');
  };
  verifyHost();const compilerIdentity=identity(compiler);
  report.currentStage={compiler,output,nodeArgs,started:new Date().toISOString()};save();
  const log=fs.openSync(output+'.log','w'),start=performance.now();
  try {
    const child=spawn(process.execPath,[...nodeArgs,driver,source,'--library','-o',output],{
      cwd:project,detached:process.platform!=='win32',stdio:['ignore',log,log],env:{...process.env,BEND_BASE:report.base.canonicalPath,BEND_TYPED_API:compiler,BEND_TYPED_RUNTIME:runtime,BEND_TYPED_TRACE:'1'}});
    activeChild=child;
    const alarm=setTimeout(()=>{
      try {if(process.platform!=='win32')process.kill(-child.pid,'SIGKILL');else child.kill('SIGKILL');}catch {}
    },timeoutMs);
    const exit=await new Promise((resolve,reject)=>{
      child.once('error',error=>{clearTimeout(alarm);reject(error);});
      child.once('exit',(code,signal)=>{clearTimeout(alarm);resolve({code,signal});});
    });
    const stage={compiler,compilerSha256:compilerIdentity.sha256,output,nodeArgs,...exit,ms:Math.round(performance.now()-start),inputsVerified:false};
    if(exit.code===0)stage.outputSha256=digest(output);
    report.stages.push(stage);delete report.currentStage;save();
    verifyHost();verifyIdentity(compilerIdentity,'stage compiler');stage.inputsVerified=true;save();
    if(exit.code!==0)throw Error('Compiler stage failed; inspect '+output+'.log');
    console.log(path.basename(output)+': '+stage.outputSha256);
    return output;
  } finally {activeChild=null;fs.closeSync(log);}
}
try {
  let compiler=firstStage===2?apiPath:path.join(directory,`stage${firstStage-1}.mjs`);
  for(const stage of requestedStages.filter(stage=>stage>=firstStage))compiler=await compile(compiler,path.join(directory,`stage${stage}.mjs`));
  report.complete=report.stages.every(stage=>stage.outputSha256===report.stages[0].outputSha256);
  report.finished=new Date().toISOString();save();
  if(!report.complete)throw Error('Self-hosted stage outputs are not a byte-for-byte fixed point');
  console.log(`${report.stages.length} checked self-emission stages are byte-identical.`);
} catch(error) {report.error=error.message;report.finished=new Date().toISOString();delete report.currentStage;save();throw error;}
