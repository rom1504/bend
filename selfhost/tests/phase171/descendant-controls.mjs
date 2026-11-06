// Invoke a checked Bend finite-control export; no semantic implementation here.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../tools/build/hosted.mjs';
const args={};
for(let i=2;i<process.argv.length;i+=2){
  need(process.argv[i]?.startsWith('--')&&process.argv[i+1],'--key value required');
  const key=process.argv[i].slice(2);need(!Object.hasOwn(args,key),'Duplicate argument');args[key]=process.argv[i+1];
}
need(Object.keys(args).sort().join(',')==='count,export,out,receipt','Expected receipt/export/count/out');
const receipt=JSON.parse(fs.readFileSync(args.receipt,'utf8'));
need(receipt.kind==='bend-checked-hosted-api'&&receipt.complete&&receipt.checked&&receipt.exports.includes(args.export),'Checked export required');
const expected=Number(args.count);need(Number.isSafeInteger(expected)&&expected>0&&expected<=1000,'Bounded control count required');
const out=path.resolve(args.out);need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'Fresh output required');
fs.mkdirSync(out,{recursive:true});
const inputs=[pin(fileURLToPath(import.meta.url)),pin(process.execPath),pin(args.receipt),receipt.api,...receipt.inputs];
const report={kind:'phase171-descendant-controls',complete:false,inputs,export:args.export,expected,rows:[],scope:'Finite checked Bend controls, not a proof or native qualification.'};
try{
  inputs.forEach(verify);
  const api=(await import(pathToFileURL(receipt.api.file))).default;
  let value=api[args.export]();
  while(value?.$==='Con'){
    need(report.rows.length<expected,'Too many controls');
    report.rows.push(value.head);value=value.tail;
  }
  need(value?.$==='Nil'&&report.rows.length===expected,'Wrong control count');
  report.rows.forEach(v=>need(typeof v==='string'&&v.startsWith('PASS '),'Control failed: '+String(v)));
  inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,controls:report.rows.length,error:report.error}));
