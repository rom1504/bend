// Execute finite checks authored in Bend; no semantic admission in this runner.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [receiptFile,outArg,...specs]=process.argv.slice(2),out=path.resolve(outArg);
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=p=>assert.deepEqual(pin(p.file),p);
const rec=JSON.parse(fs.readFileSync(receiptFile));assert(rec.complete&&rec.checked);
rec.inputs.forEach(verify);verify(rec.api);assert(!fs.existsSync(out)&&specs.length);
fs.mkdirSync(out,{recursive:true});fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const report={kind:'phase142-finite-controls',complete:false,inputs:[pin(import.meta.filename),pin(process.execPath),pin(receiptFile),rec.api,...rec.inputs],groups:[]};
try{
 const api=(await import(pathToFileURL(rec.api.file))).default;
 for(const spec of specs){
  const [root,count]=spec.split(':');assert(rec.exports.includes(root)&&Number(count)>0);
  const start=performance.now();let l=api[root]();const rows=[];
  while(l.$==='Con'){assert(rows.length<10000);rows.push(l.head);l=l.tail;}
  assert.equal(l.$,'Nil');report.groups.push({root,rows,seconds:(performance.now()-start)/1000});
  assert.equal(rows.length,Number(count));assert(rows.every(x=>x.startsWith('PASS ')),JSON.stringify(rows.filter(x=>!x.startsWith('PASS '))));
 }
 report.inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}
finally{report.peakRssBytes=process.resourceUsage().maxRSS*1024;fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,groups:report.groups.map(g=>({root:g.root,count:g.rows.length,seconds:g.seconds})),error:report.error}));}
