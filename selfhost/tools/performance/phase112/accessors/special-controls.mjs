// Coordinator-run data transport. Every lowering, verification and QBE emitter
// call below executes the checked Bend API. No compiler algorithm is in JS.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL,fileURLToPath} from 'node:url';
const [apiFile,outDir]=process.argv.slice(2);
if(!apiFile||!outDir)throw Error('Usage: special-controls.mjs API.mjs FRESH_OUT');
const api=(await import(pathToFileURL(path.resolve(apiFile)).href)).default;
fs.mkdirSync(outDir);
const pin=file=>{file=path.resolve(file);const raw=fs.readFileSync(file);return {file,bytes:raw.length,sha256:crypto.createHash('sha256').update(raw).digest('hex')};};
const inputs=[pin(apiFile),pin(fileURLToPath(import.meta.url))];
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const unlist=xs=>{const out=[];while(xs.$==='Con'){out.push(xs.head);xs=xs.tail;}assert.equal(xs.$,'Nil');return out;};
const l={$:'N111U64'},w={$:'N111U32'},ptr={$:'N111Ptr'};
const word=(lo,hi=0)=>({$:'N111Const',lo,hi});
const local=name=>({$:'N111Local',name});
const arg=(typ,value)=>({$:'N111Arg',typ,value});
const state=()=>arg(ptr,local('state'));
const scratch=()=>arg(ptr,local('scratch'));
const ctor=name=>({$:'N111CtorId',name});
const call=(name,symbol,args)=>({$:'N111Call',name,typ:l,symbol,args:list(args)});
const store=(i,value)=>({$:'N111Store',typ:l,base:local('scratch'),offset:8*i,value});
const set=(name,value)=>({$:'N111Set',name,typ:l,value});
const core=[['SNil',0],['SCon',2],['WNil',0],['WCon',2],['Nil',0],['Con',2],['Tuple',2],['Unit',0],
 ['None',0],['Some',1],['Fail',1],['Done',1],['Emit',1],['Halt',2],['True',0],['False',0],['LT',0],['EQ',0],['GT',0]];
const trueId=core.findIndex(([name])=>name==='True');
const falseId=core.findIndex(([name])=>name==='False');
// The seven literal expectation bits are False/True/Zero/Succ/Chr/U32/F32.
// They are fixed independently of the candidate expression builder.
const rows=[
 ['raw-zero',word(0),'1010111'],
 ['raw-one',word(1),'0101111'],
 ['raw-two',word(2),'1001111'],
 ['raw-high-one',word(1,1),'1001111'],
 ['all-bits',word(4294967295,4294967295),'1001111'],
 ['packed-true',word(0,16777216+trueId*256),'0101111'],
 ['packed-true-location',word(4294967295,16777216+trueId*256+255),'0101111'],
 ['packed-true-rfc',word(4294967295,2164260864+trueId*256+255),'0101111'],
 ['packed-false',word(0,16777216+falseId*256),'1001111'],
 ['constructor-true-aux',word(0,33554432+trueId*256),'1001111'],
 ['raw-one-with-rfc',word(1,2147483648),'1001111'],
 ['tag127-true-aux',word(0,2130706432+trueId*256),'1001111']
];
const names=['False','True','Zero','Succ','Chr','U32','F32'];
const cases=rows.flatMap(([name,value,expected])=>names.map((kind,i)=>({name:name+'-'+kind,kind,value,expected:expected[i]})));
const expected='"'+cases.map(x=>x.expected).join('')+'"\n';
function program(candidate){
 const body=[{$:'N111Alloca',name:'scratch',bytes:2048,align:8},
  call('tail','p111_rt_ctor',[state(),arg(w,ctor('SNil')),scratch(),arg(w,word(0))])];
 for(const c of [...cases].reverse()){
  body.push(...unlist((candidate?api.p112_special_test:api.p112_special_test_fallback)(c.kind,c.value)),
   {$:'N111If',condition:local('match_condition'),yes:list([set('character',word(49))]),no:list([set('character',word(48))])},
   store(0,local('character')),store(1,local('tail')),
   call('tail','p111_rt_ctor',[state(),arg(w,ctor('SCon')),scratch(),arg(w,word(2))]));
 }
 body.push(store(0,local('tail')),call('reply','p111_rt_return',[state(),scratch(),arg(w,word(1))]),{$:'N111Return',value:local('reply')});
 return {$:'P111Program',segments:list([{$:'N111Segment',name:'main',arity:0,result:1,incoming:0,flags:0,body:list(body)}]),
  constructors:list(core.map(([name,arity])=>({$:'N_Constructor',name,arity,hot:arity>0}))),show:list([4]),show_names:list([]),effects:list([]),pure:true};
}
for(const [name,candidate]of[['baseline',false],['candidate',true]]){
 const graph=program(candidate);assert.equal(api.p111_verify_program(graph),'');
 const text=unlist(api.p111q_chunks(graph)).join('');
 assert.equal((text.match(/call \$p111_rt_special_test/g)||[]).length,candidate?0:cases.length);
 fs.writeFileSync(path.join(outDir,name+'.ssa'),text);
}
fs.writeFileSync(path.join(outDir,'expected.stdout'),expected);
fs.writeFileSync(path.join(outDir,'cases.json'),JSON.stringify(cases,null,2)+'\n');
fs.writeFileSync(path.join(outDir,'report.json'),JSON.stringify({kind:'phase112-special-test-controls',complete:true,
 targetsExecuted:false,checkedApiExecuted:true,inputs,observations:cases.length,coreTrueId:trueId,coreFalseId:falseId,
 outputs:['baseline.ssa','candidate.ssa','expected.stdout','cases.json'].map(name=>pin(path.join(outDir,name))),
 semantics:'Independent complete bit string; raw, packed, RFC, location, wrong-tag and high-half boundaries.'},null,2)+'\n');
console.log(JSON.stringify({complete:true,targetsExecuted:false,observations:cases.length}));
