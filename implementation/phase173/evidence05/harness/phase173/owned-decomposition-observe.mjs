// Authenticated observation only. Checked Bend performs checking, summary
// admission and transformation. Host code validates/records their outputs.
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
const mode=args.mode??'all';
assert(['all','controls','inspect'].includes(mode),'Unknown mode');
assert(['receipt','assembly','out'].every(k=>args[k]),'Required: --receipt --assembly --out');
assert(Object.keys(args).every(k=>['receipt','assembly','out','mode','pattern','layout','user'].includes(k)),'Unknown argument');
assert(mode==='controls'||['pattern','layout','user'].every(k=>args[k]),'Inspection requires all three explicit frozen sources');
assert(mode!=='controls'||!['pattern','layout','user'].some(k=>args[k]),'Controls-only mode does not consume source inputs');
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
const report={kind:'phase173-owned-decomposition-observation',version:1,mode,complete:false,
  inputs:[pin(own),pin(path.resolve(path.dirname(own),'../../tools/build/hosted.mjs')),
    pin(process.execPath),pin(args.receipt),pin(args.assembly)],controls:[],workloads:[],stages:{},
  scope:'Checked Bend finite controls and semantic-plan admission diagnostics. No host optimization, native execution, full request timing, or production qualification.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();const start=performance.now();
try{
  const receipt=read(args.receipt),assembly=read(args.assembly);
  assert.equal(receipt.kind,'bend-checked-hosted-api');assert.equal(receipt.version,1);
  assert(receipt.complete&&receipt.checked&&!receipt.error,'Successful checked API required');
  assert.equal(assembly.kind,'phase171-api-source');assert(assembly.complete&&assembly.protectedUnchanged);
  assert.deepEqual(receipt.source,assembly.source);assert.deepEqual(receipt.exports,assembly.exports);
  report.inputs.push(...assembly.inputs,assembly.source,assembly.binding,assembly.exportManifest,...receipt.inputs,receipt.api);
  report.inputs.forEach(verify);
  const binding=read(assembly.binding.file);
  assert.equal(binding.kind,'phase171-prepared-base');assert.equal(binding.version,1);
  report.inputs.push(binding.assets,binding.base,binding.carrier,binding.engine);
  assert.deepEqual(binding.engine,pin(process.execPath),'Pinned Bun engine required');
  assert.equal(receipt.command[0],fs.realpathSync(process.execPath));
  const sourceNames=mode==='controls'?[]:['pattern','layout','user'];
  const sources=Object.fromEntries(sourceNames.map(name=>[name,pin(args[name])]));
  report.inputs.push(...Object.values(sources));report.inputs.forEach(verify);
  report.assembly=pin(args.assembly);report.acquisition=pin(args.receipt);report.api=receipt.api;
  report.compilerSource=receipt.source;report.base=binding.base;report.carrier=binding.carrier;report.stamp=binding.stamp;
  report.replacements=assembly.replacements;
  const required=[...(mode!=='inspect'?['p173oa_controls']:[]),...(mode!=='controls'?['p88_cache_prepare','p86_plan','p173oa_inspect_request','p173od_pair']:[])];
  const api=(await import(pathToFileURL(receipt.api.file))).default;
  for(const name of required)assert(receipt.exports.includes(name)&&typeof api[name]==='function','Missing '+name);
  report.stages.authenticationLoadSeconds=(performance.now()-start)/1000;
  if(mode!=='inspect'){
    const t=performance.now();report.controls=list(api.p173oa_controls(),32);
    report.stages.controlsSeconds=(performance.now()-t)/1000;
    assert.equal(report.controls.length,16,'Expected16 independent finite controls');
    assert.equal(new Set(report.controls).size,16,'Duplicate control rows');
    for(const row of report.controls)assert(typeof row==='string'&&row.endsWith(':pass'),String(row));
    save();
  }
  if(mode!=='controls'){
    const t=performance.now();
    const prepared=api.p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),
      fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);
    report.stages.baseSeconds=(performance.now()-t)/1000;
    assert.equal(prepared?.$,'P86PreparationReady',prepared?.error);
    report.preparationPolicy='One authenticated immutable prepared Base, fresh checked source request per workload; diagnostic clocks only.';
    const queries={pattern:['ks','k_with_children'],layout:['ks','k_rebuild'],user:['p173odw_get','p173odw_set']};
    for(const name of sourceNames){
      const source=sources[name],row={name,source,stages:{}};report.workloads.push(row);save();
      let t=performance.now();
      const plan=api.p86_plan(prepared.seed,source.file,fs.readFileSync(source.file,'utf8'));
      row.stages.frontendSeconds=(performance.now()-t)/1000;
      assert.equal(plan?.$,'P86PlanReady',plan?.error);assert.equal(plan.request?.$,'NR_Request');
      row.checkedTag=plan.$;row.verdict=plan.verdict;
      t=performance.now();row.rows=list(api.p173oa_inspect_request(plan.request),10000);
      row.stages.inspectSeconds=(performance.now()-t)/1000;
      assert(row.rows.length>0&&row.rows.every(x=>typeof x==='string'),'Missing inspection scope');
      assert(['scope:pure','scope:foreign-or-unknown-refused'].includes(row.rows[0]),'Unknown scope');
      row.scope=row.rows[0];row.owners=[];row.transformedRows=0;
      for(const text of row.rows.slice(1)){
        const match=/^(.+):rows=([0-9]+)$/.exec(text);assert(match,'Malformed diagnostic row');
        const count=Number(match[2]);assert(Number.isSafeInteger(count)&&count>0&&count<=1000000);
        row.owners.push({owner:match[1],rows:count});row.transformedRows+=count;
      }
      assert.equal(new Set(row.owners.map(x=>x.owner)).size,row.owners.length,'Duplicate owner diagnostic');
      assert(row.scope==='scope:pure'||row.owners.length===0,'Refused request reported transforms');
      t=performance.now();
      const pair=api.p173od_pair(plan.request.book,...queries[name]);
      row.stages.summarySeconds=(performance.now()-t)/1000;
      assert(['Some','None'].includes(pair?.$),'Malformed summary result');
      const file=path.join(out,name+'-summary.json'),encoded=JSON.stringify(pair,null,2)+'\n';
      assert(Buffer.byteLength(encoded)<=2*1024**2,'Summary exceeds2MiB transport bound');
      fs.writeFileSync(file,encoded,{flag:'wx'});
      row.summary={query:queries[name],admitted:pair.$==='Some',artifact:pin(file)};
      report.inputs.forEach(verify);save();
    }
  }
  report.inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{
  report.wallSeconds=(performance.now()-start)/1000;save();
  console.log(JSON.stringify({complete:report.complete,mode,controls:report.controls.length,
    workloads:report.workloads.map(x=>({name:x.name,owners:x.owners?.length,rows:x.transformedRows,scope:x.scope})),error:report.error}));
}
