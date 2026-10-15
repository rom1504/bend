// Diagnostic observer only. Await inspector readiness before the target module runs.
import fs from 'node:fs';
import path from 'node:path';
import {Worker} from 'node:worker_threads';

const out=path.resolve(process.env.P90_JS_PROFILE_OUT??'');
if(!process.env.P90_JS_PROFILE_OUT)throw new Error('P90_JS_PROFILE_OUT is required');
const durationMs=Number(process.env.P90_JS_PROFILE_MS??60000);
const intervalUs=Number(process.env.P90_JS_PROFILE_INTERVAL_US??16000);
if(!Number.isInteger(durationMs)||durationMs<100||durationMs>120000)throw new Error('Profile duration must be 100..120000ms');
if(!Number.isInteger(intervalUs)||intervalUs<4000||intervalUs>64000)throw new Error('Sample interval must be 4000..64000us');
fs.mkdirSync(out,{recursive:false});
const worker=new Worker(new URL('./js-partial-worker-v3.mjs',import.meta.url),{
  execArgv:[],resourceLimits:{maxOldGenerationSizeMb:64,stackSizeMb:2},
  workerData:{out,durationMs,intervalUs,argv:process.argv,execArgv:process.execArgv,
    preload:import.meta.filename},
});
let ready=false,finished=false;
await new Promise((resolve,reject)=>{
  worker.on('message',message=>{
    if(message.type==='started'){
      ready=true;worker.unref();resolve();
    }else if(message.type==='complete'){
      finished=true;
      process.stderr.write(JSON.stringify({kind:'P90_PARTIAL_PROFILE',...message})+'\n');
    }else if(message.type==='failed'){
      finished=true;
      if(!ready)reject(new Error(message.error));
      else {process.stderr.write(JSON.stringify({kind:'P90_PARTIAL_PROFILE',...message})+'\n');process.exitCode=1;}
    }
  });
  worker.on('error',error=>{finished=true;if(!ready)reject(error);else {process.stderr.write(String(error.stack??error)+'\n');process.exitCode=1;}});
  worker.on('exit',code=>{if(!ready)reject(new Error('Profiler worker exited before readiness: '+code));});
});
process.once('beforeExit',()=>{
  if(!finished){worker.ref();worker.postMessage({type:'stop',reason:'main-event-loop-drained'});}
});
