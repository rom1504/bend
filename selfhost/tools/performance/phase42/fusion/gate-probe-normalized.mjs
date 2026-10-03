// Root-run, observation-only compiler API diagnostic; no emission is retained.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
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
const instrumented=original+`
const $p42Shapes=[],$p42OriginalDef=$j_l_def$;
const $p42Gates=[];
let $p42NormalizeDomainDepth=0;
const $p42OriginalPrimitiveType=$j_primitive_type$;
$j_primitive_type$=function(book,ty,name){if($p42NormalizeDomainDepth>0&&name==='U32'&&$tg$(ty)==='Ref'&&$nm$(ty)==='U32')ty=run_loop($wnf$(book,ty));return $p42OriginalPrimitiveType(book,ty,name);};

function $p42Gate(name,fn){return function(...args){const value=run_loop(Reflect.apply(fn,null,args));const good=typeof value==='boolean'?value:typeof value==='string'?value.includes('private total scalar fusion')||value.length>0:true;if(!good&&$p42Gates.length<200)$p42Gates.push({gate:name,args:args.slice(1).map(arg=>arg&&typeof arg==='object'&&arg.$==='KTerm'?$p42Shape(arg):typeof arg==='string'||typeof arg==='number'?arg:arg&&typeof arg==='object'?JSON.stringify(arg).slice(0,300):arg)});return value;};}
$j_fusion_owner$=$p42Gate('owner',$j_fusion_owner$);
$j_fusion_producer$=$p42Gate('producer',$j_fusion_producer$);
$j_fusion_map$=$p42Gate('map',$j_fusion_map$);
$j_fusion_filter$=$p42Gate('filter',$j_fusion_filter$);
$j_fusion_fold$=$p42Gate('fold',$j_fusion_fold$);
$j_fusion_choose$=$p42Gate('choose',$j_fusion_choose$);
$j_fusion_scalar$=$p42Gate('scalar',$j_fusion_scalar$);
$j_fusion_pipeline$=$p42Gate('pipeline',$j_fusion_pipeline$);
$j_fusion_pipeline_defs$=$p42Gate('pipeline_defs',$j_fusion_pipeline_defs$);
const $p42OriginalPrefix=$j_fusion_root_prefix$;
$j_fusion_root_prefix$=function(book,t,ty,vars,at,left){++$p42NormalizeDomainDepth;let value;try{value=run_loop($p42OriginalPrefix(book,t,ty,vars,at,left));}finally{--$p42NormalizeDomainDepth;}if(value===''&&$p42Gates.length<200){const h=run_loop($j_strip$(t)),head=run_loop($wnf$(book,ty));$p42Gates.push({gate:'prefix',at,left,bodyTag:$tg$(h),type:$p42Shape(head),primitive:run_loop($j_primitive_type$(book,left===0?head:run_loop($kid$(head,0)),'U32'))});}return value;};
const $p42OriginalRoot=$j_region_root_done$;
$j_region_root_done$=function(book,d,state){const name=$dn$(d);if(['bench','pipeline','ordered_pipeline','modzero_pipeline'].includes(name)){$p42Gates.push({gate:'root-context',name,body:$p42Shape($dv$(d)),originalBody:$p42Shape($dv$(run_loop($lookup$(book,name)))),type:$p42Shape($dt$(d)),canonicalFusion:run_loop($j_fusion_root_prefix$(book,$dv$(run_loop($lookup$(book,name))),$dt$(run_loop($lookup$(book,name))),{$:'Nil'},0,$da$(d))),fusion:run_loop($j_fusion_root_prefix$(book,$dv$(d),$dt$(d),{$:'Nil'},0,$da$(d)))});}return $p42OriginalRoot(book,d,state);};

function $p42Shape(t,depth=0){t=run_loop(t);const row={tag:$tg$(t),name:$nm$(t),quantity:$qt$(t),id:$ix$(t)};if(depth<12){let xs=run_loop($ks$(t));row.kids=[];while(xs.$==='Con'){row.kids.push($p42Shape(xs.head,depth+1));xs=xs.tail;}}return row;}
$j_l_def$=function(book,d){if(['p37.list','dbl','keep_gt1','keep_gt1.at','suma','bench','chain.make','chain.keep','chain.keep.at','chain.bump','chain.fold','pipeline','retained'].includes($dn$(d))){const original=run_loop($lookup$(book,$dn$(d)));$p42Shapes.push({name:$dn$(d),type:$p42Shape($dt$(original)),body:$p42Shape($dv$(original))});}return $p42OriginalDef(book,d);};
export function listPlanObservations(){return $p42Shapes;}
export function fusionGateObservations(){return $p42Gates;}
`;
const diagnostic=path.join(out,'api-diagnostic.mjs');fs.writeFileSync(diagnostic,instrumented,{flag:'wx'});
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-probe.mjs'));
process.env.BEND_TYPED_API=diagnostic;process.env.BEND_TYPED_RUNTIME=attempt.runtime.file;process.env.BEND_BASE=attempt.base.file;
const {inspect}=await import('../../../typed-driver.mjs');const result=await inspect(path.resolve(sourceArg),{mode:'library'});
const diag=await import(pathToFileURL(diagnostic));
const report={kind:'phase42-fusion-shape-probe',mode:mode??'normalized-domain-diagnostic',complete:result.status==='ok',inputs:[id(path.join(out,'consumed-probe.mjs')),id(apiFile),id(attempt.runtime.file),id(attempt.base.file),id(sourceArg)],diagnostic:id(diagnostic),status:result.status,checked:result.checked,error:result.diagnostic,observations:diag.listPlanObservations(),gates:diag.fusionGateObservations(),codeBytes:result.code?.length,scope:'Read-only private planner/type observations; emitted output not candidate evidence.'};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,checked:report.checked,status:report.status,observations:report.observations.length,error:report.error}));if(!report.complete)process.exitCode=1;
