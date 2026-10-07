#!/usr/bin/env node
// Each worker is one fresh process. Root supplies the resource guard/affinity.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {performance} from 'node:perf_hooks';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {encodeIndexedFrame,decodeIndexedFrame,inspectIndexedLayout} from './indexed-codec-v1.mjs';
const sha=x=>crypto.createHash('sha256').update(x).digest('hex');
const identity=file=>({file:path.resolve(file),sha256:sha(fs.readFileSync(file))});
const rootKeys=['book','checkedPrefixState','freshPrefixState','preparedWorld','frontendReadyState'];
function exact(a,b){
  const forward=new WeakMap(),reverse=new WeakMap(),pending=rootKeys.map(key=>[a[key],b[key]]);
  while(pending.length){const [x,y]=pending.pop();
    if(x===null||typeof x!=='object'){assert.ok(Object.is(x,y));continue;}
    assert.ok(y!==null&&typeof y==='object');
    if(forward.has(x)){assert.equal(forward.get(x),y);continue;}
    assert.equal(reverse.has(y),false);forward.set(x,y);reverse.set(y,x);
    assert.deepEqual(Object.keys(x),Object.keys(y));for(const key of Object.keys(x))pending.push([x[key],y[key]]);
  }
}
const write=(file,data)=>fs.writeFileSync(file,JSON.stringify(data,null,2)+'\n',{flag:'wx'});
const [mode,...args]=process.argv.slice(2);
if(mode==='prepare'){
  const [driverFile,frameFile,output]=args.map(x=>path.resolve(x));fs.mkdirSync(output,{recursive:false});
  const driver=await import(pathToFileURL(driverFile)),source=fs.readFileSync(frameFile),before=driver.decodeBaseCacheFrame(source);
  const start=performance.now(),indexed=encodeIndexedFrame(source),encodeMs=performance.now()-start;
  exact(before,decodeIndexedFrame(indexed));
  const controls=[];const check=(name,fn)=>{fn();controls.push({name,pass:true});};
  const altered=(mutate,headerChange={})=>{
    const {header,segments}=inspectIndexedLayout(indexed),parts=segments.map(x=>Buffer.from(x));mutate(parts,header);
    const ph=sha(parts[1]),h={...header,...headerChange,segments:parts.map(x=>x.length),bookArenaSha256:sha(parts[0]),preparedArenaSha256:ph,checkedPrefixStateSha256:ph,freshPrefixStateSha256:ph};
    return Buffer.concat([Buffer.from(JSON.stringify(h)+'\n'),...parts]);
  };
  const layout=b=>{const n=b.readUInt32LE(8),nr=b.readUInt32LE(28),nf=b.readUInt32LE(20),tags=32+nr*4,offsets=tags+((n+3)&~3),fields=offsets+4*(n+1);return {n,nr,nf,tags,offsets,fields};};
  check('exact graph values and sharing',()=>exact(before,decodeIndexedFrame(indexed)));
  check('unaligned arena slices',()=>exact(before,decodeIndexedFrame(Buffer.concat([Buffer.from(' '),indexed]))));
  check('mandatory magic rejected',()=>assert.throws(()=>decodeIndexedFrame(altered(p=>p[0].writeUInt32LE(0,0)))));
  check('optional magic falls back',()=>{const c=decodeIndexedFrame(altered(p=>p[1].writeUInt32LE(0,0)));assert.ok(c.book);for(const k of rootKeys.slice(1))assert.equal(c[k],undefined);});
  check('base node count rejected',()=>assert.throws(()=>decodeIndexedFrame(altered(p=>p[0].writeUInt32LE(1,4)))));
  check('base string count rejected',()=>assert.throws(()=>decodeIndexedFrame(altered(p=>p[0].writeUInt32LE(1,12)))));
  check('mandatory null root rejected',()=>assert.throws(()=>decodeIndexedFrame(altered(p=>p[0].writeUInt32LE(0xffffffff,32)))));
  check('optional root type rejected',()=>{const c=decodeIndexedFrame(altered(p=>p[1].writeUInt32LE(0,32)));for(const k of rootKeys.slice(1))assert.equal(c[k],undefined);});
  check('invalid mandatory tag rejected',()=>assert.throws(()=>decodeIndexedFrame(altered(p=>{const l=layout(p[0]);p[0][l.tags]=99;}))));
  check('record offset rejected',()=>assert.throws(()=>decodeIndexedFrame(altered(p=>{const l=layout(p[0]);p[0].writeUInt32LE(1,l.offsets);}))));
  check('dangling typed reference rejected',()=>assert.throws(()=>decodeIndexedFrame(altered(p=>{const b=p[0],l=layout(b);let i=0;while(i<l.n&&b[l.tags+i]!==2)i++;assert.ok(i<l.n);const at=b.readUInt32LE(l.offsets+i*4);b.writeUInt32LE(l.n,l.fields+(at+4)*4);}))));
  check('source range rejected',()=>assert.throws(()=>decodeIndexedFrame(altered((p,h)=>{const b=p[0],l=layout(b);let i=0;while(i<l.n&&b[l.tags+i]!==2)i++;assert.ok(i<l.n);const at=b.readUInt32LE(l.offsets+i*4);b.writeUInt32LE(h.sourceEnd,l.fields+(at+6)*4);}))));
  check('boolean payload rejected',()=>assert.throws(()=>decodeIndexedFrame(altered(p=>{const b=p[0],l=layout(b);let i=0;while(i<l.n&&b[l.tags+i]!==5)i++;assert.ok(i<l.n);const at=b.readUInt32LE(l.offsets+i*4);b.writeUInt32LE(2,l.fields+(at+7)*4);}))));
  check('string reference rejected',()=>assert.throws(()=>decodeIndexedFrame(altered(p=>{const b=p[0],l=layout(b);let i=0;while(i<l.n&&b[l.tags+i]!==2)i++;assert.ok(i<l.n);const at=b.readUInt32LE(l.offsets+i*4);b.writeUInt32LE(0xffffffff,l.fields+at*4);}))));
  const cut=source.indexOf(10),oldHeader=JSON.parse(source.subarray(0,cut)),payload=source.subarray(cut+1),bg=JSON.parse(payload.subarray(0,oldHeader.segments[0])),pg=JSON.parse(payload.subarray(oldHeader.segments[0]));
  const jsonFrame=(book,prepared,meta={})=>{const b=Buffer.from(JSON.stringify(book)),p=Buffer.from(JSON.stringify(prepared)),hash=sha(p);return Buffer.concat([Buffer.from(JSON.stringify({...oldHeader,...meta,segments:[b.length,p.length],bookGraphSha256:sha(b),preparedGraphSha256:hash,checkedPrefixStateSha256:hash,freshPrefixStateSha256:hash})+'\n'),b,p]);};
  check('noncanonical negative zero refused by encoder',()=>{
    const b=Buffer.from('[1,0,[0],[[0],[2,"Ref","x",-0,0,0,0,0,0]]]'),p=Buffer.from('[1,2,[null,null,null,null],[]]'),hash=sha(p);
    const h={...oldHeader,segments:[b.length,p.length],bookGraphSha256:sha(b),preparedGraphSha256:hash,checkedPrefixStateSha256:hash,freshPrefixStateSha256:hash};
    assert.throws(()=>encodeIndexedFrame(Buffer.concat([Buffer.from(JSON.stringify(h)+'\n'),b,p])));
  });
  check('unused malformed mandatory record rejected',()=>{
    const tiny=encodeIndexedFrame(jsonFrame([1,0,[0],[[0],[0]]],[1,2,[null,null,null,null],[]]));
    const parts=inspectIndexedLayout(tiny),b=Buffer.from(parts.segments[0]),l=layout(b);b[l.tags+1]=99;
    const h={...parts.header,bookArenaSha256:sha(b)};assert.throws(()=>decodeIndexedFrame(Buffer.concat([Buffer.from(JSON.stringify(h)+'\n'),b,parts.segments[1]])));
  });
  for(const version of [1,2])check('world version '+version+' roundtrip',()=>{
    const prepared=structuredClone(pg),row=prepared[3][prepared[2][2]-prepared[1]];assert.equal(row[0],10);
    if(version===1)row.length=7;else if(row.length===7)row.push(0);
    const frame=jsonFrame(bg,prepared,{preparedWorldVersion:version}),expected=structuredClone(before);
    if(version===1)delete expected.preparedWorld.todos;else if(!Object.hasOwn(expected.preparedWorld,'todos'))expected.preparedWorld.todos=0;
    exact(expected,decodeIndexedFrame(encodeIndexedFrame(frame)));
  });
  const sourceFile=path.join(output,'source-frame3.json'),candidateFile=path.join(output,'candidate-indexed.bin');fs.writeFileSync(sourceFile,source,{flag:'wx'});fs.writeFileSync(candidateFile,indexed,{flag:'wx'});
  const manifest={schema:'phase64-indexed-codec-probe-1',pass:true,driver:identity(driverFile),baselineHelper:identity(driver.baseCacheGraphPath),controller:identity(fileURLToPath(import.meta.url)),node:{...identity(process.execPath),version:process.version},helper:identity(fileURLToPath(new URL('./indexed-codec-v1.mjs',import.meta.url))),source:identity(sourceFile),candidate:identity(candidateFile),original:identity(frameFile),controls,encodeMs,bytes:{frame3:source.length,indexed:indexed.length},
    limits:['Isolated host representation prototype; not selected compiler source.','Both record graphs fully validate and materialize eagerly.','Common API/Base/path metadata identity is retained; production driver admission integration is not tested by this decoder probe.']};
  write(path.join(output,'manifest.json'),manifest);console.log(JSON.stringify({pass:true,controls:controls.length,encodeMs,...manifest.bytes}));
}else if(mode==='worker'){
  const [manifestFile,role,output]=args,manifest=JSON.parse(fs.readFileSync(manifestFile));
  if(!['frame3','indexed'].includes(role))throw Error('Unknown role');
  for(const item of [manifest.driver,manifest.baselineHelper,manifest.controller,manifest.node,manifest.helper,manifest.source,manifest.candidate])assert.equal(sha(fs.readFileSync(item.file)),item.sha256);
  const driver=await import(pathToFileURL(manifest.driver.file));
  assert.equal(fs.realpathSync(driver.baseCacheGraphPath),fs.realpathSync(manifest.baselineHelper.file));assert.equal(process.version,manifest.node.version);
  const input=role==='frame3'?manifest.source:manifest.candidate;
  const start=performance.now(),bytes=fs.readFileSync(input.file),cached=role==='frame3'?driver.decodeBaseCacheFrame(bytes):decodeIndexedFrame(bytes),ms=performance.now()-start;
  const oracle=role==='frame3'?decodeIndexedFrame(fs.readFileSync(manifest.candidate.file)):driver.decodeBaseCacheFrame(fs.readFileSync(manifest.source.file));exact(cached,oracle);
  const report={schema:'phase64-indexed-first-decode-1',pass:true,role,ms,input,manifest:identity(manifestFile),driver:manifest.driver,baselineHelper:manifest.baselineHelper,helper:manifest.helper,controller:manifest.controller,node:manifest.node,
    limits:['One first decode after module import; no preceding graph decode in the process.','Read, outer-frame hashing, parsing, schema/range/reference validation and full ADT materialization included.','Driver/API import, API/Base/path discovery and checker-state semantic admission excluded.','Input hash verification rereads bytes before the clock; this is not OS-cold storage timing.','Exact values/sharing checked after the clock; no whole-compiler speed claim.']};
  fs.mkdirSync(path.dirname(output),{recursive:true});write(output,report);console.log(JSON.stringify({pass:true,role,ms}));
}else throw Error('Usage: indexed-probe-v1.mjs prepare DRIVER FRAME3 NEW_DIRECTORY | worker MANIFEST frame3|indexed OUTPUT.json');
