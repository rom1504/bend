// Diagnostic API overlay only. Never installs source or records favorable timings.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';import {createHash} from 'node:crypto';
import {verifyAttempt} from '../../../development/workflow.mjs';
const[attemptArg,sourceArg,outArg]=process.argv.slice(2);assert(attemptArg&&sourceArg&&outArg,'usage: trace-planner.mjs ATTEMPT SOURCE_BEND NEW_OUT');const out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out);
const identity=file=>({path:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const attempt=await verifyAttempt(path.resolve(attemptArg));const original=fs.readFileSync(attempt.api.file,'utf8');
const reportFile=path.join(out,'observations.json'),factsFile=path.join(out,'source-facts.json');
const addition=`
const $p43TraceFs=await import('node:fs');
const $p43TraceReport=${JSON.stringify(reportFile)},$p43TraceFacts=${JSON.stringify(factsFile)};
const $p43TraceEvents=[];let $p43TraceCount=0,$p43TraceDumped=false,$p43TraceActive='';
function $p43TraceArray(xs){const a=[];for(xs=run_loop(xs);xs.$==='Con';xs=run_loop(xs.tail))a.push(run_loop(xs.head));return a;}
function $p43TraceSave(stage){$p43TraceFs.writeFileSync($p43TraceReport,JSON.stringify({kind:'phase43-planner-trace',stage,count:$p43TraceCount,events:$p43TraceEvents},null,2)+'\\n');}
function $p43TraceEvent(kind,detail){const row={seq:++$p43TraceCount,kind,...detail};if($p43TraceEvents.length<10000)$p43TraceEvents.push(row);if($p43TraceCount<=100||$p43TraceCount%100===0)process.stderr.write(JSON.stringify(row)+'\\n');if($p43TraceCount%25===0)$p43TraceSave('running');if($p43TraceCount>=10000){$p43TraceSave('event-limit');throw new Error('PHASE43_DIAGNOSTIC_EVENT_LIMIT');}}
function $p43TraceShape(t,budget,depth=0){if(--budget.left<0||depth>128)return {truncated:true};t=run_loop(t);const r={tag:$tg$(t),name:$nm$(t),id:$ix$(t),quantity:$qt$(t),removed:$p43TraceArray($rm$(t))};r.kids=$p43TraceArray($ks$(t)).map(x=>$p43TraceShape(x,budget,depth+1));return r;}
function $p43TraceDump(book,defs){if($p43TraceDumped)return;$p43TraceDumped=true;const rows=[];let total=0;for(const d of $p43TraceArray(defs)){const budget={left:4096};const row={name:$dn$(d),kind:$dk$(d),arity:$da$(d),templates:$dx$(d),native:$db$(d),unsafe:$du$(d),type:$p43TraceShape($dt$(d),budget),value:$p43TraceShape($dv$(d),budget)};row.truncated=budget.left<0;total+=4096-Math.max(0,budget.left);rows.push(row);if(total>150000){rows.push({truncatedDefinitions:true});break;}}$p43TraceFs.writeFileSync($p43TraceFacts,JSON.stringify({kind:'phase43-preplanner-kdef-facts',scope:'original checked source IR before planner transformations; ids and quantities exact; subtree/total bounds explicit',definitions:rows},null,2)+'\\n');$p43TraceEvent('facts-written',{definitions:rows.length,nodes:total});}
const $p43OldProgram=$j_program_selected$;
$j_program_selected$=function(book,defs){$p43TraceDump(book,defs);return $p43OldProgram(book,defs);};
const $p43OldContext=$j_plan_context$;
$j_plan_context$=function(book,defs){$p43TraceDump(book,defs);$p43TraceEvent('context-start',{});try{const v=$p43OldContext(book,defs);$p43TraceEvent('context-end',{});return v;}catch(e){$p43TraceEvent('context-error',{error:String(e)});$p43TraceSave('error');throw e;}};
const $p43OldPlan=$j_component_plan$;
$j_component_plan$=function(book,d){const name=$dn$(d);$p43TraceEvent('component-plan-start',{name});try{const v=$p43OldPlan(book,d);$p43TraceEvent('component-plan-end',{name,valid:$j_pure_valid$(v),fuel:$j_pure_fuel$(v)});return v;}catch(e){$p43TraceEvent('component-plan-error',{name,error:String(e)});$p43TraceSave('error');throw e;}};
const $p43OldDecl=$j_component_declaration$;
$j_component_declaration$=function(book,d,pure){const name=$dn$(d),prev=$p43TraceActive;$p43TraceActive=name;$p43TraceEvent('component-declaration-start',{name});try{const v=$p43OldDecl(book,d,pure);$p43TraceEvent('component-declaration-end',{name,bytes:v.length});return v;}finally{$p43TraceActive=prev;}};
const $p43OldLeaf=$j_linear_leaf$;
$j_linear_leaf$=function(book,env,t,d){$p43TraceEvent('linear-leaf-start',{name:$dn$(d),tag:$tg$(t)});const v=$p43OldLeaf(book,env,t,d);$p43TraceEvent('linear-leaf-end',{name:$dn$(d),tag:$tg$(t),accepted:v});return v;};
const $p43OldFinish=$j_linear_finish$;
$j_linear_finish$=function(book,env,t,ty,d,phase){$p43TraceEvent('linear-finish-start',{name:$dn$(d),tag:$tg$(t),phase});const v=$p43OldFinish(book,env,t,ty,d,phase);$p43TraceEvent('linear-finish-end',{name:$dn$(d),tag:$tg$(t),phase,bytes:v.length});return v;};
if(typeof $j_linear_u32_prefix$==='function'){const $p43OldScalar=$j_linear_u32_prefix$;
$j_linear_u32_prefix$=function(book,env,t,fuel){$p43TraceEvent('u32-prefix-start',{owner:$p43TraceActive,tag:$tg$(t),name:$nm$(t),fuel});const v=$p43OldScalar(book,env,t,fuel);$p43TraceEvent('u32-prefix-end',{owner:$p43TraceActive,tag:$tg$(t),fuel,accepted:v});return v;};}
export function phase43PlannerTraceFinish(stage){$p43TraceSave(stage);return {count:$p43TraceCount,events:$p43TraceEvents};}
`;
const diagnostic=path.join(out,'api-diagnostic.mjs');fs.writeFileSync(diagnostic,original+addition,{flag:'wx'});fs.copyFileSync(import.meta.filename,path.join(out,'consumed-trace.mjs'));fs.writeFileSync(path.join(out,'inputs.json'),JSON.stringify({kind:'phase43-planner-trace-inputs',inputs:[attempt.api.file,attempt.runtime.file,attempt.base.file,path.resolve(sourceArg),path.join(out,'consumed-trace.mjs')].map(identity),diagnostic:identity(diagnostic)},null,2)+'\n',{flag:'wx'});
process.env.BEND_TYPED_API=diagnostic;process.env.BEND_TYPED_RUNTIME=attempt.runtime.file;process.env.BEND_BASE=attempt.base.file;
const {inspect}=await import('../../../typed-driver.mjs');let result;try{result=await inspect(path.resolve(sourceArg),{mode:'library'});}catch(e){result={status:'exception',checked:false,diagnostic:String(e?.stack??e)};}
const api=await import(pathToFileURL(diagnostic));const observations=api.phase43PlannerTraceFinish(result.status==='ok'?'completed':'failed');const report={kind:'phase43-planner-trace-completion',complete:result.status==='ok',status:result.status,checked:result.checked,error:result.diagnostic,count:observations.count,codeBytes:result.code?.length};fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify(report));if(!report.complete)process.exitCode=1;
