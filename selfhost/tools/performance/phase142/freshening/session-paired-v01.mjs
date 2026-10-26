// One checked API, original session versus retained freshening; separate A states.
// Host code observes/pairs results; all compilation decisions remain checked Bend.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';

const ROOT=path.resolve(import.meta.dirname,'../../../../..');
const [apiArg,outArg,oracleArg,guardArg]=process.argv.slice(2);
assert(apiArg&&outArg&&oracleArg,'API report, fresh output, completed oracle-screen report required');
const started=performance.now(),out=path.resolve(outArg),rounds=3,budgetSeconds=120;
assert(!fs.existsSync(out)&&out.startsWith(ROOT+'/selfhost/build/phase142/'));
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const read=file=>JSON.parse(fs.readFileSync(file)),verify=p=>assert.deepEqual(pin(p.file),p);
const digest=text=>({bytes:Buffer.byteLength(text),sha256:crypto.createHash('sha256').update(text).digest('hex')});
const tag=(x,t)=>{assert.equal(x?.$,t,JSON.stringify({expected:t,actual:x?.$,error:x?.error}));return x};
const timer=f=>{const t=performance.now(),value=f();return{value,seconds:(performance.now()-t)/1000}};
const elapsed=()=>(performance.now()-started)/1000;
const median=xs=>[...xs].sort((a,b)=>a-b)[Math.floor(xs.length/2)];
const list=l=>{const a=[];while(l.$==='Con'){assert(a.length<100000);a.push(l.head);l=l.tail;}tag(l,'Nil');return a};
const compact=x=>Object.fromEntries(Object.entries(x).filter(([k])=>!['text','state'].includes(k)));
const blocks=text=>{const hs=[...text.matchAll(/^(?:@unsafe\n)?(?:def|type|law) ([A-Za-z0-9_.]+)\b/gm)];return Object.fromEntries(hs.map((h,i)=>[h[1],text.slice(h.index,hs[i+1]?.index??text.length)]))};
const norm=s=>s.split('\n').map(x=>x.trimEnd()).filter(x=>x.trim()&&!x.trimStart().startsWith('#')).join('\n');
const rec=read(apiArg),parentPath=ROOT+'/selfhost/build/phase141/integrated-source02/compiler.bend';
assert(rec.complete&&rec.checked);rec.inputs.forEach(verify);verify(rec.api);
const parent=pin(parentPath);assert.equal(parent.sha256,'f5bfca6d1fe9b378955d6c89ba5ec2428ec1627d7d008eb0c15eac1b51c8a06a');
const required=['p142fs_begin','p142fs_request','p140s_named','p140s_empty','p88_cache_prepare','f_source_end','p140g_prepare','p140r_begin_cursor','p140r_next'];
for(const key of required)assert(rec.exports.includes(key),'Missing checked export: '+key);
const source=rec.inputs.find(p=>p.file.endsWith('/compiler.bend'));assert(source);
const parentBlocks=blocks(fs.readFileSync(parentPath,'utf8')),currentBlocks=blocks(fs.readFileSync(source.file,'utf8'));
for(const [name,body] of Object.entries(parentBlocks))assert.equal(norm(currentBlocks[name]),norm(body),'Unchanged parent declaration: '+name);
function exact(a,b){const todo=[[a,b]],seen=new WeakMap();while(todo.length){const[x,y]=todo.pop();if(Object.is(x,y))continue;if(!x||!y||typeof x!=='object'||typeof y!=='object'){assert.deepEqual(x,y);continue;}let set=seen.get(x);if(set?.has(y))continue;if(!set){set=new WeakSet();seen.set(x,set);}set.add(y);const keys=Object.keys(x).sort();assert.deepEqual(keys,Object.keys(y).sort());for(const k of keys)todo.push([x[k],y[k]]);}}
const selectionPath=ROOT+'/implementation/phase137/candidate.json',selection=read(selectionPath),carrier=read(selection.preferredCarrierReceipt.file);
const base=carrier.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));assert(base);verify(base);verify(selection.preferredCarrier);
const refsPath=ROOT+'/selfhost/build/phase134/reference03.json',refs=read(refsPath),oracle=read(oracleArg);
assert(refs.complete&&oracle.complete&&oracle.entryMode==='ordinary-session');oracle.inputs.forEach(verify);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const report={kind:'phase142-freshening-same-api-paired-v1',complete:false,rounds,budgetSeconds,
 inputs:[pin(import.meta.filename),pin(process.execPath),pin(apiArg),rec.api,...rec.inputs,parent,pin(selectionPath),pin(selection.preferredCarrierReceipt.file),base,selection.preferredCarrier,pin(refsPath),pin(oracleArg)],
 acquisition:{apiSeconds:rec.seconds,apiReport:pin(apiArg),includedInCurrentProcess:false},
 guard:{receiptFile:guardArg?path.resolve(guardArg):null,validatedHere:false,scope:'External controller wall/RSS includes this entire script. Bind its completed receipt separately; do not add its duration to nested timers.'},
 rows:[],controls:[],scope:'One API/runtime; original unchanged session versus retained-freshening session. Separate retained A caches, one A→B warmup each, then three alternating pairs from unchanged A. Complete request includes compile, registry, rendering, text construction, hashing and writing. Oracle comparisons and report writes are outside request timers. No native, machine-build, adoption or confidence-interval claim.',
 limitations:['Same API removes independently generated helper code/layout as a confounder; it does not remove GC, JIT, host scheduling or wrapper-specific differences.','No forced collection or best-run selection. Every pair and order is retained.','Old independent fresh QBE oracles are authenticated and reused; their acquisition cost is reported as historical, not repeated.','Freshening hit/cut/eligible counts are separate from ordinary compiler stage counters.']};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
try{
 const imported=performance.now(),api=(await import(pathToFileURL(rec.api.file))).default;report.importSeconds=(performance.now()-imported)/1000;
 const loaded=timer(()=>tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(selection.preferredCarrier.file,'utf8'),selection.preferredStamp),'P86PreparationReady').seed);
 const seed=loaded.value,origin=api.f_source_end(seed.source);report.baseSeedSeconds=loaded.seconds;
 const empty=role=>({compiler:role==='baseline'?api.p140s_empty():api.p142fs_begin(seed),registry:{$:'P140GCache',passes:{$:'Nil'}},render:{$:'P140REmpty'},pieces:[]});
 const run=(role,label,file,text,prior,hint,owner)=>{
  const start=performance.now(),compile=timer(()=>role==='baseline'?api.p140s_named(seed,file,text,prior.compiler,hint,owner):api.p142fs_request(prior.compiler,file,text,hint,owner));
  const s=tag(compile.value,role==='baseline'?'P140SResult':'P142FreshResult'),compiler=role==='baseline'?s.cache:s.session;
  if(s.emission.$==='P111Emission'){assert(s.emission.error);return{error:s.emission.error,totalSeconds:(performance.now()-start)/1000,compileSeconds:compile.seconds,state:{...prior,compiler},stats:list(s.stats),freshStats:role==='baseline'?null:list(s.fresh_stats)};}
  const emission=tag(s.emission,'P134Planned');
  const registry=timer(()=>tag(api.p140g_prepare(emission.plan,prior.registry),'P140GPrepared'));
  const render=timer(()=>{let c=api.p140r_begin_cursor(registry.value.cursor,prior.render),pieces=[];for(let i=0;i<100000;i++){
   const x=api.p140r_next(c);if(x.$==='P140REnd')return{pieces,cache:x.cache,hits:x.hits,misses:x.misses};
   if(x.$==='P140RReuse'){assert(x.ordinal>=0&&x.ordinal<prior.pieces.length);pieces.push(prior.pieces[x.ordinal]);}
   else{tag(x,'P140RText');pieces.push(x.text+(x.ending?'\n':''));}c=x.next;
  }throw Error('render cursor bound');});
  const output=timer(()=>{const text=render.value.pieces.join(''),product=digest(text);fs.writeFileSync(out+'/'+label+'.ssa',text);return{text,...product}});
  const totalSeconds=(performance.now()-start)/1000;
  return{...output.value,totalSeconds,compileSeconds:compile.seconds,registrySeconds:registry.seconds,renderSeconds:render.seconds,outputSeconds:output.seconds,
   stats:list(s.stats),freshStats:role==='baseline'?null:list(s.fresh_stats),registryHits:registry.value.hits,registryMisses:registry.value.misses,renderHits:render.value.hits,renderMisses:render.value.misses,
   state:{compiler,registry:registry.value.cache,render:render.value.cache,pieces:render.value.pieces}};
 };
 const specs=[['lexer','prng','U32.shln(x, 13n)','U32.shln(x, 12n)'],['coverage-map-churn-128','p37.map.update','U32.mul(i, 31)','U32.mul(i, 29)']];
 for(const [familyIndex,[family,owner,needle,replacement]] of specs.entries()){
  assert(elapsed()<budgetSeconds,'Process budget before family');
  const ref=refs.cases.find(x=>x.name===family),oldRow=oracle.rows.find(x=>x.family===family);assert(ref&&oldRow?.completeOutputExact);
  verify(ref.source);verify(ref.expectedQbe);report.inputs.push(ref.source,ref.expectedQbe);
  const a=fs.readFileSync(ref.source.file,'utf8');assert.equal(a.split(needle).length,2);const b=a.replace(needle,replacement),hint=origin+a.indexOf(needle);
  assert.deepEqual(oldRow.edit,{owner,needle,replacement,hint,logicalPath:ref.source.file});
  const oracleDir=path.dirname(path.resolve(oracleArg)),oldB=oracleDir+'/'+family+'-B.bend';assert.equal(fs.readFileSync(oldB,'utf8'),b);report.inputs.push(pin(oldB));
  const expectedA=fs.readFileSync(ref.expectedQbe.file,'utf8'),expectedBPath=oracleDir+'/'+family+'-reference-B.ssa',expectedB=fs.readFileSync(expectedBPath,'utf8');
  assert.deepEqual(digest(expectedB),{bytes:oldRow.reference.B.bytes,sha256:oldRow.reference.B.sha256});assert.notEqual(expectedA,expectedB);report.inputs.push(pin(expectedBPath));
  fs.writeFileSync(out+'/'+family+'-B.bend',b);report.inputs.push(pin(out+'/'+family+'-B.bend'));
  const row={family,edit:oldRow.edit,oracle:{A:ref.expectedQbe,B:pin(expectedBPath),historicalFreshSeconds:oldRow.reference.B.totalSeconds,recomputed:false},seed:{},warmup:{},pairs:[]};report.rows.push(row);save();
  const roles=familyIndex%2?['candidate','baseline']:['baseline','candidate'],saved={};row.seedOrder=roles;
  for(const role of roles){const x=run(role,family+'-'+role+'-A',ref.source.file,a,empty(role),hint,owner);assert.equal(x.text,expectedA);saved[role]=x.state;row.seed[role]=compact(x);save();}
  row.warmupOrder=[...roles].reverse();
  for(const role of row.warmupOrder){const x=run(role,family+'-'+role+'-warmup-B',ref.source.file,b,saved[role],hint,owner);assert.equal(x.text,expectedB);row.warmup[role]=compact(x);save();}
  let estimatedPairSeconds=row.warmup.baseline.totalSeconds+row.warmup.candidate.totalSeconds;
  for(let round=0;round<rounds;round++){
   assert(elapsed()+estimatedPairSeconds*1.15+0.25<budgetSeconds,'Insufficient remaining process budget for a complete pair');
   const order=(round+familyIndex)%2?['candidate','baseline']:['baseline','candidate'],values={};
   for(const role of order){const x=run(role,family+'-'+role+'-B-'+round,ref.source.file,b,saved[role],hint,owner);assert.equal(x.text,expectedB);values[role]=compact(x);}
   estimatedPairSeconds=values.baseline.totalSeconds+values.candidate.totalSeconds;
   row.pairs.push({round,order,baseline:values.baseline,candidate:values.candidate,completeRatio:values.candidate.totalSeconds/values.baseline.totalSeconds,compileRatio:values.candidate.compileSeconds/values.baseline.compileSeconds});save();
  }
  row.completeOutputExact=true;
  row.medianPairedCompleteRatio=median(row.pairs.map(x=>x.completeRatio));row.medianPairedCompileRatio=median(row.pairs.map(x=>x.compileRatio));
  row.medianBaselineSeconds=median(row.pairs.map(x=>x.baseline.totalSeconds));row.medianCandidateSeconds=median(row.pairs.map(x=>x.candidate.totalSeconds));
  row.orderStrata=['baseline','candidate'].map(first=>{const pairs=row.pairs.filter(x=>x.order[0]===first);return{first,count:pairs.length,medianCompleteRatio:median(pairs.map(x=>x.completeRatio)),medianCompileRatio:median(pairs.map(x=>x.compileRatio))}});
  save();console.log(JSON.stringify({family,completeRatio:row.medianPairedCompleteRatio,compileRatio:row.medianPairedCompileRatio,elapsedSeconds:elapsed()}));
 }
 // Failure transactions are outside performance pairs and retain the whole
 // previous session. Recovered complete products use the unchanged old session.
 const controlStarted=performance.now(),file='/phase142/freshening-session-errors.bend',a='import Base\ndef before(x: U32) -> U32:\n  x\ndef work(x: U32) -> U32:\n  U32.add(x, 1)\ndef main() -> U32:\n  work(2)\n',owner='work',hint=origin+a.indexOf('U32.add(x, 1)'),states={};
 for(const role of ['baseline','candidate']){const x=run(role,'error-'+role+'-A',file,a,empty(role),hint,owner);assert(!x.error);states[role]=x.state;}
 for(const [name,bad]of[['parse',a.replace('U32.add(x, 1)','U32.add(x, 1')],['type',a.replace('U32.add(x, 1)','U32.add(x, True{})')],['import',a.replace('import Base','import Missing')]]){
  assert(elapsed()<budgetSeconds,'Process budget before failure transaction');
  const old=run('baseline','error-baseline-'+name,file,bad,states.baseline,hint,owner),next=run('candidate','error-candidate-'+name,file,bad,states.candidate,hint,owner);assert(old.error);assert.equal(next.error,old.error);exact(old.state.compiler,states.baseline.compiler);exact(next.state.compiler,states.candidate.compiler);
  const b=a.replace('U32.add(x, 1)','U32.add(x, 3)'),oldRecovery=run('baseline','recovery-baseline-'+name,file,b,old.state,hint,owner),newRecovery=run('candidate','recovery-candidate-'+name,file,b,next.state,hint,owner);assert(!oldRecovery.error&&!newRecovery.error);assert.equal(newRecovery.text,oldRecovery.text);exact(oldRecovery.state.compiler,newRecovery.state.compiler.compiler);
  report.controls.push({name,error:next.error,originalPriorExact:true,retainedWholeSessionExact:true,recoveryQbeExact:true,recoveredCompilerCacheExact:true,recoveryProduct:digest(newRecovery.text),candidateFreshStats:newRecovery.freshStats});save();
 }
 report.failureTransactionSeconds=(performance.now()-controlStarted)/1000;
 report.inputs.forEach(verify);assert(elapsed()<budgetSeconds,'Process budget exceeded');report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}finally{
 report.processSeconds=elapsed();report.peakRssBytes=process.resourceUsage().maxRSS*1024;
 report.costs={baseSeedSeconds:report.baseSeedSeconds??null,coldASeconds:report.rows.flatMap(r=>Object.values(r.seed)).reduce((s,x)=>s+x.totalSeconds,0),
  warmupSeconds:report.rows.flatMap(r=>Object.values(r.warmup)).reduce((s,x)=>s+x.totalSeconds,0),
  failureTransactionSeconds:report.failureTransactionSeconds??0,
  measuredRequestSeconds:report.rows.flatMap(r=>r.pairs).reduce((s,p)=>s+p.baseline.totalSeconds+p.candidate.totalSeconds,0),
  note:'These disjoint request classes lie inside processSeconds; compile/registry/render/output are nested and must not be added again. Historical API/oracle acquisition and external guard cost are separate.'};
 report.costs.otherProcessSeconds=report.processSeconds-(report.costs.baseSeedSeconds??0)-report.costs.coldASeconds-report.costs.warmupSeconds-report.costs.measuredRequestSeconds-report.costs.failureTransactionSeconds;
 save();console.log(JSON.stringify({complete:report.complete,processSeconds:report.processSeconds,error:report.error}));
}
