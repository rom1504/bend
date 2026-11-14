// Transport one ordinary source request through an existing checked Bend API.
// Bend owns parsing, checking, lowering, typed x86 selection and ELF construction.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../tools/build/hosted.mjs';

const a={};
for(let i=2;i<process.argv.length;i+=2){
  const key=process.argv[i]?.slice(2),value=process.argv[i+1];
  need(['api','binding','source','out'].includes(key)&&value&&!Object.hasOwn(a,key),'Known unique --key value required');
  a[key]=value;
}
for(const key of ['api','binding','source','out'])need(a[key],'Required --'+key);
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const same=(x,y)=>x?.bytes===y?.bytes&&x?.sha256===y?.sha256;
const authority=read(a.api),binding=read(a.binding),fixture=read(a.source);
const out=path.resolve(a.out);
need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'Fresh guarded output required');
fs.mkdirSync(out,{recursive:true});
const report={kind:'phase193-compiler-hot-emission',complete:false,inputs:[],
  scope:'Existing checked API receives an ordinary separately extracted user source. '
       +'Compiler semantics remain Bend. No native execution or qualification inferred.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');
save();
try{
  need(authority.kind==='bend-checked-hosted-api'&&authority.complete&&authority.checked&&
    !authority.error&&!authority.changedInputs?.length,'Complete checked API required');
  need(same(authority.imageBinding?.image,authority.api)&&
    same(authority.imageBinding?.sourceIdentity,authority.source),'Bound API/source required');
  need(fixture.kind==='phase193-compiler-hot-source'&&fixture.complete&&fixture.overrides.length===0,
    'Exact extracted compiler-hot fixture required');
  need(binding.kind==='phase175-prepared-base'&&binding.stamp&&same(binding.engine,pin(process.execPath)),
    'Prepared Base and pinned engine required');
  const preparationFile=path.join(path.dirname(authority.source.file),'manifest.json');
  const preparation=read(preparationFile);
  need(preparation.complete&&same(preparation.source,authority.source)&&
    same(preparation.binding,pin(a.binding)),'Exact API preparation/Base binding required');
  const names=['p88_cache_prepare','p86_plan','p169np_plan','x181_prepared','x188_many','x188_render','x188_assemble'];
  need(names.every(n=>authority.exports.includes(n)),'Ordinary typed x86 exports required');
  report.inputs=[pin(fileURLToPath(import.meta.url)),pin(process.execPath),pin(a.api),pin(a.binding),
    pin(a.source),pin(preparationFile),authority.api,authority.source,binding.base,binding.carrier,
    fixture.source,fixture.expectedStdout,fixture.expectedValues,...fixture.inputs,...authority.inputs];
  report.inputs.forEach(verify);
  const api=(await import(pathToFileURL(authority.api.file))).default;
  need(names.every(n=>typeof api[n]==='function'),'Callable checked API required');
  const before=performance.now();
  const prep=api.p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),
    fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);
  need(prep?.$==='P86PreparationReady',prep?.error??'Base refused');
  const plan=api.p86_plan(prep.seed,fixture.source.file,fs.readFileSync(fixture.source.file,'utf8'));
  need(plan?.$==='P86PlanReady',plan?.error??'Ordinary source request refused');
  const prepared=api.p169np_plan(plan);
  need(prepared?.$==='P169Prepared'&&prepared.error==='',prepared?.error??'Preparation refused');
  const output=api.x181_prepared(prepared);
  need(output?.$==='X181Output'&&output.error==='',output?.error??'Typed selection refused');
  const sequence=api.x188_many(output.chunks),assembly=api.x188_render(sequence);
  need(typeof assembly==='string'&&assembly.length>0&&Buffer.byteLength(assembly)<32*1024*1024,'Bounded assembly');
  fs.writeFileSync(out+'/program.s',assembly,{flag:'wx'});
  const object=api.x188_assemble(sequence);
  need(object?.$==='X187ObjectResult'&&object.error==='',object?.error??'ELF refused');
  const chunks=[];let xs=object.bytes,count=0,chunk=[];
  while(xs?.$==='Con'){
    need(++count<16*1024*1024&&Number.isInteger(xs.head)&&xs.head>=0&&xs.head<=255,'Bounded byte list');
    chunk.push(xs.head);if(chunk.length===65536){chunks.push(Buffer.from(chunk));chunk=[];}xs=xs.tail;
  }
  need(xs?.$==='Nil'&&count>0,'Complete ELF byte list');
  if(chunk.length)chunks.push(Buffer.from(chunk));
  fs.writeFileSync(out+'/program.o',Buffer.concat(chunks,count),{flag:'wx'});
  report.seconds=(performance.now()-before)/1000;
  report.source=fixture.source;report.expectedStdout=fixture.expectedStdout;
  report.assembly=pin(out+'/program.s');report.object=pin(out+'/program.o');
  report.api=authority.api;report.compilerSource=authority.source;
  report.inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,seconds:report.seconds,error:report.error}));
