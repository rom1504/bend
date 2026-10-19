// Root-run finite selector admission and demand controls. No native claim.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [apiFile,outFile]=process.argv.slice(2);
if(!apiFile||!outFile)throw Error('Usage: controls.mjs CHECKED_API FRESH_REPORT');
const api=(await import(pathToFileURL(path.resolve(apiFile)))).default;
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const unlist=xs=>{const a=[];while(xs.$==='Con'){a.push(xs.head);xs=xs.tail;}assert.equal(xs.$,'Nil');return a;};
const term=(tag,kids=[],id=0,name='',quant=0)=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:list([]),originBegin:0,originEnd:0});
const variable=id=>term('Var',[],id),ctr=name=>term('Ctr',[],0,name);
const lam=(id,body)=>term('Lam',[body],id,'',1),app=(f,a)=>term('App',[f,a]);
const mat=(name,yes,no)=>term('Mat',[yes,no],1,name);
const unit=ctr('Unit'),yesValue=ctr('YES'),noValue=ctr('NO');
const probe=(name,result=unit)=>term('Probe',[result],0,name);
const abort=term('Abort');
const selector=mat('True',lam(1,lam(2,app(variable(1),unit))),
  mat('False',lam(3,lam(4,app(variable(4),unit))),term('Efq')));
const literalArgs=flag=>[ctr(flag),lam(10,yesValue),lam(11,noValue)];
const binding=id=>({$:'NC_Binding',id,word:'v_'+id,kind:{$:'N_W64'}});
const pin=file=>{const bytes=fs.readFileSync(file);return {file:path.resolve(file),bytes:bytes.length,sha256:createHash('sha256').update(bytes).digest('hex')};};
const report={kind:'phase112-selector-local-controls',complete:false,method:pin(import.meta.filename),api:pin(apiFile),admission:[],semantics:[],
  scope:'Finite independent raw-term evaluation and admission checks; not checked-source, native ownership, performance, or whole-compiler evidence.'};

// Independent strict lambda/matcher evaluator. Probe and Abort are test-only
// actual expressions: callee admission forbids them in the selector body.
function evaluate(t,env,trace){
  const kids=unlist(t.kids);
  if(t.tag==='Var'){assert.ok(env.has(t.id),'bound '+t.id);return env.get(t.id);}
  if(t.tag==='Ctr')return {ctor:t.name,fields:kids.map(k=>evaluate(k,env,trace))};
  if(t.tag==='Lam')return value=>evaluate(kids[0],new Map([...env,[t.id,value]]),trace);
  if(t.tag==='App'){
    const f=evaluate(kids[0],env,trace),arg=evaluate(kids[1],env,trace);
    assert.equal(typeof f,'function');return f(arg);
  }
  if(t.tag==='Mat')return value=>value.ctor===t.name?
    evaluate(kids[0],env,trace):evaluate(kids[1],env,trace)(value);
  if(t.tag==='Let'){
    const next=new Map(env);
    for(const binding of kids.slice(0,-1)){
      assert.equal(binding.tag,'Bind');next.set(binding.id,evaluate(unlist(binding.kids)[0],next,trace));
    }
    return evaluate(kids.at(-1),next,trace);
  }
  if(t.tag==='Probe'){trace.push(t.name);return evaluate(kids[0],env,trace);}
  if(t.tag==='Abort')throw Error('test abort');
  if(t.tag==='Efq')return ()=>{throw Error('test unreachable match');};
  throw Error('Unsupported test syntax '+t.tag);
}
function observation(t,env,applyResult=false){
  const trace=[];
  try{let value=evaluate(t,env,trace);if(applyResult)value=value({ctor:'Unit',fields:[]});return {value,trace};}
  catch(error){return {error:error.message,trace};}
}
function selected(body,args,env=[],n=100){
  return api.p112b_guard(list(args),n,args.length)?api.nbc_select(body,list(args),list(env),n,args.length):term('Absent');
}
function admission(name,body,args,want,env=[],n=100){
  const value=selected(body,args,env,n),actual=value.tag!=='Absent';
  assert.equal(actual,want,name);report.admission.push({name,selected:actual});return value;
}
function semantics(name,body,args,{env=new Map(),applyResult=false,expected}={}){
  const expanded=admission(name,body,args,true,[...env.keys()].map(binding));
  const before=observation(args.reduce(app,body),env,applyResult),after=observation(expanded,env,applyResult);
  assert.deepEqual(after,before,name+' semantic differential');
  if(expected!==undefined)assert.deepEqual(after,expected,name+' independent expected');
  report.semantics.push({name,observation:after});
}
try{
  semantics('select-true',selector,literalArgs('True'),{expected:{value:{ctor:'YES',fields:[]},trace:[]}});
  semantics('select-false',selector,literalArgs('False'),{expected:{value:{ctor:'NO',fields:[]},trace:[]}});
  semantics('lazy-unselected-abort',selector,[ctr('True'),lam(10,yesValue),lam(11,abort)]);
  semantics('selected-effects',selector,[ctr('True'),lam(10,probe('selected',yesValue)),lam(11,probe('BAD',noValue))],
    {expected:{value:{ctor:'YES',fields:[]},trace:['selected']}});
  semantics('false-selected-effects',selector,[ctr('False'),lam(10,probe('BAD',yesValue)),lam(11,probe('selected',noValue))]);
  semantics('captured-owner',selector,[ctr('True'),lam(10,variable(100)),lam(11,variable(100))],
    {env:new Map([[100,{ctor:'captured',fields:[{ctor:'payload',fields:[]}]}]])});
  semantics('returned-closure',selector,[ctr('False'),lam(10,lam(20,yesValue)),lam(11,lam(21,noValue))],{applyResult:true});
  const strict=lam(9,selector);
  semantics('strict-unused-argument',strict,[probe('strict-unused'),...literalArgs('True')],
    {expected:{value:{ctor:'YES',fields:[]},trace:['strict-unused']}});
  semantics('strict-unused-abort',strict,[abort,...literalArgs('True')],{expected:{error:'test abort',trace:[]}});
  semantics('ordered-nonliteral-actuals',selector,[probe('flag',ctr('True')),probe('yes-factory',lam(10,yesValue)),lam(11,noValue)],
    {expected:{value:{ctor:'YES',fields:[]},trace:['flag','yes-factory']}});
  semantics('nonliteral-branch',selector,[ctr('True'),variable(101),lam(11,noValue)],
    {env:new Map([[101,()=>({ctor:'external-closure',fields:[]})]])});
  admission('no-literal-lambda',selector,[ctr('True'),variable(100),variable(101)],false);
  admission('zero-arguments',selector,[],false);
  admission('five-arguments',selector,[...literalArgs('True'),unit,unit],false);
  admission('counter-overflow',selector,literalArgs('True'),false,[],4294967231);
  // The arithmetic budget is valid, but this fixture's low binder IDs collide
  // with the reserved descending fresh-ID range. Preserve the independent
  // freshness refusal rather than treating the budget check as full admission.
  assert.equal(api.p112b_guard(list(literalArgs('True')),4294967230,3),true);
  admission('counter-last-safe-with-fixture-id-collision',selector,literalArgs('True'),false,[],4294967230);
  admission('environment-fresh-id-collision',selector,literalArgs('True'),false,[binding(4294967295-100)]);
  admission('argument-fresh-id-collision',selector,[ctr('True'),lam(10,variable(4294967295-100)),lam(11,noValue)],false);
  admission('unknown-reference-in-callee',mat('True',term('Ref',[],0,'foreign'),term('Efq')),literalArgs('True'),false);
  admission('free-variable-in-callee',mat('True',variable(99),term('Efq')),literalArgs('True'),false);
  admission('nonnullary-match',term('Mat',unlist(selector.kids),3,'True'),literalArgs('True'),false);
  admission('duplicated-literal-branch',mat('True',lam(1,lam(2,app(app(variable(1),unit),app(variable(1),unit)))),
    mat('False',lam(3,lam(4,app(variable(4),unit))),term('Efq'))),literalArgs('True'),false);
  admission('large-callee',Array.from({length:33}).reduce((t,_,i)=>lam(200+i,t),selector),literalArgs('True'),false);
  report.complete=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;console.error(report.error);}
fs.writeFileSync(outFile,JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,admission:report.admission.length,semantics:report.semantics.length}));
