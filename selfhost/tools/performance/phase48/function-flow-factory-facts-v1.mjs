// Saved checked-API diagnostic only. Root owns execution; never emits a candidate.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {verifyAttempt} from '../../development/workflow.mjs';

const [attemptArg, sourceArg, outArg] = process.argv.slice(2);
assert(outArg, 'function-flow-factory-facts-v1.mjs ATTEMPT SOURCE_BEND NEW_OUT');
const out = path.resolve(outArg);
assert(!fs.existsSync(out), 'fresh diagnostic destination required');
fs.mkdirSync(out);
const identity = file => {
  file = fs.realpathSync(file);
  const bytes = fs.readFileSync(file);
  return {file, sha256: createHash('sha256').update(bytes).digest('hex'), bytes: bytes.length};
};
const attempt = await verifyAttempt(path.resolve(attemptArg));
const inputs = [attempt.api.file, attempt.runtime.file, attempt.base.file,
  path.resolve(sourceArg), import.meta.filename].map(identity);
const original = fs.readFileSync(attempt.api.file, 'utf8');
for (const symbol of ['$j_library_selected$', '$j_type$', '$j_arm_type$', '$j_context$',
  '$j_app_type$', '$j_lambda_count$', '$wnf$', '$subst$', '$var$', '$kt$',
  '$j_layout_ctor$', '$j_specialize$', '$j_strip$']) {
  assert(original.includes(symbol), 'checked API exposes diagnostic helper ' + symbol);
}
const facts = path.join(out, 'factory-facts.json');
const addition = `
const $p48FactoryFs=await import('node:fs');
const $p48FactoryDestination=${JSON.stringify(facts)};
const $p48FactoryStop='PHASE48_FACTORY_FACTS_COMPLETE';
let $p48FactoryNodes=0,$p48FactoryCaptureNodes=0,$p48FactorySiteCount=0,$p48FactoryTruncated=false;
function $p48FactoryArray(xs){const out=[];for(xs=run_loop(xs);xs.$==='Con';xs=run_loop(xs.tail))out.push(run_loop(xs.head));return out;}
function $p48FactoryList(xs){let out={$:'Nil'};for(let i=xs.length-1;i>=0;i--)out={$:'Con',head:xs[i],tail:out};return out;}
function $p48FactoryShape(t,budget,depth=0){
 if(--budget.left<0||depth>64)return {truncated:true};t=run_loop(t);
 return {tag:$tg$(t),name:$nm$(t),id:$ix$(t),quantity:$qt$(t),removed:$p48FactoryArray($rm$(t)),
  children:$p48FactoryArray($ks$(t)).map(k=>$p48FactoryShape(k,budget,depth+1))};
}
function $p48FactoryType(t){return $p48FactoryShape(t,{left:256});}
function $p48FactoryEnv(env,id,ty){return {$:'Con',head:$kt$('Env','',id,0,$p48FactoryList([ty])),tail:env};}
// This is the same runtime-child order as j_l_children. Type annotations and
// erased actuals are excluded; every live branch and delayed lambda is retained.
function $p48FactoryChildren(book,env,t,ty){
 t=run_loop(t);const tag=$tg$(t),ks=$p48FactoryArray($ks$(t));
 if(tag==='Ann')return [[ks[0],ks[1],env,'ann']];
 if(tag==='Lam'){
  ty=$wnf$(book,ty);if($tg$(ty)!=='All')return [];
  return [[ks[0],$subst$(run_loop($p48FactoryArray($ks$(ty))[1]),$ix$(ty),$var$($nm$(t),$ix$(t))),
   $p48FactoryEnv(env,$ix$(t),run_loop($p48FactoryArray($ks$(ty))[0])),'lambda-body']];
 }
 if(tag==='Mat'){
  ty=$wnf$(book,ty);if($tg$(ty)!=='All')return [];
  const rows=[[ks[0],$j_arm_type$(book,ty,$nm$(t)),env,'arm:'+ $nm$(t)]];
  if(ks[1]&&$tg$(ks[1])!=='Absent')rows.push([ks[1],ty,env,'remaining-arms']);return rows;
 }
 if(tag==='App'){
  const calleeTy=$wnf$(book,$j_type$(book,env,ks[0]));const rows=[[ks[0],calleeTy,env,'callee']];
  if($tg$(calleeTy)==='All'&&$qt$(calleeTy)!==0)rows.push([ks[1],run_loop($p48FactoryArray($ks$(calleeTy))[0]),env,'live-actual']);return rows;
 }
 if(tag==='Let'){
  const rows=[];for(let i=0;i+1<ks.length;i++)if($qt$(ks[i])!==0){const rhs=run_loop($p48FactoryArray($ks$(ks[i]))[0]);rows.push([rhs,$j_type$(book,env,rhs),env,'live-rhs:'+ $ix$(ks[i])]);}
  if(ks.length)rows.push([ks.at(-1),ty,$j_context$(book,env,$ks$(t)),'let-body']);return rows;
 }
 if(tag==='Ctr'){
  // Exact constructor telescope, retaining field order and omitting only qt0.
  const head=$wnf$(book,ty),ctor=$j_layout_ctor$(book,head,$nm$(t));
  let tel=$j_specialize$(book,$dt$(ctor),$ks$(head));const rows=[];
  for(let i=0;i<ks.length;i++){if($tg$(tel)!=='All')break;if($qt$(tel)!==0)rows.push([ks[i],run_loop($p48FactoryArray($ks$(tel))[0]),env,'constructor-field:'+i]);tel=$j_app_type$(tel,ks[i]);}return rows;
 }
 if(tag==='Rwt'&&ks[2])return [[ks[2],ty,env,'rewrite-body']];
 return [];
}
function $p48FactoryFree(book,env,t,ty,rootId){
 const free=new Set(),refs=new Set();let left=2048,truncated=false;
 function visit(t,ty,env,bound,depth){
  if(--left<0||++$p48FactoryCaptureNodes>65536||depth>64){truncated=true;$p48FactoryTruncated=true;return;}t=run_loop(t);const tag=$tg$(t);
  if(tag==='Var'){if(!bound.has($ix$(t)))free.add($ix$(t));return;}
  if(tag==='Ref'){refs.add($nm$(t));return;}
  let next=bound;if(tag==='Lam'){next=new Set(bound);next.add($ix$(t));}
  const rows=$p48FactoryChildren(book,env,t,ty);
  for(const [kid,kty,kenv,label]of rows){let scope=next;
   if(tag==='Let'&&label==='let-body'){scope=new Set(next);for(const k of $p48FactoryArray($ks$(t)).slice(0,-1))scope.add($ix$(k));}
   visit(kid,kty,kenv,scope,depth+1);
  }
 }
 visit(t,ty,env,new Set([rootId]),0);
 const entries=new Map($p48FactoryArray(env).map(e=>[$ix$(e),run_loop($p48FactoryArray($ks$(e))[0])]));
 return {captures:[...free].sort((a,b)=>a-b).map(id=>({id,inScope:entries.has(id),type:entries.has(id)?$p48FactoryType(entries.get(id)):null})),
  originalReferences:[...refs].sort(),truncated};
}
function $p48FactoryDefinition(book,d){
 const sites=[],errors=[];let left=4096;
 function visit(t,ty,env,labels,depth){
  if(--left<0||++$p48FactoryNodes>150000||depth>128){$p48FactoryTruncated=true;return;}
  try{
   t=run_loop(t);ty=run_loop(ty);const tag=$tg$(t);
   if(tag==='Lam'&&$p48FactorySiteCount<256){
    ++$p48FactorySiteCount;const formal=$wnf$(book,ty);
    sites.push({path:labels,binder:$ix$(t),bodyQuantity:$qt$(t),formalQuantity:$tg$(formal)==='All'?$qt$(formal):null,
     functionType:$p48FactoryType(formal),captures:$p48FactoryFree(book,env,t,ty,$ix$(t)),
     body:$p48FactoryShape(t,{left:512})});
   }
   if(tag==='Lam'&&$p48FactorySiteCount>=256)$p48FactoryTruncated=true;
   for(const [kid,kty,kenv,label]of $p48FactoryChildren(book,env,t,ty))visit(kid,kty,kenv,labels.concat(label),depth+1);
  }catch(e){errors.push({path:labels,error:String(e)});}
 }
 let prefix=$j_lambda_count$($dv$(d));if($tg$($j_strip$($dv$(d)))==='Mat')prefix=1;
 let sig=$wnf$(book,$dt$(d)),higherOrder=false;
 for(let i=0;i<prefix&&i<64&&$tg$(sig)==='All';i++){const kids=$p48FactoryArray($ks$(sig));if($tg$($wnf$(book,kids[0]))==='All')higherOrder=true;sig=$wnf$(book,kids[1]);}
 if($tg$(sig)==='All')higherOrder=true;
 if(higherOrder)visit($dv$(d),$dt$(d),{$:'Nil'},[],0);
 return {name:$dn$(d),arity:$da$(d),higherOrderCandidate:higherOrder,leadingLambdas:$j_lambda_count$($dv$(d)),type:$p48FactoryType($dt$(d)),sites,
  truncated:left<0,errors};
}
const $p48FactoryOriginal=$j_library_selected$;
$j_library_selected$=function(book,defs){
 const definitions=[];for(const d of $p48FactoryArray(defs)){
  if($dk$(d)==='Def'&&!$db$(d))definitions.push($p48FactoryDefinition(book,d));
  if($p48FactoryNodes>150000)break;
 }
 $p48FactoryFs.writeFileSync($p48FactoryDestination,JSON.stringify({kind:'phase48-original-factory-role-facts-v1',
  scope:'original checked source before planner; runtime-child interpretation; diagnostic facts only, never an admission proof',
  bounds:{definitionNodes:4096,aggregateNodes:150000,depth:128,siteCaptureNodes:2048,aggregateCaptureNodes:65536,sites:256,shapeNodes:512},
  nodes:$p48FactoryNodes,captureNodes:$p48FactoryCaptureNodes,sites:$p48FactorySiteCount,truncated:$p48FactoryTruncated,definitions},null,2)+'\\n');
 throw new Error($p48FactoryStop);
};
`;
const derivative = path.join(out, 'api-factory-facts.mjs');
fs.writeFileSync(derivative, original + addition, {flag:'wx'});
const derivativeIdentity = identity(derivative);
fs.copyFileSync(import.meta.filename, path.join(out, 'consumed-producer.mjs'));
process.env.BEND_TYPED_API = derivative;
process.env.BEND_TYPED_RUNTIME = attempt.runtime.file;
process.env.BEND_BASE = attempt.base.file;
const {inspect} = await import('../../typed-driver.mjs');
let result;
try { result = await inspect(path.resolve(sourceArg), {mode:'library'}); }
catch(e) { result = {status:'exception', checked:false, diagnostic:String(e?.stack ?? e)}; }
const complete = fs.existsSync(facts) && String(result.diagnostic ?? '').includes('PHASE48_FACTORY_FACTS_COMPLETE');
for (const input of inputs) assert.deepEqual(identity(input.file), input, 'consumed diagnostic input changed');
assert.deepEqual(identity(derivative), derivativeIdentity);
const report = {kind:'phase48-factory-role-diagnostic-v1',complete,expectedStop:complete,
  inputs,derivative:derivativeIdentity,observation:{status:result.status,checked:result.checked,diagnostic:result.diagnostic},
  facts:fs.existsSync(facts)?identity(facts):null,timingEligible:false,semanticQualification:false};
fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({kind:report.kind,complete,expectedStop:complete}));
if(!complete)process.exitCode=1;
