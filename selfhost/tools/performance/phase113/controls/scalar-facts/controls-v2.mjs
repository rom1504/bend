// Frozen independent scalar-fact properties, full-width edge values and traces.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {isDeepStrictEqual as equal} from 'node:util';
import {list,arr,l,w,ptr,word,local,scalar,set,bin,ret,again,call,branch,
  store,load,rt,fn,bundle,execute} from './ir-model.mjs';
const [apiArg,outArg]=process.argv.slice(2);
if(!apiArg||!outArg||process.argv.length!==4)throw Error('Usage: controls.mjs CHECKED_API FRESH_PHASE113_OUT');
const root=path.resolve(import.meta.dirname,'../../../../../..'),apiFile=path.resolve(apiArg),out=path.resolve(outArg);
if(!out.startsWith(root+'/selfhost/build/phase113/')||fs.existsSync(out))throw Error('Fresh Phase113 output required');
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return {file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const receiptFile=path.join(path.dirname(apiFile),'report.json'),receipt=JSON.parse(fs.readFileSync(receiptFile));
const apiPin=pin(apiFile),required=['p113d_verify','p113k_optimize'];
if(!receipt.complete||!receipt.checked||!required.every(x=>receipt.exports?.includes(x))||
 receipt.api.sha256!==apiPin.sha256||receipt.api.bytes!==apiPin.bytes||path.resolve(receipt.api.file)!==apiFile)
 throw Error('Matching complete checked scalar-facts API required');
fs.mkdirSync(out,{recursive:true});
fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
fs.copyFileSync(path.join(import.meta.dirname,'ir-model.mjs'),path.join(out,'ir-model.mjs'));
const report={kind:'phase113-independent-scalar-facts-controls',complete:false,
 inputs:[pin(import.meta.filename),pin(path.join(import.meta.dirname,'ir-model.mjs')),apiPin,pin(receiptFile),
  pin(path.join(root,'selfhost/build/phase108/toolchain/qbe-1.3/doc/il.txt'))],cases:[],
 scope:'Independent finite U32/U64 integer interpretation and ordered runtime-call observations. QBE shift counts modulo operand/result bit width. No native execution or proof for arbitrary programs; N_W32 parameter annotations never truncate full Terms.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const MAX=(1n<<64n)-1n,LOW=(1n<<32n)-1n;
const edges=[0n,1n,1n<<31n,LOW,1n<<32n,1n<<40n,(1n<<48n)-1n,1n<<63n,MAX,
  0x01000e0000000000n,0x7fc01234n];
const c64=x=>word(Number(x&LOW),Number((x>>32n)&LOW));
const signed=x=>x>=(1n<<63n)?x-(1n<<64n):x;
const expected=(x,trace=[])=>({values:[String(x)],trace});
const typedBin=(name,typ,op,left,right)=>scalar({$:'N111Bin',name,typ,op,left,right});
function ops(body,op) {
 const scalarCount=s=>s.$==='N111Bin'&&s.op===op?1:s.$==='N111If'?arr(s.yes).reduce((n,x)=>n+scalarCount(x),0)+arr(s.no).reduce((n,x)=>n+scalarCount(x),0):0;
 return arr(body).reduce((n,s)=>n+(s.$==='P113DScalar'?scalarCount(s.stmt):s.$==='P113DIf'?ops(s.yes,op)+ops(s.no,op):0),0);
}
const cases=[];
function add(name,body,inputs,oracle,{params=['input'],prior=[],mustRemove=null,kind32=false}={}) {
 const subject=fn('subject',params,body);
 if(kind32)for(const p of arr(subject.params))p.kind={$:'N_W32'};
 cases.push({name,program:bundle([...prior,subject]),inputs,oracle,mustRemove});
}
const single=edges.map(x=>[x]);
add('unknown-N_W32-retains-full64',[bin('x','shr',local('input'),word(40)),ret(local('x'))],single,
 ([x])=>expected(x>>40n),{kind32:true});
add('low32-mask-makes-high-shift-zero',[bin('x','and',local('input'),c64(LOW)),bin('x','shr',local('x'),word(40)),ret(local('x'))],single,
 ()=>expected(0),{mustRemove:'shr'});
add('mask-is-not-a-low-bit-range',[bin('x','and',local('input'),word(0x80000000)),ret(local('x'))],single,
 ([x])=>expected(x&0x80000000n));
add('double-low-mask-idempotence',[bin('x','and',local('input'),c64(LOW)),bin('x','and',local('x'),c64(LOW)),ret(local('x'))],single,
 ([x])=>expected(x&LOW));
add('comparison-join-boolean-range',[bin('c','eq',local('input'),word(0)),
 branch(local('c'),[set('b',word(0))],[set('b',word(1))]),bin('tag','shr',local('b'),word(40)),ret(local('tag'))],single,
 ()=>expected(0),{mustRemove:'shr'});
add('join-zero-and-unknown',[bin('c','eq',local('input'),word(0)),
 branch(local('c'),[set('b',word(0))],[set('b',local('other'))]),bin('tag','shr',local('b'),word(40)),ret(local('tag'))],
 edges.flatMap(x=>[[0n,x],[1n,x]]),([flag,x])=>expected(flag===0n?0n:x>>40n),{params:['input','other']});
add('join-exact-low-equal-high-distinct',[bin('c','eq',local('input'),word(0)),
 branch(local('c'),[set('b',word(7))],[set('b',word(7,1))]),ret(local('b'))],[[0n],[1n]],
 ([flag])=>expected(flag===0n?7n:(1n<<32n)+7n));
add('mutable-copy-kills-stale-exact',[set('x',word(1)),set('x',local('input')),bin('tag','shr',local('x'),word(40)),ret(local('tag'))],single,
 ([x])=>expected(x>>40n));
add('load-kills-stale-exact',[set('x',word(1)),store('scratch',local('input')),load('x','scratch'),
 bin('tag','shr',local('x'),word(40)),ret(local('tag'))],single,([x])=>expected(x>>40n));
add('runtime-call-kills-stale-exact',[set('x',word(1)),rt('x','p111_rt_keep',local('input')),
 bin('tag','shr',local('x'),word(40)),ret(local('tag'))],single,([x])=>expected(x>>40n,['p111_rt_keep:'+x]));
add('direct-call-kills-stale-exact',[set('x',word(1)),call('x','identity',local('input')),
 bin('tag','shr',local('x'),word(40)),ret(local('tag'))],single,([x])=>expected(x>>40n),
 {prior:[fn('identity',['x'],[ret(local('x'))])]});
add('terminal-arm-excluded-from-survivor',[bin('c','eq',local('input'),word(0)),
 branch(local('c'),[ret(c64(MAX))],[set('x',word(1))]),bin('tag','shr',local('x'),word(40)),ret(local('tag'))],[[0n],[1n]],
 ([x])=>expected(x===0n?MAX:0n),{mustRemove:'shr'});
add('loop-carried-input-not-initial-constant',[bin('tag','shr',local('input'),word(40)),bin('done','eq',local('count'),word(0)),
 branch(local('done'),[ret(local('tag'))],[again(c64((1n<<48n)-1n),word(0))])],
 [[0n,1n],[1n,1n],[1n<<63n,0n]],([x,n])=>expected(n===0n?x>>40n:255n),{params:['input','count']});
add('folded-branch-preserves-runtime-order',[rt('ignored','p111_rt_keep',word(11)),
 bin('always','eq',word(7),word(7)),branch(local('always'),[
 rt('ignored','p111_rt_sink',word(22)),set('x',word(5))],[rt('ignored','p111_rt_sink',word(33)),set('x',word(9))]),
 rt('ignored','p111_rt_keep',word(44)),ret(local('x'))],[[]],()=>expected(5,['p111_rt_keep:11','p111_rt_sink:22','p111_rt_keep:44']),{params:[]});
add('folded-branch-preserves-stores',[store('scratch',word(11)),bin('never','eq',word(7),word(8)),
 branch(local('never'),[store('scratch',word(22))],[store('scratch',word(33))]),load('x','scratch'),ret(local('x'))],[[]],()=>expected(33),{params:[]});
for(const count of [0,31,32,40,63,64])for(const op of ['shr','shl','sar']) {
 add(op+'-count-'+count,[bin('x',op,local('input'),word(count)),ret(local('x'))],single,([x])=>{
  const shift=BigInt(count)%64n;
  return expected(op==='shr'?x>>shift:op==='shl'?(x<<shift)&MAX:(signed(x)>>shift)&MAX);
 });
}
for(const op of ['ult','ule','ugt','uge','slt','sle','sgt','sge','eq','ne']) {
 add('comparison-'+op,[bin('c',op,local('input'),local('other')),
  branch(local('c'),[ret(word(1))],[ret(word(0))])],edges.map((x,i)=>[x,edges[(i+4)%edges.length]]),([x,y])=>{
   const a=op.startsWith('s')?signed(x):x,b=op.startsWith('s')?signed(y):y;
   const truth=op.endsWith('lt')?a<b:op.endsWith('le')?a<=b:op.endsWith('gt')?a>b:op.endsWith('ge')?a>=b:op==='eq'?a===b:a!==b;
   return expected(truth?1:0);
  },{params:['input','other']});
}
for(const [name,op,a,b,want] of [['wrap-add','add',0xffffffff,1,0],['wrap-sub','sub',0,1,0xffffffff],
 ['shift32-modulo','shl',1,32,1],['shift63-modulo','shr',0x80000000,63,1],['arithmetic-sign','sar',0x80000000,1,0xc0000000]]) {
 add('u32-'+name,[typedBin('x',w,op,word(a),word(b)),typedBin('c',w,'eq',local('x'),word(want)),
  branch(local('c'),[ret(word(1))],[ret(word(0))])],[[]],()=>expected(1),{params:[]});
}
// All exact high-word edges must survive constant/copy simplification unchanged.
for(const value of edges)add('exact-copy-'+value,[set('x',c64(value)),set('y',local('x')),ret(local('y'))],[[]],()=>expected(value),{params:[]});
// Law-review extension: exercise the two-word exact-fold path, not only ranges.
for(const [value,count] of [[0x8000000000000001n,0],[0x8000000000000001n,1],
 [0xffffffff00000001n,31],[0xffffffff00000001n,32],[0xffffffff00000001n,33],
 [MAX,63],[1n,63],[MAX,64]])for(const op of ['shr','shl']) {
 add('exact-'+op+'-'+value+'-'+count,[bin('x',op,c64(value),word(count)),ret(local('x'))],[[]],
  ()=>expected(op==='shr'?value>>(BigInt(count)%64n):(value<<(BigInt(count)%64n))&MAX),{params:[]});
}
add('nested-scalar-branch-boolean-range',[bin('c','eq',local('input'),word(0)),
 scalar({$:'N111If',condition:local('c'),yes:list([{$:'N111Set',name:'b',typ:l,value:word(0)}]),
 no:list([{$:'N111Set',name:'b',typ:l,value:word(1)}])}),
 bin('tag','shr',local('b'),word(40)),ret(local('tag'))],single,()=>expected(0),{mustRemove:'shr'});
for(const op of ['slt','ult'])add('exact-sign-'+op,[bin('c',op,c64(MAX),word(1)),
 branch(local('c'),[ret(word(1))],[ret(word(0))])],[[]],()=>expected(op==='slt'?1:0),{params:[]});
save();
try {
 const api=(await import(pathToFileURL(apiFile))).default;
 for(const c of cases) {
  const row={name:c.name,observations:[]};report.cases.push(row);save();
  fs.writeFileSync(path.join(out,c.name+'.before.json'),JSON.stringify(c.program)+'\n');
  try {
   row.beforeDiagnostic=api.p113d_verify(c.program);if(row.beforeDiagnostic!=='')throw Error('Original invalid '+row.beforeDiagnostic);
   const after=api.p113k_optimize(c.program),twice=api.p113k_optimize(after);
   fs.writeFileSync(path.join(out,c.name+'.after.json'),JSON.stringify(after)+'\n');
   row.afterDiagnostic=api.p113d_verify(after);row.twiceDiagnostic=api.p113d_verify(twice);
   row.originalRetained=equal(after.original,c.program.original)&&equal(twice.original,c.program.original);
   for(const values of c.inputs) {
    const want=c.oracle(values),before=execute(c.program,'subject',values),actual=execute(after,'subject',values),again=execute(twice,'subject',values);
    row.observations.push({inputs:values.map(String),expected:want,before,after:actual,twice:again,pass:equal(before,want)&&equal(actual,want)&&equal(again,want)});
   }
   row.requiredFold=c.mustRemove?{op:c.mustRemove,before:ops(arr(c.program.functions).at(-1).body,c.mustRemove),after:ops(arr(after.functions).at(-1).body,c.mustRemove)}:null;
   row.pass=row.afterDiagnostic===''&&row.twiceDiagnostic===''&&row.originalRetained&&row.observations.every(x=>x.pass)&&(!row.requiredFold||row.requiredFold.after===0);
  }catch(error){row.error=String(error);row.pass=false;}
  save();console.log(JSON.stringify({name:row.name,pass:row.pass,error:row.error,observations:row.observations.length,requiredFold:row.requiredFold}));
 }
 report.complete=report.cases.every(x=>x.pass);report.groups=report.cases.length;
 report.observations=report.cases.reduce((n,x)=>n+x.observations.length,0);
 for(const p of report.inputs)if(!equal(pin(p.file),p))throw Error('Input changed '+p.file);
}catch(error){report.error=String(error);throw error;}
finally{save();}
if(!report.complete)process.exitCode=1;
