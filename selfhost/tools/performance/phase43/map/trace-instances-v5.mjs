// Diagnostic API overlay only: root executes serially under bounded supervision.
// quick stops after collection; full checks/emits the selected root then stops.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';
import {verifyAttempt} from '../../../development/workflow.mjs';
const [attemptArg,sourceArg,rootName,outArg,mode='quick',overlay='none']=process.argv.slice(2);assert(outArg&&['quick','full'].includes(mode)&&['none','--cmp-overlay'].includes(overlay),'trace-instances-v1.mjs ATTEMPT SOURCE ROOT NEW_OUT [quick|full]');
const out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out);const attempt=await verifyAttempt(path.resolve(attemptArg)),reportFile=path.join(out,'report.json'),original=fs.readFileSync(attempt.api.file,'utf8');
const identity=file=>({path:fs.realpathSync(file),bytes:fs.statSync(file).size,sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const addition=`
const $p43IFs=await import('node:fs'),$p43IReport={kind:'phase43-instance-admission-trace',mode:${JSON.stringify(mode)},overlay:${JSON.stringify(overlay)},compilerQualification:false,complete:false,events:[]};
function $p43ISave(stage,detail={}){Object.assign($p43IReport,{stage,...detail});$p43IFs.writeFileSync(${JSON.stringify(reportFile)},JSON.stringify($p43IReport,null,2)+'\\n');}
function $p43IArray(xs){const rows=[];for(xs=run_loop(xs);xs.$==='Con';xs=run_loop(xs.tail)){assertBound(rows.length<128);rows.push(run_loop(xs.head));}return rows;}
function assertBound(ok){if(!ok)throw new Error('PHASE43_INSTANCE_DIAGNOSTIC_ROW_LIMIT');}
function $p43IShape(t){t=run_loop(t);return {tag:$tg$(t),name:$nm$(t),id:$ix$(t),quantity:$qt$(t),kids:run_loop($terms_len$($ks$(t)))};}
// Named diagnostic-only overlay; it must never qualify emitted compiler output.
function $p43ICmpNominal(t){t=run_loop(t);return $tg$(t)==='ADT'&&$nm$(t)==='Cmp'&&$ix$(t)===0&&[0,1].includes($qt$(t))&&run_loop($ks$(t)).$==='Nil'&&run_loop($rm$(t)).$==='Nil';}
if(${JSON.stringify(overlay)}==='--cmp-overlay'){
 const oldCmp=$j_map_cmp_type$;$j_map_cmp_ctor$=function(book,c,name,ty){return run_loop($j_pure_native_ctor$(c,name,0))&&$p43ICmpNominal(ty)&&$p43ICmpNominal(run_loop($wnf$(book,$dt$(c))));};
 $j_map_cmp_type$=function(book,ty){return $p43ICmpNominal(ty)&&run_loop(oldCmp(book,ty));};
}
function $p43ITypeInfo(book,t,depth=0){const f=run_loop,head=f($wnf$(book,t)),owner=f($lookup$(book,$nm$(head))),row={type:$p43IShape(head),pure:f($j_pure_type$(book,head)),owner:{kind:$dk$(owner),native:$db$(owner),arity:$da$(owner),type:$p43IShape(f($wnf$(book,$dt$(owner))))}};if(depth>=4)return row;
 if($nm$(head)==='Sigma'){row.sigmaHead=f($j_pure_sigma_head$(book,head));row.quantities=[0,1].map(i=>$qt$(f($kid$(head,i))));row.family=$p43IShape(f($kid$(head,3)));row.fields=[f($kid$(head,2)),f($kid$(f($kid$(head,3)),0))].map(x=>$p43ITypeInfo(book,x,depth+1));const tuple=f($lookup$($dc$(owner),'Tuple'));let tel=f($wnf$(book,f($j_specialize$(book,$dt$(tuple),$ks$(head)))));row.constructor=[];for(let left=2;left>0&&$tg$(tel)==='All';left--){const actual=f($wnf$(book,f($kid$(tel,0)))),expected=f($wnf$(book,f($j_pure_closed_field$(head,left))));row.constructor.push({left,quantity:$qt$(tel),actual:$p43IShape(actual),expected:$p43IShape(expected),same:f($j_pure_same_closed$(book,actual,expected,64)),actualPure:f($j_pure_type$(book,actual))});tel=f($wnf$(book,f($kid$(tel,1))));}row.terminal={actual:$p43IShape(tel),same:f($j_pure_same_closed$(book,tel,head,64))};}
 if($nm$(head)==='Cmp'){row.cmp=f($j_map_cmp_type$(book,head));row.kindQuantity=$qt$(f($kid$(f($wnf$(book,$dt$(owner))),0)));row.constructors=['LT','EQ','GT'].map(name=>{const c=f($lookup$($dc$(owner),name)),terminal=f($wnf$(book,$dt$(c)));return {name,kind:$dk$(c),native:$db$(c),arity:$da$(c),templates:$dx$(c),terminal:$p43IShape(terminal),nativeHeader:f($j_pure_native_ctor$(c,name,0)),exact:f($exact_term$(terminal,head)),sameClosed:f($j_pure_same_closed$(book,terminal,head,64)),cmpCtor:f($j_map_cmp_ctor$(book,c,name,head))};});}
 return row;
}
const $p43IStepOriginal=$j_erased_instance_step$,$p43IArgOriginal=$j_erased_instance_arg$,$p43IScanOriginal=$j_erased_instance_scanned$;
function $p43IProofStep(row){$p43IReport.proofSteps??=[];$p43IReport.proofStepTotal=($p43IReport.proofStepTotal||0)+1;if($p43IReport.proofSteps.length===256)$p43IReport.proofSteps.shift();$p43IReport.proofSteps.push(row);if(row.signature===false||row.closed===false||row.exactKind===false||row.scanResult==='None')$p43ISave('proof-refusal');}
$j_erased_instance_step$=function(book,env,d,body,ty,args,slots,prefix,fuel){
 const f=run_loop,head=f($wnf$(book,ty)),term=f($j_strip$(body)),remaining=$da$(d)-prefix;
 const row={kind:'prefix',name:$dn$(d),prefix,fuel,type:$p43IShape(head),body:$p43IShape(term),bodyFactory:f($j_l_name$(term)),remaining,args:f($terms_len$(args))};
 if($tg$(head)!=='All'||$qt$(head)!==0){row.signature=f($j_pure_signature$(book,head,remaining));row.domains=[];let cursor=head;for(let i=0;i<remaining&&$tg$(cursor)==='All';i++){const domain=f($wnf$(book,f($kid$(cursor,0)))),pure=f($j_pure_type$(book,domain));row.domains.push({at:i,quantity:$qt$(cursor),type:$p43IShape(domain),pure,...(!pure?{details:$p43ITypeInfo(book,domain)}:{})});cursor=f($wnf$(book,f($kid$(cursor,1))));}row.result={type:$p43IShape(cursor),pure:f($j_pure_type$(book,cursor))};}
 $p43IProofStep(row);return $p43IStepOriginal(book,env,d,body,ty,args,slots,prefix,fuel);
};
$j_erased_instance_arg$=function(book,env,d,body,ty,args,slots,prefix,fuel){const f=run_loop,values=$p43IArray(args),arg=values[0],canonical=f($wnf$(book,arg)),actual=f($wnf$(book,f($j_erased_arg_type$(book,canonical)))),expected=f($wnf$(book,f($kid$(ty,0))));$p43IProofStep({kind:'argument',name:$dn$(d),prefix,raw:$p43IShape(arg),canonical:$p43IShape(canonical),actual:$p43IShape(actual),expected:$p43IShape(expected),closed:f($j_erased_closed_arg$(book,arg)),exactKind:f($exact_term$(actual,expected))});return $p43IArgOriginal(book,env,d,body,ty,args,slots,prefix,fuel);};
$j_erased_instance_scanned$=function(book,env,d,body,ty,arg,rest,slots,prefix,r){$p43IProofStep({kind:'runtime-absence',name:$dn$(d),prefix,binder:$ix$(body),scanResult:run_loop(r).$});return $p43IScanOriginal(book,env,d,body,ty,arg,rest,slots,prefix,r);};
const $p43IOriginalErased=$j_erased_instance$;
$j_erased_instance$=function(book,env,spine){const name=$nm$(spine),d=run_loop($lookup$(book,name));$p43ISave('erased-call-start',{current:name,initial:{kind:$dk$(d),native:$db$(d),arity:$da$(d),templates:$dx$(d),args:run_loop($terms_len$($ks$(spine))),bodyBound:run_loop($j_u32_bounded$({$:'Con',head:$dv$(d),tail:{$:'Nil'}},4096))}});const result=run_loop($p43IOriginalErased(book,env,spine));const event={name,args:run_loop($terms_len$($ks$(spine))),result:result.$};$p43IReport.eventTotal=($p43IReport.eventTotal||0)+1;$p43IReport.eventCounts??={};$p43IReport.eventCounts[name]=($p43IReport.eventCounts[name]||0)+1;if($p43IReport.events.length===256)$p43IReport.events.shift();$p43IReport.events.push(event);if(result.$==='None'&&!$p43IReport.firstRefusal)$p43IReport.firstRefusal={...event,proof:$p43IReport.proofSteps?.slice(-8)};$p43ISave('erased-call-end',{current:name});return result;};
$j_library_selected$=function(book,defs){
 const f=run_loop,root=f($lookup$(book,${JSON.stringify(rootName)})),rootFacts={name:$dn$(root),kind:$dk$(root),arity:$da$(root),templates:$dx$(root),native:$db$(root),type:$p43IShape($dt$(root)),body:$p43IShape($dv$(root))};
 $p43ISave('root',{root:rootFacts});
 const list=values=>values.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'}),u32=f($kt$('ADT','U32',0,0,{$:'Nil'})),family=f($kt$('Lam','_',900001,1,list([u32]))),quantities=[[1,1],[1,2],[2,1],[2,2]],sigma=quantities.map(([qa,qb])=>f($kt$('ADT','Sigma',0,0,list([f($qua$(qa)),f($qua$(qb)),u32,family]))));
 $p43ISave('sigma-witness-start');const sigmaHeads=sigma.map((t,i)=>({quantities:quantities[i],pure:f($j_pure_type$(book,t)),selfSame:f($j_pure_same_closed$(book,t,t,1024))})),sigmaNegatives=[];for(let i=0;i<4;i++)for(let j=i+1;j<4;j++)sigmaNegatives.push({left:quantities[i],right:quantities[j],same:f($j_pure_same_closed$(book,sigma[i],sigma[j],1024))});$p43ISave('sigma-witness-end',{sigmaHeads,sigmaNegatives});
 $p43ISave('cmp-refusals-start');const cmpOwner=f($lookup$(book,'Cmp')),cmpCtor=f($lookup$($dc$(cmpOwner),'LT')),cmp0=f($kt$('ADT','Cmp',0,0,{$:'Nil'})),cmp1=f($kt$('ADT','Cmp',0,1,{$:'Nil'})),cmpResults=[];
 const checkCmp=(name,expected,body)=>{const actual=f(body());cmpResults.push({name,expected,actual});};
 checkCmp('metadata0',true,()=>$j_map_cmp_type$(book,cmp0));checkCmp('metadata1',true,()=>$j_map_cmp_type$(book,cmp1));
 const term=(tag='ADT',name='Cmp',id=0,quant=0,kids={$:'Nil'},removed={$:'Nil'})=>{const t=f($kt$(tag,name,id,quant,kids));return f($k_rebuild$(t,name,id,quant,kids,removed,0,0));};
 const badTerms=[['wrong-owner',term('ADT','Bool')],['type-argument',term('ADT','Cmp',0,0,list([u32]))],['removed-constructor',term('ADT','Cmp',0,0,{$:'Nil'},list(['LT']))],['free-id',term('ADT','Cmp',1)],['metadata2',term('ADT','Cmp',0,2)],['free-variable',f($var$('T',900002))],['function-terminal',f($kt$('All','x',900003,1,list([u32,cmp0])))]];
 for(const [name,t] of badTerms){checkCmp('head:'+name,false,()=>$j_map_cmp_type$(book,t));checkCmp('terminal:'+name,false,()=>$j_map_cmp_ctor$(book,{...cmpCtor,typ:t},'LT',cmp0));}
 for(const [name,change] of [['ctor-native',{native:false}],['ctor-arity',{arity:1}],['ctor-template',{templates:1}],['ctor-name',{name:'EQ'}]])checkCmp(name,false,()=>$j_map_cmp_ctor$(book,{...cmpCtor,...change},'LT',cmp0));
 for(const [name,change] of [['owner-native',{native:false}],['owner-arity',{arity:1}],['owner-template',{templates:1}],['owner-kind',{kind:'Def'}],['owner-kind-quantity',{typ:f($typ$(1))}],['owner-ctor-count',{ctors:list([cmpCtor])}]])checkCmp(name,false,()=>$j_map_cmp_type$(f($book_put$(book,{...cmpOwner,...change})),cmp0));
 $p43ISave('cmp-refusals-end',{cmpResults,cmpControlsPassed:cmpResults.every(x=>x.actual===x.expected)});

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
