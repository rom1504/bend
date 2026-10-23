// Test oracle/orchestration only. Executes checked Bend APIs; no host lowering.
// OLD_API_REPORT NEW_API_REPORT NEW_CARRIER_RECEIPT FRESH_OUT [PROFILE_MANIFEST]
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';

const root = path.resolve(import.meta.dirname, '../../../..');
const [oldFile,newFile,carrierFile,outArg,profileArg] = process.argv.slice(2);
assert(oldFile && newFile && carrierFile && outArg,
  'OLD_API_REPORT NEW_API_REPORT NEW_CARRIER_RECEIPT FRESH_OUT [PROFILE_MANIFEST]');
const out = path.resolve(outArg);
assert(out.startsWith(root+'/selfhost/build/phase130/') && !fs.existsSync(out));
const profileFile = profileArg || path.join(root,'selfhost/build/phase129/profile01/manifest.json');
const read = f => JSON.parse(fs.readFileSync(f));
const pin = f => {
  const file = path.resolve(f), bytes = fs.readFileSync(file);
  return {file,bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex')};
};
const verify = p => {
  const got=pin(p.file);
  assert.equal(got.sha256,p.sha256,'Changed input '+p.file);
  assert.equal(got.bytes,p.bytes,'Changed input length '+p.file);
  return got;
};
const inputs = new Map();
const add = p => {const got=verify(p), old=inputs.get(got.file); if(old)assert.deepEqual(old,got);inputs.set(got.file,got);return got;};
const addFile = f => add(pin(f));
const apiReceipt = f => {
  addFile(f);const r=read(f);
  assert(r.complete && r.checked && r.status===0);
  for(const x of r.inputs)add(x);
  add(r.api);
  for(const name of ['p88_cache_prepare','p86_prepare','p111_compile_source'])assert(r.exports.includes(name),name);
  const sources=r.command.filter(x=>x.endsWith('.bend'));assert.equal(sources.length,1);
  assert(r.inputs.some(x=>x.file===sources[0]));
  const manifest=path.join(path.dirname(sources[0]),'manifest.json');
  addFile(manifest);const m=read(manifest);assert(m.complete);assert.deepEqual(m.source,pin(sources[0]));
  for(const x of m.inputs||[])add(x);
  return {receipt:r,source:pin(sources[0]),manifest:pin(manifest)};
};

// Iterative, cycle-aware comparison of all own fields. This compares values;
// selected sharing identities are checked separately, not assumed from equality.
function exact(a,b) {
  const todo=[[a,b,'root']],seen=new WeakMap();let objectPairs=0,scalarChecks=0;
  while(todo.length) {
    const [x,y,at]=todo.pop();
    if(x===null || typeof x!=='object' || y===null || typeof y!=='object') {
      assert(Object.is(x,y),at+': scalar/type mismatch');scalarChecks++;continue;
    }
    assert.equal(Array.isArray(x),Array.isArray(y),at);
    let paired=seen.get(x);if(paired?.has(y))continue;
    if(!paired){paired=new WeakSet();seen.set(x,paired);}paired.add(y);
    assert(++objectPairs<=1000000,'Comparison exceeds bounded graph size');
    const xk=Object.keys(x).sort(),yk=Object.keys(y).sort();assert.deepEqual(xk,yk,at);
    for(const k of xk)todo.push([x[k],y[k],at.length<160?at+'.'+k:'...'+k]);
  }
  return {objectPairs,scalarChecks,exact:true};
}

// Preserve complete output without exponentially expanding shared AST nodes.
function graphSnapshot(value,file) {
  const ids=new Map(),pending=[],nodes=[];
  const ref=x=>{
    if(x===null || typeof x!=='object') {
      assert(x===null || ['string','boolean','number'].includes(typeof x),'Non-data API output');
      assert(typeof x!=='number'||Number.isFinite(x),'Nonfinite data');return {value:x};
    }
    if(!ids.has(x)){assert(ids.size<1000000,'Snapshot graph bound');ids.set(x,ids.size);pending.push(x);}
    return {node:ids.get(x)};
  };
  const start=ref(value);
  for(let i=0;i<pending.length;i++) {
    const x=pending[i];nodes.push({array:Array.isArray(x),fields:Object.keys(x).sort().map(k=>[k,ref(x[k])])});
  }
  fs.writeFileSync(file,JSON.stringify({format:'phase130-full-js-data-graph-v1',root:start,nodes})+'\n',{flag:'wx'});
  return {...pin(file),nodes:nodes.length};
}

function aliases(value) {
  assert.equal(value?.$,'P86PreparationReady',value?.error);
  assert.equal(value.seed?.$,'P86Seed');assert.equal(value.seed.world?.$,'KBasePreparedWorld');
  return {worldPrefixIsSeedBook:value.seed.world.prefix===value.seed.book,
    worldBookIsSeedBook:value.seed.world.book===value.seed.book};
}

function emit(api,source,base,carrier,stamp,file) {
  const before=performance.now();
  const r=api.p111_compile_source(source.file,fs.readFileSync(source.file,'utf8'),
    base.file,fs.readFileSync(base.file,'utf8'),carrier,stamp,true);
  assert.equal(r?.$,'P111Emission');assert.equal(r.error,'');
  const fd=fs.openSync(file,'wx');let xs=r.chunks,chunks=0;
  try {
    while(xs?.$==='Con') {
      assert.equal(typeof xs.head,'string');fs.writeSync(fd,xs.head+'\n');xs=xs.tail;
      assert(++chunks<=2000000,'Emission chunk bound');
    }
    assert.equal(xs?.$,'Nil');assert(chunks>0);
  } finally {fs.closeSync(fd);}
  return {product:pin(file),chunks,diagnosticSeconds:(performance.now()-before)/1000};
}

fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase130-base-complete-equivalence',complete:false,comparisons:[],rows:[],
  scope:'Checked JS API whole preparation and QBE equality; finite numeric predicates. No native execution, native qualification, performance conclusion or proof claim. Runtime remains unchanged.'};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};
save();
try {
  addFile(import.meta.filename);addFile(process.execPath);
  const old=apiReceipt(oldFile),candidate=apiReceipt(newFile);
  assert(candidate.receipt.exports.includes('p130b_controls'));
  addFile(carrierFile);const compact=read(carrierFile);
  assert(compact.complete && compact.inverseByteIdentity && compact.kind==='phase130-private-word-pair-carrier');
  assert.equal(compact.format,'p130-word-pair-v1');
  for(const x of compact.inputs)add(x);
  add(compact.carrier);add(compact.parentReceipt);add(compact.parentCarrier);
  const original=read(compact.parentReceipt.file);
  assert(original.complete && original.kind==='phase88-private-base-carrier');
  assert.deepEqual(original.carrier,compact.parentCarrier);
  assert.equal(original.stamp,compact.originalStamp);
  assert.equal(compact.stamp,'p130-word-pair-v1:'+original.stamp);
  for(const x of Object.values(original.inputPins))add(x);
  const base=add(original.inputPins.base);
  addFile(profileFile);const profiles=read(profileFile);
  assert.equal(profiles.schema,'bend-native-profile-workloads-v1');
  for(const x of profiles.inputs)add(x);
  const selected=read(path.join(root,'implementation/phase128/candidate.json'));
  addFile(path.join(root,'implementation/phase128/candidate.json'));add(selected.runtime);add(selected.runtimeReport);
  assert.deepEqual(old.source,selected.source);
  report.old=old;report.candidate=candidate;report.runtime=selected.runtime;
  report.carriers={old:original.carrier,candidate:compact.carrier};save();
  const oldAPI=(await import(pathToFileURL(old.receipt.api.file))).default;
  const newAPI=(await import(pathToFileURL(candidate.receipt.api.file))).default;
  let controls=newAPI.p130b_controls();report.numericControls=[];
  while(controls?.$==='Con'){assert(report.numericControls.length<12);report.numericControls.push(controls.head);controls=controls.tail;}
  assert.equal(controls?.$,'Nil');assert.equal(report.numericControls.length,12);
  assert(report.numericControls.every(x=>typeof x==='string'&&x.endsWith(':pass')));save();
  const oldText=fs.readFileSync(original.carrier.file,'utf8'),newText=fs.readFileSync(compact.carrier.file,'utf8');
  const baseText=fs.readFileSync(base.file,'utf8');
  let oldPrep=oldAPI.p88_cache_prepare(base.file,baseText,oldText,original.stamp);
  let newPrep=newAPI.p88_cache_prepare(base.file,baseText,newText,compact.stamp);
  const oa=aliases(oldPrep),na=aliases(newPrep);
  for(const [k,v] of Object.entries(oa))if(v)assert.equal(na[k],true,'Lost meaningful old alias '+k);
  report.aliases={old:oa,candidate:na,scope:'Both exposed world/book relationships recorded; every true old identity is required. No inaccessible checked-root alias is invented.'};
  report.preparationOutputs={old:graphSnapshot(oldPrep,path.join(out,'old-preparation.graph.json')),
    candidate:graphSnapshot(newPrep,path.join(out,'candidate-preparation.graph.json'))};
  report.comparisons.push({name:'complete-candidate-versus-original-cache',...exact(oldPrep,newPrep)});save();
  let fresh=oldAPI.p86_prepare(base.file,baseText);aliases(fresh);
  report.preparationOutputs.fresh=graphSnapshot(fresh,path.join(out,'fresh-preparation.graph.json'));
  report.comparisons.push({name:'complete-candidate-versus-fresh-prepare',...exact(fresh,newPrep)});save();
  oldPrep=null;newPrep=null;fresh=null;
  const names=['lexer','coverage-closures-256','coverage-map-churn-128'];
  for(const name of names) {
    const matches=profiles.workloads.filter(x=>x.name===name);assert.equal(matches.length,1);
    const v=matches[0].variants.find(x=>x.name==='phase128');assert(v);
    for(const p of v.inputs)add(p);
    const marker=v.command.indexOf('phase111');assert(marker>=0);
    const source=add(v.inputs.find(x=>x.file===v.command[marker+1]));
    assert.equal(v.command[marker+2],base.file);assert.equal(v.command[marker+3],'cache');
    assert.equal(v.command[marker+4],original.carrier.file);assert.equal(v.command[marker+5],original.stamp);
    assert.equal(v.expected.exitCode,0);assert.equal(v.expected.stdout.kind,'exact');
    const oracle=add(v.expected.stdout);const stderr=add(v.expected.stderr);assert.equal(stderr.bytes,0);
    const a=emit(oldAPI,source,base,oldText,original.stamp,path.join(out,name+'-old.ssa'));
    const b=emit(newAPI,source,base,newText,compact.stamp,path.join(out,name+'-candidate.ssa'));
    assert(fs.readFileSync(a.product.file).equals(fs.readFileSync(b.product.file)),name+': APIs differ');
    assert(fs.readFileSync(b.product.file).equals(fs.readFileSync(oracle.file)),name+': frozen native oracle differs');
    report.rows.push({name,source,old:a,candidate:b,oracle,byteIdentical:true});save();
  }
  for(const p of inputs.values())verify(p);
  report.runtimeUnchanged=true;report.complete=true;report.passed=true;
} catch(error) {report.error=error.stack||String(error);report.passed=false;process.exitCode=1;}
finally {save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,report:path.join(out,'report.json'),error:report.error}));}
