// ROOT-RUN TARGET: unchanged genuine Phase90 JS B2 emits D04 using separately authenticated new runtime assets.
// IMAGE_PINS QUALIFICATION_METHOD_PLAN NEW_OUT RUNTIME_READY; no upstream acquisition/build/admission.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const root=path.resolve(import.meta.dirname,'../../../../..');
Error.stackTraceLimit=100;
const pinsFile=fs.realpathSync(process.argv[2]??'');
const methodPlanFile=fs.realpathSync(process.argv[3]??'');
const out=path.resolve(process.argv[4]??'');
const runtimeReadyFile=fs.realpathSync(process.argv[5]??'');
assert(process.argv.length===6&&out.startsWith(path.join(root,'selfhost/build/phase90/')),'Fresh Phase90 output directory required');
fs.mkdirSync(out,{recursive:false});
const hash=data=>createHash('sha256').update(data).digest('hex');
const pin=file=>{file=fs.realpathSync(file);const data=fs.readFileSync(file);return {file,sha256:hash(data),bytes:data.length};};
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const report={kind:'phase90-qualified-js-b2-new-runtime-emission',complete:false,inputs:[],stage:'binding',
  nativeSelfEmission:false,nativeB2:false,scope:'Cross-host C emission by unchanged genuine driver-qualified JS-hosted Bend B2 with separately verified candidate runtime/template and exact driver template-pin derivative. Original qualified staging remains untouched. No upstream acquisition, Clang build, native execution, public admission or fixed point.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const mark=stage=>{report.stage=stage;save();process.stdout.write(JSON.stringify({kind:'P90_PROGRESS',stage,atMs:performance.now()})+'\n');};
const bind=record=>{const actual=pin(record.file??record.path);assert.equal(actual.sha256,record.sha256,actual.file);assert.equal(actual.bytes,record.bytes,actual.file);report.inputs.push(actual);return actual;};
const add=file=>bind(pin(file));
const unchanged=()=>{for(const p of report.inputs){const a=pin(p.file);assert.equal(a.sha256,p.sha256,p.file);assert.equal(a.bytes,p.bytes,p.file);}};
save();
try {
  add(import.meta.filename);add(process.execPath);
  const methodPlan=read(add(methodPlanFile).file);
  assert.equal(methodPlan.kind,'phase90-selfhosting-qualification-plan');
  assert.equal(pin(methodPlan.method.file).sha256,methodPlan.method.sha256);
  assert.equal(methodPlan.parentMethods.sha256,'86d03731708c12a5ff76327dcfdab2ae1023673e60cae3d8d6490fdc729ac78c');
  bind(methodPlan.parentMethods);
  let setupFile;
  for(const derivation of methodPlan.methods){
    const before=bind(derivation.parent);let text=fs.readFileSync(before.file,'utf8');
    for(const edit of derivation.edits){assert.equal(text.split(edit.before).length-1,edit.count);text=text.split(edit.before).join(edit.after);}
    const after=bind(derivation.output);assert.equal(fs.readFileSync(after.file,'utf8'),text);
    if(after.file.endsWith('/bootstrap/setup.mjs'))setupFile=after.file;
  }
  assert(setupFile,'Missing reviewed B2 setup');
  const pins=read(add(pinsFile).file);
  assert.equal(pins.kind,'phase56-direct-image-pins');
  assert.equal(pins.attempt.sha256,methodPlan.attempt.sha256);
  const W=await import(pathToFileURL(add(path.join(root,'selfhost/tools/development/workflow.mjs')).file));
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_')||key==='NODE_OPTIONS')delete process.env[key];
  mark('import-begin');const importStart=performance.now();
  const S=await import(pathToFileURL(setupFile));
  const selected=await S.setup(pinsFile,path.join(out,'image'),{progress:(phase,event)=>process.stdout.write(JSON.stringify({kind:'P90_SETUP',phase,event,atMs:performance.now()})+'\n')});
  const {image}=selected;let D=selected.D;
  report.importsAndVerifiedSetupMs=performance.now()-importStart;
  for(const p of selected.inputs)add(p.file);
  for(const p of selected.copies)add(p.after.file);
  const role={api:pin(image.api.file),driver:pin(image.driver.file),runtime:pin(image.runtime.file),
    base:pin(image.base.file),node:pin(process.execPath),project:selected.project};
  for(const key of ['api','driver','runtime','base','node'])bind(role[key]);
  assert.equal(role.api.sha256,pins.b2.sha256);
  report.producer={stage:'self-emitted driver-qualified JS-hosted Bend B2',imagePins:pin(pinsFile),
    attempt:pin(pins.attempt.file),generator:pin(pins.b1.file),emission:pin(pins.emission.file),comparison:pin(pins.comparison.file),
    api:role.api,driver:role.driver,runtime:role.runtime,node:role.node};
  const admission=add(path.join(root,'selfhost/tools/performance/phase89/native-admission.json'));
  assert.equal(admission.sha256,'9201ff03499900ed108b28b59ab24ecc79ccb7e9c64bb5765b105db7763a9a50');
  const native=read(admission.file),ancestor=bind(native.producer.source);
  assert.equal(ancestor.sha256,'4584cf083d9eddad6f1290c9472c3aac2708099caa716a27f5b53fbcbaee1618');
  const assemblyPin=add(path.join(root,'selfhost/tools/performance/phase90/observation/noindent01/compiler-noindent.assembly.json'));
  assert.equal(assemblyPin.sha256,'9b4c0796b7504ebcb030ae9ffe5f4d0d37dbd6ac4637e4723acf895de196fea9');
  const assembly=read(assemblyPin.file);
  assert.equal(assembly.kind,'phase90-native-source-assembly');assert(assembly.complete&&assembly.exactOutsideDefinitions);
  assert.equal(assembly.inputs[0].sha256,ancestor.sha256);for(const record of assembly.inputs)bind(record);
  const source=bind(assembly.output);
  assert.equal(source.sha256,'d04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097');
  assert.equal(source.bytes,1759353);
  const original=fs.readFileSync(ancestor.file,'utf8');let forward=original;
  assert.equal(assembly.replacements.length,14);
  for(const change of assembly.replacements){assert(change.old&&change.new);assert.equal(forward.split(change.old).length-1,1);forward=forward.replace(change.old,()=>change.new);}
  assert.equal(forward,fs.readFileSync(source.file,'utf8'));let inverse=forward;
  for(const change of [...assembly.replacements].reverse()){assert.equal(inverse.split(change.new).length-1,1);inverse=inverse.replace(change.new,()=>change.old);}
  assert.equal(inverse,original);
  report.sourceDerivation={assembly:assemblyPin,ancestor,inverseRecoversAncestor:true,exactOutsideReplacements:true};
  assert.deepEqual(fs.readFileSync(source.file,'utf8').match(/^import .*$/gm),['import Base']);
  const assets=bind(native.assets);assert.equal(assets.sha256,'1894cef9f71d674507aa671cd5c24730ce221b23df7ca0f9675949336671ba2b');
  const definitions=read(assets.file),effects=definitions.admittedEffects;
  assert.equal(effects.length,9);for(const p of effects)bind(p);
  for(const relative of ['runtime.c','runtime-template.json',...effects.map(p=>'effs/'+p.name)]){
    const frozen=add(path.join(role.project,'src/runtime/native',relative));
    const canonical=add(path.join(root,'selfhost/src/runtime/native',relative));
    assert.equal(frozen.sha256,canonical.sha256,'Frozen/current native asset mismatch: '+relative);
  }
  for(const relative of ['tools/compiler-abi.mjs','tools/base-cache-graph.mjs','tools/native-build.mjs',
      'tools/node-resource-args.mjs','tools/assemble.mjs','src/compiler.json'])add(path.join(role.project,relative));
  const readyPin=add(runtimeReadyFile),ready=read(readyPin.file);
  assert.equal(ready.kind,'phase90-runtime-large-table-accessor-prepared');
  assert(ready.complete&&ready.canonicalMutated===false&&ready.qualificationPending===true);
  const runtimePlanPin=bind(ready.plan);
  assert.equal(runtimePlanPin.sha256,'1d6824d4be2a0a3e763336fe7ee19f67482190b2d8f7701df788d4ffcacdf566');
  const runtimePlan=read(runtimePlanPin.file);
  assert.equal(runtimePlan.kind,'phase90-runtime-large-table-accessor-plan');
  assert.equal(runtimePlan.threshold,4096);
  for(const item of [...runtimePlan.canonicalInputs,...runtimePlan.sourceAudit,
      ...['method','helper','upstream','attempt','api','generator','source'].map(k=>runtimePlan[k])])bind(item);
  assert.deepEqual(ready.inputs,runtimePlan.canonicalInputs);
  const outputs=ready.outputs.map(bind);
  assert.equal(outputs.length,3);assert.deepEqual(outputs[0],runtimePlan.source);
  assert.equal(outputs[0].sha256,'9e1c59078878be94052cb4d2d63a713e19e29b41ed3f94b034f2175a50efd0a9');
  let transformed=fs.readFileSync(runtimePlan.canonicalInputs[0].file,'utf8');
  assert.equal(runtimePlan.edits.length,2);
  for(const e of runtimePlan.edits){assert.equal(transformed.split(e.before).length-1,1);transformed=transformed.replace(e.before,()=>e.after);}
  assert.equal(transformed,fs.readFileSync(outputs[0].file,'utf8'));
  const templateReceiptPin=bind(ready.templateReceipt),templateReceipt=read(templateReceiptPin.file);
  assert.equal(templateReceipt.kind,'bend-native-template');assert.equal(templateReceipt.chunks,5);assert(templateReceipt.exactRoundTrip);
  for(const [key,expected] of [['producer',runtimePlan.api],['attempt',runtimePlan.attempt],['generator',runtimePlan.generator],['runtime',outputs[0]],['artifact',outputs[1]]])assert.deepEqual(bind(templateReceipt[key]),expected);
  const template=read(outputs[1].file);assert.equal(template.version,1);
  assert.equal(template.runtimeSha256,outputs[0].sha256);assert.equal(template.parts.length,5);
  assert.equal(template.parts.join(''),transformed);
  const originalDriver=fs.readFileSync(role.driver.file,'utf8');
  assert.equal(role.driver.sha256,runtimePlan.canonicalInputs[2].sha256);
  const oldPin="const nativeTemplateSha256='"+runtimePlan.canonicalInputs[1].sha256+"';";
  const newPin="const nativeTemplateSha256='"+outputs[1].sha256+"';";
  assert.equal(originalDriver.split(oldPin).length-1,1);
  assert.equal(fs.readFileSync(outputs[2].file,'utf8'),originalDriver.replace(oldPin,newPin));
  const requestProject=path.join(out,'request-project');fs.mkdirSync(requestProject);
  const overrides=new Map([['src/runtime/native/runtime.c',outputs[0]],['src/runtime/native/runtime-template.json',outputs[1]],['tools/typed-driver.mjs',outputs[2]]]);
  const requestCopies=[];
  const walk=dir=>fs.readdirSync(dir,{withFileTypes:true}).sort((a,b)=>a.name.localeCompare(b.name)).flatMap(x=>x.isDirectory()?walk(path.join(dir,x.name)):[path.join(dir,x.name)]);
  for(const originalFile of walk(role.project)){
    const relative=path.relative(role.project,originalFile),before=add(originalFile);
    const chosen=overrides.get(relative)??before,target=path.join(requestProject,relative);
    fs.mkdirSync(path.dirname(target),{recursive:true});fs.copyFileSync(chosen.file,target,fs.constants.COPYFILE_EXCL);
    const after=add(target);assert.equal(after.sha256,chosen.sha256);
    requestCopies.push({before,source:chosen,after,changed:chosen.sha256!==before.sha256});
  }
  assert.equal(requestCopies.filter(x=>x.changed).length,3);
  assert(!fs.existsSync(path.join(requestProject,'build/typed/cache')));
  process.env.BEND_TYPED_API=role.api.file;process.env.BEND_TYPED_RUNTIME=role.runtime.file;process.env.BEND_BASE=role.base.file;
  D=await import(pathToFileURL(path.join(requestProject,'tools/typed-driver.mjs')));
  assert.equal(D.apiPath,role.api.file);assert.equal(D.runtimePath,role.runtime.file);
  assert.equal((await D.loadApi()),selected.api);
  report.requestRuntime={plan:runtimePlanPin,ready:readyPin,templateReceipt:templateReceiptPin,
    runtime:outputs[0],template:outputs[1],driver:outputs[2],project:requestProject,copies:requestCopies,
    producerUnchanged:true,scope:'Candidate runtime input; original B2 API and qualified project remain byte-identical. Request driver differs only by the template SHA pin.'};
  report.subject=source;report.ancestorNativeProfileAdmission=admission;
  report.checkoutReleaseVerified=false;
  report.checkoutNote='Experimental genuine B2 with preserved checked generator; no installed release mutation, native lineage or own-source fixed-point claim.';
  process.env.BEND_TYPED_TRACE='1';
  mark('prepare-base-begin');const prepareStart=performance.now();
  await D.prepareBase(undefined,{backendProducts:false});
  report.prepareBaseMs=performance.now()-prepareStart;
  const cache=W.validatedCache(path.join(requestProject,'build/typed/cache'),role.api.file,role.base.file);
  report.preparedBase=[add(cache.file)];
  mark('prepare-base-complete');
  mark('request-begin');const requestStart=performance.now();
  const result=await D.inspect(source.file,{mode:'native',withReport:true});
  report.requestMs=performance.now()-requestStart;
  const {code,...observation}=result;report.observation=observation;mark('request-returned');
  assert.equal(result.status,'ok',result.diagnostic??result.reason);assert.equal(result.checked,true);
  assert.equal(typeof code,'string');
  report.policy={};
  for(const name of ['NATIVE_TYPED_SCALARS','NATIVE_COLD_USER_CTORS','NATIVE_SCALAR_ARRAYS','NATIVE_UNSHARED_ARRAYS']){
    const match=new RegExp('^#define '+name+' ([01])$','m').exec(code);assert(match,'Missing policy '+name);
    report.policy[name]=Number(match[1]);assert.equal(report.policy[name],0,'Unexpected file-effect representation permission');
  }
  const expected=new Map(report.inputs.map(p=>[p.file,p]));
  for(const file of result.files??[]){const item=pin(file);assert(expected.has(item.file),'Unfrozen input '+file);assert.equal(item.sha256,expected.get(item.file).sha256);}
  report.verification=await selected.verifyFinal();unchanged();report.verification.requestCopiesUnchanged=true;report.inputsUnchanged=true;
  const bytes=Buffer.byteLength(code);assert(bytes>0&&bytes<=64*1024*1024,'C exceeds 64 MiB output cap');
  const target=path.join(out,'program.c');fs.writeFileSync(target,code,{flag:'wx'});report.output=pin(target);
  report.complete=true;mark('complete');
} catch(error) {
  report.error=error.stack??String(error);report.complete=false;process.exitCode=1;mark('failed');
}
report.maxRssKiB=process.resourceUsage().maxRSS;save();
process.stdout.write(JSON.stringify({complete:report.complete,stage:report.stage,requestMs:report.requestMs,output:report.output,error:report.error})+'\n');
