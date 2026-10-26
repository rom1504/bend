// Observe actual selected compiler stages. No host optimizer, pass omission,
// production edit, cache or idempotence assumption is introduced here.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const ROOT=path.resolve(import.meta.dirname,'../../../../..');
const [apiArg,outArg,...names]=process.argv.slice(2);
assert(apiArg&&outArg,'API_REPORT FRESH_PHASE144_OUT [FROZEN_REFERENCE_NAMES...]');
const out=path.resolve(outArg);
assert(!fs.existsSync(out)&&out.startsWith(ROOT+'/selfhost/build/phase144/'));
const read=f=>JSON.parse(fs.readFileSync(f,'utf8'));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const inputs=new Map(),retain=p=>{assert.deepEqual(pin(p.file),p);const old=inputs.get(p.file);if(old)assert.deepEqual(old,p);inputs.set(p.file,p);return p};
const retainFile=f=>retain(pin(f));
const selectedFile=ROOT+'/implementation/phase143/candidate.json',selected=read(selectedFile);
const refsFile=ROOT+'/selfhost/build/phase134/reference03.json',refs=read(refsFile),rec=read(apiArg);
const carrier=read(selected.preferredCarrierReceipt.file);
const base=carrier.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));assert(base);
assert(rec.complete&&rec.checked&&refs.complete&&selected.nativeQualified&&carrier.complete);
const required=['p88_cache_prepare','p86_plan','p128raw_lower_request','p114s_open','p114s_inline',
 'p113k_functions','p134v_commit','p114s_close','p113e_verify'];
for(const name of required)assert(rec.exports.includes(name),'Missing checked export '+name);
for(const f of [import.meta.filename,process.execPath,apiArg,selectedFile,refsFile,selected.preferredCarrierReceipt.file])retainFile(f);
for(const p of [...rec.inputs,rec.api,...carrier.inputs,selected.preferredCarrier,base])retain(p);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const started=performance.now(),budgetSeconds=180;
const report={kind:'phase144-actual-second-range-pass-census',complete:false,diagnostic:true,budgetSeconds,rows:[],
 scope:'Checked Bend executes actual raw lowering, verified optimizer entry, existing inlining with its inner range calls, one outer range pass, unchanged commit, and independent full direct verifier. Host compares complete values and retains differences. No pass is skipped and no production behavior changes.',
 limitations:['Finite actual-workload observations cannot prove universal range-pass idempotence.',
 'First stage is the committed existing inline result. Some functions skip inner range analysis through the original size/cleanliness/stack gates; this census does not label every unchanged outer result an avoided second analysis.',
 'Hosted one-shot stage clocks are sensitive to JIT and GC; native benefit is unmeasured.',
 'Phase134 exact-input memo reuse was rejected on cost. This experiment introduces no memo and must not be interpreted as rerunning or validating that design.',
 'The independent direct verifier is executed unchanged; array/observer emission and complete QBE/native qualification are outside this bounded census.']};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
const budget=()=>assert((performance.now()-started)/1000<budgetSeconds,'Observer soft budget; external guard required');
const tag=(x,t)=>{assert.equal(x?.$,t,JSON.stringify({expected:t,actual:x?.$,error:x?.error}));return x};
const list=x=>{const xs=[];while(x?.$==='Con'){assert(xs.length<100000);xs.push(x.head);x=x.tail}tag(x,'Nil');return xs};
const timed=f=>{budget();const t=performance.now(),value=f();return{value,seconds:(performance.now()-t)/1000}};
function compare(a,b){
 const todo=[[a,b,'root']],seen=new WeakMap();let pairs=0;
 while(todo.length){const [x,y,at]=todo.pop();if(Object.is(x,y))continue;
  if(x===null||y===null||typeof x!=='object'||typeof y!=='object')return{equal:false,firstMismatch:at,left:x,right:y,pairs};
  if(Array.isArray(x)!==Array.isArray(y))return{equal:false,firstMismatch:at+'.array-kind',pairs};
  let ys=seen.get(x);if(ys?.has(y))continue;if(!ys){ys=new WeakSet();seen.set(x,ys)}ys.add(y);
  assert(++pairs<=2000000,'Comparison node bound');const kx=Object.keys(x).sort(),ky=Object.keys(y).sort();
  if(kx.length!==ky.length||kx.some((k,i)=>k!==ky[i]))return{equal:false,firstMismatch:at+'.keys',left:kx,right:ky,pairs};
  for(let i=kx.length-1;i>=0;i--){const k=kx[i];todo.push([x[k],y[k],at.length<240?at+'.'+k:k])}
 }return{equal:true,pairs};
}
function snapshot(value,target){
 const ids=new Map(),pending=[],nodes=[];
 const ref=x=>{if(x===null||typeof x!=='object'){assert(x===null||['boolean','number','string'].includes(typeof x));return{value:x}}
  if(!ids.has(x)){assert(ids.size<1000000,'Snapshot node bound');ids.set(x,ids.size);pending.push(x)}return{node:ids.get(x)}};
 const root=ref(value);
 for(let i=0;i<pending.length;i++){const x=pending[i];nodes.push({array:Array.isArray(x),fields:Object.keys(x).sort().map(k=>[k,ref(x[k])])})}
 const text=JSON.stringify({format:'phase144-complete-data-graph-v1',root,nodes})+'\n';
 assert(Buffer.byteLength(text)<=64*1024*1024,'Snapshot exceeds64MiB; retain partial report and tighten fixture');
 fs.writeFileSync(target,text,{flag:'wx'});return{...pin(target),nodes:nodes.length};
}
function census(fn){
 tag(fn,'P113DFunction');let direct=0,scalar=0,branches=0,calls=0;const todo=[...list(fn.body)];
 while(todo.length){const s=todo.pop();direct++;
  if(s.$==='P113DIf'){branches++;todo.push(...list(s.yes),...list(s.no))}
  if(s.$==='P113DCall')calls++;
  if(s.$==='P113DScalar'){const q=[s.scalar];while(q.length){const t=q.pop();scalar++;if(t.$==='N111If'){branches++;q.push(...list(t.yes),...list(t.no))}}}
 }return{directNodes:direct,scalarNodes:scalar,branches,calls};
}
try{
 // Exercise the host comparison on differences relevant to the actual IR.
 assert(compare({$:'N111Const',lo:1,hi:0},{$:'N111Const',lo:1,hi:0}).equal);
 assert(!compare({$:'N111Const',lo:1,hi:0},{$:'N111Const',lo:1,hi:1}).equal);
 assert(!compare({$:'N111Local',name:'x'},{$:'N111Symbol',name:'x'}).equal);
 const api=(await import(pathToFileURL(rec.api.file))).default;
 const preparation=timed(()=>tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(selected.preferredCarrier.file,'utf8'),selected.preferredStamp),'P86PreparationReady'));
 report.basePreparationSeconds=preparation.seconds;save();
 for(const name of names.length?names:['lexer','coverage-map-churn-128','coverage-closures-256']){
  const fixture=refs.cases.find(x=>x.name===name);assert(fixture,'Unknown frozen reference '+name);retain(fixture.source);retain(fixture.expectedQbe);
  const row={name,source:fixture.source,complete:false,seconds:{},functions:[],changed:[]};report.rows.push(row);save();
  const front=timed(()=>tag(api.p86_plan(preparation.value.seed,fixture.source.file,fs.readFileSync(fixture.source.file,'utf8')),'P86PlanReady'));
  row.seconds.frontend=front.seconds;save();
  const raw=timed(()=>tag(api.p128raw_lower_request(front.value.request),'P128RawLowering'));
  tag(raw.value.lowered,'P113DLowered');assert.equal(raw.value.lowered.error,'');row.seconds.raw=raw.seconds;save();
  const opened=timed(()=>tag(api.p114s_open(raw.value.lowered.program),'P114SBoundary'));
  assert.equal(opened.value.valid,true);row.seconds.openAndVerify=opened.seconds;save();
  const first=timed(()=>tag(api.p114s_inline(opened.value),'P114SBoundary'));
  assert.equal(first.value.valid,true);row.seconds.inlineWithInnerRangeAndCommit=first.seconds;save();
  // Optional diagnostic replay of the retained Phase134 instrumentation. It
  // records *actual first-pass inputs*, not an assumed range fixed point. This
  // expensive replay is a census only and is never charged as a proposed gain.
  let innerMemos=null;
  if(rec.exports.includes('p134rk_functions')){
   const memo=timed(()=>tag(api.p134rk_functions(opened.value.functions,{$:'P113IEmpty'},{$:'Nil'},{$:'Nil'}),'P134RKBatch'));
   innerMemos=list(memo.value.memos);assert.equal(innerMemos.length,list(first.value.functions).length);
   row.seconds.optionalInnerMemoReplay=memo.seconds;
   row.innerReplayCandidateEqualsCommittedInline=compare(memo.value.functions,first.value.functions).equal;
  }
  const outer=timed(()=>api.p113k_functions(first.value.functions));row.seconds.outerRange=outer.seconds;
  const before=list(first.value.functions),after=list(outer.value);assert.equal(before.length,after.length);
  const changed=[],unchanged=[];
  for(let i=0;i<before.length;i++){
   const a=tag(before[i],'P113DFunction'),b=tag(after[i],'P113DFunction');assert.equal(a.name,b.name);
   const equality=compare(a,b),item={index:i,name:a.name,equality,before:census(a),after:census(b)};
   if(innerMemos){const memo=innerMemos[i];
    if(memo.$==='P134RKMemo'){
     item.inner={executed:true,firstRangeUnchanged:compare(memo.input,memo.output).equal,
      outerInputEqualsExactInnerInput:compare(a,memo.input).equal,
      outerOutputEqualsRecordedInnerOutput:compare(b,memo.output).equal};
     if(item.inner.outerInputEqualsExactInnerInput)assert(item.inner.outerOutputEqualsRecordedInnerOutput,'Fixed-input deterministic range result differs');
    }else{tag(memo,'P134RKEmpty');item.inner={executed:false}}
   }
   row.functions.push(item);(equality.equal?unchanged:changed).push(i);
  }
  row.summary={functions:before.length,unchanged:unchanged.length,changed:changed.length,
   unchangedDirectNodes:unchanged.reduce((n,i)=>n+row.functions[i].before.directNodes,0),
   changedDirectNodes:changed.reduce((n,i)=>n+row.functions[i].before.directNodes,0)};
  if(innerMemos)row.summary.innerMemoCensus={executed:row.functions.filter(x=>x.inner.executed).length,
   firstRangeUnchanged:row.functions.filter(x=>x.inner.firstRangeUnchanged).length,
   exactRepeatInputs:row.functions.filter(x=>x.inner.outerInputEqualsExactInnerInput).length,
   exactRepeatDirectNodes:row.functions.filter(x=>x.inner.outerInputEqualsExactInnerInput).reduce((n,x)=>n+x.before.directNodes,0)};
  // Whole products and every difference remain reviewable without rerunning.
  row.completeProducts=snapshot({before:first.value.functions,after:outer.value},out+'/'+name+'-range-products.graph.json');
  row.changed=changed.map(i=>row.functions[i]);save();
  const commit=timed(()=>tag(api.p134v_commit(first.value,outer.value),'P114SBoundary'));
  assert.equal(commit.value.valid,true);row.seconds.outerCommit=commit.seconds;
  row.candidateAccepted=compare(commit.value.functions,outer.value).equal;
  row.commitRetainsOriginal=compare(commit.value.original,first.value.original).equal;
  row.commitRetainsIds=compare(commit.value.ids,first.value.ids).equal;
  assert(row.commitRetainsOriginal&&row.commitRetainsIds);
  const final=timed(()=>api.p113e_verify(api.p114s_close(commit.value)));
  assert.equal(final.value,'');row.seconds.independentFinalVerify=final.seconds;row.finalError=final.value;
  row.complete=true;save();console.log(JSON.stringify({name,summary:row.summary,seconds:row.seconds,candidateAccepted:row.candidateAccepted}));
 }
 for(const p of inputs.values())retain(p);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1}
finally{report.totalObservedSeconds=(performance.now()-started)/1000;report.peakHostedRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}))}
