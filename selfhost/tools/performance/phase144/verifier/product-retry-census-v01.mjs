// Checked Bend produces all candidates, retries and verification decisions.
// This host observer only authenticates inputs and compares/retains products.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const ROOT=path.resolve(import.meta.dirname,'../../../../..');
const [apiArg,casesArg,outArg]=process.argv.slice(2);assert(apiArg&&casesArg&&outArg);
const out=path.resolve(outArg);assert(!fs.existsSync(out)&&out.startsWith(ROOT+'/selfhost/build/phase144/'));
const read=f=>JSON.parse(fs.readFileSync(f,'utf8'));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const inputs=new Map(),retain=p=>{assert.deepEqual(pin(p.file),p);const old=inputs.get(p.file);if(old)assert.deepEqual(old,p);inputs.set(p.file,p);return p};
const rec=read(apiArg),cases=read(casesArg),selectionFile=ROOT+'/implementation/phase143/candidate.json',selected=read(selectionFile);
const carrier=read(selected.preferredCarrierReceipt.file),base=carrier.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));assert(base);
assert(rec.complete&&rec.checked&&selected.nativeQualified&&carrier.complete&&cases.complete);
for(const name of ['p88_cache_prepare','p86_plan','p128raw_lower_request','p144pf_probe','p113e_verify'])assert(rec.exports.includes(name),name);
for(const f of [import.meta.filename,process.execPath,apiArg,casesArg,selectionFile,selected.preferredCarrierReceipt.file])retain(pin(f));
for(const p of [...rec.inputs,rec.api,...carrier.inputs,selected.preferredCarrier,base,...cases.inputs])retain(p);
const profileFile=ROOT+'/selfhost/build/phase144/profile01/attribution/report.json',profile=read(profileFile);retain(pin(profileFile));
assert(profile.pairing.verified&&profile.pairing.correct);
const weights=new Map();for(const row of profile.dispatchContexts){const n=row.loweredOwner;if(n)weights.set(n,(weights.get(n)||0)+row.samples)}
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const started=performance.now(),budgetSeconds=240;
const report={kind:'phase144-optional-product-retry-admission-census',complete:false,rows:[],budgetSeconds,
 scope:'Unchanged integrated source plus additive diagnostic. Complete original raw lowering equality, actual initial candidates, selective existing-lowering retries, original dependency admission and independent complete direct verifier. No machine execution or runtime gain claim.',
 limits:['A source result datatype is not an admission proof. Only actual new ready workers with a successful full verifier count as admissions.',
 'Profile sample weights refer to qualified Phase143 on a different full-compiler task; proxy-name matches are upper-ceiling leads, not measured saved time or dynamic call counts.',
 'No tail-SCC reconstruction on retries; otherwise useful mutual recursion can remain refused.',
 'Existing ready workers and their order are retained. Final production selection is unchanged.',
 'Hosted preparation and repeated diagnostic verification cost is not the native candidate overhead.']};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
const tag=(v,t)=>{assert.equal(v?.$,t,JSON.stringify({expected:t,actual:v?.$,error:v?.error}));return v};
const list=v=>{const xs=[];while(v?.$==='Con'){assert(xs.length<100000);xs.push(v.head);v=v.tail}tag(v,'Nil');return xs};
const time=f=>{assert((performance.now()-started)/1000<budgetSeconds,'Soft observer budget; external guard required');const s=performance.now(),value=f();return{value,seconds:(performance.now()-s)/1000}};
function exact(a,b){const todo=[[a,b]],seen=new WeakMap();let pairs=0;while(todo.length){const [x,y]=todo.pop();if(Object.is(x,y))continue;
 if(x===null||y===null||typeof x!=='object'||typeof y!=='object')return false;
 if(Array.isArray(x)!==Array.isArray(y))return false;let ys=seen.get(x);if(ys?.has(y))continue;if(!ys){ys=new WeakSet();seen.set(x,ys)}ys.add(y);
 assert(++pairs<=2000000);const kx=Object.keys(x).sort(),ky=Object.keys(y).sort();if(kx.length!==ky.length||kx.some((k,i)=>k!==ky[i]))return false;for(const k of kx)todo.push([x[k],y[k]])}return true}
function snapshot(value,target){const ids=new Map(),pending=[],nodes=[];const ref=x=>{if(x===null||typeof x!=='object'){assert(x===null||['boolean','number','string'].includes(typeof x));return{value:x}}
 if(!ids.has(x)){assert(ids.size<1000000);ids.set(x,ids.size);pending.push(x)}return{node:ids.get(x)}};const root=ref(value);
 for(let i=0;i<pending.length;i++){const x=pending[i];nodes.push({array:Array.isArray(x),fields:Object.keys(x).sort().map(k=>[k,ref(x[k])])})}
 const text=JSON.stringify({format:'phase144-complete-data-graph-v1',root,nodes})+'\n';assert(Buffer.byteLength(text)<80*1024*1024);fs.writeFileSync(target,text,{flag:'wx'});return{...pin(target),nodes:nodes.length}}
const owner=name=>name.replace(/^\$(direct|product)\./,'');
function rows(candidates,ready){return list(candidates).map(c=>{tag(c,'P113DCandidate');const f=tag(c.function,'P113DFunction'),calls=list(c.calls),missing=[...new Set(calls.filter(x=>!ready.has(x)))];
 return{name:f.name,owner:owner(f.name),error:c.error,calls,missing,ready:ready.has(f.name),product:f.name.startsWith('$product.'),
  onlyMissingProducts:c.error===''&&!ready.has(f.name)&&missing.length>0&&missing.every(x=>x.startsWith('$product.')),
  profileSamplesExactOwnerMatch:weights.get(owner(f.name))||0}})}
try{
 const api=(await import(pathToFileURL(rec.api.file))).default;
 const prep=time(()=>tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(selected.preferredCarrier.file,'utf8'),selected.preferredStamp),'P86PreparationReady'));
 report.basePreparationSeconds=prep.seconds;save();
 for(const fixture of cases.cases){retain(fixture.source);const row={name:fixture.name,source:fixture.source,seconds:{},complete:false};report.rows.push(row);save();
  const front=time(()=>tag(api.p86_plan(prep.value.seed,fixture.source.file,fs.readFileSync(fixture.source.file,'utf8')),'P86PlanReady'));row.seconds.frontend=front.seconds;
  const original=time(()=>tag(api.p128raw_lower_request(front.value.request),'P128RawLowering'));row.seconds.originalRaw=original.seconds;
  assert.equal(original.value.lowered.error,'');save();
  const probe=time(()=>tag(api.p144pf_probe(front.value.request),'P144PFTrace'));row.seconds.originalPlusRetryDiagnostic=probe.seconds;
  row.beforeEqualsIndependentOriginal=exact(original.value,probe.value.before);assert(row.beforeEqualsIndependentOriginal);
  const before=tag(probe.value.before.lowered,'P113DLowered'),after=tag(probe.value.after.lowered,'P113DLowered');assert.equal(before.error,'');assert.equal(after.error,'');
  const oldFns=list(before.program.functions),newFns=list(after.program.functions);
  assert(newFns.length>=oldFns.length);for(let i=0;i<oldFns.length;i++)assert(exact(oldFns[i],newFns[i]),'Existing worker or order changed');
  assert(exact(before.program.original,after.program.original),'Original static program changed');
  assert(exact(probe.value.before.raw,probe.value.after.raw),'Original observer retry reservoir changed');
  const oldReady=new Set(oldFns.map(x=>x.name)),newReady=new Set(newFns.map(x=>x.name));
  row.initial=rows(probe.value.before.raw,oldReady);row.attempts=rows(probe.value.attempts,newReady);row.withdrawn=list(probe.value.withdrawn);
  row.newReady=newFns.slice(oldFns.length).map(f=>({name:f.name,owner:owner(f.name),profileSamplesExactOwnerMatch:weights.get(owner(f.name))||0}));
  row.summary={initialCandidates:row.initial.length,initialReady:oldFns.length,withdrawnAliases:row.withdrawn.length,
   failedProductCandidates:row.initial.filter(x=>x.product&&!x.ready).length,
   consumersBlockedOnlyByProducts:row.initial.filter(x=>x.onlyMissingProducts).length,
   attempted:row.attempts.length,newReady:row.newReady.length};
  const oldCheck=time(()=>api.p113e_verify(before.program)),newCheck=time(()=>api.p113e_verify(after.program));
  row.seconds.beforeIndependentVerify=oldCheck.seconds;row.seconds.afterIndependentVerify=newCheck.seconds;
  assert.equal(oldCheck.value,'');row.finalError=newCheck.value;row.candidateVerified=newCheck.value==='';
  row.products=snapshot(probe.value,out+'/'+fixture.name+'-trace.graph.json');row.complete=true;save();
  console.log(JSON.stringify({name:row.name,summary:row.summary,newReady:row.newReady,verified:row.candidateVerified,error:row.finalError}));
 }
 for(const p of inputs.values())retain(p);report.complete=true;report.allCandidatesVerified=report.rows.every(r=>r.candidateVerified);
}catch(e){report.error=String(e.stack||e);process.exitCode=1}
finally{report.seconds=(performance.now()-started)/1000;report.peakHostedRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,allCandidatesVerified:report.allCandidatesVerified,error:report.error}))}
