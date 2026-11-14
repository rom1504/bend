// IO only: checked source -> checked Bend diagnostic data. No target/emitter use.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../../../tools/build/hosted.mjs';
const own=fileURLToPath(import.meta.url),args={};
for(let i=2;i<process.argv.length;i+=2){
  const key=process.argv[i]?.slice(2),value=process.argv[i+1];
  need(['api','binding','out','source','owners'].includes(key)&&value&&!Object.hasOwn(args,key),'Known unique --key value');args[key]=value;
}
for(const key of ['api','binding','out','source','owners'])need(args[key],'Required --'+key);
const out=path.resolve(args.out);need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'Fresh guarded output');
fs.mkdirSync(out,{recursive:true});
const read=p=>JSON.parse(fs.readFileSync(p,'utf8')),authority=read(args.api),binding=read(args.binding);
const same=(x,y)=>x?.bytes===y?.bytes&&x?.sha256===y?.sha256;
const inputs=[pin(own),pin(process.execPath),pin(args.api),pin(args.binding),pin(args.source),authority.source,authority.api,binding.base,binding.carrier];
const report={kind:'phase195-owned-source-diagnostic',version:1,complete:false,diagnosticOnly:true,loweringAuthorized:false,
  inputs,owners:args.owners.split(','),rows:[],scope:'Source acceptance and finite structural ownership-plan data only. Original implementation remains unconditional fallback. No code generation, target execution or timing.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
try{
  need(fs.readFileSync('/proc/self/status','utf8').match(/^Cpus_allowed_list:\s*(.+)$/m)?.[1]==='3','Root-owned guarded CPU3 lane');
  need(authority.kind==='bend-checked-hosted-api'&&authority.complete&&authority.checked&&!authority.error&&!authority.changedInputs?.length,'Checked complete API');
  need(binding.kind==='phase175-prepared-base'&&same(binding.engine,pin(process.execPath)),'Exact prepared Base/engine');
  const manifest=path.join(path.dirname(authority.source.file),'manifest.json'),preparation=read(manifest);
  need(preparation.kind==='phase190-api-source'&&preparation.complete&&same(preparation.source,authority.source)&&same(preparation.binding,pin(args.binding)),'Exact preparation and Base binding');
  for(const file of ['layout.bend','evaluator.bend','proof.bend']){
    const item=pin(path.join(path.dirname(own),file));
    need(preparation.inputs.some(x=>same(x,item)&&x.file===item.file),'Exact diagnostic module '+file);inputs.push(item);
  }
  inputs.push(pin(manifest),preparation.snapshot,...authority.inputs);inputs.forEach(verify);
  const api=(await import(pathToFileURL(authority.api.file))).default;
  for(const name of ['p88_cache_prepare','p86_plan','p195od_checked'])need(authority.exports.includes(name)&&typeof api[name]==='function','Checked export '+name);
  const prepared=api.p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);
  need(prepared?.$==='P86PreparationReady',prepared?.error??'Base refused');
  const plan=api.p86_plan(prepared.seed,path.resolve(args.source),fs.readFileSync(args.source,'utf8'));
  need(plan?.$==='P86PlanReady',plan?.error??'Source refused');report.sourceAccepted=true;
  const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
  let result=api.p195od_checked(plan,list(report.owners));
  while(result?.$==='Con'){need(report.rows.length<1000&&typeof result.head==='string','Bounded diagnostic rows');report.rows.push(result.head);result=result.tail;}
  need(result?.$==='Nil','Complete diagnostic rows');
  const text=report.rows.join('\n')+'\n';need(Buffer.byteLength(text)<=8*1024*1024,'Bounded diagnostic output');
  const file=out+'/diagnostic.txt';fs.writeFileSync(file,text);report.diagnostic=pin(file);
  // A completed diagnostic may correctly refuse a plan; preserve every outcome.
  report.admitted=report.rows.filter(x=>x==='legality=1').length;
  report.refused=report.rows.filter(x=>x==='legality=0').length;
  inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,admitted:report.admitted,refused:report.refused,error:report.error}));
