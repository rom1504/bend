// Transport only: checked Bend replays preparation and reports its own facts.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../tools/build/hosted.mjs';
const a={};
for(let i=2;i<process.argv.length;i+=2){const k=process.argv[i]?.slice(2),v=process.argv[i+1];need(['api','binding','case','name','out'].includes(k)&&v&&!Object.hasOwn(a,k),'Unique known --key value required');a[k]=v;}
for(const k of ['api','binding','case','name','out'])need(a[k],'Required --'+k);
const read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
const authority=read(a.api),binding=read(a.binding);
const out=path.resolve(a.out);need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'Fresh guarded build output required');fs.mkdirSync(out,{recursive:true});
const catalogFile=path.join(workspace,'selfhost/tools/bench/catalogs/native45/catalog.json'),catalog=read(catalogFile),entry=catalog.cases.find(c=>c.id===a.case);need(entry,'Known native45 case required');
const source=pin(path.resolve(path.dirname(catalogFile),'../..',entry.source.file));need(source.bytes===entry.source.bytes&&source.sha256===entry.source.sha256,'Exact catalog source');
const inputs=[pin(fileURLToPath(import.meta.url)),pin(process.execPath),pin(a.api),pin(a.binding),pin(catalogFile),source,authority.source,authority.api,binding.base,binding.carrier,...authority.inputs];
const report={kind:'phase190-checked-placement-diagnostic',version:1,complete:false,inputs,case:a.case,targetName:a.name,scope:'Read-only checked Bend replay of private x86 array/late/memory preparation, branch facts and placement. No target execution or timing claim.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
try{
 need(authority.complete&&authority.checked&&!authority.error&&!authority.changedInputs?.length,'Complete checked API required');
 const exports=['p88_cache_prepare','p86_plan','p169np_plan','p190ld_probe'];need(exports.every(n=>authority.exports.includes(n)),'Checked diagnostic exports required');
 need(binding.kind==='phase175-prepared-base'&&binding.engine.bytes===pin(process.execPath).bytes&&binding.engine.sha256===pin(process.execPath).sha256,'Exact prepared Base engine');inputs.forEach(verify);
 const api=(await import(pathToFileURL(authority.api.file))).default;
 const prep=api.p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);need(prep?.$==='P86PreparationReady',prep?.error??'Base refused');
 const plan=api.p86_plan(prep.seed,source.file,fs.readFileSync(source.file,'utf8'));need(plan?.$==='P86PlanReady',plan?.error??'Source refused');
 const prepared=api.p169np_plan(plan);need(prepared?.$==='P169Prepared'&&prepared.error==='',prepared?.error??'Preparation refused');
 let xs=api.p190ld_probe(prepared,a.name),rows=[],bytes=0;
 while(xs?.$==='Con'){need(typeof xs.head==='string'&&rows.length<8192,'Bounded String rows');bytes+=Buffer.byteLength(xs.head);need(bytes<=4*1024*1024,'Bounded diagnostic bytes');rows.push(xs.head);xs=xs.tail;}
 need(xs?.$==='Nil'&&rows[0]==='function='+a.name,'Exact target found');report.rows=rows;fs.writeFileSync(out+'/facts.txt',rows.join('\n')+'\n');inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,rows:report.rows?.length,error:report.error}));
