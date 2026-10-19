// Root-run raw IR transport. Compiler verification/emission runs in checked
// Bend APIs; the host only builds independent finite observations and compares.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL,fileURLToPath} from 'node:url';
const [baselineFile,candidateFile,outDir]=process.argv.slice(2);
if(!baselineFile||!candidateFile||!outDir)throw Error('Usage: controls.mjs BASE_API CANDIDATE_API FRESH_OUT');
const here=path.dirname(fileURLToPath(import.meta.url));
const data=JSON.parse(fs.readFileSync(path.join(here,'cases.json')));
const expected=fs.readFileSync(path.join(here,'expected.stdout'),'utf8');
const pin=file=>{file=path.resolve(file);const raw=fs.readFileSync(file);return {file,bytes:raw.length,sha256:crypto.createHash('sha256').update(raw).digest('hex')};};
const inputs=[baselineFile,candidateFile,fileURLToPath(import.meta.url),path.join(here,'cases.json'),path.join(here,'expected.stdout')].map(pin);
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
const operandStore=(buffer,i,value)=>({$:'N111Store',typ:l,base:local(buffer),offset:8*i,value});
const set=(name,value)=>({$:'N111Set',name,typ:l,value});
const bin=(name,typ,op,left,right)=>({$:'N111Bin',name,typ,op,left,right});
const branch=(condition,yes,no)=>({$:'N111If',condition:local(condition),yes:list(yes),no:list(no)});
const core=[['SNil',0],['SCon',2],['WNil',0],['WCon',2],['Nil',0],['Con',2],['Tuple',2],['Unit',0],
 ['None',0],['Some',1],['Fail',1],['Done',1],['Emit',1],['Halt',2],['True',0],['False',0],['LT',0],['EQ',0],['GT',0]];
const ctor=(name,count)=>call('tail','p111_rt_ctor',[state(),arg(w,{$:'N111CtorId',name}),scratch(),arg(w,word(count))]);
const segment=(name,arity,body)=>({$:'N111Segment',name,arity,result:1,incoming:0,flags:0,body:list(body)});
const alloca=(name,bytes)=>({$:'N111Alloca',name,bytes,align:8});
const finish=(next)=>[store(0,local('tail')),
 next===null?call('reply','p111_rt_return',[state(),scratch(),arg(w,word(1))]):
 call('reply','p111_rt_jump',[state(),arg(w,{$:'N111FuncId',name:next}),scratch(),arg(w,word(1))]),
 {$:'N111Return',value:local('reply')}];
function program(){
 // The original dispatcher transports one owned String between small cases.
 // This bounds each checked emitter traversal without changing observations.
 const caseName=i=>'float_case_'+i;
 const segments=[segment('main',0,[alloca('scratch',2048),ctor('SNil',0),
  ...finish(caseName(data.cases.length-1))])];
 for(let index=data.cases.length-1;index>=0;--index){
  const row=data.cases[index];
  const buffer=row.buffer||'scratch';
  const body=[alloca('scratch',2048),
   ...(buffer==='scratch'?[]:[alloca(buffer,16)]),
   call('tail','p111_rt_reg_get',[state(),arg(w,word(0))])];
  const prepend=value=>body.push(store(0,value),store(1,local('tail')),ctor('SCon',2));
  body.push(...row.args.map((x,i)=>operandStore(buffer,i,word(x.lo,x.hi))),
   call('result','p111_rt_op',[state(),arg(w,word(row.op)),arg(ptr,local(buffer)),arg(w,word(row.args.length))]));
  if(row.comparison==='nan-class'){
   body.push(bin('exponent',l,'and',local('result'),word(0x7f800000)),bin('mantissa',l,'and',local('result'),word(0x007fffff)),
    bin('upper',l,'shr',local('result'),word(32)),bin('exponent_ok',l,'eq',local('exponent'),word(0x7f800000)),
    bin('mantissa_ok',l,'ne',local('mantissa'),word(0)),bin('upper_ok',l,'eq',local('upper'),word(0)),
    bin('nan_low',w,'and',local('exponent_ok'),local('mantissa_ok')),bin('nan_ok',w,'and',local('nan_low'),local('upper_ok')),
    branch('nan_ok',[set('result',word(0x7fc00000))],[set('result',local('result'))]));
  }
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
 assert.equal(segments.length,data.observationCount+1);
 return {$:'P111Program',segments:list(segments),
  constructors:list(core.map(([name,arity])=>({$:'N_Constructor',name,arity,hot:arity>0}))),show:list([4]),show_names:list([]),effects:list([]),pure:true};
}
fs.mkdirSync(outDir);
const summaries=[];
for(const [name,file]of[['baseline',baselineFile],['candidate',candidateFile]]){
 const api=(await import(pathToFileURL(path.resolve(file)).href)).default;
 const graph=program();assert.equal(api.p111_verify_program(graph),'');
 if(name==='candidate'){
  const controls=unlist(api.p112fp_control_report());assert.equal(controls.length,21);assert(controls.every(x=>x.startsWith('PASS ')));
  fs.writeFileSync(path.join(outDir,'structural-controls.json'),JSON.stringify(controls,null,2)+'\n');
 }
 const text=unlist(api.p111q_chunks(graph)).join('');
 const calls=(text.match(/call \$p111_rt_op\(/g)||[]).length;
 assert.equal(calls,name==='candidate'?data.observationCount-data.expandedCount:data.observationCount);
 fs.writeFileSync(path.join(outDir,name+'.ssa'),text);summaries.push({name,primitiveCalls:calls,segments:data.observationCount+1});
}
fs.writeFileSync(path.join(outDir,'expected.stdout'),expected);
const outputs=['baseline.ssa','candidate.ssa','expected.stdout','structural-controls.json'].map(name=>pin(path.join(outDir,name)));
for(const input of inputs)assert.deepEqual(pin(input.file),input);
fs.writeFileSync(path.join(outDir,'report.json'),JSON.stringify({kind:'phase112-float-controls',complete:true,targetsExecuted:false,
 checkedApiExecuted:true,inputs,outputs,observations:data.observationCount,expanded:data.expandedCount,structuralControls:21,summaries,nanPolicy:data.nanPolicy},null,2)+'\n');
console.log(JSON.stringify({complete:true,targetsExecuted:false,observations:data.observationCount,expanded:data.expandedCount}));
