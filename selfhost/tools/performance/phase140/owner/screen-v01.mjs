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
const report={kind:'phase140-owner-raw-product-screen',complete:false,inputs:[pin(import.meta.filename),pin(apiArg),rec.api,...rec.inputs,pin(ROOT+'/implementation/phase137/candidate.json'),pin(ROOT+'/selfhost/build/phase134/reference03.json'),base,sel.preferredCarrier],rows:[],scope:'Hosted checked Bend, actual fresh raw lowering versus cold/warm owner reuse. Original frontend and downstream optimizer/final verifier stay paid. Ordered exploratory stage times; not native, calibrated or full compiler performance.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
const tag=(x,t)=>{assert.equal(x?.$,t,JSON.stringify({expected:t,actual:x?.$,error:x?.error}));return x};
const timer=f=>{const t=performance.now(),value=f();return{value,seconds:(performance.now()-t)/1000}};
const list=xs=>{const r=[];for(let n=0;xs.$==='Con';n++){assert(n<100000);r.push(xs.head);xs=xs.tail;}tag(xs,'Nil');return r};
const equal=(a,b)=>assert.deepEqual(a,b);
try{
 const api=(await import(pathToFileURL(rec.api.file))).default;
 const seed=tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(sel.preferredCarrier.file,'utf8'),sel.preferredStamp),'P86PreparationReady').seed;
 const plan=(file,text)=>timer(()=>tag(api.p86_plan(seed,file,text),'P86PlanReady').request);
 const product=(request,lowering)=>{
  assert.equal(api.p111_runtime_admission(request),'');
  const result=tag(api.p134e_collect(api.p128raw_session_finish(request,api.p113a_certificate(request),lowering)),'P111Emission');
  assert.equal(result.error,'');return list(result.chunks).map(s=>s+'\n').join('');
 };
 for(const family of families){
  const c=refs.cases.find(x=>x.name===family);assert(c);verify(c.source);verify(c.expectedQbe);report.inputs.push(c.source,c.expectedQbe);
  const a=fs.readFileSync(c.source.file,'utf8');
  const edits={lexer:['U32.shln(x, 13n)','U32.shln(x, 12n)'],'coverage-map-churn-128':['U32.mul(i, 31)','U32.mul(i, 29)']};
  const [needle,replacement]=edits[family];assert.equal(a.split(needle).length,2);const b=a.replace(needle,replacement);
  fs.writeFileSync(out+'/'+family+'-b.bend',b);report.inputs.push(pin(out+'/'+family+'-b.bend'));
  const pa=plan(c.source.file,a),pb=plan(c.source.file,b);
  const fa=timer(()=>api.p128raw_lower_request(pa.value));
  const ca=timer(()=>tag(api.p140or_lower(pa.value,api.p140or_empty()),'P140ORResult'));
  equal(ca.value.lowering,fa.value);
  const fb=timer(()=>api.p128raw_lower_request(pb.value));
  const wb=timer(()=>tag(api.p140or_lower(pb.value,ca.value.cache),'P140ORResult'));
  equal(wb.value.lowering,fb.value);
  const na=timer(()=>tag(api.p140or_lower(pa.value,ca.value.cache),'P140ORResult'));
  equal(na.value.lowering,fa.value);
  const aText=product(pa.value,fa.value),bFresh=product(pb.value,fb.value),bWarm=product(pb.value,wb.value.lowering);
  assert.equal(aText,fs.readFileSync(c.expectedQbe.file,'utf8'));assert.equal(bWarm,bFresh);assert.notEqual(aText,bFresh);
  const row={family,edit:{needle,replacement},prepareASeconds:pa.seconds,prepareBSeconds:pb.seconds,
   freshRawASeconds:fa.seconds,coldRawASeconds:ca.seconds,freshRawBSeconds:fb.seconds,warmRawBSeconds:wb.seconds,noOpRawSeconds:na.seconds,
   warmStats:list(wb.value.stats),noOpStats:list(na.value.stats),rawSpeedup:fb.seconds/wb.seconds,
   exactRawCold:true,exactRawWarm:true,exactRawNoOp:true,exactCompleteB:true,unchangedAOracle:true,a:digest(aText),b:digest(bFresh)};
  report.rows.push(row);save();console.log(JSON.stringify(row));
 }
 report.inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}finally{report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,error:report.error}));}
