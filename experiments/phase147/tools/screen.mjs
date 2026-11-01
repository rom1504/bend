// Actual captured-body equivalence, separate from native cost measurements.
import path from 'node:path';
import assert from 'node:assert/strict';
import * as S from './support.mjs';
const a=S.options();for(const key of ['capture','baseline','candidate','out'])assert(a[key],'Missing --'+key);
const out=S.output(a.out),inputs=[S.pin(import.meta.filename),S.pin(path.join(import.meta.dirname,'support.mjs')),S.pin(a.capture)];
const report={kind:'phase147-real-verifier-screen',version:1,complete:false,passed:false,inputs,rows:[],scope:'Exact diagnostic comparison on complete current raw/direct functions using all original metadata and ordered direct-call context. No generated invalid IR execution; no native or hosted speed claim.'};
const save=()=>S.save(out+'/report.json',report);save();
try{
 const baseline=await S.checked(a.baseline),candidate=await S.checked(a.candidate);inputs.push(...baseline.inputs,...candidate.inputs);S.originalIdentity(baseline,candidate);
 const capture=S.read(a.capture);assert(capture.kind==='phase147-verifier-input-capture'&&capture.complete&&S.same(capture.baseline,baseline.receipt.api));
 report.baseline=baseline.receipt.api;report.candidate=candidate.receipt.api;
 for(const family of capture.rows){
  assert(family.complete);S.verify(family.data);inputs.push(family.data);const data=S.read(family.data.file);assert(data.originalAccepted);
  const segments=S.list(data.segments),constructors=S.list(data.constructors);
  for(const kind of ['raw','direct'])for(const sample of data[kind]){
   const row={kind,segments,constructors,function:sample.function,ready:S.list(kind==='direct'?data.directHeaders.slice(0,sample.index):[])};
   const result={family:family.name,kind,index:sample.index,name:sample.function.name,passed:false};report.rows.push(result);
   result.original=S.check(baseline.api,row,S.context(baseline.api,row));assert.equal(result.original,'','Actual original function context');
   result.candidate=S.check(candidate.api,row,S.context(candidate.api,row),true);assert.equal(result.candidate,result.original,'Actual candidate function');
   result.passed=true;save();
  }
 }
 inputs.forEach(S.verify);report.complete=report.passed=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,cases:report.rows.length,error:report.error}))}
