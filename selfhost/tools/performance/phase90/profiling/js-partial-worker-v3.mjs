// Runs an inspector session against the MAIN isolate from a separate worker.
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {Session} from 'node:inspector';
import {parentPort,workerData,threadId} from 'node:worker_threads';

const {out,durationMs,intervalUs}=workerData;
const nowUs=()=>Number(process.hrtime.bigint()/1000n);
const pin=file=>{const data=fs.readFileSync(file);return {file,sha256:createHash('sha256').update(data).digest('hex'),bytes:data.length};};
const report={kind:'phase90-partial-main-isolate-profile',captureComplete:false,
  compilerCompletion:'not-observed',compilerSuccess:null,targetArgv:workerData.argv,
  targetExecArgv:workerData.execArgv,node:process.version,v8:process.versions.v8,
  pid:process.pid,workerThreadId:threadId,durationMs,intervalUs,clock:'process.hrtime microseconds',
  inputMethods:[pin(workerData.preload),pin(import.meta.filename)],
  maxProfileBytes:32*1024*1024,workerHeapLimitMiB:64,startedWorkerUs:nowUs()};
const save=()=>fs.writeFileSync(path.join(out,'metadata.json'),JSON.stringify(report,null,2)+'\n');
const session=new Session();
const post=(method,params={})=>new Promise((resolve,reject)=>session.post(method,params,(error,result)=>error?reject(error):resolve(result)));
let timer,stopping=false;
async function stop(reason){
  if(stopping)return;stopping=true;clearTimeout(timer);
  report.stopReason=reason;report.stopRequestedUs=nowUs();save();
  try{
    const result=await post('Profiler.stop');report.stopAcknowledgedUs=nowUs();
    const profile=result.profile;
    report.samples=profile.samples?.length??0;report.nodes=profile.nodes.length;
    report.profileStartUs=profile.startTime;report.profileEndUs=profile.endTime;
    const bytes=Buffer.from(JSON.stringify(profile));
    if(bytes.length>report.maxProfileBytes)throw new Error('Profile exceeds 32MiB cap: '+bytes.length);
    const target=path.join(out,'partial.cpuprofile');fs.writeFileSync(target,bytes,{flag:'wx'});
    report.profile=pin(target);report.captureComplete=true;report.writtenUs=nowUs();report.stopTargetAfterCapture=process.env.P90_JS_PROFILE_STOP_TARGET==='1';save();
    parentPort.postMessage({type:'complete',profile:report.profile,samples:report.samples,
      stopRequestedUs:report.stopRequestedUs,stopAcknowledgedUs:report.stopAcknowledgedUs,
      compilerCompletion:'not-observed'});
  }catch(error){fail(error);return;}
  session.disconnect();parentPort.close();
  if(report.stopTargetAfterCapture)process.kill(process.pid,'SIGTERM');
}
function fail(error){
  report.error=String(error.stack??error);report.captureComplete=false;report.failedUs=nowUs();
  try{save();}catch{}
  parentPort.postMessage({type:'failed',error:report.error,compilerCompletion:'not-observed'});
  try{session.disconnect();}catch{}parentPort.close();
}
parentPort.on('message',message=>{if(message.type==='stop')void stop(message.reason);});
try{
  save();session.connectToMainThread();await post('Profiler.enable');
  await post('Profiler.setSamplingInterval',{interval:intervalUs});
  report.startRequestedUs=nowUs();await post('Profiler.start');report.startAcknowledgedUs=nowUs();save();
  timer=setTimeout(()=>void stop('worker-wall-clock-deadline'),durationMs);
  parentPort.postMessage({type:'started',startAcknowledgedUs:report.startAcknowledgedUs});
}catch(error){fail(error);}
