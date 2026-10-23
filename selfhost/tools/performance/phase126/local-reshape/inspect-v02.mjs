// Host transport only: checked Bend owns preparation and all source admission.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../../..');
const [apiArg,sourceArg,outArg]=process.argv.slice(2);
assert(apiArg&&sourceArg&&outArg,'Usage: inspect.mjs CHECKED_API_REPORT COMPOSED_SOURCE_MANIFEST FRESH_PHASE126_OUT');
const read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
const pin=p=>{p=path.resolve(p);const b=fs.readFileSync(p);return{file:p,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=p=>{const actual=pin(p.file);assert.equal(actual.bytes,p.bytes,p.file);assert.equal(actual.sha256,p.sha256,p.file)};
const apiReceipt=read(apiArg),source=read(sourceArg),inventoryFile=path.join(import.meta.dirname,'inspect-manifest02.json'),inventory=read(inventoryFile);
assert(apiReceipt.complete&&apiReceipt.checked&&source.complete,'Checked API and complete source required');
assert(apiReceipt.inputs.some(p=>p.file===source.source.file&&p.sha256===source.source.sha256),'API/source identity');
assert(source.inputs.some(p=>p.sha256===inventory.recognizer.sha256&&p.bytes===inventory.recognizer.bytes),'Missing frozen recognizer');
const out=path.resolve(outArg);assert(out.startsWith(root+'/selfhost/build/phase126/')&&!fs.existsSync(out),'Fresh Phase126 output required');
const selectionFile=path.join(root,'selfhost/tools/native/selection.json'),selection=read(selectionFile);verify(selection.admission);
const admission=read(selection.admission.file);assert(admission.complete&&admission.qualified);
const {base,cache}=admission.assets;
const inputs=[pin(import.meta.filename),pin(process.execPath),pin(apiArg),pin(sourceArg),apiReceipt.api,source.source,...apiReceipt.inputs,...source.inputs,pin(inventoryFile),inventory.recognizer,...inventory.cases.map(x=>x.source),pin(selectionFile),selection.admission,base,cache.carrier];inputs.forEach(verify);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase126-local-reshape-checked-source-inspection',complete:false,targetsRun:false,inputs,cases:[],scope:'Read-only checked-source admission and original KDef transport. Expected admission is a hypothesis, not asserted or represented as a target result.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const bool=v=>{assert(typeof v==='boolean'||['True','False'].includes(v?.$));return typeof v==='boolean'?v:v.$==='True'};
const defs=xs=>{const out=[];while(xs?.$==='Con'){out.push(xs.head);xs=xs.tail}assert.equal(xs?.$,'Nil');return out};
const started=performance.now();
try{
 const api=(await import(pathToFileURL(apiReceipt.api.file))).default;
 for(const name of inventory.exports)assert.equal(typeof api[name],'function','Missing export '+name);
 const preparation=api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(cache.carrier.file,'utf8'),cache.stamp);assert.equal(preparation.$,'P86PreparationReady');
 for(const item of inventory.cases){
  const row={...item,complete:false,rows:[]};report.cases.push(row);save();
  const plan=api.p86_plan(preparation.seed,item.source.file,fs.readFileSync(item.source.file,'utf8'));assert.equal(plan.$,'P86PlanReady',JSON.stringify(plan));
  const definitions=defs(plan.request.book);
  for(const name of item.names){
   const definition=definitions.find(d=>d.name===name);assert(definition,'Missing checked definition '+name);
   const entry={name,admitted:bool(api.p126lr_inspect(plan.request,name)),equation:bool(api.p126lr_equation(definition)),types:bool(api.p126lr_types(plan.request.book,definition)),definition};row.rows.push(entry);save();
  }
  row.complete=true;save();console.log(JSON.stringify({name:item.name,rows:row.rows.map(({definition,...r})=>r)}));
 }
 inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error);process.exitCode=1}
finally{report.seconds=(performance.now()-started)/1000;report.peakRss=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,error:report.error}))}
