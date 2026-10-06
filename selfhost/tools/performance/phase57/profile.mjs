// Library only: importing this module neither profiles nor executes a compiler.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {Session} from 'node:inspector/promises';
import {summarizeCpu,summarizeAllocation} from '../programs/profile.mjs';

const parent=new URL('../programs/profile.mjs',import.meta.url);
const parentSha='891486e500066923534494e6da9c99eadf09b4a4de8470016f1eda82aa8d66f1';
const identity=file=>({file:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex'),bytes:fs.statSync(file).size});
const rawRoot=path.resolve(import.meta.dirname,'../../../build/phase57');
const asError=error=>error instanceof Error?error:new Error(String(error));
let active=false;

export {summarizeCpu,summarizeAllocation};

/** Caller imports/primes/warms first, and supplies the exact async request+oracle. */
export async function profile({mode,run,out,targetMs=5000,samplingIntervalUs=1000,
 samplingIntervalBytes=131072,maxRequests=32,moduleUrl='phase57:unspecified-compiler-module'}={}) {
 assert(['cpu','allocation'].includes(mode));assert.equal(typeof run,'function');
 assert(Number.isFinite(targetMs)&&targetMs>0&&targetMs<=10000);
 assert(Number.isInteger(maxRequests)&&maxRequests>=1&&maxRequests<=1000);
 assert.equal(samplingIntervalUs,1000,'Precommitted 1ms CPU sampling');
 assert.equal(samplingIntervalBytes,131072,'Precommitted 128KiB allocation sampling');
 assert.equal(typeof moduleUrl,'string');assert(moduleUrl.length>0);
 assert(!active,'One in-process profiler at a time');
 const directory=path.resolve(out);assert(directory.startsWith(rawRoot+path.sep));assert(!fs.existsSync(directory));
 const method=identity(parent);assert.equal(method.sha256,parentSha,'Frozen summary method changed');
 fs.mkdirSync(directory,{recursive:true});assert(fs.realpathSync(directory).startsWith(fs.realpathSync(rawRoot)+path.sep));
 const rawFile=path.join(directory,mode==='cpu'?'profile.cpuprofile':'profile.heapprofile');
 const summaryFile=path.join(directory,'summary.json'),reportFile=path.join(directory,'report.json');
 // Reserve outputs before starting inspector; a failed profile keeps its receipt.
 const rawFd=fs.openSync(rawFile,'wx'),reportFd=fs.openSync(reportFile,'wx');
 const started=performance.now(),report={kind:'phase57-async-compiler-profile',complete:false,pass:false,
  diagnosticOnly:true,mode,producer:identity(import.meta.filename),summaryMethod:method,
  node:identity(process.execPath),nodeVersion:process.version,execArgv:process.execArgv,moduleUrl,
  targetMs,maxRequests,calls:0,requestMs:[],sampling:mode==='cpu'?{intervalMicroseconds:1000}:
   {intervalBytes:131072,includeObjectsCollectedByMajorGC:true,includeObjectsCollectedByMinorGC:true},
  timingBoundary:'Inspector encloses sequential awaited run() requests, their supplied correctness checks, and loop/Promise overhead. Caller import, first request and warmup must precede this helper. Serialization and summaries follow inspector stop. Profiled durations are never benchmark ratios.',
  limits:'The target is checked between whole requests; one request can exceed targetMs. Only the caller external process-tree supervisor enforces wall/RSS limits. Sampling is approximate; inclusive frame weights must never be summed.'};
 const checkpoint=()=>{fs.ftruncateSync(reportFd,0);fs.writeSync(reportFd,JSON.stringify(report,null,2)+'\n',0,'utf8');};
 let session,profilerStarted=false,failure;
 active=true;checkpoint();
 try{
  session=new Session();session.connect();
  if(mode==='cpu'){await session.post('Profiler.enable');await session.post('Profiler.setSamplingInterval',{interval:1000});await session.post('Profiler.start');}
  else {await session.post('HeapProfiler.enable');await session.post('HeapProfiler.startSampling',{
   samplingInterval:131072,includeObjectsCollectedByMajorGC:true,includeObjectsCollectedByMinorGC:true});}
  profilerStarted=true;const workloadAt=performance.now();
  try{
   do{const callAt=performance.now();await run();report.requestMs.push(performance.now()-callAt);report.calls++;}
   while(report.calls<maxRequests&&performance.now()-workloadAt<targetMs);
  }catch(error){failure=asError(error);}
  finally{report.workloadMs=performance.now()-workloadAt;report.targetReached=report.workloadMs>=targetMs;report.requestCapReached=report.calls===maxRequests;}
 }catch(error){failure??=asError(error);}
 finally{
  if(profilerStarted){
   try{
    const {profile:raw}=await session.post(mode==='cpu'?'Profiler.stop':'HeapProfiler.stopSampling');
    fs.writeSync(rawFd,JSON.stringify(raw)+'\n');report.raw=identity(rawFile);
    const summary=mode==='cpu'?summarizeCpu(raw,moduleUrl):summarizeAllocation(raw,moduleUrl);
    if(mode==='cpu')summary.accounting={weightSource:'samples weighted by timeDeltas',sampleWeightedUs:summary.totalWeight,
     profileDurationUs:summary.profileDurationUs,profileMinusSampleUs:summary.profileDurationUs-summary.totalWeight,
     scope:'Retain the signed difference rather than assigning it to any frame or rescaling samples. Native/idle/GC frames remain in the original denominator.'};
    if(!report.targetReached)summary.warnings.push('Requested duration was not reached; inspect failures and request cap before attributing hotspots.');
    fs.writeFileSync(summaryFile,JSON.stringify(summary,null,2)+'\n',{flag:'wx'});report.summary=identity(summaryFile);
    report.totals={unit:summary.unit,totalWeight:summary.totalWeight,sampleCount:summary.sampleCount,frameCount:summary.frameCount};
    report.warnings=summary.warnings;
   }catch(error){report.profilerStopError=error?.stack??String(error);failure??=asError(error);}
  }
  try{session?.disconnect();}catch(error){failure??=asError(error);}
  fs.closeSync(rawFd);report.wallMs=performance.now()-started;report.resourceUsage=process.resourceUsage();report.memory=process.memoryUsage();
  report.affinity=fs.readFileSync('/proc/self/status','utf8').split('\n').find(x=>x.startsWith('Cpus_allowed_list:'));
  report.resourceScope='resourceUsage is cumulative process lifetime, including caller import/priming/warmup; memory is a final snapshot, not a sampled interval peak.';
  try{assert.deepEqual(identity(parent),method);assert.deepEqual(identity(import.meta.filename),report.producer);}catch(error){failure??=asError(error);}
  if(failure)report.error={name:failure.name,message:failure.message,stack:failure.stack};
  else {report.complete=true;report.pass=true;}
  checkpoint();fs.closeSync(reportFd);active=false;
 }
 const result={...report,receipt:identity(reportFile)};
 if(failure){failure.profileReceipt=result.receipt;throw failure;}
 return result;
}
