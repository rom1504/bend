// Observation-only transport: checked Bend owns every predicate and rewrite.
// One frozen source,32 finite controls, no emission or native execution.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {pin,verify,workspace} from '../../tools/build/hosted.mjs';

const own=fileURLToPath(import.meta.url),args={};
for(let i=2;i<process.argv.length;i+=2){
  assert(process.argv[i]?.startsWith('--')&&process.argv[i+1],'Expected --key value');
  const key=process.argv[i].slice(2);assert(!Object.hasOwn(args,key),'Duplicate '+key);args[key]=process.argv[i+1];
}
assert(['receipt','assembly','source','out'].every(k=>args[k]),'Required: --receipt --assembly --source --out');
assert(Object.keys(args).every(k=>['receipt','assembly','source','out'].includes(k)),'Unknown argument');
const read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
function list(value,limit){
  const result=[];
  while(value?.$==='Con'){
    assert(result.length<limit,'Bounded Bend list exceeded');result.push(value.head);value=value.tail;
  }
  assert.equal(value?.$,'Nil','Malformed Bend list');return result;
}
const out=path.resolve(args.out);
assert(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'Fresh workspace build output required');
assert.equal(fs.realpathSync(path.dirname(out)),path.dirname(out),'Parent symlink refused');
fs.mkdirSync(out);assert.equal(fs.realpathSync(out),out);
const report={kind:'phase173-qbe-owned-decomposition-observation',version:3,complete:false,
  inputs:[pin(own),pin(path.resolve(path.dirname(own),'../../tools/build/hosted.mjs')),
    pin(process.execPath),pin(args.receipt),pin(args.assembly),pin(args.source)],
  controls:[],stages:{},
  scope:'Checked Bend finite controls and QBE permission/owner census for one frozen source. No host optimization, native execution, full request timing, or production qualification.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();const start=performance.now();
try{
  const receipt=read(args.receipt),assembly=read(args.assembly);
  assert.equal(receipt.kind,'bend-checked-hosted-api');assert.equal(receipt.version,1);
  assert(receipt.complete&&receipt.checked&&!receipt.error,'Successful checked API required');
  assert.equal(assembly.kind,'phase171-api-source');assert(assembly.complete&&assembly.protectedUnchanged);
  assert.deepEqual(receipt.source,assembly.source);assert.deepEqual(receipt.exports,assembly.exports);
  assert.deepEqual(assembly.replacements.map(x=>x.name),['p168_catalogued'],'Sole QBE-specific hook required');
  report.inputs.push(...assembly.inputs,assembly.source,assembly.binding,assembly.exportManifest,...receipt.inputs,receipt.api);
  report.inputs.forEach(verify);
  const binding=read(assembly.binding.file);
  assert.equal(binding.kind,'phase171-prepared-base');assert.equal(binding.version,1);
  report.inputs.push(binding.assets,binding.base,binding.carrier,binding.engine);
  assert.deepEqual(binding.engine,pin(process.execPath),'Pinned Bun engine required');
  assert.equal(receipt.command[0],fs.realpathSync(process.execPath));
  report.inputs.forEach(verify);
  report.assembly=pin(args.assembly);report.acquisition=pin(args.receipt);report.api=receipt.api;
  report.compilerSource=receipt.source;report.source=pin(args.source);
  report.base=binding.base;report.carrier=binding.carrier;report.stamp=binding.stamp;
  report.replacements=assembly.replacements;
  const api=(await import(pathToFileURL(receipt.api.file))).default;
  for(const name of ['p173oa_controls','p173op_controls','p88_cache_prepare','p86_plan','p173op_inspect_request']){
    assert(receipt.exports.includes(name)&&typeof api[name]==='function','Missing '+name);
  }
  report.stages.authenticationLoadSeconds=(performance.now()-start)/1000;
  let t=performance.now();
  for(const name of ['p173oa_controls','p173op_controls']){
    const rows=list(api[name](),32);assert.equal(rows.length,16,'Expected16 controls from '+name);
    report.controls.push({export:name,rows});
    assert.equal(new Set(rows).size,16,'Duplicate controls in '+name);
    for(const row of rows)assert(typeof row==='string'&&row.endsWith(':pass'),String(row));
  }
  assert.equal(new Set(report.controls.flatMap(x=>x.rows)).size,32,'Repeated control across suites');
  report.stages.controlsSeconds=(performance.now()-t)/1000;report.inputs.forEach(verify);save();
  t=performance.now();
  const prepared=api.p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),
    fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);
  report.stages.baseSeconds=(performance.now()-t)/1000;
  assert.equal(prepared?.$,'P86PreparationReady',prepared?.error);
  t=performance.now();
  const plan=api.p86_plan(prepared.seed,report.source.file,fs.readFileSync(report.source.file,'utf8'));
  report.stages.frontendSeconds=(performance.now()-t)/1000;
  assert.equal(plan?.$,'P86PlanReady',plan?.error);assert.equal(plan.request?.$,'NR_Request');
  report.checkedTag=plan.$;report.verdict=plan.verdict;save();
  t=performance.now();report.rows=list(api.p173op_inspect_request(plan.request),10000);
  report.stages.inspectSeconds=(performance.now()-t)/1000;
  assert(report.rows.length>=3&&report.rows.every(x=>typeof x==='string'),'Missing permission rows');
  assert(['runtime:admitted','runtime:refused'].includes(report.rows[0]));
  assert(['observer-certificate:admitted','observer-certificate:refused'].includes(report.rows[1]));
  assert(['scope:qbe-certified','scope:qbe-refused'].includes(report.rows[2]));
  report.runtimeAdmitted=report.rows[0]==='runtime:admitted';
  report.observerCertificate=report.rows[1]==='observer-certificate:admitted';
  report.scopeAdmitted=report.rows[2]==='scope:qbe-certified';
  assert.equal(report.scopeAdmitted,report.runtimeAdmitted&&report.observerCertificate);
  report.owners=[];report.transformedRows=0;
  for(const row of report.rows.slice(3)){
    const match=/^(.+):rows=([0-9]+)$/.exec(row);assert(match,'Malformed owner row');
    const count=Number(match[2]);assert(Number.isSafeInteger(count)&&count>0&&count<=1000000);
    report.owners.push({owner:match[1],rows:count});report.transformedRows+=count;
  }
  assert.equal(new Set(report.owners.map(x=>x.owner)).size,report.owners.length,'Duplicate owner');
  assert(report.scopeAdmitted||report.owners.length===0,'Refused scope reported rewrites');
  report.inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{report.wallSeconds=(performance.now()-start)/1000;save();}
