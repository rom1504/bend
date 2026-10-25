// Transport only: semantic controls run in the independently checked Bend API.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [apiFile,outArg]=process.argv.slice(2),out=path.resolve(outArg);
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=p=>assert.deepEqual(pin(p.file),p);
const receipt=JSON.parse(fs.readFileSync(apiFile));assert(receipt.complete&&receipt.checked);
receipt.inputs.forEach(verify);verify(receipt.api);assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const report={kind:'phase140-verifier-finite',complete:false,inputs:[pin(import.meta.filename),pin(apiFile),receipt.api,...receipt.inputs],rows:[]};
try {const api=(await import(pathToFileURL(receipt.api.file))).default;const t=performance.now();let list=api.p140vt_controls();for(let n=0;n<100;n++){if(list.$==='Nil')break;assert.equal(list.$,'Con');report.rows.push(list.head);list=list.tail;}assert.equal(list.$,'Nil');assert.equal(report.rows.length,25);assert(report.rows.every(x=>x.startsWith('PASS ')),JSON.stringify(report.rows));report.seconds=(performance.now()-t)/1000;report.inputs.forEach(verify);report.complete=true;}catch(e){report.error=String(e.stack||e);process.exitCode=1;}finally{report.peakRssBytes=process.resourceUsage().maxRSS*1024;fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report));}
