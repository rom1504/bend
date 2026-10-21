// Calls checked Bend analysis controls only; no target code is generated/run.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [receipt, out] = process.argv.slice(2);
const pin = file => {
  file = path.resolve(file); const b = fs.readFileSync(file);
  return {file, bytes:b.length, sha256:crypto.createHash('sha256').update(b).digest('hex')};
};
const r = JSON.parse(fs.readFileSync(receipt));
if (!r.complete || !r.checked || fs.existsSync(out)) throw Error('Checked API and fresh output required');
for (const x of [r.api, ...r.inputs]) {
  const y=pin(x.file); if (y.sha256!==x.sha256 || y.bytes!==x.bytes) throw Error('Changed input '+x.file);
}
const result={complete:false,scope:'Finite pure analysis only; 32768-element scale checks execute only repaired traversals. No deliberate legacy overflow or malformed native program.',inputs:[pin(import.meta.filename),pin(receipt),r.api,pin(process.execPath)],rows:[]};
const start=performance.now();
try {
  const api=(await import(pathToFileURL(r.api.file))).default;
  for (const [name,args] of [['p118ns_controls',[]],['p118ns_scale',[32768]]]) {
    if (!r.exports.includes(name)) throw Error('Missing checked export '+name);
    const t=performance.now(); let xs=api[name](...args); const values=[];
    while(xs?.$==='Con'){values.push(xs.head);xs=xs.tail;}
    if(xs?.$!=='Nil'||!values.length||values.some(x=>typeof x!=='string'))throw Error('Control transport');
    result.rows.push({name,args,seconds:(performance.now()-t)/1000,values,passed:values.every(x=>x.startsWith('PASS '))});
  }
  result.complete=result.rows.every(x=>x.passed);
} catch(error) {result.error=String(error);result.stack=error?.stack;}
result.seconds=(performance.now()-start)/1000;
fs.writeFileSync(out,JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result));
if(!result.complete)process.exitCode=1;
