// Full frozen parse/check sweep. A completed observation inventory is not a
// full-language conformance claim. Preserve exact failures and nonzero exits.
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {spawn} from 'node:child_process';
import assert from 'node:assert/strict';

const [configuration,output]=process.argv.slice(2);
if(!output)throw Error('Usage: frontend-sweep.mjs CONFIG_JSON NEW_DIRECTORY');
const configFile=fs.realpathSync(configuration),config=JSON.parse(fs.readFileSync(configFile));
const resolve=file=>fs.realpathSync(path.resolve(path.dirname(configFile),file));
const out=path.resolve(output);fs.mkdirSync(out,{recursive:false});
const sha=file=>createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const identities={};
const record=file=>{file=path.resolve(file);identities[file]={canonicalPath:fs.realpathSync(file),sha256:sha(file)};return file;};
const verify=()=>{for(const [file,item] of Object.entries(identities))assert.deepEqual({canonicalPath:fs.realpathSync(file),sha256:sha(file)},item,'Input drift: '+file);};
const recorded=item=>{assert.equal(fs.realpathSync(item.file),item.canonicalPath);assert.equal(sha(record(item.file)),item.sha256);};
const walk=dir=>fs.readdirSync(dir,{withFileTypes:true}).flatMap(x=>x.isDirectory()?walk(path.join(dir,x.name)):[path.join(dir,x.name)]);
const save=(name,value)=>fs.writeFileSync(path.join(out,name),JSON.stringify(value,null,2)+'\n');
record(configFile);record(import.meta.filename);record(process.execPath);
fs.copyFileSync(import.meta.filename,path.join(out,'frontend-sweep.mjs'));record(path.join(out,'frontend-sweep.mjs'));
const project=resolve(config.project),upstream=resolve(config.upstream),base=resolve(config.base),runtime=record(resolve(config.runtime)),driver=resolve(config.driver);
assert.equal(base,fs.realpathSync(path.join(upstream,'bend2/base.bend')));record(base);
assert.ok(Number.isSafeInteger(config.cpu)&&config.cpu>=0);
const harness=path.join(out,'harness');fs.mkdirSync(path.join(harness,'tools'),{recursive:true});
fs.cpSync(path.join(project,'tools/conformance'),path.join(harness,'tools/conformance'),{recursive:true});
// The live reference adapter imports these helpers even for parse/check lanes.
for(const name of ['native-build.mjs','node-resource-args.mjs'])fs.copyFileSync(path.join(project,'tools',name),path.join(harness,'tools',name));
const host=path.join(out,'host/tools');fs.mkdirSync(host,{recursive:true});
for(const name of ['typed-driver','compiler-abi','node-resource-args','assemble','native-build'])fs.copyFileSync(path.join(path.dirname(driver),name+'.mjs'),path.join(host,name+'.mjs'));
const adapter=path.join(out,'frontend-adapter.mjs');fs.copyFileSync(path.join(import.meta.dirname,'frontend-adapter.mjs'),adapter);
for(const file of [...walk(harness),...walk(host),adapter])record(file);
const variants=config.variants.map(v=>{
  if(v.kind==='typescript')return {...v};
  assert.equal(v.kind,'bend');const api=record(resolve(v.api)),provenance=record(resolve(v.provenance)),p=JSON.parse(fs.readFileSync(provenance));
  assert.equal(p.complete,true);
  if(p.kind==='phase4-checked-overlay'){
    assert.equal(p.inputsUnchanged,true);assert.equal(p.api.sha256,sha(api));recorded(p.source);for(const item of p.inputs)recorded(item);
  }else if(p.kind==='bend-private-compiler-image'){
    assert.equal(p.proofStatus,'fixedpoint');assert.equal(api,path.join(path.dirname(provenance),'image.mjs'));
    for(const item of p.artifacts){assert.ok(!path.isAbsolute(item.relative)&&!item.relative.split(path.sep).includes('..'));const file=path.join(path.dirname(provenance),item.relative);assert.equal(sha(record(file)),item.sha256);}
    recorded(p.base);assert.equal(p.base.canonicalPath,base);assert.equal(p.runtime.sha256,sha(runtime));
  }else throw Error('Unsupported checked provenance '+p.kind);
  return {...v,api,provenance};
});
assert.equal(new Set(variants.map(x=>x.id)).size,variants.length);
for(const v of variants)assert.match(v.id,/^[-a-z0-9]+$/);
const report={kind:'phase4-full-frontend-sweep',started:new Date().toISOString(),complete:false,scope:'All pinned parse/check observations through a JSON worker boundary; serial persistent workers; workflow wall observations, not paired performance. Full-language conformance remains incomplete.',config,variants,identities,node:{file:process.execPath,version:process.version},rows:[]};
save('launch.json',report);
const common=['--upstream',upstream,'--jobs','1','--timeout','300000','--worker-mode','persistent','--recycle-after','64','--rss-limit-mb','4096','--stack-kb','4096','--heap-mb','4096','--lanes','parse,check','--retain','failed'];
const seed=config.seedCacheDirectory&&resolve(config.seedCacheDirectory);
if(seed){const target=path.join(out,'host/build/typed/cache');fs.mkdirSync(target,{recursive:true});for(const name of fs.readdirSync(seed).filter(n=>/^base-.*\.json$/.test(n)))fs.copyFileSync(record(path.join(seed,name)),path.join(target,name));}
for(const variant of variants){
  verify();console.log('Starting '+variant.id);
  const env={...process.env,BEND_UPSTREAM:upstream,BEND_BASE:base,BEND_TYPED_RUNTIME:runtime,BEND_TYPED_TRACE:'',NODE_OPTIONS:''};
  if(variant.kind==='bend')env.BEND_TYPED_API=variant.api;else delete env.BEND_TYPED_API;
  const reportFile=path.join(out,variant.id+'.json'),selected=variant.kind==='bend'?adapter:path.join(harness,'tools/conformance/adapters/upstream.mjs');
  const args=['-c',String(config.cpu),process.execPath,'--stack-size=4096','--max-old-space-size=4096',path.join(harness,'tools/conformance/run.mjs'),...common,'--adapter',selected,'--output',reportFile];
  const a=fs.openSync(path.join(out,variant.id+'.stdout'),'wx'),b=fs.openSync(path.join(out,variant.id+'.stderr'),'wx'),start=performance.now();
  let timedOut=false;
  const child=await new Promise(resolve=>{
    const p=spawn('taskset',args,{env,stdio:['ignore',a,b],detached:true});
    const timer=setTimeout(()=>{timedOut=true;try{process.kill(-p.pid,'SIGKILL');}catch{}},config.deadlineMs??3600000);
    p.once('error',error=>{clearTimeout(timer);resolve({status:null,signal:null,error:String(error)});});
    p.once('close',(status,signal)=>{clearTimeout(timer);resolve({status,signal});});
  });fs.closeSync(a);fs.closeSync(b);
  const row={variant:variant.id,command:'taskset',args,...child,timedOut,wallMs:performance.now()-start,report:reportFile,reportSha256:fs.existsSync(reportFile)?sha(reportFile):null};
  report.rows.push(row);save('execution.json',report);
  if(child.error||child.signal||timedOut||![0,1].includes(child.status)||!fs.existsSync(reportFile)){
    row.error='No complete runner report; inspect the retained launcher logs';save('execution.json',report);throw Error(row.error);
  }
  assert.ok(!child.error&&!child.signal&&!timedOut&&[0,1].includes(child.status),'Infrastructure failure; inspect logs');
  const result=JSON.parse(fs.readFileSync(reportFile));
  assert.equal(result.inventory.total,1378);assert.equal(result.results.length,2756);
  assert.equal(result.changedInputs.length,0);assert.equal(result.identity.changedArtifacts.length,0);assert.equal(result.identity.adapterChangedDuringRun,false);
  assert.ok(result.workers.every(w=>w.errors.length===0));
  assert.ok(result.results.every(r=>!['crash','timeout','unsupported'].includes(r.result?.status)&&!['crash','timeout','unsupported'].includes(r.status)),'Incomplete observations');
  row.observationsComplete=true;row.conformanceComplete=result.complete;row.summary=result.summary;
  verify();save('execution.json',report);console.log('Completed '+variant.id+': '+result.results.length+' observations');
}
verify();report.complete=true;report.finished=new Date().toISOString();save('execution.json',report);
