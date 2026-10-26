// Inspect existing Bend certificate results on an ordinary checked request.
// No host semantic recognition or generated-code rewriting.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [apiReceipt,inputFile,outPath,...requested]=process.argv.slice(2);
assert(apiReceipt&&inputFile&&outPath);
const out=path.resolve(outPath);
assert(!fs.existsSync(out)&&out.includes('/selfhost/build/phase144/'));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const check=p=>assert.deepEqual(pin(p.file),p);
const read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
const a=read(apiReceipt),i=read(inputFile);
assert(a.complete&&a.checked&&a.exports.includes('p144a_inspect'));
const inputs=[pin(import.meta.filename),pin(process.execPath),pin(apiReceipt),a.api,...a.inputs,pin(inputFile),i.base,i.carrier,i.source];
inputs.forEach(check);fs.mkdirSync(out);
const report={kind:'phase144-existing-append-certificate-inspection',complete:false,inputs,rows:[]};
const start=performance.now();
try{
 const api=(await import(pathToFileURL(a.api.file))).default;
 const p=api.p88_cache_prepare(i.base.file,fs.readFileSync(i.base.file,'utf8'),fs.readFileSync(i.carrier.file,'utf8'),i.stamp);
 assert.equal(p.$,'P86PreparationReady');
 const q=api.p86_plan(p.seed,i.source.file,fs.readFileSync(i.source.file,'utf8'));
 assert.equal(q.$,'P86PlanReady');
 for(const name of requested.length?requested:['String.append']){
  let xs=api.p144a_inspect(q.request,name);const values=[];
  while(xs.$==='Con'){assert(values.length<128);assert.equal(typeof xs.head,'string');values.push(xs.head);xs=xs.tail;}
  assert.equal(xs.$,'Nil');report.rows.push({name,values});
 }
 inputs.forEach(check);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}
finally{
 report.seconds=(performance.now()-start)/1000;
 fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
 console.log(JSON.stringify({complete:report.complete,rows:report.rows,error:report.error}));
}
