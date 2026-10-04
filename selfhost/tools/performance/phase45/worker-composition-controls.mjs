// Independent iterative mathematics and diagnostic worker counters; never timed.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [baseline,candidate,typescript,output,mode,deepRoot]=process.argv.slice(2);
const roots=['bench','tail_check','tree_check','scope_check','sibling_check'];
assert(output&&(!mode||(mode==='--deep'&&roots.includes(deepRoot))),
  'worker-composition-controls.mjs BASELINE_MODULE CANDIDATE_MODULE TS_MODULE NEW_OUT [--deep ROOT]');
const out=path.resolve(output);fs.mkdirSync(out);
const report={kind:'phase45-worker-composition-controls',complete:false,pass:false,
  scope:'Independent unsafe source fixture. Small checked predecessor/candidate/TypeScript agreement; deep runs select candidate only. Counters are untimed derivatives.',
  mode:mode?{deepRoot}:'small',inputs:[],modules:[],oracles:[],trees:[],activation:[],boundaries:[]};
const identity=p=>{const file=fs.realpathSync(p),bytes=fs.readFileSync(file);
  return {path:file,sha256:createHash('sha256').update(bytes).digest('hex'),bytes:bytes.length};};
const pinned=new Map();
function pin(file,expected){const row=identity(file);if(expected){assert.equal(row.sha256,expected.sha256);if(expected.bytes!==undefined)assert.equal(row.bytes,expected.bytes);}
  if(pinned.has(row.path))assert.deepEqual(row,pinned.get(row.path));else{pinned.set(row.path,row);report.inputs.push(row);}return row;}
function audit(x){if(Array.isArray(x))x.forEach(audit);else if(x&&typeof x==='object'){
  const file=x.file??x.path;if(file&&x.sha256)pin(file,x);Object.values(x).forEach(audit);}}
const mask=0xffffffffn,word=n=>Number(n&mask);
function arithmetic(n,seed,side=0){const saved=[];let s=BigInt(seed);
  for(let i=0;i<n;i++){saved.push([side,s]);s=(s+BigInt(side===0?3:5))&mask;side^=1;}
  let value=(s+BigInt(side===0?0:13))&mask;
  for(let i=saved.length-1;i>=0;i--){const [which,prior]=saved[i];value=(which===0?value*3n-prior:value+prior*7n)&mask;}
  return Number(value);}
function ribbon(n,seed){const marks=[];let s=BigInt(seed),sum=0n;
  for(let i=0;i<n;i++){const mark=(i%2===0?s+1n:s^85n)&mask;marks.push(Number(mark));sum=(sum+mark)&mask;s=(s+BigInt(i%2===0?3:5))&mask;}
  const end=(s+BigInt(n%2===0?0:11))&mask;return {marks,end:Number(end),sum:word(sum+end)};}
function oracle(name,n,seed){if(name==='bench')return arithmetic(n,seed);
  if(name==='tail_check')return word(BigInt(seed)+4n*BigInt(n)+BigInt(n%2===0?0:12));
  if(name==='tree_check')return ribbon(n,seed).sum;
  if(name==='scope_check')return word(BigInt(arithmetic(n,word(BigInt(seed)+2n)))-15n);
  return word(BigInt(arithmetic(n,seed))-BigInt(arithmetic(n,word(BigInt(seed)+1n),1)));}
function readRibbon(node,limit){const marks=[];while(node?.$==='RibbonMark'){
  assert(marks.length<limit,'Unexpected/cyclic Ribbon');const values=node.a??[node.value,node.rest];assert.equal(values.length,2);
  marks.push(values[0]);node=values[1];}assert.equal(node?.$,'RibbonEnd');
  const fields=node.a??[node.value];assert.equal(fields.length,1);return {marks,end:fields[0]};}
try{
  pin(import.meta.filename);pin(process.execPath);
  const catalogFile=path.join(import.meta.dirname,'worker-composition-catalog.json'),catalogId=pin(catalogFile);
  const catalog=JSON.parse(fs.readFileSync(catalogFile,'utf8'));
  const source=pin(path.join(import.meta.dirname,catalog.cases[0].source.path),catalog.cases[0].source);
  const modules=[],texts=[];
  for(const [i,file] of [baseline,candidate,typescript].entries()){
    const module=pin(file),receipt=pin(module.path+'.json'),emission=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
    assert.equal(emission.kind,'bend-program-checked-emission');assert.equal(emission.complete,true);
    assert.equal(emission.observation.checked,true);assert.equal(emission.observation.status,'ok');
    assert.equal(emission.input.sha256,source.sha256);assert.equal(emission.output.sha256,module.sha256);
    assert.equal(emission.catalog.sha256,catalogId.sha256);assert.equal(emission.compiler.upstreamCommit,catalog.upstreamCommit);
    assert.equal(emission.compiler.kind,i===2?'checked-pinned-typescript':'checked-development-attempt');audit(emission);
    report.modules.push({role:['baseline','candidate','typescript'][i],module,receipt,compiler:emission.compiler});
    texts.push(fs.readFileSync(module.path,'utf8'));
    modules.push(!mode||i===1?await import(pathToFileURL(module.path)):null);
  }
  for(const row of catalog.cases)assert.equal(oracle(row.point.exportName,...row.point.args),row.point.expected,'Catalog oracle '+row.id);
  const patches=[
    ['/* private contextual instances */','/* private contextual instances */++$p45Worker.contextual;'],
    ['/* private first-order continuation graph */','/* private first-order continuation graph */++$p45Worker.entries;'],
    ['$returns[$top]=','++$p45Worker.calls;$returns[$top]='],
    [';if(!$top)return $value;',';++$p45Worker.returns;if(!$top)return $value;'],
    ['$r.length=','++$p45Worker.tails;$r.length=']];
  assert(!texts[1].includes('$p45Worker'),'Reserved diagnostic name collision');
  let derived=texts[1];const edits=[];
  for(const [old,replacement] of patches){const count=derived.split(old).length-1;assert(count>0,'Missing worker shape '+old);
    edits.push({old,replacement,count});derived=derived.replaceAll(old,replacement);}
  derived='const $p45Worker={contextual:0,entries:0,calls:0,returns:0,tails:0};\n'+derived+
    '\nexport const p45WorkerCounts=()=>({...$p45Worker});\n';
  const derivedFile=path.join(out,'candidate-counter.mjs');fs.writeFileSync(derivedFile,derived,{flag:'wx'});
  report.derivative={module:identity(derivedFile),source:report.modules[1].module,edits,performanceEvidence:false};
  const witness=await import(pathToFileURL(derivedFile));
  function observed(name,n,seed){const expected=oracle(name,n,seed),before=witness.p45WorkerCounts();
    const value=witness.default[name](n,seed),after=witness.p45WorkerCounts();
    const counts=Object.fromEntries(Object.keys(before).map(key=>[key,after[key]-before[key]]));
    assert.equal(value,expected,name);assert.equal(counts.contextual,1,name+' contextual activation');assert.equal(counts.entries,1,name+' dispatcher activation');
    if(n>0&&name==='tail_check')assert(counts.tails>=n,'Tail transfers must execute');
    if(n>0&&name!=='tail_check')assert(counts.calls>=n,'Non-tail continuation calls must execute');
    report.activation.push({name,n,seed,expected,value,counts});return value;}
  if(!mode){
    for(const name of roots)for(const n of [0,1,2,3,8,31,32,33,64])for(const seed of [0,7,4294967295]){
      const expected=oracle(name,n,seed),values=modules.map(m=>m.default[name](n,seed));
      for(const value of values)assert.equal(value,expected,name+' '+n+' '+seed);
      report.oracles.push({name,n,seed,expected,values});}
    for(const name of roots)observed(name,33,4294967295);
    for(const [n,seed] of [[0,7],[1,7],[2,7],[3,4294967295],[8,7]]){
      const {marks,end}=ribbon(n,seed),expected={marks,end},values=[];
      for(const m of modules){const first=m.default.tree_value(n,seed),firstValue=readRibbon(first,n+1),second=m.default.tree_value(n,seed);
        assert.notEqual(first,second,'Public data must be fresh');assert.deepEqual(firstValue,expected);
        assert.deepEqual(readRibbon(first,n+1),expected);assert.deepEqual(readRibbon(second,n+1),expected);values.push(firstValue);}
      report.trees.push({n,seed,expected,values});}
    for(const name of roots){const helper={bench:'azimuth',tail_check:'port',tree_check:'willow',scope_check:'azimuth',sibling_check:'meridian'}[name];
      const observations=[];
      for(const m of modules.slice(0,2)){const f=m.G[helper],old=f.code,events=[];let value;
        try{f.code=function(a){events.push(helper);return Reflect.apply(old,this,[a]);};value=m.default[name](3,7);}
        finally{f.code=old;}observations.push({value,events});}
      assert.deepEqual(observations[1],observations[0]);assert(observations[0].events.length);
      const f=witness.G[helper],old=f.code,before=witness.p45WorkerCounts();
      try{f.code=function(a){return Reflect.apply(old,this,[a]);};assert.equal(witness.default[name](3,7),oracle(name,3,7));}
      finally{f.code=old;}
      const after=witness.p45WorkerCounts();assert.equal(after.contextual-before.contextual,0,name+' guard refusal');
      assert.equal(after.entries-before.entries,0,name+' worker refusal');report.boundaries.push({name,helper,observations});}
  }else{
    for(const n of [4096,50000])for(const seed of [7,4294967295]){
      const expected=oracle(deepRoot,n,seed),value=modules[1].default[deepRoot](n,seed);assert.equal(value,expected);
      observed(deepRoot,n,seed);report.oracles.push({name:deepRoot,n,seed,expected,value,role:'candidate'});
      assert.equal(modules[1].default[deepRoot](3,7),oracle(deepRoot,3,7),'Shallow result after deep execution');}
  }
  for(const item of pinned.values())assert.deepEqual(identity(item.path),item,'Changed input');
  assert.deepEqual(identity(derivedFile),report.derivative.module);report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,activation:report.activation.length,trees:report.trees.length,boundaries:report.boundaries.length,error:report.error}));
