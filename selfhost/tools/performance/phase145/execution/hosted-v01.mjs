// Observer only: all compilation is the existing checked Bend API.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const input=JSON.parse(fs.readFileSync(process.argv[2],'utf8'));
const report={kind:'phase145-hosted-observation',complete:false,timings:{},pieces:0,bytes:0,utf16Units:0,legacyEnds:0};
let phase='import',fd;
const counters={},seen=new Map();
globalThis.__p145hit=(name,value,kind='entry')=>{
 const row=(counters[phase]??={})[name]??=((counters[phase])[name]={});
 row[kind]=(row[kind]||0)+1;
 if(kind==='entry' && typeof value==='string')row.firstArgumentUTF16Units=(row.firstArgumentUTF16Units||0)+value.length;
 if(kind==='term' && value && typeof value==='object'){
  const key=phase+':'+name;let set=seen.get(key);if(!set)seen.set(key,set=new WeakSet());
  const field=set.has(value)?'revisitedObject':'firstObject';row[field]=(row[field]||0)+1;set.add(value);
 }
};
const now=()=>performance.now()/1000,start=now();
const measure=(name,f)=>{const t=now(),v=f();report.timings[name]=(report.timings[name]||0)+now()-t;return v;};
const tag=(v,n)=>{assert.equal(v?.$,n,String(v?.error));return v;};
function write(buffer){let offset=0;while(offset<buffer.length){const n=fs.writeSync(fd,buffer,offset,buffer.length-offset);assert(n>0);offset+=n;}report.bytes+=buffer.length;assert(report.bytes<=64*1024*1024);}
try{
 const t=now(),api=(await import(pathToFileURL(input.api.file))).default;report.timings.importSeconds=now()-t;
 const texts=measure('inputReadSeconds',()=>({source:fs.readFileSync(input.source.file,'utf8'),base:fs.readFileSync(input.base.file,'utf8'),carrier:fs.readFileSync(input.carrier.file,'utf8')}));
 phase='base';const prepared=measure('basePreparationSeconds',()=>tag(api.p88_cache_prepare(input.base.file,texts.base,texts.carrier,input.stamp),'P86PreparationReady'));
 phase='frontend';const plan=measure('frontendSeconds',()=>tag(api.p86_plan(prepared.seed,input.source.file,texts.source),'P86PlanReady'));
 phase='backend';const emitted=measure('backendInclusiveSeconds',()=>tag(api.p134e_plan(plan),'P134Planned'));
 phase='registry';let cursor=measure('registrySeconds',()=>api.p134e_begin(emitted.plan));
 phase='render';fd=fs.openSync(input.output,'wx');const render=now();
 for(;;){
  const piece=measure('cursorSeconds',()=>api.p134e_next(cursor));
  if(piece.$==='P134Done')break;
  tag(piece,'P134Piece');assert.equal(typeof piece.text,'string');assert.equal(typeof piece.legacy_end,'boolean');
  assert(++report.pieces<=2000000);report.utf16Units+=piece.text.length;
  const buffer=measure('encodeSeconds',()=>Buffer.from(piece.text,'utf8'));
  measure('writeSeconds',()=>{write(buffer);if(piece.legacy_end){write(Buffer.from('\n'));report.legacyEnds++;}});
  cursor=piece.next;
 }
 fs.closeSync(fd);fd=undefined;report.timings.renderInclusiveSeconds=now()-render;
 report.complete=true;
}catch(error){report.error=String(error.stack||error);process.exitCode=1;}
finally{
 if(fd!==undefined)fs.closeSync(fd);
 report.observerSeconds=now()-start;report.peakRssBytes=process.resourceUsage().maxRSS*1024;
 report.instrumented=input.instrumented;report.counters=input.instrumented?counters:undefined;
 report.scope='Fresh process; ordinary prepared-Base request. Natural GC only. Timings include observer calls and output encoding/writes; output authentication happens in parent after process exit. Entry counters are not complete semantic or runtime-operation counts.';
 fs.writeFileSync(input.observation,JSON.stringify(report,null,2)+'\n');
}
