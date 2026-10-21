// Transport only: all source checking, planning, policy selection and QBE
// rendering run through checked Bend exports. No IR is synthesized or edited.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../..');
const [name,outArg]=process.argv.slice(2), out=path.resolve(outArg);
if (!out.startsWith(root+'/selfhost/build/phase115/') || fs.existsSync(out)) throw Error('Fresh phase115 output required');
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return {file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const verify=r=>{const a=pin(r.file);if(a.bytes!==r.bytes||a.sha256!==r.sha256)throw Error('Changed input '+r.file);};
const manifestFile=path.join(import.meta.dirname,'manifest01.json'), m=JSON.parse(fs.readFileSync(manifestFile));
const c=m.cases.find(c=>c.name===name);if(!c)throw Error('Case absent from frozen manifest');
for(const r of [m.api,m.apiReport,m.referenceApi,m.runtime,m.parent,c.source,c.expectedStdoutEvidence,...m.inputs])verify(r);
const selFile=path.join(root,'selfhost/tools/native/selection.json'), sel=JSON.parse(fs.readFileSync(selFile));verify(sel.admission);
const admission=JSON.parse(fs.readFileSync(sel.admission.file));if(!admission.complete||!admission.qualified)throw Error('Seed not qualified');
const {base,cache}=admission.assets;verify(base);verify(cache.carrier);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase115-policy-emission-replay',complete:false,name,partition:c.partition,stages:[],rows:[],products:{},inputs:[pin(import.meta.filename),pin(manifestFile),m.api,m.apiReport,m.referenceApi,m.runtime,m.parent,c.source,c.expectedStdoutEvidence,pin(selFile),sel.admission,base,cache.carrier,pin(process.execPath)],scope:'Checked hosted Bend optimizer on real source-derived IR. Common lowering/index/private rendering setup shared equally. No native compiler acquisition, policy quality or research-yield claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const memory=()=>({rss:process.memoryUsage().rss,heapUsed:process.memoryUsage().heapUsed});
const timed=(label,f)=>{const row={label,before:memory()},t=performance.now();try{return f();}finally{row.seconds=(performance.now()-t)/1000;row.after=memory();report.stages.push(row);save();}};
function text(chunks){const a=[];while(chunks?.$==='Con'){if(typeof chunks.head!=='string')throw Error('Non-string output');a.push(chunks.head+'\n');chunks=chunks.tail;}if(chunks?.$!=='Nil')throw Error('Bad chunk tail');return a.join('');}
function mustTag(x,tag){if(x?.$!==tag)throw Error('Expected '+tag+': '+JSON.stringify(x).slice(0,500));return x;}
function good(error){if(typeof error!=='string'||error)throw Error('Bend diagnostic: '+error);}
const started=performance.now();save();
try{
 const api=(await import(pathToFileURL(m.api.file))).default;
 const ref=(await import(pathToFileURL(m.referenceApi.file))).default;
 const seed=timed('base-preparation',()=>mustTag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(cache.carrier.file,'utf8'),cache.stamp),'P86PreparationReady'));
 const request=timed('source-frontend',()=>mustTag(api.p86_plan(seed.seed,c.source.file,fs.readFileSync(c.source.file,'utf8')),'P86PlanReady')).request;
 timed('runtime-admission',()=>good(api.p111_runtime_admission(request)));
 const lowered=timed('lowering',()=>mustTag(api.p113a_lower_request(request),'P113ALowered'));good(lowered.error);
 timed('independent-original-final-verifier',()=>good(ref.p113a_verify(lowered.program)));
 const reference=timed('original-emission',()=>text(ref.p113a_admitted_chunks(lowered.program)));
 report.reference={bytes:Buffer.byteLength(reference),sha256:crypto.createHash('sha256').update(reference).digest('hex')};
 const context=timed('common-emission-context',()=>api.p115_open(lowered.program));
 let prepared=timed('initial-alternatives',()=>api.p115_prepare(context));
 const counts={direct:0,alternatives:0,legalR:0,legalG:0,legalH:0,allRefused:0,policyRoutes:[{},{},{},{}]};
 for(let xs=prepared.menus;xs?.$==='Con';xs=xs.tail){const v=xs.head;if(v.$==='P115Direct'){counts.direct++;for(const r of counts.policyRoutes)r.direct=(r.direct||0)+1;}else{counts.alternatives++;const r=v.allow_r,g=v.allow_g,h=v.h.valid;if([r,g,h].some(x=>typeof x!=='boolean'))throw Error('Unexpected flag ABI');counts.legalR+=+r;counts.legalG+=+g;counts.legalH+=+h;counts.allRefused+=+(!r&&!g&&!h);for(let p=0;p<4;p++){const route=api.p115_route(p,r,g,h);counts.policyRoutes[p][route]=(counts.policyRoutes[p][route]||0)+1;}}}
 report.counts=counts;
 const expected={};
 for(let p=0;p<4;p++){
  const a=timed('warmup-legacy-'+p,()=>text(api.p115_legacy_chunks(context,p)));
  const b=timed('warmup-cached-'+p,()=>text(api.p115_cached_chunks(prepared,p)));
  if(a!==b)throw Error('Policy engines differ: '+p);
  if(p===0&&a!==reference)throw Error('Policy0 differs from unmodified API');
  expected[p]=a;const file=path.join(out,'policy'+p+'.ssa');fs.writeFileSync(file,a,{flag:'wx'});report.products[p]=pin(file);
 }
 report.warmupExact=true;save();
 for(let round=0;round<m.rounds;round++){
  let t=performance.now();prepared=api.p115_prepare(context);const prepSeconds=(performance.now()-t)/1000;
  report.rows.push({round,engine:'cached',kind:'preparation',seconds:prepSeconds});
  for(let k=0;k<4;k++){
   const policy=(k+round)%4;
   for(const engine of ((k+round)%2?['cached','legacy']:['legacy','cached'])){
    t=performance.now();const chunks=engine==='cached'?api.p115_cached_chunks(prepared,policy):api.p115_legacy_chunks(context,policy);const seconds=(performance.now()-t)/1000;
    t=performance.now();const actual=text(chunks);const outputSeconds=(performance.now()-t)/1000;
    if(actual!==expected[policy])throw Error('Repeated policy output changed');
    report.rows.push({round,engine,policy,kind:'emission',seconds,outputSeconds,outputExact:true,bytes:Buffer.byteLength(actual),sha256:report.products[policy].sha256});save();
   }
  }
 }
 for(const r of report.inputs)verify(r);report.complete=true;
}catch(e){report.error=String(e);process.exitCode=1;}
finally{report.totalSeconds=(performance.now()-started)/1000;report.memory=memory();save();console.log(JSON.stringify({name,complete:report.complete,error:report.error,seconds:report.totalSeconds,counts:report.counts}));}
