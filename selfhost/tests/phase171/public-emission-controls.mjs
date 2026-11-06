// Compiler-only fixture observations through independent source-checked APIs.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {fileURLToPath,pathToFileURL} from 'node:url';

const args={};
for(let i=2;i<process.argv.length;i+=2){
  assert(process.argv[i]?.startsWith('--')&&process.argv[i+1]);
  args[process.argv[i].slice(2)]=process.argv[i+1];
}
assert.deepEqual(Object.keys(args).sort(),['baseline','candidate','out']);
const own=fileURLToPath(import.meta.url),dir=path.dirname(own);
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {
  file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const verify=p=>assert.deepEqual(pin(p.file),p,'Changed input: '+p.file);
const inputs=[pin(own),pin(process.execPath),pin(path.join(dir,'public-emission-controls.bend')),
  pin(path.join(dir,'lazy-admission-controls.bend'))],authorities={};
for(const role of ['baseline','candidate']){
  const receipt=pin(args[role]),doc=JSON.parse(fs.readFileSync(receipt.file,'utf8'));
  assert.equal(doc.kind,'bend-checked-hosted-api');assert(doc.complete&&doc.checked&&!doc.error);
  assert(doc.exports.includes('p171pe_case'));
  inputs.push(receipt,doc.source,doc.api);authorities[role]={receipt,source:doc.source,image:doc.api};
}
assert.notEqual(authorities.baseline.source.sha256,authorities.candidate.source.sha256);
inputs.forEach(verify);assert(!fs.existsSync(args.out));fs.mkdirSync(args.out,{recursive:true});
const report={kind:'phase171-public-emission-controls',version:1,complete:false,passed:false,
  inputs,authorities,rows:[],scope:'48 complete public function strings from independent checked APIs, including malformed compiler IR. No execution or timing of generated programs; no promotion.'};
try{
  const values={};
  for(const role of ['baseline','candidate']){
    const api=(await import(pathToFileURL(authorities[role].image.file))).default;values[role]=[];
    for(let mode=0;mode<48;mode++){
      const value=api.p171pe_case(mode);assert.equal(value.$,'P171PEObservation');assert.equal(value.mode,mode);
      assert.equal(typeof value.text,'string');assert(value.text.length>0);
      assert.equal(typeof value.tailPath,'boolean');assert.equal(typeof value.fusedPublicPath,'boolean');
      values[role].push(value);
    }
    const text=JSON.stringify(values[role])+'\n';assert(Buffer.byteLength(text)<32*1024**2);
    const artifact=path.join(args.out,role+'.json');fs.writeFileSync(artifact,text,{flag:'wx'});
    (report.artifacts??=[]).push({...pin(artifact),role,completeOutput:true});
  }
  for(let mode=0;mode<48;mode++){
    const a=values.baseline[mode],b=values.candidate[mode];assert.deepEqual(b,a,'Complete public output '+mode);
    report.rows.push({mode,outputExact:true,bytes:Buffer.byteLength(a.text),
      tailPath:a.tailPath,fusedPublicPath:a.fusedPublicPath});
  }
  const v=values.baseline;
  assert(v[0].fusedPublicPath&&v[0].text.includes('p111_rt_jump'),'Require nonempty recursive public fixture');
  assert(v[32].text.includes('INVALID_N111_FALLTHROUGH'));
  for(const mode of [34,35,36,47])assert(v[mode].text.includes('INVALID_N111_BODY'),'Require error fixture '+mode);
  for(const mode of [39,46])assert(v[mode].text.includes('call $p112w_')&&v[mode].text.includes('%p112_reply'),'Require real direct public call '+mode);
  for(const mode of [40,41,42,44])assert(!v[mode].text.includes('call $p112w_'),'Reject malformed/unavailable direct tail '+mode);
  assert.equal(v[43].fusedPublicPath,false);
  assert(v.some(x=>x.tailPath),'Require unchanged tail-specialized dispatch');
  inputs.forEach(verify);report.complete=true;report.passed=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
fs.writeFileSync(path.join(args.out,'report.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({complete:report.complete,passed:report.passed,cases:report.rows.length,error:report.error}));
