// Diagnostic-only original admission records; timings are not clean performance.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';import {pin,verify,items} from '../../phase147/tools/support.mjs';
const [receipt,source,bindingFile,out]=process.argv.slice(2);fs.mkdirSync(out,{recursive:false});const r=JSON.parse(fs.readFileSync(receipt));assert(r.complete&&r.checked);verify(r.api);const api=(await import(pathToFileURL(r.api.file))).default;
const binding=JSON.parse(fs.readFileSync(bindingFile));verify(binding.base);verify(binding.carrier);
const report={complete:false,inputs:[pin(import.meta.filename),pin(receipt),pin(source),pin(bindingFile),binding.base,binding.carrier,r.api]};
try{const prep=api.p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);assert.equal(prep.$,'P86PreparationReady');const plan=api.p86_plan(prep.seed,fs.realpathSync(source),fs.readFileSync(source,'utf8'));assert.equal(plan.$,'P86PlanReady');
 report.rows=items(api.p167why_plan(plan)).map(r=>({...r,calls:items(r.calls),missing:items(r.missing)}));assert(!report.rows.some(r=>r.kind==='error'));report.complete=true;
}catch(e){report.error=String(e.stack??e);process.exitCode=1;}
finally{fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,error:report.error,rows:report.rows?.length}));}
