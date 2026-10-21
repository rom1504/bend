// Paired full emission of the same independently checked/verified original IR.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import{pathToFileURL}from'node:url';
const root=path.resolve(import.meta.dirname,'../../../..'),out=path.resolve(process.argv[2]);
if(fs.existsSync(out)||!out.startsWith(root+'/selfhost/build/phase115/'))throw Error('Fresh output required');
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const verify=r=>{const a=pin(r.file);if(a.bytes!==r.bytes||a.sha256!==r.sha256)throw Error('Changed '+r.file);};
const manifestFile=path.join(import.meta.dirname,'manifest02.json'),m=JSON.parse(fs.readFileSync(manifestFile));
const checkedFile=path.join(root,'selfhost/build/phase111/p115-negative-api01/report.json'),checked=JSON.parse(fs.readFileSync(checkedFile));
if(!checked.checked||!checked.complete)throw Error('Unchecked API');verify(checked.api);verify(m.referenceApi);
const compositionFile=path.join(root,'selfhost/build/phase115/negative-source01/manifest.json'),composition=JSON.parse(fs.readFileSync(compositionFile));
if(!checked.inputs.some(x=>x.file===composition.source.file&&x.sha256===composition.source.sha256))throw Error('Wrong candidate source');verify(composition.source);
for(const row of composition.inputs)verify(row);
const selectionFile=path.join(root,'selfhost/tools/native/selection.json'),selection=JSON.parse(fs.readFileSync(selectionFile));verify(selection.admission);
const admission=JSON.parse(fs.readFileSync(selection.admission.file));if(!admission.qualified||!admission.complete)throw Error('Seed not qualified');const{base,cache}=admission.assets;verify(base);verify(cache.carrier);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const r={kind:'phase115-negative-decision-full-emission',complete:false,inputs:[pin(import.meta.filename),pin(manifestFile),pin(checkedFile),checked.api,m.referenceApi,pin(compositionFile),composition.source,...composition.inputs,pin(selectionFile),selection.admission,base,cache.carrier,pin(process.execPath)],cases:[],scope:'One warmup then five paired full-emission rounds on identical verified IR. No new frontend/lowering decisions, native compiler acquisition or whole-request speed claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(r,null,2)+'\n');
const asText=chunks=>{const v=[];while(chunks?.$==='Con'){v.push(chunks.head+'\n');chunks=chunks.tail;}if(chunks?.$!=='Nil')throw Error('Invalid chunks');return v.join('');};
const good=x=>{if(typeof x!=='string'||x)throw Error('Diagnostic '+x);};
const original=(await import(pathToFileURL(m.referenceApi.file))).default,candidate=(await import(pathToFileURL(checked.api.file))).default;
const start=performance.now();save();
try{
 let t=performance.now();const prepared=original.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(cache.carrier.file,'utf8'),cache.stamp);if(prepared.$!=='P86PreparationReady')throw Error('Base error');r.baseSeconds=(performance.now()-t)/1000;
 for(const c of m.cases){
  verify(c.source);const evidence=path.join(root,'selfhost/build/phase115/matrix02',c.name,'report.json'),prior=JSON.parse(fs.readFileSync(evidence));if(!prior.complete)throw Error('Missing prior replay');verify(prior.products['0']);
  r.inputs.push(c.source,pin(evidence),prior.products['0']);const row={name:c.name,partition:c.partition,samples:[],warmup:[]};r.cases.push(row);save();
  t=performance.now();const plan=original.p86_plan(prepared.seed,c.source.file,fs.readFileSync(c.source.file,'utf8'));if(plan.$!=='P86PlanReady')throw Error('Source check failed');good(original.p111_runtime_admission(plan.request));
  const lowered=original.p113a_lower_request(plan.request);if(lowered.$!=='P113ALowered')throw Error('Lowering tag');good(lowered.error);good(original.p113a_verify(lowered.program));row.frontendLoweringVerifySeconds=(performance.now()-t)/1000;
  const expected=fs.readFileSync(prior.products['0'].file,'utf8');
  for(let round=-1;round<5;round++)for(const engine of (round%2?['original','candidate']:['candidate','original'])){
   const api=engine==='original'?original:candidate;t=performance.now();const chunks=api.p113a_admitted_chunks(lowered.program);const seconds=(performance.now()-t)/1000;
   const actual=asText(chunks);if(actual!==expected)throw Error('Changed complete QBE: '+c.name+' '+engine);
   (round<0?row.warmup:row.samples).push({round,engine,seconds,outputExact:true,sha256:prior.products['0'].sha256});save();
  }
  row.complete=true;save();console.log(JSON.stringify({name:c.name,complete:true}));
 }
 for(const row of r.inputs)verify(row);r.complete=true;
}catch(e){r.error=String(e);process.exitCode=1;}
finally{r.totalSeconds=(performance.now()-start)/1000;r.memory=process.memoryUsage();save();console.log(JSON.stringify({complete:r.complete,error:r.error,seconds:r.totalSeconds}));}
