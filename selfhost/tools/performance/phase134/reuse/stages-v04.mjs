// Supervision only: every compiler stage below is an existing checked Bend export.
// This does not implement an optimizer, bypass a verifier, or alter the compiler.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../../..');
const [receiptFile,referenceFile,outArg,roundsArg='2']=process.argv.slice(2),out=path.resolve(outArg),rounds=Number(roundsArg);
assert(Number.isInteger(rounds)&&rounds>=1&&rounds<=3);
assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase134/'));
const read=f=>JSON.parse(fs.readFileSync(f));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const digest=s=>({bytes:Buffer.byteLength(s),sha256:crypto.createHash('sha256').update(s).digest('hex')});
const inputs=new Map(),add=p=>{assert.deepEqual(pin(p.file),p);inputs.set(p.file,p);return p;},file=f=>add(pin(f));
const receipt=read(receiptFile),reference=read(referenceFile);
file(receiptFile);file(referenceFile);file(import.meta.filename);file(process.execPath);
assert(receipt.complete&&receipt.checked&&receipt.status===0&&reference.complete);
receipt.inputs.forEach(add);add(receipt.api);
// Reference-generation tools are historical provenance, not replayed inputs.
// Authenticate the immutable receipt and every source/product consumed below.
const selectedFile=path.join(root,'implementation/phase131/final/candidate.json'),selected=read(selectedFile);file(selectedFile);assert(selected.nativeQualified);assert.deepEqual(reference.source,selected.source);
const compact=read(selected.preferredCarrierReceipt.file);add(selected.preferredCarrierReceipt);compact.inputs.forEach(add);add(selected.preferredCarrier);
const base=compact.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));assert(base);add(base);
for(const c of reference.cases){add(c.source);add(c.expectedQbe);}
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase134-verified-function-reuse-diagnostic',complete:false,rounds,referenceCreatorProvenance:reference.inputs,source:receipt.inputs.find(p=>p.file.endsWith('/compiler.bend')),rows:[],
 scope:'Hosted paired diagnostic of existing commits and isolated exact-function verification reuse. The host only rewraps P114SLowered with the existing checked commit result and unchanged error field. Every complete product must match frozen qualified native QBE. Timings include actual work but are not native runtime shares or edit-cache speedups; host retention, JIT, collection and stage scheduling differ from native execution.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
const tag=(v,t)=>{assert.equal(v?.$,t,JSON.stringify({expected:t,actual:v?.$,error:v?.error}));return v;};
const nil={$:'Nil'};
const timed=(stages,name,fn)=>{const start=performance.now(),value=fn();stages[name]=(performance.now()-start)/1000;return value;};
const count=xs=>{let n=0;while(xs?.$==='Con'){n++;xs=xs.tail;}tag(xs,'Nil');return n;};
const started=performance.now();
try{
 const api=(await import(pathToFileURL(receipt.api.file))).default;
 const baseTiming={};const prep=tag(timed(baseTiming,'basePreparation',()=>api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(selected.preferredCarrier.file,'utf8'),selected.preferredStamp)),'P86PreparationReady');report.basePreparationSeconds=baseTiming.basePreparation;save();
 for(let round=0;round<rounds;round++)for(const c of (round%2?[...reference.cases].reverse():reference.cases)){
  const stages={},row={round,name:c.name,stages,expected:c.expectedQbe};report.rows.push(row);save();
  const text=fs.readFileSync(c.source.file,'utf8'),expected=fs.readFileSync(c.expectedQbe.file,'utf8'),begin=performance.now();
  const req=tag(timed(stages,'frontend',()=>api.p86_plan(prep.seed,c.source.file,text)),'P86PlanReady').request;tag(req,'NR_Request');
  assert.equal(timed(stages,'runtimeAdmission',()=>api.p111_runtime_admission(req)),'');
  assert.equal(timed(stages,'compileAdmission',()=>api.nc_compile_error_known(req.source,req.bound)),'');
  const ctors=timed(stages,'constructors',()=>api.nc_add_ctors(api.nc_default_ctors(),api.nc_constructors(req.source,req.source)));
  const prepared=tag(timed(stages,'staticPreparation',()=>api.p112s_prepare(req.book,req.names,ctors)),'P112SPrepared');assert.equal(prepared.error,'');
  const bangs1=timed(stages,'bangsGeneric',()=>api.nc_bangs_names(prepared.book,req.names));
  const generic=tag(timed(stages,'genericOwnerLowering',()=>api.p111_compile_defs(prepared.book,req.names,bangs1,0,nil)),'P111Book');assert.equal(generic.error,'');
  const original=tag(timed(stages,'genericProgramAssembly',()=>api.p112s_finish(prepared.nodes,api.p111_finish(req.source,req.names,generic))),'P112SResult');assert.equal(original.error,'');
  const bangs2=timed(stages,'bangsPrivate',()=>api.nc_bangs_names(prepared.book,req.names));
  const signatures=timed(stages,'privateSignatures',()=>api.book_cached(api.nq_signatures(prepared.book,req.names),0));
  const raw=timed(stages,'privateCandidatePreparation',()=>api.p113pl_candidates(prepared.book,req.names,bangs2,signatures));
  const session=tag(timed(stages,'privateCandidateClosure',()=>api.p128raw_plan_finish(original,raw)),'P128RawLowering');
  const certificate=timed(stages,'arrayCertificate',()=>api.p113a_certificate(req));
  const opened=timed(stages,'privateOpenVerify',()=>api.p114s_open_lowered(session.lowered));
  assert.equal(opened.boundary.valid,true);
  const inlineCandidate=timed(stages,'privateInlineTransform',()=>api.p113i_functions(opened.boundary.functions,{$:'P113IEmpty'},nil));
  let inlineBaseline,inlineBoundary;
  if(round%2){inlineBoundary=timed(stages,'privateInlineReuse',()=>api.p134v_commit(opened.boundary,inlineCandidate));inlineBaseline=timed(stages,'privateInlineCommit',()=>api.p114s_commit(opened.boundary,inlineCandidate));}
  else{inlineBaseline=timed(stages,'privateInlineCommit',()=>api.p114s_commit(opened.boundary,inlineCandidate));inlineBoundary=timed(stages,'privateInlineReuse',()=>api.p134v_commit(opened.boundary,inlineCandidate));}
  assert.equal(api.p134v_boundary_same(inlineBaseline,inlineBoundary),true);
  const inlined={$:'P114SLowered',boundary:inlineBoundary,error:opened.error};
  const rangeCandidate=timed(stages,'privateRangeTransform',()=>api.p113k_functions(inlined.boundary.functions));
  let rangeBaseline,rangeBoundary;
  if(round%2){rangeBoundary=timed(stages,'privateRangeReuse',()=>api.p134v_commit(inlined.boundary,rangeCandidate));rangeBaseline=timed(stages,'privateRangeCommit',()=>api.p114s_commit(inlined.boundary,rangeCandidate));}
  else{rangeBaseline=timed(stages,'privateRangeCommit',()=>api.p114s_commit(inlined.boundary,rangeCandidate));rangeBoundary=timed(stages,'privateRangeReuse',()=>api.p134v_commit(inlined.boundary,rangeCandidate));}
  assert.equal(api.p134v_boundary_same(rangeBaseline,rangeBoundary),true);
  const ranged={$:'P114SLowered',boundary:rangeBoundary,error:inlined.error};
  const closed=timed(stages,'privateClose',()=>api.p114s_close_lowered(ranged));
  const assembled=tag(timed(stages,'arrayAssembly',()=>api.p113a_finish(certificate,closed)),'P113ALowered');assert.equal(assembled.error,'');
  assert.equal(timed(stages,'arrayFinalVerify',()=>api.p113a_verify(assembled.program)),'');
  const final=tag(timed(stages,'borrowAndFinalClosure',()=>api.p128raw_prepare(req,raw,assembled.program)),'P134Planned');
  let cursor=timed(stages,'renderContext',()=>api.p134e_begin(final.plan));
  const pieces=[];let countPieces=0,countEnds=0;
  timed(stages,'renderPieces',()=>{while(true){const step=api.p134e_next(cursor);if(step.$==='P134Done')break;tag(step,'P134Piece');assert.equal(typeof step.text,'string');pieces.push(step.text);countPieces++;if(step.legacy_end){pieces.push('\n');countEnds++;}cursor=step.next;}});
  const output=timed(stages,'hostOutputJoin',()=>pieces.join(''));
  row.completeRequestSeconds=(performance.now()-begin)/1000;row.stageSumSeconds=Object.values(stages).reduce((a,b)=>a+b,0);
  assert.equal(output,expected);row.actual=digest(output);row.exactNativeReference=true;
  row.structure={owners:count(req.names),staticNodes:count(prepared.nodes),genericSegments:count(generic.segments),rawCandidates:count(raw),pieces:countPieces,legacyEnds:countEnds};
  row.backendSeconds=row.stageSumSeconds-stages.frontend-stages.hostOutputJoin;
  row.commitComparison={baselineSeconds:stages.privateInlineCommit+stages.privateRangeCommit,reuseSeconds:stages.privateInlineReuse+stages.privateRangeReuse,inlineCounts:api.p134v_count(opened.boundary.functions,inlineCandidate,0,0),rangeCounts:api.p134v_count(inlined.boundary.functions,rangeCandidate,0,0),scope:'Paired existing commit versus unchanged-function reuse only. Complete elapsed includes both plus audit equality; not an end-to-end compiler speedup.'};row.complete=true;save();console.log(JSON.stringify(row));
 }
 for(const p of inputs.values())add(p);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}finally{report.seconds=(performance.now()-started)/1000;report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,seconds:report.seconds,error:report.error}));}
