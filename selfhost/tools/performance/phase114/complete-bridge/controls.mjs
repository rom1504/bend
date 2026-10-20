// Independent source-template assertions only; no generated IR is executed.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [apiArg,outArg]=process.argv.slice(2);
if(!apiArg||!outArg||process.argv.length!==4)throw Error('controls.mjs CHECKED_API FRESH_PHASE114_OUT');
const root=path.resolve(import.meta.dirname,'../../../../..');
const apiFile=path.resolve(apiArg),out=path.resolve(outArg);
if(!out.startsWith(root+'/selfhost/build/phase114/')||fs.existsSync(out))throw Error('Fresh Phase114 output required');
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const receiptFile=path.join(path.dirname(apiFile),'report.json'),receipt=JSON.parse(fs.readFileSync(receiptFile));
const required=['p114b_scan','p114b_target','p113e_signatures'];
if(!receipt.complete||!receipt.checked||!required.every(x=>receipt.exports?.includes(x)))throw Error('Checked exports missing');
const apiPin=pin(apiFile);assert.deepEqual(receipt.api,apiPin);
const api=(await import(pathToFileURL(apiFile))).default;
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const unlist=xs=>{const out=[];for(;xs?.$==='Con';xs=xs.tail)out.push(xs.head);assert.equal(xs?.$,'Nil');return out;};
const l={$:'N111U64'},w={$:'N111U32'},ptr={$:'N111Ptr'};
const word=(lo,hi=0)=>({$:'N111Const',lo,hi}),local=name=>({$:'N111Local',name});
const arg=(typ,value)=>({$:'N111Arg',typ,value}),scalar=stmt=>({$:'P112WorkerScalar',stmt});
const target='$direct.callee';
const fn=(count,opts={})=>({$:'P113DFunction',name:target,params:list(Array.from({length:count},(_,id)=>({$:'NC_Binding',id,word:`p${id}`,kind:{$:'N_Box'}}))),result:1,public:true,body:list([]),...opts});
// The mature catalogue index uses the normal Absent KDef seed.
const atom={$:'KTerm',tag:'Absent',name:'',id:0,quant:0,kids:list([]),removed:list([]),originBegin:0,originEnd:0};
const absent={$:'KDef',name:'',kind:'Absent',arity:0,templates:0,typ:atom,value:atom,ctors:list([]),native:false,unsafe:false};
const direct=(count,opts={})=>api.p113e_signatures(list([fn(count,opts)]),absent);
const terminal=(count,buffer='scratch',returned='reply')=>[
  scalar({$:'N111Call',name:'reply',typ:l,symbol:'p111_rt_jump',args:list([arg(ptr,local('state')),arg(w,{$:'N111FuncId',name:target}),arg(ptr,local(buffer)),arg(w,word(count))])}),
  scalar({$:'N111Return',value:local(returned)})];
const scan=(body,count,opts={})=>api.p114b_scan(list(body),direct(count,opts),0);
fs.mkdirSync(out,{recursive:true});
const report={kind:'phase114-complete-bridge-structural-controls',complete:false,inputs:[pin(import.meta.filename),apiPin,pin(receiptFile)],controls:[],scope:'Exact closed-catalogue/template assertions, no generated native IR execution. Ordinary source/native gates remain separate.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const test=(name,fn)=>{try{fn();report.controls.push({name,pass:true});}catch(e){report.controls.push({name,pass:false,error:String(e)});save();throw e;}};save();
for(const count of [0,2,9,32])test(`ordered-full-width-${count}`,()=>{
  const result=scan(terminal(count),count);assert.equal(result.next,1);
  const body=unlist(result.body).map(x=>x.stmt);assert.equal(body.length,count+4);
  for(let i=0;i<count;i++)assert.deepEqual(body[i],{$:'N111Load',name:`p114b_0_arg_${i}`,typ:l,base:local('scratch'),offset:8*i});
  const call=body[count];assert.equal(call.$,'N111Call');assert.equal(call.typ.$,'N111U64');assert.equal(call.name,'p114b_0_result');
  assert.equal(call.symbol,'p113d_FID_'+[...target].map(x=>x.codePointAt(0)).join('_')+'_');
  assert.deepEqual(unlist(call.args),[arg(ptr,local('state')),...Array.from({length:count},(_,i)=>arg(l,local(`p114b_0_arg_${i}`)))]);
  assert.deepEqual(body[count+1],{$:'N111Store',typ:l,base:local('scratch'),offset:0,value:local('p114b_0_result')});
  assert.deepEqual(body[count+2],{$:'N111Call',name:'reply',typ:l,symbol:'p111_rt_return',args:list([arg(ptr,local('state')),arg(ptr,local('scratch')),arg(w,word(1))])});
  assert.deepEqual(body[count+3],{$:'N111Return',value:local('reply')});
});
for(const [name,arity,opts,body] of [
  ['private-flat-shape',2,{public:false},terminal(2)],
  ['multi-result',2,{result:2},terminal(2)],
  ['wide-fallback',33,{},terminal(33)],
  ['arity-mismatch',3,{},terminal(2)],
  ['nonfactory-buffer',2,{},terminal(2,'other')],
  ['different-return',2,{},terminal(2,'scratch','different')],
  ['nonterminal',2,{},[...terminal(2),scalar({$:'N111Set',name:'later',typ:l,value:word(0)})]]
])test(`fallback-${name}`,()=>{const result=scan(body,arity,opts);assert.equal(result.next,0);assert.deepEqual(unlist(result.body),body);});
test('effects-and-argument-stores-retained',()=>{
  const prefix=[scalar({$:'N111Call',name:'kept',typ:l,symbol:'p111_rt_keep',args:list([arg(ptr,local('state')),arg(l,local('owned'))])}),
    scalar({$:'N111Store',typ:l,base:local('scratch'),offset:0,value:local('right')}),
    scalar({$:'N111Store',typ:l,base:local('scratch'),offset:8,value:local('left')})];
  const result=scan([...prefix,...terminal(2)],2);assert.deepEqual(unlist(result.body).slice(0,prefix.length),prefix);assert.equal(result.next,1);
});
test('fusion-scratch-keeps-own-buffer',()=>{
  const result=scan(terminal(2,'p112f_3_local_scratch'),2);assert.equal(result.next,1);
  const body=unlist(result.body).map(x=>x.stmt);assert.equal(body[0].base.name,'p112f_3_local_scratch');assert.equal(body[3].base.name,'p112f_3_local_scratch');
  assert.equal(unlist(body[4].args)[1].value.name,'p112f_3_local_scratch');
});
test('branch-site-freshness',()=>{
  const branch={$:'P112WorkerIf',condition:local('condition'),yes:list(terminal(2)),no:list(terminal(2))};
  const result=scan([branch,...terminal(2)],2);assert.equal(result.next,3);
  const body=unlist(result.body),first=body[0];
  assert.equal(unlist(first.yes)[0].stmt.name,'p114b_0_arg_0');assert.equal(unlist(first.no)[0].stmt.name,'p114b_1_arg_0');assert.equal(body[1].stmt.name,'p114b_2_arg_0');
});
test('legacy-private-marker-unchanged',()=>{
  const body=[{$:'P112WorkerCall',target,arity:2}];const result=scan(body,2);assert.equal(result.next,0);assert.deepEqual(unlist(result.body),body);
});
report.complete=true;save();console.log(JSON.stringify({complete:true,controls:report.controls.length}));
