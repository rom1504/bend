// Execute only checked Bend predicates; host checks their independent pass rows.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../../..');
const [receiptFile,outArg]=process.argv.slice(2),out=path.resolve(outArg);
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const r=JSON.parse(fs.readFileSync(receiptFile));
assert(r.complete&&r.checked&&r.status===0);
assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase137/'));
const inputs=[pin(receiptFile),pin(import.meta.filename),pin(process.execPath),...r.inputs,r.api];
for(const p of inputs)assert.deepEqual(pin(p.file),p);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase137-wide-finite-controls',complete:false,inputs,rows:[],expectedCount:17,scope:'Checked Bend finite predicates from the corrected Phase131 contract suite; no native runtime or whole-program speed claim.'};
try{
 const api=(await import(pathToFileURL(r.api.file))).default;
 let rows=api.p137w_controls();
 while(rows?.$==='Con'){report.rows.push(rows.head);rows=rows.tail}
 assert.equal(rows?.$,'Nil');assert.equal(report.rows.length,17);
 assert(report.rows.every(x=>typeof x==='string'&&x.startsWith('wide-')&&x.endsWith(':pass')));
 for(const p of inputs)assert.deepEqual(pin(p.file),p);
 report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({complete:report.complete,count:report.rows.length,error:report.error}));
