// Authenticated full P86Plan transport; every compiler decision stays in Bend.
// Warm backend replay is NEVER reported as cold source-to-executable time.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../tools/build/hosted.mjs';
import {encodeGraph,decodeGraph,writeGraph} from '../../../experiments/phase154/tools/graph.mjs';

const own=fileURLToPath(import.meta.url),a={};
for(let i=2;i<process.argv.length;i+=2){
  const key=process.argv[i]?.replace(/^--/,'');
  need(process.argv[i]?.startsWith('--')&&process.argv[i+1]&&!Object.hasOwn(a,key),'Unique --key value arguments required');
  a[key]=process.argv[i+1];
}
const allowed=['receipt','assembly','frontend','source','mode','out','capture','reference','node-limit','graph-mib'];
need(Object.keys(a).every(k=>allowed.includes(k)),'Unknown argument');
need(['receipt','assembly','frontend','source','mode','out'].every(k=>a[k]),'Missing required argument');
need(['capture','capture-emit','replay'].includes(a.mode),'Mode must be capture, capture-emit, or replay');
need((a.mode==='replay')===Boolean(a.capture),'Only replay requires --capture PLAN_RECEIPT');
need(!a.reference||a.mode!=='capture','Capture-only mode has no QBE reference');
const nodeLimit=Number(a['node-limit']??1000000),graphBytes=Number(a['graph-mib']??128)*1024**2;
need(Number.isInteger(nodeLimit)&&nodeLimit>=1&&nodeLimit<=4000000,'Graph node bound outside1..4M');
need(Number.isInteger(graphBytes)&&graphBytes>=1024**2&&graphBytes<=512*1024**2,'Graph byte bound outside1..512MiB');
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const same=(x,y)=>x?.file===y?.file&&x?.bytes===y?.bytes&&x?.sha256===y?.sha256;
const sameFingerprint=(x,y)=>x?.sha256===y?.sha256&&x?.declarations===y?.declarations&&x?.bytes===y?.bytes;
function* items(value){let n=0;while(value?.$==='Con'){need(++n<=1000000,'Unbounded Bend list');yield value.head;value=value.tail;}need(value?.$==='Nil','Malformed Bend list');}
function exactBytes(left,right){
  const x=fs.openSync(left,'r'),y=fs.openSync(right,'r'),xb=Buffer.alloc(1048576),yb=Buffer.alloc(1048576);
  try{for(;;){const nx=fs.readSync(x,xb,0,xb.length,null),ny=fs.readSync(y,yb,0,yb.length,null);if(nx!==ny||!xb.subarray(0,nx).equals(yb.subarray(0,ny)))return false;if(nx===0)return true;}}
  finally{fs.closeSync(x);fs.closeSync(y);}
}
const out=path.resolve(a.out);
need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'Fresh workspace build output required');
fs.mkdirSync(out,{recursive:true});need(fs.realpathSync(out)===out,'Symlink output refused');
const report={kind:'phase173-checked-plan-run',version:1,complete:false,mode:a.mode,warmReplay:a.mode==='replay',
  inputs:[pin(own),pin(path.resolve(path.dirname(own),'../../tools/build/hosted.mjs')),
    pin(path.resolve(path.dirname(own),'../../../experiments/phase154/tools/graph.mjs')),
    pin(a.receipt),pin(a.assembly),pin(a.frontend),pin(a.source),pin(process.execPath)],stages:{},
  scope:a.mode==='replay'?'Warm backend-only replay from an authenticated complete checked P86Plan. Frontend is omitted explicitly; not a cold-build metric.':
    'Full checked preparation, optionally followed by ordinary Bend backend emission. Hosted diagnostic, not native compiler or full executable-build timing.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const start=performance.now();save();
try{
  const assembly=read(a.assembly),receipt=read(a.receipt),front=read(a.frontend);
  need(assembly.kind==='phase171-api-source'&&assembly.complete&&assembly.protectedUnchanged,'Successful protected assembly required');
  need(receipt.kind==='bend-checked-hosted-api'&&receipt.version===1&&receipt.complete&&receipt.checked&&!receipt.error,'Successful checked API required');
  need(same(assembly.source,receipt.source),'Acquisition source differs');
  need(Array.isArray(receipt.exports)&&JSON.stringify(receipt.exports)===JSON.stringify(assembly.exports),'Different export contract');
  need(front.kind==='phase173-frontend-binding'&&front.version===1&&front.complete&&front.targetsRun===false,'Authenticated frontend binding required');
  need(same(front.assembly,pin(a.assembly))&&same(front.acquisition,pin(a.receipt))&&same(front.source,receipt.source)&&same(front.api,receipt.api),'Frontend binding is for another checked API');
  need(JSON.stringify(front.roots)===JSON.stringify(['p88_cache_prepare','p86_plan']),'Wrong frontend closure roots');
  const identity=crypto.createHash('sha256').update(JSON.stringify(front.declarations)).digest('hex');
  need(front.fingerprint.sha256===identity&&front.fingerprint.declarations===front.declarations.length,'Frontend declaration fingerprint differs');
  const boundary=front.acquisitionBoundary;
  need(boundary&&boundary.sha256===crypto.createHash('sha256').update(JSON.stringify({upstream:boundary.upstream,inputs:boundary.inputs})).digest('hex'),'Acquisition ABI fingerprint differs');
  report.inputs.push(...assembly.inputs,assembly.source,assembly.exportManifest,assembly.binding,...receipt.inputs,receipt.api,...front.inputs);
  report.inputs.forEach(verify);
  const binding=read(assembly.binding.file);
  need(binding.kind==='phase171-prepared-base'&&binding.version===1,'Missing Base binding');
  report.inputs.push(binding.assets,binding.base,binding.carrier,binding.engine);
  need(same(front.base,binding.base)&&same(front.carrier,binding.carrier)&&front.stamp===binding.stamp&&same(front.engine,binding.engine),'Frontend Base identity differs');
  need(same(binding.engine,pin(process.execPath)),'Pinned Bun engine required');
  report.inputs.forEach(verify);
  report.source=pin(a.source);report.base=binding.base;report.carrier=binding.carrier;report.stamp=binding.stamp;
  report.frontend=pin(a.frontend);report.fingerprint=front.fingerprint;report.assembly=pin(a.assembly);report.acquisition=pin(a.receipt);
  const api=(await import(pathToFileURL(receipt.api.file))).default;
  const required=a.mode==='capture'?['p88_cache_prepare','p86_plan']:['p88_cache_prepare','p86_plan','p169np_plan','p134e_next'];
  for(const name of required)need(receipt.exports.includes(name)&&typeof api[name]==='function','Missing export '+name);
  report.stages.authenticateLoadSeconds=(performance.now()-start)/1000;
  let plan,t;
  if(a.mode==='replay'){
    const capture=read(a.capture);
    need(capture.kind==='phase173-checked-plan'&&capture.version===1&&capture.complete&&capture.checkedTag==='P86PlanReady','Successful full-plan capture required');
    need(same(capture.source,report.source)&&same(capture.base,report.base)&&same(capture.carrier,report.carrier)&&capture.stamp===report.stamp,'Different source/logical path/Base/carrier/stamp');
    need(same(capture.engine,binding.engine)&&sameFingerprint(capture.fingerprint,front.fingerprint)&&capture.acquisitionBoundary===boundary.sha256,'Frontend, acquisition ABI or engine changed: recompute full checked plan');
    const producer=read(capture.acquisition.file),producerFront=read(capture.frontend.file);
    need(producer.kind==='bend-checked-hosted-api'&&producer.complete&&producer.checked&&!producer.error&&same(producer.api,capture.api),'Capture producer was not checked');
    need(producerFront.complete&&sameFingerprint(producerFront.fingerprint,front.fingerprint)&&producerFront.acquisitionBoundary?.sha256===boundary.sha256&&same(producerFront.acquisition,capture.acquisition),'Capture producer closure identity differs');
    report.inputs.push(pin(a.capture),...capture.inputs,capture.graph);report.inputs.forEach(verify);
    need(capture.graph.bytes<=graphBytes&&capture.nodes<=nodeLimit,'Captured graph exceeds explicit replay bounds');
    t=performance.now();const graph=read(capture.graph.file);
    need(Array.isArray(graph.nodes)&&graph.nodes.length===capture.nodes,'Graph node count differs');
    plan=decodeGraph(graph);report.stages.decodeSeconds=(performance.now()-t)/1000;
    report.capture=pin(a.capture);report.stages.baseSeconds=0;report.stages.frontendSeconds=0;
    report.preparationPolicy='fresh decoded immutable artifact; no p88_cache_prepare or p86_plan execution';
    report.omittedPreparation=capture.preparation;
  }else{
    t=performance.now();
    const prepared=api.p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);
    report.stages.baseSeconds=(performance.now()-t)/1000;
    need(prepared?.$==='P86PreparationReady',prepared?.error??'Prepared Base refused');
    t=performance.now();plan=api.p86_plan(prepared.seed,report.source.file,fs.readFileSync(report.source.file,'utf8'));
    report.stages.frontendSeconds=(performance.now()-t)/1000;
    need(plan?.$==='P86PlanReady'&&plan.request?.$==='NR_Request',plan?.error??'Checked request refused');
    t=performance.now();const graph=encodeGraph(plan,{nodeLimit}),file=path.join(out,'plan.graph.json');
    writeGraph(file,graph,graphBytes);report.stages.captureSeconds=(performance.now()-t)/1000;
    report.inputs.forEach(verify);
    const captured={kind:'phase173-checked-plan',version:1,complete:true,checkedTag:'P86PlanReady',
      source:report.source,base:report.base,carrier:report.carrier,stamp:report.stamp,engine:binding.engine,
      fingerprint:front.fingerprint,acquisitionBoundary:boundary.sha256,frontend:report.frontend,acquisition:report.acquisition,api:receipt.api,
      graph:pin(file),nodes:graph.nodes.length,inputs:[...report.inputs],
      preparation:{baseSeconds:report.stages.baseSeconds,frontendSeconds:report.stages.frontendSeconds,captureSeconds:report.stages.captureSeconds},
      scope:'Complete P86Plan including request and verdict, with object sharing preserved. No semantic projection, arbitrary caller certificate, or cached backend plan.'};
    const captureFile=path.join(out,'plan.json');fs.writeFileSync(captureFile,JSON.stringify(captured,null,2)+'\n',{flag:'wx'});
    report.capture=pin(captureFile);report.preparationPolicy='authenticated prepared Base followed by full p86_plan';
  }
  need(plan?.$==='P86PlanReady'&&plan.request?.$==='NR_Request'&&typeof plan.verdict==='string','Malformed captured plan boundary');
  if(a.mode!=='capture'){
    t=performance.now();const emission=api.p169np_plan(plan);report.stages.lowerVerifySeconds=(performance.now()-t)/1000;save();
    need(emission?.$==='P169Prepared'&&emission.error==='',emission?.error??'Wrong emission');
    const file=path.join(out,'program.ssa'),fd=fs.openSync(file,'wx'),hash=crypto.createHash('sha256');let bytes=0,pieces=0;
    const write=text=>{need(typeof text==='string','Malformed text chunk');bytes+=Buffer.byteLength(text);need(bytes<=256*1024**2,'QBE exceeds256MiB');hash.update(text);fs.writeSync(fd,text);};
    t=performance.now();
    try{
      for(const text of items(emission.forwarders)){write(text);write('\n');}
      let cursor=emission.cursor;
      for(;;){const next=api.p134e_next(cursor);if(next?.$==='P134Done')break;
        need(next?.$==='P134Piece'&&typeof next.legacy_end==='boolean'&&++pieces<=1000000,'Malformed cursor');
        write(next.text);if(next.legacy_end)write('\n');cursor=next.next;}
    }finally{fs.closeSync(fd);}
    report.stages.renderWriteSeconds=(performance.now()-t)/1000;report.ir={file,bytes,sha256:hash.digest('hex')};report.pieces=pieces;
    if(a.reference){
      const reference=read(a.reference);
      need(reference.complete&&reference.ir&&(['phase171-checked-request','phase173-checked-plan-run'].includes(reference.kind)),'Successful QBE reference required');
      need(reference.kind!=='phase171-checked-request'||reference.mode==='baseline','Reference is not ordinary QBE mode');
      need(same(reference.source,report.source)&&same(reference.base,report.base)&&same(reference.carrier,report.carrier)&&reference.stamp===report.stamp,'Different reference workload');
      verify(reference.ir);report.inputs.push(pin(a.reference),reference.ir);report.exactQbe=exactBytes(file,reference.ir.file);need(report.exactQbe,'Full QBE bytes differ');
    }
  }
  report.inputs.forEach(verify);verify(report.capture);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{report.wallSeconds=(performance.now()-start)/1000;save();console.log(JSON.stringify({complete:report.complete,mode:report.mode,warmReplay:report.warmReplay,capture:report.capture,ir:report.ir,error:report.error}));}
