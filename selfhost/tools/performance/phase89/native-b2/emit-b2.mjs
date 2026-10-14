// ROOT-RUN TARGET: ordinary frozen JS-hosted B2, never an upstream emitter.
// MANIFEST CASE NEW_OUT [FROZEN_PHASE83_PLAN]
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../../..');
const [manifestArg,name,outArg,planArg]=process.argv.slice(2);
assert(manifestArg&&name&&outArg,'MANIFEST CASE NEW_OUT [PLAN]');
const manifestFile=path.resolve(manifestArg),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {file,sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};};
const verify=p=>{const a=pin(p.file);assert.equal(a.sha256,p.sha256,p.file);assert.equal(a.bytes,p.bytes,p.file);return a;};
const manifest=JSON.parse(fs.readFileSync(manifestFile));
assert.equal(manifest.kind,'phase89-native-b2-falsifiers');
assert(manifest.sources[name],name);
const planFile=path.resolve(planArg??path.join(root,'selfhost/build/phase83/survey01/plan.json'));
const role=JSON.parse(fs.readFileSync(planFile)).roles.b2;
const report={kind:'phase89-b2-control-emission',complete:false,case:name,inputs:[],observation:null};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();
try {
  assert.equal(role.api.sha256,'098320e8f3e40894156790d740ad205e386f375195b3c6741d67cca96e94e092');
  report.inputs.push(...[manifestFile,planFile,import.meta.filename,process.execPath].map(pin),
    ...['api','driver','runtime','base','node'].map(k=>verify(role[k])),verify(manifest.sources[name]));
  assert.equal(fs.realpathSync(process.execPath),fs.realpathSync(role.node.file),'Use frozen Node');
  for(const p of manifest.methods)verify(p);
  const native=path.join(role.project,'src/runtime/native');
  const canonical=path.join(root,'selfhost/src/runtime/native');
  const assets=['runtime.c','runtime-template.json',...[
    'args.c','print.c','now.c','print_err.c','file_open.c','file_read.c',
    'file_size.c','file_write.c','file_close.c'].map(n=>'effs/'+n)];
  for(const f of assets){
    const a=pin(path.join(native,f)),b=pin(path.join(canonical,f));
    assert.equal(a.sha256,b.sha256,'Frozen/current native asset differs: '+f);
    report.inputs.push(a,b);
  }
  for(const f of ['tools/compiler-abi.mjs','tools/base-cache-graph.mjs','tools/native-build.mjs',
      'tools/node-resource-args.mjs','tools/assemble.mjs','src/compiler.json'])
    report.inputs.push(pin(path.join(role.project,f)));
  process.env.BEND_TYPED_API=role.api.file;
  process.env.BEND_TYPED_RUNTIME=role.runtime.file;
  process.env.BEND_BASE=role.base.file;
  save();
  const D=await import(pathToFileURL(role.driver.file));
  await D.loadApi();
  const result=await D.inspect(manifest.sources[name].file,{mode:'native',withReport:true});
  const {code,...observation}=result;report.observation=observation;save();
  assert.equal(result.status,'ok',result.diagnostic??result.reason);
  assert.equal(result.checked,true);
  assert.equal(typeof code,'string');
  const policy={};
  for(const key of ['NATIVE_TYPED_SCALARS','NATIVE_COLD_USER_CTORS','NATIVE_SCALAR_ARRAYS','NATIVE_UNSHARED_ARRAYS']){
    const m=new RegExp('^#define '+key+' ([01])$','m').exec(code);
    assert(m,'Missing policy macro '+key);policy[key]=Number(m[1]);
  }
  report.policy=policy;
  if(manifest.emission[name]==='conservative')assert(Object.values(policy).every(x=>x===0),'Unexpected representation permission');
  const expected=new Map(report.inputs.map(p=>[p.file,p]));
  for(const f of result.files??[]){
    const p=pin(f);assert(expected.has(p.file),'Unfrozen input '+p.file);verify(expected.get(p.file));
  }
  for(const p of report.inputs)verify(p);
  const target=path.join(out,'program.c');fs.writeFileSync(target,code,{flag:'wx'});
  report.output=pin(target);report.complete=true;
} catch(error) {report.error=error.stack??String(error);process.exitCode=1;}
report.maxRssKiB=process.resourceUsage().maxRSS;save();
console.log(JSON.stringify({complete:report.complete,case:name,output:report.output,policy:report.policy,error:report.error}));
