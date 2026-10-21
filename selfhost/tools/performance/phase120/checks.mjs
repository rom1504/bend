// Reflected pure checks from an authenticated checked Bend API; no lowering.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [receipt,out,...names]=process.argv.slice(2);
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const r=JSON.parse(fs.readFileSync(receipt));
if(!r.complete||!r.checked||fs.existsSync(out)||!names.length)throw Error('Checked API, exports and fresh output required');
const inputs=[pin(import.meta.filename),pin(receipt),r.api,...r.inputs];
for(const x of inputs){const y=pin(x.file);if(y.sha256!==x.sha256||y.bytes!==x.bytes)throw Error('Changed input '+x.file)}
const api=(await import(pathToFileURL(r.api.file))).default,rows=[];
for(const name of names){
  if(!r.exports.includes(name))throw Error('Unexported '+name);
  let xs=api[name]();const values=[];
  if(typeof xs==='string')values.push(...xs.trim().split('\n'));
  else{while(xs?.$==='Con'){values.push(xs.head);xs=xs.tail}if(xs?.$!=='Nil')throw Error('Control transport')}
  if(!values.length||values.some(x=>typeof x!=='string'))throw Error('Empty control');
  rows.push({name,values,passed:values.every(x=>x.startsWith('PASS '))});
}
const result={complete:rows.every(x=>x.passed),rows,inputs};
fs.mkdirSync(path.dirname(out),{recursive:true});
fs.writeFileSync(out,JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result.rows));if(!result.complete)process.exitCode=1;
