// Transport and observation only: checked Bend owns the diagnostic lowering.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../tools/build/hosted.mjs';

const own=fileURLToPath(import.meta.url),args={};
for(let i=2;i<process.argv.length;i+=2){
  const k=process.argv[i]?.replace(/^--/,'');
  need(process.argv[i]?.startsWith('--')&&process.argv[i+1]&&!Object.hasOwn(args,k),'Expected unique --key value');
  args[k]=process.argv[i+1];
}
need(['receipt','assembly','source','out'].every(k=>args[k]),'Required --receipt --assembly --source --out');
need(Object.keys(args).every(k=>['receipt','assembly','source','out'].includes(k)),'Unknown option');
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const same=(a,b)=>a.file===b.file&&a.bytes===b.bytes&&a.sha256===b.sha256;
function items(value){const rows=[];while(value?.$==='Con'){need(rows.length<1000000,'List bound');rows.push(value.head);value=value.tail;}need(value?.$==='Nil','Malformed diagnostic list');return rows;}
const out=path.resolve(args.out);
need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'Fresh build directory required');
fs.mkdirSync(out,{recursive:true});need(fs.realpathSync(out)===out,'Symlink output refused');
const report={kind:'phase173-candidate-admission-diagnostic',version:1,complete:false,
  inputs:[pin(own),pin(path.resolve(path.dirname(own),'../../tools/build/hosted.mjs')),
    pin(args.receipt),pin(args.assembly),pin(args.source),pin(process.execPath)],stages:{},
  scope:'Actual checked request, unchanged static preparation, selected p173 raw candidate errors and SCC obligations. Pre-early-ready diagnostic superset; no generic emission, machine execution, optimization or promotion claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const started=performance.now();save();
try{
  const assembly=read(args.assembly),receipt=read(args.receipt);
  need(assembly.kind==='phase171-api-source'&&assembly.complete&&assembly.protectedUnchanged,'Checked source transport authority required');
  need(receipt.kind==='bend-checked-hosted-api'&&receipt.version===1&&receipt.complete&&receipt.checked&&!receipt.error,'Checked API required');
  need(same(assembly.source,receipt.source),'Assembly/acquisition source differs');
  need(Array.isArray(receipt.exports)&&receipt.exports.length===assembly.exports.length&&receipt.exports.every((x,i)=>x===assembly.exports[i]),'API manifest differs');
  for(const name of ['p88_cache_prepare','p86_plan','p173vd_request'])need(receipt.exports.includes(name),'Missing export '+name);
  report.inputs.push(...assembly.inputs,assembly.source,assembly.exportManifest,assembly.binding,...receipt.inputs,receipt.api);
  const binding=read(assembly.binding.file);
  need(binding.kind==='phase171-prepared-base'&&binding.version===1,'Prepared Base binding required');
  report.inputs.push(binding.assets,binding.base,binding.carrier,binding.engine);
  need(same(binding.engine,pin(process.execPath)),'Use pinned Bun');report.inputs.forEach(verify);
  report.source=pin(args.source);report.assembly=pin(args.assembly);report.acquisition=pin(args.receipt);
  report.base=binding.base;report.carrier=binding.carrier;report.stamp=binding.stamp;
  const api=(await import(pathToFileURL(receipt.api.file))).default;
  report.stages.apiLoadSeconds=(performance.now()-started)/1000;
  let t=performance.now();
  const prepared=api.p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);
  report.stages.preparedBaseSeconds=(performance.now()-t)/1000;
  need(prepared?.$==='P86PreparationReady',prepared?.error??'Base refused');t=performance.now();
  const plan=api.p86_plan(prepared.seed,report.source.file,fs.readFileSync(report.source.file,'utf8'));
  report.stages.frontendSeconds=(performance.now()-t)/1000;save();
  need(plan?.$==='P86PlanReady',plan?.error??'Checked source refused');t=performance.now();
  const result=api.p173vd_request(plan.request);
  report.stages.diagnosticSeconds=(performance.now()-t)/1000;
  need(result?.$==='P173VDReport'&&result.error==='',result?.error??'Malformed diagnostic');
  const encoded=JSON.stringify(result)+'\n';need(Buffer.byteLength(encoded)<=128*1024**2,'Complete diagnostic output exceeds bound');
  const file=path.join(out,'complete-candidates.json');fs.writeFileSync(file,encoded,{flag:'wx'});report.observation=pin(file);
  report.selected=items(result.selected);
  const raw=items(result.raw);need(raw.every(row=>row.$==='P113DCandidate'),'Candidate constructor mismatch');
  report.candidates=raw.map(row=>({name:row.function.name,error:row.error,result:row.function.result,
    parameters:items(row.function.params).length,calls:items(row.calls).map(x=>x.name)}));
  report.components=items(result.components).map(row=>({...row,names:items(row.names)}));
  report.inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{report.wallSeconds=(performance.now()-started)/1000;save();console.log(JSON.stringify({complete:report.complete,
  selected:report.selected?.length,candidates:report.candidates?.length,components:report.components?.length,error:report.error}));}
