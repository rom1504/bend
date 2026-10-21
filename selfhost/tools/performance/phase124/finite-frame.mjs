// Call checked Bend predicates; host transport only, no native execution.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
const [receiptArg,outArg]=process.argv.slice(2),root=path.resolve(import.meta.dirname,'../../../..'),out=path.resolve(outArg);
assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase124/'));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=x=>assert.deepEqual(pin(x.file),x),receipt=JSON.parse(fs.readFileSync(receiptArg));assert(receipt.complete&&receipt.checked);
const inputs=[pin(import.meta.filename),pin(receiptArg),receipt.api,...receipt.inputs,pin(process.execPath)];inputs.forEach(verify);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={complete:false,inputs,rows:[],scope:'Twelve checked Bend admission/refusal predicates. Pure fabricated metadata only; no native fabricated graph or memory access.'};
try {const api=(await import(pathToFileURL(receipt.api.file))).default;let xs=api.p124fc_controls();while(xs?.$==='Con'){report.rows.push(xs.head);xs=xs.tail}assert.equal(xs?.$,'Nil');assert.equal(report.rows.length,12);assert(report.rows.every(x=>x.startsWith('PASS')));inputs.forEach(verify);report.complete=true}
catch(e){report.error=String(e);process.exitCode=1}
finally {fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report.rows));console.log(JSON.stringify({complete:report.complete,error:report.error}))}
