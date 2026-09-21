import fs from 'node:fs';import path from 'node:path';import {spawnSync} from 'node:child_process';import {createHash} from 'node:crypto';
const root=path.resolve(import.meta.dirname,'../../..'),output=path.join(import.meta.dirname,'selfhost-backend');
if(fs.existsSync(output))throw Error('Use a fresh backend-validation directory');fs.mkdirSync(output);
const abs=file=>path.join(root,file),hash=file=>createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const walk=file=>!fs.existsSync(file)?[]:fs.statSync(file).isDirectory()?fs.readdirSync(file).sort().flatMap(name=>walk(path.join(file,name))):[file];
const suites=['test.mjs','test-foreign.mjs','test-validation.mjs','test-layout.mjs','test-string-eq.mjs','test-provenance.mjs','test-global-initializers.mjs','test-choice.mjs','test-string-primitives.mjs','test-projection.mjs'].map(name=>'src/back/js/'+name);
suites.push('src/runtime/js/test-apply.mjs','tests/runtime-regressions.mjs');
const clang=abs('build/phase1/clang/root/usr'),api=abs('build/phase2/grammar-v2/fixedpoint/stage3.mjs'),runtime=abs('src/runtime.mjs'),upstream=abs('.bootstrap/upstream');
const environment={BEND_TYPED_API:api,BEND_TYPED_RUNTIME:runtime,BEND_JS_RUNTIME:runtime,BEND_JS_BACKEND:abs('tools/backend-test-api.mjs'),BEND_EXPECT_CACHED_LAM:'1',BEND_BASE:path.join(upstream,'bend2/base.bend'),BEND_UPSTREAM:upstream,CC:path.join(clang,'bin/clang-16'),LD_LIBRARY_PATH:path.join(clang,'lib/x86_64-linux-gnu'),LIBRARY_PATH:path.join(clang,'lib/x86_64-linux-gnu'),CPATH:path.join(clang,'include')};
const env={...process.env,...environment};delete env.BEND_JS_REFERENCE;
const proofFile=abs('build/phase2/grammar-v2/fixedpoint/report.json'),proof=JSON.parse(fs.readFileSync(proofFile,'utf8'));
const verify=item=>{if(!item?.file||hash(item.file)!==item.sha256||item.canonicalPath&&fs.realpathSync(item.file)!==item.canonicalPath)throw Error('Changed proof input: '+item?.file);};
if(!proof.complete||proof.stages?.length!==2||proof.stages.some(s=>s.code!==0||s.signal||s.inputsVerified!==true))throw Error('Completed verified two-stage proof required');
const proofInputs=[proof.sourceIdentity,proof.base,proof.initialCompiler,proof.driver,...proof.hostHelpers];proofInputs.forEach(verify);
for(let i=0;i<proof.stages.length;i++){const s=proof.stages[i];if(hash(s.compiler)!==s.compilerSha256||hash(s.output)!==s.outputSha256||i&&s.compilerSha256!==proof.stages[i-1].outputSha256)throw Error('Self-emission chain changed');}
if(proof.stages[0].outputSha256!==proof.stages[1].outputSha256||hash(api)!==proof.stages[1].outputSha256||hash(runtime)!==proof.runtimeSha256||hash(environment.BEND_BASE)!==proof.base.sha256)throw Error('Proof/runtime/Base identity mismatch');
const initialBootstrapFile=proof.initialCompiler.file+'.bootstrap.json',bootstrap=JSON.parse(fs.readFileSync(initialBootstrapFile,'utf8'));
if(bootstrap.apiSha256!==proof.initialCompiler.sha256||bootstrap.sourceSha256!==hash(bootstrap.source)||bootstrap.sourceSha256!==proof.sourceSha256)throw Error('Initial checked compiler identity mismatch');
const compilerSources=bootstrap.modules.map(module=>{const file=path.join(path.dirname(bootstrap.source),module.file);if(hash(file)!==module.sha256)throw Error('Checked compiler source changed');return file;});
const git=args=>{const p=spawnSync('git',['-C',upstream,...args],{encoding:'utf8'});if(p.status!==0)throw Error(p.stderr);return p.stdout.trim();};
const pin=git(['rev-parse','HEAD']);if(pin!==bootstrap.revision||git(['status','--porcelain','--untracked-files=no']))throw Error('Changed upstream pin');
const inputs=[import.meta.filename,api,proofFile,initialBootstrapFile,...proofInputs.map(p=>p.file),...proof.stages.flatMap(s=>[s.compiler,s.output]),bootstrap.source,...compilerSources,runtime,process.execPath,environment.CC,...suites.map(abs),...['typed-driver.mjs','backend-test-api.mjs','compiler-abi.mjs','node-resource-args.mjs','native-build.mjs','assemble.mjs','stage0-library.mjs'].map(name=>abs('tools/'+name)),...['bend.ts','comp.ts','base.bend'].map(name=>path.join(upstream,'bend2',name)),...walk(abs('tests/fixtures')),...walk(abs('src/runtime/native')),...walk(path.join(upstream,'bend2/effs')),path.join(upstream,'tests/reg/borrow_fork_hold.bend'),path.join(upstream,'tests/io/stack_fault_trap.bend'),path.join(upstream,'tests/reg/array_open_element.bend')];
const identities=Object.fromEntries([...new Set(inputs)].map(file=>[file,{canonicalPath:fs.realpathSync(file),sha256:hash(file)}]));
const flags=['--stack-size=4096','--max-old-space-size=4096'];
const report={kind:'phase2-final-v2-proven-self-emitted-backend-runtime-validation',selfhostProof:{file:proofFile,sha256:hash(proofFile),complete:true,sourceSha256:proof.sourceSha256,stages:proof.stages},initialBootstrap:{file:initialBootstrapFile,sha256:hash(initialBootstrapFile),role:'Initial B1 provenance only; H identity comes from the completed self-emission chain'},pin,started:new Date().toISOString(),complete:false,cpu:1,node:{file:process.execPath,version:process.version,flags},environment,identities,compilerVersion:spawnSync(environment.CC,['--version'],{env,encoding:'utf8'}).stdout,scope:'Correctness validation through the proven self-emitted v2 H API. No bootstrap report is fabricated for H. Manual core fixtures exercise the backend directly; checked-source suites exercise the ordinary pipeline. Base-cache warmth is not controlled, so elapsed times are not isolated performance comparisons.',rows:[]};
const save=()=>fs.writeFileSync(path.join(output,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const scratch=()=>[...fs.readdirSync(abs('build')).filter(name=>name.startsWith('js-emitted-')).map(name=>abs('build/'+name)),...['foreign-emitted.mjs','js-layout','js-provenance','js-initializers','choice-tests','string-primitives','projection-tests'].flatMap(name=>walk(abs('build/'+name)))];
const stamp=file=>{const stat=fs.statSync(file,{bigint:true});return stat.mtimeNs+':'+stat.ctimeNs+':'+stat.size;};
const started=performance.now(),deadline=started+300000;
for(const suite of suites){
  console.error('[backend validation] '+suite);const before=new Map(scratch().map(file=>[file,stamp(file)])),id=String(report.rows.length).padStart(2,'0')+'-'+path.basename(suite,'.mjs'),dir=path.join(output,id);fs.mkdirSync(dir);
  const args=[...flags,suite,...suite==='tests/runtime-regressions.mjs'?[path.join(output,'runtime-regressions')]:[]],start=performance.now();
  const result=spawnSync(process.execPath,args,{cwd:root,env,encoding:'utf8',timeout:Math.max(1,Math.floor(deadline-performance.now())),maxBuffer:16*1024*1024});
  fs.writeFileSync(path.join(dir,'stdout.log'),result.stdout??'');fs.writeFileSync(path.join(dir,'stderr.log'),result.stderr??'');
  const row={suite,command:[process.execPath,...args],milliseconds:performance.now()-start,status:result.status,signal:result.signal,error:result.error?.message??null,pass:result.status===0&&!result.error,stdout:result.stdout,stderr:result.stderr,artifacts:[]};
  for(const file of scratch())if(before.get(file)!==stamp(file)){const target=path.join(dir,'artifacts',path.relative(abs('build'),file));fs.mkdirSync(path.dirname(target),{recursive:true});fs.copyFileSync(file,target);row.artifacts.push({file,retained:target,sha256:hash(target)});}
  report.rows.push(row);save();if(!row.pass||performance.now()>=deadline)break;
}
report.changedInputs=Object.entries(identities).filter(([file,value])=>fs.realpathSync(file)!==value.canonicalPath||hash(file)!==value.sha256).map(([file])=>file);
report.trackedStillClean=git(['rev-parse','HEAD'])===pin&&!git(['status','--porcelain','--untracked-files=no']);report.complete=report.rows.length===suites.length&&report.rows.every(row=>row.pass)&&report.changedInputs.length===0&&report.trackedStillClean;report.milliseconds=performance.now()-started;report.finished=new Date().toISOString();save();
console.log(JSON.stringify({report:path.join(output,'report.json'),passed:report.rows.filter(row=>row.pass).length,total:report.rows.length,complete:report.complete,milliseconds:report.milliseconds}));if(!report.complete)process.exitCode=1;
