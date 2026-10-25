// Invoke existing checked Bend controls; this host supplies no semantic oracle.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import crypto from 'node:crypto';import {pathToFileURL} from 'node:url';
const [receiptFile,outArg,entry,count]=process.argv.slice(2),out=path.resolve(outArg);
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=p=>assert.deepEqual(pin(p.file),p),r=JSON.parse(fs.readFileSync(receiptFile));
assert(r.complete&&r.checked&&!fs.existsSync(out));r.inputs.forEach(verify);verify(r.api);
fs.mkdirSync(out,{recursive:true});fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const report={kind:'phase141-finite',complete:false,entry,expected:Number(count),inputs:[pin(import.meta.filename),pin(receiptFile),r.api,...r.inputs],rows:[]};
try{const api=(await import(pathToFileURL(r.api.file))).default;let list=api[entry]();
 while(list.$==='Con'){assert(report.rows.length<10000);report.rows.push(list.head);list=list.tail;}
 assert.equal(list.$,'Nil');assert.equal(report.rows.length,Number(count));assert(report.rows.every(x=>x.endsWith(':pass')),JSON.stringify(report.rows));
 report.inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}
finally{fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report));}
