// Phase43 explicit closed Sigma quantity-domain successor.
// Retains original43 controls; Sigma(2,1) now admits. Adds independent14 quantity witnesses.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
const [attemptArg,sourceArg,outArg]=process.argv.slice(2);
assert(attemptArg&&sourceArg&&outArg,'CHECKED_ATTEMPT_DIR BST_SOURCE NEW_OUT');
const out=path.resolve(outArg);fs.mkdirSync(out);
const identity=file=>({file:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const array=xs=>{const a=[];while(xs.$==='Con'){a.push(xs.head);xs=xs.tail;}assert.equal(xs.$,'Nil');return a;};
const term=(tag,name='',kids=[],id=0,quant=0)=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:list([]),originBegin:0,originEnd:0});
const adt=n=>term('ADT',n),all=(a,b,id=99001,q=1)=>term('All','',[a,b],id,q),lam=(id,body)=>term('Lam','_',[body],id,1);
const listTy=(element,q=2)=>term('ADT','List',[term('Qua','',[],0,q),element]);
const report={kind:'phase43-closed-native-proof-controls',complete:false,pass:false,observations:[],scope:'Strict predicate controls on an actual checked API. Synthetic malformed IR is not claimed TS-valid; emitted library discarded. Root activation observations are recorded separately without assertions.'};
let attempt;
try{
 attempt=await verifyAttempt(path.resolve(attemptArg));
 const names=['lookup','book_put','wnf','kid','j_specialize','j_pure_type','j_pure_type_check','j_pure_closed_list','j_pure_closed_sigma','j_pure_same_closed','j_pure_same_check','j_pure_graph','j_component_plan','j_direct_plan'];
 const original=fs.readFileSync(attempt.api.file,'utf8');
 for(const n of names)assert.equal(original.split('function $'+n+'$(').length,2,n);
 const addition=String.raw`
let $p42NativeBook=null;const $p42NativeOldDef=$j_l_def$;
$j_l_def$=function(book,d){if($p42NativeBook===null&&$dn$(d)==='bst.step')$p42NativeBook=book;return $p42NativeOldDef(book,d);};
export const phase42Native={getBook:()=>$p42NativeBook,
`+names.map(n=>n+':(...a)=>run_loop($'+n+'$(...a))').join(',')+'};\n';
 const diagnostic=path.join(out,'api-diagnostic.mjs');fs.writeFileSync(diagnostic,original+addition,{flag:'wx'});
 fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
 report.inputs=[path.join(out,'consumed-controls.mjs'),attempt.api.file,attempt.runtime.file,attempt.base.file,sourceArg,path.join(path.resolve(attemptArg),'attempt.json')].map(identity);
 report.diagnostic={...identity(diagnostic),unchangedPrefixBytes:Buffer.byteLength(original)};
 process.env.BEND_TYPED_API=diagnostic;process.env.BEND_TYPED_RUNTIME=attempt.runtime.file;process.env.BEND_BASE=attempt.base.file;
 const {inspect}=await import('../../../typed-driver.mjs');
 const checked=await inspect(path.resolve(sourceArg),{mode:'library'});
 report.compilerRequest={status:checked.status,checked:checked.checked,diagnostic:checked.diagnostic,codeBytes:checked.code?.length};
 assert.equal(checked.status,'ok');assert.equal(checked.checked,true);
 const api=(await import(pathToFileURL(diagnostic))).phase42Native;
 const book=api.getBook();assert(book,'canonical checked source context captured');
 const query=(name,actual,expected)=>{assert.deepEqual(actual,expected,name);report.observations.push({name,actual,expected,pass:true});};
 const bool=(name,value,expected)=>{assert.equal(typeof value,'boolean',name+' Boolean contract');query(name,value,expected);};
 const step=api.lookup(book,'bst.step');let sig=api.wnf(book,step.typ);sig=api.wnf(book,api.kid(sig,1));
 const sigma=api.wnf(book,api.kid(sig,0));assert.equal(sigma.name,'Sigma');
 const sigmaArgs=array(sigma.kids),sigmaOf=(a,b,q0=1,q1=1,id=99200)=>({...sigma,kids:list([term('Qua','',[],0,q0),term('Qua','',[],0,q1),a,lam(id,b)])});
 const bst=adt('BST'),frame=adt('BFrame'),u32=adt('U32'),frames=listTy(frame);
 const fn=all(u32,u32,99300,2),vector=term('ADT','Array',[u32]);
 for(const [name,ty] of [['BST',bst],['BFrame',frame],['ListFrame',frames],['SigmaBSTFrame',sigma],['ListU32',listTy(u32)]])bool('admit-'+name,api.j_pure_type(book,ty),true);
 bool('closed-list-wrapper',api.j_pure_closed_list(book,frames),true);
 bool('closed-sigma-wrapper',api.j_pure_closed_sigma(book,sigma),true);
 bool('closed-list-rejects-sigma',api.j_pure_closed_list(book,sigma),false);
 bool('closed-sigma-rejects-list',api.j_pure_closed_sigma(book,frames),false);
 const dependent=sigmaOf(bst,term('Var','',[],99201),1,1,99201);
 for(const [name,ty] of [['ListFunction',listTy(fn)],['ListVector',listTy(vector)],['SigmaFunction',sigmaOf(fn,frame)],['SigmaVector',sigmaOf(vector,frame)],['DependentSigma',dependent],['ListQty1',listTy(frame,1)],['ListQty0',listTy(frame,0)],['SigmaQty0',sigmaOf(bst,frames,0,1)],['SigmaQty2',sigmaOf(bst,frames,2,1)],['SigmaSecondQty0',sigmaOf(bst,frames,1,0)]])bool((name==='SigmaQty2'?'admit-':'reject-')+name,api.j_pure_type(book,ty),name==='SigmaQty2');
 const removed={...frames,removed:list(['BFrame'])};bool('reject-removed-list-field',api.j_pure_type(book,removed),false);
 const nested=(name,field)=>{
  const owner='$p42.control.'+name,ctr={$:'KDef',name:owner+'.Ctor',kind:'Ctr',arity:1,templates:0,typ:all(field,adt(owner),99310,1),value:term('Absent'),ctors:list([]),native:false,unsafe:false};
  return [api.book_put(book,{$:'KDef',name:owner,kind:'ADT',arity:0,templates:0,typ:term('Typ','',[term('Qua','',[],0,2)]),value:term('Absent'),ctors:list([ctr]),native:false,unsafe:false}),adt(owner)];
 };
 for(const [name,field] of [['nestedFunction',fn],['nestedVector',vector],['nestedDependentSigma',dependent]]){const [b,t]=nested(name,field);bool('reject-'+name,api.j_pure_type(b,t),false);}
 bool('equality-sigma-alpha-unused',api.j_pure_same_closed(book,sigma,sigmaOf(bst,frames,1,1,99500),64),true);
 bool('equality-sigma-first-mismatch',api.j_pure_same_closed(book,sigma,sigmaOf(frame,frames),64),false);
 bool('equality-sigma-second-mismatch',api.j_pure_same_closed(book,sigma,sigmaOf(bst,listTy(bst)),64),false);
 bool('equality-list-element-mismatch',api.j_pure_same_closed(book,frames,listTy(bst),64),false);
 bool('equality-container-vs-user',api.j_pure_same_closed(book,frames,frame,64),false);
 bool('equality-quantity-mismatch',api.j_pure_same_closed(book,sigma,sigmaOf(bst,frames,2,1),64),false);
 const mutateCtor=(ownerName,ctorName,edit)=>{
  const owner=api.lookup(book,ownerName);
  const ctors=array(owner.ctors).map(c=>c.name!==ctorName?c:edit(c,owner.arity));
  return api.book_put(book,{...owner,ctors:list(ctors)});
 };
 const editAfter=(t,skip,edit)=>{t=api.wnf(book,t);if(skip===0)return edit(t);assert.equal(t.tag,'All');const ks=array(t.kids);return {...t,kids:list([ks[0],editAfter(ks[1],skip-1,edit)])};};
 const fieldChange=(c,n)=>({...c,typ:editAfter(c.typ,n,t=>({...t,kids:list([u32,array(t.kids)[1]])}))});
 bool('reject-list-specialized-head-type-mismatch',api.j_pure_type(mutateCtor('List','Con',fieldChange),frames),false);
 bool('reject-sigma-specialized-first-type-mismatch',api.j_pure_type(mutateCtor('Sigma','Tuple',fieldChange),sigma),false);
 const qtyChange=(c,n)=>({...c,typ:editAfter(c.typ,n,t=>({...t,quant:2}))});
 bool('reject-list-ctor-field-quantity',api.j_pure_type(mutateCtor('List','Con',qtyChange),frames),false);
 bool('reject-sigma-ctor-field-quantity',api.j_pure_type(mutateCtor('Sigma','Tuple',qtyChange),sigma),false);
 const terminalChange=(c,n)=>({...c,typ:editAfter(c.typ,n+2,()=>listTy(bst))});
 bool('reject-list-ctor-terminal-type',api.j_pure_type(mutateCtor('List','Con',terminalChange),frames),false);
 bool('reject-sigma-ctor-terminal-type',api.j_pure_type(mutateCtor('Sigma','Tuple',terminalChange),sigma),false);
 for(const [name,edit] of [['arity',c=>({...c,arity:3})],['native',c=>({...c,native:false})],['templates',c=>({...c,templates:1})]])bool('reject-tuple-ctor-'+name,api.j_pure_type(mutateCtor('Sigma','Tuple',edit),sigma),false);
 let aliasBook=book,prior='U32',small;
 for(let i=0;i<20;i++){
  const name='$p42.alias'+i,value=sigmaOf(term('Ref',prior),term('Ref',prior),1,1,99600+i);
  aliasBook=api.book_put(aliasBook,{$:'KDef',name,kind:'Def',arity:0,templates:0,typ:term('Typ','',[term('Qua','',[],0,1)]),value,ctors:list([]),native:false,unsafe:false});
  prior=name;if(i===1)small=term('Ref',name);
 }
 const deep=term('Ref',prior),before=performance.now();
 query('aggregate-equality-aliasDAG20-fuel64',api.j_pure_same_check(aliasBook,deep,deep,64),{$:'None'});
 report.equalityWallMs=performance.now()-before;
 query('aggregate-equality-small-product-fuel64',api.j_pure_same_check(aliasBook,small,small,64),{$:'Some',value:57});
 bool('aggregate-type-aliasDAG20-fuel512',api.j_pure_type(aliasBook,deep),false);
 query('type-fuel-zero',api.j_pure_type_check(book,sigma,list([]),0),{$:'None'});
 report.activationObservations=['bench','bst.down','bst.up','inorder','p37.bst.build'].map(name=>{
  const d=api.lookup(book,name),state={$:'JPure',defs:list([]),fuel:32768,valid:true};
  const pure=api.j_pure_graph(book,d,state),component=api.j_component_plan(book,d),direct=api.j_direct_plan(book,d);
  return {name,pure:{valid:pure.valid,fuel:pure.fuel,defs:array(pure.defs).map(x=>x.name)},component:{valid:component.valid,fuel:component.fuel,defs:array(component.defs).map(x=>x.name)},direct:{valid:direct.valid,fuel:direct.fuel}};
 });
 query('checked-api-unchanged',identity(attempt.api.file),report.inputs[1]);
 // Independent Map witness: exact same four scalar specializations and six
 // distinct quantity pairs, evaluated on the real checked source book.
 const quantityPairs=[[1,1],[1,2],[2,1],[2,2]];
 const quantityTypes=quantityPairs.map(([qa,qb],i)=>sigmaOf(u32,u32,qa,qb,99800+i));
 for(let i=0;i<quantityPairs.length;i++){
  const [qa,qb]=quantityPairs[i],ty=quantityTypes[i];
  bool('quantity-admit-'+qa+'-'+qb,api.j_pure_type(book,ty),true);
  bool('quantity-self-equality-'+qa+'-'+qb,api.j_pure_same_closed(book,ty,ty,64),true);
 }
 for(let i=0;i<quantityPairs.length;i++)for(let j=i+1;j<quantityPairs.length;j++){
  bool('quantity-distinct-'+quantityPairs[i].join('-')+'-vs-'+quantityPairs[j].join('-'),
    api.j_pure_same_closed(book,quantityTypes[i],quantityTypes[j],64),false);
 }
 assert.equal(report.observations.length,57);
 report.quantityDomain={parameters:[1,2],familyBinderQuantity:1,originalControls:43,additionalControls:14,
  changedOriginal:{name:'admit-SigmaQty2',parameters:[2,1],expected:true},
  equalityQuantityMismatchStillRefused:true,vectorLocalEqualityValidation:'separate inherited counter owner required'};

 report.complete=report.pass=true;
}catch(error){report.error=String(error?.stack??error);process.exitCode=1;}
finally{fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});}
console.log(JSON.stringify({complete:report.complete,pass:report.pass,controls:report.observations.length,error:report.error,activation:report.activationObservations}));
