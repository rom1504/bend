// Coordinator-only checked Bend API controls. JS constructs records/oracles;
// admission and candidate emission execute the actual Bend implementations.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const [apiFile,outDir,registerMode="runtime"] = process.argv.slice(2);
if (!apiFile || !outDir) throw Error('Usage: controls.mjs API.mjs FRESH_OUT');
const api = (await import(pathToFileURL(path.resolve(apiFile)).href)).default;
fs.mkdirSync(outDir);
const list = xs => xs.reduceRight((tail,head)=>({$: 'Con',head,tail}),{$:'Nil'});
const unlist = xs => { const out=[]; while(xs.$==='Con'){out.push(xs.head);xs=xs.tail;} assert.equal(xs.$,'Nil');return out; };
const l={$:'N111U64'},w={$:'N111U32'},ptr={$:'N111Ptr'};
const local=name=>({$:'N111Local',name});
const word=n=>({$:'N111Const',lo:n,hi:0});
const arg=(typ,value)=>({$:'N111Arg',typ,value});
const state=()=>arg(ptr,local('state'));
const scratch=()=>arg(ptr,local('scratch'));
const call=(name,symbol,args)=>({$:'N111Call',name,typ:l,symbol,args:list(args)});
const ret=name=>({$:'N111Return',value:local(name)});
const store=(i,value)=>({$:'N111Store',typ:l,base:local('scratch'),offset:8*i,value});
const alloc={$:'N111Alloca',name:'scratch',bytes:2048,align:8};
const get=(name,i)=>call(name,'p111_rt_reg_get',[state(),arg(w,word(i))]);
const bin=(name,op,left,right)=>({$:'N111Bin',name,typ:l,op,left,right});
const jump=(target,values)=>[...values.map((v,i)=>store(i,v)),
  call('reply','p111_rt_jump',[state(),arg(w,{$:'N111FuncId',name:target}),scratch(),arg(w,word(values.length))]),ret('reply')];
const result=value=>[store(0,value),call('reply','p111_rt_return',[state(),scratch(),arg(w,word(1))]),ret('reply')];
const segment=(name,arity,body)=>({$:'N111Segment',name,arity,result:1,incoming:0,flags:0,body:list(body)});
const tail=jump('swap_loop',[local('next'),local('b'),local('a')]);
const exit=[bin('scaled','mul',local('a'),word(100)),bin('answer','add',local('scaled'),local('b')),...result(local('answer'))];
const loop=segment('swap_loop',3,[alloc,get('n',0),get('a',1),get('b',2),
  bin('done','eq',local('n'),word(0)),
  {$:'N111If',condition:local('done'),yes:list(exit),no:list([bin('next','sub',local('n'),word(1)),...tail])}]);
const main=segment('main',0,[alloc,...jump('swap_loop',[word(100001),word(11),word(22)])]);
const core=[['SNil',0],['SCon',2],['WNil',0],['WCon',2],['Nil',0],['Con',2],['Tuple',2],['Unit',0],
  ['None',0],['Some',1],['Fail',1],['Done',1],['Emit',1],['Halt',2],['True',0],['LT',0],['EQ',0],['GT',0]];
const program=segments=>({$:'P111Program',segments:list(segments),constructors:list(core.map(([name,arity])=>
  ({$:'N_Constructor',name,arity,hot:arity>0}))),show:list([0]),show_names:list([]),effects:list([]),pure:true});
const original=program([main,loop]),ids=api.p111q_ids(original);
assert.equal(api.p111_verify_program(original),'');
assert.equal(api.p112t_admitted(api.p112t_plan(loop)),true);
assert.equal(api.p112t_program_counts(original),'1/1');
const oldText=api.p111q_segment(loop,ids),newText=api.p112q_segment(loop,ids);
assert.match(newText,/jmp @p112_again/);
assert.doesNotMatch(newText,/call \$p111_rt_jump/);
assert.equal((newText.match(/call \$p111_rt_reg_get/g)??[]).length,registerMode==="direct"?0:3);
assert.equal((newText.match(/alloc8/g)??[]).length,1);
assert.ok(newText.indexOf('%p112_arg_2 =l loadl')<newText.indexOf('%v_n =l copy %p112_arg_0'));
assert.match(oldText,/call \$p111_rt_jump/);
const controls=[];
function refusal(name,candidate,validOriginal=true) {
  const p=program([main,candidate]);
  const err=api.p111_verify_program(p);
  if(validOriginal) assert.equal(err,'',name+': original should be well typed');
  assert.equal(api.p112t_admitted(api.p112t_plan(candidate)),false,name);
  assert.equal(api.p112q_segment(candidate,api.p111q_ids(p)),api.p111q_segment(candidate,api.p111q_ids(p)),name+': exact fallback');
  controls.push({name,originalValid:err==='',candidateAdmitted:false,fallbackExact:true});
}
const changeBody=f=>({...loop,body:list(f(unlist(loop.body)))});
refusal('bang-flags',{...loop,flags:1});
refusal('incoming-continuation',{...loop,incoming:3},false);
refusal('wrong-prelude-order',changeBody(xs=>[xs[0],xs[2],xs[1],...xs.slice(3)]));
refusal('duplicate-param-local',changeBody(xs=>[xs[0],xs[1],get('n',1),...xs.slice(3)]),false);
refusal('late-register-read',changeBody(xs=>[...xs.slice(0,4),get('again_n',0),...xs.slice(4)]));
refusal('state-load',changeBody(xs=>[...xs.slice(0,4),{$:'N111Load',name:'borrowed_state',typ:l,base:local('state'),offset:0},...xs.slice(4)]));
refusal('extra-allocation',changeBody(xs=>[...xs.slice(0,4),{$:'N111Alloca',name:'extra',bytes:8,align:8},...xs.slice(4)]));
refusal('bare-return',changeBody(xs=>[...xs.slice(0,5),{...xs[5],yes:list([ret('a')])}]));
refusal('changed-store-order',changeBody(xs=>{const no=unlist(xs[5].no);[no[1],no[2]]=[no[2],no[1]];return [...xs.slice(0,5),{...xs[5],no:list(no)}];}));
refusal('missing-return',changeBody(xs=>{const no=unlist(xs[5].no);no.pop();return [...xs.slice(0,5),{...xs[5],no:list(no)}];}),false);
refusal('malformed-scratch',changeBody(xs=>[{...xs[0],bytes:64},...xs.slice(1)]));
// A malformed count must still fail the original mandatory gate.
const bad=changeBody(xs=>{const no=unlist(xs[5].no),j=no.length-2,args=unlist(no[j].args);args[3]=arg(w,word(2));no[j]={...no[j],args:list(args)};return [...xs.slice(0,5),{...xs[5],no:list(no)}];});
assert.notEqual(api.p111_verify_program(program([main,bad])),'');
controls.push({name:'mandatory-original-arity-check',originalValid:false});
// Keep and sink operations survive verbatim in an admitted loop.
const owning=changeBody(xs=>[...xs.slice(0,4),call('kept','p111_rt_keep',[state(),arg(l,local('a'))]),
  call('ignored','p111_rt_sink',[state(),arg(l,local('kept'))]),...xs.slice(4)]);
assert.equal(api.p111_verify_program(program([main,owning])),'');
assert.equal(api.p112t_admitted(api.p112t_plan(owning)),true);
const owningText=api.p112q_segment(owning,api.p111q_ids(program([main,owning])));
for(const name of ['keep','sink'])assert.equal((owningText.match(new RegExp('call \\$p111_rt_'+name,'g'))??[]).length,1);
controls.push({name:'keep-sink-preserved',originalValid:true,candidateAdmitted:true});
// Use unchanged metadata generation and only substitute the function chunks.
const oldChunks=unlist(api.p111q_chunks(original));
oldChunks[0]=api.p111q_segment(main,ids);oldChunks[1]=oldText;
const newChunks=[...oldChunks];newChunks[0]=api.p112q_segment(main,ids);newChunks[1]=newText;
fs.writeFileSync(path.join(outDir,'baseline.ssa'),oldChunks.join(''));
fs.writeFileSync(path.join(outDir,'candidate.ssa'),newChunks.join(''));
fs.writeFileSync(path.join(outDir,'expected.stdout'),'2211\n');
fs.writeFileSync(path.join(outDir,'report.json'),JSON.stringify({kind:'phase112-tail-loop-source-controls',complete:true,
  controls,admittedSegments:1,admittedLoops:1,independentExpected:'2211\n',targetsExecuted:false},null,2)+'\n');
console.log(JSON.stringify({complete:true,controls:controls.length,admittedSegments:1,admittedLoops:1}));
