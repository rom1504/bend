// Transport a checked Bend API; all checking, optimization and emission stay in Bend.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../tools/build/hosted.mjs';
const a={};for(let i=2;i<process.argv.length;i+=2){need(process.argv[i].startsWith('--')&&process.argv[i+1],'key/value');a[process.argv[i].slice(2)]=process.argv[i+1];}
const out=path.resolve(a.out);need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'fresh output');fs.mkdirSync(out,{recursive:true});
const read=p=>JSON.parse(fs.readFileSync(p));const authority=read(a.api),binding=read(a.binding);
const catalogFile=path.join(workspace,'selfhost/tools/bench/catalogs/native45/catalog.json'),catalog=read(catalogFile);
const names=a.cases==='all'?catalog.cases.map(c=>c.id):a.cases.split(',');need(new Set(names).size===names.length&&['qbe','x86'].includes(a.target),'cases/target');
const inputs=[pin(fileURLToPath(import.meta.url)),pin(process.execPath),pin(a.api),authority.source,authority.api,pin(a.binding),binding.base,binding.carrier,pin(catalogFile)];
const report={kind:'phase185-checked-native-emission',complete:false,target:a.target,inputs,rows:[],scope:'Checked Bend API performs source preparation and final verified native emission. Host transports bytes only; no native-image qualification claim.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
const clock=()=>performance.now()/1000;
function strings(xs){const r=[];while(xs?.$==='Con'){need(r.length<10000000&&typeof xs.head==='string','bounded chunks');r.push(xs.head);xs=xs.tail;}need(xs?.$==='Nil','proper chunks');return r;}
try{
 need(authority.complete&&authority.checked&&authority.kind==='bend-checked-hosted-api','checked API');inputs.forEach(verify);
 const api=(await import(pathToFileURL(authority.api.file))).default;let t=clock();
 const prep=api.p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);
 need(prep.$==='P86PreparationReady',prep.error??'base refused');report.baseSeconds=clock()-t;
 for(const id of names){
  const c=catalog.cases.find(c=>c.id===id);need(c,'unknown case '+id);
  const source=pin(path.resolve(path.dirname(catalogFile),'../..',c.source.file));
  need(source.bytes===c.source.bytes&&source.sha256===c.source.sha256,'source identity');inputs.push(source);
  const dir=out+'/'+id;fs.mkdirSync(dir);const row={id,source,complete:false};report.rows.push(row);save();t=clock();
  const plan=api.p86_plan(prep.seed,source.file,fs.readFileSync(source.file,'utf8'));need(plan.$==='P86PlanReady',plan.error??'source refused');
  const prepared=api.p169np_plan(plan);need(prepared.$==='P169Prepared'&&prepared.error==='',prepared.error??'verified native preparation refused');row.prepareSeconds=clock()-t;t=clock();let text;
  if(a.target==='x86'){const result=api.x181_prepared(prepared);need(result.$==='X181Output'&&result.error==='',result.error??'x86 refused');text=strings(result.chunks).join('');}
  else{const parts=strings(prepared.forwarders).map(s=>s+'\n');let cursor=prepared.cursor;for(let n=0;;n++){need(n<1000000,'cursor bound');const next=api.p134e_next(cursor);if(next.$==='P134Done')break;need(next.$==='P134Piece','cursor shape');parts.push(next.text,next.legacy_end?'\n':'');cursor=next.next;}text=parts.join('');}
  row.emitSeconds=clock()-t;need(text.length>0&&Buffer.byteLength(text)<128*1024*1024,'bounded product');const file=dir+(a.target==='x86'?'/program.s':'/program.ssa');fs.writeFileSync(file,text);row.product=pin(file);row.verified=true;row.complete=true;save();
 }
 inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack??e);process.exitCode=1;}save();console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));
