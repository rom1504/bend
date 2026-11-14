// IO transport only. Checked Bend captures exact final allocation metadata.
// This driver never renders machine text, assembles, links or executes targets.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../../tools/build/hosted.mjs';

const own=fileURLToPath(import.meta.url),a={};
for(let i=2;i<process.argv.length;i+=2){
  const key=process.argv[i]?.slice(2),value=process.argv[i+1];
  need(process.argv[i]?.startsWith('--')&&['api','binding','source-manifest','out','cases'].includes(key)&&value,'Known --key value required');
  need(!Object.hasOwn(a,key),'Duplicate option '+key);a[key]=value;
}
for(const key of ['api','binding','out'])need(a[key],'Required --'+key);
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const same=(x,y)=>x?.bytes===y?.bytes&&x?.sha256===y?.sha256;
const catalogFile=path.join(workspace,'selfhost/tools/bench/catalogs/native45/catalog.json');
const splitFile=path.join(workspace,'selfhost/tests/phase194/cases.json');
const fixtureFile=path.join(path.dirname(own),'diagnostic.bend');
const catalog=read(catalogFile),split=read(splitFile),catalogPin=pin(catalogFile);
need(same(split.catalog,catalogPin),'Frozen native45 catalog changed');
const known=catalog.cases.map(c=>c.id),partition=[...split.development,...split.heldout];
need(known.length===45&&partition.length===45&&new Set(partition).size===45&&partition.every(id=>known.includes(id)),'Frozen development/heldout partition');
const selection=a.cases??'development';
const names=selection==='all'?known:selection==='development'?split.development:selection==='heldout'?split.heldout:selection.split(',');
need(names.length&&new Set(names).size===names.length&&names.every(id=>known.includes(id)),'Unique native45 cases required');
const out=path.resolve(a.out);
need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'Fresh guarded output required');
fs.mkdirSync(out,{recursive:true});
const authority=read(a.api),binding=read(a.binding),fixturePin=pin(fixtureFile),bindingPin=pin(a.binding);
const inputs=[pin(own),pin(process.execPath),pin(a.api),authority.source,authority.api,bindingPin,
  binding.base,binding.carrier,catalogPin,pin(splitFile),fixturePin,pin(path.join(workspace,'selfhost/tools/build/hosted.mjs'))];
const report={campaign:'phase195',kind:'phase195-checked-allocator-diagnostic',version:1,complete:false,
  inputs,selection,selected:names,development:split.development,heldout:split.heldout,rows:[],
  diagnosticOnly:true,executableOutput:false,
  scope:'Checked Bend prepares actual final ordinary/float placement, invokes unchanged allocation with diagnostic post-return route markers, and serializes P113 metadata plus homes. Float placement rows are not executable IR. No rendering, assembly, object generation, linking, target execution, timing claim or qualification.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');
const clock=()=>performance.now()/1000;
let totalBytes=0;
function extract(output){
  need(output?.$==='X181Output'&&output.error==='',output?.error??'Diagnostic x86 preparation refused');
  const chunks=[];let list=output.chunks;
  while(list?.$==='Con'){
    need(chunks.length<1000000,'Bounded typed chunk list');chunks.push(list.head);list=list.tail;
  }
  need(list?.$==='Nil','Complete typed chunk list');
  const pending=chunks.reverse(),functions=[],seen=new Set();let visited=0,ignored=0,payloadBytes=0;
  while(pending.length){
    need(++visited<=2000000,'Bounded typed diagnostic tree');
    const node=pending.pop();
    if(node?.$==='X188Empty')continue;
    if(node?.$==='X188Join'){pending.push(node.right,node.left);continue;}
    need(node?.$==='X188One'&&typeof node.item?.$==='string','Typed diagnostic sequence required');
    if(node.item.$!=='PError'){ignored++;continue;}
    const text=node.item.error;
    need(typeof text==='string','String diagnostic payload required');
    payloadBytes+=Buffer.byteLength(text);
    need(payloadBytes<=64*1024*1024,'Bounded per-case diagnostic JSON');
    const value=JSON.parse(text);
    need(value?.kind==='phase195-allocator-ir'&&value.version===1,'Unexpected typed PError; diagnostic marker required');
    need(typeof value.symbol==='string'&&value.symbol.length>0&&!seen.has(value.symbol),'Unique complete emitted symbol required');
    need(Array.isArray(value.params)&&value.params.every(x=>typeof x==='string')&&Array.isArray(value.setup)&&Array.isArray(value.body),'Complete preselection payload required');
    need(['ordinary','float'].includes(value.allocation?.path)&&['joint','legacy'].includes(value.allocation?.route),'Complete final allocation route required');
    seen.add(value.symbol);functions.push(value);
  }
  need(functions.length>0,'Diagnostic replacement produced no function payloads');
  return {functions,visited,ignored,payloadBytes};
}
save();
try{
  const exports=['p88_cache_prepare','p86_plan','p169np_plan','x181_prepared'];
  need(authority.complete===true&&authority.checked===true&&authority.kind==='bend-checked-hosted-api'&&!authority.error&&!authority.changedInputs?.length,'Complete checked API required');
  need(exports.every(name=>authority.exports.includes(name)),'Required checked diagnostic exports');
  const sourceManifest=pin(a['source-manifest']??path.join(path.dirname(authority.source.file),'manifest.json'));
  const preparation=read(sourceManifest.file);
  need(preparation.kind==='phase190-api-source'&&preparation.complete===true&&
    preparation.source.file===authority.source.file&&same(preparation.source,authority.source),'Exact source preparation receipt required');
  const replacementNames=['x190_allocate_legacy','x190_j_checked','x191_ordinary_facts','x194fv_place'];
  need(preparation.replacements?.length===replacementNames.length&&
    replacementNames.every(name=>preparation.replacements.filter(row=>row.name===name&&row.replacementSha256!==row.originalSha256).length===1),
    'Exact diagnostic boundary and post-return marker overrides required');
  need(preparation.inputs?.some(p=>p.file===fixturePin.file&&same(p,fixturePin)),'Exact diagnostic fixture bound in preparation receipt required');
  need(preparation.binding?.file===bindingPin.file&&same(preparation.binding,bindingPin),'Exact preparation-owned Base binding required');
  need(binding.kind==='phase175-prepared-base'&&typeof binding.stamp==='string'&&binding.stamp,'Prepared Base binding required');
  need(same(binding.engine,pin(process.execPath)),'Bound JavaScript engine required');
  report.sourcePreparation={receipt:sourceManifest,snapshot:preparation.snapshot,replacements:preparation.replacements,
    sourceConstantOverrides:preparation.sourceConstantOverrides,bridgedExportDeclarations:preparation.bridgedExportDeclarations};
  inputs.push(sourceManifest,preparation.snapshot,...authority.inputs);
  inputs.forEach(verify);
  const api=(await import(pathToFileURL(authority.api.file))).default;
  need(exports.every(name=>typeof api[name]==='function'),'Callable checked diagnostic API');
  let t=clock();
  const prep=api.p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);
  need(prep?.$==='P86PreparationReady',prep?.error??'Base refused');report.baseSeconds=clock()-t;
  for(const id of names){
    const c=catalog.cases.find(c=>c.id===id);
    const source=pin(path.resolve(path.dirname(catalogFile),'../..',c.source.file));
    const expectedFile=pin(path.resolve(path.dirname(catalogFile),'../..',c.expectedFile.file));
    need(same(source,c.source),'Native45 source identity: '+id);
    need(same(expectedFile,c.expectedFile),'Native45 independent oracle identity: '+id);
    inputs.push(source,expectedFile);const dir=path.join(out,id);fs.mkdirSync(dir);
    const row={id,source,expectedFile,partition:split.development.includes(id)?'development':'heldout',complete:false};
    report.rows.push(row);save();t=clock();
    const plan=api.p86_plan(prep.seed,source.file,fs.readFileSync(source.file,'utf8'));
    need(plan?.$==='P86PlanReady',plan?.error??'Source refused');
    const prepared=api.p169np_plan(plan);
    need(prepared?.$==='P169Prepared'&&prepared.error==='',prepared?.error??'Verified preparation refused');
    row.prepareSeconds=clock()-t;t=clock();
    const extracted=extract(api.x181_prepared(prepared));row.diagnosticSeconds=clock()-t;
    const text=JSON.stringify({kind:'phase195-allocator-case',version:1,id,functions:extracted.functions},null,2)+'\n';
    totalBytes+=Buffer.byteLength(text);need(totalBytes<=128*1024*1024,'Bounded whole-run diagnostic output');
    const file=path.join(dir,'preselection.json');fs.writeFileSync(file,text,{flag:'wx'});
    row.preselection=pin(file);row.functions=extracted.functions.length;row.typedNodes=extracted.visited;
    row.ignoredMachineItems=extracted.ignored;row.payloadBytes=extracted.payloadBytes;
    row.sourceVerified=true;row.oracleIdentityVerified=true;row.runtimeOracleExecuted=false;row.complete=true;save();
  }
  inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));
