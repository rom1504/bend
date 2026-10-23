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
const report={kind:'phase130-base-dual-format-equivalence',complete:false,comparisons:[],rows:[],refusals:[],
  scope:'Checked JS API whole preparation and QBE equality for old decimal/new decimal/new compact; finite mode and malformed-input predicates. No native execution, native qualification, performance conclusion or proof claim. Runtime remains unchanged.'};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};
save();
try {
  addFile(import.meta.filename);addFile(process.execPath);
  const old=apiReceipt(oldFile),candidate=apiReceipt(newFile);
  assert(candidate.receipt.exports.includes('p130m_controls'));
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
  let controls=newAPI.p130m_controls();report.numericControls=[];
  while(controls?.$==='Con'){assert(report.numericControls.length<26);report.numericControls.push(controls.head);controls=controls.tail;}
  assert.equal(controls?.$,'Nil');assert.equal(report.numericControls.length,26);
  assert(report.numericControls.every(x=>typeof x==='string'&&x.endsWith(':pass')));save();
  const oldText=fs.readFileSync(original.carrier.file,'utf8'),newText=fs.readFileSync(compact.carrier.file,'utf8');
  const baseText=fs.readFileSync(base.file,'utf8');
  let oldPrep=oldAPI.p88_cache_prepare(base.file,baseText,oldText,original.stamp);
  let decimalPrep=newAPI.p88_cache_prepare(base.file,baseText,oldText,original.stamp);
  let newPrep=newAPI.p88_cache_prepare(base.file,baseText,newText,compact.stamp);
  const oa=aliases(oldPrep),da=aliases(decimalPrep),na=aliases(newPrep);
  for(const [k,v] of Object.entries(oa))if(v) {
    assert.equal(da[k],true,'Lost decimal old alias '+k);assert.equal(na[k],true,'Lost compact old alias '+k);
  }
  report.aliases={old:oa,candidateDecimal:da,candidateCompact:na,scope:'Both exposed world/book relationships recorded; every true old identity is required. No inaccessible checked-root alias is invented.'};
  report.preparationOutputs={candidateDecimal:graphSnapshot(decimalPrep,path.join(out,'candidate-decimal-preparation.graph.json')),
    candidateCompact:graphSnapshot(newPrep,path.join(out,'candidate-compact-preparation.graph.json')),
    referenceScope:'Old cached and freshly prepared values are recomputed and compared completely in memory; their equivalent graphs are not duplicated on disk.'};
  report.comparisons.push({name:'complete-candidate-decimal-versus-original-cache',...exact(oldPrep,decimalPrep)});
  report.comparisons.push({name:'complete-candidate-compact-versus-original-cache',...exact(oldPrep,newPrep)});save();
  let fresh=oldAPI.p86_prepare(base.file,baseText);aliases(fresh);
  report.comparisons.push({name:'complete-candidate-decimal-versus-fresh-prepare',...exact(fresh,decimalPrep)});
  report.comparisons.push({name:'complete-candidate-compact-versus-fresh-prepare',...exact(fresh,newPrep)});save();
  oldPrep=null;newPrep=null;decimalPrep=null;fresh=null;

  // Tiny independent malformed carriers exercise the actual entry. These are
  // test strings, not accepted prepared data or a second semantic decoder.
  const dtext=s=>String([...s].length)+'\n'+s+'\n';
  const word=n=>String.fromCodePoint(65536+(n%65536),65536+Math.floor(n/65536));
  const ctext=s=>word([...s].length)+s+'\n';
  const dh=dtext(original.stamp),ch=ctext(compact.stamp);
  const decimalCases=[
    ['empty',''],['empty-number','\n'],['leading-zero','01\n'],['zero-padding','00\n'],
    ['overflow','4294967296\n'],['eleven-digits','10000000000\n'],['signed','+1\n'],
    ['truncated-number','1'],['truncated-stamp',dh.slice(0,-1)],
    ['zero-nodes',dh+'0\n0\n'],['too-many-nodes',dh+'65537\n0\n'],
    ['too-many-strings',dh+'1\n4097\n'],['bad-node-number',dh+'x\n0\n'],
    ['wrong-stamp',dh+'0\n0\n',original.stamp+'!'],
    ['new-namespace-decimal-header',dtext(compact.stamp)+'0\n0\n',compact.stamp],
    ['trailing-data',oldText+'x'],['truncated-final-field',oldText.slice(0,-1)]
  ];
  const refuse=(r,at,expected)=>{
    assert.equal(r?.$,'P86PreparationError',at+': unexpectedly admitted');
    assert.equal(typeof r.error,'string');assert(r.error.startsWith('base_cache: '),at);
    if(expected!==undefined)assert.equal(r.error,'base_cache: '+expected,at);
  };
  fs.mkdirSync(path.join(out,'refusals'));
  for(const [name,text,stamp=original.stamp] of decimalCases) {
    const file=path.join(out,'refusals','decimal-'+name+'.p88');fs.writeFileSync(file,text,{flag:'wx'});
    const a=oldAPI.p88_cache_prepare(base.file,baseText,text,stamp);
    const b=newAPI.p88_cache_prepare(base.file,baseText,text,stamp);
    refuse(a,name);refuse(b,name);const equality=exact(a,b);
    report.refusals.push({name:'decimal-'+name,input:pin(file),expectedStamp:stamp,old:a,candidate:b,...equality});save();
  }
  const low=65536+([...compact.stamp].length%65536);
  const compactCases=[
    ['empty','','cache stamp'],['one-half',String.fromCodePoint(low),'cache stamp'],
    ['low-underflow',String.fromCodePoint(65535,65536),'cache stamp'],
    ['low-overflow',String.fromCodePoint(131072,65536),'cache stamp'],
    ['high-underflow',String.fromCodePoint(low,65535),'cache stamp'],
    ['high-overflow',String.fromCodePoint(low,131072),'cache stamp'],
    ['truncated-stamp',ch.slice(0,-1),'cache stamp'],
    ['wrong-stamp',ch,'cache stamp',compact.stamp+'!'],
    ['old-namespace',ch,'cache stamp',original.stamp],
    ['zero-nodes',ch+word(0)+word(0),'cache header bounds'],
    ['too-many-nodes',ch+word(65537)+word(0),'cache header bounds'],
    ['too-many-strings',ch+word(1)+word(4097),'cache header bounds'],
    ['decimal-number-after-word-header',ch+'1\n0\n','cache header bounds'],
    ['decimal-string-length-in-word-mode',ch+word(1)+word(1)+'0\n\n','cache string'],
    ['trailing-data',newText+'x','cache roots or trailing data']
  ];
  for(const [name,text,expected,stamp=compact.stamp] of compactCases) {
    const file=path.join(out,'refusals','compact-'+name+'.p130');fs.writeFileSync(file,text,{flag:'wx'});
    const actual=newAPI.p88_cache_prepare(base.file,baseText,text,stamp);refuse(actual,name,expected);
    report.refusals.push({name:'compact-'+name,input:pin(file),expectedStamp:stamp,expectedError:'base_cache: '+expected,actual,passed:true});save();
  }
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
    const d=emit(newAPI,source,base,oldText,original.stamp,path.join(out,name+'-candidate-decimal.ssa'));
    const b=emit(newAPI,source,base,newText,compact.stamp,path.join(out,name+'-candidate-compact.ssa'));
    const expected=fs.readFileSync(oracle.file);
    for(const [label,result] of [['old',a],['candidateDecimal',d],['candidateCompact',b]])
      assert(fs.readFileSync(result.product.file).equals(expected),name+': '+label+' differs from frozen native oracle');
    report.rows.push({name,source,old:a,candidateDecimal:d,candidateCompact:b,oracle,byteIdentical:true});save();
  }
  for(const p of inputs.values())verify(p);
  report.runtimeUnchanged=true;report.complete=true;report.passed=true;
} catch(error) {report.error=error.stack||String(error);report.passed=false;process.exitCode=1;}
finally {save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,report:path.join(out,'report.json'),error:report.error}));}
