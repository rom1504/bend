// Fresh-process compilation latency: native graph, same-source uncached JS,
// and an ordinary checked JS API using its validated Base prefix cache.
import fs from 'node:fs';import path from 'node:path';import {fileURLToPath} from 'node:url';import {spawnSync} from 'node:child_process';import {createHash} from 'node:crypto';
import {verifyNativeBuildEvidence,nativeBuildTiming} from './native-build-evidence.mjs';
import {runNativeGraph,loadNativeGraphManifest} from './native-graph-run.mjs';
const tool=fileURLToPath(import.meta.url),sha=file=>createHash('sha256').update(fs.readFileSync(file)).digest('hex'),save=(file,value)=>fs.writeFileSync(file,JSON.stringify(value,null,2)+'\n');
if(['--host','--native','--warm'].includes(process.argv[2])){
  const kind=process.argv[2],request=JSON.parse(fs.readFileSync(process.argv[3],'utf8'));let report;
  if(kind==='--native')report=runNativeGraph({...request,mode:'program'});
  else{
    process.env.BEND_TYPED_API=request.api;process.env.BEND_TYPED_RUNTIME=request.runtime;process.env.BEND_BASE=request.base;
    const D=await import('../../typed-driver.mjs'),api={...await D.loadApi()};
    if(kind==='--warm'){
      if(!api.check_from_exact_prefix||!api.f_load_graph_seed)throw Error('Cached comparison requires the real validated prefix+graph-seed API');
      const location=createHash('sha256').update(fs.realpathSync(request.base)).digest('hex'),cacheFile=path.join(D.project,'build/typed/cache',`base-${sha(request.api)}-${sha(request.base)}-${location}.json`),existedBefore=fs.existsSync(cacheFile);
      const start=performance.now(),cache=await D.prepareBase(api);
      report={kind:'validated-base-cache-preparation',milliseconds:performance.now()-start,version:cache.version,compilerSha256:cache.compilerSha256,baseSha256:cache.baseSha256,bookSha256:cache.bookSha256,sourcePath:cache.sourcePath,validatedBy:cache.validatedBy,generated:cache.generated,cacheFile,existedBefore,cacheFileSha256:sha(cacheFile)};
    }else{
      if(request.variant==='uncached')for(const name of ['check_from_exact_prefix','exact_prefix','f_load_graph_seed'])delete api[name];
      for(const name of ['check_book_diagnostic','diagnostic_render','f_load_origins_for','diagnostic_result_locate'])delete api[name];
      const started=performance.now(),result=await D.inspect(request.input,{mode:'compile',api});
      report={...result,compileMs:performance.now()-started};delete report.code;
      if(result.status==='ok'){fs.writeFileSync(request.output,result.code);report.published=true;report.outputSha256=sha(request.output);report.outputBytes=Buffer.byteLength(result.code);}
    }
  }
  save(request.result,report);if(kind!=='--warm'&&!report.published)process.exitCode=1;
}else if(process.argv[1]&&path.resolve(process.argv[1])===tool){
  const [configFile,outputDirectory]=process.argv.slice(2);if(!configFile||!outputDirectory)throw Error('usage: native-graph-measure.mjs CONFIG.json NEW_OUTPUT_DIRECTORY');
  const config=JSON.parse(fs.readFileSync(configFile,'utf8')),resolve=file=>fs.realpathSync(path.resolve(path.dirname(path.resolve(configFile)),file));
  const files=Object.fromEntries(['binary','api','cachedApi','base','runtime'].map(name=>[name,resolve(config[name])])),hashes=Object.fromEntries(Object.entries(files).map(([name,file])=>[name,sha(file)]));
  const cpu=config.cpu,repetitions=config.repetitions??3,timeoutMs=config.timeoutMs??120000;
  if(!Number.isSafeInteger(cpu)||cpu<0||!Number.isSafeInteger(repetitions)||repetitions<1||repetitions>20)throw Error('Explicit CPU and bounded positive repetitions required');
  const output=path.resolve(outputDirectory);fs.mkdirSync(output,{recursive:false});
  const workloads=config.workloads.map(work=>({...work,input:resolve(work.input),manifest:resolve(work.manifest)}));
  if(!workloads.length||new Set(workloads.map(work=>work.id)).size!==workloads.length||workloads.some(work=>!/^[-a-z0-9]+$/.test(work.id)))throw Error('Unique simple workload ids required');
  const consumedTools=[tool,...['native-graph-run.mjs','native-build-evidence.mjs'].map(file=>fileURLToPath(new URL(file,import.meta.url))),...['typed-driver.mjs','compiler-abi.mjs','node-resource-args.mjs','assemble.mjs','native-build.mjs'].map(file=>fileURLToPath(new URL('../../'+file,import.meta.url))),process.execPath];
  const exposureFile=path.join(path.dirname(files.api),'exposure.json'),exposure=JSON.parse(fs.readFileSync(exposureFile,'utf8')),checked=JSON.parse(fs.readFileSync(exposure.buildReport,'utf8')),cBuildFile=files.binary+'.build.json',cBuild=JSON.parse(fs.readFileSync(cBuildFile,'utf8'));
  if(exposure.api!==files.api||hashes.api!==exposure.apiSha256||sha(exposure.workers)!==exposure.workersSha256)throw Error('Exposed checked JS workers changed');
  verifyNativeBuildEvidence({checked,cBuild,exposure,binary:files.binary});
  const cachedBuildFile=files.cachedApi+'.bootstrap.json',cachedBuild=JSON.parse(fs.readFileSync(cachedBuildFile,'utf8')),preparationFile=path.join(path.dirname(checked.source),'preparation.json'),preparation=JSON.parse(fs.readFileSync(preparationFile,'utf8'));
  if(cachedBuild.apiSha256!==hashes.cachedApi||sha(cachedBuild.source)!==cachedBuild.sourceSha256||JSON.stringify(cachedBuild.modules)!==JSON.stringify(preparation.modules))throw Error('Cached B1 and native compiler modules differ');
  const availableInputs=workloads.flatMap(work=>{const graph=loadNativeGraphManifest(work.manifest);return [...graph.modules,...graph.moduleAliases,...graph.assets].filter(input=>!input.missing).flatMap(input=>[input.path,input.lexical]);});
  consumedTools.push(exposureFile,exposure.workers,exposure.buildReport,cBuildFile,checked.source,checked.javascript.file,checked.c.file,cachedBuildFile,cachedBuild.source,preparationFile,...availableInputs,...workloads.flatMap(work=>[work.input,work.manifest]));
  const toolHashes=Object.fromEntries(consumedTools.map(file=>[file,sha(file)]));
  const report={kind:'native-graph-cached-uncached-latency',started:new Date().toISOString(),files,hashes,toolHashes,cpu,repetitions,cachedBuild:{report:cachedBuildFile,sourceSha256:cachedBuild.sourceSha256,moduleCount:cachedBuild.modules.length,modulesEqual:true},node:process.version,nodeArgs:['--stack-size=4096'],workloads,complete:false,rows:[],build:{checked:exposure.buildReport,c:cBuildFile,...nativeBuildTiming(checked,cBuild)},scope:'Fresh Node processes per sample. processWallMs includes startup/host work/output; native wallMs additionally separates wrapper overhead; uncached JS fully checks Base; cached JS uses an explicitly prepared validated Base prefix.'};
  const reportFile=path.join(output,'report.json'),flush=()=>save(reportFile,report);
  const child=args=>spawnSync('taskset',['-c',String(cpu),process.execPath,'--stack-size=4096',...args],{encoding:'utf8',timeout:timeoutMs+10000,maxBuffer:16*1024*1024});
  const warm={...files,api:files.cachedApi,result:path.join(output,'warm.json')};save(path.join(output,'warm-request.json'),warm);flush();
  const warming=child([tool,'--warm',path.join(output,'warm-request.json')]);if(warming.status!==0||warming.error)throw Error('Base cache setup failed: '+(warming.error?.message??warming.stderr));report.cachePreparation=JSON.parse(fs.readFileSync(warm.result,'utf8'));toolHashes[report.cachePreparation.cacheFile]=report.cachePreparation.cacheFileSha256;flush();
  const variants=['native','uncached','cached'];
  for(let repetition=0;repetition<repetitions;repetition++)for(const work of workloads)for(let offset=0;offset<variants.length;offset++){
    const variant=variants[(repetition+offset)%variants.length],id=`${work.id}-${repetition}-${variant}`,request={...files,api:variant==='cached'?files.cachedApi:files.api,input:work.input,manifest:work.manifest,output:path.join(output,id+'.mjs'),result:path.join(output,id+'.json'),variant,cpu,timeoutMs};
    const requestFile=path.join(output,id+'-request.json');save(requestFile,request);console.error('[native graph latency] '+id);
    const row={workload:work.id,repetition,variant,passed:false};report.rows.push(row);flush();
    const started=performance.now(),result=child([tool,variant==='native'?'--native':'--host',requestFile]);row.processWallMs=performance.now()-started;
    row.status=result.status;row.error=result.error?.message;row.stderr=result.stderr;
    if(fs.existsSync(request.result))row.compilation=JSON.parse(fs.readFileSync(request.result,'utf8'));
    if(result.status===0&&!result.error&&row.compilation?.published){
      const prior=report.rows.find(other=>other!==row&&other.workload===row.workload&&other.passed);
      row.sameOutput=!prior||prior.compilation.outputSha256===row.compilation.outputSha256;
      const execution=child([request.output]);row.execution={status:execution.status,stdout:execution.stdout,stderr:execution.stderr};
      row.passed=row.sameOutput&&execution.status===0&&!execution.error&&(work.stdout===undefined||execution.stdout===work.stdout);
    }
    flush();
  }
  const median=values=>{const sorted=[...values].sort((a,b)=>a-b);return sorted[Math.floor(sorted.length/2)];};
  report.medians=Object.fromEntries(workloads.map(work=>[work.id,Object.fromEntries(variants.map(variant=>{const rows=report.rows.filter(row=>row.workload===work.id&&row.variant===variant);return [variant,{processWallMs:median(rows.map(row=>row.processWallMs)),compileMs:median(rows.map(row=>row.compilation?.compileMs)),wrapperWallMs:variant==='native'?median(rows.map(row=>row.compilation?.wallMs)):undefined}];}))]));
  report.inputsUnchanged=Object.entries(files).every(([name,file])=>sha(file)===hashes[name]);report.toolsUnchanged=Object.entries(toolHashes).every(([file,expected])=>sha(file)===expected);report.complete=report.inputsUnchanged&&report.toolsUnchanged&&report.rows.length===workloads.length*variants.length*repetitions&&report.rows.every(row=>row.passed);report.finished=new Date().toISOString();flush();
  console.log(JSON.stringify({report:reportFile,complete:report.complete,medians:report.medians}));if(!report.complete)process.exitCode=1;
}
