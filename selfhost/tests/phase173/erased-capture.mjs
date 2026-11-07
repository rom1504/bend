// Observation only: checked Bend owns every compiler operation.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {pin,verify,workspace} from '../../tools/build/hosted.mjs';
const args={};
for(let i=2;i<process.argv.length;i+=2){
  assert(process.argv[i]?.startsWith('--')&&process.argv[i+1]);
  const key=process.argv[i].slice(2);assert(!Object.hasOwn(args,key));args[key]=process.argv[i+1];
}
assert.deepEqual(Object.keys(args).sort(),['assembly','out','receipt','source']);
const read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
const receipt=read(args.receipt),assembly=read(args.assembly),binding=read(assembly.binding.file);
assert(receipt.complete&&receipt.checked&&!receipt.error&&assembly.complete&&assembly.protectedUnchanged);
assert.deepEqual(receipt.source,assembly.source);assert.deepEqual(receipt.exports,assembly.exports);
assert.equal(receipt.command[0],fs.realpathSync(process.execPath));
const source=pin(args.source);
const inputs=[pin(fileURLToPath(import.meta.url)),pin(process.execPath),pin(args.receipt),pin(args.assembly),
  source,...assembly.inputs,assembly.source,assembly.binding,assembly.exportManifest,
  ...receipt.inputs,receipt.api,binding.assets,binding.base,binding.carrier,binding.engine];
inputs.forEach(verify);
const out=path.resolve(args.out);assert(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out));
assert.equal(fs.realpathSync(path.dirname(out)),path.dirname(out));fs.mkdirSync(out);
const report={kind:'phase173-checked-erased-body-capture',complete:false,inputs,source,
  scope:'Complete erased bodies from checked Bend API; diagnostic transport, no optimization or timing claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try{
  const api=(await import(pathToFileURL(receipt.api.file))).default;
  for(const n of ['p88_cache_prepare','p86_plan','p173v_inputs'])assert(receipt.exports.includes(n));
  const prep=api.p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);
  assert.equal(prep.$,'P86PreparationReady',prep.error);
  const plan=api.p86_plan(prep.seed,source.file,fs.readFileSync(source.file,'utf8'));
  assert.equal(plan.$,'P86PlanReady',plan.error);
  let xs=api.p173v_inputs(plan.request);const rows=[];
  while(xs?.$==='Con'){
    assert(rows.length<10000);assert.equal(xs.head?.$,'P173VInput');
    rows.push(xs.head);xs=xs.tail;
  }
  assert.equal(xs?.$,'Nil');
  const value=JSON.stringify(rows,null,2)+'\n';assert(Buffer.byteLength(value)<=16*1024*1024);
  fs.writeFileSync(path.join(out,'bodies.json'),value,{flag:'wx'});
  report.bodies=pin(path.join(out,'bodies.json'));report.names=rows.map(x=>x.name);
  inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,count:report.names?.length,error:report.error}));}
