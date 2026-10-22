// Ordinary checked source admission; no native fabricated IR or memory probes.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../..');
const [apiFile,sourceFile,expectedFile,out]=process.argv.slice(2);
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const read=f=>JSON.parse(fs.readFileSync(f));assert(!fs.existsSync(out));
const a=read(apiFile),s=read(path.join(root,'selfhost/tools/native/selection.json'));assert(a.complete&&a.checked);
const {base,cache}=read(s.admission.file).assets;
const inputs=[pin(import.meta.filename),pin(apiFile),a.api,pin(sourceFile),pin(expectedFile),s.admission,base,cache.carrier,...a.inputs];inputs.forEach(x=>assert.deepEqual(pin(x.file),x));
const report={complete:false,inputs,rows:[]};
try{
 const api=(await import(pathToFileURL(a.api.file))).default;
 const prep=api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(cache.carrier.file,'utf8'),cache.stamp);
 const plan=api.p86_plan(prep.seed,path.resolve(sourceFile),fs.readFileSync(sourceFile,'utf8'));assert.equal(plan.$,'P86PlanReady');
 for(const {name,expected} of read(expectedFile).queries){const value=api.p125p_inspect(plan.request,name);assert(typeof value==='boolean'||['True','False'].includes(value?.$));const observed=typeof value==='boolean'?value:value.$==='True';report.rows.push({name,expected,observed});assert.equal(observed,expected);}
 report.complete=true;
}catch(e){report.error=String(e);process.exitCode=1}finally{fs.writeFileSync(out,JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report.rows))}
