// Synthetic checked-IR ABI witness, not a claim about actual source lowering.
// Root executes this transport and both emitted native variants under its guard.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const [apiFile,outDir]=process.argv.slice(2);
if(!apiFile||!outDir)throw Error('Usage: direct-loop-controls.mjs API FRESH_OUT');
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
const ctor=(name,cid,count)=>call(name,'p111_rt_ctor',[state(),arg(w,{$:'N111CtorId',name:cid}),scratch(),arg(w,word(count))]);
const segment=(name,arity,body,incoming=0)=>({$:'N111Segment',name,arity,result:1,incoming,flags:0,body:list(body)});
const loop=segment('swap',3,[alloc,get('n',0),get('a',1),get('b',2),bin('done','eq',local('n'),word(0)),
  {$:'N111If',condition:local('done'),yes:list([sink(local('b')),...result(local('a'))]),
   no:list([bin('next','sub',local('n'),word(1)),...jump('swap',[local('next'),local('b'),local('a')])])}]);
const core=[['SNil',0],['SCon',2],['WNil',0],['WCon',2],['Nil',0],['Con',2],['Tuple',2],['Unit',0],
  ['None',0],['Some',1],['Fail',1],['Done',1],['Emit',1],['Halt',2],['True',0],['LT',0],['EQ',0],['GT',0]];
const program=segments=>({$:'P111Program',segments:list(segments),constructors:list(core.map(([name,arity])=>
  ({$:'N_Constructor',name,arity,hot:arity>0}))),show:list([4]),show_names:list([]),effects:list([]),pure:true});
function string(prefix,text){
  const body=[ctor(prefix+'0','SNil',0)];let at=prefix+'0',i=0;
  for(const char of [...text].reverse()){
    const next=prefix+(++i);body.push(store(0,word(char.codePointAt(0))),store(1,local(at)),ctor(next,'SCon',2));at=next;
  }
  return {body,value:local(at)};
}
const observations=[];
function emit(name,p,expected){
  assert.equal(api.p111_verify_program(p),'',name);
  const ids=api.p111q_ids(p),ready=api.p112w_index(p.segments);
  assert.equal(api.p112w_admitted(api.p112w_plan(loop,ready)),true,name+': private loop admitted');
  const segments=unlist(p.segments),candidate=unlist(api.p112w_segment_chunks(p.segments,ids,list([])));
  const loopChunk=candidate[1],privateStart=loopChunk.indexOf('function l $p112w_');
  assert.ok(privateStart>=0,name+': targeted private worker exists');
  const privateText=loopChunk.slice(privateStart);
  assert.doesNotMatch(privateText,/call \$p111_rt_(jump|return|reg_get)/);
  assert.equal((privateText.match(/alloc8/g)||[]).length,1);
  assert.equal((privateText.match(/call \$p111_rt_sink/g)||[]).length,1);
  assert.ok(privateText.indexOf('%p112_arg_2 =l loadl')<privateText.indexOf('%v_n =l copy %p112_arg_0'));
  assert.match(candidate[0],/call \$p112w_/);
  assert.equal((candidate[0].match(/call \$p111_rt_return/g)||[]).length,1);
  const all=unlist(api.p111q_chunks(p)),metadata=all.slice(segments.length);
  const baseline=segments.map(s=>api.p111q_segment(s,ids));
  fs.writeFileSync(path.join(outDir,name+'-baseline.ssa'),[...baseline,...metadata].join(''));
  fs.writeFileSync(path.join(outDir,name+'-candidate.ssa'),[...candidate,...metadata].join(''));
  fs.writeFileSync(path.join(outDir,name+'.stdout'),expected+'\n');
  observations.push({name,expected:expected+'\n',counts:api.p112w_program_counts(p),privateLoop:true,targetsExecuted:false});
}
for(const [name,n,expected] of [['unique-odd',100001,'"β"'],['unique-even',100000,'"α😀"']]){
  const a=string('a','α😀'),b=string('b','β');
  emit(name,program([segment('main',0,[alloc,...a.body,...b.body,...jump('swap',[word(n),a.value,b.value])]),loop]),expected);
}
for(const resultFirst of [true,false]){
  const a=string('shared','α😀');
  const frame=call('ignored','p111_rt_frame',[state(),arg(w,{$:'N111FuncId',name:'resume'}),scratch(),arg(w,word(1))]);
  // Two keeps produce three owner credits: two loop inputs and one held alias.
  const main=segment('main',0,[alloc,...a.body,keep('shared_owner',a.value),keep('shared_owner',local('shared_owner')),
    store(0,local('shared_owner')),frame,...jump('swap',[word(100001),local('shared_owner'),local('shared_owner')])]);
  const resume=segment('resume',2,[alloc,call('ignored','p111_rt_stack_pop',[state(),arg(w,word(1))]),
    call('alias','p111_rt_stack_get',[state(),arg(w,word(0))]),get('value',0),
    sink(local(resultFirst?'value':'alias')),...result(local(resultFirst?'alias':'value'))],1);
  emit(resultFirst?'shared-result-first':'shared-alias-first',program([main,loop,resume]),'"α😀"');
}
fs.writeFileSync(path.join(outDir,'report.json'),JSON.stringify({kind:'phase112-private-owning-loop-controls',complete:true,
  sourceKind:'synthetic-verified-N111-ABI-witness',observations,targetsExecuted:false},null,2)+'\n');
console.log(JSON.stringify({complete:true,observations:observations.length,privateLoops:4}));
