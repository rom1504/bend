// Root-run, observation-only compiler API diagnostic; no emission is retained.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../development/workflow.mjs';
const [attemptArg,sourceArg,outArg,mode]=process.argv.slice(2);assert(attemptArg&&sourceArg&&outArg);
const out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out);
const id=file=>({file:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const attempt=await verifyAttempt(path.resolve(attemptArg)),apiFile=attempt.api.file;
const original=fs.readFileSync(apiFile,'utf8');
const baseOverlay=mode==='base-layout'?`
$j_list_ground_type$=function(book,ty){const head=run_loop($wnf$(book,ty)),d=run_loop($lookup$(book,'List'));return run_loop($j_list_ground_head$(book,head))&&$dk$(d)==='ADT'&&$db$(d)&&$dx$(d)===0&&$da$(d)===2&&run_loop($j_region_def_count$($dc$(d)))===2&&run_loop($j_list_ground_kind$(run_loop($wnf$(book,run_loop($j_specialize$(book,$dt$(d),$ks$(head)))))))&&run_loop($j_list_ground_ctor$(book,run_loop($lookup$($dc$(d),'Nil')),head,0))&&run_loop($j_list_ground_ctor$(book,run_loop($lookup$($dc$(d),'Con')),head,2));};
$j_list_ground_ctor$=function(book,c,ty,fields){return $dk$(c)==='Ctr'&&$db$(c)&&$dx$(c)===0&&$da$(c)===fields&&run_loop($j_list_ground_fields$(book,run_loop($j_specialize$(book,$dt$(c),$ks$(ty))),fields));};
$j_list_ground_fields$=function(book,tel,left){const h=run_loop($wnf$(book,tel));if(left===0)return run_loop($j_list_ground_head$(book,h));return $tg$(h)==='All'&&$qt$(h)===1&&(left===2?run_loop($j_primitive_type$(book,run_loop($wnf$(book,run_loop($kid$(h,0)))),'U32')):run_loop($j_list_ground_head$(book,run_loop($wnf$(book,run_loop($kid$(h,0)))))))&&run_loop($j_list_ground_fields$(book,run_loop($kid$(h,1)),left-1));};
const $p40OldPlan=$j_component_plan$;
$j_component_plan$=function(book,d){const h=run_loop($wnf$(book,$dt$(d))),nil={$:'Nil'},one={$:'Con',head:$dv$(d),tail:nil};if(!run_loop($j_list_ground_type$(book,run_loop($kid$(h,0)))))return $p40OldPlan(book,d);const fail={$:'JPure',defs:nil,fuel:0,valid:false};return $dk$(d)==='Def'&&!$db$(d)&&$dx$(d)===0&&$da$(d)>0&&$da$(d)<=8&&$tg$(h)==='All'&&run_loop($j_u32_bounded$(one,512))&&!run_loop($j_l_deep$($dv$(d),0))&&run_loop($j_component_refs$(one,$dn$(d),1024,0))>0&&run_loop($j_region_capture_eligible$(book,d))&&run_loop($j_component_prefix$(book,nil,$dv$(d),$dt$(d),run_loop($j_component_slots$(0,$da$(d))),d,0))?run_loop($j_component_closed$(d,run_loop($j_pure_graph$(book,d,{$:'JPure',defs:nil,fuel:32768,valid:true})))):fail;};
const $p40OldMatch=$j_component_match$;
$j_component_match$=function(book,env,t,ty,slots,d,depth){if(slots.$!=='Con')return false;const arg=run_loop($wnf$(book,run_loop($kid$(ty,0))));if(!run_loop($j_list_ground_type$(book,arg)))return $p40OldMatch(book,env,t,ty,slots,d,depth);const owner=run_loop($lookup$(book,$nm$(arg))),c=run_loop($lookup$($dc$(owner),$nm$(t)));return $tg$(t)==='Mat'&&run_loop($j_l_name$(t))===''&&run_loop($terms_len$($ks$(t)))===2&&$dk$(c)==='Ctr'&&run_loop($j_component_prefix$(book,env,run_loop($kid$(t,0)),run_loop($j_arm_type$(book,ty,$nm$(t))),run_loop($j_component_fields$(slots.head,$da$(c),slots.tail)),d,depth+1))&&run_loop($j_component_prefix$(book,env,run_loop($kid$(t,1)),ty,slots,d,depth+1));};
`: "";
const instrumented=original+baseOverlay+`
const $p40Plans=[],$p40OriginalDef=$j_l_def$;
function $p40Shape(t,depth=0){t=run_loop(t);const row={tag:$tg$(t),name:$nm$(t),quantity:$qt$(t),id:$ix$(t),removed:run_loop($rm$(t))};
 if(depth<4){let xs=run_loop($ks$(t));row.kids=[];while(xs.$==='Con'&&row.kids.length<4){row.kids.push($p40Shape(xs.head,depth+1));xs=xs.tail;}}return row;}
$j_l_def$=function(book,d){const name=$dn$(d);
 if(['p37.list','dbl','keep_gt1','keep_gt1.at','suma','bench','ground.make','ground.twice','ground.select','ground.choose','ground.add','chain.make','chain.twice','chain.select','chain.choose','chain.add','ground_bench','chain_bench'].includes(name)){
  const orig=run_loop($lookup$(book,name)),nil={$:'Nil'};
  const inspect=x=>{const value=$dv$(x),one={$:'Con',head:value,tail:nil},plan=run_loop($j_component_plan$(book,x));
   const first=run_loop($wnf$(book,$kid$(run_loop($wnf$(book,$dt$(x))),0))),result=run_loop($j_fold_root_result$(book,$dt$(x),$da$(x)));
   const listTy=$nm$(first)==='List'?first:result,owner=run_loop($lookup$(book,'List'));
   const ctors=['Nil','Con'].map(n=>{const c=run_loop($lookup$($dc$(owner),n)),tel=run_loop($j_specialize$(book,$dt$(c),$ks$(listTy)));
    return {name:n,arity:$da$(c),erased:$dx$(c),native:$db$(c),type:$p40Shape($dt$(c)),specialized:$p40Shape(tel),accepted:run_loop($j_list_ground_ctor$(book,c,listTy,n==='Nil'?0:2))};});
   return {bodyTag:$tg$(value),arity:$da$(x),first:$p40Shape(first),result:$p40Shape(result),listOwner:{arity:$da$(owner),erased:$dx$(owner),native:$db$(owner),type:$p40Shape($dt$(owner))},ctors,
    listHead:run_loop($j_list_ground_head$(book,listTy)),listType:run_loop($j_list_ground_type$(book,listTy)),listKind:$p40Shape(run_loop($wnf$(book,run_loop($j_specialize$(book,$dt$(owner),$ks$(listTy)))))),
    eligible:run_loop($j_region_capture_eligible$(book,x)),prefix:run_loop($j_component_prefix$(book,nil,value,$dt$(x),run_loop($j_component_slots$(0,$da$(x))),x,0)),
    pure:$j_pure_valid$(run_loop($j_pure_graph$(book,x,{$:'JPure',defs:nil,fuel:32768,valid:true}))),
    plan:$j_pure_valid$(plan),declarationBytes:run_loop($j_component_declaration$(book,x,plan)).length};};
  $p40Plans.push({name,selected:inspect(d),context:inspect(orig)});
 }return $p40OriginalDef(book,d);};
export function listPlanObservations(){return $p40Plans;}
`;
const diagnostic=path.join(out,'api-diagnostic.mjs');fs.writeFileSync(diagnostic,instrumented,{flag:'wx'});
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-probe.mjs'));
process.env.BEND_TYPED_API=diagnostic;process.env.BEND_TYPED_RUNTIME=attempt.runtime.file;process.env.BEND_BASE=attempt.base.file;
const {inspect}=await import('../../typed-driver.mjs');const result=await inspect(path.resolve(sourceArg),{mode:'library'});
const diag=await import(pathToFileURL(diagnostic));
const report={kind:'phase40-list-plan-probe',mode:mode??'observations',complete:result.status==='ok',inputs:[id(path.join(out,'consumed-probe.mjs')),id(apiFile),id(attempt.runtime.file),id(attempt.base.file),id(sourceArg)],diagnostic:id(diagnostic),status:result.status,checked:result.checked,error:result.diagnostic,observations:diag.listPlanObservations(),codeBytes:result.code?.length,scope:'Read-only private planner/type observations; emitted output not candidate evidence.'};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,checked:report.checked,status:report.status,observations:report.observations.length,error:report.error}));if(!report.complete)process.exitCode=1;
