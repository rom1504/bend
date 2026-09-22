#!/usr/bin/env node
// Finite supervised batches, never a daemon. A failed request remains failed;
// only later requests are given a fresh worker after a timeout/crash.
import fs from 'node:fs';import path from 'node:path';import {spawn} from 'node:child_process';import {pathToFileURL} from 'node:url';
import {identity,verifyIdentity,verifyImage,readJson,writeJson} from './common.mjs';import {validateBatchRequests,privateNodeResourceArgs} from './transport.mjs';import {verifyReadAudit} from './input-audit.mjs';import {publishCheckedOutput} from './publish.mjs';
export function batchIsComplete(report,expectedCount){
 return report.rows.length===expectedCount&&report.rows.every(row=>row.complete&&row.published)&&report.lifetimes.length>0&&report.lifetimes.every(l=>l.verified&&!l.error&&!l.spawnError&&!l.outputLimit&&l.exit?.status===0&&l.exit?.signal===null)&&!report.error;
}
export async function runPrivateBatch({image,requests,output,cpu,timeoutMs=120000,heapMb=3072,recycle=32}) {
 const start=performance.now(),resourceArgs=privateNodeResourceArgs({heapMb}),selected=validateBatchRequests(requests,{timeoutMs});
 if(!Number.isInteger(recycle)||recycle<1||recycle>32)throw Error('Recycle interval must be 1..32 requests');
 if(cpu!==undefined&&(!Number.isInteger(cpu)||cpu<0))throw Error('CPU must be a nonnegative integer');
 const originalImage=verifyImage(image),requested=path.resolve(output);fs.mkdirSync(requested,{recursive:false});const out=fs.realpathSync(requested);
 const tools=['batch','common','transport','input-audit','publish'].map(name=>identity(new URL('./'+name+'.mjs',import.meta.url)));
 const report={kind:'bend-private-compiler-batch',version:1,complete:false,started:new Date().toISOString(),proofStatus:originalImage.manifest.proofStatus,imageManifest:originalImage.manifestIdentity,
  contract:'At most256 sequential data requests; fresh graphs; publication after each verified worker lifetime; input files must remain stable through their lifetime.',
  resourceArgs,cpu:cpu??null,recycle,tools,requests:selected,rows:[],lifetimes:[]};
 writeJson(path.join(out,'requests.json'),requests);const requestIdentity=identity(path.join(out,'requests.json'));report.requestConfig=requestIdentity;
 const flush=()=>fs.writeFileSync(path.join(out,'batch.json'),JSON.stringify(report,null,2)+'\n');flush();
 let cursor=0;
 while(cursor<selected.length){
  const lifeIndex=report.lifetimes.length,lifeOut=path.join(out,'worker-'+lifeIndex);fs.mkdirSync(lifeOut);
  let before,node;
  try{for(const tool of tools)verifyIdentity(tool);verifyIdentity(requestIdentity);verifyIdentity(originalImage.manifestIdentity);before=verifyImage(originalImage.root);node={...identity(process.execPath),version:process.version};}
  catch(error){report.error=String(error);break;}
  const configFile=path.join(lifeOut,'config.json');writeJson(configFile,{image:before.root,directory:out,node});
  const worker=path.join(before.root,'runner/batch-worker.mjs');if(!['runner/batch-worker.mjs','runner/session.mjs'].every(relative=>before.manifest.artifacts.some(a=>a.relative===relative))||!fs.existsSync(worker)){report.error='Image lacks finite-batch worker; rebuild with current private compiler tools';break;}
  const nodeArgs=[...resourceArgs,worker,configFile],command=cpu===undefined?process.execPath:'taskset',args=cpu===undefined?nodeArgs:['-c',String(cpu),process.execPath,...nodeArgs];
  const stdout=fs.openSync(path.join(lifeOut,'stdout'),'wx'),stderr=fs.openSync(path.join(lifeOut,'stderr'),'wx');
  const life={index:lifeIndex,node,command,args,started:new Date().toISOString(),firstRequest:cursor,config:identity(configFile),rows:[],verified:false};report.lifetimes.push(life);
  const lifetimeStart=performance.now();let child,closed=false,closeInfo,waiting=null,ready=false,lastMessage=null,outputLimit=false;
  let closeResolve;const closePromise=new Promise(resolve=>closeResolve=resolve);
  const wake=value=>{if(waiting){const resolve=waiting;waiting=null;resolve(value);}else lastMessage=value;};
  const kill=()=>{try{process.kill(-child.pid,'SIGKILL');}catch{}};
  try{
   child=spawn(command,args,{stdio:['ignore',stdout,stderr,'ipc'],detached:true,env:{...process.env,NODE_OPTIONS:''}});life.pid=child.pid;
   child.on('message',message=>wake({message}));child.on('error',error=>{life.spawnError=String(error);wake({failure:'spawn error: '+error});});child.once('close',(status,signal)=>{closed=true;closeInfo={status,signal};wake({failure:'worker closed',...closeInfo});closeResolve(closeInfo);});
   const poll=setInterval(()=>{if(fs.fstatSync(stdout).size+fs.fstatSync(stderr).size>2*1024*1024){outputLimit=true;kill();}},100);
   const wait=async deadline=>{
    if(lastMessage){const value=lastMessage;lastMessage=null;return value;}if(closed)return {failure:'worker already closed',...closeInfo};
    let timer;const value=await new Promise(resolve=>{waiting=resolve;timer=setTimeout(()=>{waiting=null;resolve({failure:'deadline exceeded',timedOut:true});},deadline);});clearTimeout(timer);return value;
   };
   try{
    const init=await wait(30000);if(init.message?.kind!=='ready')throw Error('Worker initialization failed: '+JSON.stringify(init));
    if(init.message.node.file!==process.execPath||init.message.node.version!==process.version||JSON.stringify(init.message.manifest)!==JSON.stringify(before.manifestIdentity))throw Error('Worker initialization identity mismatch');
    ready=true;life.startupMs=performance.now()-lifetimeStart;
    for(let n=0;n<recycle&&cursor<selected.length;n++){
     const index=cursor++,item=selected[index],directory=path.join(out,String(index).padStart(3,'0'));fs.mkdirSync(directory);
     const row={index,lifetime:lifeIndex,request:item.request,timeoutMs:item.timeoutMs,complete:false,published:false};report.rows.push(row);life.rows.push(index);flush();
     const requestStart=performance.now();child.send({kind:'request',index,request:item.request});const next=await wait(item.timeoutMs);row.wallMs=performance.now()-requestStart;
     if(next.message?.kind==='result'&&next.message.index===index){
      try{const observed=readJson(path.join(directory,'result.json'));if(observed.complete!==true||JSON.stringify(observed.request)!==JSON.stringify(item.request))throw Error('Worker request/result mismatch');verifyReadAudit(observed.inputs);row.observation=observed;row.workerComplete=true;}
      catch(error){row.error=String(error);kill();break;}
     }else{row.error=next.message?.error??next.failure??'Unexpected worker protocol message';row.timedOut=next.timedOut??false;row.outputLimit=outputLimit;kill();break;}
     flush();
    }
    if(!closed&&!life.rows.some(i=>!report.rows.find(r=>r.index===i)?.workerComplete)){
     child.send({kind:'finish'});const final=await wait(30000);if(final.message?.kind!=='finished'){life.error='Worker did not finish cleanly: '+JSON.stringify(final);kill();}
    }else kill();
   }catch(error){life.error=String(error);kill();if(!ready&&cursor<selected.length){report.rows.push({index:cursor++,lifetime:lifeIndex,request:selected[cursor-1].request,complete:false,published:false,error:life.error});life.rows.push(cursor-1);}}
   finally{
    const closeTimer=setTimeout(kill,5000);await closePromise;clearTimeout(closeTimer);clearInterval(poll);
   }
  }catch(error){life.error=String(error);kill();}
  finally{life.logBytes=fs.fstatSync(stdout).size+fs.fstatSync(stderr).size;outputLimit ||= life.logBytes>2*1024*1024;fs.closeSync(stdout);fs.closeSync(stderr);life.exit=closeInfo;life.wallMs=performance.now()-lifetimeStart;life.outputLimit=outputLimit;}
  try{
   verifyIdentity(node);verifyIdentity(life.config);verifyIdentity(before.manifestIdentity);verifyImage(before.root);verifyIdentity(requestIdentity);for(const tool of tools)verifyIdentity(tool);
   life.verified=true;
   for(const index of life.rows){const row=report.rows.find(r=>r.index===index);if(!row.workerComplete)continue;
    try{if(life.outputLimit)throw Error('Worker lifetime exceeded combined log limit; output was not published');verifyReadAudit(row.observation.inputs);publishCheckedOutput(path.join(out,String(index).padStart(3,'0')),row.observation,row.request.mode);row.complete=true;row.published=true;}
    catch(error){row.complete=false;row.error=String(error);}
   }
  }catch(error){life.verificationError=String(error);for(const index of life.rows){const row=report.rows.find(r=>r.index===index);row.complete=false;row.error=String(error);}report.error='Worker lifetime inputs changed; remaining requests were not run';flush();break;}
  flush();
 }
 report.complete=batchIsComplete(report,selected.length);
 report.wallMs=performance.now()-start;report.finished=new Date().toISOString();flush();return report;
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){
 try{
  const [image,file,output,...flags]=process.argv.slice(2),options={};if(!output)throw Error('Usage: batch.mjs IMAGE REQUESTS_JSON NEW_OUTPUT_DIRECTORY [--cpu=N] [--heap-mb=N] [--timeout-ms=N] [--recycle=N]');
  for(const flag of flags){const m=/^--(cpu|heap-mb|timeout-ms|recycle)=(\d+)$/.exec(flag);if(!m)throw Error('Unknown batch option '+flag);options[{'cpu':'cpu','heap-mb':'heapMb','timeout-ms':'timeoutMs','recycle':'recycle'}[m[1]]]=Number(m[2]);}
  const result=await runPrivateBatch({image,requests:readJson(file,1024*1024),output,...options});console.log(JSON.stringify({complete:result.complete,rows:result.rows.length,wallMs:result.wallMs,error:result.error}));process.exitCode=result.complete?(result.rows.some(row=>row.observation.result.status!=='ok')?1:0):2;
 }catch(error){console.error(error.stack);process.exitCode=2;}
}
