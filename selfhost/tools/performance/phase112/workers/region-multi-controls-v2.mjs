// Synthetic checked-IR controls. Root alone executes this file and native pairs.
// The arithmetic/readback oracles are independent of the region planner.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const [apiFile,outDir]=process.argv.slice(2);
if(!apiFile||!outDir)throw Error('Usage: region-multi-controls-v2.mjs API FRESH_OUT');
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
const entries=index=>unlist(index.entries);
const found=(index,name)=>entries(index).find(e=>e.segment.name===name);
function allStmts(body){
  return unlist(body).flatMap(stmt=>stmt.$==='N111If'?[stmt,...allStmts(stmt.yes),...allStmts(stmt.no)]:[stmt]);
}
function checkFreeze(p,index,name){
  const candidates=api.p112c_candidates(p.segments,list([]));
  const originalIndex=api.p112f_index(p.segments);
  let rounds=api.p112c_index(list([]));
  for(let rank=1;rank<=6;rank++){
    const old=entries(rounds);
    rounds=api.p112c_round(candidates,originalIndex,rounds,rank,1);
    for(const prior of old)assert.deepEqual(found(rounds,prior.segment.name),prior,name+': frozen round '+rank);
  }
  assert.deepEqual(rounds,index,name+': six immutable rounds');
}
function emit(name,p,expected,siteCount,privateMain=true){
  assert.equal(api.p111_verify_program(p),'',name+': mandatory original verifier');
  const index=api.p112c_index(p.segments),segments=unlist(p.segments),ids=api.p111q_ids(p);
  checkFreeze(p,index,name);
  const transformed=api.p112c_plan_index(segments[0],api.p112f_index(p.segments),index.ready);
  assert.equal(transformed.count,siteCount,name+': site budget/count');
  assert.equal(transformed.next,siteCount,name+': global next-site counter');
  const buffers=allStmts(transformed.body).filter(s=>s.$==='N111Alloca'&&s.name!=='scratch').map(s=>s.name);
  assert.deepEqual(buffers,[...Array(siteCount)].map((_,i)=>'p112f_'+i+'_local_scratch'),name+': exact unique scratch names');
  assert.equal(Boolean(found(index,'main')),privateMain,name+': private main admission');
  if(privateMain)assert.equal(found(index,'main').sites,siteCount,name+': frozen site count');
  const candidate=unlist(api.p112c_segment_chunks(p.segments,ids,list([])));
  assert.equal(candidate.length,segments.length,name+': chunk boundary');
  const baseline=segments.map(s=>api.p111q_segment(s,ids));
  assert.notDeepEqual(candidate,baseline,name+': actual transformation');
  const metadata=unlist(api.p111q_chunks(p)).slice(segments.length);
  fs.writeFileSync(path.join(outDir,name+'-baseline.ssa'),[...baseline,...metadata].join(''));
  fs.writeFileSync(path.join(outDir,name+'-candidate.ssa'),[...candidate,...metadata].join(''));
  fs.writeFileSync(path.join(outDir,name+'.stdout'),expected+'\n');
  observations.push({name,expected:expected+'\n',sites:siteCount,privateMain,counts:api.p112c_program_counts(p),targetsExecuted:false});
  return {index,candidate,transformed};
}
const identity=entry('identity',['x'],result(local('x')));
const increment=entry('increment',['x'],[bin('next','add',local('x'),word(1)),...result(local('next'))]);
const pairNumber=entry('pair_number',['a','b'],[bin('high','mul',local('a'),word(10)),bin('answer','add',local('high'),local('b')),...result(local('answer'))]);

// Each stage permutes prior captures before the next call. The independent
// oracle observes a=11,b=22,r1=34,r2=231,r3=571 in the final arithmetic result.
const permutationMain=entry('main',[],[...frame('first',[word(11),word(22)]),...jump('pair_number',[word(3),word(4)])]);
const first=continuation('first',['a','b'],'r1',[...frame('second',[local('b'),local('r1'),local('a')]),...jump('pair_number',[local('b'),local('a')])]);
const second=continuation('second',['b','r1','a'],'r2',[...frame('third',[local('r2'),local('a'),local('b'),local('r1')]),...jump('pair_number',[local('r1'),local('r2')])]);
const third=continuation('third',['r2','a','b','r1'],'r3',[
  bin('ta','mul',local('a'),word(1000000)),bin('tb','mul',local('b'),word(10000)),bin('tr1','mul',local('r1'),word(100)),
  bin('ab','add',local('ta'),local('tb')),bin('ab1','add',local('ab'),local('tr1')),bin('ab12','add',local('ab1'),local('r2')),
  bin('answer','add',local('ab12'),local('r3')),...result(local('answer'))]);
emit('three-sequential-capture-permutations',program([permutationMain,pairNumber,first,second,third]),'11224202',3);

const yes1=continuation('yes1',[],'value',[bin('next','add',local('value'),word(100)),...frame('yes2',[]),...jump('increment',[local('next')])]);
const yes2=continuation('yes2',[],'value',[bin('answer','add',local('value'),word(1000)),...result(local('answer'))]);
const no1=continuation('no1',[],'value',[bin('next','add',local('value'),word(200)),...frame('no2',[]),...jump('increment',[local('next')])]);
const no2=continuation('no2',[],'value',[bin('answer','add',local('value'),word(2000)),...result(local('answer'))]);
for(const [condition,expected] of [[1,'1112'],[0,'2222']]){
  const main=entry('main',[],[{$:'N111If',condition:word(condition),
    yes:list([...frame('yes1',[]),...jump('increment',[word(10)])]),
    no:list([...frame('no1',[]),...jump('increment',[word(20)])])}]);
  emit(condition?'branch-yes-fresh-sites':'branch-no-fresh-sites',program([main,increment,yes1,yes2,no1,no2]),expected,4);
}

function string(prefix,text){
  const body=[ctor(prefix+'0','SNil',0)];let at=prefix+'0',i=0;
  for(const char of [...text].reverse()){
    const next=prefix+(++i);body.push(store(0,word(char.codePointAt(0))),store(1,local(at)),ctor(next,'SCon',2));at=next;
  }
  return {body,value:local(at)};
}
for(const resultFirst of [true,false]){
  const a=string('shared','α😀');
  const main=entry('main',[],[...a.body,keep('owner',a.value),...frame('alias1',[local('owner')]),...jump('identity',[local('owner')])]);
  const one=continuation('alias1',['alias'],'value',[...frame('alias2',[local('alias')]),...jump('identity',[local('value')])]);
  const two=continuation('alias2',['alias'],'value',[...frame('alias3',[local('alias')]),...jump('identity',[local('value')])]);
  const three=continuation('alias3',['alias'],'value',[sink(local(resultFirst?'value':'alias')),...result(local(resultFirst?'alias':'value'))]);
  emit(resultFirst?'alias-chain-result-first':'alias-chain-alias-first',program([main,identity,one,two,three],true),'"α😀"',3);
}

function chain(count){
  const main=entry('main',[],[...frame('chain0',[]),...jump('increment',[word(0)])]);
  const conts=Array.from({length:count},(_,i)=>continuation('chain'+i,[],'value',
    i===count-1?result(local('value')):[...frame('chain'+(i+1),[]),...jump('increment',[local('value')])]));
  return program([main,increment,...conts]);
}
emit('exact-eight-site-budget',chain(8),'8',8);
emit('ninth-call-generic-fallthrough',chain(9),'9',8,false);

// This continuation graph is cyclic, but the original program terminates by
// decreasing the captured counter. Bounded fusion must retain generic progress.
const cycle=continuation('cycle',['left'],'value',[bin('done','eq',local('left'),word(0)),
  {$:'N111If',condition:local('done'),yes:list(result(local('value'))),no:list([
    bin('next_left','sub',local('left'),word(1)),...frame('cycle',[local('next_left')]),...jump('increment',[local('value')])])}]);
emit('cyclic-continuation-budget-fallthrough',program([entry('main',[],[...frame('cycle',[word(20)]),...jump('increment',[word(0)])]),increment,cycle]),'21',8,false);

function refuse(name,p,workerNames){
  assert.equal(api.p111_verify_program(p),'',name+': original verifier');
  const index=api.p112c_index(p.segments);
  for(const worker of workerNames)assert.equal(found(index,worker),undefined,name+': private '+worker+' refused');
  controls.push({name,passed:true,targetsExecuted:false});
}
const selfResume=continuation('self_resume',[],'value',result(local('value')));
refuse('non-tail-private-self-cycle',program([entry('main',[],jump('recursive',[word(1)])),
  entry('recursive',['x'],[...frame('self_resume',[]),...jump('recursive',[local('x')])]),selfResume]),['main','recursive']);
refuse('non-tail-private-mutual-cycle',program([entry('main',[],jump('a',[word(1)])),
  entry('a',['x'],[...frame('a_resume',[]),...jump('b',[local('x')])]),entry('b',['x'],[...frame('b_resume',[]),...jump('a',[local('x')])]),
  continuation('a_resume',[],'value',result(local('value'))),continuation('b_resume',[],'value',result(local('value')))]),['main','a','b']);
const collision=entry('main',[],[{$:'N111Set',name:'p112f_0_result',typ:l,value:word(99)},...frame('resume',[]),...jump('identity',[word(1)])]);
refuse('reserved-generated-namespace',program([collision,identity,continuation('resume',[],'value',result(local('value')))]),['main']);
const late=continuation('resume',[],'value',[get('late',0),...result(local('value'))]);
refuse('late-transport-observation',program([entry('main',[],[...frame('resume',[]),...jump('identity',[word(1)])]),identity,late]),['main']);
for(const [padding,sites,admit] of [[125,2,true],[126,1,false]]){
  const main=entry('main',[],[...frame('pad_first',[]),...jump('identity',[word(7)])]);
  const padFirst=continuation('pad_first',[],'value',[...frame('pad_second',[]),...jump('identity',[local('value')])]);
  const padSecond=continuation('pad_second',[],'value',[
    ...Array.from({length:padding},(_,i)=>({$:'N111Set',name:'padding'+i,typ:l,value:word(i)})),...result(local('value'))]);
  const p=program([main,identity,padFirst,padSecond]);
  assert.equal(api.p111_verify_program(p),'','continuation-copy-size original verifier');
  const index=api.p112c_index(p.segments);
  const transformed=api.p112c_plan_index(main,api.p112f_index(p.segments),index.ready);
  assert.equal(transformed.count,sites,'continuation copy size '+(padding+3));
  assert.equal(Boolean(found(index,'main')),admit,'continuation copy size private gate '+(padding+3));
  controls.push({name:'continuation-size-'+(padding+3),passed:true,sites,privateMain:admit,targetsExecuted:false});
}
fs.writeFileSync(path.join(outDir,'report.json'),JSON.stringify({kind:'phase112-multiple-continuation-fusion-controls',complete:true,
  sourceKind:'synthetic-verified-N111-ABI-witness',observations,controls,targetsExecuted:false},null,2)+'\n');
console.log(JSON.stringify({complete:true,observations:observations.length,controls:controls.length}));
