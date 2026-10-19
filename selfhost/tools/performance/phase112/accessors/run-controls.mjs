import fs from 'node:fs';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import path from 'node:path';
const [input,out]=process.argv.slice(2);
const api=(await import(pathToFileURL(path.resolve(input)).href)).default;
let xs=api.p112a_control_report();const rows=[];
while(xs.$==='Con'){rows.push(xs.head);xs=xs.tail;}
assert.equal(xs.$,'Nil');assert.equal(rows.length,14);
fs.mkdirSync(out);fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({complete:rows.every(x=>x.startsWith('PASS ')),rows},null,2)+'\n');
assert(rows.every(x=>x.startsWith('PASS ')),JSON.stringify(rows));console.log(JSON.stringify({passed:rows.length}));
