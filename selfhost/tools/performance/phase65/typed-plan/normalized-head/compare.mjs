// Diagnostic-only normalized annotation producer; target execution belongs to root.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [attemptArg,outArg,catalogArg,...wanted]=process.argv.slice(2);
assert(attemptArg&&outArg,'compare.mjs CHECKED_ATTEMPT NEW_OUTPUT [CATALOG [CASE ...]]');
const root=path.resolve(import.meta.dirname,'../../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase65')+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=x=>createHash('sha256').update(x).digest('hex');
const identity=f=>({file:fs.realpathSync(f),sha256:hash(fs.readFileSync(f)),bytes:fs.statSync(f).size});
const inputs=new Map(),pin=(f,want)=>{const r=identity(f);if(want){assert.equal(r.sha256,want.sha256);if(want.canonicalPath)assert.equal(r.file,want.canonicalPath);if(want.bytes!==undefined)assert.equal(r.bytes,want.bytes);}if(inputs.has(r.file))assert.deepEqual(r,inputs.get(r.file));inputs.set(r.file,r);return r;};
const read=f=>JSON.parse(fs.readFileSync(f,'utf8'));
const plain=x=>typeof x==='bigint'?{bigint:String(x)}:x&&typeof x==='object'?(Array.isArray(x)?x.map(plain):Object.fromEntries(Object.entries(x).map(([k,v])=>[k,plain(v)]))):x;
const revive=x=>x&&typeof x==='object'?(Object.keys(x).length===1&&typeof x.bigint==='string'?BigInt(x.bigint):Array.isArray(x)?x.map(revive):Object.fromEntries(Object.entries(x).map(([k,v])=>[k,revive(v)]))):x;
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const array=xs=>{const r=[];while(xs?.$==='Con'){assert(r.length<65536);r.push(xs.head);xs=xs.tail;}assert.equal(xs?.$,'Nil');return r;};
const report={kind:'phase65-normalized-head-producer-differential',complete:false,pass:false,cases:[],scope:'Diagnostic checked B1 only. Toggle the entire recursive annotation producer back to its exact original formula in the same image. Compare selected definition order, complete retained text index, complete per-definition call facts, SCC members/bounce flags, layout results, full modules and supplied value/refusal oracles. Annotation products themselves intentionally differ; this does not qualify public annotation API changes or establish arbitrary forged-term equivalence. Query counts are not timings.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
try{
 pin(import.meta.filename);pin(path.join(import.meta.dirname,'candidate.json'));report.attempt=pin(path.join(attemptArg,'attempt.json'));const raw=read(report.attempt.file);
 for(const k of Object.keys(process.env))if(k.startsWith('BEND_'))delete process.env[k];
 process.env.BEND_TYPED_API=raw.api.file;process.env.BEND_TYPED_RUNTIME=raw.runtime.file;process.env.BEND_BASE=raw.base.file;
 const workflow=path.resolve(import.meta.dirname,'../../../../development/workflow.mjs');pin(workflow);
 const {verifyAttempt}=await import(pathToFileURL(workflow));const attempt=await verifyAttempt(attemptArg);assert(attempt.checked&&attempt.config.strictExact);
 for(const k of ['api','runtime','base','node','bootstrapReport'])pin(attempt[k].file,attempt[k]);assert.equal(fs.realpathSync(process.execPath),fs.realpathSync(attempt.node.file));
 const candidate=read(path.join(import.meta.dirname,'candidate.json'));report.candidateSource=pin(path.join(attempt.snapshot.root,'src/check/annotate.bend'),candidate.after);
 const driver=path.join(attempt.snapshot.root,'tools/typed-driver.mjs');pin(driver);
 const original=fs.readFileSync(attempt.api.file,'utf8'),parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};
 new Function('module','exports',parserSource)(parser,parser.exports);const parse=s=>parser.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'}),ast=parse(original);
 const names=['annotate','ka_store_head','ka_node','ka_wrap','core_beta','wnf','cb','subst','j_type','jd_calls_fact','jd_component','jd_may_bounce','jd_definition_budget'];
 for(const n of ['run_loop',...names.map(n=>'$'+n+'$')])assert.equal(ast.body.filter(x=>x.type==='FunctionDeclaration'&&x.id.name===n).length,1,n);
 assert(!original.includes('phase65NormalizedHead'));
 const suffix=`
export const phase65NormalizedHead=(()=>{
 const call=(f,...xs)=>run_loop(f(...xs));let disabled=false,phase='outside',counts,limit=null;
 const reset=()=>{counts={annotation:0,storedHeads:0,queries:{}};phase='outside';};reset();
 const oldAnnotate=(e,ctx,t,ty)=>call($ka_wrap$,call($ka_node$,e,ctx,call($core_beta$,t),call($wnf$,call($cb$,e),ty)),ty);
 const annotate=$annotate$,store=$ka_store_head$,budget=$jd_definition_budget$;
 $annotate$=(...xs)=>{counts.annotation++;if(counts.annotation>1000000)throw Error('Annotation diagnostic budget');return disabled?oldAnnotate(...xs):annotate(...xs);};
 $ka_store_head$=(...xs)=>{counts.storedHeads++;return store(...xs);};
 $jd_definition_budget$=()=>limit===null?budget():limit;
 const query=(name,prior)=>(...xs)=>{const q=counts.queries[phase]??={};q[name]=(q[name]??0)+1;return prior(...xs);};
 $wnf$=query('wnf',$wnf$);$subst$=query('subst',$subst$);$j_type$=query('j_type',$j_type$);
 return {reset,disable:x=>{disabled=x;},limit:x=>{limit=x;},stats:()=>JSON.parse(JSON.stringify(counts)),
  phase(name,fn){const old=phase;phase=name;try{return fn();}finally{phase=old;}},
  facts(plan){const rows=[];let ds=plan.defs;while(ds.$==='Con'){const d=ds.head;if(d.kind==='Def')rows.push({name:d.name,fact:call($jd_calls_fact$,plan.book,d.name),component:call($jd_component$,plan.book,d.name),bounce:call($jd_may_bounce$,plan.book,d.name)});ds=ds.tail;}return rows;}
 };
})();
`;
 parse(original+suffix);const apiFile=path.join(out,'diagnostic-api.mjs');fs.writeFileSync(apiFile,original+suffix,{flag:'wx'});
 report.derivative={parent:attempt.api,output:pin(apiFile),appendOnly:true,suffixSha256:hash(suffix),parserSha256:hash(parserSource)};
 const M=await import(pathToFileURL(apiFile)),hook=M.phase65NormalizedHead;assert(!M.G,'Expected named checked B1');
 const D=await import(pathToFileURL(driver));assert.equal(D.apiPath,attempt.api.file);pin(D.directRuntimePath);
 const catalogFile=path.resolve(catalogArg||path.join(import.meta.dirname,'cases.json'));pin(catalogFile);const catalog=read(catalogFile);assert(Array.isArray(catalog.cases));
 let cases=catalog.cases;if(wanted.length)cases=cases.filter(x=>wanted.includes(x.id));assert(cases.length&&cases.length<=64&&(!wanted.length||cases.length===new Set(wanted).size));
 const observe=async(spec,disabled)=>{
  hook.reset();hook.disable(disabled);hook.limit(spec.definitionBudget??null);let plan=null,selectedDefinitions=null;const layouts=[];
  const api=Object.fromEntries(Object.entries(M.default).map(([name,fn])=>[name,typeof fn==='function'?(...xs)=>hook.phase(name,()=>fn(...xs)):fn]));
  if(spec.roots)api.jd_roots=(_book,library)=>{assert(library);return list(spec.roots);};
  const makePlan=api.jd_plan_selected;api.jd_plan_selected=(...xs)=>{assert.equal(plan,null);selectedDefinitions=array(xs[1]).map(d=>({name:d.name,kind:d.kind}));plan=makePlan(...xs);return plan;};
  const layout=api.j_layout_error;api.j_layout_error=(...xs)=>{const value=layout(...xs);layouts.push(value);return value;};
  const result=await D.inspect(spec.source.file,{mode:'library',backend:'direct',api});const counts=hook.stats();
  const facts=plan?{error:plan.error,selectedDefinitions,definitions:array(plan.defs).map(d=>({name:d.name,kind:d.kind})),texts:plain(plan.texts),calls:plain(hook.facts(plan))}:null;
  for(const f of result.files??[])pin(f);
  return{result,counts,facts,layouts,observation:Object.fromEntries(['status','phase','checked','diagnostic','exitCode'].map(k=>[k,result[k]??null]))};
 };
 for(const spec0 of cases){const sourceFile=spec0.source?.file??spec0.file,spec={...spec0,source:pin(path.resolve(path.dirname(catalogFile),sourceFile))},row={id:spec.id,source:spec.source,roots:spec.roots,definitionBudget:spec.definitionBudget,pass:false};report.cases.push(row);save();
  try{const actual=await observe(spec,false),old=await observe(spec,true);row.actual=actual.observation;row.old=old.observation;row.queries={actual:actual.counts,old:old.counts};
   assert.deepEqual(actual.observation,old.observation,'Status/diagnostic mismatch');assert.deepEqual(actual.layouts,old.layouts,'Layout refusal mismatch');assert.deepEqual(actual.facts,old.facts,'Plan retained output/call/SCC mismatch');row.planFactsEqual=true;
   for(const name of [...(spec.removedAliases??[]),...(spec.removedValues??[])]){assert(actual.facts?.selectedDefinitions.some(d=>d.name===name),'Expected initial selection: '+name);assert(!actual.facts.definitions.some(d=>d.name===name),'Expected pruned definition: '+name);}
   if(spec.status)assert.equal(actual.result.status,spec.status);if(spec.diagnosticIncludes)assert(actual.result.diagnostic?.includes(spec.diagnosticIncludes),'Expected refusal missing');
   if(actual.result.status==='ok'){
    assert.equal(actual.result.checked,true);assert.equal(actual.result.code,old.result.code,'Full module differs');assert(actual.counts.storedHeads>0,'Candidate producer not reached');assert.equal(old.counts.storedHeads,0,'Original producer oracle still retained heads');row.rawOutputEqual=true;
    row.outputs=[];row.oracles=[];
    for(const [role,result]of [['candidate',actual.result],['original',old.result]]){const file=path.join(out,spec.id+'-'+role+'.mjs');fs.writeFileSync(file,result.code,{flag:'wx'});row.outputs.push({role,...pin(file)});if(spec.points?.length){const module=(await import(pathToFileURL(file))).default;for(const point of spec.points){const value=plain(module[point.name](...revive(point.args)));assert.deepEqual(value,point.expected,role+': '+point.name);row.oracles.push({role,name:point.name,args:point.args,value});}}}
   }else assert(spec.status==='error','Unexpected equal failure does not qualify source');
   row.pass=true;
  }catch(error){row.error=String(error.stack??error);}save();console.log(JSON.stringify({id:row.id,pass:row.pass,actual:row.actual,queries:row.queries,error:row.error}));
 }
 await verifyAttempt(attemptArg);for(const x of inputs.values())assert.deepEqual(identity(x.file),x);report.complete=true;report.pass=report.cases.every(x=>x.pass);if(!report.pass)process.exitCode=1;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,cases:report.cases.length,error:report.error}));
