// Host transport only. Every compiler transformation remains checked Bend.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../..');
const [apiReportArg,sourceManifestArg,outArg,...names]=process.argv.slice(2);const out=path.resolve(outArg);
if(fs.existsSync(out)||!out.startsWith(root+'/selfhost/build/phase117/'))throw Error('Fresh Phase117 output required');
const read=p=>JSON.parse(fs.readFileSync(p));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=r=>{const x=pin(r.file);if(x.bytes!==r.bytes||x.sha256!==r.sha256)throw Error('Changed '+r.file)};
const apiReport=read(apiReportArg),sm=read(sourceManifestArg),parent=read(path.join(root,'implementation/phase114/selection.json')).nativeQualified;
if(!apiReport.complete||!apiReport.checked||!sm.complete||!apiReport.inputs.some(r=>r.file===sm.source.file&&r.sha256===sm.source.sha256))throw Error('Unchecked source');
const manifestFile=path.join(root,'selfhost/tools/performance/phase112/benchmark45/manifest01.json'),m=read(manifestFile);
const cases=names.map(n=>{const c=m.cases.find(c=>c.name===n);if(!c)throw Error('Unknown case '+n);return c});
const selFile=path.join(root,'selfhost/tools/native/selection.json'),sel=read(selFile);verify(sel.admission);const adm=read(sel.admission.file);if(!adm.complete||!adm.qualified)throw Error('Unqualified base');const{base,cache}=adm.assets;
const inputs=[pin(import.meta.filename),pin(apiReportArg),pin(sourceManifestArg),pin(manifestFile),apiReport.api,sm.source,parent.api,parent.runtime,pin(selFile),sel.admission,base,cache.carrier,pin(process.execPath),...sm.inputs];for(const r of inputs)verify(r);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase117-checked-overlay-emission',complete:false,inputs,cases:[],api:apiReport.api,source:sm.source,runtime:parent.runtime,scope:'Hosted checked Bend overlay, original admission and independent final verifier. No installed/native-image promotion.'};const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const good=e=>{if(typeof e!=='string'||e)throw Error('Bend diagnostic '+e)};const tag=(x,t)=>{if(x?.$!==t)throw Error('Expected '+t);return x};
const text=xs=>{const a=[];while(xs?.$==='Con'){if(typeof xs.head!=='string')throw Error('Invalid chunk');a.push(xs.head+'\n');xs=xs.tail}tag(xs,'Nil');return a.join('')};
const started=performance.now();
try{
 const api=(await import(pathToFileURL(apiReport.api.file))).default,ref=(await import(pathToFileURL(parent.api.file))).default;
 let t=performance.now();const prep=tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(cache.carrier.file,'utf8'),cache.stamp),'P86PreparationReady');report.prepareSeconds=(performance.now()-t)/1000;
 for(const c of cases){verify(c.source);verify(c.expectedStdoutEvidence);const row={name:c.name,source:c.source,stages:{}};report.cases.push(row);save();
  t=performance.now();const request=tag(api.p86_plan(prep.seed,c.source.file,fs.readFileSync(c.source.file,'utf8')),'P86PlanReady').request;row.stages.frontend=(performance.now()-t)/1000;
  t=performance.now();good(api.p111_runtime_admission(request));row.stages.admission=(performance.now()-t)/1000;
  t=performance.now();const lowered=tag(api.p113a_lower_request(request),'P113ALowered');good(lowered.error);row.stages.lower=(performance.now()-t)/1000;
  t=performance.now();good(ref.p113a_verify(lowered.program));good(api.p113a_verify(lowered.program));row.stages.verify=(performance.now()-t)/1000;
  row.certificate=lowered.program.certificate;
  t=performance.now();const output=text(api.p113a_admitted_chunks(lowered.program));row.stages.emit=(performance.now()-t)/1000;
  const file=path.join(out,c.name+'.ssa');fs.writeFileSync(file,output);row.qbe=pin(file);row.verified=true;report.inputs.push(c.source,c.expectedStdoutEvidence);save();console.log(JSON.stringify(row));
 }
 for(const r of report.inputs)verify(r);report.complete=true;
}catch(e){report.error=String(e);process.exitCode=1}finally{report.seconds=(performance.now()-started)/1000;report.peakRss=process.resourceUsage().maxRSS*1024;save()}
