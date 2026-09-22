import test from 'node:test';import assert from 'node:assert/strict';import fs from 'node:fs';import path from 'node:path';import os from 'node:os';
import {auditReads} from './input-audit.mjs';import {identity,digest,verifyImage} from './common.mjs';import {validateProof} from './proof.mjs';
const directory=fs.mkdtempSync(path.join(os.tmpdir(),'private-compiler-boundary-'));let serial=0;
const fresh=()=>{const p=path.join(directory,String(serial++));fs.mkdirSync(p);return p;};
test.after(()=>fs.rmSync(directory,{recursive:true,force:true}));
test('input audit hashes consumed bytes and rejects changes even on compiler rejection',()=>{
 const dir=fresh(),file=path.join(dir,'source.bend');fs.writeFileSync(file,'original');
 let a=auditReads({cacheDirectory:path.join(dir,'cache')});assert.equal(fs.readFileSync(file,'utf8'),'original');assert.equal(a.finish().files[0].sha256,digest('original'));
 a=auditReads({cacheDirectory:path.join(dir,'cache')});fs.readFileSync(file);fs.writeFileSync(file,'changed');assert.throws(()=>a.finish(),/changed during compilation/);
 a=auditReads({cacheDirectory:path.join(dir,'cache')});fs.readFileSync(file);fs.writeFileSync(file,'twice');fs.readFileSync(file);assert.throws(()=>a.finish(),/changed while being read/);
});
test('input audit preserves encoding and rejects symlink retarget even with identical bytes',()=>{
 const dir=fresh(),a=path.join(dir,'a'),b=path.join(dir,'b'),link=path.join(dir,'link');fs.writeFileSync(a,'🙂');fs.writeFileSync(b,'🙂');fs.symlinkSync(a,link);
 const audit=auditReads({cacheDirectory:path.join(dir,'cache')});assert.equal(fs.readFileSync(link,{encoding:'utf8'}),'🙂');fs.realpathSync(link);fs.unlinkSync(link);fs.symlinkSync(b,link);assert.throws(()=>audit.finish(),/changed during compilation|resolution changed/);
});
test('input audit permits expected creation of a validated Base cache but rejects appeared missing input',()=>{
 const dir=fresh(),cache=path.join(dir,'cache');fs.mkdirSync(cache);const c=path.join(cache,'base.json'),missing=path.join(dir,'missing.bend');
 let a=auditReads({cacheDirectory:cache});assert.throws(()=>fs.readFileSync(c),/ENOENT/);fs.writeFileSync(c,'{}');assert.equal(a.finish().files.length,0);
 a=auditReads({cacheDirectory:cache});assert.throws(()=>fs.readFileSync(missing),/ENOENT/);fs.writeFileSync(missing,'x');assert.throws(()=>a.finish(),/Missing input appeared/);
});
// Synthetic reports below test validation rejection only; they are never used
// to create a compiler image or to claim a checked bootstrap.
function proofFixture(){
 const dir=fresh(),write=(name,text)=>{const file=path.join(dir,name);fs.writeFileSync(file,text);return identity(file);};
 const runtime=write('runtime.mjs','// runtime\n'),source=write('compiler.bend','def x(): 1'),initial=write('b1.mjs','// seed'),h=write('h.mjs','// runtime\n// H'),h3=write('h3.mjs','// runtime\n// H'),base=write('base.bend','// base'),driver=write('typed-driver.mjs','// host');
 const helpers=['compiler-abi','node-resource-args','native-build','assemble'].map(n=>write(n+'.mjs','// '+n));
 const report={complete:true,source:source.file,sourceIdentity:source,sourceSha256:source.sha256,runtimeSha256:runtime.sha256,initialCompiler:initial,base,driver,hostHelpers:helpers,
 stages:[{compiler:initial.file,compilerSha256:initial.sha256,output:h.file,outputSha256:h.sha256,code:0,signal:null,inputsVerified:true},{compiler:h.file,compilerSha256:h.sha256,output:h3.file,outputSha256:h3.sha256,code:0,signal:null,inputsVerified:true}]};
 const proofFile=path.join(dir,'proof.json'),save=()=>fs.writeFileSync(proofFile,JSON.stringify(report));save();return {report,save,options:{proofFile,apiFile:h.file,runtimeFile:runtime.file},helpers,base};
}
test('proof validator rejects incomplete, failed, broken-chain and stale provenance',()=>{
 const f=proofFixture();assert.equal(validateProof(f.options).status,'fixedpoint');
 f.report.complete=false;f.save();assert.throws(()=>validateProof(f.options),/completed fixed-point/);assert.equal(validateProof({...f.options,experimental:true}).status,'checked-stage-proof-pending');
 f.report.stages[0].inputsVerified=false;f.save();assert.throws(()=>validateProof({...f.options,experimental:true}),/did not complete/);
 f.report.stages[0].inputsVerified=true;f.report.stages[1].compilerSha256='0'.repeat(64);f.save();assert.throws(()=>validateProof({...f.options,experimental:true}),/Broken compiler chain/);
 const b=proofFixture();fs.appendFileSync(b.base.file,'changed');assert.throws(()=>validateProof(b.options),/Artifact changed/);
 const h=proofFixture();fs.appendFileSync(h.helpers[0].file,'changed');assert.throws(()=>validateProof(h.options),/Artifact changed/);
});
test('proof validator will not accept unrelated H or old missing-helper reports',()=>{
 const f=proofFixture();fs.writeFileSync(f.options.apiFile,'// runtime\n// other');assert.throws(()=>validateProof(f.options),/stage artifact changed/);
 const g=proofFixture();delete g.report.hostHelpers;g.save();assert.throws(()=>validateProof(g.options),/host helpers/);
});
test('manifest cannot omit image artifact, escape its directory, or claim pending status silently',()=>{
 const dir=fresh(),file=path.join(dir,'manifest.json'),save=value=>fs.writeFileSync(file,JSON.stringify(value));
 save({kind:'bend-private-compiler-image',version:1,complete:true,proofStatus:'fixedpoint',artifacts:[]});assert.throws(()=>verifyImage(dir),/no artifact/);
 save({kind:'bend-private-compiler-image',version:1,complete:true,proofStatus:'fixedpoint',artifacts:[{relative:'../outside',sha256:'0'.repeat(64)}]});assert.throws(()=>verifyImage(dir),/required artifacts/);
 save({kind:'bend-private-compiler-image',version:1,complete:true,proofStatus:'unverified',artifacts:[]});assert.throws(()=>verifyImage(dir),/Unknown image proof/);
});
test('publication requires checked compile and exact pending bytes, refuses aliases and overwrite',async()=>{
 const {publishCheckedOutput}=await import('./publish.mjs');
 const create=()=>{const dir=fresh(),file=path.join(dir,'generated.mjs.pending');fs.writeFileSync(file,'valid source');return {dir,observation:{result:{status:'ok',phase:'compile',checked:true},emitted:{file,sha256:digest('valid source'),bytes:12}}};};
 const pass=create();publishCheckedOutput(pass.dir,pass.observation,'library');assert.equal(pass.observation.emitted.published,true);assert.equal(fs.readFileSync(path.join(pass.dir,'generated.mjs'),'utf8'),'valid source');
 const altered=create();fs.writeFileSync(altered.observation.emitted.file,'bad source');assert.throws(()=>publishCheckedOutput(altered.dir,altered.observation,'compile'),/Artifact changed/);assert.equal(fs.existsSync(path.join(altered.dir,'generated.mjs')),false);
 const failed=create();failed.observation.result.checked=false;assert.throws(()=>publishCheckedOutput(failed.dir,failed.observation,'compile'),/outside successful checked/);
 const exists=create();fs.writeFileSync(path.join(exists.dir,'generated.mjs'),'preserve');assert.throws(()=>publishCheckedOutput(exists.dir,exists.observation,'compile'),/already exists/);assert.equal(fs.readFileSync(path.join(exists.dir,'generated.mjs'),'utf8'),'preserve');
 const alias=create(),other=path.join(alias.dir,'other');fs.renameSync(alias.observation.emitted.file,other);fs.symlinkSync(other,alias.observation.emitted.file);assert.throws(()=>publishCheckedOutput(alias.dir,alias.observation,'compile'),/Unexpected worker output path/);
 assert.throws(()=>publishCheckedOutput(fresh(),{result:{status:'ok',phase:'compile',checked:true}},'compile'),/no emitted artifact/);
});
test('parent rechecks consumed files after worker completion before publication',async()=>{
 const {verifyReadAudit}=await import('./input-audit.mjs');const dir=fresh(),file=path.join(dir,'input.bend');fs.writeFileSync(file,'old');const inputs={files:[identity(file)],resolutions:[],missing:[]};verifyReadAudit(inputs);fs.writeFileSync(file,'new');assert.throws(()=>verifyReadAudit(inputs),/Artifact changed/);
});
test('private resource arguments accept explicit full-source heap without forwarding arbitrary Node flags',async()=>{
 const {privateNodeResourceArgs}=await import('./transport.mjs');
 assert.deepEqual(privateNodeResourceArgs(),['--stack-size=4096','--max-old-space-size=3072']);assert.deepEqual(privateNodeResourceArgs({heapMb:12288}),['--stack-size=4096','--max-old-space-size=12288']);
 for(const heapMb of [0,255,16385,Infinity,NaN,3.5,'12288','3072 --eval=bad'])assert.throws(()=>privateNodeResourceArgs({heapMb}),/Heap must/);
});
test('finite batch transport caps requests, deadlines and rejects hook-bearing envelopes',async()=>{
 const {validateBatchRequests}=await import('./transport.mjs');const item={input:'/tmp/source.bend',mode:'check'};
 assert.deepEqual(validateBatchRequests([item,{...item,timeoutMs:1}]).map(x=>x.timeoutMs),[120000,1]);
 for(const value of [[],Array(257).fill(item),[{...item,timeoutMs:0}],[{...item,mode:'native'}],[{...item,G:{}}]])assert.throws(()=>validateBatchRequests(value));
 let touched=0;const hooked=[];Object.defineProperty(hooked,0,{get(){touched++;return item;}});assert.throws(()=>validateBatchRequests(hooked));
 const proxy=new Proxy([item],{get(){touched++;throw Error('hook');}});assert.throws(()=>validateBatchRequests(proxy));assert.equal(touched,0);
});
test('completed proof rejects a later checked stage that breaks the fixed point',()=>{
 const f=proofFixture(),previous=f.report.stages.at(-1),file=path.join(path.dirname(f.options.proofFile),'divergent.mjs');fs.writeFileSync(file,'// runtime\n// divergent repeat');const different=identity(file);
 f.report.stages.push({compiler:previous.output,compilerSha256:previous.outputSha256,output:file,outputSha256:different.sha256,code:0,signal:null,inputsVerified:true});f.save();assert.throws(()=>validateProof(f.options),/equal checked self-emissions/);
});
test('production builder refuses any unreviewed runtime revision without restricting unit fixtures',async()=>{
 const {assertSupportedRuntime}=await import('./build.mjs');const source=fs.readFileSync(new URL('../../src/runtime.mjs',import.meta.url));assert.doesNotThrow(()=>assertSupportedRuntime(source));assert.throws(()=>assertSupportedRuntime(Buffer.concat([source,Buffer.from('\n// revision\n')])),/has not been reviewed/);
});
test('finished request rows cannot turn a failed worker lifetime into a complete batch',async()=>{
 const {batchIsComplete}=await import('./batch.mjs');const good={rows:[{complete:true,published:true}],lifetimes:[{verified:true,exit:{status:0,signal:null}}]};assert.equal(batchIsComplete(good,1),true);
 for(const failure of [{error:'finish handshake failed'},{spawnError:'EPERM'},{outputLimit:true},{verified:false},{exit:{status:1,signal:null}},{exit:{status:null,signal:'SIGKILL'}}])assert.equal(batchIsComplete({...good,lifetimes:[{...good.lifetimes[0],...failure}]},1),false);
 assert.equal(batchIsComplete({...good,error:'input drift'},1),false);assert.equal(batchIsComplete({...good,rows:[{complete:true,published:false}]},1),false);assert.equal(batchIsComplete(good,2),false);
});
test('proof helpers must be the files actually imported beside the frozen driver',()=>{
 const f=proofFixture(),other=path.join(path.dirname(f.options.proofFile),'unrelated');fs.mkdirSync(other);const misplaced=path.join(other,'compiler-abi.mjs');fs.copyFileSync(f.helpers[0].file,misplaced);f.report.hostHelpers[0]=identity(misplaced);f.save();assert.throws(()=>validateProof(f.options),/not the helper imported/);
});
