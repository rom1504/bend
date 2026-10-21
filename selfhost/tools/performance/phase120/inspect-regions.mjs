// Inspect checked Bend decisions; this host script does not transform IR.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../..');
const [receipt,out,name]=process.argv.slice(2),read=f=>JSON.parse(fs.readFileSync(f));
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=x=>{const y=pin(x.file);if(y.sha256!==x.sha256||y.bytes!==x.bytes)throw Error('Changed '+x.file)};
const r=read(receipt),manifest=path.join(root,'selfhost/tools/performance/phase112/benchmark45/manifest01.json');
if(!r.complete||!r.checked||fs.existsSync(out))throw Error('Checked API and fresh output required');
const c=read(manifest).cases.find(c=>c.name===name);if(!c)throw Error('Unknown source');
const selection=path.join(root,'selfhost/tools/native/selection.json'),sel=read(selection);verify(sel.admission);
const {base,cache}=read(sel.admission.file).assets;
const inputs=[pin(import.meta.filename),pin(receipt),...r.inputs,r.api,pin(manifest),c.source,pin(selection),sel.admission,base,cache.carrier];inputs.forEach(verify);
const tag=(x,t)=>{if(x?.$!==t)throw Error('Expected '+t);return x},good=e=>{if(e!=='')throw Error(e)};
const list=x=>{const a=[];while(x?.$==='Con'){a.push(x.head);x=x.tail}tag(x,'Nil');return a};
const api=(await import(pathToFileURL(r.api.file))).default;
const prep=tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(cache.carrier.file,'utf8'),cache.stamp),'P86PreparationReady');
const request=tag(api.p86_plan(prep.seed,c.source.file,fs.readFileSync(c.source.file,'utf8')),'P86PlanReady').request;
const lowered=tag(api.p113a_lower_request(request),'P113ALowered');good(lowered.error);good(api.p113a_verify(lowered.program));
const functions=list(lowered.program.original.functions),rows=[];
for(const f of functions){
  const eligible=api.p120nr_eligible(f),calls=[];
  const walk=xs=>{for(const x of list(xs)){if(x.$==='P113DCall')calls.push(x.target);if(x.$==='P113DIf'){walk(x.yes);walk(x.no)}}};walk(f.body);
  rows.push({name:f.name,eligible:eligible===true||eligible?.$==='True',size:api.p113i_size(f.body),copyCost:api.p113j_cost(f),calls});
}
fs.mkdirSync(path.dirname(out),{recursive:true});fs.writeFileSync(out,JSON.stringify({complete:true,inputs,source:c.source,rows,scope:'Actual checked source-derived optimized private functions. Costs and legality are Bend exports; no host IR rewrite.'},null,2)+'\n');
console.log(JSON.stringify(rows.filter(x=>x.eligible||x.name.includes('nearest')),null,2));
