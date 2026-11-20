// Finite, independently interpreted IR controls for the checked Bend certificate.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import {pathToFileURL} from 'node:url';
const opts={};for(let i=2;i<process.argv.length;i+=2)opts[process.argv[i].slice(2)]=process.argv[i+1];
if(!/^Cpus_allowed_list:\s*3$/m.test(fs.readFileSync('/proc/self/status','utf8')))throw Error('CPU3 guard required');
const out=path.resolve(opts.out);if(fs.existsSync(out))throw Error('fresh controls root required');fs.mkdirSync(out,{recursive:true});
const read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
const pin=p=>({file:path.resolve(p),bytes:fs.statSync(p).size,sha256:crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex')});
const need=(v,m)=>{if(!v)throw Error(m);};const copy=x=>structuredClone(x);
const receipt=read(opts.api);need(receipt.complete&&receipt.checked&&!receipt.error,'checked API');need(pin(receipt.api.file).sha256===receipt.api.sha256,'API pin');need(pin(receipt.source.file).sha256===receipt.source.sha256,'source pin');
const api=(await import(pathToFileURL(receipt.api.file))).default;
const dir='selfhost/build/phase198/numeric-followup02/capture/';const source=read(dir+'mit-ir.json'),entry=read(dir+'mit-typed-entry.json');
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const array=xs=>{const a=[];while(xs.$==='Con'){a.push(xs.head);xs=xs.tail;}need(xs.$==='Nil','list');return a;};
const local=name=>({$:'N111Local',name});const constant=(lo,hi=0)=>({$:'N111Const',lo,hi});
const bin=(name,typ,op,left,right)=>({$:'P113DScalar',stmt:{$:'N111Bin',name,typ:{$:typ},op,left,right}});
const body=source.body,params=entry.params,names=array(params).map(x=>x.word),fuel=names[0],mode=names[5],resultName=names[6];
const report={complete:false,api:pin(opts.api),capture:pin(dir+'capture.json'),method:pin('research/phase198/numeric/controls.mjs'),seed:198,checks:[],interpretations:0,abstractObservations:0};
const save=()=>fs.writeFileSync(out+'/controls.json',JSON.stringify(report,null,2)+'\n');
function visit(x,fn){if(x&&typeof x==='object'){fn(x);for(const y of Object.values(x))if(y&&typeof y==='object')visit(y,fn);}}
const changed=(a,b)=>JSON.stringify(a)!==JSON.stringify(b);
const guardCount=x=>{let n=0;visit(x,y=>{if(y.$==='N111Bin'&&y.name==='p198n_nonzero_exit')n++;});return n;};
function check(name,input,p,accept){const result=api.x198n_body(input,p);need(changed(result,input)===accept,name+' changed');need(guardCount(result)===(accept?1:guardCount(input)),name+' guard');report.checks.push({name,accept});save();return result;}
const transformed=check('actual-current-mit',body,params,true);fs.writeFileSync(out+'/transformed-ir.json',JSON.stringify(transformed,null,2)+'\n');
for(let i=1;i<names.length;i++){let p=copy(params),a=array(p);a[i].kind={$:'N_W64'};check('refuse-noncanonical-param-'+i,body,p,false);}
let p=copy(params);array(p)[0].kind={$:'N_Box'};check('refuse-boxed-fuel',body,p,false);
function mutate(name,predicate,change,accept=false){let x=copy(body),done=false;visit(x,y=>{if(!done&&predicate(y)){done=true;change(y);}});need(done,name+' mutation');return check(name,x,params,accept);}
mutate('refuse-low32-fuel-test',x=>x.$==='N111Bin'&&x.op==='eq'&&x.left?.name===fuel,x=>x.typ={$:'N111U32'});
mutate('refuse-fuel-step-two',x=>x.$==='N111Bin'&&x.op==='sub'&&x.left?.name===fuel,x=>x.right=constant(2));
mutate('refuse-mode-not-absorbing',x=>x.$==='N111Bin'&&x.op==='or'&&x.left?.name==='p112_s_a',x=>x.op='and');
mutate('refuse-observable-fuel',x=>x.$==='P113DResult',x=>x.values=list([local(fuel)]));
mutate('refuse-observable-mode',x=>x.$==='P113DResult',x=>x.values=list([local(mode)]));
mutate('refuse-changing-other-state',x=>x.$==='P113DAgain',x=>{let v=array(x.values);v[1]=constant(0);x.values=list(v);});
mutate('refuse-arity-mismatch',x=>x.$==='P113DAgain',x=>x.values=list(array(x.values).slice(1)));
mutate('refuse-fresh-name-collision',x=>x.$==='N111Set',x=>x.name='p198n_nonzero_exit');
mutate('refuse-call-effect',x=>x.$==='P113DScalar'&&x.stmt?.$==='N111Set',x=>x.stmt={$:'N111Call',name:'effect',typ:{$:'N111U64'},symbol:'external_effect',args:list([])});
mutate('refuse-load-effect',x=>x.$==='P113DScalar'&&x.stmt?.$==='N111Set',x=>x.stmt={$:'N111Load',name:'effect',typ:{$:'N111U64'},base:local('state'),offset:0});
mutate('refuse-store-effect',x=>x.$==='P113DScalar'&&x.stmt?.$==='N111Set',x=>x.stmt={$:'N111Store',typ:{$:'N111U64'},base:local('state'),offset:0,value:constant(1)});
mutate('refuse-trapping-division',x=>x.$==='N111Bin'&&x.op==='mul',x=>{x.op='div';x.right=constant(0);});
mutate('refuse-parameter-reassignment',x=>x.$==='N111Set',x=>x.name=names[1]);
let huge=copy(body);let inner=array(array(huge)[1].no)[1];inner.yes=list([...Array.from({length:300},(_,i)=>({$:'P113DScalar',stmt:{$:'N111Set',name:'extra_'+i,typ:{$:'N111U64'},value:constant(0)}})),...array(inner.yes)]);check('refuse-body-budget',huge,params,false);
// Renaming every local demonstrates that the rule has no benchmark or parameter IDs.
const renaming=new Map();let serial=0;const rename=x=>{if(!renaming.has(x))renaming.set(x,'renamed_'+serial++);return renaming.get(x);};
let renamedBody=copy(body),renamedParams=copy(params);
for(const x of [renamedBody,renamedParams])visit(x,y=>{if(typeof y.name==='string')y.name=rename(y.name);if(typeof y.word==='string')y.word=rename(y.word);});
check('accept-systematic-renaming',renamedBody,renamedParams,true);
const mask64=(1n<<64n)-1n,mask32=(1n<<32n)-1n;
function operation(op,a,b,width){let mask=width===32?mask32:mask64;a&=mask;b&=mask;let v;
 switch(op){case 'add':v=a+b;break;case 'sub':v=a-b;break;case 'mul':v=a*b;break;case 'and':v=a&b;break;case 'or':v=a|b;break;case 'xor':v=a^b;break;case 'shl':v=a<<(b&BigInt(width-1));break;case 'shr':v=a>>(b&BigInt(width-1));break;case 'sar':{let s=a;if(s&(1n<<BigInt(width-1)))s-=1n<<BigInt(width);v=s>>(b&BigInt(width-1));break;}case 'eq':v=BigInt(a===b);break;case 'ne':v=BigInt(a!==b);break;case 'ult':v=BigInt(a<b);break;case 'ule':v=BigInt(a<=b);break;case 'ugt':v=BigInt(a>b);break;case 'uge':v=BigInt(a>=b);break;default:throw Error('operator '+op);}return v&mask;}
let lastIterations=0;
function interpret(code,inputs,limit=100){const env=new Map(names.map((n,i)=>[n,inputs[i]]));env.set('state',0n);
 const value=x=>x.$==='N111Const'?BigInt(x.lo)+(BigInt(x.hi)<<32n):(need(env.has(x.name),'undefined '+x.name),env.get(x.name));
 function run(rows){for(const s of array(rows)){if(s.$==='P113DScalar'){const x=s.stmt;if(x.$==='N111Set')env.set(x.name,value(x.value)&(x.typ.$==='N111U32'?mask32:mask64));else if(x.$==='N111Bin')env.set(x.name,operation(x.op,value(x.left),value(x.right),x.typ.$==='N111U32'?32:64));else if(x.$==='N111If'){let r=run(list(array(value(x.condition)!==0n?x.yes:x.no).map(stmt=>({$:'P113DScalar',stmt}))));if(r)return r;}else throw Error('effect reached '+x.$);}else if(s.$==='P113DIf'){let r=run(value(s.condition)!==0n?s.yes:s.no);if(r)return r;}else if(s.$==='P113DAgain')return {again:array(s.values).map(value)};else if(s.$==='P113DResult')return {result:array(s.values).map(value)};else throw Error('row '+s.$);}return null;}
 for(let count=0;count<limit;count++){let r=run(code);need(r,'no terminator');if(r.result){lastIterations=count;return r.result;}if(r.again){need(r.again.length===names.length,'backedge');names.forEach((n,i)=>env.set(n,r.again[i]));}}
 throw Error('interpreter fuel');}
let rng=198;const rand=()=>{rng^=rng<<13;rng^=rng>>>17;rng^=rng<<5;return rng>>>0;};
const cases=[];
for(let i=0;i<1024;i++){let xs=[BigInt(i%41),...Array.from({length:6},()=>BigInt(rand()))];if(i%3===0)xs[3]=xs[4]=xs[5]=0n;if(i%7===0)xs[5]=0n;let a=interpret(body,xs),b=interpret(transformed,xs);need(JSON.stringify(a.map(String))===JSON.stringify(b.map(String)),'IR semantic '+i);cases.push({inputs:xs.map(String),result:a.map(String)});report.interpretations++;}
const nonescaping=[8192n,0n,0n,0n,0n,0n,0n];
const nonescapeBefore=interpret(body,nonescaping,8194),beforeIterations=lastIterations;
const nonescapeAfter=interpret(transformed,nonescaping,8194),afterIterations=lastIterations;
need(nonescapeBefore[0]===8192n&&nonescapeAfter[0]===8192n&&beforeIterations===8192&&afterIterations===8192,'scalar8192 negative transfer');
report.negativeTransfer={case:'scalar-region-8192',seed:524800,coordinates:[0,0],result:'8192',beforeIterations,afterIterations,scope:'Independent IR interpretation; no claim of unchanged machine time. Added guard may regress.'};report.interpretations++;
// Large full-width fuel terminates via proven stable state, with canonical U32 fields.
for(const n of [1n<<32n,(1n<<63n)+1n,mask64]){let xs=[n,1n,2n,3n,4n,0x80000000n,mask32];let got=interpret(transformed,xs,2);need(got.length===1&&got[0]===mask32,'full-width stable exit');report.interpretations++;}
// A positive full-width fuel with zero low word must still execute its live prefix.
const escapingPrefix=[3n,0xfffffe00n,0xfffffe80n,0n,0n,0n,0n];
need(interpret(body,escapingPrefix,8)[0]===1n,'independent escaping prefix');
report.fullWidthLivePrefix=[];
for(const n of [1n<<32n,(1n<<63n)+1n,mask64]){let xs=[n,...escapingPrefix.slice(1)];let got=interpret(transformed,xs,8);need(got[0]===1n&&lastIterations===2,'full-width live prefix');report.fullWidthLivePrefix.push({fuel:String(n),result:'1',completedBackedges:lastIterations});report.interpretations++;}
fs.writeFileSync(out+'/ir-cases.json',JSON.stringify(cases)+'\n');
const facts=[{$:'X198NUnknown'},{$:'X198NConst',lo:0,hi:0},{$:'X198NConst',lo:1,hi:0},{$:'X198NConst',lo:0xffffffff,hi:0},{$:'X198NConst',lo:0,hi:1},{$:'X198NAlias',name:'a',narrow:true},{$:'X198NAlias',name:'b',narrow:false},{$:'X198NNonzero',narrow:true},{$:'X198NNonzero',narrow:false}];
function concrete(f,aliases){if(f.$==='X198NConst')return BigInt(f.lo)+(BigInt(f.hi)<<32n);if(f.$==='X198NAlias')return aliases[f.name];let v=(BigInt(rand())<<32n)|BigInt(rand());if(f.$==='X198NNonzero')v|=f.narrow?1n:1n<<32n;return v;}
function satisfies(f,v,aliases){switch(f.$){case 'X198NUnknown':return true;case 'X198NConst':return v===BigInt(f.lo)+(BigInt(f.hi)<<32n);case 'X198NAlias':return v===aliases[f.name];case 'X198NNonzero':return f.narrow?(v&mask32)!==0n:v!==0n;default:return false;}}
for(const width of [32,64])for(const op of ['add','sub','mul','and','or','xor','shl','shr','sar','eq','ne','ult','ule','ugt','uge'])for(const left of facts)for(const right of facts){
 const stmt=bin('answer','N111U'+width,op,local('left'),local('right'));
 const result=api.x198n_eval(list([stmt]),list([{$:'X198NBinding',name:'left',fact:left},{$:'X198NBinding',name:'right',fact:right}]),'fuel');need(result.valid,'abstract accepted');const found=array(result.env).find(x=>x.name==='answer').fact;
 for(let j=0;j<4;j++){let aliases={a:BigInt(rand()),b:(BigInt(rand())<<32n)|BigInt(rand())};let a=concrete(left,aliases),b=concrete(right,aliases),actual=operation(op,a,b,width);need(satisfies(found,actual,aliases),'unsound abstract '+JSON.stringify({width,op,left,right,found,actual:String(actual)}));report.abstractObservations++;}}
report.complete=true;save();console.log(JSON.stringify({complete:true,checks:report.checks.length,interpretations:report.interpretations,abstractObservations:report.abstractObservations}));
