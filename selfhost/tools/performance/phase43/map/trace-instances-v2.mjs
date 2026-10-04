// Diagnostic API overlay only: root executes serially under bounded supervision.
// quick stops after collection; full checks/emits the selected root then stops.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';
import {verifyAttempt} from '../../../development/workflow.mjs';
const [attemptArg,sourceArg,rootName,outArg,mode='quick']=process.argv.slice(2);assert(outArg&&['quick','full'].includes(mode),'trace-instances-v1.mjs ATTEMPT SOURCE ROOT NEW_OUT [quick|full]');
const out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out);const attempt=await verifyAttempt(path.resolve(attemptArg)),reportFile=path.join(out,'report.json'),original=fs.readFileSync(attempt.api.file,'utf8');
const identity=file=>({path:fs.realpathSync(file),bytes:fs.statSync(file).size,sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const addition=`
const $p43IFs=await import('node:fs'),$p43IReport={kind:'phase43-instance-admission-trace',mode:${JSON.stringify(mode)},complete:false,events:[]};
function $p43ISave(stage,detail={}){Object.assign($p43IReport,{stage,...detail});$p43IFs.writeFileSync(${JSON.stringify(reportFile)},JSON.stringify($p43IReport,null,2)+'\\n');}
function $p43IArray(xs){const rows=[];for(xs=run_loop(xs);xs.$==='Con';xs=run_loop(xs.tail)){assertBound(rows.length<128);rows.push(run_loop(xs.head));}return rows;}
function assertBound(ok){if(!ok)throw new Error('PHASE43_INSTANCE_DIAGNOSTIC_ROW_LIMIT');}
function $p43IShape(t){t=run_loop(t);return {tag:$tg$(t),name:$nm$(t),id:$ix$(t),quantity:$qt$(t),kids:run_loop($terms_len$($ks$(t)))};}
const $p43IStepOriginal=$j_erased_instance_step$,$p43IArgOriginal=$j_erased_instance_arg$,$p43IScanOriginal=$j_erased_instance_scanned$;
function $p43IProofStep(row){assertBound(($p43IReport.proofSteps??=[]).length<256);$p43IReport.proofSteps.push(row);$p43ISave('proof-step');}
$j_erased_instance_step$=function(book,env,d,body,ty,args,slots,prefix,fuel){
 const f=run_loop,head=f($wnf$(book,ty)),term=f($j_strip$(body)),remaining=$da$(d)-prefix;
 const row={kind:'prefix',name:$dn$(d),prefix,fuel,type:$p43IShape(head),body:$p43IShape(term),bodyFactory:f($j_l_name$(term)),remaining,args:f($terms_len$(args))};
 if($tg$(head)!=='All'||$qt$(head)!==0){row.signature=f($j_pure_signature$(book,head,remaining));row.domains=[];let cursor=head;for(let i=0;i<remaining&&$tg$(cursor)==='All';i++){const domain=f($wnf$(book,f($kid$(cursor,0))));row.domains.push({at:i,quantity:$qt$(cursor),type:$p43IShape(domain),pure:f($j_pure_type$(book,domain))});cursor=f($wnf$(book,f($kid$(cursor,1))));}row.result={type:$p43IShape(cursor),pure:f($j_pure_type$(book,cursor))};}
 $p43IProofStep(row);return $p43IStepOriginal(book,env,d,body,ty,args,slots,prefix,fuel);
};
$j_erased_instance_arg$=function(book,env,d,body,ty,args,slots,prefix,fuel){const f=run_loop,values=$p43IArray(args),arg=values[0],canonical=f($wnf$(book,arg)),actual=f($wnf$(book,f($j_erased_arg_type$(book,canonical)))),expected=f($wnf$(book,f($kid$(ty,0))));$p43IProofStep({kind:'argument',name:$dn$(d),prefix,raw:$p43IShape(arg),canonical:$p43IShape(canonical),actual:$p43IShape(actual),expected:$p43IShape(expected),closed:f($j_erased_closed_arg$(book,arg)),exactKind:f($exact_term$(actual,expected))});return $p43IArgOriginal(book,env,d,body,ty,args,slots,prefix,fuel);};
$j_erased_instance_scanned$=function(book,env,d,body,ty,arg,rest,slots,prefix,r){$p43IProofStep({kind:'runtime-absence',name:$dn$(d),prefix,binder:$ix$(body),scanResult:run_loop(r).$});return $p43IScanOriginal(book,env,d,body,ty,arg,rest,slots,prefix,r);};
const $p43IOriginalErased=$j_erased_instance$;
$j_erased_instance$=function(book,env,spine){const name=$nm$(spine),d=run_loop($lookup$(book,name));$p43ISave('erased-call-start',{current:name,initial:{kind:$dk$(d),native:$db$(d),arity:$da$(d),templates:$dx$(d),args:run_loop($terms_len$($ks$(spine))),bodyBound:run_loop($j_u32_bounded$({$:'Con',head:$dv$(d),tail:{$:'Nil'}},4096))}});const result=run_loop($p43IOriginalErased(book,env,spine));assertBound($p43IReport.events.length<2048);$p43IReport.events.push({name,args:run_loop($terms_len$($ks$(spine))),result:result.$});$p43ISave('erased-call-end',{current:name});return result;};
$j_library_selected$=function(book,defs){
 const f=run_loop,root=f($lookup$(book,${JSON.stringify(rootName)})),rootFacts={name:$dn$(root),kind:$dk$(root),arity:$da$(root),templates:$dx$(root),native:$db$(root),type:$p43IShape($dt$(root)),body:$p43IShape($dv$(root))};
 $p43ISave('root',{root:rootFacts});
 const signature=f($j_region_signature$(book,$dt$(root),$da$(root))),result=f($j_region_scalar$(book,f($j_fold_root_result$(book,$dt$(root),$da$(root))))),hasErased=f($j_instance_has_erased$(book,{$:'Con',head:$dv$(root),tail:{$:'Nil'}},2048));
 $p43ISave('root-gates',{signature,result,hasErased});
 if(signature&&result&&hasErased){
  $p43ISave('collection-start');const state=f($j_instances_collect$(book,{$:'Con',head:$dv$(root),tail:{$:'Nil'}},{$:'JInstances',rows:{$:'Nil'},sources:{$:'Con',head:root,tail:{$:'Nil'}},fuel:1048576,valid:true}));
  const valid=f($j_instances_valid$(state)),facts=$p43IArray(f($j_instances_rows$(state))),sources=$p43IArray(f($j_instances_sources$(state)));
  $p43ISave('collection-end',{valid,fuel:f($j_instances_fuel$(state)),facts:facts.map(d=>({name:$dn$(d),erased:$da$(d),runtimeArity:$dx$(d),type:$p43IShape($dt$(d)),body:$p43IShape($dv$(d))})),sources:sources.map(d=>$dn$(d))});
  if(valid&&${JSON.stringify(mode)}==='full'){
   const rows=f($j_instance_aliases$(f($j_instances_sources$(state)),f($j_instances_rows$(state))));$p43ISave('exact-start');const exact=f($j_instance_all_exact$(book,rows));$p43ISave('exact-end',{exact});
   if(exact){$p43ISave('rewrite-start');const raw=f($j_instance_view_defs$(book,rows,rows,0)),view=f($List$append$(raw,f($j_instance_attach$(book,rows,{$:'Con',head:root,tail:{$:'Nil'}}))));
    const at=f($j_instance_source_index$(rows,root,0)),name=f($j_instance_name$(at));$p43ISave('raw-pure-start',{rootInstance:name});const pure=f($j_pure_graph$(view,f($lookup$(view,name)),{$:'JPure',defs:{$:'Nil'},fuel:131072,valid:true}));$p43ISave('raw-pure-end',{pureValid:f($j_pure_valid$(pure)),pureFuel:f($j_pure_fuel$(pure)),pureDefs:$p43IArray(f($j_pure_defs$(pure))).map(d=>$dn$(d))});
    if(f($j_pure_valid$(pure))){$p43ISave('caps-start');const caps=f($j_instance_caps$(view,raw));$p43ISave('caps-end',{caps:$p43IArray(caps).map(d=>({instance:$dn$(d),source:$dn$(f($j_instance_original$(f($index_first$($dc$(d)))))),liveArity:$da$(d),ready:f($j_instance_emit_ready$(view,d))}))});
     $p43ISave('final-root-start');const code=f($j_instance_root_view$(book,root,rows,caps));$p43ISave('final-root-end',{emissionBytes:code.length,activated:code.includes('private contextual instances')});
    }
   }
  }
 }
 $p43ISave('complete',{complete:true});throw new Error('PHASE43_INSTANCE_TRACE_COMPLETE');
};
`;
const diagnostic=path.join(out,'api-diagnostic.mjs');fs.writeFileSync(diagnostic,original+addition,{flag:'wx'});fs.copyFileSync(import.meta.filename,path.join(out,'consumed-trace.mjs'));fs.writeFileSync(path.join(out,'inputs.json'),JSON.stringify({inputs:[attempt.api.file,attempt.runtime.file,attempt.base.file,path.resolve(sourceArg),import.meta.filename].map(identity),diagnostic:identity(diagnostic)},null,2)+'\n');
process.env.BEND_TYPED_API=diagnostic;process.env.BEND_TYPED_RUNTIME=attempt.runtime.file;process.env.BEND_BASE=attempt.base.file;const {inspect}=await import('../../../typed-driver.mjs');let result;try{result=await inspect(path.resolve(sourceArg),{mode:'library'});}catch(e){result={status:'exception',diagnostic:String(e?.stack??e)};}
fs.writeFileSync(path.join(out,'completion.json'),JSON.stringify({expectedStop:fs.existsSync(reportFile)&&JSON.parse(fs.readFileSync(reportFile)).complete===true,status:result.status,diagnostic:result.diagnostic},null,2)+'\n');assert(fs.existsSync(reportFile),'No instance trace; inspect completion.json');console.log(fs.readFileSync(reportFile,'utf8'));
