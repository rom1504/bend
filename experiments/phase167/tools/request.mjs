// File transport and measurements only; semantic compilation is checked Bend.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {pin, verify, items} from '../../phase147/tools/support.mjs';
const [receipt, source, base, role, out] = process.argv.slice(2);
assert(['baseline','raw','bounded','controls'].includes(role));
fs.mkdirSync(out,{recursive:false});
const report={complete:false,role,inputs:[pin(import.meta.filename),pin(receipt),pin(source),pin(base)],stages:{}};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const start=performance.now();
try {
 const r=JSON.parse(fs.readFileSync(receipt));assert(r.complete&&r.checked);verify(r.api);report.inputs.push(r.api);
 const api=(await import(pathToFileURL(r.api.file))).default;
 report.stages.loadSeconds=(performance.now()-start)/1000;
 if(role==='controls') {report.controls=items(api.p167e_controls());assert.equal(report.controls.length,30);assert(report.controls.every(x=>x.endsWith(':pass')));}
 else {
  let t=performance.now();
  const prepared=api.p86_prepare(fs.realpathSync(base),fs.readFileSync(base,'utf8'));
  assert.equal(prepared.$,'P86PreparationReady',JSON.stringify(prepared));
  report.stages.baseSeconds=(performance.now()-t)/1000;
  t=performance.now();
  const plan=api.p86_plan(prepared.seed,fs.realpathSync(source),fs.readFileSync(source,'utf8'));
  report.stages.frontendSeconds=(performance.now()-t)/1000;save();
  assert.equal(plan.$,'P86PlanReady',JSON.stringify(plan));
  t=performance.now();
  const product=role==='baseline'?api.p134e_plan(plan):api.p167e_plan(role==='raw'?0:1,plan);
  report.stages.lowerVerifySeconds=(performance.now()-t)/1000;save();
  const file=path.join(out,'program.ssa'),fd=fs.openSync(file,'wx');
  t=performance.now();
  try {
   if(role==='baseline'){
    assert.equal(product.$,'P134Planned',JSON.stringify(product));let cursor=api.p134e_begin(product.plan);
    for(;;){const next=api.p134e_next(cursor);if(next.$==='P134Done')break;assert.equal(next.$,'P134Piece');fs.writeSync(fd,next.text+(next.legacy_end?'\n':''));cursor=next.next;}
   } else {assert.equal(product.error,'');for(const chunk of items(product.chunks))fs.writeSync(fd,chunk+'\n');}
  } finally {fs.closeSync(fd);}
  report.stages.writeRenderSeconds=(performance.now()-t)/1000;
  report.ir=pin(file);
  const text=fs.readFileSync(file,'utf8');report.functions=(text.match(/^(?:export )?function /gm)||[]).length;
  report.requestSeconds=(performance.now()-start)/1000;
 }
 report.inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack??e);process.exitCode=1;}
finally{report.wallSeconds=(performance.now()-start)/1000;save();console.log(JSON.stringify(report));}
