// Interleaved checked-bootstrap B1, proven self-emitted H, and pinned TS latency.
// Host/compiler computation is reused from existing measured workers.
import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {loadNativeGraphManifest} from './native-graph-run.mjs';
const tool=fileURLToPath(import.meta.url),sha=p=>createHash('sha256').update(fs.readFileSync(p)).digest('hex'),save=(p,v)=>fs.writeFileSync(p,JSON.stringify(v,null,2)+'\n');
const [configArgument,outputArgument]=process.argv.slice(2);
if(!configArgument||!outputArgument)throw Error('usage: selfhost-cache-measure.mjs CONFIG.json NEW_OUTPUT_DIRECTORY');
const configFile=fs.realpathSync(configArgument),config=JSON.parse(fs.readFileSync(configFile,'utf8')),resolve=p=>fs.realpathSync(path.resolve(path.dirname(configFile),p));
const priorFile=resolve(config.priorReport),proofFile=resolve(config.selfhostReport),prior=JSON.parse(fs.readFileSync(priorFile,'utf8')),proof=JSON.parse(fs.readFileSync(proofFile,'utf8'));
if(!prior.complete||prior.kind!=='native-graph-cached-uncached-latency')throw Error('A completed prior workload comparison is required');
if(!proof.complete||proof.stages?.length<2||!proof.base||!proof.hostHelpers||proof.stages.some(s=>s.code!==0||s.signal||s.inputsVerified!==true))throw Error('Completed input-verified self-emission proof required');
const stages=proof.stages,first=stages[0],last=stages.at(-1);
const identity=item=>{if(!item?.file||sha(item.file)!==item.sha256||item.canonicalPath&&fs.realpathSync(item.file)!==item.canonicalPath)throw Error('Changed proof identity: '+item?.file);};
for(const item of [proof.sourceIdentity,proof.base,proof.initialCompiler,proof.driver,...proof.hostHelpers])identity(item);
if(proof.sourceSha256!==sha(proof.source)||proof.sourceSha256!==prior.cachedBuild.sourceSha256||proof.initialCompiler.sha256!==first.compilerSha256)throw Error('Proof source or initial compiler differs from prior workload compiler');
for(let i=0;i<stages.length;i++){
 const s=stages[i];if(sha(s.compiler)!==s.compilerSha256||sha(s.output)!==s.outputSha256||i&&s.compilerSha256!==stages[i-1].outputSha256)throw Error('Broken self-emission stage chain');
}
if(first.outputSha256!==last.outputSha256)throw Error('Self-emitted stage bytes do not match');
const apiH=fs.realpathSync(last.output),apiB1=fs.realpathSync(prior.files.cachedApi),bootstrapFile=apiB1+'.bootstrap.json',bootstrap=JSON.parse(fs.readFileSync(bootstrapFile,'utf8'));
if(sha(apiB1)!==bootstrap.apiSha256||bootstrap.apiSha256!==proof.initialCompiler.sha256||sha(bootstrap.source)!==bootstrap.sourceSha256||bootstrap.sourceSha256!==proof.sourceSha256)throw Error('B1 bootstrap and H proof do not identify the same source');
for(const m of bootstrap.modules)if(sha(path.join(path.dirname(bootstrap.source),m.file))!==m.sha256)throw Error('Changed checked source module '+m.file);
const base=fs.realpathSync(prior.files.base),runtime=fs.realpathSync(prior.files.runtime),upstream=resolve(config.upstream);
if(sha(runtime)!==proof.runtimeSha256||sha(runtime)!==prior.hashes.runtime||sha(base)!==prior.hashes.base||sha(base)!==proof.base.sha256||base!==fs.realpathSync(path.join(upstream,'bend2/base.bend')))throw Error('Runtime or canonical pinned Base differs');
const git=args=>{const p=spawnSync('git',['-C',upstream,...args],{encoding:'utf8'});if(p.status!==0)throw Error(p.stderr);return p.stdout.trim();};
const pin=git(['rev-parse','HEAD']);if(pin!==bootstrap.revision||git(['status','--porcelain','--untracked-files=no']))throw Error('Upstream revision or tracked source differs');
const cpu=config.cpu,repetitions=config.repetitions??3,timeoutMs=config.timeoutMs??120000;
if(!Number.isSafeInteger(cpu)||cpu<0||!Number.isSafeInteger(repetitions)||repetitions<1||repetitions>10||!Number.isSafeInteger(timeoutMs)||timeoutMs<=0)throw Error('Valid CPU, bounded repetition count and positive timeout required');
if(process.version!==prior.node||sha(process.execPath)!==prior.toolHashes[process.execPath])throw Error('Node differs from prior comparison');
const worker=fileURLToPath(new URL('native-graph-measure.mjs',import.meta.url)),tsWorker=fileURLToPath(new URL('../compare-worker.mjs',import.meta.url));
const currentTools=[tool,worker,tsWorker,fileURLToPath(new URL('native-graph-run.mjs',import.meta.url)),...['typed-driver.mjs','compiler-abi.mjs','node-resource-args.mjs','assemble.mjs','native-build.mjs'].map(n=>fileURLToPath(new URL('../../'+n,import.meta.url)))];
const allInputs=new Set([configFile,priorFile,proofFile,apiB1,apiH,bootstrapFile,base,runtime,process.execPath,...currentTools,...[proof.sourceIdentity,proof.base,proof.initialCompiler,proof.driver,...proof.hostHelpers].map(i=>i.file),...stages.flatMap(s=>[s.compiler,s.output]),...bootstrap.modules.map(m=>path.join(path.dirname(bootstrap.source),m.file))]);
for(const relative of git(['ls-files','bend2']).split('\n').filter(Boolean)){const p=path.join(upstream,relative);if(fs.statSync(p).isFile())allInputs.add(p);}
for(const work of prior.workloads){
 const graph=loadNativeGraphManifest(work.manifest);
 for(const p of [work.input,work.manifest,...[...graph.modules,...graph.moduleAliases,...graph.assets].filter(x=>!x.missing).flatMap(x=>[x.path,x.lexical])]){
  if(sha(p)!==prior.toolHashes[p])throw Error('Workload changed since original comparison: '+p);allInputs.add(p);
 }
}
const output=path.resolve(outputArgument);fs.mkdirSync(output,{recursive:false});const copies=path.join(output,'consumed-tools');fs.mkdirSync(copies);
const toolSnapshots=currentTools.map((file,index)=>{const copy=path.join(copies,index+'-'+path.basename(file));fs.copyFileSync(file,copy);fs.chmodSync(copy,0o444);return {file,copy,sha256:sha(file)};});
const hashes=Object.fromEntries([...allInputs].map(p=>[p,sha(p)]));
const report={kind:'interleaved-b1-self-emitted-h-typescript-latency',started:new Date().toISOString(),node:process.version,nodeArgs:prior.nodeArgs,cpu,repetitions,timeoutMs,priorReport:{file:priorFile,sha256:sha(priorFile)},selfhostProof:{file:proofFile,sha256:sha(proofFile),sourceSha256:proof.sourceSha256,stages,complete:true},checkedBootstrap:{file:bootstrapFile,sha256:sha(bootstrapFile),api:apiB1,apiSha256:sha(apiB1),moduleCount:bootstrap.modules.length},apiH,apiHSha256:sha(apiH),upstream,pin,base,runtime,workloads:prior.workloads,hashes,toolSnapshots,hostChangesSincePrior:currentTools.filter(p=>prior.toolHashes[p]&&prior.toolHashes[p]!==hashes[p]).map(file=>({file,priorSha256:prior.toolHashes[file],currentSha256:hashes[file]})),scope:'Fresh processes and rotating variant order on one CPU. B1 and proven self-emitted H use the same current native-graph-measure --host cached policy; each validated Base cache is primed and recorded separately. TypeScript fully checks Base per fresh process. H provenance is a completed self-emission chain, not a bootstrap report. Prior native timings are separate historical samples. processWallMs includes startup/host/output; program execution is a separate oracle.',cachePreparation:{},rows:[],complete:false};
const childEnv={...process.env};delete childEnv.NODE_OPTIONS;delete childEnv.BEND_TYPED_TRACE;
report.childEnvironmentPolicy='Inherited environment with NODE_OPTIONS and BEND_TYPED_TRACE removed; compiler, runtime and Base paths are set by each worker request.';
const reportFile=path.join(output,'report.json'),flush=()=>save(reportFile,report),child=args=>spawnSync('taskset',['-c',String(cpu),process.execPath,...report.nodeArgs,...args],{encoding:'utf8',env:childEnv,timeout:timeoutMs,maxBuffer:16*1024*1024});flush();
for(const [variant,api] of [['B1',apiB1],['H',apiH]]){
 const request={api,base,runtime,result:path.join(output,'warm-'+variant+'.json')},file=path.join(output,'warm-'+variant+'-request.json');save(file,request);console.error('[self-host latency] prepare '+variant+' Base cache');
 const start=performance.now(),p=child([worker,'--warm',file]);const result={status:p.status,error:p.error?.message,stderr:p.stderr,processWallMs:performance.now()-start};
 if(fs.existsSync(request.result))Object.assign(result,JSON.parse(fs.readFileSync(request.result,'utf8')));report.cachePreparation[variant]=result;flush();
 if(p.status!==0||p.error)throw Error('Cache preparation failed for '+variant);hashes[result.cacheFile]=result.cacheFileSha256;console.error('[self-host latency] ready '+variant+' cache '+JSON.stringify({file:result.cacheFile,existedBefore:result.existedBefore,processWallMs:result.processWallMs,milliseconds:result.milliseconds}));
}
const variants=['B1','H','typescript'];
for(let repetition=0;repetition<repetitions;repetition++)for(const work of prior.workloads)for(let offset=0;offset<variants.length;offset++){
 const variant=variants[(repetition+offset)%variants.length],id=work.id+'-'+repetition+'-'+variant,emitted=path.join(output,id+(variant==='typescript'?'.cjs':'.mjs')),resultFile=path.join(output,id+'.json'),requestFile=path.join(output,id+'-request.json');
 const request=variant==='typescript'?{variant:{kind:'upstream'},input:work.input,output:emitted,upstream,cache:'off'}:{api:variant==='H'?apiH:apiB1,base,runtime,input:work.input,output:emitted,result:resultFile,variant:'cached'};save(requestFile,request);
 console.error('[self-host latency] '+id);const row={workload:work.id,repetition,variant,passed:false};report.rows.push(row);flush();
 const start=performance.now(),p=child(variant==='typescript'?[tsWorker,requestFile,resultFile]:[worker,'--host',requestFile]);row.processWallMs=performance.now()-start;row.status=p.status;row.error=p.error?.message;row.stderr=p.stderr;
 if(fs.existsSync(resultFile))row.compilation=JSON.parse(fs.readFileSync(resultFile,'utf8'));
 if(p.status===0&&!p.error&&fs.existsSync(emitted)){
  row.outputSha256=sha(emitted);const priorRow=prior.rows.find(r=>r.workload===work.id&&r.passed);
  row.samePortOutput=variant==='typescript'?null:row.outputSha256===priorRow.compilation.outputSha256;
  const execution=child([emitted]);row.execution={status:execution.status,stdout:execution.stdout,stderr:execution.stderr};row.passed=row.samePortOutput!==false&&execution.status===0&&!execution.error&&execution.stdout===priorRow.execution.stdout&&(work.stdout===undefined||execution.stdout===work.stdout);
 }
 flush();
}
const median=a=>[...a].sort((a,b)=>a-b)[Math.floor(a.length/2)];
report.medians=Object.fromEntries(prior.workloads.map(work=>[work.id,Object.fromEntries(variants.map(variant=>{const rows=report.rows.filter(r=>r.workload===work.id&&r.variant===variant);return [variant,{processWallMs:median(rows.map(r=>r.processWallMs)),compileMs:median(rows.map(r=>r.compilation?.compileMs))}];}))]));
report.inputsUnchanged=Object.entries(hashes).every(([p,h])=>sha(p)===h);report.trackedStillClean=git(['rev-parse','HEAD'])===pin&&!git(['status','--porcelain','--untracked-files=no']);report.complete=report.inputsUnchanged&&report.trackedStillClean&&report.rows.length===prior.workloads.length*variants.length*repetitions&&report.rows.every(r=>r.passed);report.finished=new Date().toISOString();flush();console.log(JSON.stringify({report:reportFile,complete:report.complete,medians:report.medians}));if(!report.complete)process.exitCode=1;
