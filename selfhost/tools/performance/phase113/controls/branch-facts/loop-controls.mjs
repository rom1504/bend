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
const report={kind:'phase113-independent-branch-loop-controls',complete:false,
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
function add(name,body,inputs,oracle,{params=['remaining','value','acc'],prior=[]}={}) {
 cases.push({name,program:bundle([...prior,fn('subject',params,body)]),inputs,oracle,mustRemove:null});
}
const wset=(name,value)=>scalar({$:'N111Set',name,typ:w,value});
const wbin=(name,op,left,right)=>typedBin(name,w,op,left,right);
const sbranch=(condition,yes,no)=>scalar({$:'N111If',condition,
 yes:list(yes.map(s=>s.stmt)),no:list(no.map(s=>s.stmt))});
const low32=x=>x&LOW;
const inputs=[0n,1n,2n,3n,7n].flatMap(n=>[0n,1n,2n,3n,LOW,1n<<40n,MAX].map(v=>[n,v,0n]));
function recurrence(values,mode,inverted,cmp) {
 let [n,x,a]=values;const trace=[];
 while(n-->0n) {
  let b=x&1n;let c=cmp==='eq0'?b===0n:cmp==='eq1'?b===1n:cmp==='ne0'?b!==0n:b!==1n;
  if(inverted)c=!c;
  if(mode==='subject-write')b=(x>>1n)&1n;
  if(mode==='condition-write')c=((x>>1n)&1n)===1n;
  let selected=b+(c?11n:23n);
  if(mode==='mandatory-join')selected=(selected|65536n)&65535n;
  if(mode==='effect')trace.push('p111_rt_keep:'+b,'p111_rt_sink:'+selected);
  x=low32((x<<1n)^selected);a=low32(a*33n+selected);
 }
 return expected(a,trace);
}
// Same finite recurrence exercised with distinct syntactic/control-flow shapes.
// Oracle above is ordinary arithmetic and does not interpret compiler facts.
for(const mode of ['plain','subject-write','condition-write','mandatory-join','effect'])
for(const inverted of [false,true])
for(const scalarBranches of [false,true]) {
 const choose=scalarBranches?sbranch:branch;
 const work=[bin('b','and',local('value'),word(1)),bin('c','eq',local('b'),word(1)),wset('copy',local('c'))];
 if(inverted)work.push(wbin('copy','xor',local('copy'),word(1)));
 if(mode==='subject-write')work.push(bin('temp','shr',local('value'),word(1)),bin('b','and',local('temp'),word(1)));
 if(mode==='condition-write')work.push(bin('temp','shr',local('value'),word(1)),bin('temp','and',local('temp'),word(1)),bin('copy','eq',local('temp'),word(1)));
 if(mode==='effect')work.push(rt('ignored','p111_rt_keep',local('b')));
 work.push(choose(local('copy'),[bin('selected','add',local('b'),word(11))],[bin('selected','add',local('b'),word(23))]));
 if(mode==='mandatory-join')work.push(bin('selected','or',local('selected'),word(65536)),bin('selected','and',local('selected'),word(65535)));
 if(mode==='effect')work.push(rt('ignored','p111_rt_sink',local('selected')));
 work.push(bin('next','shl',local('value'),word(1)),bin('next','xor',local('next'),local('selected')),bin('next','and',local('next'),word(4294967295)),
 bin('sum','mul',local('acc'),word(33)),bin('sum','add',local('sum'),local('selected')),bin('sum','and',local('sum'),word(4294967295)),
 bin('n','sub',local('remaining'),word(1)),again(local('n'),local('next'),local('sum')));
 add('recurrence-'+mode+'-'+Number(inverted)+'-'+(scalarBranches?'scalar':'direct'),
 [bin('done','eq',local('remaining'),word(0)),branch(local('done'),[ret(local('acc'))],work)],inputs,
 values=>recurrence(values,mode,inverted,'eq1'));
}
// Distinct equality polarities and aliases on the condition result itself.
for(const [op,k] of [['eq',0],['ne',0],['ne',1]]) {
 const work=[bin('b','and',local('value'),word(1)),bin('c',op,local('b'),word(k)),wbin('c','xor',local('c'),word(1)),
 branch(local('c'),[bin('selected','add',local('b'),word(11))],[bin('selected','add',local('b'),word(23))]),
 bin('next','shl',local('value'),word(1)),bin('next','xor',local('next'),local('selected')),bin('next','and',local('next'),word(4294967295)),
 bin('sum','mul',local('acc'),word(33)),bin('sum','add',local('sum'),local('selected')),bin('sum','and',local('sum'),word(4294967295)),
 bin('n','sub',local('remaining'),word(1)),again(local('n'),local('next'),local('sum'))];
 add('recurrence-polarity-'+op+k,[bin('done','eq',local('remaining'),word(0)),branch(local('done'),[ret(local('acc'))],work)],inputs,
 values=>recurrence(values,'plain',true,op+k));
}
// Multiple relations survive until an assumption; the subject is unchanged
// at runtime even when its abstract fact/version is refined on a branch.
for(const scalarBranches of [false,true]) {
 const choose=scalarBranches?sbranch:branch;
 add('two-relations-refinement-'+(scalarBranches?'scalar':'direct'),[
  bin('b','and',local('value'),word(1)),bin('c','eq',local('b'),word(0)),bin('d','ne',local('b'),word(0)),
  choose(local('c'),[choose(local('d'),[set('answer',word(99))],[set('answer',local('b'))])],
    [choose(local('d'),[set('answer',local('b'))],[set('answer',word(98))])]),ret(local('answer'))],
  edges.map(x=>[0n,x,0n]),([n,x])=>expected(x&1n));
}
// No assignment between a predicate's subject and destination: their physical
// local names alias. A recorded relation must not describe the old value.
add('condition-reuses-subject-with-Again',[
 bin('done','eq',local('remaining'),word(0)),branch(local('done'),[ret(local('acc'))],[
  bin('b','eq',local('value'),word(0)),wbin('b','eq',local('b'),word(0)),
  branch(local('b'),[set('selected',word(11))],[set('selected',word(23))]),
  bin('next','xor',local('value'),word(1)),bin('sum','add',local('acc'),local('selected')),
  bin('n','sub',local('remaining'),word(1)),again(local('n'),local('next'),local('sum'))])],inputs,
 ([n,x,a])=>{while(n-->0n){a+=x!==0n?11n:23n;x^=1n;}return expected(a);});
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
