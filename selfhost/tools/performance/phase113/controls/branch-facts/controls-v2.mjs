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
const report={kind:'phase113-independent-branch-facts-controls',complete:false,
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
const wset=(name,value)=>scalar({$:'N111Set',name,typ:w,value});
const boolPrefix=[bin('b','and',local('input'),word(1)),bin('c','eq',local('b'),word(1))];
const returnB=()=>[ret(local('b'))];
add('mandatory-or-bit-cannot-equal-zero',[bin('x','or',local('input'),word(65536)),bin('c','eq',local('x'),word(0)),
 branch(local('c'),[ret(word(9))],[ret(word(7))])],single,()=>expected(7),{mustRemove:'eq'});
add('mandatory-high-bit-cannot-equal-zero',[bin('x','or',local('input'),c64(1n<<63n)),bin('c','eq',local('x'),word(0)),
 branch(local('c'),[ret(word(9))],[ret(word(7))])],single,()=>expected(7),{mustRemove:'eq'});
add('unknown-constructor-id-or-bit',[bin('x','or',{$:'N111CtorId',name:'True'},word(65536)),bin('c','eq',local('x'),word(0)),
 branch(local('c'),[ret(word(9))],[ret(word(7))])],[[]],()=>expected(7),{params:[],mustRemove:'eq'});
add('and-removes-mandatory-one',[bin('x','or',local('input'),word(65536)),bin('x','and',local('x'),word(65535)),
 bin('c','eq',local('x'),word(0)),branch(local('c'),[ret(word(1))],[ret(word(0))])],single,
 ([x])=>expected((x&65535n)===0n?1:0));
add('xor-cancels-mandatory-one',[bin('x','or',local('input'),word(65536)),bin('x','xor',local('x'),word(65536)),
 bin('c','eq',local('x'),word(0)),branch(local('c'),[ret(word(1))],[ret(word(0))])],single,
 ([x])=>expected(((x|65536n)^65536n)===0n?1:0));
add('join-only-common-mandatory-bits',[bin('flag','eq',local('input'),word(0)),
 branch(local('flag'),[bin('x','or',local('other'),word(65536))],[bin('x','or',local('other'),word(131072))]),
 bin('x','and',local('x'),word(65536)),ret(local('x'))],edges.flatMap(x=>[[0n,x],[1n,x]]),
 ([f,x])=>expected(((x|(f===0n?65536n:131072n))&65536n)),{params:['input','other']});
add('copied-condition-refines-valid-subject',[...boolPrefix,wset('copy',local('c')),
 branch(local('copy'),returnB(),returnB())],single,([x])=>expected(x&1n));
add('inverted-condition-preserves-truth',[...boolPrefix,typedBin('inv',w,'xor',local('c'),word(1)),
 branch(local('inv'),[bin('x','add',local('b'),word(10)),ret(local('x'))],returnB())],single,
 ([x])=>expected((x&1n)===0n?10n:1n));
add('stale-subject-after-condition-copy',[...boolPrefix,wset('copy',local('c')),set('b',local('other')),
 branch(local('copy'),returnB(),returnB())],edges.flatMap(x=>[[0n,x],[1n,x]]),([f,x])=>expected(x),{params:['input','other']});
add('stale-condition-after-overwrite',[...boolPrefix,bin('c','eq',local('other'),word(0)),
 branch(local('c'),returnB(),returnB())],[[0n,0n],[0n,1n],[1n,0n],[1n,1n]],([x])=>expected(x&1n),{params:['input','other']});
add('condition-load-overwrite',[...boolPrefix,store('scratch',word(0)),scalar({$:'N111Load',name:'c',typ:w,base:local('scratch'),offset:0}),
 branch(local('c'),returnB(),returnB())],single,([x])=>expected(x&1n));
add('subject-runtime-overwrite-trace',[...boolPrefix,rt('b','p111_rt_keep',local('other')),
 branch(local('c'),returnB(),returnB())],edges.flatMap(x=>[[0n,x],[1n,x]]),
 ([f,x])=>expected(x,['p111_rt_keep:'+x]),{params:['input','other']});
add('subject-direct-vector-overwrite',[...boolPrefix,call(['b','unused'],'pair',local('other')),
 branch(local('c'),returnB(),returnB())],edges.flatMap(x=>[[0n,x],[1n,x]]),([f,x])=>expected(x),
 {params:['input','other'],prior:[fn('pair',['x'],[ret(local('x'),word(0))],2,false)]});
add('condition-result-alias-subject',[bin('x','eq',local('input'),word(0)),typedBin('x',w,'eq',local('x'),word(0)),
 branch(local('x'),[typedBin('y',w,'eq',local('x'),word(0)),branch(local('y'),[ret(word(7))],[ret(word(9))])],[ret(word(8))])],
 single,([x])=>expected(x===0n?8:9));
add('branch-mutation-not-leaked',[...boolPrefix,branch(local('c'),[set('b',word(0))],[set('b',word(1))]),
 bin('new','eq',local('b'),word(1)),branch(local('new'),[ret(word(3))],[ret(word(4))])],single,
 ([x])=>expected((x&1n)===0n?3:4));
add('join-drops-equal-epoch-different-relations',[bin('flag','eq',local('input'),word(0)),bin('b','and',local('other'),word(1)),
 branch(local('flag'),[bin('c','eq',local('b'),word(0))],[bin('c','eq',local('b'),word(1))]),
 branch(local('c'),returnB(),returnB())],[[0n,0n],[0n,1n],[1n,0n],[1n,1n]],
 ([f,x])=>expected(x&1n),{params:['input','other']});
add('unknown-fullwidth-is-not-a-Bool',[bin('c','eq',local('input'),word(1)),
 branch(local('c'),[ret(local('input'))],[ret(local('input'))])],single,([x])=>expected(x),{kind32:true});
add('ordinary-local-cannot-collide-with-hidden-key',[set('condition_c',local('input')),...boolPrefix,
 branch(local('c'),[ret(local('condition_c'))],[ret(local('condition_c'))])],single,([x])=>expected(x));
add('branch-refinement-preserves-effect-order',[...boolPrefix,rt('ignored','p111_rt_keep',word(11)),
 branch(local('c'),[rt('ignored','p111_rt_sink',word(22)),ret(local('b'))],
 [rt('ignored','p111_rt_sink',word(33)),ret(local('b'))])],single,
 ([x])=>expected(x&1n,['p111_rt_keep:11','p111_rt_sink:'+((x&1n)===1n?22:33)]));
// A reassigned subject must remain Bool-bounded so only epoch validity, not
// the numeric range gate, can prevent stale refinement.
add('stale-subject-overwritten-with-another-Bool',[...boolPrefix,wset('copy',local('c')),
 bin('b','and',local('other'),word(1)),branch(local('copy'),returnB(),returnB())],
 [[0n,0n],[0n,1n],[1n,0n],[1n,1n]],([f,x])=>expected(x&1n),{params:['input','other']});
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
 report.refusals=[];
 for(const [name,subject] of [
  ['hidden-relation-key-parameter',fn('subject',['@condition:c'],[ret(word(0))])],
  ['hidden-relation-key-local',fn('subject',[],[set('@condition:c',word(1)),ret(word(0))])]]) {
  const original=bundle([subject]),diagnostic=api.p113d_verify(original),after=api.p113k_optimize(original);
  report.refusals.push({name,diagnostic,originalRetained:equal(after,original),pass:diagnostic!==''&&equal(after,original)});
 }
 report.complete=report.cases.every(x=>x.pass)&&report.refusals.every(x=>x.pass);report.groups=report.cases.length;
 report.observations=report.cases.reduce((n,x)=>n+x.observations.length,0);
 for(const p of report.inputs)if(!equal(pin(p.file),p))throw Error('Input changed '+p.file);
}catch(error){report.error=String(error);throw error;}
finally{save();}
if(!report.complete)process.exitCode=1;
