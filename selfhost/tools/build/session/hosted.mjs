// Transport and observation only; all parsing/checking/reuse/render decisions run Bend.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {pin, verify} from '../hosted.mjs';
const [requestFile] = process.argv.slice(2);
const request = JSON.parse(fs.readFileSync(requestFile)), out = request.out;
const tag = (value, name) => {assert.equal(value?.$,name,value?.error);return value;};
const nil = () => ({$:'Nil'});
const report = {kind:'bend-experimental-hosted-session',version:1,complete:false,experimental:true,selected:false,
  mode:'cached-session',inputs:request.inputs,request:pin(requestFile),rows:[],coldComparisons:0,source:request.imageMetadata.sourceIdentity,
  scope:'One checked Bend API and fixed prepared Base. Same-mode cold comparisons; no ordinary/session byte identity or native qualification claim.'};
const save = () => fs.writeFileSync(path.join(out,'hosted.json'),JSON.stringify(report,null,2)+'\n');
function exact(left,right) {
  const todo=[[left,right]],seen=new WeakMap();
  while(todo.length) {const [a,b]=todo.pop();if(Object.is(a,b))continue;
    if(!a||!b||typeof a!=='object'||typeof b!=='object'){assert.deepEqual(a,b);continue;}
    let s=seen.get(a);if(s?.has(b))continue;if(!s){s=new WeakSet();seen.set(a,s);}s.add(b);
    const keys=Object.keys(a).sort();assert.deepEqual(keys,Object.keys(b).sort());for(const k of keys)todo.push([a[k],b[k]]);
  }
}
function frames(api,cursor,file,expected) {
  const fd=fs.openSync(file,'wx'),hash=crypto.createHash('sha256');let bytes=0,kind=3,unit=0,count=0,pieces=0;
  const marker=(verb,k,n)=>fs.writeSync(fd,`# P135/1 ${verb} ${k} ${n}\n`);
  try {for(;pieces<100000;pieces++) {
    const x=api.p135m_next(cursor);if(x.$==='P135MDone')break;tag(x,'P135MFrame');
    assert([0,1,2].includes(x.family)&&typeof x.complete==='boolean'&&typeof x.legacy_end==='boolean');
    if(x.family!==kind||(kind===0&&count>=1000)){if(kind!==3){marker('END',kind,unit);unit++;}kind=x.family;count=0;marker('BEGIN',kind,unit);}
    const data=Buffer.from(x.text+(x.legacy_end?'\n':''));bytes+=data.length;assert(bytes<=32*1024*1024);
    hash.update(data);fs.writeSync(fd,data);count+=Number(x.complete);cursor=x.next;
  }
  assert(pieces<100000,'unit cursor limit');if(kind!==3)marker('END',kind,unit);
  fs.writeSync(fd,`# P135/1 DONE ${kind===3?0:unit+1}\n`);
  } finally {fs.closeSync(fd);}
  assert.deepEqual({bytes,sha256:hash.digest('hex')},{bytes:expected.bytes,sha256:expected.sha256},'unit/render product mismatch');
  return pin(file);
}
const start=performance.now();save();
try {
  assert.equal(request.kind,'bend-experimental-session-request');assert.equal(request.host,'js');
  request.inputs.forEach(verify);assert.equal(request.imageMetadata.checked,true);
  assert.equal(pin(process.execPath).sha256,request.engine.sha256,'wrong JavaScript engine');
  const api=(await import(pathToFileURL(request.image.file))).default;
  for(const name of ['p88_cache_prepare','f_source_end','p140s_empty','p140s_named','p140g_prepare','p140r_begin_cursor','p140r_next',...(request.units?['p135m_next']:[])])assert.equal(typeof api[name],'function','missing export '+name);
  const prepared=tag(api.p88_cache_prepare(request.base.file,fs.readFileSync(request.base.file,'utf8'),fs.readFileSync(request.carrier.file,'utf8'),request.stamp),'P86PreparationReady');
  const seed=prepared.seed,origin=api.f_source_end(seed.source);
  assert(Number.isInteger(origin)&&origin>=0&&origin<=4294967295);
  const empty=()=>({compiler:api.p140s_empty(),registry:{$:'P140GCache',passes:nil()},render:{$:'P140REmpty'},pieces:[]});
  function compile(job,prior,label,makeUnits) {
    const text=fs.readFileSync(job.source.file,'utf8');assert(job.hint<=text.length&&origin+job.hint<=4294967295);
    const s=tag(api.p140s_named(seed,request.logical,text,prior.compiler,origin+job.hint,job.owner),'P140SResult');
    if(s.emission.$==='P111Emission'){assert(s.emission.error);exact(s.cache,prior.compiler);return {error:s.emission.error,state:prior};}
    const emitted=tag(s.emission,'P134Planned'),p=tag(api.p140g_prepare(emitted.plan,prior.registry),'P140GPrepared');
    let cursor=api.p140r_begin_cursor(p.cursor,prior.render),pieces=[],bytes=0,end;
    for(let n=0;n<100000;n++) {const x=api.p140r_next(cursor);if(x.$==='P140REnd'){end=x;break;}
      let text;if(x.$==='P140RReuse'){assert(Number.isInteger(x.ordinal)&&x.ordinal>=0&&x.ordinal<prior.pieces.length);text=prior.pieces[x.ordinal];}
      else {tag(x,'P140RText');assert.equal(typeof x.ending,'boolean');text=x.text+(x.ending?'\n':'');}
      bytes+=Buffer.byteLength(text);assert(bytes<=32*1024*1024);pieces.push(text);cursor=x.next;
    }
    assert(end&&bytes>0,'complete bounded rendered output');const productFile=path.join(out,label+'.ssa');
    fs.writeFileSync(productFile,pieces.join(''),{flag:'wx'});const product=pin(productFile);
    // Publication occurs only after the complete payload and optional frame view succeed.
    const unitFrames=makeUnits?frames(api,p.cursor,path.join(out,label+'.units'),product):undefined;
    return {product,unitFrames,registryHits:p.hits,registryMisses:p.misses,renderHits:end.hits,renderMisses:end.misses,
      state:{compiler:s.cache,registry:p.cache,render:end.cache,pieces}};
  }
  let state=empty();
  for(let i=0;i<request.jobs.length;i++) {
    const job=request.jobs[i],label=String(i).padStart(3,'0'),before=performance.now();
    let oracle;
    if(request.checkCold){oracle=compile(job,empty(),label+'-cold',false);delete oracle.state;}
    const result=compile(job,job.mode==='cold'?empty():state,label,request.units);
    if(job.expectError){assert(result.error,'expected semantic refusal');assert(!result.product);}
    else {assert(!result.error,result.error);if(job.expected)assert.equal(result.product.sha256,job.expected.sha256,'frozen product mismatch');}
    if(oracle){assert.equal(result.error,oracle.error,'mode-matched error mismatch');if(!result.error)assert.deepEqual([result.product.bytes,result.product.sha256],[oracle.product.bytes,oracle.product.sha256]);report.coldComparisons++;}
    state=result.state;delete result.state;
    report.rows.push({name:job.name,source:job.source,mode:job.mode,expectedError:job.expectError===true,seconds:(performance.now()-before)/1000,...result});save();
  }
  request.inputs.forEach(verify);verify(report.request);report.complete=true;
} catch(error) {report.error=String(error.stack||error);process.exitCode=1;}
finally {report.seconds=(performance.now()-start)/1000;save();console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));}
