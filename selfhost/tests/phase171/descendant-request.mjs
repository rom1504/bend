// Checked Bend calls and byte transport only. Root owns guarded execution.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../tools/build/hosted.mjs';

const own=fileURLToPath(import.meta.url),args={};
for(let i=2;i<process.argv.length;i+=2){
  const key=process.argv[i]?.replace(/^--/,'');
  need(process.argv[i]?.startsWith('--')&&process.argv[i+1]&&!Object.hasOwn(args,key),'Unique --key value arguments required');
  args[key]=process.argv[i+1];
}
need(['receipt','assembly','source','out','owner','mode'].every(k=>args[k]),'Required: --receipt --assembly --source --out');
need(Object.keys(args).every(k=>['receipt','assembly','source','out','owner','mode'].includes(k)),'Unknown argument');
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const same=(a,b)=>a.file===b.file&&a.bytes===b.bytes&&a.sha256===b.sha256;
function* items(value){let n=0;while(value?.$==='Con'){need(++n<=1000000,'Unbounded Bend list');yield value.head;value=value.tail;}need(value?.$==='Nil','Malformed Bend list');}
const out=path.resolve(args.out);
need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'Fresh workspace build output required');
fs.mkdirSync(out,{recursive:true});
need(fs.realpathSync(out)===out,'Symlink output refused');
const report={kind:'phase171-descendant-emission',version:1,complete:false,mode:'metadata',
  inputs:[pin(own),pin(path.resolve(path.dirname(own),'../../tools/build/hosted.mjs')),pin(args.receipt),pin(args.assembly),pin(args.source),pin(process.execPath)],stages:{},
  scope:'Authenticated producer metadata from a source-checked experimental API. Includes actual proposal source/structural checks, but is not native execution, lifetime qualification, a proof or promotion.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const start=performance.now();save();
try{
  const assembly=read(args.assembly),receipt=read(args.receipt);
  need(assembly.kind==='phase171-api-source'&&assembly.complete&&assembly.protectedUnchanged,'Invalid assembly receipt');
  need(receipt.kind==='bend-checked-hosted-api'&&receipt.version===1&&receipt.complete&&receipt.checked&&!receipt.error,'Checked successful acquisition required');
  need(same(assembly.source,receipt.source),'Acquisition is not of this assembled source');
  need(Array.isArray(receipt.exports)&&receipt.exports.length===assembly.exports.length&&receipt.exports.every((x,i)=>x===assembly.exports[i]),'Different exported API');
  report.inputs.push(...assembly.inputs,assembly.source,assembly.exportManifest,assembly.binding,...receipt.inputs,receipt.api);
  report.inputs.forEach(verify);
  const binding=read(assembly.binding.file);
  need(binding.kind==='phase171-prepared-base'&&binding.version===1,'Missing prepared Base binding');
  report.inputs.push(binding.assets,binding.base,binding.carrier,binding.engine);
  report.inputs.forEach(verify);
  need(same(binding.engine,pin(process.execPath)),'Run with the pinned Bun executable');
  report.source=pin(args.source);report.assembly=pin(args.assembly);report.acquisition=pin(args.receipt);
  report.base=binding.base;report.carrier=binding.carrier;report.stamp=binding.stamp;
  report.preparationPolicy='authenticated prepared Base, fresh process';
  const known={
    ff6b4083aa2f3e034f3b4f8e43dfb25d93a4f524685934e0ee13845278033ef3:{name:'captured-real-verifier',bytes:39333,stdout:'768\n'},
    cd22c831c180c0de12d84aeb80debf4881d08cbd18fcf8f6d634153fba2feb03:{name:'native45-map-churn-128',bytes:3659,oracle:'experiments/phase167/tools/map-oracle.py',scope:'Timed IO output: semantic fields checked by the native45 oracle, not exact timing text.'},
  };
  const fixture=known[report.source.sha256];
  if(fixture){need(fixture.bytes===report.source.bytes,'Fixed fixture size differs');report.independentRuntimeOracle={...fixture,executed:false};}
  const api=(await import(pathToFileURL(receipt.api.file))).default;
  report.stages.loadSeconds=(performance.now()-start)/1000;
  for(const name of ['p88_cache_prepare','p86_plan','p169np_plan','p171d_plan','p134e_next'])need(receipt.exports.includes(name)&&typeof api[name]==='function','Required export missing: '+name);
  let t=performance.now();
  const prepared=api.p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);
  report.stages.baseSeconds=(performance.now()-t)/1000;
  need(prepared?.$==='P86PreparationReady',prepared?.error??'Prepared Base refused');
  t=performance.now();
  const plan=api.p86_plan(prepared.seed,report.source.file,fs.readFileSync(report.source.file,'utf8'));
  report.stages.frontendSeconds=(performance.now()-t)/1000;save();
  need(plan?.$==='P86PlanReady',plan?.error??'Checked request refused');
  need(['baseline','descendant'].includes(args.mode),'Unknown mode');
  t=performance.now();
  const emission=args.mode==='baseline'?api.p169np_plan(plan):api.p171d_plan(plan,args.owner);
  report.stages.lowerVerifySeconds=(performance.now()-t)/1000;
  need(emission?.$==='P169Prepared'&&emission.error==='',emission?.error??'Invalid emission');
  report.mode=args.mode;report.owner=args.owner;
  const file=path.join(out,'program.ssa'),fd=fs.openSync(file,'wx'),hash=crypto.createHash('sha256');
  let bytes=0,pieces=0;
  const write=text=>{need(typeof text==='string','Malformed text chunk');bytes+=Buffer.byteLength(text);need(bytes<=128*1024**2,'QBE exceeds 128MiB');hash.update(text);fs.writeSync(fd,text);};
  t=performance.now();
  try{
    for(const text of items(emission.forwarders)){write(text);write('\n');}
    let cursor=emission.cursor;
    for(;;){const next=api.p134e_next(cursor);if(next?.$==='P134Done')break;
      need(next?.$==='P134Piece'&&typeof next.legacy_end==='boolean'&&++pieces<=1000000,'Malformed cursor');
      write(next.text);if(next.legacy_end)write('\n');cursor=next.next;}
  }finally{fs.closeSync(fd);}
  report.stages.renderWriteSeconds=(performance.now()-t)/1000;
  report.ir={file,bytes,sha256:hash.digest('hex')};report.pieces=pieces;
  report.inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{report.wallSeconds=(performance.now()-start)/1000;save();console.log(JSON.stringify({complete:report.complete,ir:report.ir,error:report.error}));}
