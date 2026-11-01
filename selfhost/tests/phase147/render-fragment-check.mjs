// Root-supervised complete String controls; no compiler implementation in the host.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import * as S from '../../../experiments/phase147/tools/support.mjs';
const a=S.options();for(const key of ['api','preparation','fixtures','out'])assert(a[key],'Missing --'+key);
const out=S.output(a.out),inputs=[S.pin(import.meta.filename),S.pin(path.join(S.root,'experiments/phase147/tools/support.mjs')),S.pin(a.api),S.pin(a.preparation),S.pin(a.fixtures)];
const report={kind:'phase147-fragment-render-controls',version:1,complete:false,passed:false,inputs,controls:[],rows:[],scope:'Ten call plus eighteen fragment text/state/error controls; exact complete Strings in original/call-only/general modes for three current complete bodies. Not whole-pipeline/native qualification or speed.'};
const save=()=>S.save(out+'/report.json',report);save();
try{
 const preparation=S.read(a.preparation),receipt=S.read(a.api),fixtures=S.read(a.fixtures);
 assert.equal(preparation.kind,'phase147-fragment-render-kernel-preparation');assert(preparation.complete);
 assert.equal(receipt.kind,'bend-checked-hosted-api');assert(receipt.complete&&receipt.checked);
 assert(S.same(preparation.source,receipt.source));assert.deepEqual(receipt.exports,S.read(preparation.exports.file).exports);
 assert.equal(fixtures.kind,'phase147-current-render-fixtures');assert(fixtures.complete&&fixtures.fixtures.length===3);
 inputs.push(preparation.source,preparation.exports,receipt.api,...preparation.inputs,...receipt.inputs,fixtures.capture,fixtures.bend);
 for(const row of fixtures.fixtures)inputs.push(row.capture);
 inputs.forEach(S.verify);
 const api=(await import(pathToFileURL(receipt.api.file))).default;report.api=receipt.api;report.source=receipt.source;
 const names=['empty-args','mixed-args-widths','function-constructor-symbol','missing-id-marker','prior-chunks-order','metadata-max-terminal-error','unicode-text-preserved','complete-call-return','fallthrough-marker','statement-after-terminal'];
 report.controls=S.items(api.p147q_controls());assert.deepEqual(report.controls,names.map(x=>x+':pass'),'Independent call controls');
 const fragmentNames=['loaduw-zero-offset','load64-offset','load-pointer-symbol','store32-zero-offset','store-temp-wrap','load-temp-wrap','store-pointer-id','store-missing-id','set-u64-max','set-constructor','bin-comparison-width','bin-invalid-marker','offset-high-word','prior-fragments-order','direct-error-terminal-state','body-earlier-error','body-after-terminal','body-fallthrough'];
 const fragmentRows=S.items(api.p147f_controls());assert.deepEqual(fragmentRows,fragmentNames.map(x=>x+':pass'),'Independent fragment controls');report.controls.push(...fragmentRows);
 for(const fixture of fixtures.fixtures){
  const segment=api['p147q_fixture_segment'+fixture.index](),ids=api['p147q_fixture_ids'+fixture.index]();
  const captured=S.read(fixture.capture.file);assert(captured.complete&&captured.originalAccepted);
  assert.deepEqual(fixture.completeSegment,captured.raw.find(x=>x.index===fixture.captureIndex).function,'Actual complete current capture');
  for(const field of ['functions','constructors'])for(const entry of fixture.referencedIds[field]){const headers=field==='functions'?captured.segments:captured.constructors;assert.equal(headers[entry.id].name,entry.name,'Actual symbol position');}
  assert.deepEqual(segment,fixture.completeSegment,'Exact retained segment value');
  for(const field of ['functions','constructors'])assert.deepEqual(S.semanticRows(ids[field]),fixture.referencedIds[field].map(x=>[x.name,'N111Id',x.id,0]));
  const before=JSON.stringify([segment,ids]);
  const baseline=api.p147f_render_segment(segment,ids,0),calls=api.p147f_render_segment(segment,ids,1),candidate=api.p147f_render_segment(segment,ids,2);
  assert.equal(calls,baseline,'Call-only ablation complete String');
  assert.equal(typeof baseline,'string');assert(baseline.length>0);assert.equal(candidate,baseline,'Complete segment String');
  assert(!baseline.includes('INVALID_'),'Retained segment must render without refusal');assert.equal(JSON.stringify([segment,ids]),before,'Immutable inputs');
  const files={};for(const [role,text] of Object.entries({baseline,calls,candidate})){const file=path.join(out,fixture.index+'-'+role+'.ssa');fs.writeFileSync(file,text,{flag:'wx'});files[role]=S.pin(file)}
  report.rows.push({index:fixture.index,name:fixture.definition,capture:fixture.capture,calls:fixture.calls,family:fixture.family,census:fixture.census,statementTags:fixture.statementTags,callOnly:files.calls,baseline:files.baseline,candidate:files.candidate,completeTextExact:true,inputUnchanged:true});save();
 }
 inputs.forEach(S.verify);report.complete=report.passed=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,controls:report.controls.length,segments:report.rows.length,error:report.error}))}
