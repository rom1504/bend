// Exact Bend transport functions are checked/emitted before this finite test.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [apiFile,reportFile]=process.argv.slice(2);
const api=(await import(pathToFileURL(path.resolve(apiFile)))).default;
const texts=['','plain identifier','function w $f() {\n@entry\n ret 0\n}\n',
  'quote " and backslash \\','\b\t\n\f\r','Bend λ 😀','lone \ud800 surrogate',
  ...Array.from({length:32},(_,i)=>String.fromCharCode(i))];
const units=texts.map((text,i)=>({$:'NxqUnit',name:'unit_'+i,text}));
const toList=values=>values.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
let checks=0;
for(const unit of units){
  const parsed=JSON.parse(api.p107_unit_json(unit));
  assert.deepEqual(parsed,{name:unit.name,text:unit.text});checks++;
}
for(const values of [[],units.slice(0,1),units.slice(1,3),units]){
  const parsed=JSON.parse('['+api.p107_unit_items(toList(values))+']');
  assert.deepEqual(parsed,values.map(({name,text})=>({name,text})));checks++;
}
const pin=file=>{const bytes=fs.readFileSync(file);return{file:path.resolve(file),bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex')};};
const report={complete:true,checks,individualStrings:texts.length,api:pin(apiFile),method:pin(import.meta.filename),
  scope:'Exact checked Bend unit transport; all control bytes, quoting, slashes, Unicode and lists. No native image acquisition.'};
fs.writeFileSync(reportFile,JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({passed:checks,report:reportFile}));
