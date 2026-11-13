// Checked Bend owns source preparation, lowering, typed selection and ELF.
// This adapter transports the same typed sequence to its two checked consumers.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../tools/build/hosted.mjs';

const a={};
for(let i=2;i<process.argv.length;i+=2){
  const key=process.argv[i]?.slice(2),value=process.argv[i+1];
  need(process.argv[i]?.startsWith('--')&&['api','binding','source-manifest','out','cases','target','emit'].includes(key)&&value,'Known --key value required');
  need(!Object.hasOwn(a,key),'Duplicate option '+key);a[key]=value;
}
for(const key of ['api','binding','out'])need(a[key],'Required --'+key);
const target=a.target??'x86',emit=a.emit??'object';
need(target==='x86'&&['object','assembly'].includes(emit),'Typed x86 object/assembly required');
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const catalogFile=path.join(workspace,'selfhost/tools/bench/catalogs/native45/catalog.json');
const splitFile=path.join(path.dirname(fileURLToPath(import.meta.url)),'cases.json');
const catalog=read(catalogFile),split=read(splitFile),catalogPin=pin(catalogFile);
need(split.catalog.bytes===catalogPin.bytes&&split.catalog.sha256===catalogPin.sha256,'Frozen native45 catalog changed');
const known=catalog.cases.map(c=>c.id),partition=[...split.development,...split.heldout];
need(known.length===45&&partition.length===45&&new Set(partition).size===45&&partition.every(id=>known.includes(id)),'Frozen development/heldout partition');
const selection=a.cases??'development';
const names=selection==='all'?known:selection==='development'?split.development:selection==='heldout'?split.heldout:selection.split(',');
need(names.length&&new Set(names).size===names.length&&names.every(id=>known.includes(id)),'Unique native45 cases required');
const out=path.resolve(a.out);
need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'Fresh guarded output required');
fs.mkdirSync(out,{recursive:true});
const authority=read(a.api),binding=read(a.binding);
const inputs=[pin(fileURLToPath(import.meta.url)),pin(process.execPath),pin(a.api),authority.source,authority.api,
  pin(a.binding),binding.base,binding.carrier,catalogPin,pin(splitFile),
  pin(path.join(workspace,'selfhost/tools/build/hosted.mjs'))];
const report={campaign:'phase191',kind:'phase190-checked-native-emission',version:1,complete:false,target,emit,inputs,
  selection,selected:names,development:split.development,heldout:split.heldout,rows:[],
  scope:'Checked Bend API performs source preparation and verified typed x86 emission. Object and diagnostic assembly consume the same typed sequence. Host serializes checked bytes only. No native-image, compiler-timing, source-language or promotion qualification.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');
const clock=()=>performance.now()/1000;
function bytes(result){
  need(result?.$==='X187ObjectResult'&&result.error==='',result?.error??'Malformed object result');
  const chunks=[];let xs=result.bytes,count=0,chunk=[];
  while(xs?.$==='Con'){
    need(++count<=64*1024*1024&&Number.isInteger(xs.head)&&xs.head>=0&&xs.head<=255,'Bounded emitted byte list');
    chunk.push(xs.head);if(chunk.length===65536){chunks.push(Buffer.from(chunk));chunk=[];}xs=xs.tail;
  }
  need(xs?.$==='Nil'&&count>0,'Complete nonempty emitted byte list');
  if(chunk.length)chunks.push(Buffer.from(chunk));return Buffer.concat(chunks,count);
}
save();
try{
  const exports=['p88_cache_prepare','p86_plan','p169np_plan','x181_prepared','x188_many','x188_render','x188_assemble'];
  need(authority.complete===true&&authority.checked===true&&authority.kind==='bend-checked-hosted-api'&&!authority.error&&!authority.changedInputs?.length,'Complete checked API required');
  need(exports.every(name=>authority.exports.includes(name)),'Required checked typed exports');
  const sourceManifest=pin(a['source-manifest']??path.join(path.dirname(authority.source.file),'manifest.json'));
  const preparation=read(sourceManifest.file);
  need(preparation.kind==='phase190-api-source'&&preparation.complete===true&&
    preparation.source.file===authority.source.file&&preparation.source.sha256===authority.source.sha256&&
    preparation.source.bytes===authority.source.bytes,'Exact Phase190 source preparation receipt required');
  report.sourcePreparation={receipt:sourceManifest,snapshot:preparation.snapshot,
    sourceConstantOverrides:preparation.sourceConstantOverrides,bridgedExportDeclarations:preparation.bridgedExportDeclarations};
  inputs.push(sourceManifest,preparation.snapshot,...authority.inputs);
  need(binding.kind==='phase175-prepared-base'&&typeof binding.stamp==='string'&&binding.stamp,'Prepared Base binding required');
  need(binding.engine.bytes===pin(process.execPath).bytes&&binding.engine.sha256===pin(process.execPath).sha256,'Bound JavaScript engine required');
  inputs.forEach(verify);
  const api=(await import(pathToFileURL(authority.api.file))).default;
  need(exports.every(name=>typeof api[name]==='function'),'Callable checked typed API');
  let t=clock();
  const prep=api.p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);
  need(prep?.$==='P86PreparationReady',prep?.error??'Base refused');report.baseSeconds=clock()-t;
  for(const id of names){
    const c=catalog.cases.find(c=>c.id===id);
    const source=pin(path.resolve(path.dirname(catalogFile),'../..',c.source.file));
    const expectedFile=pin(path.resolve(path.dirname(catalogFile),'../..',c.expectedFile.file));
    need(source.bytes===c.source.bytes&&source.sha256===c.source.sha256,'Native45 source identity: '+id);
    need(expectedFile.bytes===c.expectedFile.bytes&&expectedFile.sha256===c.expectedFile.sha256,'Native45 independent oracle identity: '+id);
    inputs.push(source,expectedFile);
    const dir=out+'/'+id;fs.mkdirSync(dir);
    const row={id,source,expectedFile,partition:split.development.includes(id)?'development':'heldout',complete:false};
    report.rows.push(row);save();t=clock();
    const plan=api.p86_plan(prep.seed,source.file,fs.readFileSync(source.file,'utf8'));
    need(plan?.$==='P86PlanReady',plan?.error??'Source refused');
    const prepared=api.p169np_plan(plan);
    need(prepared?.$==='P169Prepared'&&prepared.error==='',prepared?.error??'Verified preparation refused');
    row.prepareSeconds=clock()-t;t=clock();
    const output=api.x181_prepared(prepared);
    need(output?.$==='X181Output'&&output.error==='',output?.error??'Typed x86 selection refused');
    const sequence=api.x188_many(output.chunks);row.selectSeconds=clock()-t;t=clock();
    const text=api.x188_render(sequence);
    need(typeof text==='string'&&text.length>0&&Buffer.byteLength(text)<=128*1024*1024,'Bounded diagnostic assembly');
    fs.writeFileSync(dir+'/program.s',text);row.assembly=pin(dir+'/program.s');row.renderSeconds=clock()-t;
    if(emit==='object'){
      t=clock();const object=bytes(api.x188_assemble(sequence));
      fs.writeFileSync(dir+'/program.o',object);row.product=pin(dir+'/program.o');row.objectSeconds=clock()-t;
    }else row.product=row.assembly;
    row.sameTypedSequence=true;row.verified=true;row.complete=true;save();
  }
  inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));
