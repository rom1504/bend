// Complete public output comparison; the compiler algorithms remain in Bend.
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
const pin=file=>{file=fs.realpathSync(file);const bytes=fs.readFileSync(file);return {
  file,bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex')};};
const verify=p=>assert.deepEqual(pin(p.file),p,'Changed input: '+p.file);
const inputs=[pin(own),pin(process.execPath),pin(path.join(dir,'render-clean-controls-v2.bend')),
  pin(path.join(dir,'lazy-admission-controls.bend'))],authorities={};
for(const role of ['baseline','candidate']){
  const receipt=pin(args[role]),doc=JSON.parse(fs.readFileSync(receipt.file,'utf8'));
  assert.equal(doc.kind,'bend-checked-hosted-api');assert(doc.complete&&doc.checked&&!doc.error);
  assert(doc.exports.includes('p171rc_case'));
  inputs.push(receipt,doc.source,doc.api);authorities[role]={receipt,source:doc.source,image:doc.api};
}
assert.notEqual(authorities.baseline.source.sha256,authorities.candidate.source.sha256);
inputs.forEach(verify);assert(!fs.existsSync(args.out));fs.mkdirSync(args.out,{recursive:true});
const report={kind:'phase171-render-clean-controls',version:1,complete:false,passed:false,
  inputs,authorities,rows:[],scope:'44 complete public-emission strings and plan-boundary observations from two checked APIs. Constructed IR is not executed; no native performance or promotion claim.'};
try{
  const values={};
  for(const role of ['baseline','candidate']){
    const api=(await import(pathToFileURL(authorities[role].image.file))).default;
    values[role]=[];
    for(let mode=0;mode<44;mode++){
      const value=api.p171rc_case(mode);assert.equal(value.$,'P171RCObservation');assert.equal(value.mode,mode);
      assert.equal(typeof value.text,'string');assert(value.text.length>0);
      for(const key of ['direct','originalClean','hReady','hView'])assert.equal(typeof value[key],'boolean');
      values[role].push(value);
    }
    const text=JSON.stringify(values[role])+'\n';assert(Buffer.byteLength(text)<32*1024**2);
    const artifact=path.join(args.out,role+'.json');fs.writeFileSync(artifact,text,{flag:'wx'});
    (report.artifacts??=[]).push({...pin(artifact),role,completeOutput:true});
  }
  for(let mode=0;mode<44;mode++){
    const a=values.baseline[mode],b=values.candidate[mode];assert.deepEqual(b,a,'Complete public emission '+mode);
    if([36,37,38].includes(mode)){assert.equal(a.direct,true);assert.equal(a.text,a.directText);}
    if(mode===39)assert.equal(a.direct,false);
    report.rows.push({mode,outputExact:true,bytes:Buffer.byteLength(a.text),direct:a.direct,
      originalClean:a.originalClean,hReady:a.hReady,hView:a.hView});
  }
  for(const mode of [20,21,25,26,37,38,43])assert.equal(values.baseline[mode].originalClean,false);
  assert.equal(values.baseline[0].hReady,true,'Require accepted recursive helper fixture');
  assert(values.baseline.some(v=>v.hReady!==v.hView),'Require genuinely differing ready/view admission');
  inputs.forEach(verify);report.complete=true;report.passed=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
fs.writeFileSync(path.join(args.out,'report.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({complete:report.complete,passed:report.passed,cases:report.rows.length,error:report.error}));
