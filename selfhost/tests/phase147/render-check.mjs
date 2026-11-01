// Root-supervised complete String controls; no compiler implementation in the host.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import * as S from '../../../experiments/phase147/tools/support.mjs';
const a=S.options();for(const key of ['api','preparation','fixtures','out'])assert(a[key],'Missing --'+key);
const out=S.output(a.out),inputs=[S.pin(import.meta.filename),S.pin(path.join(S.root,'experiments/phase147/tools/support.mjs')),S.pin(a.api),S.pin(a.preparation),S.pin(a.fixtures)];
const report={kind:'phase147-call-render-controls',version:1,complete:false,passed:false,inputs,controls:[],rows:[],scope:'Ten independent text/state/error controls plus exact complete rendered Strings for three retained scalar segments. This is a renderer experiment, not whole-pipeline/native qualification or a speed measurement.'};
const save=()=>S.save(out+'/report.json',report);save();
try{
 const preparation=S.read(a.preparation),receipt=S.read(a.api),fixtures=S.read(a.fixtures);
 assert.equal(preparation.kind,'phase147-call-render-kernel-preparation');assert(preparation.complete);
 assert.equal(receipt.kind,'bend-checked-hosted-api');assert(receipt.complete&&receipt.checked);
 assert(S.same(preparation.source,receipt.source));assert.deepEqual(receipt.exports,S.read(preparation.exports.file).exports);
 assert.equal(fixtures.kind,'phase147-call-render-fixtures');assert(fixtures.complete&&fixtures.fixtures.length===3);
 inputs.push(preparation.source,preparation.exports,receipt.api,...preparation.inputs,...receipt.inputs,fixtures.capture,fixtures.bend);
 for(const row of fixtures.fixtures)inputs.push(row.capture);
 inputs.forEach(S.verify);
 const api=(await import(pathToFileURL(receipt.api.file))).default;report.api=receipt.api;report.source=receipt.source;
 const names=['empty-args','mixed-args-widths','function-constructor-symbol','missing-id-marker','prior-chunks-order','metadata-max-terminal-error','unicode-text-preserved','complete-call-return','fallthrough-marker','statement-after-terminal'];
 report.controls=S.items(api.p147q_controls());assert.deepEqual(report.controls,names.map(x=>x+':pass'),'Independent renderer controls');
 for(const fixture of fixtures.fixtures){
  const segment=api['p147q_fixture_segment'+fixture.index](),ids=api['p147q_fixture_ids'+fixture.index]();
  assert.deepEqual(segment,fixture.completeSegment,'Exact retained segment value');
  for(const field of ['functions','constructors'])assert.deepEqual(S.semanticRows(ids[field]),fixture.referencedIds[field].map(x=>[x.name,'N111Id',x.id,0]));
  const before=JSON.stringify([segment,ids]);
  const baseline=api.p147q_render_segment(segment,ids,false),candidate=api.p147q_render_segment(segment,ids,true);
  assert.equal(typeof baseline,'string');assert(baseline.length>0);assert.equal(candidate,baseline,'Complete segment String');
  assert(!baseline.includes('INVALID_'),'Retained segment must render without refusal');assert.equal(JSON.stringify([segment,ids]),before,'Immutable inputs');
  const files={};for(const [role,text] of Object.entries({baseline,candidate})){const file=path.join(out,fixture.index+'-'+role+'.ssa');fs.writeFileSync(file,text,{flag:'wx'});files[role]=S.pin(file)}
  report.rows.push({index:fixture.index,name:fixture.definition,capture:fixture.capture,calls:fixture.calls,...files,completeTextExact:true,inputUnchanged:true});save();
 }
 inputs.forEach(S.verify);report.complete=report.passed=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,controls:report.controls.length,segments:report.rows.length,error:report.error}))}
