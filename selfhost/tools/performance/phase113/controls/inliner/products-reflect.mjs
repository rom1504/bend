import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {isDeepStrictEqual as equal} from 'node:util';
import {list,arr,l,w,ptr,word,local,scalar,set,bin,ret,again,call,branch,
  alloc,store,load,fn,bundle,execute,callCount,stackBytes} from './ir-model.mjs';

const [apiArg,outArg]=process.argv.slice(2);
if(!apiArg||!outArg||process.argv.length!==4)throw Error('Usage: products-reflect.mjs CHECKED_API FRESH_PHASE113_OUT');
const root=path.resolve(import.meta.dirname,'../../../../../..');
const apiFile=path.resolve(apiArg),out=path.resolve(outArg);
if(!out.startsWith(root+'/selfhost/build/phase113/')||fs.existsSync(out))throw Error('Fresh Phase113 output required');
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return {file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const receiptFile=path.join(path.dirname(apiFile),'report.json'),receipt=JSON.parse(fs.readFileSync(receiptFile));
const needed=['p113i_optimize','p113d_verify','p113i_eligible','p113j_scratch','p113j_buffer_origin','p113j_audit'];
const apiPin=pin(apiFile);
if(!receipt.complete||!receipt.checked||!needed.every(x=>receipt.exports?.includes(x))||
 receipt.api.sha256!==apiPin.sha256||receipt.api.bytes!==apiPin.bytes||
 path.resolve(receipt.api.file)!==apiFile)throw Error('Matching complete checked product-inliner API required');
fs.mkdirSync(out,{recursive:true});
fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
fs.copyFileSync(path.join(import.meta.dirname,'ir-model.mjs'),path.join(out,'ir-model.mjs'));
const report={kind:'phase113-independent-product-inliner-controls',complete:false,
 inputs:[pin(import.meta.filename),pin(path.join(import.meta.dirname,'ir-model.mjs')),apiPin,pin(receiptFile)],
 cases:[],footprints:[],bufferNames:[],boundaries:[],
 scope:'Independent finite scalar-word/array-contract interpretation, structural admission, hygiene and footprint checks. Logical array handle100=[7,11]; no production heap/RC ownership proof or native execution.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const cases=[];
const add=(name,functions,values,calls,options={})=>cases.push({name,program:bundle(functions),
 expected:{values:values.map(String),trace:options.trace??[]},calls,...options});
const storeAt=(base,offset,value)=>scalar({$:'N111Store',typ:l,base:local(base),offset,value});
const loadAt=(name,base,offset)=>scalar({$:'N111Load',name,typ:l,base:local(base),offset});
const argument=(typ,value)=>({$:'N111Arg',typ,value});
const arrayCall=(op,input='scratch',output='p113p_out_0',count=2)=>scalar({$:'N111Call',
 name:'status',typ:l,symbol:'p113_rt_array_pair',args:list([
 argument(ptr,local('state')),argument(w,word(op)),argument(ptr,local(input)),
 argument(w,word(count)),argument(ptr,local(output)),argument(w,word(2))])});
const exactAlloc=(name,bytes)=>scalar({$:'N111Alloca',name,bytes,align:8});
const pairLeaf=()=>fn('pair',['a','b'],[ret(local('b'),local('a'))],2,false);
add('two-results-destination-permutation',[pairLeaf(),fn('caller',[],[
 set('x',word(2)),set('y',word(7)),call(['x','y'],'pair',local('x'),local('y')),
 bin('z','mul',local('x'),word(10)),bin('z','add',local('z'),local('y')),ret(local('z'))])],[72],0);
add('three-results-overlapping-actuals',[fn('triple',['a','b','c'],[ret(local('c'),local('a'),local('b'))],3,false),
 fn('caller',[],[set('x',word(2)),set('y',word(7)),set('z',word(9)),
 call(['y','z','x'],'triple',local('x'),local('y'),local('z')),
 bin('v','mul',local('x'),word(100)),bin('t','mul',local('y'),word(10)),
 bin('v','add',local('v'),local('t')),bin('v','add',local('v'),local('z')),ret(local('v'))])],[792],0);
const loop=()=>fn('loop',['n'],[bin('test','eq',local('n'),word(0)),
 branch(local('test'),[ret(word(99))],[bin('next','sub',local('n'),word(1)),again(local('next'))])]);
add('retained-call-inside-copied-dag',[loop(),fn('wrapper',['n'],[
 call('answer','loop',local('n')),ret(local('answer'))]),
 fn('caller',[],[call('answer','wrapper',word(4)),ret(local('answer'))])],[99],1,{callee:'loop',eligible:false});
const getLeaf=()=>fn('get',['array','index'],[
 store('scratch',local('array')),storeAt('scratch',8,local('index')),exactAlloc('p113p_out_0',16),
 arrayCall(72),load('array_out','p113p_out_0'),loadAt('value','p113p_out_0',8),
 ret(local('array_out'),local('value'))],2,false);
add('array-pair-hygienic-nested-buffers',[getLeaf(),
 fn('wrapper',['array','index'],[call(['a','v'],'get',local('array'),local('index')),ret(local('a'),local('v'))],2,false),
 fn('caller',[],[store('scratch',word(333)),call(['a','v'],'wrapper',word(100),word(1)),
 load('held','scratch'),bin('answer','add',local('v'),local('held')),ret(local('answer'))])],[344],0,
 {trace:['p113_rt_array_pair:72:100'],scratch:16});
add('array-swap-then-get-order',[fn('swap',['array','index','value'],[
 store('scratch',local('array')),storeAt('scratch',8,local('index')),storeAt('scratch',16,local('value')),
 exactAlloc('p113p_out_0',16),arrayCall(74,'scratch','p113p_out_0',3),
 load('a','p113p_out_0'),loadAt('old','p113p_out_0',8),ret(local('a'),local('old'))],2,false),
 getLeaf(),fn('caller',[],[call(['a','old'],'swap',word(100),word(1),word(19)),
 call(['a','current'],'get',local('a'),word(1)),bin('answer','mul',local('old'),word(100)),
 bin('answer','add',local('answer'),local('current')),ret(local('answer'))])],[1119],0,
 {trace:['p113_rt_array_pair:74:100','p113_rt_array_pair:72:100']});
add('refuse-partial-return-product',[fn('pair',['a'],[bin('c','eq',local('a'),word(0)),
 branch(local('c'),[ret(word(2),word(3))],[set('v',word(5))]),ret(local('v'),word(6))],2,false),
 fn('caller',[],[call(['x','y'],'pair',word(0)),bin('z','add',local('x'),local('y')),ret(local('z'))])],[5],1,
 {callee:'pair',eligible:false,unchanged:true});
add('refuse-again-product',[fn('pair',['a'],[bin('c','eq',local('a'),word(0)),
 branch(local('c'),[ret(word(2),word(3))],[bin('next','sub',local('a'),word(1)),again(local('next'))])],2,false),
 fn('caller',[],[call(['x','y'],'pair',word(3)),bin('z','add',local('x'),local('y')),ret(local('z'))])],[5],1,
 {callee:'pair',eligible:false,unchanged:true});
add('two-result-branch-snapshots',[fn('pair',['a','b'],[bin('c','eq',local('a'),word(0)),
 branch(local('c'),[ret(local('b'),local('a'))],[ret(local('a'),local('b'))])],2,false),
 fn('caller',[],[set('x',word(0)),set('y',word(17)),call(['x','y'],'pair',local('x'),local('y')),
 bin('z','add',local('x'),local('y')),ret(local('z'))])],[17],0);
const footprintCases=[
 ['unused',[],0],
 ['one-word-store',[store('scratch',word(1))],8],
 ['two-word-load',[loadAt('x','scratch',8)],16],
 ['full-buffer',[loadAt('x','scratch',2040)],2048],
 ['branch-maximum',[branch(word(1),[store('scratch',word(1))],[storeAt('scratch',8,word(2))])],16],
 ['array-get-input',[arrayCall(72)],16],
 ['array-swap-input',[arrayCall(74,'scratch','p113p_out_0',3)],24],
 ['unknown-pointer-alias',[scalar({$:'N111Set',name:'p',typ:ptr,value:local('scratch')})],2048],
 ['unknown-runtime-import',[scalar({$:'N111Call',name:'x',typ:l,symbol:'unknown',
   args:list([argument(ptr,local('scratch'))])})],2048],
 ['scratch-twice-in-import',[arrayCall(72,'scratch','scratch',2)],2048],
 ['scratch-value-escape',[ret(local('scratch'))],2048],
];
const names=[
 ['scratch',true,true],['p113p_out_0',false,true],
 ['p113i_0_local_scratch',true,true],['p113i_15_local_scratch',true,true],
 ['p113i_0_local_p113i_15_local_scratch',true,true],
 ['p113i_10_local_p113i_1_local_p113p_out_7',false,true],
 ['state',true,false],['p113i_0_local_state',true,false],
 ['p113i_16_local_scratch',true,false],['p113i_00_local_scratch',true,false],
 ['p113i_-1_local_scratch',true,false],['p113i_0_localscratch',true,false],
 ['scratch',false,false],['p113p_out_0',true,false],
 ['p113i_0_local_p113p_out_7',true,false],
 ['p113i_0_local_scratch',false,false],['arbitrary_heap',true,false],
];
function importFixture(input,output,inputBytes,outputBytes) {
 const prefix=[...(input==='scratch'?[]:[exactAlloc(input,inputBytes)]),exactAlloc(output,outputBytes)];
 if(input==='scratch'&&inputBytes!==2048)throw Error('Use named explicit buffer for capacity mutation');
 return bundle([fn('raw',[],[...prefix,arrayCall(72,input,output,2),ret(word(0))])]);
}
const boundaries=[
 ['renamed-buffers-valid',importFixture('p113i_0_local_scratch','p113i_0_local_p113p_out_0',16,16),true],
 ['nested-buffers-valid',importFixture('p113i_10_local_p113i_0_local_scratch','p113i_10_local_p113i_0_local_p113p_out_0',16,16),true],
 ['input-capacity-short',importFixture('p113i_0_local_scratch','p113i_0_local_p113p_out_0',8,16),false],
 ['output-capacity-short',importFixture('p113i_0_local_scratch','p113i_0_local_p113p_out_0',16,8),false],
 ['invalid-input-ancestry',importFixture('p113i_16_local_scratch','p113i_0_local_p113p_out_0',16,16),false],
 ['invalid-output-ancestry',importFixture('p113i_0_local_scratch','p113i_16_local_p113p_out_0',16,16),false],
];
save();
try {
 const api=(await import(pathToFileURL(apiFile))).default;
 for(const c of cases) {
  const row={name:c.name,expected:c.expected,expectedRemainingCalls:c.calls};report.cases.push(row);save();
  fs.writeFileSync(path.join(out,c.name+'.before.json'),JSON.stringify(c.program)+'\n');
  try {
   row.beforeDiagnostic=api.p113d_verify(c.program);
   if(row.beforeDiagnostic!=='')throw Error('Invalid original '+row.beforeDiagnostic);
   const after=api.p113i_optimize(c.program);
   fs.writeFileSync(path.join(out,c.name+'.after.json'),JSON.stringify(after)+'\n');
   row.afterDiagnostic=api.p113d_verify(after);row.before=execute(c.program,'caller',[]);row.after=execute(after,'caller',[]);
   const caller=arr(after.functions).find(f=>f.name==='caller');
   row.remainingCalls=callCount(caller.body);row.explicitStackBytes=stackBytes(caller.body);
   row.originalRetained=equal(after.original,c.program.original);row.idempotent=equal(api.p113i_optimize(after),after);
   row.unchanged=equal(after,c.program);
   row.eligibility=c.callee?api.p113i_eligible(arr(c.program.functions).find(f=>f.name===c.callee)):null;
   row.auditBefore=api.p113j_audit(c.program);row.auditAfter=api.p113j_audit(after);
   row.pass=row.afterDiagnostic===''&&equal(row.before,c.expected)&&equal(row.after,c.expected)&&
    row.remainingCalls===c.calls&&row.originalRetained&&row.idempotent&&row.explicitStackBytes<=16384&&
    (!c.unchanged||row.unchanged)&&(!c.callee||row.eligibility===c.eligible);
  }catch(error){row.error=String(error);row.pass=false;}
  save();console.log(JSON.stringify(row));
 }
 for(const [name,body,expected] of footprintCases) {
  const actual=api.p113j_scratch(list(body));report.footprints.push({name,expected,actual,pass:actual===expected});
 }
 for(const [name,input,expected] of names) {
  const actual=api.p113j_buffer_origin(name,input);report.bufferNames.push({name,input,expected,actual,pass:actual===expected});
 }
 for(const [name,program,expected] of boundaries) {
  const diagnostic=api.p113d_verify(program);const after=api.p113i_optimize(program);
  report.boundaries.push({name,expected,diagnostic,pass:(diagnostic==='')===expected&&
    (expected||equal(after,program))});
  fs.writeFileSync(path.join(out,name+'.ir.json'),JSON.stringify(program)+'\n');
 }
 report.complete=[...report.cases,...report.footprints,...report.bufferNames,...report.boundaries].every(x=>x.pass);
 for(const input of report.inputs)if(!equal(pin(input.file),input))throw Error('Input changed '+input.file);
}catch(error){report.error=String(error);throw error;}
finally{save();}
if(!report.complete)process.exitCode=1;
