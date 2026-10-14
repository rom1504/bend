// ROOT-RUN TARGET: fixed Phase82 JS-hosted Bend B2 emits frozen native89 S as C.
// NEW_OUT; no upstream compiler call, policy override, image build or admission.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const root=path.resolve(import.meta.dirname,'../../../../..');
const out=path.resolve(process.argv[2]??'');
assert(process.argv.length===3&&out.startsWith(path.join(root,'selfhost/build/phase90/')),'Fresh Phase90 output directory required');
fs.mkdirSync(out,{recursive:false});
const hash=data=>createHash('sha256').update(data).digest('hex');
const pin=file=>{file=fs.realpathSync(file);const data=fs.readFileSync(file);return {file,sha256:hash(data),bytes:data.length};};
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const report={kind:'phase90-js-b2-native-self-source-emission',complete:false,inputs:[],stage:'binding',
  nativeSelfEmission:false,nativeB2:false,scope:'Cross-host C emission by the unchanged JS-hosted Bend B2. No upstream acquisition, Clang build, native execution, public admission or fixed point.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const mark=stage=>{report.stage=stage;save();process.stdout.write(JSON.stringify({kind:'P90_PROGRESS',stage,atMs:performance.now()})+'\n');};
const bind=record=>{const actual=pin(record.file??record.path);assert.equal(actual.sha256,record.sha256,actual.file);assert.equal(actual.bytes,record.bytes,actual.file);report.inputs.push(actual);return actual;};
const add=file=>bind(pin(file));
const unchanged=()=>{for(const p of report.inputs){const a=pin(p.file);assert.equal(a.sha256,p.sha256,p.file);assert.equal(a.bytes,p.bytes,p.file);}};
save();
try {
  add(import.meta.filename);add(process.execPath);
  const planFile=add(path.join(root,'selfhost/build/phase83/survey01/plan.json'));
  const role=read(planFile.file).roles.b2;
  assert.equal(role.api.sha256,'098320e8f3e40894156790d740ad205e386f375195b3c6741d67cca96e94e092');
  for(const key of ['api','driver','runtime','base','node'])bind(role[key]);
  assert.equal(fs.realpathSync(process.execPath),fs.realpathSync(role.node.file),'Use frozen Node');
  const installed=add(path.join(root,'selfhost/dist/typed-api.mjs'));
  assert.equal(installed.sha256,role.api.sha256,'Installed JS B2 changed');
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
  const prepared=add(role.preparation),preparation=read(prepared.file);
  assert(preparation.complete&&preparation.pass&&preparation.inputsUnchanged);
  assert.equal(preparation.cache.length,1);for(const p of preparation.cache)bind(p);
  report.producer={stage:'self-emitted JS-hosted Bend B2',api:role.api,driver:role.driver,runtime:role.runtime,node:role.node};
  report.subject=source;report.preparedBase=preparation.cache;report.nativeProfileAdmission=admission;
  report.checkoutReleaseVerified=false;
  report.checkoutNote='Phase89 recorded three inherited Phase88 source/manifest differences; this experiment binds the unchanged generated API and frozen host, not a passing current-checkout release verification.';
  process.env.BEND_TYPED_API=role.api.file;process.env.BEND_TYPED_RUNTIME=role.runtime.file;process.env.BEND_BASE=role.base.file;
  process.env.BEND_TYPED_TRACE='1';
  mark('import-begin');const importStart=performance.now();
  const D=await import(pathToFileURL(role.driver.file));await D.loadApi();
  report.importsMs=performance.now()-importStart;
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
  unchanged();report.inputsUnchanged=true;
  const bytes=Buffer.byteLength(code);assert(bytes>0&&bytes<=64*1024*1024,'C exceeds 64 MiB output cap');
  const target=path.join(out,'program.c');fs.writeFileSync(target,code,{flag:'wx'});report.output=pin(target);
  report.complete=true;mark('complete');
} catch(error) {
  report.error=error.stack??String(error);report.complete=false;process.exitCode=1;mark('failed');
}
report.maxRssKiB=process.resourceUsage().maxRSS;save();
process.stdout.write(JSON.stringify({complete:report.complete,stage:report.stage,requestMs:report.requestMs,output:report.output,error:report.error})+'\n');
