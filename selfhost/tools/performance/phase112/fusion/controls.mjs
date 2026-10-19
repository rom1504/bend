// Coordinator-only finite admission/emission controls and native fixture writer.
// All transformations execute the checked Bend API, never a JS optimizer.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const [apiFile,outDir]=process.argv.slice(2);
if(!apiFile||!outDir)throw Error('API FRESH_OUTPUT');
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
const set=(name,value)=>({$:'N111Set',name,typ:l,value});
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
const identity=entry('identity',['x'],result(local('x')));
const leaf=entry('leaf',['a','b'],[bin('scaled','mul',local('a'),word(10)),bin('answer','add',local('scaled'),local('b')),...result(local('answer'))]);
const resume=continuation('resume',['left','right'],'value',[bin('high','mul',local('left'),word(10000)),
  bin('low','mul',local('right'),word(100)),bin('partial','add',local('high'),local('low')),bin('answer','add',local('partial'),local('value')),...result(local('answer'))]);
const main=entry('main',[],[set('left',word(11)),set('right',word(22)),...frame('resume',[local('left'),local('right')]),...jump('leaf',[word(3),word(4)])]);
const good=program([main,leaf,resume]),observations=[],controls=[];
function counts(p){return api.p112f_program_counts(p);}
function emit(name,p,expected,count){
  assert.equal(api.p111_verify_program(p),'',name+': original verifier');
  assert.equal(counts(p),count,name+': actual admission count');
  const ids=api.p111q_ids(p),segments=unlist(p.segments);
  const baseline=unlist(api.p112w_segment_chunks(p.segments,ids,list([])));
  const candidate=unlist(api.p112f_segment_chunks(p.segments,ids,list([])));
  const metadata=unlist(api.p111q_chunks(p)).slice(segments.length);
  assert.notDeepEqual(candidate,baseline,name+': mechanism changed');
  assert.ok(candidate.join('').includes('p112f_0_capture_')||candidate.join('').includes('p112f_0_result'));
  assert.ok(candidate.join('').includes('p112f_0_local_scratch =l alloc8 2048'));
  fs.writeFileSync(path.join(outDir,name+'-baseline.ssa'),[...baseline,...metadata].join(''));
  fs.writeFileSync(path.join(outDir,name+'-candidate.ssa'),[...candidate,...metadata].join(''));
  fs.writeFileSync(path.join(outDir,name+'.stdout'),expected+'\n');
  observations.push({name,expected:expected+'\n',counts:count,targetsExecuted:false});
  return candidate;
}
const permutation=emit('capture-permutation',good,'112234','1/1')[0];
assert.doesNotMatch(permutation,/call \$p111_rt_(frame|stack_get|stack_pop|reg_get|jump)/);
const captureLast=permutation.indexOf('%v_p112f_0_capture_1 =l copy');
const argumentFirst=permutation.indexOf('%v_p112f_0_arg_0 =l copy');
const argumentLast=permutation.indexOf('%v_p112f_0_arg_1 =l copy');
const directCall=permutation.indexOf('%v_p112f_0_result =l call $p112w_');
assert.ok(captureLast>=0&&captureLast<argumentFirst&&argumentFirst<argumentLast&&argumentLast<directCall);
assert.ok(directCall<permutation.indexOf('%v_p112f_0_local_left =l copy'));
controls.push({name:'capture-and-argument-snapshots-before-call',passed:true},{name:'hygienic-locals-and-separate-scratch',passed:true});
const noCapture=continuation('resume',[],'value',[bin('answer','add',local('value'),word(1)),...result(local('answer'))]);
emit('zero-captures',program([entry('main',[],[...frame('resume',[]),...jump('identity',[word(42)])]),identity,noCapture]),'43','1/1');
const inner=continuation('inner',['held'],'value',[bin('answer','add',local('held'),local('value')),...result(local('answer'))]);
const outer=continuation('outer',['held'],'value',[bin('answer','add',local('held'),local('value')),...result(local('answer'))]);
const pending=emit('pending-outer',program([entry('main',[],[...frame('outer',[word(1000)]),...frame('inner',[word(100)]),...jump('identity',[word(42)])]),identity,inner,outer]),'1142','1/1')[0];
assert.equal((pending.match(/call \$p111_rt_frame/g)||[]).length,1,'outer frame retained');
controls.push({name:'outer-continuation-frame-retained',passed:true});
emit('frame-result-zero',program([entry('main',[],[...frame('inner',[word(100)]),...jump('identity',[local('ignored')])]),identity,inner]),'100','1/1');

function string(prefix,text){
  const body=[ctor(prefix+'0','SNil',0)];let at=prefix+'0',i=0;
  for(const char of [...text].reverse()){
    const next=prefix+(++i);body.push(store(0,word(char.codePointAt(0))),store(1,local(at)),ctor(next,'SCon',2));at=next;
  }
  return {body,value:local(at)};
}
const loop=entry('swap',['n','a','b'],[bin('done','eq',local('n'),word(0)),
  {$:'N111If',condition:local('done'),yes:list([sink(local('b')),...result(local('a'))]),
   no:list([bin('next','sub',local('n'),word(1)),...jump('swap',[local('next'),local('b'),local('a')])])}]);
for(const resultFirst of [true,false]){
  const a=string('shared','α😀');
  const owner=entry('main',[],[...a.body,keep('shared_owner',a.value),keep('shared_owner',local('shared_owner')),
    ...frame('resume',[local('shared_owner')]),...jump('swap',[word(100001),local('shared_owner'),local('shared_owner')])]);
  const resume=continuation('resume',['alias'],'value',[sink(local(resultFirst?'value':'alias')),...result(local(resultFirst?'alias':'value'))]);
  emit(resultFirst?'shared-result-first':'shared-alias-first',program([owner,loop,resume],true),'"α😀"','1/1');
}

// Refused graphs are never executed. Preserve structural-verifier status too;
// some intentionally malformed metadata is rejected at both boundaries.
function refuse(name,p){
  assert.equal(counts(p),'0/0',name+': no fusion');
  const ids=api.p111q_ids(p);
  assert.deepEqual(unlist(api.p112f_segment_chunks(p.segments,ids,list([]))),
    unlist(api.p112w_segment_chunks(p.segments,ids,list([]))),name+': exact fallback');
  controls.push({name,passed:true,originalError:api.p111_verify_program(p),fused:false});
}
const replaceBody=(s,body)=>({...s,body:list(body)}),rb=unlist(resume.body),mb=unlist(main.body);
refuse('late-register-read',program([main,leaf,replaceBody(resume,[...rb.slice(0,5),get('late',0),...rb.slice(5)])]));
refuse('raw-state-read',program([main,leaf,replaceBody(resume,[...rb.slice(0,5),{$:'N111Load',name:'raw',typ:l,base:local('state'),offset:0},...rb.slice(5)])]));
refuse('unknown-effect',program([main,leaf,replaceBody(resume,[...rb.slice(0,5),call('external','not_runtime',[]),...rb.slice(5)])]));
refuse('reserved-caller-local',program([replaceBody(main,[alloc,set('p112f_collision',word(0)),...mb.slice(1)]),leaf,resume]));
refuse('reserved-continuation-local',program([main,leaf,replaceBody(resume,[...rb.slice(0,5),set('p112f_collision',word(0)),...rb.slice(5)])]));
refuse('intervening-owner-operation',program([replaceBody(main,[...mb.slice(0,6),sink(word(0)),...mb.slice(6)]),leaf,resume]));
refuse('capture-store-order',program([replaceBody(main,mb.map((s,i)=>i===3?{...s,offset:8}:s)),leaf,resume]));
refuse('wrong-stack-pop',program([main,leaf,replaceBody(resume,rb.map((s,i)=>i===1?call('ignored','p111_rt_stack_pop',[state(),arg(w,word(1))]):s))]));
refuse('duplicate-capture-local',program([main,leaf,replaceBody(resume,rb.map((s,i)=>i===3?{...s,name:'left'}:s))]));
refuse('wrong-result-slot',program([main,leaf,replaceBody(resume,rb.map((s,i)=>i===4?get('value',1):s))]));
refuse('wrong-incoming-count',program([main,leaf,{...resume,incoming:0}]));
refuse('flagged-continuation',program([main,leaf,{...resume,flags:1}]));
refuse('nonprivate-target',program([main,replaceBody(leaf,[...unlist(leaf.body).slice(0,3),get('late',0),...unlist(leaf.body).slice(3)]),resume]));
refuse('continuation-size-bound',program([main,leaf,replaceBody(resume,[...rb.slice(0,5),...Array.from({length:129},(_,i)=>set('size'+i,word(i))),...rb.slice(5)])]));
const nineNames=Array.from({length:9},(_,i)=>'held'+i);
refuse('capture-count-bound',program([entry('main',[],[...frame('resume',nineNames.map((_,i)=>word(i))),...jump('identity',[word(1)])]),identity,
  continuation('resume',nineNames,'value',result(local('value')))]));
fs.writeFileSync(path.join(outDir,'report.json'),JSON.stringify({kind:'phase112-continuation-fusion-controls',complete:true,
  sourceKind:'synthetic-verified-N111-ABI-witness',controls,observations,targetsExecuted:false},null,2)+'\n');
console.log(JSON.stringify({complete:true,controls:controls.length,observations:observations.length}));
