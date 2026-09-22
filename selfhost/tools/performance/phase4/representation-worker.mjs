// One compile in a fresh process; validated Base preparation is separately timed.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import {pathToFileURL} from 'node:url';
const request=JSON.parse(fs.readFileSync(process.argv[2])),hash=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
process.env.BEND_TYPED_API=request.api;process.env.BEND_TYPED_RUNTIME=request.runtime;process.env.BEND_BASE=request.base;delete process.env.BEND_TYPED_TRACE;
const raw=await import(pathToFileURL(request.api)),D=await import(pathToFileURL(request.driver)),original=await D.loadApi(),api={},phases=[];
const copyCounts=()=>raw.representationCounts?structuredClone(raw.representationCounts):null;
for(const [name,fn] of Object.entries(original))api[name]=typeof fn==='function'?(...args)=>{const before=copyCounts(),start=performance.now();try{return fn(...args);}finally{phases.push({name,milliseconds:performance.now()-start,before,after:copyCounts()});}}:fn;
if(request.cache!=='validated'){api.f_load_graph_seed=undefined;api.check_from_exact_prefix=undefined;}api.driver_report=undefined;api.f_main_names=undefined;api.f_parsed_main_names=undefined;
let preparation=null;
if(request.cache==='validated'){
 const version=api.f_load_graph_seed?2:1,sourcePath=fs.realpathSync(request.base),location=crypto.createHash('sha256').update(sourcePath).digest('hex');
 const cacheFile=path.join(D.project,'build/typed/cache',`base-${hash(request.api)}-${hash(request.base)}${version===2?'-'+location:''}.json`),existedBefore=fs.existsSync(cacheFile),start=performance.now();
 const cached=await D.prepareBase(api);
 preparation={milliseconds:performance.now()-start,existedBefore,cacheFile,cacheSha256:hash(cacheFile),bookSha256:cached.bookSha256,validatedBy:cached.validatedBy,phases:phases.splice(0),counts:copyCounts()};
}
raw.resetRepresentationCounts?.();const start=performance.now(),cpu=process.cpuUsage();const result=await D.inspect(request.input,{mode:request.mode??'compile',api}),used=process.cpuUsage(cpu),milliseconds=performance.now()-start;
const report={cache:request.cache??'off',preparation,mode:request.mode??'compile',status:result.status,phase:result.phase,checked:result.checked,milliseconds,cpuMilliseconds:(used.user+used.system)/1000,maxRssKiB:process.resourceUsage().maxRSS,phases,counts:copyCounts(),apiSha256:hash(request.api),inputSha256:hash(request.input),runtimeSha256:hash(request.runtime),driverSha256:hash(request.driver)};
if(result.code){fs.writeFileSync(request.output,result.code);report.outputSha256=hash(request.output);report.outputBytes=fs.statSync(request.output).size;}else report.result=result;
fs.writeFileSync(request.report,JSON.stringify(report,null,2)+'\n');if(result.status!=='ok'||!result.checked)process.exitCode=1;
