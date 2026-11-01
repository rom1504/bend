// Literal original-optimizer oracles; no host compiler or native execution.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import * as S from './support.mjs';
const a=S.options();for(const key of ['api','fixtures','out'])assert(a[key],'Missing --'+key);
const out=S.output(a.out),inputs=[S.pin(import.meta.filename),S.pin(path.join(import.meta.dirname,'support.mjs')),S.pin(a.fixtures)];
const report={kind:'phase148-supplementary-scalar-controls',version:1,complete:false,passed:false,inputs,rows:[],optimizerParity:0,explicitRefusals:0,
 scope:'Literal whole original optimizer results and consuming compact-unit observations. Some inputs are intentionally inadmissible. No program execution, admission parity or mathematical proof claimed. Refusals are counted separately.'};
const save=()=>S.save(out+'/report.json',report);save();
try{
 const checked=await S.checked(a.api),api=checked.api;inputs.push(...checked.inputs);report.api=checked.receipt.api;report.source=checked.receipt.source;
 const fixtures=S.read(a.fixtures);assert.equal(fixtures.kind,'phase148-independent-supplementary-scalar-controls');assert(fixtures.complete);
 report.referenceRelocations=[];
 for(const reference of fixtures.inputs){
  let current=null;try{current=S.pin(reference.file)}catch{}
  if(current&&S.same(current,reference)){inputs.push(reference);continue;}
  assert(a['source-history'],'Changed authoring reference requires explicit --source-history');
  const retained=S.pin(path.join(path.resolve(a['source-history']),path.basename(reference.file)));
  assert(S.same(retained,reference),'Retained authoring reference differs: '+reference.file);
  report.referenceRelocations.push({declared:reference,retained});inputs.push(retained);
 }
 inputs.forEach(S.verify);
 for(const row of fixtures.cases){
  const before=JSON.stringify(row.function),old=api.p113k_function(row.function);
  assert.deepEqual(old,row.expectedOptimized,row.name+' independently specified original whole AST');
  const roundtrip=api.p148_pack(row.function);assert.equal(roundtrip.$,'P148Good',row.name+' packing refused');
  assert.deepEqual(api.p148_unpack(roundtrip),row.function,row.name+' complete roundtrip');
  const unit=api.p148_pack(row.function);assert.equal(unit.$,'P148Good',row.name+' fresh packing refused');
  const next=api.p148o_function(unit); // unit is consumed; never read it again.
  if(row.classification==='explicit-refusal'){
   assert.deepEqual(next,row.expectedCandidate,row.name+' exact refusal');report.explicitRefusals++;
  }else{
   assert.equal(row.classification,'optimizer-parity');assert.equal(next.$,'P148Good',row.name+' unexpected refusal');
   assert.deepEqual(api.p148_unpack(next),row.expectedOptimized,row.name+' compact whole AST');report.optimizerParity++;
  }
  assert.equal(JSON.stringify(row.function),before,row.name+' immutable original changed');
  report.rows.push({name:row.name,classification:row.classification,oldLiteralExact:true,candidateTag:next.$,passed:true});save();
 }
 assert.equal(report.optimizerParity,fixtures.counts.optimizerParity);assert.equal(report.explicitRefusals,fixtures.counts.explicitRefusals);
 inputs.forEach(S.verify);report.complete=report.passed=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,optimizerParity:report.optimizerParity,explicitRefusals:report.explicitRefusals,error:report.error}))}
