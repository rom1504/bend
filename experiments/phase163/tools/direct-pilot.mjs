// Scheduling, timing and exact artifacts only. All compiler decisions are Bend.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {pin,verify,items,list} from '../../phase147/tools/support.mjs';
const [receipt,baselineReceipt,base,out,...sources]=process.argv.slice(2);
const r=JSON.parse(fs.readFileSync(receipt));assert(r.complete&&r.checked);verify(r.api);
fs.mkdirSync(out,{recursive:false});
const api=(await import(pathToFileURL(r.api.file))).default;
const br=JSON.parse(fs.readFileSync(baselineReceipt));assert(br.complete&&br.checked);verify(br.api);
assert.equal(br.source.sha256,'027e15041035522ed7e40ef971eff75f24a09ef6a00e3f8fe335839f94bcb8a8');
const old=(await import(pathToFileURL(br.api.file))).default;
function emitOld(plan){const emission=old.p134e_plan(plan);if(emission.$==='P111Emission'){assert.equal(emission.error,'');return items(emission.chunks).join('\n')+'\n'}
 assert.equal(emission.$,'P134Planned');let cursor=old.p134e_begin(emission.plan),text='';
 while(true){const next=old.p134e_next(cursor);if(next.$==='P134Done')return text;assert.equal(next.$,'P134Piece');text+=next.text+(next.legacy_end?'\n':'');cursor=next.next}}
const report={complete:false,inputs:[pin(import.meta.filename),pin(receipt),r.api,pin(baselineReceipt),br.api,pin(base)],controls:[],rows:[],scope:'Checked hosted execution of Bend lowering on the same prepared request; machine construction and native outputs are separate.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
try{
 for(const name of ['p163dc_controls','p163x_controls']){
  const rows=items(api[name]());report.controls.push(...rows);save();
  assert.equal(rows.length,name==='p163dc_controls'?14:4);assert(rows.every(x=>x.endsWith(':pass')));
 }
 let start=performance.now();const prepared=api.p86_prepare(fs.realpathSync(base),fs.readFileSync(base,'utf8'));
 assert.equal(prepared.$,'P86PreparationReady',JSON.stringify(prepared));report.basePreparationSeconds=(performance.now()-start)/1000;
 for(const source of sources){
  const row={source:pin(source),name:path.basename(path.dirname(source)),complete:false};report.rows.push(row);report.inputs.push(row.source);save();
  start=performance.now();const plan=api.p86_plan(prepared.seed,fs.realpathSync(source),fs.readFileSync(source,'utf8'));row.frontendSeconds=(performance.now()-start)/1000;
  assert.equal(plan.$,'P86PlanReady',JSON.stringify(plan));
  start=performance.now();const direct=api.p163d_executable(plan.request);row.directSeconds=(performance.now()-start)/1000;
  assert.equal(direct.$,'P111Emission');row.directError=direct.error;
  if(!direct.error){const file=path.join(out,row.name+'-direct.ssa');fs.writeFileSync(file,items(direct.chunks).join(''),{flag:'wx'});row.direct=pin(file)}
  start=performance.now();const baseline=emitOld(plan);row.baselineSeconds=(performance.now()-start)/1000;
  const file=path.join(out,row.name+'-baseline.ssa');fs.writeFileSync(file,baseline,{flag:'wx'});row.baseline=pin(file);
  row.complete=true;save();
 }
 report.inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack??e);process.exitCode=1}
finally{save();console.log(JSON.stringify(report))}
