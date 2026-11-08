// Transport checked Bend APIs and invoke machine tools. No host-side lowering.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import {pin,verify,requireThat as need,workspace} from '../../tools/build/hosted.mjs';
const a={};for(let i=2;i<process.argv.length;i+=2){need(process.argv[i]?.startsWith('--')&&process.argv[i+1],'--key value required');a[process.argv[i].slice(2)]=process.argv[i+1];}
const out=path.resolve(a.out);need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'fresh output required');fs.mkdirSync(out,{recursive:true});
const binding=JSON.parse(fs.readFileSync(a.binding)),assetsFile=path.join(workspace,'selfhost/manifests/assets-native.json'),assets=JSON.parse(fs.readFileSync(assetsFile));
const source=pin(a.source),expected=a.expected?pin(a.expected):null;
const inputs=[pin(fileURLToPath(import.meta.url)),pin(process.execPath),pin(a.binding),binding.base,binding.carrier,source,pin(assetsFile),...(expected?[expected]:[])];
const report={kind:'phase181-hosted-native-pair',complete:false,inputs,source,expected,roles:{},scope:'Already checked Bend semantic API prepares once; separate checked Bend emitter consumes its actual verified cursor. Host writes text and runs tools only. Shared preparation is charged separately; these are not independent cold native compiler builds. Historical API authenticated by exact receipt/source/image, not mutable acquisition recipes.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
const clock=()=>performance.now()/1000;
function tool(name){const r=assets.assets[name],p=pin(path.resolve(workspace,r.file));need(p.bytes===r.bytes&&p.sha256===r.sha256,'asset mismatch '+name);inputs.push(p);return p.file;}
async function api(file){const r=JSON.parse(fs.readFileSync(file));need(r.complete&&r.checked&&r.kind==='bend-checked-hosted-api','checked API required');verify(r.source);verify(r.api);inputs.push(pin(file),r.source,r.api);return(await import(pathToFileURL(r.api.file))).default;}
function strings(list){const xs=[];let n=0;while(list?.$==='Con'){need(typeof list.head==='string'&&++n<=10000000,'bounded string list');xs.push(list.head);list=list.tail;}need(list?.$==='Nil','proper list');return xs;}
function run(role,label,command){const dir=out+'/'+role;const t=clock(),r=spawnSync(command[0],command.slice(1),{cwd:workspace,encoding:null,timeout:45000,maxBuffer:8*1024*1024,env:{...process.env,LD_PRELOAD:'',LD_AUDIT:''}});fs.writeFileSync(dir+'/'+label+'.stdout',r.stdout??'');fs.writeFileSync(dir+'/'+label+'.stderr',r.stderr??'');const row={label,command,seconds:clock()-t,status:r.status,signal:r.signal,error:r.error?String(r.error):null,stdout:pin(dir+'/'+label+'.stdout'),stderr:pin(dir+'/'+label+'.stderr')};report.roles[role].jobs.push(row);save();need(r.status===0,'machine stage failed '+role+'/'+label);need(['assemble','link'].includes(label)||row.stderr.bytes===0,'unexpected diagnostic '+role+'/'+label);return r.stdout;}
try{
 const baseline=await api(a.baseline),emitter=await api(a.emitter);
 const qbe=tool('qbe'),assembler=tool('assembler'),linker=tool('linker'),runtime=tool('qbe-runtime'),policy=assets.toolchains.qbe;
 inputs.forEach(verify);
 let t=clock();const p=baseline.p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);need(p.$==='P86PreparationReady',p.error??'Base refused');report.baseSeconds=clock()-t;
 t=clock();const plan=baseline.p86_plan(p.seed,source.file,fs.readFileSync(source.file,'utf8'));const prepared=baseline.p169np_plan(plan);need(prepared.$==='P169Prepared'&&prepared.error==='',prepared.error??'request refused');report.prepareSeconds=clock()-t;
 const inventory={private:0,public:0,legacy:0};let cursor=prepared.cursor;
 while(cursor&&['P134Private','P134Public','P134Legacy'].includes(cursor.$)){let l=cursor.functions??cursor.segments??cursor.entries,n=0;while(l?.$==='Con'){n++;l=l.tail;}inventory[cursor.$==='P134Private'?'private':cursor.$==='P134Public'?'public':'legacy']+=n;cursor=cursor.next;}report.inventory=inventory;save();
 let expectedOutput=expected?fs.readFileSync(expected.file):null;
 for(const role of (a.role??'both')==='both'?['qbe','x86']:[a.role]){
  need(['qbe','x86'].includes(role),'role');const dir=out+'/'+role;fs.mkdirSync(dir);const row=report.roles[role]={jobs:[]};t=clock();let text;
  if(role==='x86'){const result=emitter.x181_prepared(prepared);need(result.$==='X181Output'&&result.error==='',result.error??'x86 refused');text=strings(result.chunks).join('');}
  else{const parts=strings(prepared.forwarders).map(s=>s+'\n');let c=prepared.cursor,n=0;while(true){need(++n<1000000,'cursor bound');const step=baseline.p134e_next(c);if(step.$==='P134Done')break;need(step.$==='P134Piece','cursor shape');parts.push(step.text,step.legacy_end?'\n':'');c=step.next;}text=parts.join('');}
  row.emitSeconds=clock()-t;need(text.length>0&&Buffer.byteLength(text)<128*1024*1024,'bounded emission');const file=dir+(role==='qbe'?'/program.ssa':'/program.s');fs.writeFileSync(file,text);row.emitted=pin(file);save();
  if(role==='qbe')run(role,'qbe',[qbe,'-t',policy.target,'-o',dir+'/program.s',file]);
  run(role,'assemble',[assembler,...policy.assemblerFlags,'-o',dir+'/program.o',dir+'/program.s']);
  run(role,'link',[linker,...policy.linkerFlags,dir+'/program.o',runtime,...policy.libraries,'-o',dir+'/program']);row.binary=pin(dir+'/program');
  const got=run(role,'execute',[dir+'/program','--threads','1','--gpu','off']);if(expectedOutput===null)expectedOutput=got;need(got.equals(expectedOutput),'output mismatch '+role);row.outputExact=true;row.assembly=pin(dir+'/program.s');save();
 }
 inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,roles:Object.keys(report.roles),error:report.error}));
