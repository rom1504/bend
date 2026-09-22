// Read-only capability/observation probe. It never substitutes compile for check.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {spawn} from 'node:child_process';import {pathToFileURL} from 'node:url';import {createHash} from 'node:crypto';
const sha=file=>createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const [mode,arg,outArg]=process.argv.slice(2);
if(mode==='--worker'){
 const cfg=JSON.parse(fs.readFileSync(arg));process.env.BEND_UPSTREAM=cfg.upstream;process.env.BEND_BASE=cfg.base;process.env.BEND_TYPED_RUNTIME=cfg.runtime;process.env.BEND_TYPED_API=cfg.api??'';delete process.env.BEND_TYPED_TRACE;
 const report={kind:cfg.kind,rows:[],complete:false};
 if(cfg.kind==='native-capability'){
  process.env.BEND_NATIVE_BINARY=cfg.binary;process.env.BEND_NATIVE_RUNTIME=cfg.runtime;process.env.BEND_NATIVE_MANIFEST_DIRECTORY=cfg.fixtureDirectory;
  const A=await import(pathToFileURL(cfg.nativeAdapter));report.capabilities=A.capabilities;
  for(const fixture of cfg.fixtures)for(const lane of ['parse','check'])report.rows.push({id:fixture.name,lane,result:await A.probe({test:{id:fixture.name,file:fixture.input},lane,workdir:cfg.workdir,timeoutMs:30000,upstream:cfg.upstream})});
 }else if(cfg.kind==='typescript'){
  const A=await import(pathToFileURL(cfg.upstreamAdapter)),session=await A.createPersistentSession();
  for(const fixture of cfg.fixtures)for(const lane of ['parse','check'])report.rows.push({id:fixture.name,lane,result:await session.probe({test:{id:fixture.name,file:fixture.input},lane,workdir:cfg.workdir,timeoutMs:30000,upstream:cfg.upstream})});
 }else{
  const D=await import(pathToFileURL(cfg.driver)),api=await D.loadApi();const start=performance.now();const seed=await D.prepareBase(api);report.basePreparation={ms:performance.now()-start,validatedBy:seed.validatedBy,compilerSha256:seed.compilerSha256};
  for(const fixture of cfg.fixtures)for(const lane of ['parse','check'])report.rows.push({id:fixture.name,lane,result:await D.inspect(fixture.input,{mode:lane,api})});
 }
 report.complete=true;report.peakRssKB=process.resourceUsage().maxRSS;fs.writeFileSync(outArg,JSON.stringify(report,null,2)+'\n');
}else{
 if(!outArg||mode!=='--run')throw Error('Usage: TOOL --run SELFHOST_PROJECT NEW_DIRECTORY');const P=fs.realpathSync(arg),out=path.resolve(outArg);fs.mkdirSync(out);const B=path.join(P,'build/phase4'),validation=path.join(B,'native-final/validation/validation.json'),old=JSON.parse(fs.readFileSync(validation));assert.equal(old.complete,true);
 const proofFile=path.join(B,'combined-fixedpoint/report.json'),proof=JSON.parse(fs.readFileSync(proofFile));assert.equal(proof.complete,true);assert.equal(proof.stages[0].outputSha256,proof.stages[1].outputSha256);for(const stage of proof.stages){assert(stage.inputsVerified&&stage.code===0&&!stage.signal);assert.equal(sha(stage.output),stage.outputSha256);}
 const fixtures=old.rows.filter(r=>['nested-parent','non-bmp-source','library','imported-parse-error','imported-type-error','imported-todo'].includes(r.name));assert.equal(fixtures.length,6);
 const driver=path.join(B,'combined-host/tools/typed-driver.mjs'),upstream=path.join(P,'.bootstrap/upstream'),base=path.join(upstream,'bend2/base.bend'),runtime=path.join(B,'baseline/src/runtime.mjs'),binary=path.join(B,'native-final/compiler-o2'),nativeAdapter=path.join(P,'tools/conformance/adapters/native-graph.mjs'),upstreamAdapter=path.join(P,'tools/conformance/adapters/upstream.mjs');
 const files=[import.meta.filename,validation,proofFile,driver,base,runtime,binary,nativeAdapter,upstreamAdapter,...['compiler-abi','native-build','node-resource-args','assemble'].map(n=>path.join(path.dirname(driver),n+'.mjs')),...['bend.ts','comp.ts'].map(n=>path.join(upstream,'bend2',n)),...fixtures.map(x=>x.input),proof.initialCompiler.file,proof.stages[0].output];
 const inputs=Object.fromEntries(files.map(file=>[file,sha(file)]));const report={kind:'native-frontend-feasibility',complete:false,cpu:3,inputs,scope:'Correctness/capability feasibility only. Retained native results are program/library compile observations, never mislabeled as parse/check. No controlled timing claim.',runs:[],existingNative:fixtures.map(f=>({name:f.name,native:f.native})),started:new Date().toISOString()};const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
 for(const kind of ['native-capability','b1','h','typescript']){
  const cfg={kind,driver,upstream,base,runtime,binary,nativeAdapter,upstreamAdapter,fixtureDirectory:path.join(B,'native-final/validation/fixtures'),fixtures:fixtures.map(({name,input})=>({name,input})),workdir:out,api:kind==='h'?proof.stages[0].output:proof.initialCompiler.file},configuration=path.join(out,kind+'.config.json'),result=path.join(out,kind+'.json');fs.writeFileSync(configuration,JSON.stringify(cfg,null,2));console.error(kind);const fds=['stdout','stderr'].map(s=>fs.openSync(path.join(out,kind+'.'+s),'wx'));let timedOut=false;const resultCode=await new Promise(resolve=>{const child=spawn(process.execPath,['--stack-size=4096','--max-old-space-size=4096',import.meta.filename,'--worker',configuration,result],{stdio:['ignore',...fds],detached:true,env:{...process.env,NODE_OPTIONS:''}});const timer=setTimeout(()=>{timedOut=true;try{process.kill(-child.pid,'SIGKILL')}catch{}},120000);child.on('error',e=>{clearTimeout(timer);resolve({error:String(e)})});child.on('close',(status,signal)=>{clearTimeout(timer);resolve({status,signal})})});fds.forEach(fs.closeSync);report.runs.push({kind,...resultCode,timedOut,result});save();assert.equal(resultCode.status,0);assert.equal(resultCode.signal,null);assert.equal(timedOut,false);
 }
 const results=Object.fromEntries(report.runs.map(r=>[r.kind,JSON.parse(fs.readFileSync(r.result))]));assert.deepEqual(results.b1.rows,results.h.rows);assert(results['native-capability'].rows.every(r=>r.result.status==='unsupported'));
 report.portObservationsEqual=true;report.nativeFrontendSupported=false;report.inputsUnchanged=Object.entries(inputs).every(([f,h])=>sha(f)===h);assert(report.inputsUnchanged);report.complete=true;report.finished=new Date().toISOString();save();console.log(JSON.stringify({complete:true,portObservations:results.b1.rows.length,nativeFrontendSupported:false}));
}
