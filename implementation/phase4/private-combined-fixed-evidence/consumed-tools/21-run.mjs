#!/usr/bin/env node
// Public data-only CLI. Every invocation owns a fresh bounded worker process.
import fs from 'node:fs';
import path from 'node:path';
import {spawn} from 'node:child_process';
import {pathToFileURL} from 'node:url';
import {identity,verifyImage,verifyIdentity,writeJson,readJson} from './common.mjs';
import {validateInspectRequest,privateNodeResourceArgs} from './transport.mjs';
import {verifyReadAudit} from './input-audit.mjs';
import {publishCheckedOutput} from './publish.mjs';
export async function runPrivateCompiler({image,input,mode,output,cpu,timeoutMs=120000,withReport=false,heapMb=3072}) {
 const start=performance.now(),resourceArgs=privateNodeResourceArgs({heapMb}),launcherTools=['run.mjs','common.mjs','transport.mjs','input-audit.mjs','publish.mjs'].map(name=>identity(new URL(name,import.meta.url))),before=verifyImage(image),request=validateInspectRequest({input:path.resolve(input),mode,withReport}),requestedOut=path.resolve(output);
 if(!Number.isInteger(timeoutMs)||timeoutMs<1||timeoutMs>3600000)throw Error('Timeout must be 1..3600000 milliseconds');
 if(cpu!==undefined&&(!Number.isInteger(cpu)||cpu<0))throw Error('CPU must be a nonnegative integer');
 // Requiring a new directory gives every input, dependency, source, artifact,
 // and prior result overwrite protection without interpreting Bend imports.
 fs.mkdirSync(requestedOut,{recursive:false});const out=fs.realpathSync(requestedOut);writeJson(path.join(out,'request.json'),request);
 const worker=path.join(before.root,'runner/worker.mjs'),nodeArgs=[...resourceArgs,worker,before.root,path.join(out,'request.json'),out];
 const command=cpu===undefined?process.execPath:'taskset',args=cpu===undefined?nodeArgs:['-c',String(cpu),process.execPath,...nodeArgs];
 const stdout=fs.openSync(path.join(out,'worker.stdout'),'wx'),stderr=fs.openSync(path.join(out,'worker.stderr'),'wx');
 let timedOut=false,outputLimit=false;
 const child=await new Promise(resolve=>{
  const p=spawn(command,args,{stdio:['ignore',stdout,stderr],detached:true,env:{...process.env,NODE_OPTIONS:''}});
  const kill=()=>{try{process.kill(-p.pid,'SIGKILL');}catch{}};
  const timer=setTimeout(()=>{timedOut=true;kill();},timeoutMs);
  const poll=setInterval(()=>{if(fs.fstatSync(stdout).size+fs.fstatSync(stderr).size>2*1024*1024){outputLimit=true;kill();}},100);
  let settled=false;const done=result=>{if(settled)return;settled=true;clearTimeout(timer);clearInterval(poll);resolve(result);};
  p.once('error',error=>done({error:String(error),status:null,signal:null}));p.once('close',(status,signal)=>done({status,signal}));
 });const logBytes=fs.fstatSync(stdout).size+fs.fstatSync(stderr).size;outputLimit ||= logBytes>2*1024*1024;fs.closeSync(stdout);fs.closeSync(stderr);
 const report={kind:'bend-private-compiler-launch',version:1,complete:false,proofStatus:before.manifest.proofStatus,request,
  imageManifest:before.manifestIdentity,launcher:launcherTools[0],launcherTools,node:{...identity(process.execPath),version:process.version},
  command,args,resourceArgs,timeoutMs,timedOut,outputLimit,logBytes,...child,wallMs:performance.now()-start};
 try{
  for(const tool of launcherTools)verifyIdentity(tool);verifyIdentity(before.manifestIdentity);verifyImage(before.root);
  if(child.status===0&&!child.signal&&!timedOut&&!outputLimit){
   const result=readJson(path.join(out,'result.json'));if(result.complete!==true)throw Error('Incomplete private worker result');
   verifyReadAudit(result.inputs);
   publishCheckedOutput(out,result,request.mode);
   report.result=result.result;report.requestMs=result.requestMs;report.emitted=result.emitted;report.complete=true;
  }
 }catch(error){report.error=String(error);}
 report.wallMs=performance.now()-start;writeJson(path.join(out,'launch.json'),report);
 return report;
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){
 const [image,input,mode,output,...flags]=process.argv.slice(2),options={};
 for(const flag of flags){if(/^--cpu=\d+$/.test(flag))options.cpu=Number(flag.slice(6));else if(/^--timeout-ms=\d+$/.test(flag))options.timeoutMs=Number(flag.slice(13));else if(/^--heap-mb=\d+$/.test(flag))options.heapMb=Number(flag.slice(10));else if(flag==='--report')options.withReport=true;else throw Error('Unknown option '+flag);}
 if(!output)throw Error('Usage: run.mjs IMAGE INPUT parse|check|compile|library NEW_OUTPUT_DIRECTORY [--cpu=N] [--timeout-ms=N] [--heap-mb=N] [--report]');
 try{const result=await runPrivateCompiler({image,input,mode,output,...options});console.log(JSON.stringify(result));process.exitCode=result.complete?(result.result.exitCode??0):2;}catch(error){console.error(error.stack);process.exitCode=2;}
}
