#!/usr/bin/env node
// Same-image transport discriminator. Root owns the single process-tree guard.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import {spawnSync} from 'node:child_process';
import {pathToFileURL} from 'node:url';
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const pin=file=>({file:path.resolve(file),sha256:sha(fs.readFileSync(file))});
const verify=x=>assert.equal(pin(x.file).sha256,x.sha256,x.file);
const write=(file,data)=>fs.writeFileSync(file,JSON.stringify(data,null,2)+'\n',{flag:'wx'});
const [mode,manifestArg,...args]=process.argv.slice(2),manifestFile=path.resolve(manifestArg),m=JSON.parse(fs.readFileSync(manifestFile));
assert.equal(m.kind,'phase65-frame4-case-local-probe');
for(const key of ['producer','worker','node','preparation','api','driver','originalHelper','baseline','candidate','frame','frame3','corpus','previousCorpus','patch'])verify(m[key]);
assert.equal(process.execPath,m.node.file);assert.equal(pin(import.meta.filename).sha256,m.worker.sha256);
assert.equal(fs.readFileSync('/proc/self/status','utf8').match(/^Cpus_allowed_list:\s*(.+)$/m)?.[1],'3');
function exact(xs,ys){
 assert.equal(xs.length,ys.length);const forward=new WeakMap(),reverse=new WeakMap(),stack=xs.map((x,i)=>[x,ys[i]]);
 while(stack.length){const [a,b]=stack.pop();
  if(a===null||typeof a!=='object'){assert.ok(Object.is(a,b));continue;}
  assert.ok(b!==null&&typeof b==='object');if(forward.has(a)){assert.equal(forward.get(a),b);continue;}
  assert.equal(reverse.has(b),false);forward.set(a,b);reverse.set(b,a);assert.equal(Object.getPrototypeOf(a),Object.getPrototypeOf(b));assert.deepEqual(Object.keys(a),Object.keys(b));
  for(const key of Object.keys(a))stack.push([a[key],b[key]]);
 }
}
function decodeFrame(bytes,helper){
 const first=performance.now(),cut=bytes.indexOf(10);assert(cut>=0);
 const h=JSON.parse(bytes.subarray(0,cut).toString('utf8'));assert.equal(h.format,'bend-base-cache-frame-4');
 assert.equal(h.version,6);assert.equal(h.termAbi,1);assert.equal(h.spanAbi,3);assert.equal(h.validatedBy,'check_book');
 assert(Array.isArray(h.segments)&&h.segments.length===2&&h.segments.every(x=>Number.isSafeInteger(x)&&x>=0));
 const payload=bytes.subarray(cut+1);assert.equal(h.segments[0]+h.segments[1],payload.length);
 const bookBytes=payload.subarray(0,h.segments[0]),preparedBytes=payload.subarray(h.segments[0]);
 assert.equal(sha(bookBytes),h.bookGraphSha256);assert.equal(sha(preparedBytes),h.preparedGraphSha256);
 const options={range:{begin:h.sourceBegin,end:h.sourceEnd},termAbi:h.termAbi};
 const bookStart=performance.now(),book=helper.decodeBaseArena(bookBytes,{...options,rootKinds:['defs']}),bookEnd=performance.now();assert.notEqual(book.roots[0],null);
 const preparedStart=performance.now(),prepared=helper.decodeBaseArena(preparedBytes,{...options,base:book,rootKinds:['checked','fresh','world','frontend']}),end=performance.now();
 return {book,prepared,timing:{totalMs:end-first,bookMs:bookEnd-bookStart,preparedMs:end-preparedStart}};
}
function sameGraph(got,want){
 exact([...want.book.nodes,...want.prepared.nodes,...want.book.roots,...want.prepared.roots],[...got.book.nodes,...got.prepared.nodes,...got.book.roots,...got.prepared.roots]);
 for(const key of ['kinds','strings'])for(const part of ['book','prepared'])assert.deepEqual(got[part][key],want[part][key]);
 assert.equal(got.prepared.roots[2].prefix,got.book.roots[0]);assert.equal(got.prepared.roots[2].state,got.prepared.roots[0]);
}
if(mode==='worker'){
 const [role,output,diagnostic]=args;assert(['baseline','candidate'].includes(role));assert(!fs.existsSync(output));
 const helper=await import(pathToFileURL(m[role].file)),bytes=fs.readFileSync(m.frame.file),results=[];
 // No prior graph decode or equality walk; uninterrupted first/second/third calls.
 for(let i=0;i<3+m.warmDecodes;i++)results.push(decodeFrame(bytes,helper));
 const oracleHelper=await import(pathToFileURL(m.baseline.file)),oracle=decodeFrame(bytes,oracleHelper);
 for(const result of results)sameGraph(result,oracle);
 for(const key of ['worker','baseline','candidate','frame','api','driver'])verify(m[key]);
 const report={kind:'phase65-frame4-decoder-worker',complete:true,pass:true,role,traceDiagnostic:diagnostic==='trace',manifest:pin(manifestFile),node:pin(process.execPath),helper:m[role],frame:m.frame,rounds:results.map((r,i)=>({decode:i,label:i===0?'first':i<3?'next':'later',...r.timing})),graph:{bookNodes:oracle.book.nodes.length,preparedNodes:oracle.prepared.nodes.length,allNodeValuesAndSharingEqual:true},maxRssKiB:process.resourceUsage().maxRSS,scope:'Microprobe only. Module import/file read/input hashing precede clocks; complete frame header+payload digest checks and two eager schema-validating graph decodes inside clocks. All first3+later outputs retained until post-clock full graph/node/sharing comparison. Includes natural tier-up/GC; later calls are not fresh request latency. No driver semantic admission or compiler target run.'};
 write(output,report);console.log(JSON.stringify({pass:true,role,traceDiagnostic:report.traceDiagnostic,rounds:report.rounds}));
}else if(mode==='run'){
 const [outArg]=args,out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
 const env={...process.env};for(const k of Object.keys(env))if(k.startsWith('BEND_')||k==='NODE_OPTIONS'||k==='NODE_PATH')delete env[k];
 const base=['--stack-size=4096','--max-old-space-size=1024'];
 const report={kind:'phase65-frame4-case-local-execution',complete:false,pass:false,manifest:pin(manifestFile),node:pin(process.execPath),compilerExecuted:false,workers:[]};
 const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
 function run(name,argv){
  const stdout=path.join(out,name+'.stdout'),stderr=path.join(out,name+'.stderr'),fds=[fs.openSync(stdout,'wx'),fs.openSync(stderr,'wx')];let child;
  try{child=spawnSync(process.execPath,argv,{env,timeout:30000,stdio:['ignore',...fds]});}finally{fds.forEach(fs.closeSync);}
  assert.equal(child.error,undefined);assert.equal(child.signal,null);assert.equal(child.status,0,name);assert(fs.statSync(stdout).size+fs.statSync(stderr).size<4*1024*1024);
 }
 try{
  const controls=path.join(out,'controls.json');run('controls',[...base,m.corpus.file,m.baseline.file,m.candidate.file,m.frame3.file,controls]);const c=JSON.parse(fs.readFileSync(controls));assert(c.pass&&c.controls.length===87);report.controls=pin(controls);save();
  const orders=[['baseline','candidate'],['candidate','baseline'],['candidate','baseline'],['baseline','candidate']];assert.equal(m.rounds,orders.length);
  for(let round=0;round<orders.length;round++)for(const role of orders[round]){
   const name=`${round}-${role}`,file=path.join(out,name+'.json');run(name,[...base,import.meta.filename,'worker',manifestFile,role,file]);const row=JSON.parse(fs.readFileSync(file));assert(row.complete&&row.pass&&!row.traceDiagnostic);report.workers.push({round,role,result:pin(file),rounds:row.rounds});save();
  }
  const median=xs=>{xs=[...xs].sort((a,b)=>a-b);const n=xs.length;return (xs[Math.floor((n-1)/2)]+xs[Math.floor(n/2)])/2;};
  report.summary={};for(const role of ['baseline','candidate']){
   const rows=report.workers.filter(x=>x.role===role);report.summary[role]={};
   for(const [label,select] of [['first',rs=>[rs[0]]],['second',rs=>[rs[1]]],['third',rs=>[rs[2]]],['later',rs=>rs.slice(3)]])report.summary[role][label]=Object.fromEntries(['totalMs','bookMs','preparedMs'].map(k=>[k,median(rows.flatMap(x=>select(x.rounds).map(r=>r[k])))]));
  }
  report.candidateOverBaseline=Object.fromEntries(['first','second','third','later'].map(label=>[label,report.summary.candidate[label].totalMs/report.summary.baseline[label].totalMs]));
  report.complete=report.pass=true;
 }catch(error){report.error=String(error.stack??error);process.exitCode=1;}finally{save();}
 console.log(JSON.stringify({complete:report.complete,pass:report.pass,controls:report.controls,summary:report.summary,candidateOverBaseline:report.candidateOverBaseline,error:report.error}));
}else throw Error('Usage: probe.mjs run MANIFEST FRESH_OUTPUT | worker MANIFEST baseline|candidate FRESH_RESULT [trace]');
