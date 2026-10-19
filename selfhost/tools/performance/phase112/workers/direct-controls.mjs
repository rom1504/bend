// Coordinator-only. JS prepares records and independent scalar oracles; the
// actual worker planning and machine generation execute checked Bend code.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const [apiFile,outDir]=process.argv.slice(2);
if(!apiFile||!outDir)throw Error('Usage: direct-controls.mjs API FRESH_OUT');
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
const jump=(name,vs)=>[...vs.map((v,i)=>store(i,v)),call('reply','p111_rt_jump',[state(),arg(w,{$:'N111FuncId',name}),scratch(),arg(w,word(vs.length))]),ret('reply')];
const result=value=>[store(0,value),call('reply','p111_rt_return',[state(),scratch(),arg(w,word(1))]),ret('reply')];
const seg=(name,params,body)=>({$:'N111Segment',name,arity:params.length,result:1,incoming:0,flags:0,body:list([alloc,...params.map(get),...body])});
const core=[['SNil',0],['SCon',2],['WNil',0],['WCon',2],['Nil',0],['Con',2],['Tuple',2],['Unit',0],
  ['None',0],['Some',1],['Fail',1],['Done',1],['Emit',1],['Halt',2],['True',0],['LT',0],['EQ',0],['GT',0]];
const program=segments=>({$:'P111Program',segments:list(segments),constructors:list(core.map(([name,arity])=>
  ({$:'N_Constructor',name,arity,hot:arity>0}))),show:list([0]),show_names:list([]),effects:list([]),pure:true});
const leaf=seg('leaf',['a','b'],[bin('scaled','mul',local('a'),word(100)),bin('answer','add',local('scaled'),local('b')),...result(local('answer'))]);
const middle=seg('middle',['a','b'],jump('leaf',[local('b'),local('a')]));
const main=seg('main',[],jump('middle',[word(11),word(22)]));
const unused=seg('unused',['a'],result(local('a')));
const original=program([main,middle,leaf,unused]),ids=api.p111q_ids(original);
assert.equal(api.p111_verify_program(original),'');
const ready=api.p112w_index(original.segments);
assert.equal(api.p112w_program_counts(original),'4/2');
for(const segment of [main,middle,leaf,unused])assert.equal(api.p112w_admitted(api.p112w_plan(segment,ready)),true);
const chunks=unlist(api.p112w_segment_chunks(original.segments,ids,list([])));
assert.equal(chunks.length,4);
assert.equal(chunks[3],api.p111q_segment(unused,ids),'untargeted public leaf stays exact');
assert.ok(chunks[2].startsWith(api.p111q_segment(leaf,ids)),'targeted leaf public body stays exact');
assert.equal((chunks.join('').match(/function l \$p112w_/g)||[]).length,2);
assert.equal((chunks[0].match(/call \$p111_rt_return/g)||[]).length,1);
assert.doesNotMatch(chunks[0],/call \$p111_rt_jump/);
assert.ok(chunks[0].indexOf('%p112_arg_1 =l loadl')<chunks[0].indexOf('%p112_result =l call'));
const privateMiddle=chunks[1].slice(chunks[1].indexOf('function l $p112w_'));
assert.doesNotMatch(privateMiddle,/call \$p111_rt_(return|jump|reg_get)/);
const controls=[{name:'three-rank-leaf-chain',admitted:true},{name:'targeted-private-only',admitted:true},
  {name:'public-return-boundary-preserved',admitted:true},{name:'argument-snapshots-before-call',admitted:true}];
function refusal(name,candidate,originalValid=true){
  const p=program([seg('main',[],jump(candidate.name,Array.from({length:candidate.arity},(_,i)=>word(i+1)))),candidate]);
  const err=api.p111_verify_program(p);
  if(originalValid)assert.equal(err,'',name);
  const index=api.p112w_index(p.segments);
  assert.equal(api.p112w_admitted(api.p112w_plan(candidate,index)),false,name);
  const emitted=unlist(api.p112w_segment_chunks(p.segments,api.p111q_ids(p),list([]))).join('');
  assert.doesNotMatch(emitted,/function l \$p112w_/,name+': no private worker');
  controls.push({name,originalValid:err==='',admitted:false});
}
refusal('arity-nine',seg('wide',Array.from({length:9},(_,i)=>'p'+i),result(local('p8'))));
refusal('flagged-worker',{...leaf,flags:1});
const leafBody=unlist(leaf.body);
refusal('late-register-read',{...leaf,body:list([...leafBody.slice(0,3),get('late',0),...leafBody.slice(3)])});
refusal('state-load',{...leaf,body:list([...leafBody.slice(0,3),{$:'N111Load',name:'stateword',typ:l,base:local('state'),offset:0},...leafBody.slice(3)])});
refusal('extra-alloca',{...leaf,body:list([...leafBody.slice(0,3),{$:'N111Alloca',name:'extra',bytes:8,align:8},...leafBody.slice(3)])});
refusal('bare-machine-return',seg('bare',['a'],[ret('a')]));
refusal('malformed-return-buffer',{...leaf,body:list(leafBody.map(x=>x.$==='N111Store'?{...x,offset:8}:x))});
refusal('return-failure-is-not-term',seg('fail',[],[call('reply','p111_rt_fail',[state(),arg(w,word(4))]),ret('reply')]));
const cycleA=seg('cycleA',['x'],jump('cycleB',[local('x')])),cycleB=seg('cycleB',['x'],jump('cycleA',[local('x')]));
const cycle=program([seg('main',[],jump('cycleA',[word(1)])),cycleA,cycleB]);
assert.equal(api.p111_verify_program(cycle),'');assert.equal(api.p112w_program_counts(cycle),'0/0');
controls.push({name:'mutual-cycle-falls-back',admitted:false});
const d0=seg('d0',['x'],result(local('x'))),d1=seg('d1',['x'],jump('d0',[local('x')])),
  d2=seg('d2',['x'],jump('d1',[local('x')])),d3=seg('d3',['x'],jump('d2',[local('x')]));
const deep=program([seg('main',[],jump('d3',[word(7)])),d3,d2,d1,d0]);
assert.equal(api.p111_verify_program(deep),'');assert.equal(api.p112w_program_counts(deep),'3/3');
controls.push({name:'bounded-three-pass-depth',admitted:true});
const owned=seg('owned',['a','b'],[call('kept','p111_rt_keep',[state(),arg(l,local('b'))]),
  call('ignored','p111_rt_sink',[state(),arg(l,local('a'))]),
  call('ignored','p111_rt_sink',[state(),arg(l,local('kept'))]),...result(local('b'))]);
const owning=program([seg('main',[],jump('owned',[word(11),word(22)])),owned]);
assert.equal(api.p111_verify_program(owning),'');
const ownText=unlist(api.p112w_segment_chunks(owning.segments,api.p111q_ids(owning),list([])))[1];
assert.equal((ownText.match(/call \$p111_rt_keep/g)||[]).length,2);
assert.equal((ownText.match(/call \$p111_rt_sink/g)||[]).length,4);
controls.push({name:'owning-helpers-preserved-in-both-abis',admitted:true});
const observations=[];
function fixture(name,p,expected){
  assert.equal(api.p111_verify_program(p),'',name);
  const fid=api.p111q_ids(p),segments=unlist(p.segments),all=unlist(api.p111q_chunks(p)),metadata=all.slice(segments.length);
  const baseline=segments.map(s=>api.p111q_segment(s,fid));
  const candidate=unlist(api.p112w_segment_chunks(p.segments,fid,list([])));
  fs.writeFileSync(path.join(outDir,name+'-baseline.ssa'),[...baseline,...metadata].join(''));
  fs.writeFileSync(path.join(outDir,name+'-candidate.ssa'),[...candidate,...metadata].join(''));
  fs.writeFileSync(path.join(outDir,name+'.stdout'),expected+'\n');
  observations.push({name,expected:expected+'\n',counts:api.p112w_program_counts(p)});
}
fixture('ordered-chain',original,'2211');
fixture('ownership-calls',owning,'22');
// Public continuation state survives a direct call; captured100 plus result42.
const frame=call('ignored','p111_rt_frame',[state(),arg(w,{$:'N111FuncId',name:'resume'}),scratch(),arg(w,word(1))]);
const resume={$:'N111Segment',name:'resume',arity:2,result:1,incoming:1,flags:0,body:list([alloc,
  call('ignored','p111_rt_stack_pop',[state(),arg(w,word(1))]),call('held','p111_rt_stack_get',[state(),arg(w,word(0))]),
  get('value',0),bin('answer','add',local('held'),local('value')),...result(local('answer'))])};
fixture('pending-continuation',program([seg('main',[],[store(0,word(100)),frame,...jump('identity',[word(42)])]),
  seg('identity',['x'],result(local('x'))),resume]),'142');
// Eight owned args force state+8 words beyond the six SysV integer registers.
const params=Array.from({length:8},(_,i)=>'p'+i),weighted=[];
for(let i=0;i<8;i++){weighted.push(bin('part'+i,'mul',local(params[i]),word(10**i)));if(i)weighted.push(bin('sum'+i,'add',local(i===1?'part0':'sum'+(i-1)),local('part'+i)));}
fixture('eight-argument-order',program([seg('main',[],jump('wide8',params.map((_,i)=>word(i+1)))),seg('wide8',params,[...weighted,...result(local('sum7'))])]),'87654321');
fs.writeFileSync(path.join(outDir,'report.json'),JSON.stringify({kind:'phase112-direct-worker-controls',complete:true,controls,observations,targetsExecuted:false},null,2)+'\n');
console.log(JSON.stringify({complete:true,controls:controls.length,observations:observations.length}));
