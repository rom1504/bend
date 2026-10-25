// Orchestration and independent byte/structure checks only. Checked Bend owns
// dependency admission, cache state and all annotation/lowering transformations.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const ROOT=path.resolve(import.meta.dirname,'../../../../..');
const [apiArg,outArg,...chosen]=process.argv.slice(2),out=path.resolve(outArg);
const families=chosen.length?chosen:['lexer','coverage-map-churn-128'];
assert(!fs.existsSync(out)&&out.startsWith(ROOT+'/selfhost/build/phase140/'));
const pin=p=>{p=path.resolve(p);const b=fs.readFileSync(p);return{file:p,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const digest=s=>({bytes:Buffer.byteLength(s),sha256:crypto.createHash('sha256').update(s).digest('hex')});
const verify=p=>assert.deepEqual(pin(p.file),p),read=p=>JSON.parse(fs.readFileSync(p));
const rec=read(apiArg),sel=read(ROOT+'/implementation/phase137/candidate.json'),refs=read(ROOT+'/selfhost/build/phase134/reference03.json');
assert(rec.complete&&rec.checked&&sel.nativeQualified&&refs.complete);rec.inputs.forEach(verify);verify(rec.api);
const carrier=read(sel.preferredCarrierReceipt.file),base=carrier.inputs.find(x=>x.file.endsWith('/bend2/base.bend'));assert(base);verify(base);verify(sel.preferredCarrier);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const report={kind:'phase140-initial-observer-screen',complete:false,inputs:[pin(import.meta.filename),pin(apiArg),rec.api,...rec.inputs,pin(ROOT+'/implementation/phase137/candidate.json'),pin(ROOT+'/selfhost/build/phase134/reference03.json'),base,sel.preferredCarrier],rows:[],scope:'Hosted checked Bend, actual fresh initial observer scan versus cold/warm reuse. Complete scan structures and final QBE are independently compared. Ordered exploratory scan times include dependency admission; acquisition, frontend, lowering, later retry and final verification are reported separately, not a native or whole-request speed claim.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
const tag=(x,t)=>{assert.equal(x?.$,t,JSON.stringify({expected:t,actual:x?.$,error:x?.error}));return x};
const timer=f=>{const t=performance.now(),value=f();return{value,seconds:(performance.now()-t)/1000}};
const list=xs=>{const r=[];for(let n=0;xs.$==='Con';n++){assert(n<100000);r.push(xs.head);xs=xs.tail;}tag(xs,'Nil');return r};
const equal=(a,b)=>assert.deepEqual(a,b);
try{
 const api=(await import(pathToFileURL(rec.api.file))).default;
 const seed=tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(sel.preferredCarrier.file,'utf8'),sel.preferredStamp),'P86PreparationReady').seed;
 const plan=(file,text)=>timer(()=>tag(api.p86_plan(seed,file,text),'P86PlanReady').request);
 const product=(request,raw,original,scan)=>{
  assert.equal(api.p111_runtime_admission(request),'');
  const result=tag(api.p134e_collect(api.p140lc_complete(request,raw,original,scan)),'P111Emission');
  assert.equal(result.error,'');return list(result.chunks).map(s=>s+'\n').join('');
 };
 const prepared=request=>{
  const raw=tag(api.p128raw_lower_request(request),'P128RawLowering');
  assert.equal(raw.lowered.error,'');
  const original=tag(api.p140lc_original(request,raw),'P113ALowered');
  assert.equal(original.error,'');return {raw:raw.raw,original:original.program};
 };
 for(const family of families){
  const c=refs.cases.find(x=>x.name===family);assert(c);verify(c.source);verify(c.expectedQbe);report.inputs.push(c.source,c.expectedQbe);
  const a=fs.readFileSync(c.source.file,'utf8');
  const edits={lexer:['U32.shln(x, 13n)','U32.shln(x, 12n)'],'coverage-map-churn-128':['U32.mul(i, 31)','U32.mul(i, 29)']};
  const [needle,replacement]=edits[family];assert.equal(a.split(needle).length,2);const b=a.replace(needle,replacement);
  fs.writeFileSync(out+'/'+family+'-b.bend',b);report.inputs.push(pin(out+'/'+family+'-b.bend'));
  const pa=plan(c.source.file,a),pb=plan(c.source.file,b);
  const qa=timer(()=>prepared(pa.value)),qb=timer(()=>prepared(pb.value));
  const fa=timer(()=>api.p140lc_fresh(pa.value,qa.value.original));
  const ca=timer(()=>tag(api.p140lc_cached(pa.value,qa.value.original,api.p140l_empty()),'P140LResult'));
  equal(ca.value.scan,fa.value);
  const fb=timer(()=>api.p140lc_fresh(pb.value,qb.value.original));
  const wb=timer(()=>tag(api.p140lc_cached(pb.value,qb.value.original,ca.value.cache),'P140LResult'));
  equal(wb.value.scan,fb.value);
  const na=timer(()=>tag(api.p140lc_cached(pa.value,qa.value.original,ca.value.cache),'P140LResult'));
  equal(na.value.scan,fa.value);
  const reverted=timer(()=>tag(api.p140lc_cached(pa.value,qa.value.original,wb.value.cache),'P140LResult'));
  equal(reverted.value.scan,fa.value);
  const af=timer(()=>product(pa.value,qa.value.raw,qa.value.original,fa.value));
  const bf=timer(()=>product(pb.value,qb.value.raw,qb.value.original,fb.value));
  const bw=timer(()=>product(pb.value,qb.value.raw,qb.value.original,wb.value.scan));
  assert.equal(af.value,fs.readFileSync(c.expectedQbe.file,'utf8'));assert.equal(bw.value,bf.value);assert.notEqual(af.value,bf.value);
  const nil={$:'Nil'};
  const failed=tag(api.p140lc_complete(pb.value,qb.value.raw,qb.value.original,{$:'P128BROpen',functions:nil,helpers:nil,retry:nil,error:'phase140-injected-scan-error'}),'P111Emission');
  assert.equal(failed.error,'borrowed profile: phase140-injected-scan-error');
  const recovery=tag(api.p140lc_cached(pb.value,qb.value.original,ca.value.cache),'P140LResult');
  equal(recovery.scan,fb.value);
  const wrapper=timer(()=>tag(api.p140le_verified(pb.value,qb.value.raw,qb.value.original,'',ca.value.cache),'P140LEmission'));
  const wrapped=tag(api.p134e_collect(wrapper.value.emission),'P111Emission');assert.equal(wrapped.error,'');
  assert.equal(list(wrapped.chunks).map(x=>x+'\n').join(''),bf.value);
  const wrapperError=tag(api.p140le_verified(pb.value,qb.value.raw,qb.value.original,'phase140-array-error',ca.value.cache),'P140LEmission');
  assert.equal(wrapperError.emission.error,'array structured IR: phase140-array-error');equal(wrapperError.cache,ca.value.cache);
  const row={family,edit:{needle,replacement},prepareASeconds:pa.seconds,prepareBSeconds:pb.seconds,
   freshOptimizerASeconds:qa.seconds,freshOptimizerBSeconds:qb.seconds,
   freshScanASeconds:fa.seconds,coldScanASeconds:ca.seconds,freshScanBSeconds:fb.seconds,warmScanBSeconds:wb.seconds,
   noOpScanSeconds:na.seconds,revertedScanSeconds:reverted.seconds,
   finishFreshASeconds:af.seconds,finishFreshBSeconds:bf.seconds,finishWarmBSeconds:bw.seconds,
   warmStats:list(wb.value.stats),noOpStats:list(na.value.stats),revertedStats:list(reverted.value.stats),scanSpeedup:fb.seconds/wb.seconds,
   exactScanCold:true,exactScanWarm:true,exactScanNoOp:true,exactScanReverted:true,exactCompleteB:true,unchangedAOracle:true,
   exactOptionalWrapper:true,wrapperErrorPriorCacheExact:true,wrapperSeconds:wrapper.seconds,
   injectedScanErrorExact:true,recoveryFromPriorSuccessExact:true,a:digest(af.value),b:digest(bf.value)};
  report.rows.push(row);save();console.log(JSON.stringify(row));
 }
 report.inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}finally{report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,error:report.error}));}
