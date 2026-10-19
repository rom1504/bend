// Source controls only; actual Bend admission/emission runs in root's guard.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const [apiFile,outDir,registerMode="runtime"]=process.argv.slice(2);
if(!apiFile||!outDir)throw Error('Usage: side-exit-controls.mjs API FRESH_OUT');
const api=(await import(pathToFileURL(path.resolve(apiFile)).href)).default;
fs.mkdirSync(outDir);
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const l={$:'N111U64'},w={$:'N111U32'},ptr={$:'N111Ptr'};
const local=name=>({$:'N111Local',name}),word=lo=>({$:'N111Const',lo,hi:0});
const arg=(typ,value)=>({$:'N111Arg',typ,value});
const state=()=>arg(ptr,local('state')),scratch=()=>arg(ptr,local('scratch'));
const call=(name,symbol,args)=>({$:'N111Call',name,typ:l,symbol,args:list(args)});
const ret=name=>({$:'N111Return',value:local(name)});
const store=(i,value)=>({$:'N111Store',typ:l,base:local('scratch'),offset:8*i,value});
const alloc={$:'N111Alloca',name:'scratch',bytes:2048,align:8};
const get=(name,i)=>call(name,'p111_rt_reg_get',[state(),arg(w,word(i))]);
const result=value=>[store(0,value),call('reply','p111_rt_return',[state(),scratch(),arg(w,word(1))]),ret('reply')];
const jump=(name,vs)=>[...vs.map((v,i)=>store(i,v)),call('reply','p111_rt_jump',[state(),arg(w,{$:'N111FuncId',name}),scratch(),arg(w,word(vs.length))]),ret('reply')];
const frame=call('ignored','p111_rt_frame',[state(),arg(w,{$:'N111FuncId',name:'failure_cont'}),scratch(),arg(w,word(1))]);
const fail=call('reply','p111_rt_fail',[state(),arg(w,word(4))]);
const sink=call('ignored','p111_rt_sink',[state(),arg(l,local('a'))]);
const failure=[sink,store(0,local('b')),frame,fail,ret('reply')];
const tail=jump('loop',[local('n'),local('b'),local('a')]);
const branch=(yes,no)=>({$:'N111If',condition:local('condition'),yes:list(yes),no:list(no)});
const seg=(name,arity,body,incoming=0)=>({$:'N111Segment',name,arity,result:1,incoming,flags:0,body:list(body)});
const make=(bad=failure,back=tail,prefix=[])=>seg('loop',3,[alloc,get('n',0),get('a',1),get('b',2),
  {$:'N111Bin',name:'condition',typ:l,op:'eq',left:local('n'),right:word(0)},...prefix,branch(result(local('a')),[branch(back,bad)])]);
const continuation=seg('failure_cont',2,[alloc,call('ignored','p111_rt_stack_pop',[state(),arg(w,word(1))]),
  call('held','p111_rt_stack_get',[state(),arg(w,word(0))]),get('incoming',0),
  call('ignored','p111_rt_sink',[state(),arg(l,local('held'))]),...result(local('incoming'))],1);
const main=seg('main',0,[alloc,...jump('loop',[word(1),word(11),word(22)])]);
const program=loop=>({$:'P111Program',segments:list([main,loop,continuation]),constructors:list([]),show:list([0]),show_names:list([]),effects:list([]),pure:true});
const controls=[];
function check(name,loop,admitted,originalValid=true){
  const p=program(loop),error=api.p111_verify_program(p);
  if(originalValid)assert.equal(error,'',name);
  assert.equal(api.p112t_admitted(api.p112t_plan(loop)),admitted,name);
  const ids=api.p111q_ids(p),out=api.p112q_segment(loop,ids);
  if(!admitted)assert.equal(out,api.p111q_segment(loop,ids),name+': fallback');
  controls.push({name,originalValid:error==='',admitted,fallbackExact:!admitted});
  return out;
}
const out=check('terminal-frame-failure-side-exit',make(),true);
assert.equal((out.match(/call \$p111_rt_frame/g)||[]).length,1);
assert.equal((out.match(/call \$p111_rt_fail/g)||[]).length,1);
assert.equal((out.match(/call \$p111_rt_reg_get/g)||[]).length,registerMode==="direct"?0:3);
assert.doesNotMatch(out,/call \$p111_rt_jump/);
check('terminal-failure-without-frame',make([fail,ret('reply')]),true);
check('frame-before-loopback',make(failure,[store(0,local('a')),frame,...tail]),false);
check('frame-before-branch',make(failure,tail,[store(0,local('a')),frame]),false);
check('state-load-in-failure',make([{$:'N111Load',name:'stateword',typ:l,base:local('state'),offset:0},...failure]),false);
check('register-read-in-failure',make([get('again',0),...failure]),false);
check('failure-followed-by-loopback',make([fail,...tail]),false);
check('bare-failure-return',make([ret('a')]),false);
const badCode=call('reply','p111_rt_fail',[state(),arg(w,word(0))]);
check('out-of-contract-failure-code',make([badCode,ret('reply')]),false,false);
fs.writeFileSync(path.join(outDir,'report.json'),JSON.stringify({kind:'phase112-terminal-failure-controls',complete:true,controls,targetsExecuted:false},null,2)+'\n');
console.log(JSON.stringify({complete:true,controls:controls.length}));
