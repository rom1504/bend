// Checked Bend structural/import controls; host transports results only.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
const [receiptArg,sourceArg,outArg]=process.argv.slice(2),root=path.resolve(import.meta.dirname,'../../../../..');
assert(receiptArg&&sourceArg&&outArg,'Usage: finite.mjs CHECKED_API_REPORT SOURCE_MANIFEST FRESH_PHASE126_OUT');
const out=path.resolve(outArg);assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase126/'));
const read=f=>JSON.parse(fs.readFileSync(f,'utf8')),pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=p=>assert.deepEqual(pin(p.file),p),receipt=read(receiptArg),source=read(sourceArg),authorityFile=path.join(import.meta.dirname,'manifest04.json'),authority=read(authorityFile);
assert(receipt.complete&&receipt.checked&&source.complete);assert(receipt.inputs.some(p=>p.file===source.source.file&&p.sha256===source.source.sha256));
for(const p of authority.modules)assert(source.inputs.some(x=>x.sha256===p.sha256&&x.bytes===p.bytes),'Missing module: '+p.file);
const inputs=[pin(import.meta.filename),pin(receiptArg),pin(sourceArg),receipt.api,source.source,...receipt.inputs,...source.inputs,pin(authorityFile),...authority.modules,pin(process.execPath)];inputs.forEach(verify);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={complete:false,targetsRun:false,inputs,rows:[],scope:'Eighteen checked Bend structural/import/refusal/hygiene predicates. Invented metadata remains inside analysis; no native graph construction, emitted fabricated IR or native execution.'};
try {const api=(await import(pathToFileURL(receipt.api.file))).default;assert.equal(typeof api.p126lr_controls,'function');let xs=api.p126lr_controls();while(xs?.$==='Con'){report.rows.push(xs.head);xs=xs.tail}assert.equal(xs?.$,'Nil');assert.equal(report.rows.length,18);assert(report.rows.every(x=>x.endsWith(':pass')));inputs.forEach(verify);report.complete=true}
catch(error){report.error=String(error);process.exitCode=1}
finally {fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report.rows));console.log(JSON.stringify({complete:report.complete,error:report.error}))}
