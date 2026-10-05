// Execute a production Bend pass through a diagnostic export of its checked API.
// This adds one export to a fresh copy; it never edits/rebuilds the checked API.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [attemptArg,outArg]=process.argv.slice(2);assert(outArg,'jw-ir-controls-v1.mjs CHECKED_ATTEMPT NEW_OUT');
const root=fs.realpathSync(attemptArg),out=path.resolve(outArg);fs.mkdirSync(out);
const report={kind:'phase47-production-jw-pass-ir-controls',complete:false,pass:false,inputs:[],cases:[],
  scope:'Synthetic private JW graphs through the actual checked pass; independent bounded interpreter observes values/errors/effects. No frontend, emitter, timing or universal soundness claim.'};
const hash=b=>createHash('sha256').update(b).digest('hex');
const identity=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return{file,sha256:hash(b),bytes:b.length};};
const pin=file=>{const x=identity(file);report.inputs.push(x);return x;};
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
function array(xs){const a=[];while(xs?.$==='Con'){assert(a.length<10000);a.push(xs.head);xs=xs.tail;}assert.equal(xs?.$,'Nil');return a;}
const slot=n=>({$:'JWSlot',slot:n}),lit=n=>({$:'JWLiteral',code:String(n)}),nat=n=>({$:'JWNat',number:n});
const global=name=>({$:'JWGlobal',name,layout:'u32'});
const prim=(name,...args)=>({$:'JWPrimitive',name,args:list(args)});
const ctor=(layout,name,...fields)=>({$:'JWConstruct',layout,name,fields:list(fields)});
const project=(layout,input,index)=>({$:'JWProject',layout,input,index});
const assign=(n,value)=>({$:'JWAssign',slot:n,value}),ret=value=>({$:'JWReturn',value});
const call=(n,target,...args)=>({$:'JWDirectCall',slot:n,target,args:list(args)});
const branch=(input,yes,no,layout='bool',name='True')=>({$:'JWCase',layout,name,input,yes:list(yes),no:list(no)});
const fun=(name,arity,code,valid=true)=>({$:'JWFunction',name,arity,code:list(code),valid});
function counts(functions){const sums={instructions:0,calls:0,constructors:0,projections:0};
  function walk(v){if(!v||typeof v!=='object')return;if(v.$?.startsWith('JW')&&['JWAssign','JWDirectCall','JWCase','JWReturn','JWImpossible'].includes(v.$))sums.instructions++;
    if(v.$==='JWDirectCall')sums.calls++;if(v.$==='JWConstruct')sums.constructors++;if(v.$==='JWProject')sums.projections++;for(const x of Object.values(v))if(x&&typeof x==='object')walk(x);}
  functions.forEach(walk);return sums;}
function execute(functions,args,mode='normal'){
  const events=[];let ticks=0,fuel=10000;
  function value(v,slots){
    switch(v.$){
      case 'JWSlot':if(!(v.slot in slots))throw Error('undefined-slot:'+v.slot);return slots[v.slot];
      case 'JWLiteral':if(v.code==='true')return true;if(v.code==='false')return false;assert(/^\d+$/.test(v.code));return Number(v.code);
      case 'JWNat':return BigInt(v.number);
      case 'JWGlobal':events.push(v.name);if(v.name==='boom'||mode===v.name)throw Error('global:'+v.name);return ++ticks;
      case 'JWConstruct':{const fields=array(v.fields).map(x=>value(x,slots));return v.layout==='tuple'?fields:{$:v.name,fields};}
      case 'JWProject':{const x=value(v.input,slots);return v.layout==='tuple'?x[v.index]:x.fields[v.index];}
      case 'JWNative':{const args=array(v.args).map(x=>value(x,slots));if(v.name!=='sink')throw Error('unknown-native:'+v.name);events.push(['sink',args]);return 23;}
      case 'JWPrimitive':{const a=array(v.args).map(x=>value(x,slots));switch(v.name){
        case 'U32.add':return(a[0]+a[1])>>>0;case 'U32.sub':return(a[0]-a[1])>>>0;case 'U32.mul':return Math.imul(a[0],a[1])>>>0;
        case 'U32.xor':return(a[0]^a[1])>>>0;case 'U32.is_eq':return a[0]===a[1];default:throw Error('unknown-primitive:'+v.name);}}
      default:throw Error('unknown-value:'+v.$);
    }
  }
  function invoke(at,args){if(--fuel<0)throw Error('interpreter-fuel');const f=functions[at];if(!f)throw Error('invalid-target:'+at);if(args.length!==f.arity)throw Error('arity:'+at);
    function block(code,slots){for(const ins of array(code)){if(--fuel<0)throw Error('interpreter-fuel');switch(ins.$){
      case 'JWAssign':slots[ins.slot]=value(ins.value,slots);break;
      case 'JWDirectCall':slots[ins.slot]=invoke(ins.target,array(ins.args).map(x=>value(x,slots)));break;
      case 'JWReturn':return{done:true,value:value(ins.value,slots)};
      case 'JWImpossible':throw Error('impossible');
      case 'JWCase':{const x=value(ins.input,slots),yes=ins.layout==='tuple'||(ins.layout==='bool'?(ins.name==='True'?x:!x):x.$===ins.name);
        const r=block(yes?ins.yes:ins.no,slots);if(r.done)return r;break;}
      default:throw Error('unknown-instruction:'+ins.$);
    }}return{done:false};}
    const r=block(f.code,[...args]);if(!r.done)throw Error('missing-return');return r.value;
  }
  try{return{value:invoke(0,args),events};}catch(e){return{error:{name:e.name,message:e.message},events};}
}
const cases=[],add=(name,functions,args=[[]],options={})=>cases.push({name,functions,args,...options});
const pairHelper=fun('renamed_producer',1,[assign(1,prim('U32.add',slot(0),lit(1))),ret(ctor('tuple','Tuple',slot(0),slot(1)))]);
add('inline-then-project',[fun('entry',1,[call(1,1,slot(0)),assign(2,project('tuple',slot(1),0)),assign(3,project('tuple',slot(1),1)),ret(prim('U32.add',slot(2),slot(3)))]),pairHelper],[[0],[7],[4294967295]],{improves:true});
add('actuals-once-even-unused',[fun('entry',0,[call(0,1,global('first'),global('second')),ret(slot(0))]),fun('first',2,[ret(slot(0))])],[[]],{modes:['normal','first','second']});
add('dead-shell-keeps-field-effects',[fun('entry',0,[assign(0,global('left')),assign(1,global('right')),assign(2,ctor('tuple','Tuple',slot(0),slot(1))),assign(3,project('tuple',slot(2),0)),ret(slot(3))])],[[]],{modes:['normal','left','right']});
add('field-used-twice',[fun('entry',0,[assign(0,global('once')),assign(1,ctor('tuple','Tuple',slot(0),nat(1))),assign(2,project('tuple',slot(1),0)),ret(prim('U32.add',slot(2),slot(2)))])]);
add('tagged-constructor-mismatch',[fun('entry',0,[assign(0,lit(7)),assign(1,ctor('tagged','Slate',slot(0))),branch(slot(1),[ret(lit(99))],[assign(2,project('tagged',slot(1),0)),ret(slot(2))],'tagged','Lantern')])]);
add('branch-local-slots',[fun('entry',1,[branch(slot(0),[assign(1,lit(11)),assign(2,ctor('tuple','Tuple',slot(1))),assign(3,project('tuple',slot(2),0)),ret(slot(3))],[assign(1,lit(29)),assign(2,ctor('tuple','Tuple',slot(1))),assign(3,project('tuple',slot(2),0)),ret(slot(3))])])],[[true],[false],[true]]);
add('copy-before-source-slot-reassigned',[fun('entry',0,[assign(0,lit(5)),assign(1,slot(0)),assign(0,lit(9)),ret(slot(1))])]);
add('captured-field-before-source-slot-reassigned',[fun('entry',0,[assign(0,lit(5)),assign(1,ctor('tuple','Tuple',slot(0),nat(1))),assign(0,lit(9)),assign(2,project('tuple',slot(1),0)),ret(slot(2))])]);
add('constructor-fact-killed',[fun('entry',0,[assign(0,lit(5)),assign(1,ctor('tuple','Tuple',slot(0))),assign(1,ctor('tuple','Tuple',nat(13))),assign(2,project('tuple',slot(1),0)),ret(slot(2))])]);
add('public-return-materializes',[fun('entry',1,[assign(1,prim('U32.add',slot(0),lit(1))),assign(2,ctor('tagged','Lantern',slot(0),slot(1))),ret(slot(2))])],[[0],[7]]);
add('native-escape-materializes',[fun('entry',1,[assign(1,ctor('tuple','Tuple',slot(0),nat(1))),assign(2,{$:'JWNative',name:'sink',args:list([slot(1)])}),ret(slot(2))])],[[7]]);
add('recursive-caller',[fun('entry',1,[branch(prim('U32.is_eq',slot(0),lit(0)),[ret(lit(0))],[call(1,1,slot(0)),assign(2,project('tuple',slot(1),0)),assign(3,prim('U32.sub',slot(0),lit(1))),call(4,0,slot(3)),ret(prim('U32.add',slot(2),slot(4)))])]),pairHelper],[[0],[1],[7],[33]]);
add('invalid-target-refusal',[fun('entry',0,[call(0,99),ret(slot(0))])]);
add('arity-mismatch-refusal',[fun('entry',0,[call(0,1,lit(1)),ret(slot(0))]),fun('binary',2,[ret(slot(0))])]);
add('invalid-function-refusal',[fun('entry',0,[call(0,1,lit(1)),ret(slot(0))]),fun('invalid',1,[ret(slot(0))],false)]);
add('invalid-caller-unchanged',[fun('entry',1,[call(1,1,slot(0)),ret(slot(1))],false),fun('simple',1,[ret(slot(0))])],[[7]],{unchangedCaller:true});
const longCode=Array.from({length:13},(_,i)=>assign(i+1,prim('U32.add',slot(i),lit(1))));
add('oversized-helper-refusal',[fun('entry',1,[call(1,1,slot(0)),ret(slot(1))]),fun('large',1,[...longCode,ret(slot(13))])],[[0]],{keepsCall:true});
const repeated=Array.from({length:40},(_,i)=>call(i+1,1,slot(i)));
add('bounded-growth',[fun('entry',1,[...repeated,ret(slot(40))]),fun('small',1,[assign(1,prim('U32.add',slot(0),lit(1))),ret(slot(1))])],[[0]],{growth:true});
try{
  pin(import.meta.filename);pin(process.execPath);const attemptFile=pin(path.join(root,'attempt.json')),attempt=JSON.parse(fs.readFileSync(attemptFile.file,'utf8'));assert.equal(attempt.checked,true);
  for(const k of ['api','runtime','base']){const x=pin(attempt[k].file);assert.equal(x.sha256,attempt[k].sha256);}
  const original=fs.readFileSync(attempt.api.file,'utf8'),parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],module={exports:{}};
  new Function('module','exports',parserSource)(module,module.exports);const parse=s=>module.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'}),ast=parse(original);
  for(const name of ['$jw_optimize_functions$','run_loop'])assert.equal(ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name===name).length,1,'Missing unique diagnostic helper '+name);
  assert(!original.includes('phase47Optimize'));const text=original+'\nexport const phase47Optimize = xs => run_loop($jw_optimize_functions$(xs));\n';parse(text);
  const file=path.join(out,'diagnostic-api.mjs');fs.writeFileSync(file,text,{flag:'wx'});fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
  report.derivative={api:identity(file),parent:identity(attempt.api.file),change:'One diagnostic export appended; original byte prefix retained.',productionAbiChanged:false,
    parser:{version:module.exports.version,sha256:hash(parserSource)}};
  const api=await import(pathToFileURL(file));
  for(const spec of cases){const input=structuredClone(spec.functions),optimized=array(api.phase47Optimize(list(input)));assert.deepEqual(input,spec.functions,'Input mutation');assert.equal(optimized.length,input.length);
    const before=counts(input),after=counts(optimized),observations=[];
    for(const args of spec.args)for(const mode of spec.modes??['normal']){const wanted=execute(input,args,mode),got=execute(optimized,args,mode);assert.deepEqual(got,wanted,spec.name);observations.push({args,mode,result:got});}
    if(spec.improves)assert(after.calls<before.calls&&after.projections<before.projections,'Required inline/projection activation');
    if(spec.keepsCall)assert(after.calls>=1,'Oversized helper must retain call');
    if(spec.unchangedCaller)assert.deepEqual(optimized[0],input[0],'Invalid caller must remain unchanged');
    if(spec.growth)assert(counts([optimized[0]]).instructions<=counts([input[0]]).instructions+32,'Per-caller net instruction growth bound');
    report.cases.push({name:spec.name,before,after,observations,input,optimized});
  }
  for(const x of report.inputs)assert.deepEqual(identity(x.file),x);assert.deepEqual(identity(file),report.derivative.api);report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,(_k,v)=>typeof v==='bigint'?{$bigint:String(v)}:v,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,cases:report.cases.length,error:report.error}));
