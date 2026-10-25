// Checked Bend decides reuse; this adapter transports ordinal-addressed output
// bytes and compares them with the original fresh renderer. No source lowering.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const ROOT=path.resolve(import.meta.dirname,'../../../../..');
const [apiArg,outArg,...familiesArg]=process.argv.slice(2);
const out=path.resolve(outArg), families=familiesArg.length?familiesArg:['lexer','coverage-map-churn-128'];
assert(!fs.existsSync(out)&&out.startsWith(ROOT+'/selfhost/build/phase140/'));
const pin=p=>{p=path.resolve(p);const b=fs.readFileSync(p);return {file:p,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const digest=b=>({bytes:Buffer.byteLength(b),sha256:crypto.createHash('sha256').update(b).digest('hex')});
const verify=p=>assert.deepEqual(pin(p.file),p);
const read=p=>JSON.parse(fs.readFileSync(p));
const rec=read(apiArg), sel=read(ROOT+'/implementation/phase137/candidate.json'), refs=read(ROOT+'/selfhost/build/phase134/reference03.json');
assert(rec.checked&&rec.complete&&sel.nativeQualified&&refs.complete);rec.inputs.forEach(verify);verify(rec.api);
const carrier=read(sel.preferredCarrierReceipt.file),base=carrier.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));assert(base);verify(base);verify(sel.preferredCarrier);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const report={kind:'phase140-render-reuse-screen',complete:false,inputs:[pin(import.meta.filename),pin(apiArg),rec.api,...rec.inputs,pin(ROOT+'/implementation/phase137/candidate.json'),pin(ROOT+'/selfhost/build/phase134/reference03.json'),base,sel.preferredCarrier],rows:[],controls:[],scope:'Hosted checked Bend rendering only. Fresh frontend/lowering remain paid and are reported separately. Ordinal payload materialization is transport, not native qualification or full incremental rebuild timing.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
const tag=(v,t)=>{assert.equal(v?.$,t,JSON.stringify({expected:t,actual:v?.$,error:v?.error}));return v};
const timer=f=>{const t=performance.now(),value=f();return {value,seconds:(performance.now()-t)/1000}};
const nil=()=>({$:'Nil'}),list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil());
try{
 const api=(await import(pathToFileURL(rec.api.file))).default;
 const seed=tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(sel.preferredCarrier.file,'utf8'),sel.preferredStamp),'P86PreparationReady').seed;
 const prepare=(file,text)=>timer(()=>tag(api.p134e_plan(api.p86_plan(seed,file,text)),'P134Planned').plan);
 const fresh=plan=>timer(()=>{let c=api.p134e_begin(plan),pieces=[];for(let n=0;n<100000;n++){const s=api.p134e_next(c);if(s.$==='P134Done')return pieces;tag(s,'P134Piece');pieces.push(s.text+(s.legacy_end?'\n':''));c=s.next;}throw Error('cursor budget');});
 const cached=(plan,cache,previous)=>timer(()=>{let s=api.p140r_begin(plan,cache),pieces=[];for(let n=0;n<100000;n++){const x=api.p140r_next(s);if(x.$==='P140REnd')return {pieces,cache:x.cache,hits:x.hits,misses:x.misses,contextValid:s.valid};if(x.$==='P140RReuse'){assert(Number.isInteger(x.ordinal)&&x.ordinal>=0&&x.ordinal<previous.length);pieces.push(previous[x.ordinal]);}else{tag(x,'P140RText');pieces.push(x.text+(x.ending?'\n':''));}s=x.next;}throw Error('cache cursor budget');});
 for(const family of families){
  const c=refs.cases.find(c=>c.name===family);assert(c);verify(c.source);verify(c.expectedQbe);report.inputs.push(c.source,c.expectedQbe);
  const a=fs.readFileSync(c.source.file,'utf8');
  const edits={lexer:['U32.shln(x, 13n)','U32.shln(x, 12n)'],'coverage-map-churn-128':['U32.mul(i, 31)','U32.mul(i, 29)']};
  const [needle,replacement]=edits[family];assert.equal(a.split(needle).length,2);
  const b=a.replace(needle,replacement);fs.writeFileSync(out+'/'+family+'-b.bend',b);
  const pa=prepare(c.source.file,a), pb=prepare(c.source.file,b);
  const fa=fresh(pa.value), ca=cached(pa.value,{$:'P140REmpty'},[]), fb=fresh(pb.value), cb=cached(pb.value,ca.value.cache,ca.value.pieces), noop=cached(pa.value,ca.value.cache,ca.value.pieces);
  assert.equal(fa.value.join(''),fs.readFileSync(c.expectedQbe.file,'utf8'));
  assert.deepEqual(ca.value.pieces,fa.value);assert.deepEqual(noop.value.pieces,fa.value);assert.deepEqual(cb.value.pieces,fb.value);assert.notEqual(fa.value.join(''),fb.value.join(''));
  const row={family,edit:{needle,replacement},prepareASeconds:pa.seconds,prepareBSeconds:pb.seconds,freshRenderASeconds:fa.seconds,coldRenderASeconds:ca.seconds,freshRenderBSeconds:fb.seconds,warmRenderBSeconds:cb.seconds,noOpRenderSeconds:noop.seconds,hits:cb.value.hits,misses:cb.value.misses,contextValid:cb.value.contextValid,noOpHits:noop.value.hits,renderSpeedup:fb.seconds/cb.seconds,completeSmallRequestSpeedup:(pb.seconds+fb.seconds)/(pb.seconds+cb.seconds),coldOverhead:(pa.seconds+ca.seconds)/(pa.seconds+fa.seconds)-1,exactFreshB:true,a:digest(fa.value.join('')),b:digest(fb.value.join(''))};
  report.rows.push(row);save();console.log(JSON.stringify(row));
 }
 // Finite adversarial data challenges call actual checked admission predicates.
 const seg=(name,body)=>({$:'N111Segment',name,arity:0,result:0,incoming:0,flags:0,body:list(body)});
 const val=n=>({$:'N111Const',lo:n,hi:0});
 const stmt=n=>({$:'N111Return',value:val(n)});
 const s=seg('test',[stmt(1)]);assert.equal(api.p140r_segment(s,s),true);assert.equal(api.p140r_segment(s,seg('test',[stmt(2)])),false);
 report.controls.push('exact-segment','changed-body-refused');
 for(const group of ['p140rc_controls','p140rc_extra_controls'])if(api[group]){let rows=api[group]();while(rows.$==='Con'){assert(rows.head.endsWith(':pass'),rows.head);report.controls.push(rows.head);rows=rows.tail;}tag(rows,'Nil');}
 report.inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}finally{report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,error:report.error}));}
