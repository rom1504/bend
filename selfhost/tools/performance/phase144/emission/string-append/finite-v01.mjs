// Checked Bend predicates only; malformed reflected IR is never executed.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [receiptFile,outArg]=process.argv.slice(2),out=path.resolve(outArg);
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const r=JSON.parse(fs.readFileSync(receiptFile));assert(r.complete&&r.checked&&r.status===0);
assert(!fs.existsSync(out)&&out.includes('/selfhost/build/phase144/'));
const inputs=[pin(import.meta.filename),pin(process.execPath),pin(receiptFile),r.api,...r.inputs];
inputs.forEach(p=>assert.deepEqual(pin(p.file),p));fs.mkdirSync(out);
const report={kind:'phase144-append-finite-controls',complete:false,inputs,suites:[],rows:[],expectedCount:55};
try{
 const api=(await import(pathToFileURL(r.api.file))).default;
 for(const [name,count]of [['p144ap_controls',23],['p125pc_controls',12],['p127lb_controls',20]]){
  let xs=api[name]();const rows=[];
  while(xs?.$==='Con'){assert(rows.length<count);rows.push(xs.head);xs=xs.tail;}
  assert.equal(xs?.$,'Nil');assert.equal(rows.length,count);
  report.suites.push({name,rows});report.rows.push(...rows);
  assert(rows.every(x=>typeof x==='string'&&(name==='p127lb_controls'?x.endsWith(':pass'):x.startsWith('PASS '))),name+' refused');
 }
 assert.equal(report.rows.length,55);inputs.forEach(p=>assert.deepEqual(pin(p.file),p));report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}
finally{fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,rows:report.rows,error:report.error}));}
