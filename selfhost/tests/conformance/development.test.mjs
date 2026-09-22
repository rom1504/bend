import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {configuration,digest,identity,verifyIdentity,verifyBootstrap,validatedCache,verifyAttempt,observationHealth,runDevelopment,validateAttempt} from '../../tools/development/workflow.mjs';
import {supervise,requireExecution} from '../../tools/development/process.mjs';
import {PIN} from '../../tools/conformance/inventory.mjs';

const temporary=fn=>async t=>{const root=fs.mkdtempSync(path.join(os.tmpdir(),'bend-development-test-'));try{await fn(root,t);}finally{fs.rmSync(root,{recursive:true,force:true});}};
const put=(root,name,text)=>{const file=path.join(root,name);fs.mkdirSync(path.dirname(file),{recursive:true});fs.writeFileSync(file,text);return file;};
const write=(root,name,data)=>put(root,name,JSON.stringify(data));
function fixture(root){
  const api=put(root,'api.mjs','export const value=1;'),source=put(root,'compiler.bend','def value() -> U32: 1'),base=put(root,'base.bend','base'),runtime=put(root,'runtime.mjs','runtime'),helper=put(root,'helper.mjs','helper');
  const module=put(root,'src/value.bend','module');
  const proof={stage:'upstream-bootstrap',revision:PIN,apiSha256:identity(api).sha256,source,sourceSha256:identity(source).sha256,baseSha256:identity(base).sha256,
    modules:[{file:'src/value.bend',sha256:identity(module).sha256}],provenance:{verifiedAfterBuild:true,inputs:[identity(source),identity(helper),identity(module)]}};
  const bootstrap=write(root,'api.mjs.bootstrap.json',proof);
  const attempt={kind:'bend-development-attempt',version:1,checked:true,artifactKind:'checked-b1',node:{...identity(process.execPath),version:process.version},base:identity(base),runtime:identity(runtime),
    snapshot:{sources:[{frozen:identity(helper)},{frozen:identity(runtime)}]},checkedApi:identity(api),api:identity(api),bootstrapReport:identity(bootstrap),artifacts:[identity(api),identity(bootstrap)]};
  write(root,'attempt.json',attempt);return {api,source,base,runtime,helper,module,proof,bootstrap,attempt};
}
test('configuration rejects unknown and unbounded resource options',temporary(root=>{
  assert.throws(()=>configuration({project:root,upstream:root,wrong:true}),/Unknown configuration/);
  for(const option of [{jobs:0},{jobs:5},{heapMb:8192},{timeoutMs:300001},{cpu:'0,0'},{profile:'fake'},{fullFrontend:'yes'}])assert.throws(()=>configuration({project:root,upstream:root,...option}));
  assert.equal(configuration({project:root,upstream:root,cpu:'0,2'}).cpu,'0,2');
}));
test('identical bytes after symlink retargeting still invalidate identity',temporary(root=>{
  const a=put(root,'a','same'),b=put(root,'b','same'),link=path.join(root,'link');fs.symlinkSync(a,link);const before=identity(link);fs.unlinkSync(link);fs.symlinkSync(b,link);assert.throws(()=>verifyIdentity(before),/Changed input/);
}));
test('checked provenance rejects missing verification, changed API, source and helpers',temporary(root=>{
  const f=fixture(root);assert.equal(verifyBootstrap(f.api,f.bootstrap,f.base).stage,'upstream-bootstrap');
  const original=fs.readFileSync(f.bootstrap);
  f.proof.provenance.verifiedAfterBuild=false;fs.writeFileSync(f.bootstrap,JSON.stringify(f.proof));assert.throws(()=>verifyBootstrap(f.api,f.bootstrap,f.base),/genuine verified/);fs.writeFileSync(f.bootstrap,original);
  for(const file of [f.api,f.source,f.helper,f.module,f.base]){const bytes=fs.readFileSync(file);fs.appendFileSync(file,'changed');assert.throws(()=>verifyBootstrap(f.api,f.bootstrap,f.base));fs.writeFileSync(file,bytes);}
}));
test('attempt reuse requires completed build and unchanged frozen runtime/API/helper',temporary(async root=>{
  const f=fixture(root);assert.equal((await verifyAttempt(root)).artifactKind,'checked-b1');
  for(const file of [f.runtime,f.api,f.helper,f.bootstrap]){const bytes=fs.readFileSync(file);fs.appendFileSync(file,'changed');await assert.rejects(verifyAttempt(root));fs.writeFileSync(file,bytes);}
  f.attempt.checked=false;write(root,'attempt.json',f.attempt);await assert.rejects(verifyAttempt(root),/fresh attempt/);
}));
test('selected checked API cannot be substituted beside a valid proof',temporary(async root=>{
  const f=fixture(root);f.attempt.api=identity(put(root,'other.mjs','export const value=2;'));write(root,'attempt.json',f.attempt);
  await assert.rejects(verifyAttempt(root),/Selected API differs from checked bootstrap/);
}));
test('derived adapter API is bound to verifier output and its original checked build',temporary(async root=>{
  const f=fixture(root),derived=put(root,'derived.mjs','derived'),derivation=write(root,'derivation.json',{complete:true});
  const metadata={original:{api:identity(f.api),bootstrapReport:identity(f.bootstrap)}};
  // This stub isolates the workflow association check. The equality helper's
  // own tests exercise genuine provenance and exact-body replay separately.
  const helper=put(root,'tools/development/equality.mjs',`export function verifyEqualityDerivation(){return ${JSON.stringify({api:derived,metadata})}}`);
  f.attempt.snapshot.root=root;f.attempt.snapshot.sources.push({frozen:identity(helper)});f.attempt.artifactKind='derived-b1';f.attempt.api=identity(derived);f.attempt.derivationReport=identity(derivation);
  write(root,'attempt.json',f.attempt);assert.equal((await verifyAttempt(root)).artifactKind,'derived-b1');
  f.attempt.api=identity(put(root,'substitute.mjs','other'));write(root,'attempt.json',f.attempt);await assert.rejects(verifyAttempt(root),/Selected API differs from verified derivation/);
}));
test('fresh output refusal preserves prior attempt and validation reports',temporary(async root=>{
  const f=fixture(root);const config=write(root,'config.json',{project:root,upstream:root});
  await assert.rejects(runDevelopment(config,root),/EEXIST/);
  await assert.rejects(validateAttempt(root,config,root),/EEXIST/);
  assert.equal(fs.readFileSync(f.api,'utf8'),'export const value=1;');
}));
test('validated cache rejects API, source path and serialized book drift',temporary(root=>{
  const f=fixture(root),book={x:1};const record={version:2,compilerSha256:identity(f.api).sha256,baseSha256:identity(f.base).sha256,sourcePath:fs.realpathSync(f.base),validatedBy:'check_book',bookSha256:digest(JSON.stringify(book)),book};
  const filename=`base-${record.compilerSha256}-${record.baseSha256}-${digest(record.sourcePath)}.json`,file=write(root,filename,record);assert.equal(validatedCache(root,f.api,f.base).file,file);
  for(const alteration of [{compilerSha256:'wrong'},{sourcePath:'wrong'},{book:{x:2}},{validatedBy:'assumed'}]){fs.writeFileSync(file,JSON.stringify({...record,...alteration}));assert.throws(()=>validatedCache(root,f.api,f.base),/Invalid API-specific/);}
}));
test('observation coverage does not erase strict failures or accept worker crashes',()=>{
  const report={finished:'now',selection:{requested:[{}]},results:[{status:'fail',result:{status:'error',phase:'check'}}],changedInputs:[],identity:{changedArtifacts:[],adapterChangedDuringRun:false},workers:[{errors:[]}]};
  assert.equal(observationHealth(report),true);assert.equal(report.results[0].status,'fail');
  assert.equal(observationHealth({...report,results:[]}),false);
  assert.equal(observationHealth({...report,results:[{status:'timeout'}]}),false);
  assert.equal(observationHealth({...report,workers:[{errors:['crash']}]}),false);
});
test('finite supervision retains failed output, catches fast overflow and deadline',temporary(async root=>{
  const run=(name,source,extra={})=>supervise(process.execPath,['-e',source],{directory:path.join(root,name),env:process.env,timeoutMs:3000,...extra});
  const failed=await run('failed','process.stderr.write("witness");process.exitCode=1');assert.equal(failed.exitCode,1);assert.match(fs.readFileSync(failed.stderr,'utf8'),/witness/);assert.throws(()=>requireExecution(failed));requireExecution(failed,[0,1]);
  const overflow=await run('overflow','require("fs").writeSync(1,"x".repeat(10000))',{maxBytes:100});assert.equal(overflow.overflow,true);assert.throws(()=>requireExecution(overflow,[0,1]));
  const deadline=await run('timeout','setInterval(()=>{},1000)',{timeoutMs:100});assert.equal(deadline.timedOut,true);assert.throws(()=>requireExecution(deadline));
  const missing=await supervise('/definitely/no/bend-node',[],{directory:path.join(root,'missing'),env:process.env,timeoutMs:1000});assert.ok(missing.error);assert.throws(()=>requireExecution(missing));
}));
test('deadline terminates a separately grouped compiler descendant',temporary(async root=>{
  if(process.platform!=='linux')return;
  const pidFile=path.join(root,'pid');
  const source=`const fs=require('fs');const {spawn}=require('child_process');const c=spawn(process.execPath,['-e','setInterval(()=>{},1000)'],{detached:true,stdio:'ignore'});fs.writeFileSync(${JSON.stringify(pidFile)},String(c.pid));setInterval(()=>{},1000);`;
  const result=await supervise(process.execPath,['-e',source],{directory:path.join(root,'capture'),env:process.env,timeoutMs:200});
  assert.equal(result.timedOut,true);const pid=Number(fs.readFileSync(pidFile));
  // A killed descendant can remain a zombie briefly until the system reaps it.
  const alive=()=>{try{return !/^State:\s+Z/m.test(fs.readFileSync(`/proc/${pid}/status`,'utf8'));}catch{return false;}};
  for(let i=0;i<20&&alive();i++)await new Promise(resolve=>setTimeout(resolve,10));
  assert.equal(alive(),false,'Detached descendant survived phase deadline');
}));
