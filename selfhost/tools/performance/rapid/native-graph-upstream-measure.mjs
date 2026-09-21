// Separate live pinned-TypeScript samples extending a completed native/cache report.
// Compiler algorithms and checking run through the existing upstream worker.
import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import {fileURLToPath} from 'node:url';
import {loadNativeGraphManifest} from './native-graph-run.mjs';

const sha=file=>createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const save=(file,value)=>fs.writeFileSync(file,JSON.stringify(value,null,2)+'\n');
const [priorFile,upstreamArgument,outputArgument]=process.argv.slice(2);
if(!priorFile||!upstreamArgument||!outputArgument)throw Error('usage: native-graph-upstream-measure.mjs LATENCY_REPORT.json PINNED_UPSTREAM NEW_OUTPUT_DIRECTORY');
const priorPath=fs.realpathSync(priorFile),prior=JSON.parse(fs.readFileSync(priorPath,'utf8'));
if(!prior.complete||prior.kind!=='native-graph-cached-uncached-latency')throw Error('A complete native/cache comparison is required');
const upstream=fs.realpathSync(upstreamArgument),output=path.resolve(outputArgument);
const git=args=>{const result=spawnSync('git',['-C',upstream,...args],{encoding:'utf8'});if(result.status!==0)throw Error(result.stderr);return result.stdout.trim();};
const nativeBuild=JSON.parse(fs.readFileSync(prior.build.checked,'utf8'));
const pin=git(['rev-parse','HEAD']);
if(pin!==nativeBuild.pin||git(['status','--porcelain','--untracked-files=no']))throw Error('Upstream must match the checked native build pin and have no tracked modifications');
if(fs.realpathSync(prior.files.base)!==fs.realpathSync(path.join(upstream,'bend2/base.bend')))throw Error('Prior comparison must use the pinned upstream Base path');
if(process.version!==prior.node||sha(process.execPath)!==prior.toolHashes[process.execPath])throw Error('Node differs from the prior comparison');
const worker=fileURLToPath(new URL('../compare-worker.mjs',import.meta.url));
const inputs=new Set([priorPath,worker,fileURLToPath(import.meta.url),fileURLToPath(new URL('native-graph-run.mjs',import.meta.url)),process.execPath]);
for(const relative of git(['ls-files','bend2']).split('\n').filter(Boolean)){
  const file=path.join(upstream,relative);if(fs.statSync(file).isFile())inputs.add(file);
}
for(const work of prior.workloads){
  const graph=loadNativeGraphManifest(work.manifest);
  for(const file of [work.input,work.manifest,...[...graph.modules,...graph.moduleAliases,...graph.assets].filter(item=>!item.missing).flatMap(item=>[item.path,item.lexical])]){
    if(prior.toolHashes[file]!==sha(file))throw Error('Workload changed since prior comparison: '+file);
    inputs.add(file);
  }
}
const hashes=Object.fromEntries([...inputs].map(file=>[file,sha(file)]));
fs.mkdirSync(output,{recursive:false});
const report={kind:'native-graph-live-upstream-latency-extension',started:new Date().toISOString(),priorReport:priorPath,priorReportSha256:hashes[priorPath],upstream,pin,trackedClean:true,node:process.version,cpu:prior.cpu,nodeArgs:prior.nodeArgs,repetitions:prior.repetitions,hashes,rows:[],complete:false,scope:'Separate subsequent samples, not interleaved with the prior native/cache experiment. Same CPU, Node flags, physical inputs and fresh-process policy. Pinned TypeScript fully loads/checks Base in each process and has no persistent Base prefix cache. Process wall includes startup, checking, emission and output write; execution is a separate oracle. Emitted JS bytes may differ across compilers.'};
const reportFile=path.join(output,'report.json'),flush=()=>save(reportFile,report);
const child=args=>spawnSync('taskset',['-c',String(prior.cpu),process.execPath,...prior.nodeArgs,...args],{encoding:'utf8',timeout:120000,maxBuffer:16*1024*1024});
flush();
for(let repetition=0;repetition<prior.repetitions;repetition++)for(const work of prior.workloads){
  const id=`${work.id}-${repetition}`,requestFile=path.join(output,id+'-request.json'),resultFile=path.join(output,id+'.json'),emitted=path.join(output,id+'.cjs');
  save(requestFile,{variant:{kind:'upstream'},input:work.input,output:emitted,upstream,cache:'off'});
  console.error('[live upstream latency] '+id);
  const row={workload:work.id,repetition,passed:false};report.rows.push(row);flush();
  const started=performance.now(),result=child([worker,requestFile,resultFile]);row.processWallMs=performance.now()-started;
  row.status=result.status;row.error=result.error?.message;row.stderr=result.stderr;
  if(result.status===0&&!result.error){
    row.compilation=JSON.parse(fs.readFileSync(resultFile,'utf8'));row.outputSha256=sha(emitted);
    const execution=child([emitted]);row.execution={status:execution.status,stdout:execution.stdout,stderr:execution.stderr};
    const priorRow=prior.rows.find(sample=>sample.workload===work.id&&sample.passed);
    row.passed=execution.status===0&&!execution.error&&execution.stdout===priorRow.execution.stdout&&(work.stdout===undefined||execution.stdout===work.stdout);
  }
  flush();
}
const median=values=>[...values].sort((a,b)=>a-b)[Math.floor(values.length/2)];
report.medians=Object.fromEntries(prior.workloads.map(work=>{const rows=report.rows.filter(row=>row.workload===work.id);return [work.id,{...prior.medians[work.id],upstream:{processWallMs:median(rows.map(row=>row.processWallMs)),compileMs:median(rows.map(row=>row.compilation?.compileMs))}}];}));
report.inputsUnchanged=Object.entries(hashes).every(([file,hash])=>sha(file)===hash);
report.trackedStillClean=git(['rev-parse','HEAD'])===pin&&!git(['status','--porcelain','--untracked-files=no']);
report.complete=report.inputsUnchanged&&report.trackedStillClean&&report.rows.every(row=>row.passed);report.finished=new Date().toISOString();flush();
console.log(JSON.stringify({report:reportFile,complete:report.complete,medians:report.medians}));if(!report.complete)process.exitCode=1;
