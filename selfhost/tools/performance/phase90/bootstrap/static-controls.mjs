// Exercise public full-library exports; no generated-code rewriting.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [apiArg,outArg]=process.argv.slice(2),file=path.resolve(apiArg),out=path.resolve(outArg);
assert(!fs.existsSync(out));
const pin=f=>({file:path.resolve(f),sha256:createHash('sha256').update(fs.readFileSync(f)).digest('hex'),bytes:fs.statSync(f).size});
const report={complete:false,inputs:[pin(file),pin(import.meta.filename),pin(process.execPath)],rows:[]};
const list=values=>values.reduceRight((tail,head)=>({$: 'Con',head,tail}),{$:'Nil'});
const values=node=>{const xs=[];for(;node.$==='Con';node=node.tail)xs.push(node.head);assert.equal(node.$,'Nil');return xs;};
try {
  const api=(await import(pathToFileURL(file))).default;
  for(const count of [0,1,17,65536]){
    const words=Array.from({length:count},(_,i)=>`${i}:λ🙂`),input=list(words);
    const row={count,terms:false,words:false,retainedInput:false};report.rows.push(row);
    const terms=api.ns_image_terms(input),flat=values(terms);assert.equal(flat.length,count);
    for(let i=0;i<count;i++)assert.deepEqual(flat[i],{$:'KTerm',tag:'StaticWord',name:words[i],id:0,quant:0,kids:{$:'Nil'},removed:{$:'Nil'},originBegin:0,originEnd:0});
    row.terms=true;assert.deepEqual(values(api.ns_image_words(terms)),words);row.words=true;
    assert.deepEqual(values(input),words);assert.equal(values(terms).length,count);row.retainedInput=true;
  }
  for(const p of report.inputs)assert.deepEqual(pin(p.file),p);
  report.complete=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(out,JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,rows:report.rows,error:report.error}));
