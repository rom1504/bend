// Root-supervised diagnostic only; never use these clocks as performance data.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [attemptArg,outArg,catalogArg,...wanted]=process.argv.slice(2);assert(attemptArg&&outArg);
const root=path.resolve(import.meta.dirname,'../../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase64')+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=x=>createHash('sha256').update(x).digest('hex'),identity=file=>({file:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))});
const inputs=new Map(),pin=(file,want)=>{const x=identity(file);if(want)assert.equal(x.sha256,want.sha256);if(inputs.has(x.file))assert.deepEqual(inputs.get(x.file),x);inputs.set(x.file,x);return x;};
const report={kind:'phase64-discarded-child-type-differential',complete:false,pass:false,cases:[],scope:'Compare enclosing JDText, JDCallScan and layout worklists under actual guarded type arguments versus original eager reconstruction; also exact complete module bytes. Helpers may legitimately return different types because the unchanged child Ann replaces them. Lexical query counts are diagnostic, not timings or proof of arbitrary malformed input termination.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
try{
 const read=f=>JSON.parse(fs.readFileSync(f,'utf8'));report.attempt=pin(path.join(attemptArg,'attempt.json'));const raw=read(report.attempt.file);
 for(const k of Object.keys(process.env))if(k.startsWith('BEND_'))delete process.env[k];
 process.env.BEND_TYPED_API=raw.api.file;process.env.BEND_TYPED_RUNTIME=raw.runtime.file;process.env.BEND_BASE=raw.base.file;
 const workflowFile=path.resolve(import.meta.dirname,'../../../../development/workflow.mjs');pin(workflowFile);
 const {verifyAttempt}=await import(pathToFileURL(workflowFile));const attempt=await verifyAttempt(attemptArg);assert(attempt.checked&&attempt.config.strictExact);
 for(const k of ['api','runtime','base','node','bootstrapReport'])pin(attempt[k].file,attempt[k]);pin(import.meta.filename);pin(process.execPath);
 const driverFile=path.join(attempt.snapshot.root,'tools/typed-driver.mjs');pin(driverFile);
 const original=fs.readFileSync(attempt.api.file,'utf8'),parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};
 new Function('module','exports',parserSource)(parser,parser.exports);const parse=s=>parser.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'}),ast=parse(original);
 const names=['run_loop','$jd_lambda_child_type$','$jd_arm_child_type$','$j_layout_lambda_child_type$','$j_layout_arm_child_type$','$j_app_type$','$subst$','$j_arm_tel$','$j_specialize$','$wnf$','$tg$','$kid$','$nm$','$ix$','$dt$','$ks$','$j_layout_ctor$','$var$','$kt$','$all$','$atom$',
  '$jd_doc_body_lambda$','$jd_doc_body_live_lambda$','$jd_calls_lambda$','$jd_calls_match_other$','$jd_doc_match_emit_at$','$jd_doc_word_bind_type$','$j_layout_lam$','$j_layout_match$'];
 for(const n of names)assert.equal(ast.body.filter(x=>x.type==='FunctionDeclaration'&&x.id.name===n).length,1,n);assert(!original.includes('phase64DeadTypes'));
 const suffix=`
export const phase64DeadTypes=(()=>{
 let disabled=false,oracle=false,active=0,stats;
 const reset=()=>{stats={helpers:{},consumers:{},compared:0,comparedCharacters:0,queries:{outside:{},actual:{},oracle:{}}};};reset();
 const serialize=x=>JSON.stringify(x,(_,v)=>typeof v==='bigint'?{$bigint:String(v)}:v);
 const compare=(name,a,b)=>{const x=serialize(a),y=serialize(b);stats.comparedCharacters+=x.length;if(stats.comparedCharacters>67108864)throw Error('Dead-type diagnostic byte budget');if(x!==y)throw Error('Discarded-type consumer differs: '+name);stats.compared++;};
 // Explicit JS composition must force each Bend trampoline before using its result.
 const call=(fn,...args)=>run_loop(fn(...args));
 const ann=x=>call($tg$,x)==='Ann',child=t=>call($kid$,t,0);
 const oldLambda=(t,ty)=>call($j_app_type$,ty,call($var$,call($nm$,t),call($ix$,t)));
 const oldArm=(book,arm,tel,ret)=>call($j_arm_tel$,book,tel,ret);
 const oldLayoutLambda=(t,ty)=>call($subst$,call($kid$,ty,1),call($ix$,ty),call($var$,call($nm$,t),call($ix$,t)));
 const oldLayoutArm=(book,t,ty)=>call($j_arm_tel$,book,call($j_specialize$,book,call($dt$,call($j_layout_ctor$,book,call($wnf$,book,call($kid$,ty,0)),call($nm$,t))),call($ks$,call($wnf$,book,call($kid$,ty,0)))),call($kid$,ty,1));
 const helper=(name,prior,old,admit)=>(...args)=>{const h=stats.helpers[name]??={calls:0,admitted:0,fallback:0,forced:0};if(disabled||oracle){h.forced++;return old(...args);}if(++h.calls>100000)throw Error('Dead-type helper call budget');if(admit(...args))h.admitted++;else h.fallback++;return prior(...args);};
 $jd_lambda_child_type$=helper('direct-lambda',$jd_lambda_child_type$,oldLambda,t=>ann(child(t)));
 $jd_arm_child_type$=helper('direct-arm',$jd_arm_child_type$,oldArm,(book,arm)=>ann(arm));
 $j_layout_lambda_child_type$=helper('layout-lambda',$j_layout_lambda_child_type$,oldLayoutLambda,t=>ann(child(t)));
 $j_layout_arm_child_type$=helper('layout-arm',$j_layout_arm_child_type$,oldLayoutArm,(book,t)=>ann(child(t)));
 const query=(name,prior)=>(...args)=>{const q=stats.queries[oracle?'oracle':active?'actual':'outside'];q[name]=(q[name]??0)+1;return prior(...args);};
 $wnf$=query('wnf',$wnf$);$subst$=query('subst',$subst$);$j_app_type$=query('j_app_type',$j_app_type$);$j_arm_tel$=query('j_arm_tel',$j_arm_tel$);$j_specialize$=query('j_specialize',$j_specialize$);
 const consumer=(name,prior)=>(...args)=>{
  if(disabled||oracle||active)return prior(...args);
  stats.consumers[name]=(stats.consumers[name]??0)+1;active++;let actual,expected;
  try{actual=run_loop(prior(...args));oracle=true;try{expected=run_loop(prior(...args));}finally{oracle=false;}compare(name,actual,expected);return actual;}finally{active--;}
 };
 $jd_doc_body_lambda$=consumer('body-lambda',$jd_doc_body_lambda$);
 $jd_doc_body_live_lambda$=consumer('body-live-lambda',$jd_doc_body_live_lambda$);
 $jd_calls_lambda$=consumer('calls-lambda',$jd_calls_lambda$);
 $jd_calls_match_other$=consumer('calls-match',$jd_calls_match_other$);
 $jd_doc_match_emit_at$=consumer('body-match',$jd_doc_match_emit_at$);
 $jd_doc_word_bind_type$=consumer('word-bind',$jd_doc_word_bind_type$);
 $j_layout_lam$=consumer('layout-lambda',$j_layout_lam$);
 $j_layout_match$=consumer('layout-match',$j_layout_match$);
 const controls=()=>{
  const nil={$:'Nil'},cons=(head,tail=nil)=>({$:'Con',head,tail}),term=(tag,name='',id=0,quant=0,kids=nil)=>call($kt$,tag,name,id,quant,kids),abs=call($atom$,'Absent');
  const annBody=term('Ann','',0,0,cons(term('Var','x',7),cons(abs))),rawBody=term('Var','x',7),rewritten=term('Rwt','',0,0,cons(abs,cons(abs,cons(annBody))));
  const ty=call($all$,1,'x',7,abs,abs),result={raw:0,rewriteFallback:0,scans:0};
  for(const body of [rawBody,rewritten]){const t=term('Lam','x',7,1,cons(body));compare('raw-lambda-fallback',run_loop($jd_lambda_child_type$(t,ty)),run_loop(oldLambda(t,ty)));compare('raw-layout-fallback',run_loop($j_layout_lambda_child_type$(t,ty)),run_loop(oldLayoutLambda(t,ty)));result[body===rawBody?'raw':'rewriteFallback']++;}
  const odd=term('Odd','',7,0,cons(abs,cons(rawBody))),rawLambda=term('Lam','x',7,1,cons(rawBody));compare('non-All-layout-fallback',run_loop($j_layout_lambda_child_type$(rawLambda,odd)),run_loop(oldLayoutLambda(rawLambda,odd)));
  for(const fuel of [0,1,2,8]){const state={$:'JDCallScan',edges:nil,unknown:false,fuel,valid:true};run_loop($jd_calls_lambda$(nil,nil,term('Lam','x',7,1,cons(annBody)),ty,1,state));result.scans++;}
  for(const fields of [64,65]){let tel=abs;for(let i=0;i<fields;i++)tel=call($all$,1,'f'+i,i,abs,tel);const domain=term('ADT','Fixture'),mat=term('Mat','C',0,0,cons(annBody,cons(abs))),mty=call($all$,1,'v',9,domain,abs),state={$:'JDCallScan',edges:nil,unknown:false,fuel:1,valid:true};run_loop($jd_calls_match_other$(nil,nil,mat,mty,domain,1,state,tel));result.scans++;}
  return result;
 };
 return {reset,disable(value){disabled=value;},stats(){return JSON.parse(JSON.stringify(stats));},controls};
})();
`;
 parse(original+suffix);const apiFile=path.join(out,'diagnostic-api.mjs');fs.writeFileSync(apiFile,original+suffix,{flag:'wx'});report.derivative={parent:attempt.api,output:pin(apiFile),suffixSha256:hash(suffix),appendOnly:true,parserSha256:hash(parserSource)};
 const module=await import(pathToFileURL(apiFile));assert(!module.G,'Expected named checked B1');const hook=module.phase64DeadTypes;
 const D=await import(pathToFileURL(driverFile));assert.equal(D.apiPath,attempt.api.file);pin(D.directRuntimePath);
 let cases;
 if(catalogArg){pin(catalogArg);const c=read(catalogArg);assert(Array.isArray(c.cases));cases=c.cases.map(x=>({id:x.id,file:x.source?.file??x.file}));}
 else cases=[{id:'numeric-recurrence',file:path.join(root,'selfhost/tools/performance/phase37/fixtures-new/numeric-recurrence.bend')},{id:'test-map-set-ops',file:path.join(root,'selfhost/tools/performance/phase37/fixtures-historical/test-map-set-ops.bend')}];
 if(wanted.length)cases=cases.filter(x=>wanted.includes(x.id));assert(cases.length&&cases.length<=32);
 for(const spec of cases){const file=path.resolve(catalogArg?path.dirname(catalogArg):root,spec.file),row={id:spec.id,source:pin(file),pass:false};report.cases.push(row);save();
  try{hook.reset();hook.disable(false);const actual=await D.inspect(file,{mode:'library',backend:'direct',api:module.default});row.counts=hook.stats();row.observation={status:actual.status,checked:actual.checked,diagnostic:actual.diagnostic};assert.equal(actual.status,'ok',actual.diagnostic);assert.equal(actual.checked,true);assert(row.counts.compared>0,'No enclosing consumers compared');assert(Object.values(row.counts.helpers).some(x=>x.admitted>0),'No skipped child derivation');row.controls=hook.controls();
   hook.disable(true);const old=await D.inspect(file,{mode:'library',backend:'direct',api:module.default});assert.equal(old.status,'ok',old.diagnostic);assert.equal(old.checked,true);assert.equal(actual.code,old.code,'Full module differs from original eager child-type reconstruction');
   for(const f of [...actual.files,...old.files])pin(f);const output=path.join(out,spec.id+'.mjs');fs.writeFileSync(output,actual.code,{flag:'wx'});row.output=pin(output);row.rawOutputEqual=true;row.pass=true;
  }catch(error){row.error=String(error.stack??error);}save();console.log(JSON.stringify({id:row.id,pass:row.pass,counts:row.counts,error:row.error}));
 }
 await verifyAttempt(attemptArg);for(const x of inputs.values())assert.deepEqual(identity(x.file),x);report.complete=true;report.pass=report.cases.every(x=>x.pass);if(!report.pass)process.exitCode=1;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,cases:report.cases.length,error:report.error}));
