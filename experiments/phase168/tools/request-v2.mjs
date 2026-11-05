// File transport and measurements only; semantic compilation is checked Bend.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {pin, verify, items} from '../../phase147/tools/support.mjs';
const [receipt, source, base, role, out, bindingFile] = process.argv.slice(2);
assert(['baseline','targeted','targeted-regions','scalar-regions','scalars','scalars-inline','raw','bounded','controls','observers','live','plain','plain-live','plain-live-bounded','single','single-region'].includes(role));
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
  const binding=bindingFile?JSON.parse(fs.readFileSync(bindingFile)):null;
  if(binding){assert.equal(binding.base.sha256,pin(base).sha256);verify(binding.carrier);report.inputs.push(pin(bindingFile),binding.carrier);}
  report.preparationPolicy=binding?'authenticated prepared Base, fresh process':'live Base, fresh process';
  const prepared=binding?api.p88_cache_prepare(fs.realpathSync(base),fs.readFileSync(base,'utf8'),fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp):api.p86_prepare(fs.realpathSync(base),fs.readFileSync(base,'utf8'));
  assert.equal(prepared.$,'P86PreparationReady',prepared.error??'invalid preparation tag');
  report.stages.baseSeconds=(performance.now()-t)/1000;
  t=performance.now();
  const plan=api.p86_plan(prepared.seed,fs.realpathSync(source),fs.readFileSync(source,'utf8'));
  report.stages.frontendSeconds=(performance.now()-t)/1000;save();
  assert.equal(plan.$,'P86PlanReady',plan.error??'invalid checked plan tag');
  t=performance.now();
  const entries={'targeted':'p168t_plan','targeted-regions':'p168r_plan','scalar-regions':'p168r_plan','scalars-inline':'p168_plan','scalars':'p168_plan','observers':'p167ob_plan','raw':'p167e_plan','bounded':'p167e_plan','live':'p167live_plan','plain':'p167plain_plan','plain-live':'p167plainlive_plan','plain-live-bounded':'p167plainlive_plan','single':'p167single_mode','single-region':'p167single_mode'};
  const product=role==='baseline'?api.p134e_plan(plan):api[entries[role]](['targeted','targeted-regions','scalar-regions','scalars-inline','bounded','plain-live-bounded','single-region'].includes(role)?1:0,plan);
  report.stages.lowerVerifySeconds=(performance.now()-t)/1000;save();
  const file=path.join(out,'program.ssa'),fd=fs.openSync(file,'wx');
  t=performance.now();
  try {
   if(role==='baseline'){
    assert.equal(product.$,'P134Planned',product.error??'invalid emission tag');let cursor=api.p134e_begin(product.plan);
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
