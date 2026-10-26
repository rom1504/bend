// Hosted complete-request differential screen; compilation and reuse stay in
// checked Bend. Keep producer acquisition and derived-product rendering separate.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';
import assert from 'node:assert/strict';import{pathToFileURL}from'node:url';
const ROOT=path.resolve(import.meta.dirname,'../../../../..'),[apiArg,outArg]=process.argv.slice(2);
assert(apiArg&&outArg);const out=path.resolve(outArg);assert(!fs.existsSync(out)&&out.startsWith(ROOT+'/selfhost/build/phase142/'));
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const read=f=>JSON.parse(fs.readFileSync(f)),verify=p=>assert.deepEqual(pin(p.file),p),rec=read(apiArg),selPath=ROOT+'/implementation/phase137/candidate.json',sel=read(selPath),refPath=ROOT+'/selfhost/build/phase134/reference03.json',refs=read(refPath),carrier=read(sel.preferredCarrierReceipt.file);
assert(rec.complete&&rec.checked&&sel.nativeQualified&&refs.complete);rec.inputs.forEach(verify);verify(rec.api);
const base=carrier.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));assert(base);verify(base);verify(sel.preferredCarrier);
const required=['p88_cache_prepare','f_source_end','p142fs_begin','p142fs_request','p140s_empty','p140s_named','p140g_prepare','p140r_begin_cursor','p140r_next','p86_plan','p134e_plan','p134e_begin','p134e_next','p142ft_controls','p142ffd_controls'];for(const e of required)assert(rec.exports.includes(e),'Missing export '+e);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const report={kind:'phase142-freshening-session-screen',complete:false,diagnostic:true,inputs:[pin(import.meta.filename),pin(apiArg),rec.api,...rec.inputs,pin(selPath),pin(refPath),pin(sel.preferredCarrierReceipt.file),base,sel.preferredCarrier,pin(process.execPath)],rows:[],controls:[],scope:'Hosted checked Bend actual cold A and edited warm B, complete QBE products. Retained registry/render products separate for each role; original fresh compiler and frozen source product are independent output oracles. Ordered observations, no native speedup or broad conformance claim.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
const tag=(x,t)=>{assert.equal(x?.$,t,JSON.stringify({expected:t,actual:x?.$,error:x?.error}));return x},nil=()=>({$:'Nil'});
const arr=l=>{const a=[];while(l.$==='Con'){assert(a.length<1000000);a.push(l.head);l=l.tail;}tag(l,'Nil');return a};
const time=f=>{const t=performance.now(),value=f();return{value,seconds:(performance.now()-t)/1000}},digest=s=>({bytes:Buffer.byteLength(s),sha256:crypto.createHash('sha256').update(s).digest('hex')});
function exact(a,b){const todo=[[a,b]],seen=new WeakMap();while(todo.length){const[x,y]=todo.pop();if(Object.is(x,y))continue;if(!x||!y||typeof x!=='object'||typeof y!=='object'){assert.deepEqual(x,y);continue;}let z=seen.get(x);if(z?.has(y))continue;if(!z){z=new WeakSet();seen.set(x,z);}z.add(y);const keys=Object.keys(x).sort();assert.deepEqual(keys,Object.keys(y).sort());for(const k of keys)todo.push([x[k],y[k]]);}}
const started=performance.now();
try{
 const api=(await import(pathToFileURL(rec.api.file))).default;
 for(const[name,n]of[['p142ft_controls',24],['p142ffd_controls',12]]){const values=arr(api[name]());assert.equal(values.length,n);assert(values.every(x=>x.endsWith(':pass')));report.controls.push({name,values});}save();
 const seedT=time(()=>tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(sel.preferredCarrier.file,'utf8'),sel.preferredStamp),'P86PreparationReady').seed),seed=seedT.value,origin=api.f_source_end(seed.source);report.seedSeconds=seedT.seconds;
 const empty=role=>({compiler:role==='original'?api.p140s_empty():api.p142fs_begin(seed),registry:{$:'P140GCache',passes:nil()},render:{$:'P140REmpty'},pieces:[]});
 const request=(role,file,text,hint,owner,prior)=>{
  const began=performance.now(),compile=time(()=>role==='original'?api.p140s_named(seed,file,text,prior.compiler,hint,owner):api.p142fs_request(prior.compiler,file,text,hint,owner)),result=compile.value;
  const compiler=role==='original'?result.cache:result.session;
  if(result.emission.$==='P111Emission'&&result.emission.error)return{error:result.emission.error,state:{...prior,compiler},compileSeconds:compile.seconds};
  const plan=tag(result.emission,'P134Planned').plan,registry=time(()=>tag(api.p140g_prepare(plan,prior.registry),'P140GPrepared'));
  const rendering=time(()=>{let state=api.p140r_begin_cursor(registry.value.cursor,prior.render);const pieces=[];for(let i=0;i<1000000;i++){const x=api.p140r_next(state);if(x.$==='P140REnd')return{pieces,cache:x.cache,hits:x.hits,misses:x.misses};if(x.$==='P140RReuse'){assert(x.ordinal>=0&&x.ordinal<prior.pieces.length);pieces.push(prior.pieces[x.ordinal]);}else{tag(x,'P140RText');pieces.push(x.text+(x.ending?'\n':''));}state=x.next;}throw Error('cursor bound');});
  const material=time(()=>rendering.value.pieces.join('')),textOut=material.value;
  return{text:textOut,state:{compiler,registry:registry.value.cache,render:rendering.value.cache,pieces:rendering.value.pieces},timing:{compileSeconds:compile.seconds,registrySeconds:registry.seconds,renderSeconds:rendering.seconds,materializationSeconds:material.seconds,totalSeconds:(performance.now()-began)/1000},stats:arr(result.stats),freshStats:role==='original'?null:arr(result.fresh_stats),renderHits:rendering.value.hits,renderMisses:rendering.value.misses};
 };
 const originalFresh=(file,text)=>{const plan=tag(api.p134e_plan(api.p86_plan(seed,file,text)),'P134Planned').plan;let c=api.p134e_begin(plan);const pieces=[];for(let i=0;i<1000000;i++){const x=api.p134e_next(c);if(x.$==='P134Done')return pieces.join('');tag(x,'P134Piece');pieces.push(x.text+(x.legacy_end?'\n':''));c=x.next;}throw Error('fresh bound');};
 for(const[name,owner,needle,replacement]of[['lexer','prng','U32.shln(x, 13n)','U32.shln(x, 12n)'],['coverage-map-churn-128','p37.map.update','U32.mul(i, 31)','U32.mul(i, 29)']]){
  const fixture=refs.cases.find(x=>x.name===name);assert(fixture);verify(fixture.source);verify(fixture.expectedQbe);report.inputs.push(fixture.source,fixture.expectedQbe);
  const a=fs.readFileSync(fixture.source.file,'utf8');assert.equal(a.split(needle).length,2);const b=a.replace(needle,replacement),hint=origin+a.indexOf(needle),bp=out+'/'+name+'-B.bend';fs.writeFileSync(bp,b);report.inputs.push(pin(bp));
  const row={name,edit:{owner,needle,replacement,hint,logicalPath:fixture.source.file},acquisition:{},pairs:[]};report.rows.push(row);save();
  const OA=request('original',fixture.source.file,a,hint,owner,empty('original')),NA=request('retained',fixture.source.file,a,hint,owner,empty('retained'));assert(!OA.error&&!NA.error);assert.equal(OA.text,NA.text);assert.equal(OA.text,fs.readFileSync(fixture.expectedQbe.file,'utf8'));row.acquisition={originalCold:OA.timing,retainedCold:NA.timing,freshStats:NA.freshStats};save();
  const oracle=time(()=>originalFresh(fixture.source.file,b));assert.notEqual(oracle.value,OA.text);row.freshOracleSeconds=oracle.seconds;row.B=digest(oracle.value);
  for(let round=0;round<3;round++){
   let old,next;if(round%2){next=request('retained',fixture.source.file,b,hint,owner,NA.state);old=request('original',fixture.source.file,b,hint,owner,OA.state);}else{old=request('original',fixture.source.file,b,hint,owner,OA.state);next=request('retained',fixture.source.file,b,hint,owner,NA.state);}
   assert(!old.error&&!next.error);assert.equal(old.text,oracle.value);assert.equal(next.text,oracle.value);exact(old.state.compiler,next.state.compiler.compiler);
   row.pairs.push({round,order:round%2?'retained/original':'original/retained',original:old.timing,retained:next.timing,compileRatio:next.timing.compileSeconds/old.timing.compileSeconds,totalRatio:next.timing.totalSeconds/old.timing.totalSeconds,freshStats:next.freshStats,exactCompleteQbe:true,exactOriginalCompilerCache:true});save();
  }
 }
 const file='/phase142/freshening-errors.bend',a='import Base\ndef before(x: U32) -> U32:\n  x\ndef work(x: U32) -> U32:\n  U32.add(x, 1)\ndef main() -> U32:\n  work(2)\n',owner='work',hint=origin+a.indexOf('U32.add(x, 1)'),O=request('original',file,a,hint,owner,empty('original')),N=request('retained',file,a,hint,owner,empty('retained'));assert(!O.error&&!N.error);assert.equal(O.text,N.text);
 for(const[name,bad]of[['parse',a.replace('U32.add(x, 1)','U32.add(x, 1')],['type',a.replace('U32.add(x, 1)','U32.add(x, True{})')],['import',a.replace('import Base','import Missing')]]){
  const old=request('original',file,bad,hint,owner,O.state),next=request('retained',file,bad,hint,owner,N.state);assert(old.error);assert.equal(next.error,old.error);exact(next.state.compiler,N.state.compiler);
  const b=a.replace('U32.add(x, 1)','U32.add(x, 3)'),recovery=request('retained',file,b,hint,owner,next.state);assert(!recovery.error);assert.equal(recovery.text,originalFresh(file,b));report.controls.push({name,error:next.error,retainedSessionExact:true,recoveryQbeExact:true});save();
 }
 report.inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}finally{report.totalSeconds=(performance.now()-started)/1000;report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,totalSeconds:report.totalSeconds,error:report.error}));}
