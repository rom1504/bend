// Data transport, exact observations and bounded hosted timing only. Every
// query and source preparation operation executes checked Bend API exports.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const ROOT=path.resolve(import.meta.dirname,'../../../../..');
const [apiArg,outArg,carrierArg=ROOT+'/selfhost/build/phase130/base-carrier01/receipt.json',budgetArg='20']=process.argv.slice(2);
assert(apiArg&&outArg,'API_REPORT FRESH_OUTPUT [CARRIER_RECEIPT] [SOFT_SECONDS]');
const out=path.resolve(outArg),budget=Number(budgetArg);
assert(out.startsWith(ROOT+'/selfhost/build/phase143/')&&!fs.existsSync(out));
assert(Number.isFinite(budget)&&budget>=5&&budget<=60);
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const digest=value=>{const b=JSON.stringify(value);return{bytes:Buffer.byteLength(b),sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const inputs=new Map(),add=p=>{const actual=pin(p.file);assert.equal(actual.sha256,p.sha256);assert.equal(actual.bytes,p.bytes);inputs.set(p.file,p);return p};
const addFile=file=>add(pin(file));
const rec=read(apiArg),carrier=read(carrierArg),refsPath=ROOT+'/selfhost/build/phase134/reference03.json',refs=read(refsPath);
assert(rec.complete&&rec.checked&&rec.status===0&&carrier.complete&&refs.complete);
addFile(import.meta.filename);addFile(process.execPath);addFile(apiArg);rec.inputs.forEach(add);add(rec.api);addFile(carrierArg);carrier.inputs.forEach(add);add(carrier.carrier);addFile(refsPath);
const base=carrier.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));assert(base);add(base);
const referencePath=ROOT+'/implementation/phase142/candidate.json';addFile(referencePath);
const reference=read(referencePath);add(reference.source);
const apiSource=rec.inputs.find(p=>p.file===(rec.command||[]).find(x=>x.endsWith('.bend')));assert(apiSource);
const declaration=(text,name)=>{const lines=text.split('\n'),start=lines.findIndex(x=>x.startsWith('def '+name+'('));assert(start>=0,name);let end=start+1;while(end<lines.length&&(!lines[end].trim()||/^\s/.test(lines[end])))end++;return lines.slice(start,end).join('\n').trim();};
assert.equal(declaration(fs.readFileSync(apiSource.file,'utf8'),'nd_comb_fresh'),declaration(fs.readFileSync(reference.source.file,'utf8'),'nd_comb_fresh'),'Differential API must retain the original nd_comb_fresh body');
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const started=performance.now(),elapsed=()=>((performance.now()-started)/1000);
const report={kind:'phase143-occurrence-actual-body-screen',complete:false,controls:[],families:[],subjects:[],queries:[],timings:[],refusals:[],
 softBudgetSeconds:budget,scope:'Hosted checked Bend; real compacted bodies with constructed query/env schedules, not captured production calls. Summary construction is inside every query. No native timing, full-QBE qualification or production speed claim.'};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n')};
const tag=(v,t)=>{assert.equal(v?.$,t,JSON.stringify({expected:t,actual:v?.$,error:v?.error}));return v};
const list=value=>{const result=[];while(value?.$==='Con'){assert(result.length<100000);result.push(value.head);value=value.tail;}tag(value,'Nil');return result};
const bendList=values=>values.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const children=t=>t.$==='KLiteral'?[]:list(t.kids);
const shape=body=>{let nodes=0,vars=0;const ids=new Set(),todo=[body];while(todo.length){const t=todo.pop();assert(++nodes<=200000);if(t.$==='KTerm'&&t.tag==='Var'){vars++;ids.add(t.id);}else todo.push(...children(t));}return{nodes,vars,distinctIds:ids.size};};
const clock=f=>{const before=performance.now(),value=f();return{value,seconds:(performance.now()-before)/1000}};
const rowTime=(fn,q,repetitions)=>{const before=performance.now();let checksum=0;for(let i=0;i<repetitions;i++){const v=fn(q.body,q.args,q.env,q.n,q.left);assert.equal(v,q.expected);checksum+=Number(v);}return{seconds:(performance.now()-before)/1000,checksum,repetitions}};
save();
try{
 const api=(await import(pathToFileURL(rec.api.file))).default;
 for(const name of ['p88_cache_prepare','p86_plan','p143o_subject','p143o_original','p143o_summary','p143o_range','p143o_controls','p143o_range_controls'])assert.equal(typeof api[name],'function','Missing export '+name);
 for(const [entry,count] of [['p143o_controls',33],['p143o_range_controls',14]]){
  const rows=list(api[entry]());assert.equal(rows.length,count);assert(rows.every(s=>typeof s==='string'&&s.startsWith('PASS ')),JSON.stringify(rows));assert.equal(new Set(rows).size,count);report.controls.push({entry,count,rows});
 }
 report.controlsPassed=47;save();
 const prepared=clock(()=>tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(carrier.carrier.file,'utf8'),carrier.stamp),'P86PreparationReady').seed);
 report.basePreparationSeconds=prepared.seconds;
 const selected=[];
 for(const family of ['lexer','coverage-map-churn-128']){
  const c=refs.cases.find(x=>x.name===family);assert(c);add(c.source);add(c.expectedQbe);
  const text=fs.readFileSync(c.source.file,'utf8');
  const preparedPlan=clock(()=>tag(api.p86_plan(prepared.value,c.source.file,text),'P86PlanReady'));
  const names=[...new Set([...text.matchAll(/^def\s+([A-Za-z_][A-Za-z0-9_.]*)\s*\(/gm)].map(x=>x[1]))].slice(0,8);
  assert(names.length,'No ordinary source declaration candidates');
  const bodies=[];
  for(const name of names){
   const body=clock(()=>tag(api.p143o_subject(preparedPlan.value.request,name,0),'P143OSubject'));
   if(body.value.error){report.refusals.push({family,name,error:body.value.error});continue;}
   const census=shape(body.value.body);assert(census.nodes<=10000,'Oversized microbenchmark body');
   bodies.push({...body.value,census,prepareSeconds:body.seconds});
  }
  assert(bodies.length,'No accepted real source body');bodies.sort((a,b)=>a.census.nodes-b.census.nodes||a.owner.localeCompare(b.owner));
  const chosen=[...new Set([0,Math.floor((bodies.length-1)/2),bodies.length-1])].map(i=>bodies[i]);
  report.families.push({family,source:c.source,frontendSeconds:preparedPlan.seconds,preparedCandidates:bodies.length,chosen:chosen.map(b=>b.owner),oraclePin:c.expectedQbe,completeQbeCompared:false});
  for(const b of chosen){
   const id='subject-'+String(selected.length).padStart(2,'0'),file=out+'/'+id+'.json';
   fs.writeFileSync(file,JSON.stringify({family,source:c.source,fresh:0,subject:b},null,2)+'\n');
   const item={id,family,owner:b.owner,arity:b.arity,shape:b.census,body:digest(b.body),fixture:addFile(file),prepareSeconds:b.prepareSeconds};
   report.subjects.push(item);selected.push({item,body:b.body});
  }
  save();
 }
 const modes={original:api.p143o_original,summary:api.p143o_summary,range:api.p143o_range},queries=[];
 for(const {item,body} of selected){
  for(const left of [1,4,64])for(const scenario of ['empty-env','actual-child-argument','env-first','env-last']){
   const n=1048576,at=scenario==='env-last'?(n+left-1)>>>0:n;
   const args=bendList(scenario==='actual-child-argument'?children(body).slice(0,1):[]);
   const env=bendList(scenario.startsWith('env-')?[{$:'NC_Binding',id:(0xffffffff-at)>>>0,word:'bound',kind:{$:'N_W64'}}]:[]);
   const q={id:'query-'+String(queries.length).padStart(3,'0'),subject:item.id,left,scenario,n,body,args,env};
   q.expected=api.p143o_original(body,args,env,n,left);assert.equal(typeof q.expected,'boolean');
   for(const fn of Object.values(modes))assert.equal(fn(body,args,env,n,left),q.expected);
   const copy=JSON.parse(JSON.stringify({body,args,env}));
   for(const fn of Object.values(modes))assert.equal(fn(copy.body,copy.args,copy.env,n,left),q.expected);
   const record={id:q.id,subject:item.id,n,left,scenario,expected:q.expected,arguments:digest(args),environment:env,allThreeEqual:true,reconstructedValuesEqual:true,
    schedule:'constructed; not captured production invocation',bodyFitsNbcSelectSize:item.shape.nodes<=32};
   report.queries.push(record);queries.push(q);
  }
 }
 report.semanticQueriesPassed=queries.length;report.semanticComplete=true;save();
 const permutations=[['original','summary','range'],['range','summary','original'],['summary','original','range'],['range','original','summary'],['original','range','summary'],['summary','range','original']];
 const calibrated=new Map();let stop=false;
 for(let round=0;round<permutations.length&&!stop;round++){
  const order=round%2?[...queries].reverse():queries;
  for(const q of order){
   if(elapsed()>budget-0.1){stop=true;break;}
   let repetitions=calibrated.get(q.id);
   if(repetitions===undefined){
    for(const fn of Object.values(modes))rowTime(fn,q,2);
    repetitions=1;let pilotSeconds;
    do{pilotSeconds=Math.max(...Object.values(modes).map(fn=>rowTime(fn,q,repetitions).seconds));if(pilotSeconds>=0.001||repetitions>=4096)break;repetitions*=4;}while(elapsed()<budget-0.5);
    repetitions=Math.max(1,Math.min(8192,Math.ceil(repetitions*0.002/Math.max(pilotSeconds,0.000001))));
    calibrated.set(q.id,repetitions);
   }
   const rows=[];
   for(const mode of permutations[round])rows.push({mode,...rowTime(modes[mode],q,repetitions)});
   const original=rows.find(r=>r.mode==='original').seconds;
   report.timings.push({query:q.id,round,order:permutations[round],rows,ratios:Object.fromEntries(rows.map(r=>[r.mode,r.seconds/original]))});
  }
  save();
 }
 report.timingComplete=!stop;report.timingBudgetStopped=stop;report.timingRoundsRequested=6;
 report.timingScope='Exploratory hosted microtiming; shared process/JIT/GC, no confidence interval, no unpaired aggregate headline. Each row measures full query including summary build and host call/check loop. Incomplete schedules remain visible.';
 report.complete=true;
}catch(error){report.error=String(error.stack||error);process.exitCode=1;}
finally{report.elapsedSeconds=elapsed();report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,controlsPassed:report.controlsPassed,semanticQueriesPassed:report.semanticQueriesPassed,timingRows:report.timings.length,timingComplete:report.timingComplete,error:report.error}));}
