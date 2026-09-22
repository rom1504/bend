// Exact-image counts only. No semantic lowering and no timing claim.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {spawn} from 'node:child_process';
const EXPECTED_IMAGE='4318bbcdb2040ad794387b1466b0bafbe12233e67983224c5a564d13fa5753a3';
const EXPECTED_OUTPUT='016a5cedeb7e285adeabdad19388d99d3d9070668c15776ccc10fab8ea7b7186';
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const sha=f=>hash(fs.readFileSync(f));
const bodies={subst_node:'f6d6ffee36b2b6b26d31bc7f45e2d452dd23378f53dec5d7aeb5bece28038d05',subst_terms:'acb4386cdbba8228856b1508cdf6b28672d525951e76a7f254fdc8ae2c0c7cdd',ka_defs_except:'d9aa5ebed5c8ad0aebb0736ffacbf22fd4cd0539d376ee102edd9d211807188e',tele_check:'cc082217f8d37ec7780132cfbbffcad214ff3cf8b173b5fff1b3b2855e34db26',ka_args:'ff8b2fd11dc946a27bbfb4a3459b9ae5466bd94baaa8a105f08371dbca092ba4',privateWorker731:'3d8666d337fa0f555eff1c7d31a8ccd1920c4909b4c3ce815bcadba3303d45f2',privateWorker741:'d80cef1a7cf65bed9f8130cb791ef7075be99f9b7e9dd0ad4a743b9db97c0ce9',privateWorker896:'2dc2391f3d3dabc7dab474467e689af354ea2c3ad1974d62597e2f527b48ebd0'};
const workers={privateWorker731:'ka_args',privateWorker741:'ka_defs_except',privateWorker896:'tele_check'};
const support=`
const p4Tags=new WeakMap(),p4Counts=Object.create(null);let p4Phase='setup';
function p4Inc(k){const rows=p4Counts[p4Phase]??=(Object.create(null));rows[k]=(rows[k]??0)+1;}
function p4Tag(f,family,kind){p4Tags.set(f,{family,kind});return f;}
function p4Fn(family,...args){p4Inc(family+':created:arm');return p4Tag(fn(...args),family,'arm');}
function p4Matcher(family,...args){p4Inc(family+':created:matcher');return p4Tag(matcher(...args),family,'matcher');}
function p4Matcher1(family,...args){p4Inc(family+':created:matcher1');return p4Tag(matcher1(...args),family,'matcher1');}
function p4Apply(f,args){
 p4Inc('all:apply');
 if(!(f instanceof PrivateFunction)){p4Inc('all:nonPrivateFunction');return;}
 const n=f.bound.length+args.length,kind=n===f.arity?'exact':n<f.arity?'under':'over';p4Inc('all:'+kind);
 const tag=p4Tags.get(f);if(tag){p4Inc(tag.family+':'+tag.kind+':apply:'+kind);p4Inc(tag.family+':shape:'+f.bound.length+'+'+args.length+'/'+f.arity);}
}
function p4Partial(f,result){p4Inc('all:partialRecords');const tag=p4Tags.get(f);if(tag){p4Inc(tag.family+':'+tag.kind+':partialRecords');p4Tags.set(result,tag);}return result;}
export const p4Diagnostic=Object.freeze({phase(name){p4Phase=name;},snapshot(){return JSON.parse(JSON.stringify(p4Counts));},selfTest(){
 p4Phase='counterControl';const f=p4Fn('control',2,a=>a[0]+a[1]);if(call(call(f,[20]),[22])!==42)throw Error('Counter partial control failed');
 const m=p4Matcher1('control','Tuple',()=>p4Fn('control',2,a=>a[0]+a[1]));if(call(m,[[20,22]])!==42)throw Error('Counter matcher control failed');
 const rows=p4Counts.counterControl;if(rows['control:arm:apply:under']!==1||rows['control:arm:partialRecords']!==1||rows['control:arm:apply:exact']!==2||rows['control:matcher1:apply:exact']!==1)throw Error('Counter accounting control failed');
 return {...rows};}});
`;
function once(s,from,to){assert.equal(s.split(from).length,2,'Expected exactly one guarded runtime insertion');return s.replace(from,to);}
export function instrument(source){
 assert.equal(hash(source),EXPECTED_IMAGE,'Only the selected immutable image is supported');
 const changed=[];let lines=source.split('\n');
 for(const [name,expected] of Object.entries(bodies)){
  const prefix=workers[name]?'function '+name+'(':'G['+JSON.stringify(name)+']=';
  const ids=lines.flatMap((line,i)=>line.startsWith(prefix)?[i]:[]);assert.equal(ids.length,1);const i=ids[0],original=lines[i];assert.equal(hash(original),expected,name+' body changed');
  const family=workers[name]??name,q=JSON.stringify(family);let line=original;
  // Exact whole-body hashes restrict these lexical replacements to inspected
  // generated lines. No user strings contain these call spellings.
  line=line.replace(/\bmatcher1\(/g,'p4Matcher1('+q+',').replace(/\bmatcher\(/g,'p4Matcher('+q+',').replace(/\bfn\(/g,'p4Fn('+q+',');
  if(workers[name])line=line.replace('{','{p4Inc('+q+'+":workerEntry");');
  else {line+='p4Tag(G['+q+'],'+q+','+JSON.stringify(['subst_node','subst_terms'].includes(name)?'entryMatcher':'entryFn')+');';}
  lines[i]=line;changed.push({name,sha256:expected,original,instrumented:line});
 }
 let output=lines.join('\n');output=once(output,'function apply(f,args){','function apply(f,args){p4Apply(f,args);');
 output=once(output,'if(all.length<f.arity)return fn(f.arity,f.code,f.env,all);','if(all.length<f.arity)return p4Partial(f,fn(f.arity,f.code,f.env,all));');
 output=once(output,'const G=Object.create(null)',support+'\nconst G=Object.create(null)');
 return {source:output,changed};
}
async function child(configFile,out){
 const cfg=JSON.parse(fs.readFileSync(configFile)),identities=new Map();
 const capture=f=>{f=fs.realpathSync(f);const identity={file:f,sha256:sha(f),bytes:fs.statSync(f).size};if(identities.has(f))assert.deepEqual(identity,identities.get(f));else identities.set(f,identity);return f;};
 const verify=()=>{for(const row of identities.values())assert.equal(sha(row.file),row.sha256,'Input drift: '+row.file);};
 capture(import.meta.filename);capture(configFile);capture(process.execPath);
 for(const name of ['api','driver','base','runtime','input'])cfg[name]=capture(cfg[name]);
 assert.equal(sha(cfg.api),EXPECTED_IMAGE);
 const manifestFile=capture(path.join(path.dirname(cfg.api),'manifest.json')),manifest=JSON.parse(fs.readFileSync(manifestFile));assert.equal(manifest.complete,true);assert.equal(manifest.proofStatus,'fixedpoint');
 for(const artifact of manifest.artifacts){const file=capture(path.join(path.dirname(cfg.api),artifact.relative));assert.equal(sha(file),artifact.sha256);}
 const proofFile=capture(manifest.proof.file);assert.equal(sha(proofFile),manifest.proof.sha256);const proof=JSON.parse(fs.readFileSync(proofFile));assert.equal(proof.complete,true);assert.equal(proof.stages.length,2);
 for(const stage of proof.stages){assert.equal(stage.inputsVerified,true);assert.equal(stage.code,0);assert.equal(stage.signal,null);assert.equal(sha(capture(stage.output)),stage.outputSha256);}
 assert.equal(proof.stages[0].outputSha256,proof.stages[1].outputSha256);assert.equal(sha(capture(proof.source)),'34c6ef63931e522a96a4203f8bbd8e103d3a27636cce5dd42d9ec57a8587d122');
 assert.ok(fs.statSync(cfg.input).size<=128*1024);
 for(const name of ['compiler-abi.mjs','assemble.mjs','native-build.mjs','node-resource-args.mjs'])capture(path.join(path.dirname(cfg.driver),name));
 const transformed=instrument(fs.readFileSync(cfg.api,'utf8')),image=path.join(out,'instrumented.mjs');fs.writeFileSync(image,transformed.source,{flag:'wx'});capture(image);
 fs.writeFileSync(path.join(out,'insertions.json'),JSON.stringify(transformed.changed,null,2)+'\n');
 const report={kind:'phase4-matcher-family-counts',complete:false,started:new Date().toISOString(),scope:'Operation counts only; counter overhead invalidates timing comparisons.',inputs:[...identities.values()],originalApi:cfg.api,diagnosticImage:image,node:{version:process.version,args:process.execArgv},affinity:fs.readFileSync('/proc/self/status','utf8').split('\n').find(x=>x.startsWith('Cpus_allowed_list:'))};
 const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
 let diag;
 try{
  process.env.BEND_TYPED_API=image;process.env.BEND_TYPED_RUNTIME=cfg.runtime;process.env.BEND_BASE=cfg.base;delete process.env.BEND_TYPED_TRACE;
  const D=await import(pathToFileURL(cfg.driver)),raw=await D.loadApi();diag=(await import(pathToFileURL(image))).p4Diagnostic;report.counterControl=diag.selfTest();
  const cacheFile=path.join(D.project,'build/typed/cache','base-'+sha(image)+'-'+sha(cfg.base)+'-'+hash(fs.realpathSync(cfg.base))+'.json');
  report.baseCache={file:cacheFile,existedBefore:fs.existsSync(cacheFile),policy:'Explicit prepareBase before request; diagnostic-image-specific validated cache identity.'};
  diag.phase('prepareBase');const seed=await D.prepareBase(raw);assert.equal(seed.validatedBy,'check_book');capture(cacheFile);report.baseCache.sha256=sha(cacheFile);
  diag.phase('discoverSources');for(const file of D.discoverSources(raw,cfg.input,{seed}).files)capture(file);
  diag.phase('request:host');const api=Object.fromEntries(Object.entries(raw).map(([name,method])=>[name,(...args)=>{diag.phase('request:'+name);try{return method(...args);}finally{diag.phase('request:host');}}]));
  const result=await D.inspect(cfg.input,{api,mode:'library'});assert.equal(result.status,'ok');assert.equal(result.checked,true);assert.equal(result.phase,'compile');
  assert.equal(hash(result.code),EXPECTED_OUTPUT);const file=path.join(out,'program.mjs');fs.writeFileSync(file,result.code,{flag:'wx'});report.emitted={file,sha256:sha(file),bytes:Buffer.byteLength(result.code)};delete result.code;report.result=result;
  verify();report.inputs=[...identities.values()];report.inputsUnchanged=true;report.complete=true;
 }catch(error){report.error=error.stack;process.exitCode=1;}finally{report.counts=diag?.snapshot();report.finished=new Date().toISOString();save();}
 console.log(JSON.stringify({complete:report.complete,emitted:report.emitted,error:report.error}));
}
async function launch(configFile,out){
 const cfg=JSON.parse(fs.readFileSync(configFile));assert.equal(cfg.cpu,3);fs.mkdirSync(out,{recursive:false});
 const frozen=path.join(out,'config.json');fs.copyFileSync(configFile,frozen);const tool=path.join(out,'matcher-family-counts.mjs');fs.copyFileSync(import.meta.filename,tool);
 const report={kind:'phase4-matcher-family-counts-launch',complete:false,started:new Date().toISOString(),timeoutMs:90000,cpu:3,tool:{file:tool,sha256:sha(tool)},config:{file:frozen,sha256:sha(frozen)},node:{file:process.execPath,version:process.version,sha256:sha(process.execPath)},timedOut:false};
 const save=()=>fs.writeFileSync(path.join(out,'launch.json'),JSON.stringify(report,null,2)+'\n');save();
 const stdout=fs.openSync(path.join(out,'stdout.log'),'wx'),stderr=fs.openSync(path.join(out,'stderr.log'),'wx');
 try{await new Promise((resolve,reject)=>{const proc=spawn('taskset',['-c','3',process.execPath,'--stack-size=4096','--max-old-space-size=3072',tool,'--child',frozen,out],{detached:true,stdio:['ignore',stdout,stderr],env:{...process.env,NODE_OPTIONS:''}});report.pid=proc.pid;save();const timer=setTimeout(()=>{report.timedOut=true;save();try{process.kill(-proc.pid,'SIGKILL');}catch(e){if(e.code!=='ESRCH')report.killError=e.message;}},90000);proc.once('error',e=>{clearTimeout(timer);reject(e);});proc.once('close',(code,signal)=>{clearTimeout(timer);report.exitCode=code;report.signal=signal;resolve();});});const file=path.join(out,'report.json');report.childReport=fs.existsSync(file)?{file,sha256:sha(file),complete:JSON.parse(fs.readFileSync(file)).complete}:null;report.complete=report.exitCode===0&&!report.signal&&!report.timedOut&&report.childReport?.complete===true;}catch(e){report.error=e.stack;}finally{fs.closeSync(stdout);fs.closeSync(stderr);report.finished=new Date().toISOString();save();}
 console.log(JSON.stringify(report));if(!report.complete)process.exitCode=1;
}
if(process.argv[1]&&path.resolve(process.argv[1])===import.meta.filename){const args=process.argv.slice(2);if(args[0]==='--child')await child(path.resolve(args[1]),path.resolve(args[2]));else {if(args.length!==2)throw Error('Usage: matcher-family-counts.mjs CONFIG NEW_DIRECTORY');await launch(path.resolve(args[0]),path.resolve(args[1]));}}
