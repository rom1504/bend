#!/usr/bin/env node
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawn} from 'node:child_process';
import {pathToFileURL} from 'node:url';
import {inventory,probes,sha256} from './inventory.mjs';
import {judge} from './judge.mjs';

const project=path.resolve(import.meta.dirname,'../..');
const options={upstream:process.env.BEND_UPSTREAM||path.resolve(project,'../upstream-bend'),
  adapter:path.join(import.meta.dirname,'adapters/prototype.mjs'),output:path.join(project,'tests/conformance/latest.json'),
  jobs:8,timeout:5000,lanes:'parse,check,interpreter,js,native,metal,cuda',filter:'',gpu:'','stack-kb':0,'heap-mb':0};
for(let i=2;i<process.argv.length;i++) {
  const arg=process.argv[i];
  if(arg==='--help') {
    console.log('node tools/conformance/run.mjs [--upstream PATH] [--adapter PATH] [--output PATH] [--jobs N] [--timeout MS] [--stack-kb N] [--heap-mb N] [--lanes parse,check,interpreter,js,native,metal,cuda] [--filter REGEX] [--gpu metal,cuda]');
    process.exit(0);
  }
  const key=arg.slice(2);
  if(!arg.startsWith('--')||!(key in options)||process.argv[i+1]===undefined) throw Error('Unknown/incomplete option '+arg);
  options[key]=process.argv[++i];
}
for(const key of ['upstream','adapter','output']) options[key]=path.resolve(options[key]);
for(const key of ['jobs','timeout']) {
  options[key]=Number(options[key]);
  if(!Number.isInteger(options[key])||options[key]<1) throw Error(`Invalid --${key}`);
}
for(const key of ['stack-kb','heap-mb']) {
  options[key]=Number(options[key]);
  if(!Number.isInteger(options[key])||options[key]<0)throw Error(`Invalid --${key}`);
}
const workerNodeArgs=[...(options['stack-kb']?[`--stack-size=${options['stack-kb']}`]:[]),
  ...(options['heap-mb']?[`--max-old-space-size=${options['heap-mb']}`]:[])];
const laneNames=['parse','check','interpreter','js','native','metal','cuda'];
const lanes=options.lanes.split(',');
if(lanes.some(l=>!laneNames.includes(l))) throw Error('Unknown lane');
const manifest=inventory(options.upstream);
const adapter=await import(pathToFileURL(options.adapter));
if(!adapter.capabilities||typeof adapter.probe!=='function') throw Error('Adapter must export capabilities and probe');
const initialIdentity={adapter:adapter.name||options.adapter,capabilities:adapter.capabilities,adapterSha256:sha256(fs.readFileSync(options.adapter)),
  artifacts:Object.fromEntries(Object.entries(adapter.artifacts||{}).map(([name,file])=>[name,{file,sha256:sha256(fs.readFileSync(file))}]))};
const matches=new RegExp(options.filter);
const tests=manifest.tests.filter(t=>matches.test(t.id));
const jobs=tests.flatMap(test=>probes(test).filter(p=>lanes.includes(p.lane)).map(p=>({test,...p})));
const temporary=fs.mkdtempSync(path.join(os.tmpdir(),'bend-conformance-'));
const results=[];
fs.mkdirSync(path.dirname(options.output),{recursive:true});
const progressFile=options.output.replace(/\.json$/, '')+'.progress.jsonl';
fs.writeFileSync(progressFile,'');
function record(row) {results.push(row);fs.appendFileSync(progressFile,JSON.stringify(row)+'\n');}
let next=0;
const started=new Date().toISOString();

function runWorker(request) {
  return new Promise(resolve=>{
    const file=path.join(request.workdir,'request.json');
    fs.writeFileSync(file,JSON.stringify(request));
    const child=spawn(process.execPath,[...workerNodeArgs,path.join(import.meta.dirname,'worker.mjs'),file],
      {cwd:request.workdir,stdio:['ignore','pipe','pipe'],detached:process.platform!=='win32'});
    let stdout='',stderr='',timedOut=false,overflow=false;
    function stop() {
      try { if(process.platform!=='win32') process.kill(-child.pid,'SIGKILL'); else child.kill('SIGKILL'); } catch {}
    }
    const capture=which=>data=>{
      if(which==='stdout') stdout+=data; else stderr+=data;
      if(stdout.length+stderr.length>2**20) {overflow=true;stop();}
    };
    child.stdout.on('data',capture('stdout'));child.stderr.on('data',capture('stderr'));
    const alarm=setTimeout(()=>{timedOut=true;stop();},options.timeout);
    child.on('error',error=>{clearTimeout(alarm);resolve({status:'crash',reason:error.message});});
    child.on('close',code=>{
      clearTimeout(alarm);
      // Kill stragglers, including subprocesses spawned by effect implementations.
      stop();
      if(timedOut) return resolve({status:'timeout',reason:`Probe exceeded ${options.timeout} ms.`,stdout:stdout.slice(-16384),stderr:stderr.slice(-16384)});
      if(overflow) return resolve({status:'crash',reason:'Probe exceeded output limit.',stdout:stdout.slice(-16384),stderr:stderr.slice(-16384)});
      try {resolve(JSON.parse(fs.readFileSync(request.response,'utf8')));}
      catch {resolve({status:'crash',reason:'Worker returned no valid result',exitCode:code,stdout,stderr});}
    });
  });
}

function hardwareGate(lane) {
  if(lane!=='metal'&&lane!=='cuda') return null;
  if(!options.gpu.split(',').includes(lane)) return 'GPU execution requires explicit --gpu '+lane+' on a verified host.';
  if(lane==='metal'&&process.platform!=='darwin') return 'Metal requires an Apple host.';
  if(lane==='cuda'&&!fs.existsSync('/dev/nvidiactl')) return 'CUDA device is unavailable.';
  return null;
}
try {
  await Promise.all(Array.from({length:Math.min(options.jobs,jobs.length)},async()=>{
    while(next<jobs.length) {
      const index=next++,{test,lane}=jobs[index],start=performance.now();
      const base={id:test.id,namespace:test.namespace,negative:test.negative,lane};
      const gate=hardwareGate(lane);
      if(gate) {record({...base,status:'hardware-gated',reason:gate,implemented:!!adapter.capabilities[lane]});continue;}
      if(!adapter.capabilities[lane]) {record({...base,status:'unsupported',reason:'Adapter does not implement '+lane});continue;}
      const workdir=path.join(temporary,String(index));fs.mkdirSync(workdir);
      const result=await runWorker({adapter:options.adapter,test,lane,upstream:options.upstream,project,workdir,timeoutMs:options.timeout,response:path.join(workdir,'response.json')});
      const verdict=judge(test,lane,result,adapter.capabilities);
      record({...base,...verdict,ms:Math.round(performance.now()-start),result});
      fs.rmSync(workdir,{recursive:true,force:true});
    }
  }));
} finally {fs.rmSync(temporary,{recursive:true,force:true});}
results.sort((a,b)=>a.id.localeCompare(b.id)||laneNames.indexOf(a.lane)-laneNames.indexOf(b.lane));
function counts(rows) {return rows.reduce((a,r)=>(a[r.status]=(a[r.status]||0)+1,a),{});}
const summary={tests:tests.length,allTests:manifest.total,excludedTests:manifest.total-tests.length,probes:results.length,
  statuses:counts(results),lanes:Object.fromEntries(lanes.map(l=>[l,counts(results.filter(r=>r.lane===l))])),
  namespaces:Object.fromEntries(Object.keys(manifest.namespaces).map(n=>[n,counts(results.filter(r=>r.namespace===n))])),
  checkerRejections:results.filter(r=>r.evidence==='checker-rejection').length,
  frontendRejections:results.filter(r=>r.evidence==='frontend-rejection').length,
  uncheckedExecutions:results.filter(r=>r.evidence==='unchecked-execution').length};
const allRequired=manifest.tests.flatMap(t=>probes(t)).length;
const identity=initialIdentity;
identity.finalAdapterSha256=sha256(fs.readFileSync(options.adapter));
identity.adapterChangedDuringRun=identity.finalAdapterSha256!==identity.adapterSha256;
identity.finalArtifactHashes=Object.fromEntries(Object.entries(identity.artifacts).map(([name,artifact])=>[name,sha256(fs.readFileSync(artifact.file))]));
identity.changedArtifacts=Object.entries(identity.artifacts).filter(([name,artifact])=>identity.finalArtifactHashes[name]!==artifact.sha256).map(([name])=>name);
const complete=!identity.adapterChangedDuringRun&&!identity.changedArtifacts.length&&tests.length===manifest.total&&results.length===allRequired&&results.every(r=>r.status==='pass'||r.status==='not-applicable'||(r.lane==='parse'&&r.status==='observed'));
if(identity.adapter==='unchecked-prototype') {
  identity.compilerSha256=sha256(fs.readFileSync(process.env.BEND_CONFORMANCE_COMPILER||path.join(project,'dist/bend2c.mjs')));
  identity.runtimeSha256=sha256(fs.readFileSync(process.env.BEND_CONFORMANCE_RUNTIME||path.join(project,'src/runtime.mjs')));
}
const report={schemaVersion:1,started,finished:new Date().toISOString(),host:{platform:process.platform,arch:process.arch,node:process.version,workerNodeArgs},
  options,identity,complete,summary,inventory:manifest,results};
fs.mkdirSync(path.dirname(options.output),{recursive:true});fs.writeFileSync(options.output,JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({complete,summary,report:options.output},null,2));
// Unsupported features, gated GPU lanes and filters never turn a full suite green.
if(!complete) process.exitCode=1;
