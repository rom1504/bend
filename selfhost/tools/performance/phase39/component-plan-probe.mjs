// Root-executed bounded diagnosis: checked API plus observation-only export.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../development/workflow.mjs';
const [attemptArg,sourceArg,outArg]=process.argv.slice(2);assert(attemptArg&&sourceArg&&outArg);
const out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out);
const id=file=>({file:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const attempt=await verifyAttempt(path.resolve(attemptArg)),apiFile=attempt.api.file;
const original=fs.readFileSync(apiFile,'utf8');
for(const name of ['j_l_def','j_component_plan','j_component_prefix','j_component_declaration'])assert(original.includes('function $'+name+'$('));
const instrumented=original+`
const $p39Plans=[],$p39OriginalDef=$j_l_def$;
$j_l_def$=function(book,d){
 const name=$dn$(d);
 if(['scan','warp','component.mix','component.dependent','component.back'].includes(name)){
  const orig=run_loop($lookup$(book,name));
  const inspect=x=>{const value=$dv$(x),nil={$:'Nil'},one={$:'Con',head:value,tail:nil},plan=run_loop($j_component_plan$(book,x));
   return {bodyTag:$tg$(value),bounded512:run_loop($j_u32_bounded$(one,512)),deep:run_loop($j_l_deep$(value,0)),refs:run_loop($j_component_refs$(one,name,1024,0)),
    eligible:run_loop($j_region_capture_eligible$(book,x)),prefix:run_loop($j_component_prefix$(book,nil,value,$dt$(x),run_loop($j_component_slots$(0,$da$(x))),x,0)),
    valid:$j_pure_valid$(plan),declarationBytes:run_loop($j_component_declaration$(book,x,plan)).length};};
  $p39Plans.push({name,selected:inspect(d),context:inspect(orig)});
 }
 return $p39OriginalDef(book,d);
};
export function componentPlanObservations(){return $p39Plans;}
`;
const diagnostic=path.join(out,'api-diagnostic.mjs');fs.writeFileSync(diagnostic,instrumented,{flag:'wx'});
process.env.BEND_TYPED_API=diagnostic;process.env.BEND_TYPED_RUNTIME=attempt.runtime.file;process.env.BEND_BASE=attempt.base.file;
const {inspect}=await import('../../typed-driver.mjs');
const result=await inspect(path.resolve(sourceArg),{mode:'library'});
const diag=await import(pathToFileURL(diagnostic));
const report={kind:'phase39-component-plan-probe',complete:result.status==='ok',inputs:[id(import.meta.filename),id(apiFile),id(attempt.runtime.file),id(attempt.base.file),id(sourceArg)],
 diagnostic:id(diagnostic),status:result.status,checked:result.checked,error:result.diagnostic,observations:diag.componentPlanObservations(),
 codeBytes:result.code?.length,scope:'Only j_l_def observations added to checked compiler API; emitted code is not executed and is not candidate evidence.'};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify(report));
if(!report.complete)process.exitCode=1;
