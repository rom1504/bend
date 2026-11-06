// Observe complete Bend-produced plans through two separately checked APIs.
// No lowering, admission, or generated-program execution is implemented here.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {fileURLToPath,pathToFileURL} from 'node:url';

const own=fileURLToPath(import.meta.url),fixture=path.join(path.dirname(own),'lazy-admission-controls.bend');
const args={};
for(let i=2;i<process.argv.length;i+=2){
  assert(process.argv[i]?.startsWith('--')&&process.argv[i+1]);
  args[process.argv[i].slice(2)]=process.argv[i+1];
}
assert.deepEqual(Object.keys(args).sort(),['baseline','candidate','out']);
const pin=file=>{file=fs.realpathSync(file);const bytes=fs.readFileSync(file);return {
  file,bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex')};};
const verify=p=>assert.deepEqual(pin(p.file),p,'Changed input: '+p.file);
const inputs=[pin(own),pin(fixture),pin(process.execPath)],authorities={};
for(const role of ['baseline','candidate']){
  const receipt=pin(args[role]),doc=JSON.parse(fs.readFileSync(receipt.file,'utf8'));
  assert.equal(doc.kind,'bend-checked-hosted-api');assert(doc.complete&&doc.checked&&!doc.error);
  assert(doc.exports.includes('p171l_case'));
  inputs.push(receipt,doc.source,doc.api,...(doc.inputs??[]));
  authorities[role]={receipt,source:doc.source,image:doc.api};
}
assert.notEqual(authorities.baseline.source.sha256,authorities.candidate.source.sha256);
inputs.forEach(verify);
const labels=[
  'captured-head-recursive-success','arity-zero','arity-eight','arity-nine',
  'result-zero','result-two','incoming-one','flags-one',
  'known-legacy','wrong-legacy-kind','known-direct-view','direct-wrong-result',
  'direct-private','direct-arity-nine','legacy-in-view','body-511',
  'body-512','body-513','nested-body-512','nested-body-513',
  'fusion-declaration-prefix','fusion-use-prefix','local-declaration-prefix','local-use-prefix',
  'prefix-near-miss','bad-header-large-dirty','known-ready-dirty','other-direct-name',
  'plain-direct-is-not-legacy-ready','invalid-direct-legacy-fallback','plain-legacy-nine','view-legacy-nine'
];
const out=path.resolve(args.out);assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const report={kind:'phase171-lazy-admission-controls',version:1,complete:false,passed:false,
  inputs,authorities,rows:[],
  scope:'All fields of four planner results, including refused bodies/counters, compared across separately checked APIs. Finite compiler-data controls; constructed runtime programs are never executed. Native/corpus qualification remains separate.'};
try{
  const values={};
  for(const role of ['baseline','candidate']){
    const api=(await import(pathToFileURL(authorities[role].image.file))).default;
    values[role]=[];
    for(let mode=0;mode<labels.length;mode++){
      const value=api.p171l_case(mode);
      assert.equal(value.$,'P171LObservation');assert.equal(value.mode,mode);
      values[role].push(value);
    }
    const serialized=JSON.stringify(values[role])+'\n';
    const serializedBytes=Buffer.byteLength(serialized);
    assert(serializedBytes<=4*1024**2,'Compact complete-plan artifact exceeds 4 MiB bound');
    fs.writeFileSync(path.join(out,role+'.json'),serialized,{flag:'wx'});
    (report.artifacts??=[]).push({...pin(path.join(out,role+'.json')),role,format:'compact-json',completePlans:true});
  }
  for(let mode=0;mode<labels.length;mode++){
    const a=values.baseline[mode],b=values.candidate[mode];
    assert.deepEqual(b,a,labels[mode]+' complete observation');
    report.rows.push({mode,label:labels[mode],passed:true,completePlansExact:true,
      size:a.size,legacy:a.legacy,known:a.known,rvalid:a.rvalid,gvalid:a.gvalid,hvalid:a.hvalid});
  }
  const v=values.baseline;
  // A nonempty accepted plan is mandatory: empty-refusal agreement is insufficient.
  for(const key of ['rvalid','gvalid','hvalid'])assert.equal(v[0][key],1,'Missing admitted recursive fixture: '+key);
  assert.equal(v[0].rplan.body.$,'Con');assert.equal(v[0].gplan.body.$,'Con');assert.equal(v[0].hplan.body.$,'Con');
  assert.equal(v[0].hplan.cases.$,'Con');
  for(const mode of [1,2,3,4,5,6,7,20,21,25,26]){
    for(const key of ['rvalid','gvalid','hvalid'])assert.equal(v[mode][key],0,labels[mode]+' refusal '+key);
  }
  for(const mode of [8,30]){
    assert.equal(v[mode].legacy,1);assert.equal(v[mode].known,1);
    assert.equal(v[mode].gvalid,0);assert.equal(v[mode].hvalid,0);
  }
  for(const mode of [10,14,29]){
    assert.equal(v[mode].legacy,0);assert.equal(v[mode].known,1);
    assert.equal(v[mode].gvalid,1);assert.equal(v[mode].hvalid,0);
  }
  for(const mode of [9,11,12,13,27,28,31]){
    assert.equal(v[mode].legacy,0);assert.equal(v[mode].known,0);
    assert.equal(v[mode].gvalid,1);assert.equal(v[mode].hvalid,1);
  }
  for(const [mode,size] of [[15,511],[16,512],[17,513],[18,512],[19,513]]){
    assert.equal(v[mode].size,size);assert.equal(v[mode].hvalid,size<=512?1:0);
  }
  for(const mode of [22,23]){
    assert.equal(v[mode].clean,1);assert.equal(v[mode].hclean,0);
    assert.equal(v[mode].rvalid,1);assert.equal(v[mode].gvalid,1);assert.equal(v[mode].hvalid,0);
  }
  assert.equal(v[24].hclean,1);assert.equal(v[24].hvalid,1);
  // The c planner deliberately ignores arity/incoming, unlike r/g/h.
  for(const mode of [1,2,3,6])assert.deepEqual(v[mode].cplan,v[0].cplan,'Preserve c header scope '+labels[mode]);
  inputs.forEach(verify);report.complete=true;report.passed=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({complete:report.complete,passed:report.passed,cases:report.rows.length,error:report.error}));
