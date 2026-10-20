// Ordinary valid-source sequence: compare verification-reuse candidate with
// unchanged reference through existing checked lowering/verification APIs.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baselineArg,candidateArg,manifestArg,outArg]=process.argv.slice(2);
if(!baselineArg||!candidateArg||!manifestArg||!outArg||process.argv.length!==6)throw Error('Usage: BASELINE_API CANDIDATE_API MANIFEST FRESH_PHASE114_OUT');
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg),manifestFile=path.resolve(manifestArg);
if(!out.startsWith(root+'/selfhost/build/phase114/')||fs.existsSync(out))throw Error('Fresh Phase114 output required');
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return {file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const verify=p=>{const q=pin(path.resolve(root,p.file));if(q.bytes!==p.bytes||q.sha256!==p.sha256)throw Error('Changed '+p.file);return q;};
const manifest=JSON.parse(fs.readFileSync(manifestFile));for(const p of manifest.inputs)verify(p);
const cases=new Map(manifest.cases.map(c=>[c.name,c]));
const sources=manifest.sessionSequence.map(n=>{if(!cases.has(n))throw Error('Unknown case '+n);return cases.get(n);});
const selectionFile=path.join(root,'selfhost/tools/native/selection.json'),selection=JSON.parse(fs.readFileSync(selectionFile));verify(selection.admission);
const admission=JSON.parse(fs.readFileSync(selection.admission.file));if(!admission.complete||!admission.qualified)throw Error('Trusted assets not qualified');
const {base,cache}=admission.assets;verify(base);verify(cache.carrier);
const required=['p88_cache_prepare','p86_plan','p111_runtime_admission','p113a_lower_request','p113a_verify'];
const apis=[['baseline',baselineArg],['candidate',candidateArg]].map(([label,arg])=>{
 const file=path.resolve(arg),receiptFile=path.join(path.dirname(file),'report.json'),receipt=JSON.parse(fs.readFileSync(receiptFile));
 if(!receipt.complete||!receipt.checked||!required.every(n=>receipt.exports?.includes(n)))throw Error('Checked API exports incomplete');
 verify(receipt.api);if(path.resolve(receipt.api.file)!==file)throw Error('API receipt mismatch');
 const renderer=receipt.exports.includes('p113a_admitted_chunks')?'p113a_admitted_chunks':'p113a_chunks';
 if(!receipt.exports.includes(renderer))throw Error('Renderer missing');
 return {label,file,receiptFile,renderer};
});
fs.mkdirSync(out,{recursive:true});fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase114-ordinary-verification-session-source-sequence',complete:false,targetExecutions:false,
 inputs:[pin(import.meta.filename),pin(manifestFile),pin(selectionFile),selection.admission,base,cache.carrier,...apis.flatMap(a=>[pin(a.file),pin(a.receiptFile)])],
 sequence:manifest.sessionSequence,requests:[],comparisons:[],
 scope:'Positive typechecked source requests only. Normal lowering and final verification for every request. Compare exact QBE across isolated verification-reuse profiles and repeated A/B/A requests; no externally supplied session certificate. Does not execute generated programs or attribute speed to a changed codegen profile.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const digest=chunks=>{const hash=crypto.createHash('sha256');let bytes=0,count=0,c=chunks;for(;c?.$==='Con';c=c.tail){const b=Buffer.from(c.head+'\n');hash.update(b);bytes+=b.length;count++;}if(c?.$!=='Nil')throw Error('Bad chunks');return {bytes,chunks:count,sha256:hash.digest('hex')};};
const catalog=program=>{let p=program.original.original.program.constructors,result=[];for(;p?.$==='Con';p=p.tail)result.push([p.head.name,p.head.arity]);if(p?.$!=='Nil')throw Error('Bad constructor list');return result;};
try {
 for(const a of apis){
  const api=(await import(pathToFileURL(a.file))).default;
  const prepared=api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(cache.carrier.file,'utf8'),cache.stamp);
  if(prepared?.$!=='P86PreparationReady')throw Error('Preparation failed '+prepared?.error);
  for(let i=0;i<sources.length;i++){
   const c=sources[i],source=path.resolve(root,c.source),row={profile:a.label,index:i,name:c.name,source:pin(source),stages:[],complete:false};report.requests.push(row);save();
   const stage=(name,fn)=>{const t=performance.now();const value=fn();row.stages.push({name,seconds:(performance.now()-t)/1000});save();return value;};
   let plan=stage('frontend',()=>api.p86_plan(prepared.seed,source,fs.readFileSync(source,'utf8')));
   if(plan?.$!=='P86PlanReady')throw Error('Frontend '+c.name+': '+plan?.error);
   row.sourceChecked=true;
   const runtime=stage('runtime-admission',()=>api.p111_runtime_admission(plan.request));if(runtime!=='')throw Error(runtime);
   let lowered=stage('lowering',()=>api.p113a_lower_request(plan.request));plan=null;
   if(lowered?.$!=='P113ALowered'||lowered.error!=='')throw Error('Lowering '+c.name+': '+lowered?.error);
   row.catalogue=catalog(lowered.program);
   const diagnostic=stage('final-verification',()=>api.p113a_verify(lowered.program));if(diagnostic!=='')throw Error(diagnostic);
   row.finalVerified=true;row.renderer=a.renderer;
   const chunks=stage('emission',()=>api[a.renderer](lowered.program));lowered=null;
   row.qbe=digest(chunks);row.complete=true;save();console.log(JSON.stringify({profile:a.label,index:i,name:c.name,qbe:row.qbe}));
  }
 }
 for(const name of new Set(manifest.sessionSequence)){
  const matches=report.requests.filter(r=>r.name===name),first=matches[0];
  const same=matches.every(r=>r.complete&&r.qbe.bytes===first.qbe.bytes&&r.qbe.sha256===first.qbe.sha256&&JSON.stringify(r.catalogue)===JSON.stringify(first.catalogue));
  report.comparisons.push({name,requests:matches.map(r=>({profile:r.profile,index:r.index,qbe:r.qbe})),sameQbeAndCatalogue:same});
 }
 for(const p of report.inputs)verify(p);for(const r of report.requests)verify(r.source);
 report.complete=report.requests.every(r=>r.complete)&&report.comparisons.every(r=>r.sameQbeAndCatalogue);
}catch(error){report.error=String(error);throw error;}
finally{save();}
if(!report.complete)process.exitCode=1;
