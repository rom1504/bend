// Inspect checked Bend admission and independently require emitted activation.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../..');
const [apiFile,emissionFile,checksFile,out]=process.argv.slice(2);
const read=f=>JSON.parse(fs.readFileSync(f));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return {file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=r=>{const s=pin(r.file);if(s.sha256!==r.sha256||s.bytes!==r.bytes)throw Error('Changed '+r.file)};
if(fs.existsSync(out))throw Error('Fresh output required');
const a=read(apiFile),e=read(emissionFile),checks=read(checksFile);
if(!a.checked||!a.complete||!e.complete)throw Error('Incomplete checked input');
const selectionFile=path.join(root,'selfhost/tools/native/selection.json'),sel=read(selectionFile);
verify(sel.admission);const {base,cache}=read(sel.admission.file).assets;
const inputs=[pin(import.meta.filename),pin(process.execPath),pin(apiFile),pin(emissionFile),pin(checksFile),pin(selectionFile),sel.admission,base,cache.carrier,...a.inputs,a.api,...e.inputs];
for(const x of inputs)verify(x);
const api=(await import(pathToFileURL(a.api.file))).default;
const prep=api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(cache.carrier.file,'utf8'),cache.stamp);
if(prep.$!=='P86PreparationReady')throw Error(prep.error);
const rows=[];
for(const item of checks){
  const source=e.cases.find(x=>x.name===item.case);if(!source)throw Error('Missing case');verify(source.source);verify(source.qbe);
  const plan=api.p86_plan(prep.seed,source.source.file,fs.readFileSync(source.source.file,'utf8'));
  if(plan.$!=='P86PlanReady')throw Error(plan.error);
  const result=item.kind==='list'?api.p121f_inspect(plan.request,item.name).$==='P121FPlan':api.p121c_inspect(plan.request,item.name).$==='True';
  const symbol='p113d_FID_'+[...('$p121.'+(item.kind==='list'?'stream.':'callback.')+item.name)].map(c=>c.codePointAt(0)+'_').join('');
  const emitted=fs.readFileSync(source.qbe.file,'utf8').includes('function l $'+symbol+'(');
  rows.push({...item,admitted:result,emitted});
  if(result!==item.expected||emitted!==item.expected)throw Error('Admission/activation mismatch '+JSON.stringify(rows.at(-1)));
}
for(const x of inputs)verify(x);
fs.writeFileSync(out,JSON.stringify({complete:true,inputs,rows},null,2)+'\n');
console.log(JSON.stringify({complete:true,checks:rows.length}));
