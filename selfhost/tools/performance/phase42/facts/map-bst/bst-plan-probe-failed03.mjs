// Root-run observation only. Never substitutes a predicate or retains emission.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../../development/workflow.mjs';
const [attemptArg, sourceArg, outArg] = process.argv.slice(2);
assert(attemptArg && sourceArg && outArg, 'ATTEMPT BST_SOURCE NEW_OUT');
const out = path.resolve(outArg); fs.mkdirSync(out);
const identity = file => ({file: fs.realpathSync(file), sha256: createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const attempt = await verifyAttempt(path.resolve(attemptArg));
const original = fs.readFileSync(attempt.api.file, 'utf8');
const addition = String.raw`
const $p42BstRows=[], $p42BstTypes=[], $p42BstChecks=[];
const $p42BstNames=['bst.pick','bst.step','bst.down','bst.up','insert.fin','insert','inorder','p37.bst.insert','p37.bst.build','bench'];
const $p42BstNil={$:'Nil'};
const $p42BstRun=x=>run_loop(x);
function $p42BstList(xs){return xs.reduceRight((tail,head)=>({$:'Con',head,tail}),$p42BstNil);}
function $p42BstArray(xs){const a=[];for(xs=run_loop(xs);xs.$==='Con';xs=run_loop(xs.tail))a.push(run_loop(xs.head));return a;}
function $p42BstTerm(tag,name='',kids=[],id=0,quant=0){return {$:'KTerm',tag,name,id,quant,kids:$p42BstList(kids),removed:$p42BstNil,originBegin:0,originEnd:0};}
function $p42BstShape(t,depth=0){t=run_loop(t);const r={tag:$tg$(t),name:$nm$(t),id:$ix$(t),quantity:$qt$(t),removed:$p42BstArray($rm$(t))};if(depth<5)r.kids=$p42BstArray($ks$(t)).slice(0,8).map(x=>$p42BstShape(x,depth+1));return r;}
function $p42BstQuery(name,fn){try{return {name,value:fn()};}catch(e){return {name,error:String(e?.stack??e)};}}
function $p42BstPlan(p){p=run_loop(p);return {valid:$j_pure_valid$(p),fuel:$j_pure_fuel$(p),defs:$p42BstArray($j_pure_defs$(p)).map($dn$)};}
function $p42BstRefs(t){const out=new Set(),todo=[t];let fuel=8192;while(todo.length&&fuel-->0){const h=run_loop(todo.pop());if($tg$(h)==='Ref')out.add($nm$(h));todo.push(...$p42BstArray($ks$(h)));}return {names:[...out].sort(),complete:todo.length===0};}
let $p42BstObserved=false;
const $p42BstOldDef=$j_l_def$;
$j_l_def$=function(book,d){if(!$p42BstObserved&&$p42BstNames.includes($dn$(d))){$p42BstObserved=true;
 const types=new Map();
 for(const name of $p42BstNames){const src=run_loop($lookup$(book,name));if($dk$(src)!=='Def')continue;
  let h=run_loop($wnf$(book,$dt$(src)));const args=[];for(let i=0;i<$da$(src)&&$tg$(h)==='All';i++){const a=run_loop($wnf$(book,run_loop($kid$(h,0))));args.push(a);h=run_loop($wnf$(book,run_loop($kid$(h,1))));}args.forEach((t,i)=>types.set(name+':arg'+i,t));types.set(name+':result',h);
  const one={$:'Con',head:$dv$(src),tail:$p42BstNil};
  $p42BstRows.push({name,arity:$da$(src),type:$p42BstShape($dt$(src)),args:args.map(t=>$p42BstShape(t)),result:$p42BstShape(h),refs:$p42BstRefs($dv$(src)),queries:[
   $p42BstQuery('signature',()=>run_loop($j_pure_signature$(book,$dt$(src),$da$(src)))),
   $p42BstQuery('captureEligible',()=>run_loop($j_region_capture_eligible$(book,src))),
   $p42BstQuery('componentPrefix',()=>run_loop($j_component_prefix$(book,$p42BstNil,$dv$(src),$dt$(src),run_loop($j_component_slots$(0,$da$(src))),src,0))),
   $p42BstQuery('selfRefs',()=>run_loop($j_component_refs$(one,name,1024,0))),
   $p42BstQuery('pureGraph',()=>$p42BstPlan($j_pure_graph$(book,src,{$:'JPure',defs:$p42BstNil,fuel:32768,valid:true}))),
   $p42BstQuery('componentPlan',()=>$p42BstPlan($j_component_plan$(book,src))),
   $p42BstQuery('directPlan',()=>$p42BstPlan($j_direct_plan$(book,src)))
  ]});
 }
 for(const [label,t] of types){$p42BstTypes.push({label,shape:$p42BstShape(t),queries:[
  $p42BstQuery('pureType',()=>run_loop($j_pure_type$(book,t))),
  $p42BstQuery('groundList',()=>run_loop($j_list_ground_type$(book,t))),
  $p42BstQuery('closedList',()=>run_loop($j_pure_closed_list$(book,t))),
  $p42BstQuery('closedSigma',()=>run_loop($j_pure_closed_sigma$(book,t))),
  $p42BstQuery('localSigmaHeader',()=>run_loop($j_region_local_sigma$(book,t))),
  $p42BstQuery('localType',()=>run_loop($j_region_local_type$(book,t)))
 ]});}
 const adt=n=>$p42BstTerm('ADT',n),u32=adt('U32'),bst=adt('BST'),frame=adt('BFrame');
 const fn=$p42BstTerm('All','',[u32,u32],99001,2),vec=$p42BstTerm('ADT','Array',[u32]);
 const list=e=>$p42BstTerm('ADT','List',[$p42BstTerm('Qua','',[],0,2),e]);
 const sigma=types.get('bst.step:arg1');
 const sigmaKids=$p42BstArray($ks$(sigma));
 const sigmaOther={...sigma,kids:$p42BstList(sigmaKids.map((x,i)=>i===2?frame:x))};
 const sigmaDependent={...sigma,kids:$p42BstList(sigmaKids.map((x,i)=>i===3?$p42BstTerm('Lam','',[$p42BstTerm('Var','',[],99002)],99002,2):x))};
 for(const [label,t] of [['Sigma',sigma],['List',list(frame)]]){const owner=run_loop($lookup$(book,label));$p42BstChecks.push({label:'nativeABI-'+label,owner:{arity:$da$(owner),templates:$dx$(owner),native:$db$(owner),kind:$p42BstShape(run_loop($wnf$(book,run_loop($j_specialize$(book,$dt$(owner),$ks$(t))))))},ctors:$p42BstArray($dc$(owner)).map(c=>({name:$dn$(c),arity:$da$(c),templates:$dx$(c),native:$db$(c),specialized:$p42BstShape(run_loop($wnf$(book,run_loop($j_specialize$(book,$dt$(c),$ks$(t)))))))}))});}
 const candidates=[['closedBST',bst],['closedFrame',frame],['closedListFrame',list(frame)],['closedSigma',sigma],['listFunction',list(fn)],['listVector',list(vec)],['dependentSigma',sigmaDependent]];
 for(const [label,t] of candidates)$p42BstChecks.push({label,shape:$p42BstShape(t),query:$p42BstQuery('pureType',()=>run_loop($j_pure_type$(book,t)))});
 for(const [label,field] of [['nestedFunction',fn],['nestedVector',vec],['nestedDependentSigma',sigmaDependent]]){
  const owner='$p42.'+label,ctor=owner+'.Ctor',result=adt(owner);
  const c={$:'KDef',name:ctor,kind:'Ctr',arity:1,templates:0,typ:$p42BstTerm('All','',[field,result],99003,1),value:$p42BstTerm('Absent'),ctors:$p42BstNil,native:false,unsafe:false};
  const o={$:'KDef',name:owner,kind:'ADT',arity:0,templates:0,typ:$p42BstTerm('Typ','',[$p42BstTerm('Qua','',[],0,2)]),value:$p42BstTerm('Absent'),ctors:$p42BstList([c]),native:false,unsafe:false};
  const local=run_loop($book_put$(book,o));$p42BstChecks.push({label,shape:$p42BstShape(field),query:$p42BstQuery('pureType',()=>run_loop($j_pure_type$(local,result)))});
 }
 $p42BstChecks.push({label:'sameType-mismatched-Sigma-current-quarantine',left:$p42BstShape(sigma),right:$p42BstShape(sigmaOther),query:$p42BstQuery('sameType',()=>run_loop($j_region_same_type$(book,sigma,sigmaOther)))});
 $p42BstChecks.push({label:'sameType-mismatched-List',query:$p42BstQuery('sameType',()=>run_loop($j_region_same_type$(book,list(bst),list(frame))))});
 }return $p42BstOldDef(book,d);};
export function phase42BstObservations(){return {definitions:$p42BstRows,types:$p42BstTypes,controls:$p42BstChecks};}
`;
const diagnostic=path.join(out,'api-diagnostic.mjs');
fs.writeFileSync(diagnostic,original+addition,{flag:'wx'});
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-probe.mjs'));
process.env.BEND_TYPED_API=diagnostic;process.env.BEND_TYPED_RUNTIME=attempt.runtime.file;process.env.BEND_BASE=attempt.base.file;
const {inspect}=await import('../../../../typed-driver.mjs');
const result=await inspect(path.resolve(sourceArg),{mode:'library'});
const api=await import(pathToFileURL(diagnostic));
const report={kind:'phase42-bst-observation-only',complete:result.status==='ok',status:result.status,checked:result.checked,error:result.diagnostic,
 inputs:[path.join(out,'consumed-probe.mjs'),attempt.api.file,attempt.runtime.file,attempt.base.file,sourceArg].map(identity),diagnostic:identity(diagnostic),observations:api.phase42BstObservations(),codeBytes:result.code?.length,
 scope:'Original predicates only. Synthetic negative controls are observation fixtures, not proof of an unimplemented extension. No emitted program retained.'};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,definitions:report.observations.definitions.length,controls:report.observations.controls.length,error:report.error}));
if(!report.complete||report.observations.definitions.length===0)process.exitCode=1;
