// Compare observations from two separately checked Bend APIs; no lowering here.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {fileURLToPath,pathToFileURL} from 'node:url';

const own=fileURLToPath(import.meta.url);
const args={};
for(let i=2;i<process.argv.length;i+=2){
  assert(process.argv[i]?.startsWith('--')&&process.argv[i+1]);
  args[process.argv[i].slice(2)]=process.argv[i+1];
}
assert.deepEqual(Object.keys(args).sort(),['baseline','candidate','out']);
const pin=file=>{file=fs.realpathSync(file);const bytes=fs.readFileSync(file);return {
  file,bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex')};};
const verify=p=>assert.deepEqual(pin(p.file),p,'Changed input: '+p.file);
const list=value=>{const rows=[];while(value?.$==='Con'){
  assert(rows.length<100);rows.push(value.head);value=value.tail;
}assert.equal(value?.$,'Nil');return rows;};
const inputs=[pin(own),pin(process.execPath)],authorities={};
for(const role of ['baseline','candidate']){
  const receipt=pin(args[role]),doc=JSON.parse(fs.readFileSync(receipt.file,'utf8'));
  assert.equal(doc.kind,'bend-checked-hosted-api');
  assert(doc.complete&&doc.checked&&!doc.error);
  for(const name of ['p171ff_cases','p171ff_scc_controls'])assert(doc.exports.includes(name));
  inputs.push(receipt,doc.source,doc.api);
  authorities[role]={receipt,source:doc.source,image:doc.api};
}
assert.notEqual(authorities.baseline.source.sha256,authorities.candidate.source.sha256);
inputs.forEach(verify);
const out=path.resolve(args.out);assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const report={kind:'phase171-fail-fast-controls',version:1,complete:false,passed:false,
  inputs,authorities,rows:[],scc:{},
  scope:'Successful complete lowering records, first failure diagnostics, and retained SCC selection. Failed partial body/calls/fresh intentionally may differ. No complete compiler speed or runtime qualification.'};
try{
  const values={};
  for(const role of ['baseline','candidate']){
    const api=(await import(pathToFileURL(authorities[role].image.file))).default;
    values[role]=list(api.p171ff_cases());
    report.scc[role]=list(api.p171ff_scc_controls());
    assert.equal(report.scc[role].length,6);
    assert(report.scc[role].every(x=>typeof x==='string'&&x.endsWith(':pass')));
    fs.writeFileSync(path.join(out,role+'.json'),JSON.stringify(values[role],null,2)+'\n',{flag:'wx'});
  }
  assert.equal(values.baseline.length,22);assert.equal(values.candidate.length,22);
  for(let i=0;i<22;i++){
    const a=values.baseline[i],b=values.candidate[i];
    assert.equal(a.$,'P171FFCase');assert.equal(b.$,'P171FFCase');
    assert.equal(a.name,b.name);assert.equal(a.expected,b.expected);
    assert.equal(a.code.$,'P113DCode');assert.equal(b.code.$,'P113DCode');
    assert.equal(a.code.error,a.expected,a.name+' baseline oracle');
    assert.equal(b.code.error,b.expected,b.name+' candidate oracle');
    if(a.expected==='')assert.deepEqual(b.code,a.code,a.name+' complete successful record');
    report.rows.push({name:a.name,passed:true,error:a.expected,
      completeCodeExact:a.expected==='',firstDiagnosticExact:true});
  }
  assert.deepEqual(report.scc.candidate,report.scc.baseline);
  inputs.forEach(verify);report.complete=true;report.passed=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({complete:report.complete,passed:report.passed,
  cases:report.rows.length,error:report.error}));
