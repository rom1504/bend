// Execute only exported checked Bend controls; host checks reported observations.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';
import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
const [input,name,count,out]=process.argv.slice(2);
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return {file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const inputs=[pin(input),pin(import.meta.filename)];
const api=(await import(pathToFileURL(path.resolve(input)).href)).default;
let xs=api[name]();const rows=[];while(xs.$==='Con'){rows.push(xs.head);xs=xs.tail;}
assert.equal(xs.$,'Nil');assert.equal(rows.length,Number(count));
fs.mkdirSync(out);fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({complete:rows.every(x=>x.startsWith('PASS ')),inputs,rows},null,2)+'\n');
assert(rows.every(x=>x.startsWith('PASS ')),JSON.stringify(rows));console.log(JSON.stringify({passed:rows.length}));
