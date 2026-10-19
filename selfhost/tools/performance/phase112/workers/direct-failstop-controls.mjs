// Optional CPU-runtime04 profile. Reachable failures have independent expected
// status/stdout/stderr; root must bind admit-failstop.py before native execution.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const [apiFile,outDir]=process.argv.slice(2);
if(!apiFile||!outDir)throw Error('Usage: direct-failstop-controls.mjs API FRESH_OUT');
const api=(await import(pathToFileURL(path.resolve(apiFile)).href)).default;
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
const jump=(name,vs)=>[...vs.map((v,i)=>store(i,v)),call('reply','p111_rt_jump',[state(),arg(w,{$:'N111FuncId',name}),scratch(),arg(w,word(vs.length))]),ret('reply')];
const result=value=>[store(0,value),call('reply','p111_rt_return',[state(),scratch(),arg(w,word(1))]),ret('reply')];
const failure=code=>[call('reply','p111_rt_fail',[state(),arg(w,word(code))]),ret('reply')];
const frame=call('ignored','p111_rt_frame',[state(),arg(w,{$:'N111FuncId',name:'dead_cont'}),scratch(),arg(w,word(1))]);
const branch=(yes,no)=>({$:'N111If',condition:local('done'),yes:list(yes),no:list(no)});
const seg=(name,arity,body,incoming=0)=>({$:'N111Segment',name,arity,result:1,incoming,flags:0,body:list(body)});
const prefix=[alloc,get('x',0),{$:'N111Bin',name:'done',typ:l,op:'eq',left:local('x'),right:word(0)}];
const dead=seg('dead_cont',2,[alloc,call('ignored','p111_rt_stack_pop',[state(),arg(w,word(1))]),
  call('held','p111_rt_stack_get',[state(),arg(w,word(0))]),get('value',0),...result(local('value'))],1);
const core=[['SNil',0],['SCon',2],['WNil',0],['WCon',2],['Nil',0],['Con',2],['Tuple',2],['Unit',0],
  ['None',0],['Some',1],['Fail',1],['Done',1],['Emit',1],['Halt',2],['True',0],['LT',0],['EQ',0],['GT',0]];
const program=(worker,input=1)=>({$:'P111Program',segments:list([seg('main',0,[alloc,...jump('worker',[word(input)])]),worker,dead]),
  constructors:list(core.map(([name,arity])=>({$:'N_Constructor',name,arity,hot:arity>0}))),show:list([0]),show_names:list([]),effects:list([]),pure:true});
const framed=[store(0,local('x')),frame,...failure(4)];
const worker=seg('worker',1,[...prefix,branch(result(word(7)),framed)]);
const controls=[];
function check(name,candidate,admitted,originalValid=true){
  const p=program(candidate),error=api.p111_verify_program(p);
  if(originalValid)assert.equal(error,'',name);
  assert.equal(api.p112w_admitted(api.p112w_plan(candidate,api.p112w_index(p.segments))),admitted,name);
  controls.push({name,originalValid:error==='',admitted,targetsExecuted:false});
}
check('framed-failure-side-exit',worker,true);
check('unframed-failure-side-exit',seg('worker',1,[...prefix,branch(result(word(7)),failure(1))]),true);
check('frame-before-successful-branch',seg('worker',1,[...prefix,store(0,local('x')),frame,branch(result(word(7)),failure(4))]),false);
check('frame-before-loopback',seg('worker',1,[...prefix,branch([store(0,local('x')),frame,...jump('worker',[local('x')])],failure(4))]),false);
check('failure-followed-by-result',seg('worker',1,[...prefix,call('ignored','p111_rt_fail',[state(),arg(w,word(4))]),...result(local('x'))]),false);
check('mismatched-failure-return',seg('worker',1,[...prefix,call('reply','p111_rt_fail',[state(),arg(w,word(4))]),ret('x')]),false);
check('invalid-failure-code',seg('worker',1,[...prefix,...failure(0)]),false,false);
check('state-buffer-in-failure',seg('worker',1,[...prefix,branch(result(word(7)),[
  call('ignored','p111_rt_op',[state(),arg(w,word(1)),state(),arg(w,word(2))]),...failure(4)])]),false);
const observations=[];
function emit(name,p,expected){
  assert.equal(api.p111_verify_program(p),'');
  const ids=api.p111q_ids(p),segments=unlist(p.segments),candidate=unlist(api.p112w_segment_chunks(p.segments,ids,list([])));
  assert.match(candidate[0],/call \$p112w_/);
  const privateText=candidate[1].slice(candidate[1].indexOf('function l $p112w_'));
  assert.match(privateText,/call \$p111_rt_fail/);
  const metadata=unlist(api.p111q_chunks(p)).slice(segments.length);
  fs.writeFileSync(path.join(outDir,name+'-baseline.ssa'),[...segments.map(s=>api.p111q_segment(s,ids)),...metadata].join(''));
  fs.writeFileSync(path.join(outDir,name+'-candidate.ssa'),[...candidate,...metadata].join(''));
  fs.writeFileSync(path.join(outDir,name+'.expected.json'),JSON.stringify(expected,null,2)+'\n');
  observations.push({name,...expected,counts:api.p112w_program_counts(p),targetsExecuted:false});
}
emit('successful-framed-alternative',program(worker,0),{status:0,stdout:'7\n',stderr:''});
emit('reachable-framed-failure',program(worker,1),{status:1,stdout:'',stderr:'bend: a function the device does not hold\n'});
emit('reachable-unframed-failure',program(seg('worker',1,[alloc,get('x',0),...failure(1)]),1),
  {status:1,stdout:'',stderr:'bend: runtime fail-stop\n'});
fs.writeFileSync(path.join(outDir,'report.json'),JSON.stringify({kind:'phase112-cpu-failstop-worker-controls',complete:true,
  requires:'phase112-cpu-failstop-worker-admission exact compiler/runtime receipt',controls,observations},null,2)+'\n');
console.log(JSON.stringify({complete:true,controls:controls.length,observations:observations.length}));
