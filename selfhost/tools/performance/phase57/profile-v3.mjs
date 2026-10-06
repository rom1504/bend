// Fixed 25ms CPU sampler for one bounded emission diagnostic; no target runs on import.
// Exact policy/summary predecessor: profile-v2.mjs f472c5e565827e7a8cfc4181e19dffe61f4485c63a3d137c1315c82e388064f6.
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

// Preserve signed raw deltas. A narrowly bounded view corrects observed timestamp jitter;
// this does not establish its cause and never changes the raw profile.
export function summarizeCpuViews(raw,moduleUrl) {
 assert(Array.isArray(raw.samples)&&Array.isArray(raw.timeDeltas));assert.equal(raw.samples.length,raw.timeDeltas.length);
 assert(raw.timeDeltas.every(Number.isInteger));const duration=raw.endTime-raw.startTime;assert(Number.isFinite(duration)&&duration>0);
 const negatives=raw.timeDeltas.flatMap((value,index)=>value<0?[{index,value}]:[]);
 const correctionUs=negatives.reduce((n,x)=>n-x.value,0),correctionPpm=correctionUs/duration*1e6;
 const policy={maxNegativeMagnitudeUs:2,maxCorrectionPartsPerMillion:10};
 const reasons=[];
 if(!negatives.every(x=>-x.value<=policy.maxNegativeMagnitudeUs))reasons.push('Negative CPU delta exceeds 2us magnitude');
 if(correctionPpm>policy.maxCorrectionPartsPerMillion)reasons.push('CPU correction exceeds 10ppm of raw profile duration');
 const weightedStatus=reasons.length?'refused':'admitted';
 const counts=summarizeCpu({...raw,timeDeltas:raw.timeDeltas.map(()=>1)},moduleUrl);
 counts.unit='samples';counts.weighting='Every original CPU sample contributes exactly one, independent of timestamp deltas. Inclusive stacks overlap and must not be summed.';
 for(const frame of [...counts.frames,...counts.topSelf,...counts.topInclusive]){delete frame.selfUs;delete frame.inclusiveUs;}
 const signedRawUs=raw.timeDeltas.reduce((a,b)=>a+b,0),nonnegativeSumUs=raw.timeDeltas.reduce((n,x)=>n+Math.max(0,x),0);
 const accounting={weightSource:'max(timeDeltas[i],0) only when the explicit tiny-jitter policy admits a weighted view',weightedStatus,reasons,policy,
  negativeDeltas:negatives,negativeDeltaCount:negatives.length,signedRawTimeDeltaUs:signedRawUs,correctionUs,correctionPartsPerMillion:correctionPpm,
  admittedWeightedUs:weightedStatus==='admitted'?nonnegativeSumUs:null,profileDurationUs:duration,profileMinusSignedRawUs:duration-signedRawUs,
  profileMinusWeightedUs:weightedStatus==='admitted'?duration-nonnegativeSumUs:null,rawProfileUnmodified:true,
  scope:'Observed signed increments are retained; cause is not established. Negative values are clipped only in an admitted weighted view. Count-based summary is an independent view; no timing/semantic result is changed.'};
 counts.accounting={weightSource:'one per original CPU sample',sampleCount:raw.samples.length,weightedStatus,signedTimeAccounting:accounting};
 const weighted=weightedStatus==='admitted'?summarizeCpu({...raw,timeDeltas:raw.timeDeltas.map(x=>Math.max(0,x))},moduleUrl):null;
 if(weighted){
  weighted.accounting=accounting;
  weighted.weighting='Each CPU sample uses its preceding nonnegative time delta; admitted tiny negative increments contribute zero only in this view. Inspect signed raw accounting and sample-count summary.';
  if(negatives.length)weighted.warnings.push(`${negatives.length} negative deltas totaling ${correctionUs}us were clipped only in the weighted view (${correctionPpm} ppm); raw values and independent sample-count weights are preserved.`);
 }else counts.warnings.push('Weighted timestamp view REFUSED: '+reasons.join('; ')+'. Only sample-count attribution is available; units are samples, not microseconds.');
 return {weighted,counts,weightedStatus,accounting};
}

/** Caller imports/primes/warms first, and supplies the exact async request+oracle. */
export async function profile({mode,run,out,targetMs=5000,samplingIntervalUs=25000,
 samplingIntervalBytes=131072,maxRequests=32,moduleUrl='phase57:unspecified-compiler-module'}={}) {
 assert.equal(mode,'cpu','This successor is fixed CPU-only');assert.equal(typeof run,'function');
 assert(Number.isFinite(targetMs)&&targetMs>0&&targetMs<=10000);
 assert(Number.isInteger(maxRequests)&&maxRequests>=1&&maxRequests<=1000);
 assert.equal(samplingIntervalUs,25000,'Precommitted 25ms CPU sampling');
 assert.equal(samplingIntervalBytes,131072,'Precommitted 128KiB allocation sampling');
 assert.equal(typeof moduleUrl,'string');assert(moduleUrl.length>0);
 assert(!active,'One in-process profiler at a time');
 const directory=path.resolve(out);assert(directory.startsWith(rawRoot+path.sep));assert(!fs.existsSync(directory));
 const derivedFrom=identity(new URL('./profile-v2.mjs',import.meta.url));assert.equal(derivedFrom.sha256,'f472c5e565827e7a8cfc4181e19dffe61f4485c63a3d137c1315c82e388064f6');
 const method=identity(parent);assert.equal(method.sha256,parentSha,'Frozen summary method changed');assert.equal(identity(new URL('./profile.mjs',import.meta.url)).sha256,'3372be2a9db0b85e7391e9ac0e79a5500e355a2f3fd2f8c061e5880d0566b8c5','Consumed predecessor changed');
 fs.mkdirSync(directory,{recursive:true});assert(fs.realpathSync(directory).startsWith(fs.realpathSync(rawRoot)+path.sep));
 const rawFile=path.join(directory,mode==='cpu'?'profile.cpuprofile':'profile.heapprofile');
 const summaryFile=path.join(directory,'summary.json'),reportFile=path.join(directory,'report.json');
 // Reserve outputs before starting inspector; a failed profile keeps its receipt.
 const rawFd=fs.openSync(rawFile,'wx'),reportFd=fs.openSync(reportFile,'wx');
 const started=performance.now(),report={kind:'phase57-async-compiler-profile',complete:false,pass:false,
  diagnosticOnly:true,mode,schemaVersion:2,derivedFrom,producer:identity(import.meta.filename),predecessor:identity(new URL('./profile.mjs',import.meta.url)),summaryMethod:method,
  node:identity(process.execPath),nodeVersion:process.version,execArgv:process.execArgv,moduleUrl,
  targetMs,maxRequests,calls:0,requestMs:[],sampling:mode==='cpu'?{intervalMicroseconds:25000}:
   {intervalBytes:131072,includeObjectsCollectedByMajorGC:true,includeObjectsCollectedByMinorGC:true},
  timingBoundary:'Inspector encloses sequential awaited run() requests, their supplied correctness checks, and loop/Promise overhead. Caller import, first request and warmup must precede this helper. Serialization and summaries follow inspector stop. Profiled durations are never benchmark ratios.',
  limits:'The target is checked between whole requests; one request can exceed targetMs. Only the caller external process-tree supervisor enforces wall/RSS limits. Sampling is approximate; inclusive frame weights must never be summed.'};
 const checkpoint=()=>{fs.ftruncateSync(reportFd,0);fs.writeSync(reportFd,JSON.stringify(report,null,2)+'\n',0,'utf8');};
 let session,profilerStarted=false,failure;
 active=true;checkpoint();
 try{
  session=new Session();session.connect();
  if(mode==='cpu'){await session.post('Profiler.enable');await session.post('Profiler.setSamplingInterval',{interval:25000});await session.post('Profiler.start');}
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
    const views=mode==='cpu'?summarizeCpuViews(raw,moduleUrl):null;
    const summary=views?(views.weighted??views.counts):summarizeAllocation(raw,moduleUrl);
    if(views){report.weightedStatus=views.weightedStatus;report.weightedAccounting=views.accounting;report.summaryView=views.weighted?'weighted-time':'sample-count';const file=path.join(directory,'summary-counts.json');fs.writeFileSync(file,JSON.stringify(views.counts,null,2)+'\n',{flag:'wx'});report.sampleCountSummary=identity(file);}
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
  try{assert.deepEqual(identity(new URL('./profile-v2.mjs',import.meta.url)),derivedFrom);assert.deepEqual(identity(parent),method);assert.deepEqual(identity(import.meta.filename),report.producer);assert.deepEqual(identity(new URL('./profile.mjs',import.meta.url)),report.predecessor);}catch(error){failure??=asError(error);}
  if(failure)report.error={name:failure.name,message:failure.message,stack:failure.stack};
  else {report.complete=true;report.pass=true;}
  checkpoint();fs.closeSync(reportFd);active=false;
 }
 const result={...report,receipt:identity(reportFile)};
 if(failure){failure.profileReceipt=result.receipt;throw failure;}
 return result;
}
