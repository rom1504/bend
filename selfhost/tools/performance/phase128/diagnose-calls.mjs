// Host reporting only; all analyses are checked Bend exports.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [apiPath, sourcePath, output, ...owners] = process.argv.slice(2);
const pin = p => {p=path.resolve(p); const b=fs.readFileSync(p); return {file:p,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const verify = p => {const v=pin(p.file); if(v.sha256!==p.sha256 || v.bytes!==p.bytes) throw Error('Changed '+p.file);};
const read = p => JSON.parse(fs.readFileSync(p));
const report=read(apiPath); if(!report.complete || !report.checked) throw Error('Unchecked API');
verify(report.api); for(const p of report.inputs) verify(p);
const selection=read('selfhost/tools/native/selection.json'); verify(selection.admission);
const admission=read(selection.admission.file); if(!admission.complete || !admission.qualified) throw Error('Unqualified base');
const {base,cache}=admission.assets; verify(base); verify(cache.carrier);
const inputs=[pin(import.meta.filename),pin(apiPath),report.api,pin(sourcePath),selection.admission,base,cache.carrier];
const api=(await import(pathToFileURL(report.api.file))).default;
const list=x=>{const out=[]; while(x?.$==='Con'){out.push(x.head);x=x.tail;} if(x?.$!=='Nil') throw Error('Invalid list');return out;};
const start=performance.now();
const prep=api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(cache.carrier.file,'utf8'),cache.stamp);
if(prep.$!=='P86PreparationReady') throw Error(JSON.stringify(prep));
const planned=api.p86_plan(prep.seed,path.resolve(sourcePath),fs.readFileSync(sourcePath,'utf8'));
if(planned.$!=='P86PlanReady') throw Error(JSON.stringify(planned));
const rows=[];
for(const owner of owners){
 const t=performance.now();
 const row={owner,diagnostic:list(api.p128br_diagnose(planned.request,owner)),seconds:(performance.now()-t)/1000};
 rows.push(row); console.log(JSON.stringify(row));
}
for(const p of inputs) verify(p);
fs.writeFileSync(output,JSON.stringify({complete:true,inputs,rows,seconds:(performance.now()-start)/1000},null,2)+'\n',{flag:'wx'});
