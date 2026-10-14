// ROOT-RUN TARGET: genuine driver-qualified Phase90 B2 emits frozen native89 S as C.
// IMAGE_PINS QUALIFICATION_METHOD_PLAN NEW_OUT; no upstream acquisition/build/admission.
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
assert(process.argv.length===5&&out.startsWith(path.join(root,'selfhost/build/phase90/')),'Fresh Phase90 output directory required');
fs.mkdirSync(out,{recursive:false});
const hash=data=>createHash('sha256').update(data).digest('hex');
const pin=file=>{file=fs.realpathSync(file);const data=fs.readFileSync(file);return {file,sha256:hash(data),bytes:data.length};};
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const report={kind:'phase90-qualified-js-b2-native-self-source-emission',complete:false,inputs:[],stage:'binding',
  nativeSelfEmission:false,nativeB2:false,scope:'Cross-host C emission by the recorded genuinely self-emitted, driver-qualified JS-hosted Bend B2. No upstream acquisition, Clang build, native execution, public admission or fixed point.'};
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
  const {D,image}=selected;
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
  const native=read(admission.file),source=bind(native.producer.source);
  assert.equal(source.sha256,'4584cf083d9eddad6f1290c9472c3aac2708099caa716a27f5b53fbcbaee1618');
  assert.equal(source.bytes,1755310);
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
  report.subject=source;report.nativeProfileAdmission=admission;
  report.checkoutReleaseVerified=false;
  report.checkoutNote='Experimental genuine B2 with preserved checked generator; no installed release mutation, native lineage or own-source fixed-point claim.';
  process.env.BEND_TYPED_TRACE='1';
  mark('prepare-base-begin');const prepareStart=performance.now();
  await D.prepareBase(undefined,{backendProducts:false});
  report.prepareBaseMs=performance.now()-prepareStart;
  const cache=W.validatedCache(path.join(role.project,'build/typed/cache'),role.api.file,role.base.file);
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
  report.verification=await selected.verifyFinal();unchanged();report.inputsUnchanged=true;
  const bytes=Buffer.byteLength(code);assert(bytes>0&&bytes<=64*1024*1024,'C exceeds 64 MiB output cap');
  const target=path.join(out,'program.c');fs.writeFileSync(target,code,{flag:'wx'});report.output=pin(target);
  report.complete=true;mark('complete');
} catch(error) {
  report.error=error.stack??String(error);report.complete=false;process.exitCode=1;mark('failed');
}
report.maxRssKiB=process.resourceUsage().maxRSS;save();
process.stdout.write(JSON.stringify({complete:report.complete,stage:report.stage,requestMs:report.requestMs,output:report.output,error:report.error})+'\n');
