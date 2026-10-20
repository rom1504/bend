// Independent structural controls. These deliberately artificial IR programs
// must never be executed: raw IR verification is not source correctness.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [apiArg,outArg]=process.argv.slice(2);
if(!apiArg||!outArg||process.argv.length!==4)
  throw Error('Usage: direct-ir-controls.mjs CHECKED_API FRESH_PHASE113_OUT');
const root=path.resolve(import.meta.dirname,'../../../../..');
const apiFile=path.resolve(apiArg),out=path.resolve(outArg);
if(!out.startsWith(root+'/selfhost/build/phase113/')||fs.existsSync(out))
  throw Error('Fresh Phase113 output required');
const pin=file=>{
  file=path.resolve(file);const bytes=fs.readFileSync(file);
  return {file,bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex')};
};
const receiptFile=path.join(path.dirname(apiFile),'report.json');
const receipt=JSON.parse(fs.readFileSync(receiptFile));
const required=['p113d_verify','p113d_chunks'];
if(!receipt.complete||!receipt.checked||!required.every(x=>receipt.exports?.includes(x)))
  throw Error('Complete checked API with direct verifier/chunks required');
const apiPin=pin(apiFile);
if(path.resolve(receipt.api.file)!==apiFile||receipt.api.sha256!==apiPin.sha256||
   receipt.api.bytes!==apiPin.bytes)throw Error('API differs from checked receipt');
fs.mkdirSync(out,{recursive:true});
fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase113-independent-direct-ir-controls',complete:false,
  inputs:[pin(import.meta.filename),apiPin,pin(receiptFile)],controls:[],
  scope:'Structural verifier and guarded text-emission controls only. No generated QBE/native execution, frontend semantics, ownership proof, or performance qualification.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();

const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const unlist=xs=>{const values=[];for(;xs?.$==='Con';xs=xs.tail)values.push(xs.head);
  if(xs?.$!=='Nil')throw Error('Invalid result list');return values;};
const l={$:'N111U64'},w={$:'N111U32'},ptr={$:'N111Ptr'};
const word=(lo,hi=0)=>({$:'N111Const',lo,hi});
const local=name=>({$:'N111Local',name});
const scalar=stmt=>({$:'P113DScalar',stmt});
const set=(name,value,typ=l)=>scalar({$:'N111Set',name,typ,value});
const result=values=>({$:'P113DResult',values:list(values)});
const again=values=>({$:'P113DAgain',values:list(values)});
const call=(destinations,target,args)=>({$:'P113DCall',destinations:list(destinations),target,args:list(args)});
const branch=(yes,no)=>({$:'P113DIf',condition:word(1),yes:list(yes),no:list(no)});
const nbranch=(yes,no)=>scalar({$:'N111If',condition:word(1),yes:list(yes),no:list(no)});
const arg=(typ,value)=>({$:'N111Arg',typ,value});
const state=()=>arg(ptr,local('state'));
const runtime=(name,symbol,args,typ=l)=>scalar({$:'N111Call',name,typ,symbol,args:list(args)});
const binding=(name,id)=>({$:'NC_Binding',id,word:name,kind:{$:'N_Box'}});
const fn=(name,params,body,{public:pub=false,result:count=1}={})=>
  ({$:'P113DFunction',name,params:list(params.map(binding)),result:count,public:pub,body:list(body)});
const segment=(name,arity=0,incoming=0,flags=0)=>({$:'N111Segment',name,arity,result:1,incoming,flags,
  body:list([{$:'N111Return',value:word(0)}])});
const core=[['SNil',0],['SCon',2],['WNil',0],['WCon',2],['Nil',0],['Con',2],
  ['Tuple',2],['Unit',0],['None',0],['Some',1],['Fail',1],['Done',1],
  ['Emit',1],['Halt',2],['True',0],['LT',0],['EQ',0],['GT',0]];
const original=()=>({$:'P112StaticProgram',nodes:list([]),program:{$:'P111Program',
  segments:list([segment('main'),segment('leaf',2),segment('loop',2),segment('fallback'),
    segment('framed',1,1),segment('effect',0,0,2)]),
  constructors:list(core.map(([name,arity])=>({$:'N_Constructor',name,arity,hot:arity>0}))),
  show:list([0]),show_names:list([]),effects:list([]),pure:true}});
const bundle=(functions,old=original())=>({$:'P113DProgram',original:old,functions:list(functions)});
const leaf=()=>fn('leaf',['a','b'],[result([local('a')])],{public:true});
const pair=()=>fn('pair',['a','b'],[result([local('b'),local('a')])],{result:2});
const one=body=>bundle([fn('private',[],body)]);

const cases=[];
const add=(name,valid,program,shape)=>cases.push({name,valid,program,shape});
add('positive-empty-direct-fallback',true,bundle([]));
add('positive-public-identity',true,bundle([leaf()]));
add('positive-private-new-identity',true,one([result([word(7)])]));
add('positive-topological-native-call',true,bundle([leaf(),fn('caller',[],[
  call(['answer'],'leaf',[word(9),word(4)]),result([local('answer')])])]));
add('positive-two-output-slots',true,bundle([pair(),fn('caller',[],[
  call(['x','y'],'pair',[word(9),word(4)]),result([local('y')])])]),
  text=>text.includes('%p113_result_out')&&text.includes('%p113_results')&&text.includes('storel'));
add('positive-shared-suffix',true,one([
  branch([set('x',word(7))],[set('x',word(8))]),result([local('x')])]));
add('positive-nested-scalar-join',true,one([
  nbranch([{$:'N111Set',name:'x',typ:l,value:word(7)}],
          [{$:'N111Set',name:'x',typ:l,value:word(8)}]),result([local('x')])]));
add('positive-terminal-one-arm',true,one([
  branch([result([word(7)])],[set('x',word(8))]),result([local('x')])]));
add('positive-loop-parallel-swap',true,bundle([fn('loop',['a','b'],[
  branch([result([local('a')])],[again([local('b'),local('a')])])],{public:true})]),
  text=>{
    const a=text.indexOf('%p113_again_0 =l copy'),b=text.indexOf('%p113_again_1 =l copy');
    const move=text.indexOf('=l copy %p113_again_0');
    return a>=0&&b>a&&move>b&&text.includes('jmp @p113_loop');
  });
add('positive-owned-runtime-keep',true,one([
  runtime('x','p111_rt_keep',[state(),arg(l,word(0))]),result([local('x')])]));
add('positive-scratch-store-load',true,one([
  scalar({$:'N111Store',typ:l,base:local('scratch'),offset:2040,value:word(9)}),
  scalar({$:'N111Load',name:'x',typ:l,base:local('scratch'),offset:2040}),result([local('x')])]));
add('negative-undefined-local',false,one([result([local('absent')])]));
add('negative-branch-only-assignment',false,one([
  branch([set('x',word(7))],[]),result([local('x')])]));
add('negative-nested-branch-only-assignment',false,one([
  nbranch([{$:'N111Set',name:'x',typ:l,value:word(7)}],[]),result([local('x')])]));
add('negative-unknown-native-callee',false,one([call(['x'],'absent',[]),result([local('x')])]));
add('negative-forward-native-call',false,bundle([
  fn('caller',[],[call(['x'],'leaf',[word(1),word(2)]),result([local('x')])]),leaf()]));
add('negative-self-native-call',false,bundle([
  fn('self',['a'],[call(['x'],'self',[local('a')]),result([local('x')])])]));
add('negative-call-argument-count',false,bundle([leaf(),
  fn('caller',[],[call(['x'],'leaf',[word(1)]),result([local('x')])])]));
add('negative-call-result-count',false,bundle([pair(),
  fn('caller',[],[call(['x'],'pair',[word(1),word(2)]),result([local('x')])])]));
add('negative-duplicate-result-destinations',false,bundle([pair(),
  fn('caller',[],[call(['x','x'],'pair',[word(1),word(2)]),result([local('x')])])]));
add('negative-call-undefined-argument',false,bundle([leaf(),
  fn('caller',[],[call(['x'],'leaf',[word(1),local('absent')]),result([local('x')])])]));
add('negative-result-vector-count',false,one([result([word(1),word(2)])]));
add('negative-again-vector-count',false,bundle([fn('loop',['a','b'],[again([local('a')])])]));
add('negative-again-undefined-value',false,bundle([fn('loop',['a'],[again([local('absent')])])]));
add('negative-missing-terminal',false,one([set('x',word(1))]));
add('negative-after-terminal',false,one([result([word(1)]),set('x',word(2))]));
add('negative-hidden-return',false,one([
  nbranch([{$:'N111Return',value:word(0)}],[]),result([word(0)])]));
add('negative-hidden-scheduler-call',false,one([
  nbranch([{$:'N111Call',name:'x',typ:l,symbol:'p111_rt_return',args:list([
    state(),arg(ptr,local('scratch')),arg(w,word(1))])}],[]),result([word(0)])]));
add('negative-state-write',false,one([
  scalar({$:'N111Store',typ:l,base:local('state'),offset:0,value:word(0)}),result([word(0)])]));
add('negative-state-pointer-alias',false,one([set('alias',local('state'),ptr),result([word(0)])]));
add('negative-state-pointer-offset',false,one([
  scalar({$:'N111Offset',name:'alias',base:local('state'),bytes:word(0)}),result([word(0)])]));
add('negative-state-as-runtime-buffer',false,one([
  runtime('x','p111_rt_op',[state(),arg(w,word(1)),arg(ptr,local('state')),arg(w,word(2))]),
  result([local('x')])]));
add('negative-reserved-state-parameter',false,bundle([fn('private',['state'],[result([word(0)])])]));
add('negative-reserved-scratch-parameter',false,bundle([fn('private',['scratch'],[result([word(0)])])]));
add('negative-duplicate-parameter',false,bundle([fn('private',['a','a'],[result([local('a')])])]));
add('negative-conflicting-local-width',false,one([
  set('x',word(0)),set('x',word(0),w),result([word(0)])]));
add('negative-public-absent-original',false,bundle([fn('absent',[],[result([word(0)])],{public:true})]));
add('negative-public-arity-mismatch',false,bundle([fn('leaf',['a'],[result([local('a')])],{public:true})]));
add('negative-public-product-result',false,bundle([fn('leaf',['a','b'],
  [result([local('a'),local('b')])],{public:true,result:2})]));
add('negative-public-continuation',false,bundle([fn('framed',['a'],[result([local('a')])],{public:true})]));
add('negative-public-effects',false,bundle([fn('effect',[],[result([word(0)])],{public:true})]));
add('negative-duplicate-function',false,bundle([leaf(),leaf()]));
add('negative-output-zero',false,bundle([fn('private',[],[result([])],{result:0})]));
add('negative-output-nine',false,bundle([fn('private',[],[result(Array(9).fill(word(0)))],{result:9})]));
const invalidOriginal=original();
invalidOriginal.program.segments=list([segment('not_main')]);
add('negative-invalid-original-retained',false,bundle([],invalidOriginal));

try {
  const api=(await import(pathToFileURL(apiFile))).default;
  for(const item of cases) {
    const row={name:item.name,expectedValid:item.valid};
    report.controls.push(row);save();
    fs.writeFileSync(path.join(out,item.name+'.ir.json'),JSON.stringify(item.program)+'\n');
    try {
      row.diagnostic=api.p113d_verify(item.program);
      if(typeof row.diagnostic!=='string')throw Error('Verifier returned a non-string');
      row.accepted=row.diagnostic==='';
      const chunks=unlist(api.p113d_chunks(item.program));
      const text=chunks.map(chunk=>chunk+'\n').join('');
      const product=path.join(out,item.name+'.ssa');
      fs.writeFileSync(product,text);
      row.product=pin(product);
      row.guardedEmission=item.valid?!text.includes('INVALID_P113_PROGRAM:'):
        text.startsWith('INVALID_P113_PROGRAM:');
      row.shape=item.shape?item.shape(text):true;
      row.pass=row.accepted===item.valid&&row.guardedEmission&&row.shape;
    } catch(error) {row.error=String(error);row.pass=false;}
    save();console.log(JSON.stringify(row));
  }
  report.complete=report.controls.every(row=>row.pass);
  report.count=report.controls.length;
  report.accepted=report.controls.filter(row=>row.accepted).length;
  for(const input of report.inputs)if(JSON.stringify(pin(input.file))!==JSON.stringify(input))
    throw Error('Input changed during controls: '+input.file);
} catch(error) {report.error=String(error);throw error;}
finally {save();}
if(!report.complete)process.exitCode=1;
