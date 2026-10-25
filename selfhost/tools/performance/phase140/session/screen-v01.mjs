// Transport, exact differential checks and timing only. All compilation and
// cache admission decisions execute checked Bend exports from the pinned API.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const ROOT=path.resolve(import.meta.dirname,'../../../../..');
const [apiArg,outArg,...selected]=process.argv.slice(2),out=path.resolve(outArg);
const families=selected.length?selected:['lexer','coverage-map-churn-128'];
assert(!fs.existsSync(out)&&out.startsWith(ROOT+'/selfhost/build/phase140/'));
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const digest=text=>({bytes:Buffer.byteLength(text),sha256:crypto.createHash('sha256').update(text).digest('hex')});
const verify=p=>assert.deepEqual(pin(p.file),p),read=p=>JSON.parse(fs.readFileSync(p));
const rec=read(apiArg),selection=read(ROOT+'/implementation/phase137/candidate.json'),reference=read(ROOT+'/selfhost/build/phase134/reference03.json');
assert(rec.checked&&rec.complete&&selection.nativeQualified&&reference.complete);rec.inputs.forEach(verify);verify(rec.api);
const carrier=read(selection.preferredCarrierReceipt.file),base=carrier.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));assert(base);verify(base);verify(selection.preferredCarrier);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const report={kind:'phase140-integrated-session-screen',complete:false,inputs:[pin(import.meta.filename),pin(apiArg),rec.api,...rec.inputs,pin(ROOT+'/implementation/phase137/candidate.json'),pin(ROOT+'/selfhost/build/phase134/reference03.json'),pin(selection.preferredCarrierReceipt.file),base,selection.preferredCarrier],rows:[],controls:[],scope:'Single-process hosted checked Bend. Seed acquisition is separate. Each complete request includes frontend, backend, registry, rendering, byte materialization, hashing and writing a complete QBE file. Cold means empty candidate state, not cold process. Ordered diagnostic observations, no native or calibrated speed claim.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
const tag=(x,t)=>{assert.equal(x?.$,t,JSON.stringify({expected:t,actual:x?.$,error:x?.error}));return x};
const timer=f=>{const t=performance.now(),value=f();return{value,seconds:(performance.now()-t)/1000}};
const nil=()=>({$:'Nil'}),list=xs=>{const r=[];for(let n=0;xs.$==='Con';n++){assert(n<100000);r.push(xs.head);xs=xs.tail;}tag(xs,'Nil');return r;};
function exact(left,right){const todo=[[left,right]],seen=new WeakMap();let objects=0,scalars=0;while(todo.length){const[a,b]=todo.pop();if(Object.is(a,b)){scalars++;continue;}if(a===null||b===null||typeof a!=='object'||typeof b!=='object'){assert.equal(a,b,'exact scalar mismatch');scalars++;continue;}let pairs=seen.get(a);if(pairs?.has(b))continue;if(!pairs){pairs=new WeakSet();seen.set(a,pairs);}pairs.add(b);objects++;const ka=Object.keys(a).sort(),kb=Object.keys(b).sort();assert.deepEqual(ka,kb,'exact fields mismatch');for(const k of ka)todo.push([a[k],b[k]]);}return{objects,scalars};}
function textEqual(a,b,label){assert(a===b,JSON.stringify({label,actual:digest(a),expected:digest(b)}));}
try{
 const api=(await import(pathToFileURL(rec.api.file))).default;
 const seedTime=timer(()=>tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(selection.preferredCarrier.file,'utf8'),selection.preferredStamp),'P86PreparationReady').seed);
 const seed=seedTime.value,start=api.f_source_end(seed.source);assert(Number.isInteger(start));report.seedSeconds=seedTime.seconds;report.sourceOrigin=start;
 const empty=()=>({compiler:api.p140s_empty(),registry:{$:'P140GCache',passes:nil()},render:{$:'P140REmpty'},pieces:[]});
 const output=(name,pieces)=>{const material=timer(()=>{const text=pieces.join('');return{text,...digest(text)}}),write=timer(()=>fs.writeFileSync(out+'/'+name+'.ssa',material.value.text));return{...material.value,materializeSeconds:material.seconds,writeSeconds:write.seconds,file:out+'/'+name+'.ssa'};};
 const fresh=(name,file,text)=>{
  const all=performance.now(),front=timer(()=>api.p86_plan(seed,file,text)),backend=timer(()=>api.p134e_plan(front.value));
  if(backend.value.$==='P111Emission'){assert(backend.value.error);return{error:backend.value.error,plan:front.value,totalSeconds:(performance.now()-all)/1000};}
  const plan=tag(backend.value,'P134Planned').plan,prepare=timer(()=>api.p134e_begin(plan)),render=timer(()=>{let c=prepare.value,pieces=[];for(let n=0;n<100000;n++){const s=api.p134e_next(c);if(s.$==='P134Done')return pieces;tag(s,'P134Piece');pieces.push(s.text+(s.legacy_end?'\n':''));c=s.next;}throw Error('fresh cursor budget');});
  const written=output(name,render.value);return{...written,plan:front.value,totalSeconds:(performance.now()-all)/1000,frontSeconds:front.seconds,backendSeconds:backend.seconds,registrySeconds:prepare.seconds,renderSeconds:render.seconds};
 };
 const cached=(name,file,text,prior,hint,owner)=>{
  const all=performance.now(),compile=timer(()=>tag(api.p140s_named(seed,file,text,prior.compiler,hint,owner),'P140SResult')),s=compile.value;
  if(s.emission.$==='P111Emission'){assert(s.emission.error);return{error:s.emission.error,state:{...prior,compiler:s.cache},stats:list(s.stats),totalSeconds:(performance.now()-all)/1000};}
  const plan=tag(s.emission,'P134Planned').plan,prepare=timer(()=>tag(api.p140g_prepare(plan,prior.registry),'P140GPrepared'));
  const render=timer(()=>{let c=api.p140r_begin_cursor(prepare.value.cursor,prior.render),pieces=[];const contextValid=c.valid;for(let n=0;n<100000;n++){const x=api.p140r_next(c);if(x.$==='P140REnd')return{pieces,cache:x.cache,hits:x.hits,misses:x.misses,contextValid};if(x.$==='P140RReuse'){assert(Number.isInteger(x.ordinal)&&x.ordinal>=0&&x.ordinal<prior.pieces.length);pieces.push(prior.pieces[x.ordinal]);}else{tag(x,'P140RText');pieces.push(x.text+(x.ending?'\n':''));}c=x.next;}throw Error('cache cursor budget');});
  const written=output(name,render.value.pieces);return{...written,totalSeconds:(performance.now()-all)/1000,compileSeconds:compile.seconds,registrySeconds:prepare.seconds,renderSeconds:render.seconds,stats:list(s.stats),registryHits:prepare.value.hits,registryMisses:prepare.value.misses,renderHits:render.value.hits,renderMisses:render.value.misses,renderContextValid:render.value.contextValid,state:{compiler:s.cache,registry:prepare.value.cache,render:render.value.cache,pieces:render.value.pieces}};
 };
 const compact=x=>Object.fromEntries(Object.entries(x).filter(([k])=>!['text','plan','state'].includes(k)));
 const specs={lexer:['prng','U32.shln(x, 13n)','U32.shln(x, 12n)'],'coverage-map-churn-128':['p37.map.update','U32.mul(i, 31)','U32.mul(i, 29)'],'coverage-closures-256':['main.out','U32.mul(a, 1000)','U32.mul(a, 1001)']};
 for(const family of families){
  const c=reference.cases.find(x=>x.name===family);assert(c);verify(c.source);verify(c.expectedQbe);report.inputs.push(c.source,c.expectedQbe);
  const a=fs.readFileSync(c.source.file,'utf8'),[owner,needle,replacement]=specs[family];assert.equal(a.split(needle).length,2);assert(a.includes('def '+owner+'('));
  const b=a.replace(needle,replacement),hint=start+a.indexOf(needle);fs.writeFileSync(out+'/'+family+'-b.bend',b);report.inputs.push(pin(out+'/'+family+'-b.bend'));
  const row={family,edit:{owner,needle,replacement,hint},runs:{},equalities:{}};report.rows.push(row);save();
  const fa=fresh(family+'-fresh-a',c.source.file,a);assert(!fa.error);textEqual(fa.text,fs.readFileSync(c.expectedQbe.file,'utf8'),'frozen A');row.runs.freshA=compact(fa);row.equalities.frozenA=true;save();
  const ca=cached(family+'-cold-a',c.source.file,a,empty(),hint,owner);assert(!ca.error);textEqual(ca.text,fa.text,'cold A');row.runs.coldA=compact(ca);row.equalities.coldA=true;save();
  const fb=fresh(family+'-fresh-b',c.source.file,b);assert(!fb.error);assert(fa.text!==fb.text,'edit did not change QBE');row.runs.freshB=compact(fb);save();
  const cb=cached(family+'-cold-b',c.source.file,b,empty(),hint,owner);assert(!cb.error);textEqual(cb.text,fb.text,'cold B');row.runs.coldB=compact(cb);row.equalities.coldB=true;save();
  const wb=cached(family+'-warm-b',c.source.file,b,ca.state,hint,owner);assert(!wb.error);textEqual(wb.text,fb.text,'warm B');row.runs.warmB=compact(wb);row.equalities.warmB=true;save();
  const nb=cached(family+'-noop-b',c.source.file,b,wb.state,hint,owner);assert(!nb.error);textEqual(nb.text,fb.text,'no-op B');row.runs.noOpB=compact(nb);row.equalities.noOpB=true;save();
  const frontA=timer(()=>tag(api.p140f_named(seed,c.source.file,a,api.p140f_empty(),hint,owner),'P140FResult'));
  const frontB=timer(()=>tag(api.p140f_named(seed,c.source.file,b,frontA.value.cache,hint,owner),'P140FResult'));
  row.equalities.frontendA=exact(frontA.value.plan,fa.plan);row.equalities.frontendB=exact(frontB.value.plan,fb.plan);row.frontend={coldSeconds:frontA.seconds,warmSeconds:frontB.seconds,statsA:list(frontA.value.stats),statsB:list(frontB.value.stats)};
  row.speedups={originalFreshOverWarm:fb.totalSeconds/wb.totalSeconds,sameCandidateColdOverWarm:cb.totalSeconds/wb.totalSeconds,originalFreshOverNoOp:fb.totalSeconds/nb.totalSeconds};row.coldOverhead=cb.totalSeconds/fb.totalSeconds-1;save();console.log(JSON.stringify(row));
 }
 // Small independent fixture checks invalid edits and successful recovery without
 // paying for repeated large output materializations solely to test error gates.
 const file='/phase140/session-errors.bend',a='import Base\ndef before(x: U32) -> U32:\n  x\ndef work(x: U32) -> U32:\n  U32.add(x, 1)\ndef main() -> U32:\n  work(2)\n',owner='work',hint=start+a.indexOf('U32.add(x, 1)');
 const first=cached('error-fixture-a',file,a,empty(),hint,owner);assert(!first.error);
 for(const[label,bad]of[['type',a.replace('U32.add(x, 1)','U32.add(x, True{})')],['parse',a.replace('U32.add(x, 1)','U32.add(x, 1')]]){
  const expected=api.p86_plan(seed,file,bad);tag(expected,'P86PlanError');const attempted=cached('error-'+label,file,bad,first.state,hint,owner);assert.equal(attempted.error,expected.error);const retained=exact(attempted.state.compiler,first.state.compiler);
  const b=a.replace('U32.add(x, 1)','U32.add(x, 3)'),baseline=fresh('recovery-'+label+'-fresh',file,b),recovery=cached('recovery-'+label+'-warm',file,b,attempted.state,hint,owner);assert(!baseline.error&&!recovery.error);textEqual(recovery.text,baseline.text,'error recovery');report.controls.push({name:label,error:expected.error,retainedCache:retained,recoveryExact:true,recoveryStats:recovery.stats});save();
 }
 if(api.p140cb_cut_controls){const controls=list(api.p140cb_cut_controls());assert(controls.every(x=>x.endsWith(':pass')));report.cutControls=controls;}
 report.inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}finally{report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,error:report.error}));}
