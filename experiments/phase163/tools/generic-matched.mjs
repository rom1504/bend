import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
import {pin,verify,items} from '../../phase147/tools/support.mjs';
const [receiptFile,originalFile,base,out]=process.argv.slice(2),receipt=JSON.parse(fs.readFileSync(receiptFile)),original=JSON.parse(fs.readFileSync(originalFile));
assert(receipt.complete&&receipt.checked&&original.complete);verify(receipt.api);fs.mkdirSync(out,{recursive:false});
const r={complete:false,inputs:[pin(import.meta.filename),pin(receiptFile),receipt.api,pin(originalFile),pin(base)],rows:[],scope:'Same prepared source, same mode3 policy, exactly identical final QBE. Generic control additionally constructs and verifies real original generic IR before discarding it. Hosted engine; not native or whole-self-build attribution.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(r,null,2)+'\n');
function text(emission){assert.equal(emission.$,'P111Emission');assert.equal(emission.error,'');return items(emission.chunks).join('')}
try{
 const api=(await import(pathToFileURL(receipt.api.file))).default;let start=performance.now();const prepared=api.p86_prepare(fs.realpathSync(base),fs.readFileSync(base,'utf8'));assert.equal(prepared.$,'P86PreparationReady');r.baseSeconds=(performance.now()-start)/1000;
 for(const old of original.rows.filter(x=>x.mode===3)){
  verify(old.source);verify(old.direct);r.inputs.push(old.source,old.direct);const row={name:old.case,source:old.source,samples:[],complete:false};r.rows.push(row);save();
  const plan=api.p86_plan(prepared.seed,old.source.file,fs.readFileSync(old.source.file,'utf8'));assert.equal(plan.$,'P86PlanReady');const expected=fs.readFileSync(old.direct.file,'utf8');
  start=performance.now();const raw=api.p163g_raw(plan.request);row.rawConstructionSeconds=(performance.now()-start)/1000;row.rawSummary=api.p163g_summary(raw);
  start=performance.now();const finished=text(api.p163g_finish(3,plan.request,raw));row.finishSeconds=(performance.now()-start)/1000;assert.equal(finished,expected,'Generic control differs from same-policy output');
  for(const [i,mode] of ['direct','generic','generic','direct'].entries()){
   start=performance.now();const value=text(mode==='direct'?api.p163o_executable_mode(3,plan.request):api.p163g_executable(3,plan.request));const seconds=(performance.now()-start)/1000;assert.equal(value,expected);
   row.samples.push({mode,seconds,outputBytes:Buffer.byteLength(value),exactOutput:true});save();
  }
  row.complete=true;save();
 }
 r.inputs.forEach(verify);r.complete=true;
}catch(e){r.error=String(e.stack??e);process.exitCode=1}finally{save();console.log(JSON.stringify({complete:r.complete,rows:r.rows.length,error:r.error}))}
