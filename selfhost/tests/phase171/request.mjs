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
need(['receipt','assembly','source','mode','out'].every(k=>args[k]),'Required: --receipt --assembly --source --mode --out');
need(Object.keys(args).every(k=>['receipt','assembly','source','mode','out','reference'].includes(k)),'Unknown argument');
need(['baseline','imports','import-controls'].includes(args.mode),'Unknown mode');
need(!args.reference||args.mode==='baseline','Exact-QBE comparison is for unmodified/lowerer-overlay pipelines');
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const same=(a,b)=>a.file===b.file&&a.bytes===b.bytes&&a.sha256===b.sha256;
function* items(value){let n=0;while(value?.$==='Con'){need(++n<=1000000,'Unbounded Bend list');yield value.head;value=value.tail;}need(value?.$==='Nil','Malformed Bend list');}
function bytesEqual(a,b){
  const x=fs.openSync(a,'r'),y=fs.openSync(b,'r'),xb=Buffer.alloc(1048576),yb=Buffer.alloc(1048576);
  try{for(;;){const nx=fs.readSync(x,xb,0,xb.length,null),ny=fs.readSync(y,yb,0,yb.length,null);if(nx!==ny||!xb.subarray(0,nx).equals(yb.subarray(0,ny)))return false;if(nx===0)return true;}}
  finally{fs.closeSync(x);fs.closeSync(y);}
}
const out=path.resolve(args.out);
need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'Fresh workspace build output required');
fs.mkdirSync(out,{recursive:true});
need(fs.realpathSync(out)===out,'Symlink output refused');
const report={kind:'phase171-checked-request',version:1,complete:false,mode:args.mode,
  inputs:[pin(own),pin(path.resolve(path.dirname(own),'../../tools/build/hosted.mjs')),pin(args.receipt),pin(args.assembly),pin(args.source),pin(process.execPath)],stages:{},
  scope:'Checked experimental hosted compiler request. This is not native compiler timing, generated-program execution, or promotion.'};
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
  for(const name of ['p88_cache_prepare','p86_plan',...(args.mode==='baseline'?['p169np_plan','p134e_next']:args.mode==='imports'?['p171_plan','p171e_next']:['p171_controls'])])need(receipt.exports.includes(name)&&typeof api[name]==='function','Required export missing: '+name);
  let t=performance.now();
  const prepared=api.p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);
  report.stages.baseSeconds=(performance.now()-t)/1000;
  need(prepared?.$==='P86PreparationReady',prepared?.error??'Prepared Base refused');
  t=performance.now();
  const plan=api.p86_plan(prepared.seed,report.source.file,fs.readFileSync(report.source.file,'utf8'));
  report.stages.frontendSeconds=(performance.now()-t)/1000;save();
  need(plan?.$==='P86PlanReady',plan?.error??'Checked request refused');
  t=performance.now();
  if(args.mode==='import-controls'){
    report.controls=[...items(api.p171_controls(plan.request))];
    need(report.controls.length===9,'Expected nine import controls');
    report.controls.forEach((value,index)=>{need(typeof value==='string'&&!value.includes('coverage gap:'),'Untested import boundary');need((value==='')===[0,8].includes(index),'Import control differs at '+index);});
    report.stages.controlsSeconds=(performance.now()-t)/1000;
  }else{
    const emission=args.mode==='baseline'?api.p169np_plan(plan):api.p171_plan(plan);
    report.stages.lowerVerifySeconds=(performance.now()-t)/1000;save();
    need(emission?.$===(args.mode==='baseline'?'P169Prepared':'P171Emission')&&emission.error==='',emission?.error??'Wrong emission');
    if(args.mode==='imports')report.importOwners=[...items(emission.imports)].map(item=>item.segment.name??item.segment.owner);
    const file=path.join(out,'program.ssa'),fd=fs.openSync(file,'wx'),hash=crypto.createHash('sha256');
    let bytes=0,pieces=0;
    const write=text=>{need(typeof text==='string','Malformed text chunk');bytes+=Buffer.byteLength(text);need(bytes<=256*1024**2,'QBE exceeds 256 MiB');hash.update(text);fs.writeSync(fd,text);};
    t=performance.now();
    try{
      for(const text of items(args.mode==='baseline'?emission.forwarders:emission.prefix)){write(text);write('\n');}
      let cursor=emission.cursor;
      for(;;){
        const next=args.mode==='baseline'?api.p134e_next(cursor):api.p171e_next(emission.imports,cursor);
        if(next?.$==='P134Done')break;
        need(next?.$==='P134Piece'&&typeof next.legacy_end==='boolean'&&++pieces<=1000000,'Malformed cursor');
        write(next.text);if(next.legacy_end)write('\n');cursor=next.next;
      }
    }finally{fs.closeSync(fd);}
    report.stages.renderWriteSeconds=(performance.now()-t)/1000;
    report.ir={file,bytes,sha256:hash.digest('hex')};report.pieces=pieces;
    if(args.reference){
      const reference=read(args.reference);
      need(reference.kind==='phase171-checked-request'&&reference.complete&&reference.mode==='baseline','Successful baseline request reference required');
      need(same(reference.source,report.source)&&same(reference.base,report.base)&&same(reference.carrier,report.carrier)&&reference.stamp===report.stamp,'Different reference workload/Base');
      verify(reference.ir);report.inputs.push(pin(args.reference),reference.ir);
      report.exactQbe=bytesEqual(file,reference.ir.file);need(report.exactQbe,'Full QBE bytes differ');
    }
  }
  report.inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{report.wallSeconds=(performance.now()-start)/1000;save();console.log(JSON.stringify({complete:report.complete,mode:report.mode,ir:report.ir,controls:report.controls?.length,error:report.error}));}
