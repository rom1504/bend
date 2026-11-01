// Old/new actual selected renderer; only values and complete texts cross the host.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import * as S from '../../../experiments/phase147/tools/support.mjs';
const a=S.options();for(const key of ['preparation','out'])assert(a[key]);
const out=S.output(a.out),plan=S.read(a.preparation),inputs=[S.pin(import.meta.filename),S.pin(path.join(S.root,'experiments/phase147/tools/support.mjs')),S.pin(a.preparation),...plan.inputs];
const report={kind:'phase147-selected-renderer-complete-function-controls',version:1,complete:false,passed:false,inputs,rows:[],scope:'Exact old/new selected renderer on eighteen whole current captured raw functions with full actual function/constructor IDs, including nested branches. No full-compiler equality or speed claim.'};
const save=()=>S.save(out+'/report.json',report);save();
try{
 assert.equal(plan.kind,'phase147-selected-renderer-pair-preparation');assert(plan.complete);assert.deepEqual(plan.rows.map(x=>x.role),['baseline','candidate']);
 const apis={};
 for(const row of plan.rows){
  S.verify(row.preparation);const p=S.read(row.preparation.file),r=S.read(row.apiReport);
  assert.equal(p.kind,'phase147-selected-renderer-preparation');assert(p.complete&&p.role===row.role);
  assert.equal(r.kind,'bend-checked-hosted-api');assert(r.complete&&r.checked);assert(S.same(p.source,r.source));assert.deepEqual(r.exports,S.read(p.exports.file).exports);
  inputs.push(row.preparation,S.pin(row.apiReport),p.source,p.exports,p.canonicalSource,r.api,...p.inputs,...r.inputs);
  inputs.forEach(S.verify);apis[row.role]=(await import(pathToFileURL(r.api.file))).default;
 }
 S.verify(plan.capture);const capture=S.read(plan.capture.file);assert(capture.complete&&capture.rows.length===3);inputs.push(plan.capture);
 const originalPrep=S.read(plan.rows[0].preparation.file);assert(S.same(originalPrep.canonicalSource,capture.sourceIdentity),'Capture source differs from original canonical source');
 for(const family of capture.rows){
  S.verify(family.data);inputs.push(family.data,family.source);const data=S.read(family.data.file);assert(data.complete&&data.originalAccepted&&data.raw.length===6);
  const before=JSON.stringify(data),segments=S.list(data.segments),constructors=S.list(data.constructors),ids={};
  for(const role of ['baseline','candidate']){const api=apis[role];ids[role]={$: 'N111Ids',functions:api.p111q_function_ids(segments,0,api.missing()),constructors:api.p111q_constructor_ids(constructors,0,api.missing())};}
  assert.deepEqual(S.semanticRows(ids.baseline.functions),S.semanticRows(ids.candidate.functions));
  assert.deepEqual(S.semanticRows(ids.baseline.constructors),S.semanticRows(ids.candidate.constructors));
  const idsBefore=JSON.stringify(ids);
  for(const row of data.raw){
   const texts={};for(const role of ['baseline','candidate'])texts[role]=apis[role].p111q_segment(row.function,ids[role]);
   assert.equal(typeof texts.baseline,'string');assert(texts.baseline.length>0&&!texts.baseline.includes('INVALID_'),'Original selected renderer refused valid captured body');
   assert.equal(texts.candidate,texts.baseline,'Complete selected text differs: '+family.name+'/'+row.function.name);
   const products={};for(const role of ['baseline','candidate']){const f=path.join(out,family.name+'-'+row.index+'-'+role+'.ssa');fs.writeFileSync(f,texts[role],{flag:'wx'});products[role]=S.pin(f);}
   report.rows.push({family:family.name,index:row.index,name:row.function.name,census:row.census,...products,completeTextExact:true});save();
  }
  assert.equal(JSON.stringify(data),before);assert.equal(JSON.stringify(ids),idsBefore);
 }
 assert.equal(report.rows.length,18);inputs.forEach(S.verify);report.complete=report.passed=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,functions:report.rows.length,error:report.error}));}
