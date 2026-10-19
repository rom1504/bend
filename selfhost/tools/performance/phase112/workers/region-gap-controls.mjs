// Synthetic checked-IR controls. Root alone executes this file and native pairs.
// The arithmetic/readback oracles are independent of the region planner.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const [apiFile,outDir]=process.argv.slice(2);
if(!apiFile||!outDir)throw Error('Usage: region-gap-controls.mjs API FRESH_OUT');
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
const identity=entry('identity',['x'],result(local('x')));
const found=(index,name)=>unlist(index.entries).find(e=>e.segment.name===name);
function emit(name,p,expected){
  assert.equal(api.p111_verify_program(p),'',name+': original verifier');
  const index=api.p112c_index(p.segments),segments=unlist(p.segments),ids=api.p111q_ids(p);
  const transformed=api.p112c_plan_index(segments[0],api.p112f_index(p.segments),index.ready);
  assert.equal(transformed.count,1,name+': one gap site');
  assert.equal(transformed.next,1,name+': one fresh site');
  assert.ok(found(index,'main'),name+': private main admitted');
  const candidate=unlist(api.p112c_segment_chunks(p.segments,ids,list([])));
  const metadata=unlist(api.p111q_chunks(p)).slice(segments.length);
  fs.writeFileSync(path.join(outDir,name+'-baseline.ssa'),[...segments.map(s=>api.p111q_segment(s,ids)),...metadata].join(''));
  fs.writeFileSync(path.join(outDir,name+'-candidate.ssa'),[...candidate,...metadata].join(''));
  fs.writeFileSync(path.join(outDir,name+'.stdout'),expected+'\n');
  observations.push({name,expected:expected+'\n',counts:api.p112c_program_counts(p),targetsExecuted:false});
  return unlist(transformed.body);
}
const resume=continuation('resume',['old_x','old_y'],'value',[
  bin('a','mul',local('old_x'),word(10000)),bin('b','mul',local('old_y'),word(100)),
  bin('ab','add',local('a'),local('b')),bin('answer','add',local('ab'),local('value')),...result(local('answer'))]);
const changed=emit('captures-before-gap-redefinitions',program([
  entry('main',[],[set('x',word(11)),set('y',word(22)),...frame('resume',[local('x'),local('y')]),
    set('x',word(100)),bin('y','add',local('x'),word(7)),bin('argument','mul',local('y'),word(2)),...jump('identity',[local('argument')])]),identity,resume]),'112414');
const position=predicate=>changed.findIndex(predicate);
assert.ok(position(s=>s.$==='N111Set'&&s.name==='p112f_0_capture_1')<position(s=>s.$==='N111Set'&&s.name==='ignored'));
assert.ok(position(s=>s.$==='N111Set'&&s.name==='ignored')<position(s=>s.$==='N111Set'&&s.name==='x'&&s.value.lo===100));
assert.ok(position(s=>s.$==='N111Bin'&&s.name==='argument')<position(s=>s.$==='N111Set'&&s.name==='p112f_0_arg_0'));
controls.push({name:'capture-zero-gap-argument-order',passed:true});

const zeroResume=continuation('resume',['old_x'],'value',[bin('high','mul',local('old_x'),word(100)),bin('answer','add',local('high'),local('value')),...result(local('answer'))]);
const zeroFrame=[store(0,local('x')),call('x','p111_rt_frame',[state(),arg(w,{$:'N111FuncId',name:'resume'}),scratch(),arg(w,word(1))])];
emit('frame-zero-before-gap-use',program([entry('main',[],[set('x',word(9)),...zeroFrame,
  bin('x','add',local('x'),word(5)),set('y',local('x')),bin('argument','mul',local('y'),word(3)),...jump('identity',[local('argument')])]),identity,zeroResume]),'915');

const exactGap=[set('g',word(0)),...Array.from({length:31},()=>bin('g','add',local('g'),word(1)))];
emit('exact-thirty-two-pure-statements',program([entry('main',[],[...frame('resume',[word(7)]),...exactGap,...jump('identity',[local('g')])]),identity,zeroResume]),'731');

function string(prefix,text){
  const body=[ctor(prefix+'0','SNil',0)];let at=prefix+'0',i=0;
  for(const char of [...text].reverse()){
    const next=prefix+(++i);body.push(store(0,word(char.codePointAt(0))),store(1,local(at)),ctor(next,'SCon',2));at=next;
  }
  return {body,value:local(at)};
}
for(const resultFirst of [true,false]){
  const a=string('shared','α😀');
  const main=entry('main',[],[...a.body,keep('owner',a.value),...frame('resume',[local('owner')]),
    set('chosen',local('owner')),...jump('identity',[local('chosen')])]);
  const done=continuation('resume',['alias'],'value',[sink(local(resultFirst?'value':'alias')),...result(local(resultFirst?'alias':'value'))]);
  emit(resultFirst?'pure-owner-copy-result-first':'pure-owner-copy-alias-first',program([main,identity,done],true),'"α😀"');
}

const pureSet=set('word',word(7)),pureBin=bin('word','add',local('word'),word(1));
for(const [name,stmt,expected] of [
  ['u64-set',pureSet,true],['u64-bin',pureBin,true],['u32-set',set('word',word(7),w),true],
  ['keep-call',keep('word',word(7)),false],['sink-call',sink(word(7)),false],
  ['memory-load',{$:'N111Load',name:'word',typ:l,base:local('scratch'),offset:0},false],
  ['memory-store',store(9,word(7)),false],['pointer-copy',set('p',local('scratch'),ptr),false],
  ['state-operand',set('word',local('state')),false],['scratch-operand',set('word',local('scratch')),false],
  ['generated-scratch-operand',set('word',local('p112f_7_local_scratch')),false],
  ['state-destination',set('state',word(7)),false],['symbol-operand',set('word',{$:'N111FuncId',name:'identity'}),false],
  ['inner-frame',call('ignored','p111_rt_frame',[state(),arg(w,{$:'N111FuncId',name:'resume'}),scratch(),arg(w,word(0))]),false],
]){
  assert.equal(api.p112g_pure(stmt),expected,name);
  controls.push({name:'pure-gate-'+name,passed:true});
}
assert.equal(api.p112g_split(list(exactGap),0,list([])).$,'Some','32 accepted');
assert.equal(api.p112g_split(list([...exactGap,pureSet]),0,list([])).$,'None','33 refused');
assert.equal(api.p112g_splice(list([pureSet]),2,list([pureBin])).$,'None','short generated scaffold refused');
assert.deepEqual(unlist(api.p112g_splice(list([pureSet,pureSet]),1,list([pureBin])).value),[pureSet,pureBin,pureSet],'exact splice position');
controls.push({name:'gap-budget-and-short-scaffold',passed:true});

function refusal(name,gap){
  const done=continuation('resume',[],'value',result(local('value')));
  const main=entry('main',[],[...frame('resume',[]),...gap,...jump('identity',[word(7)])]);
  const p=program([main,identity,done]);
  assert.equal(api.p111_verify_program(p),'',name+': original verifier');
  const index=api.p112c_index(p.segments);
  assert.equal(api.p112c_plan_index(main,api.p112f_index(p.segments),index.ready).count,0,name+': no gap fusion');
  assert.equal(found(index,'main'),undefined,name+': no private main');
  controls.push({name,passed:true,targetsExecuted:false});
}
refusal('thirty-three-gap-statements',[...exactGap,pureSet]);
refusal('keep-between-frame-and-arguments',[keep('word',word(7))]);
refusal('sink-between-frame-and-arguments',[sink(word(7))]);
refusal('load-between-frame-and-arguments',[{$:'N111Load',name:'word',typ:l,base:local('scratch'),offset:0}]);
refusal('extra-store-between-frame-and-arguments',[store(9,word(7))]);
refusal('pointer-between-frame-and-arguments',[set('p',local('scratch'),ptr)]);
fs.writeFileSync(path.join(outDir,'report.json'),JSON.stringify({kind:'phase112-pure-gap-fusion-controls',complete:true,
  sourceKind:'synthetic-verified-N111-ABI-witness',observations,controls,targetsExecuted:false},null,2)+'\n');
console.log(JSON.stringify({complete:true,observations:observations.length,controls:controls.length}));
