// Authenticated calls to checked Bend controls; no compiler transformation here.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {pin,verify,workspace} from '../../tools/build/hosted.mjs';
const args={};
for(let i=2;i<process.argv.length;i+=2){
  assert(process.argv[i]?.startsWith('--')&&process.argv[i+1]);
  const key=process.argv[i].slice(2);assert(!Object.hasOwn(args,key));args[key]=process.argv[i+1];
}
assert.deepEqual(Object.keys(args).sort(),['assembly','out','receipt']);
const read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
const assembly=read(args.assembly),receipt=read(args.receipt);
assert(assembly.complete&&assembly.protectedUnchanged&&receipt.complete&&receipt.checked&&!receipt.error);
assert.deepEqual(assembly.source,receipt.source);assert.deepEqual(assembly.exports,receipt.exports);
const inputs=[pin(fileURLToPath(import.meta.url)),pin(process.execPath),pin(args.assembly),pin(args.receipt),
  ...assembly.inputs,assembly.source,assembly.exportManifest,assembly.binding,...receipt.inputs,receipt.api];
inputs.forEach(verify);
assert.equal(receipt.command[0],fs.realpathSync(process.execPath));
const out=path.resolve(args.out);assert(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out));
fs.mkdirSync(out,{recursive:true});assert.equal(fs.realpathSync(out),out);
const report={kind:'phase173-abi-finite-controls',complete:false,inputs,rows:{},
  scope:'Finite compiler-data controls and existing final verifiers; not a correctness theorem or native qualification.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try{
  const api=(await import(pathToFileURL(receipt.api.file))).default;
  for(const [name,count] of [['p173sc_controls',21],['p173ab_controls',25]]){
    assert(receipt.exports.includes(name));let xs=api[name]();const rows=[];
    while(xs?.$==='Con'){assert(rows.length<64);assert.equal(typeof xs.head,'string');rows.push(xs.head);xs=xs.tail;}
    report.rows[name]=rows;assert.equal(xs?.$,'Nil');assert.equal(rows.length,count);
    rows.forEach(row=>assert(row.endsWith(':pass'),row));
  }
  inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,rows:report.rows,error:report.error}));}
