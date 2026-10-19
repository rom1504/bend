// Synthetic checked-IR controls. Root alone executes this file and native pairs.
// The arithmetic/readback oracles are independent of the region planner.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const [apiFile,outDir]=process.argv.slice(2);
if(!apiFile||!outDir)throw Error('Usage: region-controls.mjs API FRESH_OUT');
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
function registry(p){
  const index=api.p112r_index(p.segments);
  assert.equal(index.$,'P112RegionRegistry');
  return {...index,entries:unlist(index.entries)};
}
function admitted(index,name){return index.entries.find(e=>e.segment.name===name);}
function emit(name,p,expected,rankOrder){
  assert.equal(api.p111_verify_program(p),'',name+': original verifier');
  const index=registry(p),ids=api.p111q_ids(p),segments=unlist(p.segments);
  const ranks=rankOrder.map(n=>{
    const found=admitted(index,n);assert.ok(found,name+': frozen '+n);
    assert.equal(found.plan.valid,true,name+': admitted plan '+n);
    return found.rank;
  });
  for(let i=1;i<ranks.length;i++)assert.ok(ranks[i]>ranks[i-1],name+': previous-rank dependency');
  // Independently expose each immutable round: later admission cannot rewrite
  // any earlier segment, body, plan, site count or rank.
  const fusionIndex=api.p112f_index(p.segments);
  let rounds=api.p112r_index(list([]));
  for(let rank=1;rank<=6;rank++){
    const oldEntries=unlist(rounds.entries);
    rounds=api.p112r_round(p.segments,fusionIndex,rounds,rank,1);
    const newEntries=unlist(rounds.entries);
    for(const old of oldEntries)assert.deepEqual(newEntries.find(e=>e.segment.name===old.segment.name),old,
      name+': round '+rank+' preserves first entry '+old.segment.name);
  }
  assert.deepEqual(rounds,api.p112r_index(p.segments),name+': independent six-round construction');
  // Disconnected source additions must not change an existing first admission.
  const unrelated=entry('unrelated',['x'],result(local('x')));
  const extended=registry({...p,segments:list([...segments,unrelated])});
  for(const e of index.entries){
    const other=admitted(extended,e.segment.name);assert.ok(other);
    assert.deepEqual(other,e,name+': first frozen entry is stable');
  }
  const candidate=unlist(api.p112r_segment_chunks(p.segments,ids,list([])));
  assert.equal(candidate.length,segments.length,name+': metadata chunk boundary');
  const baseline=segments.map(s=>api.p111q_segment(s,ids));
  assert.notDeepEqual(candidate,baseline,name+': generated mechanism changed');
  assert.ok(candidate.join('').includes('call $p112w_'),name+': private calls emitted');
  assert.ok(candidate.join('').includes('p112f_0_result'),name+': a non-tail call was fused');
  const metadata=unlist(api.p111q_chunks(p)).slice(segments.length);
  fs.writeFileSync(path.join(outDir,name+'-baseline.ssa'),[...baseline,...metadata].join(''));
  fs.writeFileSync(path.join(outDir,name+'-candidate.ssa'),[...candidate,...metadata].join(''));
  fs.writeFileSync(path.join(outDir,name+'.stdout'),expected+'\n');
  observations.push({name,expected:expected+'\n',counts:api.p112r_program_counts(p),
    firstRanks:Object.fromEntries(index.entries.map(e=>[e.segment.name,e.rank])),targetsExecuted:false});
  return {candidate,index};
}
const identity=entry('identity',['x'],result(local('x')));
const identityRegistry=registry(program([identity]));
const privateIdentity=call('p112f_0_result',api.p112w_symbol('identity'),[state(),arg(l,word(7))]);
assert.equal(api.p112r_private_call(privateIdentity,identityRegistry.symbols),true,'known exact private signature');
const privateMutants=[
  ['private-unknown-symbol',{...privateIdentity,symbol:'p112w_not_admitted'}],
  ['private-runtime-symbol',{...privateIdentity,symbol:'p111_rt_keep'}],
  ['private-wrong-result-type',{...privateIdentity,typ:w}],
  ['private-missing-state',{...privateIdentity,args:list([arg(l,word(7))])}],
  ['private-scratch-as-state',{...privateIdentity,args:list([scratch(),arg(l,word(7))])}],
  ['private-state-wrong-type',{...privateIdentity,args:list([arg(l,local('state')),arg(l,word(7))])}],
  ['private-missing-owned-word',{...privateIdentity,args:list([state()])}],
  ['private-extra-owned-word',{...privateIdentity,args:list([state(),arg(l,word(7)),arg(l,word(8))])}],
  ['private-owned-word-wrong-type',{...privateIdentity,args:list([state(),arg(w,word(7))])}],
  ['private-buffer-as-owned-word',{...privateIdentity,args:list([state(),scratch()])}],
];
for(const [name,stmt] of privateMutants){
  assert.equal(api.p112r_private_call(stmt,identityRegistry.symbols),false,name);
  controls.push({name,passed:true,targetsExecuted:false});
}
for(const [name,sites,expected] of [['scratch',0,true],['p112f_0_local_scratch',1,true],
  ['p112f_7_local_scratch',8,true],['p112f_0_local_scratch',0,false],['p112f_1_local_scratch',1,false],
  ['p112f_8_local_scratch',8,false],['p112f_00_local_scratch',1,false],['p112f_0_local_scratch_extra',1,false],['state',8,false]]){
  assert.equal(api.p112r_buffer(name,sites),expected,'exact buffer '+name+'/'+sites);
  controls.push({name:'buffer-'+name+'-'+sites,passed:true,targetsExecuted:false});
}
const leaf=entry('leaf',['x'],[bin('next','add',local('x'),word(1)),...result(local('next'))]);
const middle=entry('middle',['x'],[...frame('middle_resume',[]),...jump('leaf',[local('x')])]);
const middleResume=continuation('middle_resume',[],'value',[bin('twice','mul',local('value'),word(2)),...result(local('twice'))]);
const finalResume=continuation('final_resume',[],'value',[bin('answer','add',local('value'),word(100)),...result(local('answer'))]);
const nested=program([entry('main',[],[...frame('final_resume',[]),...jump('middle',[word(20)])]),middle,leaf,middleResume,finalResume]);
emit('nested-nontail-chain',nested,'142',['leaf','middle','main']);

const loopResume=continuation('loop_resume',['next_n'],'value',jump('loop',[local('next_n'),local('value')]));
const loop=entry('loop',['n','acc'],[bin('done','eq',local('n'),word(0)),
  {$:'N111If',condition:local('done'),yes:list(result(local('acc'))),no:list([
    bin('next_n','sub',local('n'),word(1)),...frame('loop_resume',[local('next_n')]),...jump('leaf',[local('acc')])])}]);
const loopOutput=emit('tail-loop-calls-leaf',program([entry('main',[],jump('loop',[word(10001),word(0)])),loop,leaf,loopResume]),'10001',['leaf','loop','main']);
const allLoopText=loopOutput.candidate.join('');
const loopPrivateStart=allLoopText.indexOf('function l $'+api.p112w_symbol('loop')+'(');
assert.ok(loopPrivateStart>=0,'frozen private loop definition exists');
const loopPrivateEnd=allLoopText.indexOf('\n}\n',loopPrivateStart);
assert.ok(loopPrivateEnd>=0,'frozen private loop definition closes');
const loopPrivate=allLoopText.slice(loopPrivateStart,loopPrivateEnd+3);
assert.ok(loopPrivate.includes('@p112_again'),'private loop emitted');
assert.doesNotMatch(loopPrivate,/call \$p111_rt_(frame|stack_get|stack_pop|reg_get|jump|return)\(/,'private loop has no transport transitions');
controls.push({name:'tail-loop-private-call-and-local-backedge',passed:true});

const inner=continuation('inner',['held'],'value',[bin('answer','add',local('held'),local('value')),...result(local('answer'))]);
const outer=continuation('outer',['held'],'value',[bin('answer','add',local('held'),local('value')),...result(local('answer'))]);
const pending=emit('pending-outer',program([entry('main',[],[...frame('outer',[word(1000)]),...frame('inner',[word(100)]),...jump('identity',[word(42)])]),identity,inner,outer]),'1142',['identity']);
assert.equal((pending.candidate[0].match(/call \$p111_rt_frame\(/g)||[]).length,1,'pending outer frame stays live');
controls.push({name:'outer-frame-preserved',passed:true});

function string(prefix,text){
  const body=[ctor(prefix+'0','SNil',0)];let at=prefix+'0',i=0;
  for(const char of [...text].reverse()){
    const next=prefix+(++i);body.push(store(0,word(char.codePointAt(0))),store(1,local(at)),ctor(next,'SCon',2));at=next;
  }
  return {body,value:local(at)};
}
const ownedMiddle=entry('owned_middle',['x'],[...frame('owned_middle_resume',[]),...jump('identity',[local('x')])]);
const ownedMiddleResume=continuation('owned_middle_resume',[],'value',result(local('value')));
for(const resultFirst of [true,false]){
  const a=string('shared','α😀');
  const owner=entry('main',[],[...a.body,keep('owner',a.value),...frame('resume',[local('owner')]),...jump('owned_middle',[local('owner')])]);
  const resume=continuation('resume',['alias'],'value',[sink(local(resultFirst?'value':'alias')),...result(local(resultFirst?'alias':'value'))]);
  emit(resultFirst?'capture-alias-result-first':'capture-alias-alias-first',program([owner,ownedMiddle,identity,ownedMiddleResume,resume],true),'"α😀"',['identity','owned_middle','main']);
}

function refuseCycle(name,segments,names){
  const p=program(segments);assert.equal(api.p111_verify_program(p),'',name+': original verifier');
  const index=registry(p);for(const n of names)assert.equal(admitted(index,n),undefined,name+': '+n+' refused');
  const ids=api.p111q_ids(p),actual=unlist(api.p112r_segment_chunks(p.segments,ids,list([])));
  for(let i=0;i<segments.length;i++)assert.equal(actual[i],api.p111q_segment(segments[i],ids),name+': generic fallback');
  controls.push({name,passed:true,targetsExecuted:false});
}
const recurResume=continuation('recur_resume',[],'value',result(local('value')));
refuseCycle('non-tail-self-recursion',[entry('main',[],jump('recur',[word(1)])),entry('recur',['x'],[...frame('recur_resume',[]),...jump('recur',[local('x')])]),recurResume],['main','recur']);
refuseCycle('mutual-nontail-cycle',[entry('main',[],jump('a',[word(1)])),
  entry('a',['x'],[...frame('a_resume',[]),...jump('b',[local('x')])]),
  entry('b',['x'],[...frame('b_resume',[]),...jump('a',[local('x')])]),
  continuation('a_resume',[],'value',result(local('value'))),continuation('b_resume',[],'value',result(local('value')))],['main','a','b']);

// Forged private calls must never enter through the original checked graph.
for(const [name,symbol,args] of [
  ['forged-private-name','p112w_fake',[state(),arg(l,word(7))]],
  ['runtime-name-disguised-as-private','p111_rt_keep',[scratch(),arg(l,word(7))]],
  ['wrong-private-state','p112w_fake',[scratch(),arg(l,word(7))]],
  ['wrong-private-word-type','p112w_fake',[state(),arg(w,word(7))]],
]){
  const p=program([entry('main',[],[call('value',symbol,args),...result(local('value'))])]);
  assert.notEqual(api.p111_verify_program(p),'',name+': mandatory original verifier refuses');
  controls.push({name,passed:true,targetsExecuted:false});
}
fs.writeFileSync(path.join(outDir,'report.json'),JSON.stringify({kind:'phase112-rank-frozen-region-controls',complete:true,
  sourceKind:'synthetic-verified-N111-ABI-witness',observations,controls,targetsExecuted:false},null,2)+'\n');
console.log(JSON.stringify({complete:true,observations:observations.length,controls:controls.length}));
