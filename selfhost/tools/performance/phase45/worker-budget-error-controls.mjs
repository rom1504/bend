// Genuine admitted Nat overflow and Error-hook reentry; no diagnostic fault injection.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseline,candidate,output]=process.argv.slice(2);
assert(output,'worker-budget-error-controls.mjs BASELINE_MODULE CANDIDATE_MODULE NEW_OUT');
const out=path.resolve(output);fs.mkdirSync(out);
const report={kind:'phase45-native-budget-admitted-errors',complete:false,pass:false,
  scope:'Checked source Nat overflow through a positive-arity recursive native worker. Clean predecessor/candidate observations separate from counter/budget derivative; no timing or nullary-admission claim.',
  inputs:[],modules:[],normal:[],errors:[],activation:[]};
const identity=p=>{const file=fs.realpathSync(p),bytes=fs.readFileSync(file);
  return {path:file,sha256:createHash('sha256').update(bytes).digest('hex'),bytes:bytes.length};};
const pinned=new Map();
function pin(file,expected){const got=identity(file);if(expected){assert.equal(got.sha256,expected.sha256);if(expected.bytes!==undefined)assert.equal(got.bytes,expected.bytes);}
  if(pinned.has(got.path))assert.deepEqual(got,pinned.get(got.path));else{pinned.set(got.path,got);report.inputs.push(got);}return got;}
function audit(x){if(Array.isArray(x))x.forEach(audit);else if(x&&typeof x==='object'){
  const file=x.file??x.path;if(file&&x.sha256)pin(file,x);Object.values(x).forEach(audit);}}
const max=281474976710655n;
function errorObservation(m,reenter){const original=Object.getOwnPropertyDescriptor(globalThis,'Error'),OriginalError=Error,events=[];let thrown;
  try{Object.defineProperty(globalThis,'Error',{configurable:true,writable:true,value:function(...args){
    events.push(['Error',String(args[0])]);if(reenter){const nested=m.default.error_check(0n);assert.equal(nested,1n);events.push(['nested',String(nested)]);}
    return Reflect.apply(OriginalError,this,args);}});
    try{m.default.error_check(max);}catch(error){thrown={name:error.name,message:error.message};}
  }finally{Object.defineProperty(globalThis,'Error',original);}
  assert(thrown,'Admitted maximum Nat addition must overflow');assert.equal(events.filter(e=>e[0]==='Error').length,1);
  const replay=m.default.error_check(7n);assert.equal(replay,8n);return {thrown,events,replay:String(replay)};}
try{
  pin(import.meta.filename);pin(process.execPath);
  const catalogFile=path.join(import.meta.dirname,'nullary-demand-catalog.json'),catalogId=pin(catalogFile),catalog=JSON.parse(fs.readFileSync(catalogFile,'utf8'));
  const source=pin(path.join(import.meta.dirname,catalog.cases[0].source.path),catalog.cases[0].source),modules=[],texts=[];
  for(const [i,file] of [baseline,candidate].entries()){
    const module=pin(file),receipt=pin(module.path+'.json'),emission=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
    assert.equal(emission.kind,'bend-program-checked-emission');assert.equal(emission.complete,true);
    assert.equal(emission.observation.checked,true);assert.equal(emission.observation.status,'ok');
    assert.equal(emission.compiler.kind,'checked-development-attempt');assert.equal(emission.compiler.upstreamCommit,catalog.upstreamCommit);
    assert.equal(emission.input.sha256,source.sha256);assert.equal(emission.output.sha256,module.sha256);assert.equal(emission.catalog.sha256,catalogId.sha256);audit(emission);
    report.modules.push({role:i?'candidate':'baseline',module,receipt,compiler:emission.compiler});
    texts.push(fs.readFileSync(module.path,'utf8'));modules.push(await import(pathToFileURL(module.path)));
  }
  for(const seed of [0n,7n,max-1n]){const expected=seed+1n,values=modules.map(m=>m.default.error_check(seed));
    for(const value of values)assert.equal(value,expected);report.normal.push({seed:String(seed),expected:String(expected),values:values.map(String)});}
  for(const reenter of [false,true]){const values=modules.map(m=>errorObservation(m,reenter));assert.deepEqual(values[1],values[0]);report.errors.push({reenter,values});}
  assert(!texts[1].includes('$p45BudgetError'),'Reserved diagnostic name collision');
  const patches=[['let $workerBudget=32;','let $workerBudget=32;$p45BudgetError.readers.push(()=>$workerBudget);'],
    ['/* private contextual instances */','/* private contextual instances */++$p45BudgetError.contextual;'],
    ['--$workerBudget;try{','--$workerBudget;try{++$p45BudgetError.native;'],
    ['}finally{++$workerBudget;}','}finally{++$workerBudget;++$p45BudgetError.restored;}']];
  let derived=texts[1];const edits=[];
  for(const [old,replacement] of patches){const count=derived.split(old).length-1;assert(count>0,'Required native-budget shape '+old);
    edits.push({old,replacement,count});derived=derived.replaceAll(old,replacement);}
  assert.equal(edits[2].count,edits[3].count);
  derived='const $p45BudgetError={contextual:0,native:0,restored:0,readers:[]};\n'+derived+
    '\nexport const p45BudgetError=()=>({contextual:$p45BudgetError.contextual,native:$p45BudgetError.native,restored:$p45BudgetError.restored,budgets:$p45BudgetError.readers.map(read=>read())});\n';
  const file=path.join(out,'candidate-counter.mjs');fs.writeFileSync(file,derived,{flag:'wx'});
  report.derivative={module:identity(file),source:report.modules[1].module,edits,performanceEvidence:false};
  const witness=await import(pathToFileURL(file));
  function state(){const s=witness.p45BudgetError();assert.equal(s.budgets.length,edits[0].count);assert(s.budgets.every(x=>x===32),'Native budgets must be32 outside calls');return s;}
  for(const reenter of [false,true]){
    const before=state(),original=Object.getOwnPropertyDescriptor(globalThis,'Error'),OriginalError=Error;let during,nested,error;
    try{Object.defineProperty(globalThis,'Error',{configurable:true,writable:true,value:function(...args){
      during=witness.p45BudgetError();assert(during.budgets.some(x=>x<32),'Overflow must occur inside an admitted native try');
      if(reenter){nested=witness.default.error_check(0n);assert.equal(nested,1n);}
      return Reflect.apply(OriginalError,this,args);}});
      try{witness.default.error_check(max);}catch(e){error={name:e.name,message:e.message};}
    }finally{Object.defineProperty(globalThis,'Error',original);}
    assert.deepEqual(error,report.errors.find(row=>row.reenter===reenter).values[1].thrown);
    const after=state(),native=after.native-before.native,restored=after.restored-before.restored;
    assert(native>0);assert.equal(native,restored,'All throwing and nested native frames must restore');
    assert.equal(after.contextual-before.contextual,reenter?2:1,'Real error and nested calls must use admitted roots');
    const replay=witness.default.error_check(7n);assert.equal(replay,8n);state();
    report.activation.push({reenter,before,during,after,nested:nested===undefined?null:String(nested),error,replay:String(replay),native,restored});
  }
  for(const item of pinned.values())assert.deepEqual(identity(item.path),item,'Changed input');assert.deepEqual(identity(file),report.derivative.module);
  report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,normal:report.normal.length,errors:report.errors.length,activation:report.activation.length,error:report.error}));
