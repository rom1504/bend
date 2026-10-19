// Root-run finite observation transport. Compiler algorithms stay in Bend.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL,fileURLToPath} from 'node:url';
const [baselineFile,candidateFile,outDir]=process.argv.slice(2);
if(!baselineFile||!candidateFile||!outDir)throw Error('Usage: controls.mjs BASE_API CANDIDATE_API FRESH_OUT');
const here=path.dirname(fileURLToPath(import.meta.url));
const data=JSON.parse(fs.readFileSync(path.join(here,'cases.json')));
const predicate=JSON.parse(fs.readFileSync(path.join(here,'predicate-cases.json')));
const expected=fs.readFileSync(path.join(here,'expected.stdout'),'utf8');
const pin=file=>{file=path.resolve(file);const raw=fs.readFileSync(file);return {file,bytes:raw.length,sha256:crypto.createHash('sha256').update(raw).digest('hex')};};
const inputs=[baselineFile,candidateFile,fileURLToPath(import.meta.url),path.join(here,'cases.json'),path.join(here,'predicate-cases.json'),path.join(here,'expected.stdout')].map(pin);
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const unlist=xs=>{const out=[];while(xs.$==='Con'){out.push(xs.head);xs=xs.tail;}assert.equal(xs.$,'Nil');return out;};
const l={$:'N111U64'},w={$:'N111U32'},ptr={$:'N111Ptr'};
const word=(lo,hi=0)=>({$:'N111Const',lo,hi});
const local=name=>({$:'N111Local',name});
const arg=(typ,value)=>({$:'N111Arg',typ,value});
const state=()=>arg(ptr,local('state'));
const scratch=()=>arg(ptr,local('scratch'));
const call=(name,symbol,args)=>({$:'N111Call',name,typ:l,symbol,args:list(args)});
const store=(i,value)=>({$:'N111Store',typ:l,base:local('scratch'),offset:8*i,value});
const load=(name,i)=>({$:'N111Load',name,typ:l,base:local('scratch'),offset:8*i});
const bin=(name,typ,op,left,right)=>({$:'N111Bin',name,typ,op,left,right});
const set=(name,value)=>({$:'N111Set',name,typ:l,value});
const branch=(condition,yes,no)=>({$:'N111If',condition:local(condition),yes:list(yes),no:list(no)});
const alloca=()=>({$:'N111Alloca',name:'scratch',bytes:2048,align:8});
const segment=(name,arity,body)=>({$:'N111Segment',name,arity,result:1,incoming:0,flags:0,body:list(body)});
const core=[['SNil',0],['SCon',2],['WNil',0],['WCon',2],['Nil',0],['Con',2],['Tuple',2],['Unit',0],
 ['None',0],['Some',1],['Fail',1],['Done',1],['Emit',1],['Halt',2],['True',0],['False',0],['LT',0],['EQ',0],['GT',0]];
const ctor=(dest,name,count)=>call(dest,'p111_rt_ctor',[state(),arg(w,{$:'N111CtorId',name}),scratch(),arg(w,word(count))]);
const keep=(dest,value)=>call(dest,'p111_rt_keep',[state(),arg(l,value)]);
const sink=(dest,value)=>call(dest,'p111_rt_sink',[state(),arg(l,value)]);
const take=value=>call('status','p111_rt_take',[state(),arg(l,value),scratch(),arg(w,word(2))]);
const finish=next=>[store(0,local('tail')),next===null?
 call('reply','p111_rt_return',[state(),scratch(),arg(w,word(1))]):
 call('reply','p111_rt_jump',[state(),arg(w,{$:'N111FuncId',name:next}),scratch(),arg(w,word(1))]),
 {$:'N111Return',value:local('reply')}];
function observation(row){
 switch(row.kind){
  case 'immediate': return [store(0,word(row.word.lo,row.word.hi)),
   // Unsupported bits identity forces an opaque full-word result before the
   // tested operation. The result/input alias must remain safe on both paths.
   call('result','p111_rt_op',[state(),arg(w,word(59)),scratch(),arg(w,word(1))]),
   call('result','p111_rt_'+row.operation,[state(),arg(l,local('result'))])];
  case 'shared-heap': return [store(0,word(123)),store(1,word(456)),ctor('owner','Tuple',2),
   keep('owner',local('owner')),sink('status',local('owner')),
   store(0,word(999)),store(1,word(998)),ctor('blocker','Tuple',2),
   take(local('owner')),load('result',0),sink('status',local('blocker'))];
  case 'unique-heap': return [store(0,word(123)),store(1,word(456)),ctor('owner','Tuple',2),sink('result',local('owner'))];
  case 'nested-heap': return [store(0,word(321)),store(1,word(654)),ctor('child','Tuple',2),
   store(0,local('child')),store(1,word(987)),ctor('owner','Tuple',2),keep('owner',local('owner')),
   take(local('owner')),load('child',0),sink('status',local('owner')),take(local('child')),load('result',0)];
  case 'captureless': return [call('owner','p111_rt_closure',[state(),arg(w,{$:'N111FuncId',name:'unused_closure'}),scratch(),arg(w,word(0))]),
   keep('alias',local('owner')),bin('same',l,'eq',local('owner'),local('alias')),
   branch('same',[set('result',word(1))],[set('result',word(0))]),sink('status',local('owner')),sink('status',local('alias'))];
  default: throw Error('Unknown finite case '+row.kind);
 }
}
function program(){
 const caseName=i=>'immediate_case_'+i;
 const segments=[segment('main',0,[alloca(),ctor('tail','SNil',0),...finish(caseName(data.cases.length-1))])];
 for(let index=data.cases.length-1;index>=0;--index){
  const body=[alloca(),call('tail','p111_rt_reg_get',[state(),arg(w,word(0))]),...observation(data.cases[index])];
  const prepend=value=>body.push(store(0,value),store(1,local('tail')),ctor('tail','SCon',2));
  prepend(word(59));
  for(let digit=0;digit<16;++digit){
   body.push(bin('shifted',l,'shr',local('result'),word(4*digit)),bin('nibble',l,'and',local('shifted'),word(15)),
    bin('decimal',l,'ult',local('nibble'),word(10)),
    branch('decimal',[bin('character',l,'add',local('nibble'),word(48))],[bin('character',l,'add',local('nibble'),word(87))]));
   prepend(local('character'));
  }
  body.push(...finish(index===0?null:caseName(index-1)));
  segments.push(segment(caseName(index),1,body));
 }
 segments.push(segment('unused_closure',1,[alloca(),call('tail','p111_rt_reg_get',[state(),arg(w,word(0))]),...finish(null)]));
 return {$:'P111Program',segments:list(segments),constructors:list(core.map(([name,arity])=>({$:'N_Constructor',name,arity,hot:arity>0}))),
  show:list([4]),show_names:list([]),effects:list([]),pure:true};
}
assert.equal(data.cases.length,28);assert.equal(predicate.cases.length,512);
for(const row of predicate.cases){
 const value=(BigInt(row.word.hi)<<32n)|BigInt(row.word.lo);
 assert.equal(value<144115188075855872n,row.fast);
 const rfc=(value&0x8000000000000000n)!==0n,tag=(value>>56n)&127n;
 assert.equal(!rfc&&tag<=1n,row.runtimeKeepPremise);assert.equal(row.fast,row.runtimeKeepPremise);
}
fs.mkdirSync(outDir);
const summaries=[];
for(const [name,file]of[['baseline',baselineFile],['candidate',candidateFile]]){
 const api=(await import(pathToFileURL(path.resolve(file)).href)).default;
 const graph=program();assert.equal(api.p111_verify_program(graph),'');
 if(name==='candidate'){
  const controls=unlist(api.p112i_control_report());assert.equal(controls.length,15);assert(controls.every(x=>x.startsWith('PASS ')));
  fs.writeFileSync(path.join(outDir,'structural-controls.json'),JSON.stringify(controls,null,2)+'\n');
 }
 const text=unlist(api.p111q_chunks(graph)).join('');
 const keeps=(text.match(/call \$p111_rt_keep\(/g)||[]).length,sinks=(text.match(/call \$p111_rt_sink\(/g)||[]).length;
 assert(keeps>0&&sinks>0);
 if(name==='candidate')assert(text.includes(', 144115188075855872\n'));
 fs.writeFileSync(path.join(outDir,name+'.ssa'),text);summaries.push({name,keeps,sinks,segments:data.cases.length+2});
}
fs.writeFileSync(path.join(outDir,'expected.stdout'),expected);
const outputs=['baseline.ssa','candidate.ssa','expected.stdout','structural-controls.json'].map(name=>pin(path.join(outDir,name)));
for(const input of inputs)assert.deepEqual(pin(input.file),input);
fs.writeFileSync(path.join(outDir,'report.json'),JSON.stringify({kind:'phase112-immediate-controls',complete:true,targetsExecuted:false,
 checkedApiExecuted:true,inputs,outputs,observations:data.observationCount,predicateDataCases:512,structuralControls:15,summaries},null,2)+'\n');
console.log(JSON.stringify({complete:true,targetsExecuted:false,observations:data.observationCount}));
