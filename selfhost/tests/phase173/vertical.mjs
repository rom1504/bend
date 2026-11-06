// Observation/transport only. Checked Bend owns parsing, checking, erasure,
// compaction, the indexed store, dependency extraction, and all admission.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {fileURLToPath,pathToFileURL} from 'node:url';

const own=fileURLToPath(import.meta.url),root=path.resolve(path.dirname(own),'../../..');
const args={};
for(let i=2;i<process.argv.length;i+=2){
  assert(process.argv[i]?.startsWith('--')&&process.argv[i+1],'Expected --key value');
  const k=process.argv[i].slice(2);assert(!Object.hasOwn(args,k),'Duplicate '+k);args[k]=process.argv[i+1];
}
const required=['baseline','baseline-assembly','candidate','candidate-assembly','source','out'];
assert(required.every(k=>args[k]),'Required: '+required.map(k=>'--'+k).join(' '));
assert(Object.keys(args).every(k=>required.includes(k)),'Unknown argument');
const read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
const pin=file=>{file=fs.realpathSync(file);const data=fs.readFileSync(file);return {file,bytes:data.length,sha256:crypto.createHash('sha256').update(data).digest('hex')};};
const verify=p=>assert.deepEqual(pin(p.file),p,'Changed input '+p.file);
const same=(a,b)=>a.file===b.file&&a.bytes===b.bytes&&a.sha256===b.sha256;
function items(xs){const out=[];while(xs?.$==='Con'){assert(out.length<1000000,'Bend list bound');out.push(xs.head);xs=xs.tail;}assert.equal(xs?.$,'Nil','Complete proper list required');return out;}

function compare(a,b){
  const work=[[a,b]],seen=new WeakMap();let values=0;
  while(work.length){
    assert(++values<=20000000,'Complete value comparison bound');
    const [x,y]=work.pop();if(Object.is(x,y))continue;
    assert(x!==null&&y!==null&&typeof x==='object'&&typeof y==='object','Scalar mismatch');
    let ys=seen.get(x);if(ys?.has(y))continue;
    if(!ys){ys=new WeakSet();seen.set(x,ys);}ys.add(y);
    assert.equal(Array.isArray(x),Array.isArray(y),'Container shape mismatch');
    const xk=Object.keys(x).sort(),yk=Object.keys(y).sort();assert.deepEqual(xk,yk,'Complete fields mismatch');
    for(const k of xk)work.push([x[k],y[k]]);
  }
  return {completeValuesEqual:true,valuesCompared:values};
}
function comparatorControls(){
  const x={$:'KTerm',tag:'Ref',name:'x',id:1,quant:2,kids:{$:'Nil'},removed:{$:'Nil'},originBegin:4,originEnd:8};
  compare(x,structuredClone(x));let rejected=0;
  for(const y of [{...x,id:2},{...x,name:'y'},{...x,quant:0},{...x,originBegin:0},{...x,originEnd:9},
    {...x,removed:{$:'Con',head:'z',tail:{$:'Nil'}}},{...x,kids:{$:'Con',head:x,tail:{$:'Nil'}}},{...x,$:'Other'}]){
    assert.throws(()=>compare(x,y),'Comparator accepted changed field');rejected++;
  }
  assert.throws(()=>compare([{name:'a'},{name:'b'}],[{name:'b'},{name:'a'}]),'Lost output ordering');
  return {equalControls:1,changedFieldsRejected:rejected,orderMutationsRejected:1};
}

const source=pin(args.source),known={
  ff6b4083aa2f3e034f3b4f8e43dfb25d93a4f524685934e0ee13845278033ef3:
    {name:'real-compiler-verifier',bytes:39333,stdout:'768\n'},
  cd22c831c180c0de12d84aeb80debf4881d08cbd18fcf8f6d634153fba2feb03:
    {name:'unrelated-native45-map-churn-128',bytes:3659,oracle:'experiments/phase167/tools/map-oracle.py'},
};
assert(known[source.sha256]&&known[source.sha256].bytes===source.bytes,'Use the frozen real verifier or unrelated Map fixture');
const inputs=[pin(own),pin(process.execPath),source],roles={},authorities={};
for(const role of ['baseline','candidate']){
  const assemblyPin=pin(args[role+'-assembly']),receiptPin=pin(args[role]);
  const assembly=read(assemblyPin.file),receipt=read(receiptPin.file);
  assert(assembly.kind==='phase171-api-source'&&assembly.complete&&assembly.protectedUnchanged,'Frozen protected source assembly required');
  assert(receipt.kind==='bend-checked-hosted-api'&&receipt.version===1&&receipt.complete&&receipt.checked&&!receipt.error,'Checked acquisition required');
  assert(same(assembly.source,receipt.source),'Source receipt mismatch');
  assert.deepEqual(assembly.exports,receipt.exports,'Different API manifest');
  const exports=['p88_cache_prepare','p86_plan','p173v_inputs','p173v_control_inputs',
    ...(role==='baseline'?['p173v_baseline','p173v_original_body']:['p173v_candidate','p173v_roundtrip'])];
  assert(exports.every(name=>receipt.exports.includes(name)),'Missing '+role+' API export');
  const binding=read(assembly.binding.file);assert.equal(binding.kind,'phase171-prepared-base');
  assert(same(binding.engine,pin(process.execPath)),'Run with pinned Bun');
  inputs.push(assemblyPin,receiptPin,...assembly.inputs,assembly.source,assembly.exportManifest,assembly.binding,
    ...receipt.inputs,receipt.api,binding.assets,binding.base,binding.carrier,binding.engine);
  roles[role]={receipt,assembly,binding};authorities[role]={assembly:assemblyPin,receipt:receiptPin,source:receipt.source,api:receipt.api};
}
assert(same(roles.baseline.binding.base,roles.candidate.binding.base)&&same(roles.baseline.binding.carrier,roles.candidate.binding.carrier)&&
  roles.baseline.binding.stamp===roles.candidate.binding.stamp,'Prepared Base must match exactly');
inputs.forEach(verify);
const out=path.resolve(args.out);assert(out.startsWith(root+'/selfhost/build/')&&!fs.existsSync(out),'Fresh build output required');
fs.mkdirSync(out,{recursive:true});assert.equal(fs.realpathSync(out),out,'Symlink output refused');
const report={kind:'phase173-indexed-vertical-controls',version:1,complete:false,passed:false,
  inputs,authorities,source,fixture:known[source.sha256],stages:{},
  scope:'Complete checked compiler values, same source and prepared Base. Shared hosted process diagnostic; not native runtime, complete cold-build timing, proof, or qualification.',
  chargedCandidateWork:['fresh store allocation','import of actual erased body','indexed compaction','indexed ordered reference traversal',
    'terminal complete KTerm export','store structural validation','store release before return'],
  retainedWork:['source checking and erasure','per-body imports/exports','legacy downstream consumers and final verifier'],
  runtimeOracleExecuted:false};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const started=performance.now();
try{
  report.comparator=comparatorControls();const apis={},plans={},bodyInputs={};
  for(const role of ['baseline','candidate']){
    let t=performance.now();apis[role]=(await import(pathToFileURL(roles[role].receipt.api.file))).default;
    report.stages[role]={apiLoadSeconds:(performance.now()-t)/1000};
    const {binding}=roles[role];t=performance.now();
    const prepared=apis[role].p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);
    report.stages[role].preparedBaseSeconds=(performance.now()-t)/1000;
    assert.equal(prepared?.$,'P86PreparationReady',prepared?.error);
    t=performance.now();plans[role]=apis[role].p86_plan(prepared.seed,source.file,fs.readFileSync(source.file,'utf8'));
    report.stages[role].frontendSeconds=(performance.now()-t)/1000;
    assert.equal(plans[role]?.$,'P86PlanReady',plans[role]?.error);
    t=performance.now();bodyInputs[role]=apis[role].p173v_inputs(plans[role].request);
    report.stages[role].extractErasedBodiesSeconds=(performance.now()-t)/1000;save();
  }
  report.checkedRequests=compare(plans.baseline,plans.candidate);
  report.completeInputs=compare(bodyInputs.baseline,bodyInputs.candidate);
  report.actualBodies=items(bodyInputs.baseline).length;assert(report.actualBodies>0,'No actual compiler computation exercised');
  const capturedInputs=JSON.stringify(bodyInputs.baseline)+'\n';
  assert(Buffer.byteLength(capturedInputs)<=128*1024**2,'Captured input exceeds declared file bound');
  const capturedInputFile=path.join(out,'complete-input-values.json');
  fs.writeFileSync(capturedInputFile,capturedInputs,{flag:'wx'});report.capturedInputs=pin(capturedInputFile);
  const controls=apis.baseline.p173v_control_inputs();compare(controls,apis.candidate.p173v_control_inputs());
  assert.equal(items(controls).length,16);report.roundtrips=[];
  for(const input of items(controls)){
    const expected=apis.baseline.p173v_original_body(input),actual=apis.candidate.p173v_roundtrip(input);
    assert.equal(actual.error,'');report.roundtrips.push({name:input.name,...compare(expected,actual)});
  }
  report.finiteCompaction=compare(apis.baseline.p173v_baseline(controls),apis.candidate.p173v_candidate(controls));
  const outputs={};
  for(const role of ['baseline','candidate']){
    const t=performance.now();outputs[role]=apis[role][role==='baseline'?'p173v_baseline':'p173v_candidate'](bodyInputs[role]);
    report.stages[role].completePassSeconds=(performance.now()-t)/1000;
    const rows=items(outputs[role]);assert.equal(rows.length,report.actualBodies);
    assert(rows.every(row=>row.$==='P173VBody'&&row.error===''),'Refused or incomplete actual body');save();
  }
  report.completePassOutputs=compare(outputs.baseline,outputs.candidate);
  report.observations=[];
  for(const role of ['baseline','candidate']){
    const serialized=JSON.stringify(outputs[role])+'\n';assert(Buffer.byteLength(serialized)<=128*1024**2,'Observation exceeds declared file bound');
    const file=path.join(out,role+'-complete-values.json');fs.writeFileSync(file,serialized,{flag:'wx'});
    report.observations.push({role,...pin(file)});
  }
  inputs.forEach(verify);report.complete=true;report.passed=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{report.wallSeconds=(performance.now()-started)/1000;save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,bodies:report.actualBodies,error:report.error}));}
