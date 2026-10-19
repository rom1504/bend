// Synthetic checked-IR controls. Root alone executes this file and native pairs.
// The arithmetic/readback oracles are independent of the region planner.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const [apiFile,outDir]=process.argv.slice(2);
if(!apiFile||!outDir)throw Error('Usage: region-gap-if-controls.mjs API FRESH_OUT');
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
const bin=(name,op,left,right)=>({$:'N111Bin',name,typ:l,op,left,right});
const sink=value=>call('ignored','p111_rt_sink',[state(),arg(l,value)]);
const keep=(name,value)=>call(name,'p111_rt_keep',[state(),arg(l,value)]);
const jump=(name,vs)=>[...vs.map((v,i)=>store(i,v)),call('reply','p111_rt_jump',[state(),arg(w,{$:'N111FuncId',name}),scratch(),arg(w,word(vs.length))]),ret('reply')];
const result=value=>[store(0,value),call('reply','p111_rt_return',[state(),scratch(),arg(w,word(1))]),ret('reply')];
const frame=(name,vs)=>[...vs.map((v,i)=>store(i,v)),call('ignored','p111_rt_frame',[state(),arg(w,{$:'N111FuncId',name}),scratch(),arg(w,word(vs.length))])];
const ctor=(name,cid,count)=>call(name,'p111_rt_ctor',[state(),arg(w,{$:'N111CtorId',name:cid}),scratch(),arg(w,word(count))]);
const segment=(name,arity,body,incoming=0)=>({$:'N111Segment',name,arity,result:1,incoming,flags:0,body:list(body)});
const entry=(name,params,body)=>segment(name,params.length,[alloc,...params.map(get),...body]);
const continuation=(name,captures,res,body)=>segment(name,captures.length+1,[alloc,
  ...(captures.length?[call('ignored','p111_rt_stack_pop',[state(),arg(w,word(captures.length))])]:[]),
  ...captures.map((name,i)=>call(name,'p111_rt_stack_get',[state(),arg(w,word(i))])),get(res,0),...body],1);
const core=[['SNil',0],['SCon',2],['WNil',0],['WCon',2],['Nil',0],['Con',2],['Tuple',2],['Unit',0],
  ['None',0],['Some',1],['Fail',1],['Done',1],['Emit',1],['Halt',2],['True',0],['LT',0],['EQ',0],['GT',0]];
const program=(segments,string=false)=>({$:'P111Program',segments:list(segments),constructors:list(core.map(([name,arity])=>
  ({$:'N_Constructor',name,arity,hot:arity>0}))),show:list([string?4:0]),show_names:list([]),effects:list([]),pure:true});
const observations=[],controls=[];
const set=(name,value,typ=l)=>({$:'N111Set',name,typ,value});
const branch=(condition,yes,no)=>({$:'N111If',condition,yes:list(yes),no:list(no)});
const leaf=set('x',word(1));
const identity=entry('identity',['x'],result(local('x')));
const resume=continuation('resume',['old_x'],'value',[bin('high','mul',local('old_x'),word(1000)),bin('answer','add',local('high'),local('value')),...result(local('answer'))]);
for(const [outer,inner,padding,expected] of [[1,0,0,'11210'],[0,1,22,'11406']]){
  const innerTree=branch(word(inner),[bin('x','add',local('x'),word(3))],[bin('x','add',local('x'),word(5))]);
  const gap=[branch(word(outer),[set('x',word(100)),innerTree],[set('x',word(200)),innerTree]),
    ...Array.from({length:padding},(_,i)=>set('padding'+i,word(i))),bin('argument','mul',local('x'),word(2))];
  const main=entry('main',[],[set('x',word(11)),...frame('resume',[local('x')]),...gap,...jump('identity',[local('argument')])]);
  const p=program([main,identity,resume]),name=outer?'nested-yes-capture-prevalue':'nested-no-exact32';
  assert.equal(api.p111_verify_program(p),'',name+': original verifier');
  const index=api.p112c_index(p.segments),ids=api.p111q_ids(p);
  const transformed=api.p112c_plan_index(main,api.p112f_index(p.segments),index.ready);
  assert.equal(transformed.count,1,name+': fused');assert.equal(transformed.next,1);
  assert.ok(unlist(index.entries).some(e=>e.segment.name==='main'),name+': private caller');
  const gapSize=10+padding;
  assert.deepEqual(api.p112h_nodes(list(gap),32),{$:'Some',value:32-gapSize},name+': shared tree size');
  const candidate=unlist(api.p112c_segment_chunks(p.segments,ids,list([])));
  const metadata=unlist(api.p111q_chunks(p)).slice(3);
  fs.writeFileSync(path.join(outDir,name+'-baseline.ssa'),[...[main,identity,resume].map(s=>api.p111q_segment(s,ids)),...metadata].join(''));
  fs.writeFileSync(path.join(outDir,name+'-candidate.ssa'),[...candidate,...metadata].join(''));
  fs.writeFileSync(path.join(outDir,name+'.stdout'),expected+'\n');
  observations.push({name,expected:expected+'\n',gapTotalNodes:gapSize,targetsExecuted:false});
}
function check(name,body,expected){
  assert.deepEqual(api.p112h_nodes(list(body),32),expected,name);controls.push({name,passed:true});
}
check('pure-two-branches',[branch(word(1),[leaf],[leaf])],{$:'Some',value:29});
check('nested-tree-count',[branch(word(0),[branch(word(1),[leaf],[leaf])],[leaf])],{$:'Some',value:27});
for(const [yes,no,total] of [[15,15,31],[15,16,32],[16,16,33]]){
  const tree=branch(word(1),Array(yes).fill(leaf),Array(no).fill(leaf));
  check('shared-total-'+total,[tree],total<=32?{$:'Some',value:32-total}:{$:'None'});
  assert.equal(api.p112g_split(list([tree]),0,list([])).$,total<=32?'Some':'None');
}
check('siblings-share-budget',[branch(word(1),Array(8).fill(leaf),Array(8).fill(leaf)),branch(word(0),Array(8).fill(leaf),Array(8).fill(leaf))],{$:'None'});
for(const [name,stmt] of [
  ['keep',keep('x',word(7))],['sink',sink(word(7))],
  ['load',{$:'N111Load',name:'x',typ:l,base:local('scratch'),offset:0}],['store',store(0,word(7))],
  ['pointer',set('p',local('scratch'),ptr)],['state',set('x',local('state'))],
  ['unknown-call',call('x','unknown_effect',[])],['return',ret('x')],
  ['frame',call('ignored','p111_rt_frame',[state(),arg(w,{$:'N111FuncId',name:'resume'}),scratch(),arg(w,word(0))])],
])check('unselected-nested-'+name,[branch(word(1),[leaf],[branch(word(0),[leaf],[stmt])])],{$:'None'});
for(const [name,condition] of [
  ['state',local('state')],['scratch',local('scratch')],['generated-scratch',local('p112f_7_local_scratch')],
  ['symbol',{$:'N111FuncId',name:'identity'}],['high-constant',{$:'N111Const',lo:1,hi:1}],
]){
  assert.equal(api.p112h_condition(condition),false,name);
  check('invalid-condition-'+name,[branch(condition,[leaf],[leaf])],{$:'None'});
}
assert.equal(api.p112g_split(list([branch(word(1),[leaf],[leaf])]),31,list([])).$,'None');
controls.push({name:'prior-statements-share-branch-budget',passed:true});
const wrongTyped=program([entry('main',[],[set('condition',word(1)),branch(local('condition'),result(word(7)),result(word(9)))])]);
assert.notEqual(api.p111_verify_program(wrongTyped),'','original verifier rejects U64 local condition');
controls.push({name:'original-condition-typing-remains-mandatory',passed:true});
fs.writeFileSync(path.join(outDir,'report.json'),JSON.stringify({kind:'phase112-structured-pure-gap-controls',complete:true,
  sourceKind:'synthetic-verified-N111-ABI-witness',observations,controls,targetsExecuted:false},null,2)+'\n');
console.log(JSON.stringify({complete:true,observations:observations.length,controls:controls.length}));
