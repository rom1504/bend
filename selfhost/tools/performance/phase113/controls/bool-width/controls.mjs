// Independent ordinary structural and finite functional controls. No native jobs.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {isDeepStrictEqual as equal} from 'node:util';
import {list,arr,l,w,ptr,word,local,scalar,set,bin,ret,again,call,branch,rt,fn,bundle,execute} from '../branch-facts/ir-model.mjs';
const [apiArg,outArg]=process.argv.slice(2);
if(!apiArg||!outArg||process.argv.length!==4)throw Error('Usage: controls.mjs CHECKED_API FRESH_PHASE113_OUT');
const root=path.resolve(import.meta.dirname,'../../../../../..'),apiFile=path.resolve(apiArg),out=path.resolve(outArg);
if(!out.startsWith(root+'/selfhost/build/phase113/')||fs.existsSync(out))throw Error('Fresh Phase113 output required');
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return {file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const receiptFile=path.join(path.dirname(apiFile),'report.json'),receipt=JSON.parse(fs.readFileSync(receiptFile));
const apiPin=pin(apiFile),required=['p113bq_scalar','p113bq_direct','p113bq_ready','p113bq_emit','p113d_verify'];
if(!receipt.complete||!receipt.checked||!required.every(x=>receipt.exports?.includes(x))||receipt.api.sha256!==apiPin.sha256||receipt.api.bytes!==apiPin.bytes||path.resolve(receipt.api.file)!==apiFile)throw Error('Matching complete checked Bool-width API required');
fs.mkdirSync(out,{recursive:true});fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase113-independent-bool-width-controls',complete:false,targetExecutions:false,
 inputs:[pin(import.meta.filename),pin(path.join(import.meta.dirname,'../branch-facts/ir-model.mjs')),apiPin,pin(receiptFile)],cases:[],
 scope:'Exact pure-branch recognition, guarded emission, and independent finite zero/nonzero normalization. Abstract original-IR interpretation plus emitted two-instruction semantics; no native code execution or backend proof.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const rows=[];const check=(name,actual,want)=>{const row={name,actual,expected:want,pass:equal(actual,want)};report.cases.push(row);save();console.log(JSON.stringify(row));};
const no={$:'P113BQNo'},yes=(name,invert)=>({$:'P113BQYes',name,invert});
const stmt=(name,value,typ=l)=>({$:'N111Set',name,typ,value});
const atom={$:'KTerm',tag:'Absent',name:'',id:0,quant:0,kids:list([]),removed:list([]),originBegin:0,originEnd:0};
const missing={$:'KDef',name:'',kind:'Absent',arity:0,templates:0,typ:atom,value:atom,ctors:list([]),native:false,unsafe:false};
const ids={$:'N111Ids',functions:missing,constructors:missing};
const code=(next=7,terminal=false,error='',chunks=[])=>({$:'P111QCode',chunks:list(chunks),next,terminal,error});
const edges=[0n,1n,2n,3n,2147483647n,2147483648n,4294967295n];
const scalarBranches=(a,b)=>[list(a),list(b)];
const directBranches=(a,b)=>[list(a.map(scalar)),list(b.map(scalar))];
const casePairs=[];
for(const invert of [false,true])casePairs.push({name:'pure-'+Number(invert),
 a:[stmt('result',word(invert?0:1))],b:[stmt('result',word(invert?1:0))],expected:yes('result',invert)});
const effect=rt('ignored','p111_rt_keep',word(5)).stmt;
const invalid=[
 ['different-destinations',[stmt('left',word(1))],[stmt('right',word(0))]],
 ['word-destination',[stmt('result',word(1),w)],[stmt('result',word(0),w)]],
 ['pointer-destination',[stmt('result',word(1),ptr)],[stmt('result',word(0),ptr)]],
 ['different-widths',[stmt('result',word(1),l)],[stmt('result',word(0),w)]],
 ['same-one',[stmt('result',word(1))],[stmt('result',word(1))]],
 ['same-zero',[stmt('result',word(0))],[stmt('result',word(0))]],
 ['other-number',[stmt('result',word(2))],[stmt('result',word(0))]],
 ['nonzero-high-word',[stmt('result',word(1,1))],[stmt('result',word(0))]],
 ['local-rhs',[stmt('result',local('input'))],[stmt('result',word(0))]],
 ['empty-arms',[],[]],['empty-yes',[],[stmt('result',word(0))]],
 ['two-yes',[stmt('result',word(1)),stmt('other',word(0))],[stmt('result',word(0))]],
 ['two-no',[stmt('result',word(1))],[stmt('other',word(0)),stmt('result',word(0))]],
 ['effect-before',[effect,stmt('result',word(1))],[stmt('result',word(0))]],
 ['effect-after',[stmt('result',word(1))],[stmt('result',word(0)),effect]],
 ['call-only',[effect],[stmt('result',word(0))]],
 ['hidden-return',[{$:'N111Return',value:word(1)}],[stmt('result',word(0))]],
 ['nested-branch',[{$:'N111If',condition:word(1),yes:list([stmt('result',word(1))]),no:list([stmt('result',word(0))])}],[stmt('result',word(0))]],
 ];
for(const [name,a,b] of invalid)casePairs.push({name,a,b,expected:no});
save();
try {
 const api=(await import(pathToFileURL(apiFile))).default;
 for(const c of casePairs){check('scalar-'+c.name,api.p113bq_scalar(...scalarBranches(c.a,c.b)),c.expected);check('direct-'+c.name,api.p113bq_direct(...directBranches(c.a,c.b)),c.expected);}
 for(const [name,a,b] of [
  ['result-terminal',[ret(word(1))],[ret(word(0))]],
  ['again-terminal',[again(word(1))],[again(word(0))]],
  ['direct-call',[call('result','helper',word(1))],[set('result',word(0))]],
  ['nested-direct',[branch(word(1),[set('result',word(1))],[set('result',word(0))])],[set('result',word(0))]]])
  check('direct-refuses-'+name,api.p113bq_direct(list(a),list(b)),no);
 for(const [name,d,c,want] of [
  ['zero',yes('result',false),code(0),true],['ordinary',yes('result',false),code(),true],
  ['last-counter',yes('result',true),code(4294967294),true],['counter-exhausted',yes('result',false),code(4294967295),false],
  ['terminal',yes('result',false),code(7,true),false],['error',yes('result',false),code(7,false,'existing error'),false],
  ['not-diamond',no,code(),false]])check('ready-'+name,api.p113bq_ready(d,c),want);
 for(const invert of [false,true])for(const destination of ['result','p113_bool_7']) {
  const original=code(7,false,'',['existing-prefix\n']);
  const actual=api.p113bq_emit(local('condition'),yes(destination,invert),ids,original);
  const expected=code(8,false,'',[
   '%v_'+destination+' =l extuw %p113_bool_7\n',
   '%p113_bool_7 =w '+(invert?'ceqw':'cnew')+' %v_condition, 0\n','existing-prefix\n']);
  check('emission-'+Number(invert)+'-'+destination,actual,expected);
  // The emitted grammar is exact above; evaluate its actual comparison spelling
  // independently for arbitrary U32 inputs, then its unsigned width conversion.
  const lines=arr(actual.chunks).slice(0,2).reverse();
  const match=/ =w (ceqw|cnew) %v_condition, 0\n$/.exec(lines[0]);
  for(const x of edges){
   const program=bundle([fn('subject',[],[
    scalar(stmt('condition',word(Number(x)),w)),
    branch(local('condition'),[set('result',word(invert?0:1))],[set('result',word(invert?1:0))]),ret(local('result'))])]);
   check('verified-original-'+Number(invert)+'-'+destination+'-'+x,api.p113d_verify(program),'');
   const want=invert?(x===0n?1n:0n):(x!==0n?1n:0n);
   const observed=match?(match[1]==='ceqw'?(x===0n?1n:0n):(x!==0n?1n:0n)):null;
   check('normalization-'+Number(invert)+'-'+destination+'-'+x,
    {original:execute(program,'subject',[]),emitted:observed===null?null:String(observed&0xffffffffn)},
    {original:{values:[String(want)],trace:[]},emitted:String(want)});
  }
 }
 check('invalid-emission-preserves-prefix',api.p113bq_emit(word(0),no,ids,code(3,false,'',['prefix\n'])),code(3,false,'invalid private Boolean diamond',['prefix\n']));
 for(const p of report.inputs)if(!equal(pin(p.file),p))throw Error('Input changed '+p.file);
 report.complete=report.cases.every(x=>x.pass);report.count=report.cases.length;
}catch(error){report.error=String(error);throw error;}
finally{save();}
if(!report.complete)process.exitCode=1;
