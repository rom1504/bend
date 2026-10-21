// Isolate analysis and its unchanged independent verifier on one prepared graph.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../..');
const [receipt,out,name]=process.argv.slice(2),read=f=>JSON.parse(fs.readFileSync(f));
if(!process.versions.bun||fs.existsSync(out))throw Error('Pinned Bun and fresh output required');
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=x=>{const y=pin(x.file);if(y.sha256!==x.sha256||y.bytes!==x.bytes)throw Error('Changed '+x.file)};
const r=read(receipt);if(!r.complete||!r.checked)throw Error('Checked API required');
const mf=path.join(root,'selfhost/tools/performance/phase112/benchmark45/manifest01.json'),c=read(mf).cases.find(x=>x.name===name);if(!c)throw Error('Unknown source');
const sf=path.join(root,'selfhost/tools/native/selection.json'),sel=read(sf);verify(sel.admission);const {base,cache}=read(sel.admission.file).assets;
const inputs=[pin(import.meta.filename),pin(process.execPath),pin(receipt),r.api,...r.inputs,pin(mf),c.source,pin(sf),sel.admission,base,cache.carrier];inputs.forEach(verify);
const tag=(x,t)=>{if(x?.$!==t)throw Error('Expected '+t);return x},good=e=>{if(e!=='')throw Error(e)},yes=x=>x===true||x?.$==='True';
const api=(await import(pathToFileURL(r.api.file))).default;
const start=performance.now();
const prep=tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(cache.carrier.file,'utf8'),cache.stamp),'P86PreparationReady');
const request=tag(api.p86_plan(prep.seed,c.source.file,fs.readFileSync(c.source.file,'utf8')),'P86PlanReady').request;good(api.p111_runtime_admission(request));
const raw=tag(api.p113pl_lower_request(request),'P113DLowered');good(raw.error);
const opened=api.p114s_open_lowered(raw),inlined=api.p114s_inline_lowered(opened);good(inlined.error);if(!yes(inlined.boundary.valid))throw Error('Invalid original');
let t=performance.now();const ranges=api.p113k_functions(inlined.boundary.functions);const rangesSeconds=(performance.now()-t)/1000;
t=performance.now();const boundary=api.p114s_commit(inlined.boundary,ranges),rangeCommitSeconds=(performance.now()-t)/1000;
if(!yes(boundary.valid)||JSON.stringify(boundary.functions)!==JSON.stringify(ranges))throw Error('Range fallback');
const result={complete:false,inputs,name,preparationSeconds:(performance.now()-start)/1000,rangesSeconds,rangeCommitSeconds,rows:[],scope:'Hosted diagnostic of a fixed prepared checked graph. One warmup/three measurements. Verification unchanged; serialization/equality assertion outside timed intervals. Not whole compilation, native compiler timing, or research-loop speedup.'};
fs.mkdirSync(path.dirname(out),{recursive:true});const save=()=>fs.writeFileSync(out,JSON.stringify(result,null,2)+'\n');save();
try{
  for(let round=-1;round<3;round++){
    t=performance.now();const functions=api.p120w_functions(boundary.functions,{$:'Nil'}),analysisSeconds=(performance.now()-t)/1000;
    t=performance.now();const committed=api.p114s_commit(boundary,functions),verifySeconds=(performance.now()-t)/1000;
    if(!yes(committed.valid)||JSON.stringify(committed.functions)!==JSON.stringify(functions))throw Error('Word fallback');
    result.rows.push({round,warmup:round<0,analysisSeconds,verifySeconds,accepted:true});save();
  }
  result.complete=true;
}finally{result.seconds=(performance.now()-start)/1000;save();console.log(JSON.stringify(result.rows))}
