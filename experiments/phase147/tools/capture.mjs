// Freeze complete actual verifier inputs; no lowering/verification in JavaScript.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import * as S from './support.mjs';
const a=S.options();for(const key of ['baseline','cases','base','out'])assert(a[key],'Missing --'+key);
const out=S.output(a.out),inputs=[S.pin(import.meta.filename),S.pin(path.join(import.meta.dirname,'support.mjs')),S.pin(a.cases),S.pin(a.base)];
const report={kind:'phase147-verifier-input-capture',version:1,complete:false,inputs,rows:[],scope:'Current checked Bend pipeline produces actual raw/direct IR. All original bodies are verified before fixed top-and-spread selection. Captured whole functions retain all original metadata headers. Compiler family is a dependency-closed verifier workload, not a full compiler request.'};
const save=()=>S.save(out+'/report.json',report);save();
const count=Number(a.functions??6);assert(Number.isInteger(count)&&count>=2&&count<=16);
function census(fn){let statements=0,branches=0,calls=0;const todo=[fn.body];while(todo.length){for(const stmt of S.items(todo.pop())){
 statements++;if(stmt.$==='N111If'||stmt.$==='P113DIf'){branches++;todo.push(stmt.yes,stmt.no)}
 if(stmt.$==='N111Call'||stmt.$==='P113DCall'||(stmt.$==='P113DScalar'&&stmt.stmt.$==='N111Call'))calls++;
}}return{statements,branches,calls}}
function select(functions){
 const all=functions.map((fn,index)=>({index,function:fn,census:census(fn)}));
 if(all.length<=count)return all;
 const selected=new Set([...all].sort((a,b)=>b.census.branches-a.census.branches||b.census.statements-a.census.statements||a.index-b.index).slice(0,2).map(x=>x.index));
 for(let i=0;i<count-2;i++)selected.add(Math.round(i*(all.length-1)/Math.max(1,count-3)));
 for(let i=0;selected.size<count;i++)selected.add(i);
 return all.filter(x=>selected.has(x.index));
}
try{
 const baseline=await S.checked(a.baseline);inputs.push(...baseline.inputs);report.baseline=baseline.receipt.api;report.sourceIdentity=baseline.preparation.canonicalSourceIdentity;
 const api=baseline.api,cases=S.read(a.cases);assert(cases.kind==='phase147-verifier-capture-inputs'&&cases.complete);
 const started=performance.now(),seed=S.tag(api.p86_prepare(fs.realpathSync(a.base),fs.readFileSync(a.base,'utf8')),'P86PreparationReady').seed;
 report.basePreparationSeconds=(performance.now()-started)/1000;
 for(const fixture of cases.cases){
  S.verify(fixture.source);inputs.push(fixture.source);const row={name:fixture.name,source:fixture.source,scope:fixture.scope,complete:false};report.rows.push(row);save();
  let t=performance.now();const plan=S.tag(api.p86_plan(seed,fixture.source.file,fs.readFileSync(fixture.source.file,'utf8')),'P86PlanReady');row.frontendSeconds=(performance.now()-t)/1000;
  t=performance.now();const lowered=S.tag(api.p140or_lower(plan.request,api.p140or_empty()),'P140ORResult');row.lowerSeconds=(performance.now()-t)/1000;
  assert.equal(lowered.lowering.lowered.error,'');const direct=S.tag(lowered.lowering.lowered.program,'P113DProgram'),raw=S.tag(direct.original.program,'P111Program');
  t=performance.now();assert.equal(api.p111_verify_program(raw),'');
  const ids={$:'N111Ids',functions:api.p113e_originals(raw.segments,api.missing()),constructors:api.ns_ctor_index(raw.constructors,api.missing())};
  assert.equal(api.p113e_functions(direct.functions,ids,api.missing()),'');row.originalVerificationSeconds=(performance.now()-t)/1000;
  const segments=S.items(raw.segments),functions=S.items(direct.functions);
  const packet={kind:'phase147-complete-function-inputs',version:1,complete:true,family:fixture.name,source:fixture.source,
   segments:segments.map(x=>({...x,body:{$:'Nil'}})),constructors:S.items(raw.constructors),
   directHeaders:functions.map(x=>({...x,body:{$:'Nil'}})),raw:select(segments),direct:select(functions),
   selection:'Two greatest branch/statement counts plus declaration-order spread, filled from earliest remaining rows; complete bodies, all actual metadata headers.',
   counts:{raw:segments.length,direct:functions.length,constructors:S.items(raw.constructors).length},originalAccepted:true};
  const encoded=JSON.stringify(packet)+'\n';assert(Buffer.byteLength(encoded)<=32*1024**2,'Captured input exceeds32MiB bound');
  const file=path.join(out,fixture.name+'.json');fs.writeFileSync(file,encoded,{flag:'wx'});row.data=S.pin(file);row.counts=packet.counts;
  row.selected={raw:packet.raw.map(x=>({index:x.index,name:x.function.name,...x.census})),direct:packet.direct.map(x=>({index:x.index,name:x.function.name,...x.census}))};row.complete=true;save();
 }
 inputs.forEach(S.verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,families:report.rows.length,error:report.error}))}
