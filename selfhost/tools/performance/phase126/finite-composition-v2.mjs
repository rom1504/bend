// Transport for independently specified checked Bend finite-control groups.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';

const [apiArg,outArg,...groups]=process.argv.slice(2);
const root=path.resolve(import.meta.dirname,'../../../..'),out=path.resolve(outArg);
assert(groups.length && !fs.existsSync(out) && out.startsWith(root+'/selfhost/build/phase126/'));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=p=>assert.deepEqual(pin(p.file),p);
const receipt=JSON.parse(fs.readFileSync(apiArg));
assert(receipt.complete && receipt.checked);
const inputs=[pin(import.meta.filename),pin(apiArg),receipt.api,...receipt.inputs,pin(process.execPath)];
inputs.forEach(verify);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={complete:false,inputs,groups:[],scope:'Checked Bend finite predicates only; no fabricated native runtime objects or benchmark execution.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
try {
  const api=(await import(pathToFileURL(receipt.api.file))).default;
  for(const group of groups){
    const match=/^(p126[a-z]+(?:_[a-z]+)?_controls)=([1-9][0-9]*)$/.exec(group);assert(match);
    const [,name,count]=match;assert.equal(typeof api[name],'function');
    const row={name,expectedCount:Number(count),rows:[]};report.groups.push(row);save();
    let xs=api[name]();
    while(xs?.$==='Con'){row.rows.push(xs.head);assert(row.rows.length<=row.expectedCount);xs=xs.tail;}
    assert.equal(xs?.$,'Nil');assert.equal(row.rows.length,row.expectedCount);
    assert(row.rows.every(x=>typeof x==='string'&&x.endsWith(':pass')));
    row.complete=true;save();
  }
  inputs.forEach(verify);report.complete=true;
} catch(error){report.error=String(error);process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,groups:report.groups.map(g=>({name:g.name,count:g.rows.length,complete:g.complete})),error:report.error}));}
