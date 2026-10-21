// Matched hosted whole-request cost. Compiler decisions remain in checked Bend.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import{pathToFileURL}from'node:url';
const root=path.resolve(import.meta.dirname,'../../../..');
const [emissionArg,outArg,...names]=process.argv.slice(2),out=path.resolve(outArg);
const read=p=>JSON.parse(fs.readFileSync(p));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=r=>{const p=pin(r.file);if(p.bytes!==r.bytes||p.sha256!==r.sha256)throw Error('Changed '+r.file)};
const tag=(x,t)=>{if(x?.$!==t)throw Error('Expected '+t);return x};const good=x=>{if(typeof x!=='string'||x)throw Error('Diagnostic '+x)};
const text=xs=>{const a=[];while(xs?.$==='Con'){a.push(xs.head+'\n');xs=xs.tail}tag(xs,'Nil');return a.join('')};
const e=read(emissionArg),parent=read(path.join(root,'implementation/phase114/selection.json')).nativeQualified;
if(!e.complete||fs.existsSync(out)||!out.startsWith(root+'/selfhost/build/phase117/'))throw Error('Need complete emission and fresh output');
const sel=read(path.join(root,'selfhost/tools/native/selection.json'));verify(sel.admission);const adm=read(sel.admission.file);if(!adm.complete||!adm.qualified)throw Error('Seed');const{base,cache}=adm.assets;
const manifest=path.join(root,'selfhost/tools/performance/phase112/benchmark45/manifest01.json'),m=read(manifest);
const r={complete:false,scope:'Checked hosted APIs, prepared-Base whole request; one warmup + three alternating rounds; no native B1/B2 or upstream compilation claim.',inputs:[pin(import.meta.filename),pin(emissionArg),...e.inputs,parent.api,parent.source,base,cache.carrier,pin(manifest)],prepare:[],rows:[]};for(const x of r.inputs)verify(x);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(r,null,2)+'\n');save();const start=performance.now();
try{
 const apis={baseline:(await import(pathToFileURL(parent.api.file))).default,candidate:(await import(pathToFileURL(e.api.file))).default},seeds={};
 for(const role of ['baseline','candidate']){const t=performance.now();seeds[role]=tag(apis[role].p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(cache.carrier.file,'utf8'),cache.stamp),'P86PreparationReady').seed;r.prepare.push({role,seconds:(performance.now()-t)/1000});}
 for(const name of names){const c=m.cases.find(c=>c.name===name),em=e.cases.find(c=>c.name===name);if(!c||!em)throw Error('Unknown case');verify(c.source);verify(em.qbe);const source=fs.readFileSync(c.source.file,'utf8'),hashes={};r.inputs.push(c.source,em.qbe);
  for(let round=-1;round<3;round++)for(const role of(round%2?['baseline','candidate']:['candidate','baseline'])){
   const api=apis[role],stages={},all=performance.now();let t=all;
   const request=tag(api.p86_plan(seeds[role],c.source.file,source),'P86PlanReady').request;stages.frontend=(performance.now()-t)/1000;t=performance.now();good(api.p111_runtime_admission(request));stages.admission=(performance.now()-t)/1000;t=performance.now();
   const lower=tag(api.p113a_lower_request(request),'P113ALowered');good(lower.error);stages.lower=(performance.now()-t)/1000;t=performance.now();good(api.p113a_verify(lower.program));stages.verify=(performance.now()-t)/1000;t=performance.now();
   const chunks=api.p113a_admitted_chunks(lower.program);stages.emit=(performance.now()-t)/1000;const seconds=(performance.now()-all)/1000;
   const output=text(chunks),hash=crypto.createHash('sha256').update(output).digest('hex');if(hashes[role]&&hashes[role]!==hash)throw Error('Unstable output');hashes[role]=hash;if(role==='candidate'&&hash!==em.qbe.sha256)throw Error('Candidate differs from independently verified/built emission');
   good(apis.baseline.p113a_verify(lower.program));r.rows.push({name,role,round,seconds,stages,sha256:hash,bytes:Buffer.byteLength(output),verified:true});save();
  }console.log(name,'complete');
 }for(const x of r.inputs)verify(x);r.complete=true;
}catch(err){r.error=String(err);process.exitCode=1}finally{r.seconds=(performance.now()-start)/1000;r.peakRss=process.resourceUsage().maxRSS*1024;save()}
