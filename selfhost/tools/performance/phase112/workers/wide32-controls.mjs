// Synthetic ABI fixtures: every reordered argument is independently observed
// through ordinary runtime boxed-product readback, not a checksum.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const [apiFile,outDir]=process.argv.slice(2);
if(!apiFile||!outDir)throw Error('Usage: wide32-controls.mjs API FRESH_OUT');
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
const seg=(name,params,body)=>({$:'N111Segment',name,arity:params.length,result:1,incoming:0,flags:0,body:list([alloc,...params.map(get),...body])});
const core=[['SNil',0],['SCon',2],['WNil',0],['WCon',2],['Nil',0],['Con',2],['Tuple',2],['Unit',0],
  ['None',0],['Some',1],['Fail',1],['Done',1],['Emit',1],['Halt',2],['True',0],['LT',0],['EQ',0],['GT',0]];
function fixture(n){
  const params=Array.from({length:n},(_,i)=>'p'+i),values=Array.from({length:n},(_,i)=>1009+37*i);
  // Independent fixed permutations straddle stack/register boundaries twice.
  const first=[...params.keys()].filter(i=>i%2===1).reverse().concat([...params.keys()].filter(i=>i%2===0));
  const second=[...params.keys()].map(i=>(i+Math.floor(n/2)+1)%n).reverse();
  assert.equal(new Set(first).size,n);assert.equal(new Set(second).size,n);
  const leaf=seg('wide_leaf',params,[...params.map((p,i)=>store(i,local(p))),
    call('product','p111_rt_ctor',[state(),arg(w,{$:'N111CtorId',name:'WideTuple'}),scratch(),arg(w,word(n))]),...result(local('product'))]);
  const middle=seg('wide_middle',params,jump('wide_leaf',second.map(i=>local(params[i]))));
  const main=seg('main',[],jump('wide_middle',first.map(i=>word(values[i]))));
  const fields=second.map(i=>values[first[i]]),scalarOffset=6+2*n;
  const show=[7,1,1,0,core.length,n,...params.flatMap((_,i)=>[i,scalarOffset]),0];
  const program={$:'P111Program',segments:list([main,middle,leaf]),
    constructors:list([...core,['WideTuple',n]].map(([name,arity])=>({$:'N_Constructor',name,arity,hot:arity>0}))),
    show:list(show),show_names:list(['WideTuple']),effects:list([]),pure:true};
  return {program,leaf,middle,params,first,second,values,fields,expected:'WideTuple{'+fields.join(', ')+'}\n'};
}
const observations=[];
for(const n of [9,16,26,32]){
  const f=fixture(n),p=f.program;
  assert.equal(api.p111_verify_program(p),'','width'+n);
  assert.equal(api.p112w_program_counts(p),'3/2','width'+n);
  const ids=api.p111q_ids(p),ready=api.p112w_index(p.segments);
  for(const s of [f.leaf,f.middle])assert.equal(api.p112w_admitted(api.p112w_plan(s,ready)),true);
  const candidate=unlist(api.p112w_segment_chunks(p.segments,ids,list([])));
  for(const text of candidate.slice(1)){
    const privateText=text.slice(text.indexOf('function l $p112w_'));
    const header=privateText.split('\n')[0];
    assert.equal((header.match(/l %/g)||[]).length,n+1,'state plus all owned args');
    assert.doesNotMatch(privateText,/call \$p111_rt_(jump|return|reg_get)/);
  }
  assert.ok(candidate[0].indexOf('%p112_arg_'+(n-1)+' =l loadl')<candidate[0].indexOf('%p112_result =l call'));
  const middlePrivate=candidate[1].slice(candidate[1].indexOf('function l $p112w_'));
  assert.ok(middlePrivate.indexOf('%p112_arg_'+(n-1)+' =l loadl')<middlePrivate.indexOf('%p112_result =l call'));
  const metadata=unlist(api.p111q_chunks(p)).slice(3),segments=unlist(p.segments),name='arity-'+n;
  fs.writeFileSync(path.join(outDir,name+'-baseline.ssa'),[...segments.map(s=>api.p111q_segment(s,ids)),...metadata].join(''));
  fs.writeFileSync(path.join(outDir,name+'-candidate.ssa'),[...candidate,...metadata].join(''));
  fs.writeFileSync(path.join(outDir,name+'.stdout'),f.expected);
  observations.push({name,ownedArguments:n,machineArguments:n+1,firstPermutation:f.first,secondPermutation:f.second,
    originalValues:f.values,observedFields:f.fields,expected:f.expected,counts:'3/2',targetsExecuted:false});
}
const refused=fixture(33),rp=refused.program;
assert.equal(api.p111_verify_program(rp),'','width33 stays legal generic IR');
assert.equal(api.p112w_program_counts(rp),'0/0');
const rejectedIndex=api.p112w_index(rp.segments);
assert.equal(api.p112w_admitted(api.p112w_plan(refused.leaf,rejectedIndex)),false);
const rejected=unlist(api.p112w_segment_chunks(rp.segments,api.p111q_ids(rp),list([]))).join('');
assert.doesNotMatch(rejected,/function l \$p112w_/);
fs.writeFileSync(path.join(outDir,'report.json'),JSON.stringify({kind:'phase112-wide32-worker-controls',complete:true,
  sourceKind:'synthetic-verified-N111-ABI-witness',observations,refusals:[{ownedArguments:33,originalValid:true,admitted:false}],
  unrelatedLimits:{dependencyPasses:3,oneResult:true,incomingContinuation:false,flags:0,fusionArityUnchanged:8}},null,2)+'\n');
console.log(JSON.stringify({complete:true,observations:observations.length,refusals:1}));
