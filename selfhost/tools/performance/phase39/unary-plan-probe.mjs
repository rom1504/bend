// Root-executed bounded diagnosis: checked API plus observation-only export.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../development/workflow.mjs';
const [attemptArg,sourceArg,outArg]=process.argv.slice(2);assert(attemptArg&&sourceArg&&outArg);
const out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out);
const id=file=>({file:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const attempt=await verifyAttempt(path.resolve(attemptArg)),apiFile=attempt.api.file;
const original=fs.readFileSync(apiFile,'utf8');
const names=['j_producer_plan','j_producer_shape','j_producer_unary_shape','j_producer_unary_pure','j_producer_unary_zero','j_producer_unary_call','j_producer_unary_helper','j_producer_unary_done','j_region_helper'];
for(const name of names)assert(original.includes('function $'+name+'$('));
let appended='\nconst $p39UnaryPlans=[];\n';
for(const name of names){const owner=name==='j_producer_unary_done'?'$dn$(args[0])':['j_producer_unary_call','j_producer_unary_helper'].includes(name)?'args[4]':'$dn$(args[1])';
 appended+=`const $p39Original_${name}=$${name}$;
$${name}$=function(...args){const name=${owner},result=run_loop($p39Original_${name}(...args));
 if(['p37.expr','p37.expr.pick','unary.first','unary.last','unary.middle','unary.pick_middle'].includes(name)){
  const row={stage:${JSON.stringify(name)},name,valid:$j_region_valid$(result),fuel:$j_region_fuel$(result),term:$tg$($j_region_term$(result))};
  let ds=$j_region_helpers$(result);row.helpers=[];while(ds.$==='Con'){row.helpers.push({name:$dn$(ds.head),tag:$tg$($dv$(ds.head))});ds=ds.tail;}
  ${['j_producer_plan','j_producer_shape','j_producer_unary_shape'].includes(name)?`const d=args[1],value=$dv$(d),nil={$:'Nil'},one={$:'Con',head:value,tail:nil};
   const succ=run_loop($j_strip$($kid$(run_loop($j_strip$($kid$(run_loop($j_strip$(value)),1))),0)));
   const body=run_loop($j_call_spine$(run_loop($j_nat_loop_unwrap$(succ)),nil));
   row.shape={nat:run_loop($j_nat_shape$(args[0],d,true)),signature:run_loop($j_producer_signature$(args[0],$dt$(d),$da$(d))),refs:run_loop($j_component_refs$(one,name,1024,0)),
    succ:$tg$(succ),body:$tg$(body),callee:$nm$(body),args:run_loop($terms_len$($ks$(body))),child:run_loop($j_producer_unary_index$($ks$(body),name,$ix$(succ),$da$(d),0))};`:''}
  $p39UnaryPlans.push(row);
 }return result;};\n`;
}
const instrumented=original+appended+'\nexport function unaryPlanObservations(){return $p39UnaryPlans;}\n';
const diagnostic=path.join(out,'api-diagnostic.mjs');fs.writeFileSync(diagnostic,instrumented,{flag:'wx'});
process.env.BEND_TYPED_API=diagnostic;process.env.BEND_TYPED_RUNTIME=attempt.runtime.file;process.env.BEND_BASE=attempt.base.file;
const {inspect}=await import('../../typed-driver.mjs');
const result=await inspect(path.resolve(sourceArg),{mode:'library'});
const diag=await import(pathToFileURL(diagnostic));
const report={kind:'phase39-unary-plan-probe',complete:result.status==='ok',inputs:[id(import.meta.filename),id(apiFile),id(attempt.runtime.file),id(attempt.base.file),id(sourceArg)],
 diagnostic:id(diagnostic),status:result.status,checked:result.checked,error:result.diagnostic,observations:diag.unaryPlanObservations(),
 codeBytes:result.code?.length,scope:'Only private producer planner observations added to checked compiler API; emitted code is not executed and is not candidate evidence.'};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify(report));
if(!report.complete)process.exitCode=1;
