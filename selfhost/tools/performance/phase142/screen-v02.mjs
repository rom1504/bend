// Host orchestration and exact observation only. All compiler decisions execute
// independently source-checked Bend APIs; baseline/candidate states stay separate.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';

const ROOT=path.resolve(import.meta.dirname,'../../../..');
const [baseArg,candidateArg,outArg,roundsArg='3',...chosen]=process.argv.slice(2);
const out=path.resolve(outArg),rounds=Number(roundsArg);
const witness=!chosen.includes('--ordinary-candidate');
assert(rounds>=1&&rounds<=7&&Number.isInteger(rounds));
assert(!fs.existsSync(out)&&out.startsWith(ROOT+'/selfhost/build/phase142/'));
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const read=file=>JSON.parse(fs.readFileSync(file));
const verify=p=>assert.deepEqual(pin(p.file),p);
const digest=text=>({bytes:Buffer.byteLength(text),sha256:crypto.createHash('sha256').update(text).digest('hex')});
const tag=(x,t)=>{assert.equal(x?.$,t,JSON.stringify({expected:t,actual:x?.$,error:x?.error}));return x};
const timer=f=>{const start=performance.now(),value=f();return{value,seconds:(performance.now()-start)/1000}};
const list=l=>{const a=[];while(l.$==='Con'){assert(a.length<100000);a.push(l.head);l=l.tail;}tag(l,'Nil');return a};
const nil=()=>({$:'Nil'});
const median=a=>[...a].sort((x,y)=>x-y)[Math.floor(a.length/2)];
function exact(a,b){const todo=[[a,b]],seen=new WeakMap();while(todo.length){const[x,y]=todo.pop();if(Object.is(x,y))continue;if(!x||!y||typeof x!=='object'||typeof y!=='object'){assert.deepEqual(x,y);continue;}let s=seen.get(x);if(s?.has(y))continue;if(!s){s=new WeakSet();seen.set(x,s);}s.add(y);const k=Object.keys(x).sort();assert.deepEqual(k,Object.keys(y).sort());for(const n of k)todo.push([x[n],y[n]]);}}
const baseRec=read(baseArg),candidateRec=read(candidateArg);
for(const r of [baseRec,candidateRec]){assert(r.complete&&r.checked);r.inputs.forEach(verify);verify(r.api);}
const selection=read(ROOT+'/implementation/phase137/candidate.json');
const carrier=read(selection.preferredCarrierReceipt.file);
const base=carrier.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));
assert(base);verify(base);verify(selection.preferredCarrier);
const reference=read(ROOT+'/selfhost/build/phase134/reference03.json');assert(reference.complete);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const report={kind:'phase142-retained-witness-complete-screen',complete:false,rounds,entryMode:witness?'witness':'ordinary-session',
 inputs:[pin(import.meta.filename),pin(process.execPath),pin(baseArg),pin(candidateArg),baseRec.api,candidateRec.api,...baseRec.inputs,...candidateRec.inputs,pin(ROOT+'/implementation/phase137/candidate.json'),pin(selection.preferredCarrierReceipt.file),base,selection.preferredCarrier,pin(ROOT+'/selfhost/build/phase134/reference03.json')],
 rows:[],controls:[],scope:'Hosted checked Bend, separate baseline/candidate retained states. Complete request includes compilation, registry, rendering, complete text construction, hashing and writing. No machine build, native speed or adoption claim. Acquisition/seeding charged separately. Diagnostic dual admission excluded only from timed production path.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
try{
 const old=(await import(pathToFileURL(baseRec.api.file))).default;
 const next=(await import(pathToFileURL(candidateRec.api.file))).default;
 const baseText=fs.readFileSync(base.file,'utf8'),carrierText=fs.readFileSync(selection.preferredCarrier.file,'utf8');
 const load=api=>timer(()=>tag(api.p88_cache_prepare(base.file,baseText,carrierText,selection.preferredStamp),'P86PreparationReady').seed);
 const oldLoad=load(old),newLoad=load(next);report.seedSeconds={baseline:oldLoad.seconds,candidate:newLoad.seconds};
 const origin=old.f_source_end(oldLoad.value.source);assert.equal(origin,next.f_source_end(newLoad.value.source));
 const empty=(api,seed,candidate)=>({compiler:candidate&&witness?api.p142w_seed(seed):api.p140s_empty(),registry:{$:'P140GCache',passes:nil()},render:{$:'P140REmpty'},pieces:[]});
 const output=(label,pieces)=>{const text=pieces.join('');const d=digest(text);fs.writeFileSync(out+'/'+label+'.ssa',text);return{text,...d}};
 const fresh=(label,file,text)=>{const start=performance.now();const plan=tag(old.p86_plan(oldLoad.value,file,text),'P86PlanReady');const emission=tag(old.p134e_plan(plan),'P134Planned');let cursor=old.p134e_begin(emission.plan),pieces=[];for(let i=0;i<100000;i++){const s=old.p134e_next(cursor);if(s.$==='P134Done')return{...output(label,pieces),totalSeconds:(performance.now()-start)/1000};tag(s,'P134Piece');pieces.push(s.text+(s.legacy_end?'\n':''));cursor=s.next;}throw Error('fresh cursor budget');};
 const cached=(api,seed,candidate,diagnostic,label,file,text,prior,hint,owner)=>{
  const start=performance.now();
  const compile=timer(()=>candidate&&witness?(diagnostic?api.p142w_diagnose:api.p142w_named)(prior.compiler,file,text,hint,owner):api.p140s_named(seed,file,text,prior.compiler,hint,owner));
  const s=compile.value;
  if(s.emission.$==='P111Emission'){assert(s.emission.error);return{error:s.emission.error,state:{...prior,compiler:s.cache},stats:list(s.stats),totalSeconds:(performance.now()-start)/1000};}
  const prepare=timer(()=>tag(api.p140g_prepare(tag(s.emission,'P134Planned').plan,prior.registry),'P140GPrepared'));
  const render=timer(()=>{let c=api.p140r_begin_cursor(prepare.value.cursor,prior.render),pieces=[];for(let i=0;i<100000;i++){const x=api.p140r_next(c);if(x.$==='P140REnd')return{pieces,cache:x.cache,hits:x.hits,misses:x.misses};if(x.$==='P140RReuse'){assert(x.ordinal>=0&&x.ordinal<prior.pieces.length);pieces.push(prior.pieces[x.ordinal]);}else{tag(x,'P140RText');pieces.push(x.text+(x.ending?'\n':''));}c=x.next;}throw Error('reuse cursor budget');});
  const written=output(label,render.value.pieces);
  const observation=Object.fromEntries(Object.entries(s).filter(([k])=>!['$','emission','cache','stats'].includes(k)).map(([k,v])=>[k,v&&v.$==='Con'?list(v):v]));
  return{...written,totalSeconds:(performance.now()-start)/1000,compileSeconds:compile.seconds,registrySeconds:prepare.seconds,renderSeconds:render.seconds,stats:list(s.stats),observation,registryHits:prepare.value.hits,registryMisses:prepare.value.misses,renderHits:render.value.hits,renderMisses:render.value.misses,state:{compiler:s.cache,registry:prepare.value.cache,render:render.value.cache,pieces:render.value.pieces}};
 };
 const compact=x=>Object.fromEntries(Object.entries(x).filter(([k])=>!['text','state'].includes(k)));
 const specs={lexer:['prng','U32.shln(x, 13n)','U32.shln(x, 12n)'],'coverage-map-churn-128':['p37.map.update','U32.mul(i, 31)','U32.mul(i, 29)']};
 const selected=chosen.filter(x=>x!=='--ordinary-candidate');
 const families=selected.length?selected:Object.keys(specs);
 for(const family of families){
  const ref=reference.cases.find(x=>x.name===family);assert(ref&&specs[family]);verify(ref.source);verify(ref.expectedQbe);report.inputs.push(ref.source,ref.expectedQbe);
  const a=fs.readFileSync(ref.source.file,'utf8'),[owner,needle,replacement]=specs[family];assert.equal(a.split(needle).length,2);
  const b=a.replace(needle,replacement),hint=origin+a.indexOf(needle);fs.writeFileSync(out+'/'+family+'-B.bend',b);report.inputs.push(pin(out+'/'+family+'-B.bend'));
  const row={family,edit:{owner,needle,replacement,hint,logicalPath:ref.source.file},pairs:[]};report.rows.push(row);save();
  const expectedA=fresh(family+'-reference-A',ref.source.file,a);assert.equal(expectedA.text,fs.readFileSync(ref.expectedQbe.file,'utf8'));
  const expectedB=fresh(family+'-reference-B',ref.source.file,b);assert.notEqual(expectedA.text,expectedB.text);row.reference={A:compact(expectedA),B:compact(expectedB)};
  const oldA=cached(old,oldLoad.value,false,false,family+'-baseline-A',ref.source.file,a,empty(old,oldLoad.value,false),hint,owner);
  const newA=cached(next,newLoad.value,true,false,family+'-candidate-A',ref.source.file,a,empty(next,newLoad.value,true),hint,owner);
  assert.equal(oldA.text,expectedA.text);assert.equal(newA.text,expectedA.text);row.seed={baseline:compact(oldA),candidate:compact(newA)};save();
  const diagnostic=cached(next,newLoad.value,true,true,family+'-diagnostic-B',ref.source.file,b,newA.state,hint,owner);assert.equal(diagnostic.text,expectedB.text);row.diagnostic={...compact(diagnostic),dualWitnessComparison:witness};save();
  let last;
  for(let round=0;round<rounds;round++){
   const runOld=()=>cached(old,oldLoad.value,false,false,family+'-baseline-B-'+round,ref.source.file,b,oldA.state,hint,owner);
   const runNew=()=>cached(next,newLoad.value,true,false,family+'-candidate-B-'+round,ref.source.file,b,newA.state,hint,owner);
   let x,y;if(round%2){y=runNew();x=runOld();}else{x=runOld();y=runNew();}
   assert.equal(x.text,expectedB.text);assert.equal(y.text,expectedB.text);last=y;
   row.pairs.push({round,order:round%2?'candidate/baseline':'baseline/candidate',baseline:compact(x),candidate:compact(y),ratio:y.totalSeconds/x.totalSeconds});save();
  }
  const reverted=cached(next,newLoad.value,true,true,family+'-revert-A',ref.source.file,a,last.state,hint,owner);assert.equal(reverted.text,expectedA.text);row.revert=compact(reverted);
  row.completeOutputExact=true;row.medianPairedRatio=median(row.pairs.map(p=>p.ratio));row.medianBaselineSeconds=median(row.pairs.map(p=>p.baseline.totalSeconds));row.medianCandidateSeconds=median(row.pairs.map(p=>p.candidate.totalSeconds));save();console.log(JSON.stringify({family,ratio:row.medianPairedRatio,baseline:row.medianBaselineSeconds,candidate:row.medianCandidateSeconds}));
 }
 const file='/phase142/error-fixture.bend',a='import Base\ndef work(x: U32) -> U32:\n  U32.add(x, 1)\ndef main() -> U32:\n  work(2)\n',owner='work',hint=origin+a.indexOf('U32.add');
 const first=cached(next,newLoad.value,true,true,'error-seed',file,a,empty(next,newLoad.value,true),hint,owner);assert(!first.error);
 for(const [label,bad]of[['type',a.replace('U32.add(x, 1)','U32.add(x, True{})')],['parse',a.replace('U32.add(x, 1)','U32.add(x, 1')]]){
  const expected=tag(old.p86_plan(oldLoad.value,file,bad),'P86PlanError');const attempted=cached(next,newLoad.value,true,true,'error-'+label,file,bad,first.state,hint,owner);assert.equal(attempted.error,expected.error);exact(attempted.state.compiler,first.state.compiler);
  const b=a.replace('U32.add(x, 1)','U32.add(x, 3)'),ref=fresh('recovery-reference-'+label,file,b),recovered=cached(next,newLoad.value,true,true,'recovery-'+label,file,b,attempted.state,hint,owner);assert.equal(recovered.text,ref.text);report.controls.push({label,error:expected.error,priorStateExact:true,recoveryExact:true});save();
 }
 report.inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}finally{report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,error:report.error}));}
