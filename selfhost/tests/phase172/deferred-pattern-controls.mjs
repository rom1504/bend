// Observation only: all parsing, substitution and flattening run in checked Bend.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {fileURLToPath,pathToFileURL} from 'node:url';

const own=fileURLToPath(import.meta.url),root=path.resolve(path.dirname(own),'../../..');
const args={};
for(let i=2;i<process.argv.length;i+=2){assert(process.argv[i]?.startsWith('--')&&process.argv[i+1]);args[process.argv[i].slice(2)]=process.argv[i+1];}
assert(Object.keys(args).every(k=>['baseline','candidate','out','source','base'].includes(k)));
for(const k of ['baseline','candidate','out'])assert(args[k],'Missing --'+k);
assert(Boolean(args.source)===Boolean(args.base),'Optional loader requires both --source and --base');
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const verify=p=>assert.deepEqual(pin(p.file),p,'Changed input: '+p.file);
const list=items=>items.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
function compareGraph(a,b){
  const pending=[[a,b]],seen=new WeakMap();let values=0;
  while(pending.length){
    assert(++values<=20000000,'Whole graph comparison bound exceeded');
    const [x,y]=pending.pop();if(Object.is(x,y))continue;
    assert(x!==null&&y!==null&&typeof x==='object'&&typeof y==='object','Complete scalar mismatch');
    let ys=seen.get(x);if(ys?.has(y))continue;if(!ys){ys=new WeakSet();seen.set(x,ys);}ys.add(y);
    assert.equal(Array.isArray(x),Array.isArray(y),'Container shape mismatch');
    const kx=Object.keys(x).sort(),ky=Object.keys(y).sort();assert.deepEqual(kx,ky,'Field shape mismatch');
    for(const k of kx)pending.push([x[k],y[k]]);
  }
  return {valuesCompared:values,completeGraphExact:true};
}
function comparisonControls(){
  const x={$:'KTerm',tag:'Var',name:'x',id:1,quant:2,kids:{$:'Nil'},removed:{$:'Nil'},originBegin:4,originEnd:8};
  compareGraph(x,structuredClone(x));let rejected=0;
  for(const y of [{...x,id:2},{...x,originBegin:0},{...x,removed:list(['z'])},{...x,kids:list([x])},{...x,name:'y'},{...x,$:'Other'}]){
    let failed=false;try{compareGraph(x,y);}catch{failed=true;}assert(failed,'Comparator accepted a changed complete field');rejected++;
  }
  return {equal:1,changedFieldsRejected:rejected};
}
const inputs=[pin(own),pin(process.execPath),pin(path.join(path.dirname(own),'deferred-pattern-controls.bend'))],authorities={};
for(const role of ['baseline','candidate']){
  const receipt=pin(args[role]),d=JSON.parse(fs.readFileSync(receipt.file,'utf8'));
  assert(d.kind==='bend-checked-hosted-api'&&d.complete&&d.checked&&!d.error,'Actual checked API required');
  for(const e of ['p172dp_sub_case','p172dp_match_case',...(args.source?['f_load_graph_trace']:[])])assert(d.exports.includes(e),'Missing export '+e);
  inputs.push(receipt,d.source,d.api);authorities[role]={receipt,source:d.source,image:d.api};
}
assert.notEqual(authorities.baseline.source.sha256,authorities.candidate.source.sha256);
let supplied=null,logical=null;
if(args.source){
  const source=pin(args.source),base=pin(args.base);assert(source.bytes<=4*1024**2&&base.bytes<=4*1024**2,'Bounded loader input required');inputs.push(source,base);
  const sourceText=fs.readFileSync(source.file,'utf8'),baseText=fs.readFileSync(base.file,'utf8');logical=source.file;
  const baseEnd=baseText.length+2,sourceEnd=baseEnd+sourceText.length+1;
  supplied=()=>list([
    {$:'FLocatedSource',source:{$:'FSource',name:logical,path:logical,text:sourceText},begin:baseEnd,end:sourceEnd},
    {$:'FLocatedSource',source:{$:'FSource',name:'Base',path:base.file,text:baseText},begin:1,end:baseEnd}
  ]);
}
inputs.forEach(verify);const out=path.resolve(args.out);
assert(out.startsWith(path.join(root,'selfhost/build')+path.sep)&&!fs.existsSync(out),'Fresh build output required');fs.mkdirSync(out,{recursive:true});
const report={kind:'phase172-deferred-pattern-controls',version:1,complete:false,passed:false,inputs,authorities,
  scope:'Whole-record equality from independently checked Bend APIs; finite data and optional complete loader controls. No native execution, proof or compilation-speed claim.',substitution:[],matches:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try{
  report.comparator=comparisonControls();const apis={};
  for(const role of ['baseline','candidate'])apis[role]=(await import(pathToFileURL(authorities[role].image.file))).default;
  const observations={baseline:{substitution:[],matches:[]},candidate:{substitution:[],matches:[]}};
  for(let mode=0;mode<20;mode++){
    const row={mode};
    for(const role of ['baseline','candidate']){
      const v=apis[role].p172dp_sub_case(mode);assert.equal(v.$,'P172DPSubObservation');assert.equal(v.mode,mode);
      row[role]=compareGraph(v.expected,v.actual);observations[role].substitution.push(v);
    }
    row.apisExact=compareGraph(observations.baseline.substitution[mode],observations.candidate.substitution[mode]);report.substitution.push(row);
  }
  for(let mode=0;mode<24;mode++){
    for(const role of ['baseline','candidate']){
      const v=apis[role].p172dp_match_case(mode);assert.equal(v.$,'P172DPMatchObservation');assert.equal(v.mode,mode);assert.equal(v.result.$,'FFlatten');observations[role].matches.push(v);
    }
    report.matches.push({mode,...compareGraph(observations.baseline.matches[mode],observations.candidate.matches[mode])});
  }
  assert.equal(observations.baseline.matches[0].result.term.tag,'Efq');
  for(const mode of [8,9,13])assert.equal(observations.baseline.matches[mode].result.term.tag,'Error','Required error observation '+mode);
  report.artifacts=[];
  for(const role of ['baseline','candidate']){const f=path.join(out,role+'.json');fs.writeFileSync(f,JSON.stringify(observations[role])+'\n',{flag:'wx'});report.artifacts.push({...pin(f),role});}
  save();
  if(supplied){
    const values={},times={};
    for(const role of ['baseline','candidate']){
      const begin=performance.now();values[role]=apis[role].f_load_graph_trace(logical,supplied());times[role]=(performance.now()-begin)/1000;
      assert.equal(values[role].$,'FLoadTrace');assert.equal(values[role].result.$,'FResult');assert.equal(values[role].result.error,'','Actual compiler loader source must pass');
    }
    report.loader={...compareGraph(values.baseline,values.candidate),diagnosticSeconds:times,scope:'Single shared host process; not clean native timing. Complete graph including diagnostic, ordering and origin fields compared.'};
  }
  inputs.forEach(verify);report.complete=true;report.passed=true;
}catch(e){report.error=String(e.stack??e);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,substitutions:report.substitution.length,matches:report.matches.length,loader:!!report.loader,error:report.error}));
