// Bounded P5-005 rejection-path and local-scope controls; no timing claims.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash}from'node:crypto';import{spawnSync}from'node:child_process';
const hash=f=>createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const id=f=>({file:path.resolve(f),sha256:hash(f)}),save=(f,x)=>fs.writeFileSync(f,JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const [priorArg,outArg]=process.argv.slice(2);assert.ok(priorArg&&outArg,'usage: PRIOR_18_CASE_GATE FRESH_OUTPUT');
const prior=path.resolve(priorArg),out=path.resolve(outArg);fs.mkdirSync(out);
const old=JSON.parse(fs.readFileSync(path.join(prior,'report.json')));assert.ok(old.complete&&old.pass);
const inputs=[...old.inputs,id(import.meta.filename),id(path.join(prior,'report.json'))];
const n=128,params=Array.from({length:n},(_,i)=>'x'+i+': Bool').join(', '),args=Array.from({length:n},(_,i)=>i===n-1?'0':'True{}').join(', ');
const fixtures=[
 ['local-head','import Base\ndef apply(f: U32 -> U32) -> U32:\n  f(True{})\ndef main() -> U32:\n  0\n',true],
 ['local-argument','import Base\ndef f(x: Bool) -> Bool:\n  x\ndef bad(x: U32) -> Bool:\n  f(x)\ndef main() -> U32:\n  0\n',true],
 ['wrapped-head','import Base\ndef f(x: Bool) -> Bool:\n  x\ndef main() -> Bool:\n  (f)(0)\n',true],
 ['long-spine','import Base\ndef many('+params+') -> Bool:\n  x0\ndef main() -> Bool:\n  many('+args+')\n',false]
];
const cases=fixtures.map(([name,text,refuse])=>{const file=path.join(out,name+'.bend');fs.writeFileSync(file,text,{flag:'wx'});inputs.push(id(file));return{id:name,file,refuse};});
const report={kind:'phase5-application-origin-supplement',started:new Date().toISOString(),complete:false,scope:'Local scopes and bounded128-argument rejection; correctness and timeout only, no timing claim.',inputs,executions:[]};
try {
 const observed={};
 for(const variant of ['baseline','candidate','typescript']){
  const source=path.join(prior,variant,'request.json');inputs.push(id(source));const request=JSON.parse(fs.readFileSync(source));request.cases=cases;request.inputs=inputs;request.output=path.join(out,variant+'-observations.json');
  const file=path.join(out,variant+'-request.json');save(file,request);
  const a=fs.openSync(path.join(out,variant+'.stdout'),'wx'),b=fs.openSync(path.join(out,variant+'.stderr'),'wx');let result;
  const prep=JSON.parse(fs.readFileSync(inputs.find(x=>x.file.endsWith('/preparation.json')).file));
  const bootstrap=inputs.filter(x=>x.file.endsWith('api.mjs.bootstrap.json')).map(x=>JSON.parse(fs.readFileSync(x.file)));
  const candidateApi=bootstrap.find(x=>x.apiPath.includes('/application-origins/project/')).apiPath;
  try{result=spawnSync(process.execPath,['--stack-size=4096','--max-old-space-size=4096',path.resolve('tools/performance/phase5/application-origins-probe.mjs'),'--worker',file],{env:{...process.env,BEND_UPSTREAM:request.upstream,BEND_BASE:path.join(request.upstream,'bend2/base.bend'),BEND_TYPED_API:variant==='baseline'?prep.baselineApi:candidateApi,BEND_TYPED_RUNTIME:path.resolve(path.dirname(request.driver),'../src/runtime.mjs')},stdio:['ignore',a,b],timeout:90000});}finally{fs.closeSync(a);fs.closeSync(b);}
  report.executions.push({variant,status:result.status,signal:result.signal,error:result.error?.message});assert.equal(result.error,undefined);assert.equal(result.signal,null);assert.equal(result.status,0);
  observed[variant]=JSON.parse(fs.readFileSync(request.output));assert.ok(observed[variant].complete);
 }
 report.rows=cases.map((item,i)=>{
  const a=observed.baseline.rows[i],b=observed.candidate.rows[i],r=observed.typescript.rows[i];
  const unchanged=JSON.stringify(a.result)===JSON.stringify(b.result),exact=JSON.stringify(b.result)===JSON.stringify(r.result);
  assert.equal(a.id,item.id);assert.equal(b.id,item.id);assert.equal(r.id,item.id);
  assert.equal(a.result.status,'error',item.id+' must exercise rejection');assert.equal(a.result.phase,'check');
  assert.ok(unchanged||exact,item.id+' changed without exact reference');if(item.refuse)assert.equal(b.applicationOrigins.length,0,item.id+' must refuse added origin');
  return{id:item.id,unchanged,exact,refusalExpected:item.refuse,applicationOrigins:b.applicationOrigins};
 });
 for(const x of inputs)assert.equal(hash(x.file),x.sha256,'changed input '+x.file);
 report.complete=true;report.pass=true;
}catch(error){report.error=String(error.stack);process.exitCode=1;}
report.finished=new Date().toISOString();save(path.join(out,'report.json'),report);console.log(JSON.stringify({complete:report.complete,pass:report.pass,error:report.error}));
