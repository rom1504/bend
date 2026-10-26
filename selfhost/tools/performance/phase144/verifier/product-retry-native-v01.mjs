// Matched checked-Bend baseline/retry emission; no host optimizer or QBE edits.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const ROOT=path.resolve(import.meta.dirname,'../../../../..');
const [planFile,outArg]=process.argv.slice(2),out=path.resolve(outArg);
assert(planFile&&outArg&&!fs.existsSync(out)&&out.startsWith(ROOT+'/selfhost/build/phase144/'));
const read=f=>JSON.parse(fs.readFileSync(f,'utf8'));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const plan=read(planFile);assert(plan.complete&&plan.kind==='phase144-product-retry-native-plan');
const inputs=[pin(import.meta.filename),pin(process.execPath),pin(planFile),...plan.inputs];
for(const p of inputs)assert.deepEqual(pin(p.file),p);
const baseline=read(plan.apis.old),retry=read(plan.apis.new);
assert(baseline.complete&&baseline.checked&&retry.complete&&retry.checked);
const bs=baseline.inputs.find(p=>p.file.endsWith('/compiler.bend'));
const rs=retry.inputs.find(p=>p.file.endsWith('/compiler.bend'));
assert.equal(bs.sha256,'992893e6cf6a5bf7d6d092812b3a5da20852feca882005f32a91e607cef0483b');
assert.equal(rs.sha256,'d5ffda8074b32d32ad58288b6206e783e7a72faf1882367a1548f518469955e8');
assert(fs.readFileSync(rs.file,'utf8').startsWith(fs.readFileSync(bs.file,'utf8')));
const census=read(plan.census.file);assert(census.complete&&census.allCandidatesVerified);
const witness=census.rows.find(r=>r.name==='verifier-product');
assert(witness?.complete&&witness.candidateVerified&&witness.summary.newReady===5);
assert.deepEqual(witness.source,plan.source);
fs.mkdirSync(out);
const report={kind:'phase144-product-retry-matched-emission',complete:false,inputs,
 source:plan.source,expected:plan.expected,runtime:plan.runtime,variants:{},
 compilerRelation:'Retry compiler is exact unchanged baseline source prefix plus141 additive prototype lines; same input program, Base, carrier and runtime. Emission uses original final verifier. No production selection changes.',
 scope:'Complete checked emission only. Hosted stage seconds are diagnostic, not compiler-speed comparisons. Retry raw reservoir remains unchanged as in the admission census.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
const tag=(x,t)=>{assert.equal(x?.$,t,JSON.stringify({expected:t,actual:x?.$,error:x?.error}));return x};
const start=performance.now();
try{
 for(const mode of ['old','new']){
  const ar=mode==='old'?baseline:retry,api=(await import(pathToFileURL(ar.api.file))).default;
  const row={api:pin(plan.apis[mode]),source:plan.source,complete:false};report.variants[mode]=row;save();
  const t=performance.now();
  const prep=tag(api.p88_cache_prepare(plan.base.file,fs.readFileSync(plan.base.file,'utf8'),
   fs.readFileSync(plan.carrier.file,'utf8'),plan.stamp),'P86PreparationReady');
  const checked=tag(api.p86_plan(prep.seed,plan.source.file,fs.readFileSync(plan.source.file,'utf8')),'P86PlanReady');
  const target=out+'/'+mode+'.ssa',fd=fs.openSync(target,'wx');let bytes=0,pieces=0;
  const write=text=>{bytes+=Buffer.byteLength(text);assert(bytes<32*1024*1024);fs.writeSync(fd,text)};
  try{
   if(mode==='old'){
    const emitted=tag(api.p134e_plan(checked),'P134Planned');let cursor=api.p134e_begin(emitted.plan);
    while(true){const x=api.p134e_next(cursor);if(x.$==='P134Done')break;
     tag(x,'P134Piece');assert(++pieces<=20000);write(x.text);if(x.legacy_end)write('\n');cursor=x.next}
   }else{
    const emitted=tag(api.p134e_collect(api.p144pf_emit_request(checked.request)),'P111Emission');
    assert.equal(emitted.error,'');let chunks=emitted.chunks;
    while(chunks.$==='Con'){assert(++pieces<=20000);write(chunks.head);write('\n');chunks=chunks.tail}tag(chunks,'Nil');
   }
  }finally{fs.closeSync(fd)}
  assert(bytes>0);row.qbe=pin(target);assert.equal(bytes,row.qbe.bytes);
  row.pieces=pieces;row.seconds=(performance.now()-t)/1000;row.complete=true;save();
 }
 for(const p of inputs)assert.deepEqual(pin(p.file),p);
 report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1}
finally{report.seconds=(performance.now()-start)/1000;save();console.log(JSON.stringify({complete:report.complete,variants:report.variants,error:report.error}))}
