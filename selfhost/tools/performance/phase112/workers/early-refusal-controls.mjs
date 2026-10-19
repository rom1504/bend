// Root-only comparison of two checked Bend APIs that differ solely by the
// early-refusal profile. Invalid payloads may differ; admission and emitted
// text must not. Every valid private plan is compared in full as well.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const [oldFile,newFile,outDir]=process.argv.slice(2);
if(!oldFile||!newFile||!outDir)throw Error('Usage: early-refusal-controls.mjs OLD_API NEW_API FRESH_OUT');
const load=async file=>(await import(pathToFileURL(path.resolve(file)).href)).default;
const old=await load(oldFile),now=await load(newFile);
fs.mkdirSync(outDir);
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const unlist=xs=>{const out=[];while(xs.$==='Con'){out.push(xs.head);xs=xs.tail;}assert.equal(xs.$,'Nil');return out;};
const l={$:'N111U64'},w={$:'N111U32'},ptr={$:'N111Ptr'};
const local=name=>({$:'N111Local',name}),word=lo=>({$:'N111Const',lo,hi:0});
const arg=(typ,value)=>({$:'N111Arg',typ,value});
const state=()=>arg(ptr,local('state')),scratch=()=>arg(ptr,local('scratch'));
const call=(name,symbol,args)=>({$:'N111Call',name,typ:l,symbol,args:list(args)});
const ret=name=>({$:'N111Return',value:local(name)});
const store=(i,value)=>({$:'N111Store',typ:l,base:local('scratch'),offset:8*i,value});
const alloc={$:'N111Alloca',name:'scratch',bytes:2048,align:8};
const get=(name,i)=>call(name,'p111_rt_reg_get',[state(),arg(w,word(i))]);
const bin=(name,op,left,right)=>({$:'N111Bin',name,typ:l,op,left,right});
const jump=(name,vs)=>[...vs.map((v,i)=>store(i,v)),call('reply','p111_rt_jump',[state(),arg(w,{$:'N111FuncId',name}),scratch(),arg(w,word(vs.length))]),ret('reply')];
const result=value=>[store(0,value),call('reply','p111_rt_return',[state(),scratch(),arg(w,word(1))]),ret('reply')];
const fail=[call('reply','p111_rt_fail',[state(),arg(w,word(4))]),ret('reply')];
const frame=call('ignored','p111_rt_frame',[state(),arg(w,{$:'N111FuncId',name:'cont'}),scratch(),arg(w,word(1))]);
const branch=(yes,no)=>({$:'N111If',condition:local('done'),yes:list(yes),no:list(no)});
const prefix=[alloc,get('x',0),bin('done','eq',local('x'),word(0))];
const seg=body=>({$:'N111Segment',name:'worker',arity:1,result:1,incoming:0,flags:0,body:list([...prefix,...body])});
const safe=(n,p='s')=>Array.from({length:n},(_,i)=>bin(p+i,'add',local('x'),word(i)));
const self=jump('worker',[local('x')]);
const cont={$:'N111Segment',name:'cont',arity:2,result:1,incoming:1,flags:0,body:list([alloc,
  call('ignored','p111_rt_stack_pop',[state(),arg(w,word(1))]),call('held','p111_rt_stack_get',[state(),arg(w,word(0))]),
  get('value',0),...result(local('value'))])};
const core=[['SNil',0],['SCon',2],['WNil',0],['WCon',2],['Nil',0],['Con',2],['Tuple',2],['Unit',0],
  ['None',0],['Some',1],['Fail',1],['Done',1],['Emit',1],['Halt',2],['True',0],['LT',0],['EQ',0],['GT',0]];
const program=worker=>({$:'P111Program',segments:list([{$:'N111Segment',name:'main',arity:0,result:1,incoming:0,flags:0,
  body:list([alloc,...jump('worker',[word(1)])])},worker,cont]),constructors:list(core.map(([name,arity])=>({$:'N_Constructor',name,arity,hot:arity>0}))),
  show:list([0]),show_names:list([]),effects:list([]),pure:true});
const controls=[];
function compare(name,worker){
  const p=program(worker);
  for(const api of [old,now])assert.equal(api.p111_verify_program(p),'',name);
  const a=old.p112w_index(p.segments),b=now.p112w_index(p.segments);
  assert.deepEqual(b,a,name+': exact ready trie and first admission ranks');
  const oldLoop=old.p112t_plan(worker),newLoop=now.p112t_plan(worker);
  const loop=old.p112t_admitted(oldLoop);
  assert.equal(now.p112t_admitted(newLoop),loop,name+': loop admission');
  if(loop)assert.deepEqual(newLoop,oldLoop,name+': full valid loop plan');
  const oldPlan=old.p112w_plan(worker,a),newPlan=now.p112w_plan(worker,b),direct=old.p112w_admitted(oldPlan);
  assert.equal(now.p112w_admitted(newPlan),direct,name+': direct admission');
  if(direct)assert.deepEqual(newPlan,oldPlan,name+': full valid worker plan');
  assert.equal(now.p112w_program_counts(p),old.p112w_program_counts(p),name+': exact counts');
  assert.deepEqual(unlist(now.p112w_segment_chunks(p.segments,now.p111q_ids(p),list([]))),
    unlist(old.p112w_segment_chunks(p.segments,old.p111q_ids(p),list([]))),name+': exact complete worker chunks');
  assert.deepEqual(unlist(now.p111q_chunks(p)),unlist(old.p111q_chunks(p)),name+': exact final entry chunks');
  controls.push({name,originalValid:true,loopAdmitted:loop,directAdmitted:direct,readyExact:true,validPlansExact:true,emissionExact:true});
}
compare('valid-leaf',seg([...safe(8),...result(local('x'))]));
compare('valid-self-loop',seg([branch(result(local('x')),self)]));
compare('valid-scalar-prefix-loop',seg([...safe(20),branch(result(local('x')),self)]));
compare('early-register-refusal',seg([get('late',0),...safe(16),...self]));
compare('late-register-refusal',seg([...safe(16),get('late',0),...self]));
compare('invalid-first-arm',seg([branch([get('late',0),...result(local('x'))],[...safe(24),...self])]));
compare('invalid-second-arm',seg([branch([...safe(24),...self],[get('late',0),...result(local('x'))])]));
compare('invalid-arm-before-shared-rest',seg([branch(safe(8,'yes'),[get('late',0),...safe(8,'no')]),...self]));
compare('valid-branches-and-shared-rest',seg([branch(safe(8,'yes'),safe(8,'no')),...self]));
compare('terminal-failure-side-exit',seg([branch(self,[store(0,local('x')),frame,...fail])]));
compare('frame-before-success',seg([store(0,local('x')),frame,branch(result(local('x')),self)]));
compare('state-buffer-refusal',seg([call('out','p111_rt_op',[state(),arg(w,word(1)),state(),arg(w,word(2))]),...safe(12),...self]));
const scaling=[];
const emptyOld=old.p112w_index(list([])),emptyNew=now.p112w_index(list([]));
function time(api,index,worker){
  const samples=[];
  for(let i=0;i<5;i++){
    const begin=process.hrtime.bigint();
    const plan=api.p112w_plan(worker,index);
    const end=process.hrtime.bigint();
    assert.equal(api.p112w_admitted(plan),false);
    samples.push(Number(end-begin)/1e6);
  }
  return samples;
}
for(const n of [32,128,384]){
  const scalar=seg([get('late',0),...safe(n),...self]);
  const arm=seg([branch([get('late',0),...result(local('x'))],[...safe(n),...self])]);
  for(const [kind,worker] of [['scalar-prefix',scalar],['first-arm',arm]]){
    compare(kind+'-'+n,worker);
    const oldMs=time(old,emptyOld,worker),newMs=time(now,emptyNew,worker);
    scaling.push({kind,suffixStatements:n,oldMs,newMs,unit:'milliseconds',repetitions:5});
  }
}
fs.writeFileSync(path.join(outDir,'report.json'),JSON.stringify({kind:'phase112-early-refusal-comparison',complete:true,
  oldAPI:path.resolve(oldFile),newAPI:path.resolve(newFile),controls,scaling,targetsExecuted:'checked Bend planner/emitter API only; no generated fixture executable'},null,2)+'\n');
console.log(JSON.stringify({complete:true,controls:controls.length,scalingCases:scaling.length}));
