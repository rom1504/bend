// Independent logical semantics for the checked private tuple-transport pass.
// Root executes this file. The diagnostic export is a separately retained copy.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [attemptArg,outArg]=process.argv.slice(2);
assert(attemptArg&&outArg,'jw-values-controls-v1.mjs CHECKED_ATTEMPT NEW_OUT');
const root=fs.realpathSync(attemptArg),out=path.resolve(outArg);fs.mkdirSync(out);
const report={kind:'phase48-private-values-ir-controls',complete:false,pass:false,inputs:[],cases:[],
  scope:'Actual checked Bend pass, independent bounded JW interpretation and explicit value/event/identity oracles. Logical source-tuple counts, not V8 allocation measurements. Does not qualify machine emission, public ABI, deep native stack or universal soundness.'};
const hash=b=>createHash('sha256').update(b).digest('hex');
function identity(file){file=fs.realpathSync(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:hash(b)};}
function pin(file,expected){const row=identity(file);if(expected)assert.equal(row.sha256,expected.sha256);report.inputs.push(row);return row;}
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
function array(xs){const a=[];while(xs?.$==='Con'){assert(a.length<20000);a.push(xs.head);xs=xs.tail;}assert.equal(xs?.$,'Nil');return a;}
const s=slot=>({$:'JWSlot',slot}),n=x=>({$:'JWLiteral',code:String(x)}),g=name=>({$:'JWGlobal',name,layout:'u32'});
const op=(name,...args)=>({$:'JWPrimitive',name,args:list(args)}),native=(name,...args)=>({$:'JWNative',name,args:list(args)});
const tuple=(...fields)=>({$:'JWConstruct',layout:'tuple',name:'Tuple',fields:list(fields)});
const tagged=(name,...fields)=>({$:'JWConstruct',layout:'tagged',name,fields:list(fields)});
const field=(value,index)=>({$:'JWProject',layout:'tuple',input:value,index});
const a=(slot,value)=>({$:'JWAssign',slot,value}),ret=value=>({$:'JWReturn',value});
const call=(slot,target,...args)=>({$:'JWDirectCall',slot,target,args:list(args)});
const branch=(input,yes,no)=>({$:'JWCase',layout:'bool',name:'True',input,yes:list(yes),no:list(no)});
const fn=(name,arity,code,valid=true)=>({$:'JWFunction',name,arity,code:list(code),valid});
const add=(x,y)=>op('U32.add',x,y),sub=(x,y)=>op('U32.sub',x,y),mul=(x,y)=>op('U32.mul',x,y);
const pairSum=x=>add(field(x,0),field(x,1));
const word=x=>Number(BigInt.asUintN(32,BigInt(x)));
function view(x,seen=new Map()){
  if(x===null||typeof x!=='object')return x;
  if(seen.has(x))return{ref:seen.get(x)};
  const id=seen.size;seen.set(x,id);
  return Array.isArray(x)?{id,tuple:x.map(v=>view(v,seen))}:{id,tag:x.$,fields:x.fields.map(v=>view(v,seen))};
}
const ok=(value,events=[])=>({value:view(value),events});
const failure=(message,events=[])=>({error:{name:'Error',message},events});
function counts(fs){const result={calls:0,multiCalls:0,multiReturns:0,constructors:0};
  function walk(v){if(!v||typeof v!=='object')return;
    if(v.$==='JWDirectCall')result.calls++;if(v.$==='JWCallValues')result.multiCalls++;
    if(v.$==='JWReturnValues')result.multiReturns++;if(v.$==='JWConstruct')result.constructors++;
    Object.values(v).forEach(walk);}
  fs.forEach(walk);return result;
}
function execute(functions,args,entry=0,mode='normal'){
  const events=[],stats={tupleAllocations:0,taggedAllocations:0,calls:0,multiCalls:0,multiReturns:0};let ticks=0,fuel=200000;
  function value(v,slots){
    switch(v.$){
      case 'JWSlot':if(!Object.hasOwn(slots,v.slot))throw Error('undefined-slot:'+v.slot);return slots[v.slot];
      case 'JWLiteral':if(v.code==='true')return true;if(v.code==='false')return false;if(v.code==='null')return null;assert(/^\d+$/.test(v.code));return Number(v.code);
      case 'JWNat':return BigInt(v.number);
      case 'JWGlobal':events.push(v.name);if(v.name==='boom'||mode===v.name)throw Error('global:'+v.name);return ++ticks;
      case 'JWConstruct':{const fields=array(v.fields).map(x=>value(x,slots));if(v.layout==='tuple'){stats.tupleAllocations++;return fields;}stats.taggedAllocations++;return{$:v.name,fields};}
      case 'JWProject':{const x=value(v.input,slots);if(v.layout==='tuple'){if(!Array.isArray(x))throw Error('tuple-projection');return x[v.index];}if(!x||!Array.isArray(x.fields))throw Error('tagged-projection');return x.fields[v.index];}
      case 'JWPrimitive':{const x=array(v.args).map(v=>value(v,slots));switch(v.name){
        case 'U32.add':return(x[0]+x[1])>>>0;case 'U32.sub':return(x[0]-x[1])>>>0;
        case 'U32.mul':return Math.imul(x[0],x[1])>>>0;case 'U32.xor':return(x[0]^x[1])>>>0;
        case 'U32.is_eq':return x[0]===x[1];default:throw Error('primitive:'+v.name);}}
      case 'JWNative':{const x=array(v.args).map(v=>value(v,slots));
        if(v.name==='same')return x[0]===x[1];
        if(v.name==='observe'){events.push(['observe',...x.map(v=>view(v))]);return 0;}
        throw Error('native:'+v.name);}
      default:throw Error('value:'+v.$);
    }
  }
  function invoke(target,actuals){
    if(--fuel<0)throw Error('interpreter-fuel');const f=functions[target];
    if(!f)throw Error('invalid-target:'+target);if(!f.valid)throw Error('invalid-function:'+target);
    if(actuals.length!==f.arity)throw Error('arity:'+target);
    const slots=[...actuals];
    function block(code){for(const i of array(code)){if(--fuel<0)throw Error('interpreter-fuel');switch(i.$){
      case 'JWAssign':slots[i.slot]=value(i.value,slots);break;
      case 'JWDirectCall':{const args=array(i.args).map(v=>value(v,slots));stats.calls++;const result=invoke(i.target,args);if(result.kind!=='single')throw Error('wrong-return-protocol');slots[i.slot]=result.value;break;}
      case 'JWCallValues':{const args=array(i.args).map(v=>value(v,slots));stats.multiCalls++;const result=invoke(i.target,args),destinations=array(i.slots);
        if(result.kind!=='values'||result.values.length!==destinations.length)throw Error('wrong-return-vector');
        // All returned values exist before any caller destination is written.
        result.values.forEach((v,index)=>{slots[destinations[index]]=v;});break;}
      case 'JWReturn':return{kind:'single',value:value(i.value,slots)};
      case 'JWReturnValues':stats.multiReturns++;return{kind:'values',values:array(i.values).map(v=>value(v,slots))};
      case 'JWImpossible':throw Error('impossible');
      case 'JWCase':{const x=value(i.input,slots),yes=i.layout==='bool'?(i.name==='True'?Boolean(x):!x):i.layout==='tuple'||x.$===i.name;
        const result=block(yes?i.yes:i.no);if(result)return result;break;}
      default:throw Error('instruction:'+i.$);
    }}return null;}
    const result=block(f.code);if(!result)throw Error('missing-return');return result;
  }
  try{const result=invoke(entry,structuredClone(args));if(result.kind!=='single')throw Error('public-return-protocol');return{semantic:ok(result.value,events),stats};}
  catch(error){return{semantic:{error:{name:error.name,message:error.message},events},stats};}
}
const cases=[];
function test(name,functions,args,oracle,checks={}){cases.push({name,functions,args,oracle,...checks});}
const scalarInputs=[[0],[1],[7],[4294967295]];
const producer=fn('unrelated_pair',1,[a(1,tuple(s(0),add(s(0),n(1)))),ret(s(1))]);
test('private-result-pair',[fn('root',1,[call(1,1,s(0)),ret(pairSum(s(1)))]),producer],scalarInputs,x=>ok(word(2n*BigInt(x[0])+1n)),{cutsResult:true,reducesTuples:true});
test('private-parameter-pair',[fn('root',1,[a(1,tuple(s(0),add(s(0),n(7)))),call(2,1,s(1)),ret(s(2))]),fn('consumer',1,[ret(pairSum(s(0)))])],scalarInputs,x=>ok(word(2n*BigInt(x[0])+7n)),{parameterArity:2,reducesTuples:true});
test('two-parameters-parallel-renumbering',[fn('root',2,[a(2,tuple(s(0),s(1))),a(3,tuple(s(1),s(0))),call(4,1,s(2),s(3)),ret(s(4))]),fn('cross',2,[ret(add(mul(field(s(0),1),n(10)),field(s(1),1)))])],[[0,9],[7,31],[4294967295,3]],x=>ok(word(BigInt(x[1])*10n+BigInt(x[0]))),{parameterArity:4,reducesTuples:true});
test('nested-results-four-scalars',[fn('root',1,[call(1,1,s(0)),ret(add(pairSum(field(s(1),0)),pairSum(field(s(1),1))))]),fn('nested',1,[a(1,tuple(s(0),add(s(0),n(1)))),a(2,tuple(add(s(0),n(2)),add(s(0),n(3)))),a(3,tuple(s(1),s(2))),ret(s(3))])],scalarInputs,x=>ok(word(4n*BigInt(x[0])+6n)),{cutsResult:true,reducesTuples:true});
function fieldOracle(_args,mode){return mode==='left'?failure('global:left',['left']):mode==='right'?failure('global:right',['left','right']):ok(1,['left','right']);}
test('unused-input-field-still-evaluates',[fn('root',0,[a(0,tuple(g('left'),g('right'))),call(1,1,s(0)),ret(s(1))]),fn('first',1,[ret(field(s(0),0))])],[[]],fieldOracle,{modes:['normal','left','right'],parameterArity:2});
test('unused-return-field-still-evaluates',[fn('root',0,[call(0,1),ret(field(s(0),0))]),fn('produce',0,[a(0,tuple(g('left'),g('right'))),ret(s(0))])],[[]],fieldOracle,{modes:['normal','left','right'],cutsResult:true});
test('actuals-around-pair-stay-ordered',[fn('root',0,[a(0,tuple(g('left'),g('right'))),call(1,1,g('before'),s(0),g('after')),ret(s(1))]),fn('middle',3,[ret(field(s(1),0))])],[[]],()=>ok(1,['left','right','before','after']),{parameterArity:4});
for(const shared of [true,false])test(shared?'shared-persistent-child':'distinct-equal-children',[
  fn('root',0,[call(0,1),ret(native('same',field(s(0),0),field(s(0),1)))]),
  fn('children',0,[a(0,tagged('Twig',n(9))),...(shared?[]:[a(1,tagged('Twig',n(9)))]),a(2,tuple(s(0),s(shared?0:1))),ret(s(2))])
],[[]],()=>ok(shared),{cutsResult:true,reducesTuples:true,taggedAllocations:shared?1:2});
test('branch-return-field-order',[fn('root',2,[call(2,1,s(0),s(1)),ret(add(mul(field(s(2),0),n(10)),field(s(2),1)))]),
  fn('choose',2,[branch(s(0),[a(2,tuple(s(1),add(s(1),n(1)))),ret(s(2))],[a(2,tuple(add(s(1),n(1)),s(1))),ret(s(2))])])
],[[true,0],[false,0],[true,7],[false,7],[false,4294967295]],x=>ok(word(11n*BigInt(x[1])+(x[0]?1n:10n))),{cutsResult:true,reducesTuples:true});
test('branch-join-remains-conservative',[fn('root',1,[call(1,1,s(0)),ret(pairSum(s(1)))]),fn('join',1,[branch(s(0),[a(1,tuple(n(2),n(3)))],[a(1,tuple(n(7),n(11)))]),ret(s(1))])],[[true],[false]],x=>ok(x[0]?5:18),{noResultCut:true});
test('overwritten-constructor-fact',[fn('root',1,[call(1,1,s(0)),ret(pairSum(s(1)))]),fn('overwrite',1,[a(1,tuple(n(1),n(2))),a(1,tuple(s(0),add(s(0),n(5)))),ret(s(1))])],scalarInputs,x=>ok(word(2n*BigInt(x[0])+5n)));
test('copy-snapshots-fields-before-source-write',[fn('root',0,[a(0,n(5)),a(1,tuple(s(0),n(7))),a(2,s(1)),a(0,n(99)),call(3,1,s(2)),ret(s(3))]),fn('sum',1,[ret(pairSum(s(0)))])],[[]],()=>ok(12),{parameterArity:2});
test('recursive-return-retains-caller-state',[fn('root',1,[call(1,1,s(0)),ret(add(field(s(1),0),mul(field(s(1),1),n(100))))]),
  fn('recur',1,[branch(op('U32.is_eq',s(0),n(0)),[a(1,tuple(n(0),n(1))),ret(s(1))],[call(1,1,sub(s(0),n(1))),a(2,field(s(1),0)),a(3,field(s(1),1)),a(4,tuple(add(s(2),s(0)),add(s(3),n(1)))),ret(s(4))])])
],[[0],[1],[7],[40]],x=>ok(word(BigInt(x[0])*(BigInt(x[0])+1n)/2n+(BigInt(x[0])+1n)*100n)),{cutsResult:true,reducesTuples:true});
test('entry-result-remains-public',[fn('root',1,[a(1,tuple(s(0),add(s(0),n(1)))),ret(s(1))])],scalarInputs,x=>ok([x[0],word(BigInt(x[0])+1n)]),{entryArity:1,publicTuple:true});
test('entry-parameter-remains-public',[fn('root',1,[ret(pairSum(s(0)))])],[[[4,7]],[[4294967295,1]]],x=>ok(word(BigInt(x[0][0])+BigInt(x[0][1]))),{entryArity:1});
test('nonzero-entry-index',[producer,fn('public_later',1,[call(1,0,s(0)),ret(pairSum(s(1)))])],scalarInputs,x=>ok(word(2n*BigInt(x[0])+1n)),{entry:1,cutsResult:true,reducesTuples:true});
test('inline-constructor-result-refused',[fn('root',1,[call(1,1,s(0)),ret(pairSum(s(1)))]),fn('inline',1,[ret(tuple(s(0),n(3)))])],scalarInputs,x=>ok(word(BigInt(x[0])+3n)),{noResultCut:true});
test('inline-effectful-return-refused',[fn('root',0,[call(0,1),ret(field(s(0),0))]),fn('inline_effects',0,[ret(tuple(g('left'),g('right')))])],[[]],fieldOracle,{modes:['normal','left','right'],noResultCut:true});
test('escaping-result-retains-shell',[fn('root',1,[call(1,1,s(0)),ret(s(1))]),producer],scalarInputs,x=>ok([x[0],word(BigInt(x[0])+1n)]),{noResultCut:true,publicTuple:true});
test('inline-actual-refuses-parameter-cut',[fn('root',0,[call(0,1,tuple(g('left'),g('right'))),ret(s(0))]),fn('first',1,[ret(field(s(0),0))])],[[]],fieldOracle,{modes:['normal','left','right'],parameterArity:1});
test('unknown-native-use-keeps-result',[fn('root',0,[call(0,1,n(7)),a(1,native('observe',s(0))),ret(pairSum(s(0)))]),producer],[[]],()=>ok(15,[['observe',view([7,8])]]),{noResultCut:true});
test('invalid-function-refused',[fn('root',0,[call(0,1,n(7)),ret(s(0))]),fn('invalid',1,[a(1,tuple(s(0),n(1))),ret(s(1))],false)],[[]],()=>failure('invalid-function:1'),{unchanged:true});
// Invalid targets/arity are outside compiler-produced typed JW and are not a
// new malformed-IR validation obligation of this transport pass.
const largeArgs=[s(0),...Array.from({length:11},(_,i)=>n(i))];
test('parameter-arity-ceiling',[fn('root',0,[a(0,tuple(n(7),n(9))),call(1,1,...largeArgs),ret(s(1))]),fn('twelve',12,[ret(pairSum(s(0)))])],[[]],()=>ok(16),{parameterArity:12});
const many=[fn('root',0,[a(0,n(0)),...Array.from({length:40},(_,i)=>[call(i+1,i+1),a(0,add(s(0),pairSum(s(i+1))))]).flat(),ret(s(0))]),
  ...Array.from({length:40},(_,i)=>fn('p'+i,0,[a(0,tuple(n(i),n(i+1))),ret(s(0))]))];
test('bounded-result-work',[...many],[[]],()=>ok(1600),{cutsResult:true,reducesTuples:true,resultBudget:32});
const oversized=[fn('root',0,[ret(n(17))]),...Array.from({length:96},(_,i)=>fn('unused'+i,0,[a(0,tuple(n(i),n(i))),ret(s(0))]))];
test('ninety-seven-functions-refused',oversized,[[]],()=>ok(17),{unchanged:true});

try{
  pin(import.meta.filename);pin(process.execPath);
  pin(path.resolve(import.meta.dirname,'../../phase47/controls/jw-ir-controls-v2.mjs'));
  const attemptFile=pin(path.join(root,'attempt.json')),attempt=JSON.parse(fs.readFileSync(attemptFile.file));
  assert.equal(attempt.checked,true);assert.equal(attempt.config.strictExact,true);
  for(const key of ['api','runtime','base','node'])pin(attempt[key].file,attempt[key]);
  assert.equal(identity(process.execPath).sha256,attempt.node.sha256);
  const gate=pin(path.join(root,'validation-001/report.json')),checked=JSON.parse(fs.readFileSync(gate.file));
  assert(checked.complete&&checked.pass&&checked.strictExact);assert.equal(checked.attempt.sha256,attemptFile.sha256);assert.equal(checked.api.sha256,attempt.api.sha256);
  const original=fs.readFileSync(attempt.api.file,'utf8'),parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};
  new Function('module','exports',parserSource)(parser,parser.exports);
  const parse=text=>parser.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'}),ast=parse(original);
  for(const name of ['$jw_values_functions$','run_loop'])assert.equal(ast.body.filter(x=>x.type==='FunctionDeclaration'&&x.id.name===name).length,1,'Missing diagnostic helper '+name);
  assert(!original.includes('phase48Values'));
  const text=original+'\nexport const phase48Values = (fs,entry) => run_loop($jw_values_functions$(fs,entry));\n';parse(text);
  const file=path.join(out,'diagnostic-api.mjs');fs.writeFileSync(file,text,{flag:'wx'});fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
  report.derivative={parent:identity(attempt.api.file),api:identity(file),change:'One diagnostic export; original byte prefix unchanged.',parser:{version:parser.exports.version,sha256:hash(parserSource)}};
  const api=await import(pathToFileURL(file));
  for(const spec of cases){
    const entry=spec.entry??0,input=structuredClone(spec.functions),optimized=array(api.phase48Values(list(input),entry));
    assert.deepEqual(input,spec.functions,'Input mutation');assert.equal(optimized.length,input.length);
    assert.deepEqual(optimized.map(f=>f.name),input.map(f=>f.name));assert.equal(optimized[entry].arity,input[entry].arity,'Public arity changed');
    const before=counts(input),after=counts(optimized),observations=[];
    for(const args of spec.args)for(const mode of spec.modes??['normal']){
      const expected=spec.oracle(args,mode),old=execute(input,args,entry,mode),now=execute(optimized,args,entry,mode);
      assert.deepEqual(old.semantic,expected,spec.name+' independent original oracle');
      assert.deepEqual(now.semantic,expected,spec.name+' independent transformed oracle');
      if(spec.reducesTuples)assert(now.stats.tupleAllocations<old.stats.tupleAllocations,spec.name+' no dynamic tuple reduction');
      if(spec.taggedAllocations!==undefined)assert.equal(now.stats.taggedAllocations,spec.taggedAllocations,'Persistent children reconstructed');
      if(spec.publicTuple)assert.equal(now.stats.tupleAllocations,old.stats.tupleAllocations,'Public shell disappeared');
      observations.push({args,mode,expected,before:old.stats,after:now.stats});
    }
    if(spec.cutsResult)assert(after.multiCalls>0&&after.multiReturns>0,spec.name+' no result transport activation');
    if(spec.noResultCut)assert.equal(after.multiCalls,0,spec.name+' unsupported result shape changed');
    if(spec.parameterArity!==undefined)assert.equal(optimized[1].arity,spec.parameterArity,spec.name+' formal contract');
    if(spec.entryArity!==undefined)assert.equal(optimized[entry].arity,spec.entryArity);
    if(spec.resultBudget!==undefined)assert(after.multiReturns<=spec.resultBudget,'Result cut budget');
    if(spec.unchanged)assert.deepEqual(optimized,input,spec.name+' invalid graph must be unchanged');
    report.cases.push({name:spec.name,entry,before,after,observations,input,optimized});
  }
  for(const row of report.inputs)assert.deepEqual(identity(row.file),row);
  assert.deepEqual(identity(file),report.derivative.api);
  report.observations=report.cases.reduce((n,c)=>n+c.observations.length,0);report.complete=report.pass=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,(_k,v)=>typeof v==='bigint'?{$bigint:String(v)}:v,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,cases:report.cases.length,observations:report.observations,error:report.error}));
