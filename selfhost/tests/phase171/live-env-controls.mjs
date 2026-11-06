// Complete observations from separately checked Bend APIs, including refusals.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {fileURLToPath,pathToFileURL} from 'node:url';

const [baseline,candidate,out]=process.argv.slice(2);
assert(baseline&&candidate&&out&&process.argv.length===5);
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {
  file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const verify=p=>assert.deepEqual(pin(p.file),p,'Changed input: '+p.file);
const list=value=>{const rows=[];while(value?.$==='Con'){
  assert(rows.length<100);rows.push(value.head);value=value.tail;
}assert.equal(value?.$,'Nil');return rows;};
const inputs=[pin(fileURLToPath(import.meta.url)),pin(process.execPath)],authorities={};
for(const [role,file] of [['baseline',baseline],['candidate',candidate]]){
  const receipt=pin(file),doc=JSON.parse(fs.readFileSync(receipt.file,'utf8'));
  assert.equal(doc.kind,'bend-checked-hosted-api');assert(doc.complete&&doc.checked&&!doc.error);
  assert(doc.exports.includes('p171le_cases'));
  inputs.push(receipt,doc.source,doc.api);authorities[role]={receipt,source:doc.source,image:doc.api};
}
assert.notEqual(authorities.baseline.source.sha256,authorities.candidate.source.sha256);
inputs.forEach(verify);assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const report={kind:'phase171-live-env-controls',version:1,complete:false,passed:false,
  inputs,authorities,rows:[],scope:'Full P113DCode equality including failed partial records, all fresh/call/body fields. No runtime or complete compiler performance qualification.'};
try{
  const values={};
  for(const role of ['baseline','candidate']){
    const api=(await import(pathToFileURL(authorities[role].image.file))).default;
    values[role]=list(api.p171le_cases());assert.equal(values[role].length,44);
    fs.writeFileSync(path.join(out,role+'.json'),JSON.stringify(values[role],null,2)+'\n',{flag:'wx'});
  }
  for(let i=0;i<44;i++){
    const a=values.baseline[i],b=values.candidate[i];
    assert.equal(a.$,'P171LECase');assert.equal(a.code.$,'P113DCode');
    assert.deepEqual(b,a,a.name+' full record');
    report.rows.push({name:a.name,error:a.code.error,completeCodeExact:true});
  }
  inputs.forEach(verify);report.complete=true;report.passed=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({complete:report.complete,passed:report.passed,cases:report.rows.length,error:report.error}));
