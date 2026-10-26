// Actual checked Bend sealed cursor. Host code transports bytes, not QBE semantics.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../../../..');
const [apiFile,casesFile,outArg]=process.argv.slice(2),out=path.resolve(outArg);
assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase144/'));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const read=f=>JSON.parse(fs.readFileSync(f,'utf8'));
const ar=read(apiFile),cases=read(casesFile).cases;
assert(ar.complete&&ar.checked&&ar.status===0&&cases.length>0&&cases.length<=4);
const seedFile=path.join(root,'selfhost/build/phase143/integrated-hosted-lexer01/input.json'),seed=read(seedFile);
const selected=read(path.join(root,'implementation/phase143/candidate.json'));
const inputs=[pin(import.meta.filename),pin(process.execPath),pin(apiFile),ar.api,...ar.inputs,pin(casesFile),pin(seedFile),seed.base,seed.carrier,selected.runtime];
for(const c of cases)inputs.push(c.source,c.expectedStdoutEvidence,c.stdoutEvidence);
inputs.forEach(p=>assert.deepEqual(pin(p.file),p));fs.mkdirSync(out);
const report={kind:'phase144-append-ordinary-cursor-emission',complete:false,inputs,runtime:selected.runtime,cases:[],scope:'Ordinary checked source to sealed Bend cursor, with unchanged complete verifier. No alternative lowering or generated-byte rewriting.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const start=performance.now();save();
try{
 const api=(await import(pathToFileURL(ar.api.file))).default;
 const prep=api.p88_cache_prepare(seed.base.file,fs.readFileSync(seed.base.file,'utf8'),fs.readFileSync(seed.carrier.file,'utf8'),seed.stamp);
 assert.equal(prep.$,'P86PreparationReady');
 for(const c of cases){
  const t=performance.now(),row={name:c.name,source:c.source,expected:c.stdoutEvidence};report.cases.push(row);save();
  const plan=api.p86_plan(prep.seed,c.source.file,fs.readFileSync(c.source.file,'utf8'));assert.equal(plan.$,'P86PlanReady');
  const emitted=api.p134e_plan(plan);assert.equal(emitted.$,'P134Planned');
  let cursor=api.p134e_begin(emitted.plan),pieces=0,bytes=0;
  const file=path.join(out,c.name+'.ssa'),fd=fs.openSync(file,'wx');
  try{while(true){const x=api.p134e_next(cursor);if(x.$==='P134Done')break;
    assert.equal(x.$,'P134Piece');assert.equal(typeof x.text,'string');assert.equal(typeof x.legacy_end,'boolean');
    assert(++pieces<=20000);bytes+=Buffer.byteLength(x.text)+(x.legacy_end?1:0);assert(bytes<=32*1024*1024);
    fs.writeSync(fd,x.text);if(x.legacy_end)fs.writeSync(fd,'\n');cursor=x.next;
  }}finally{fs.closeSync(fd)}
  row.qbe=pin(file);row.pieces=pieces;row.seconds=(performance.now()-t)/1000;row.verified=true;assert(bytes===row.qbe.bytes&&bytes>0);save();
 }
 inputs.forEach(p=>assert.deepEqual(pin(p.file),p));report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}
finally{report.seconds=(performance.now()-start)/1000;save();console.log(JSON.stringify({complete:report.complete,cases:report.cases.map(c=>({name:c.name,qbe:c.qbe})),error:report.error}));}
