// Test-only orchestration. Both compiler paths execute checked Bend APIs.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../../..');
const [apiFile,outArg,oldApiFile]=process.argv.slice(2),out=path.resolve(outArg);
assert(apiFile && out.startsWith(root+'/selfhost/build/phase131/') && !fs.existsSync(out));
const read=f=>JSON.parse(fs.readFileSync(f));
const pin=f=>{const file=path.resolve(f),b=fs.readFileSync(file);return {file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const inputs=new Map();
const add=p=>{const x=pin(p.file);assert.equal(x.bytes,p.bytes);assert.equal(x.sha256,p.sha256);inputs.set(x.file,x);return x;};
const file=f=>add(pin(f));
const selectionFile=path.join(root,'implementation/phase130/candidate.json');file(selectionFile);
const selected=read(selectionFile);assert(selected.complete && selected.nativeQualified);
for(const key of ['source','api','checkedApi','sourceManifest','preferredCarrier','preferredCarrierReceipt','legacyCarrierReceipt'])add(selected[key]);
const oldReceipt=oldApiFile?read(oldApiFile):read(selected.checkedApi.file);
if(oldApiFile)file(oldApiFile);assert(oldReceipt.complete && oldReceipt.checked && oldReceipt.status===0);
oldReceipt.inputs.forEach(add);add(oldReceipt.api);
const oldSources=oldReceipt.command.filter(x=>x.endsWith('.bend'));assert.equal(oldSources.length,1);
const comparisonSource=file(oldSources[0]);
const candidate=read(apiFile);file(apiFile);assert(candidate.complete && candidate.checked && candidate.status===0);
candidate.inputs.forEach(add);add(candidate.api);
const sources=candidate.command.filter(x=>x.endsWith('.bend'));assert.equal(sources.length,1);
const manifestFile=path.join(path.dirname(sources[0]),'manifest.json');file(manifestFile);
const manifest=read(manifestFile);assert(manifest.complete);add(manifest.source);manifest.inputs.forEach(add);
assert.deepEqual(manifest.parent,selected.source);
assert.deepEqual([...manifest.overrides].sort(),["P128BRHelper", "index_find", "index_set", "lookup", "missing", "nbc_closed", "nbc_definition", "nh_terms", "ns_unshared_terms", "p128br_call", "p128br_helper_names", "p128br_lookup", "p128br_scan_ready", "p128br_seed", "p128br_summaries", "p128raw_br_scanned"]);
const compact=read(selected.preferredCarrierReceipt.file);assert(compact.complete && compact.inverseByteIdentity);
compact.inputs.forEach(add);add(compact.carrier);assert.deepEqual(compact.carrier,selected.preferredCarrier);
assert.equal(compact.stamp,selected.preferredStamp);
const legacy=read(selected.legacyCarrierReceipt.file);assert(legacy.complete);Object.values(legacy.inputPins).forEach(add);
const base=add(legacy.inputPins.base),baseText=fs.readFileSync(base.file,'utf8');
const carrier=fs.readFileSync(compact.carrier.file,'utf8');
const profilesFile=path.join(root,'selfhost/build/phase129/profile01/manifest.json');file(profilesFile);
const profiles=read(profilesFile);assert.equal(profiles.schema,'bend-native-profile-workloads-v1');
profiles.inputs.forEach(add);file(import.meta.filename);file(process.execPath);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={complete:false,source:manifest.source,parent:selected.source,comparisonParent:comparisonSource,rows:[],realBodies:[],
  scope:'Independent checked APIs with unchanged final verification; parent QBE must match qualified frozen native oracles. Codegen candidate QBE may differ and requires independent ordinary native output checks. CPU5 diagnostic paired wall times are exploratory and not native compiler performance; concurrent root work may exist.'};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};save();
try {
  const old=(await import(pathToFileURL(oldReceipt.api.file))).default;
  const next=(await import(pathToFileURL(candidate.api.file))).default;
  const preparation=next.p88_cache_prepare(base.file,baseText,carrier,compact.stamp);
  assert.equal(preparation.$,'P86PreparationReady');
  // Real checked Base bodies, bounded and independently chosen before queries.
  let list=preparation.seed.book, visited=0;
  while(list?.$==='Con' && report.realBodies.length<16) {
    const d=list.head;list=list.tail;assert(++visited<10000);
    if(d?.$!=='KDef' || !d.value)continue;
    const todo=[d.value],seen=new Set();let nodes=0;
    while(todo.length && nodes<=128) {
      const t=todo.pop();if(!t || seen.has(t))continue;seen.add(t);nodes++;
      let kids=t.kids;while(kids?.$==='Con'){todo.push(kids.head);kids=kids.tail;}
    }
    if(nodes<4 || nodes>128)continue;
    assert.equal(next.p131u_agrees_all(d.value),true,d.name);
    report.realBodies.push({name:d.name,nodes,exactMinMax:true});
  }
  assert(report.realBodies.length>0,'No real Base bodies sampled');save();
  for(const name of ['lexer','coverage-closures-256','coverage-map-churn-128']) {
    const w=profiles.workloads.find(x=>x.name===name);assert(w);
    const variant=w.variants.find(x=>x.name==='phase128');assert(variant);
    const marker=variant.command.indexOf('phase111');assert(marker>=0);
    const source=add(variant.inputs.find(x=>x.file===variant.command[marker+1]));
    const sourceText=fs.readFileSync(source.file,'utf8'),oracle=add(variant.expected.stdout);
    const expected=fs.readFileSync(oracle.file);
    for(let round=0;round<1;round++)for(const label of round===0?['parent','candidate']:['candidate','parent']) {
      const api=label==='parent'?old:next,start=performance.now();
      const result=api.p111_compile_source(source.file,sourceText,base.file,baseText,carrier,compact.stamp,true);
      const requestSeconds=(performance.now()-start)/1000;
      assert.equal(result.$,'P111Emission');assert.equal(result.error,'');
      const target=path.join(out,`${name}-${round}-${label}.ssa`),fd=fs.openSync(target,'wx');
      let chunks=result.chunks,count=0;
      try {while(chunks?.$==='Con'){assert(++count<=2000000);fs.writeSync(fd,chunks.head+'\n');chunks=chunks.tail;}assert.equal(chunks?.$,'Nil');}finally{fs.closeSync(fd);}
      const frozenEqual=fs.readFileSync(target).equals(expected);
      if(label==='parent')assert(frozenEqual,`${name}/${label} differs from frozen QBE`);
      report.rows.push({name,round,label,source,oracle,product:file(target),requestSeconds,byteIdentical:frozenEqual});save();
    }
  }
  for(const p of inputs.values())add(p);
  report.complete=true;
} catch(error) {report.error=String(error);process.exitCode=1;}
finally {save();console.log(JSON.stringify({complete:report.complete,realBodies:report.realBodies.length,rows:report.rows.length,error:report.error}));}
