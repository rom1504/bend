// Checked hosted oracle for a native revision request. No host compiler logic.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../../..');
const argv=process.argv.slice(2);assert.equal(argv.length,5);
const [apiFile,manifestFile,logicalArg,physicalArg,outArg]=argv.map(x=>path.resolve(x));
const logicalPath=logicalArg,out=outArg;
assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase144/'));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const read=f=>JSON.parse(fs.readFileSync(f,'utf8'));
const ar=read(apiFile),manifest=read(manifestFile);
assert(ar.complete&&ar.checked&&ar.status===0&&manifest.complete);
assert(ar.inputs.some(p=>p.file===manifest.source.file&&p.sha256===manifest.source.sha256&&p.bytes===manifest.source.bytes));
for(const name of ['p88_cache_prepare','p86_plan','p134e_plan','p134e_begin','p134e_next'])assert(ar.exports.includes(name));
const priorFile=path.join(root,'selfhost/build/phase144/final04-small-products01/report.json');
const prior=read(priorFile);assert(prior.complete);
assert(prior.inputs.some(p=>p.file===path.resolve(apiFile)&&p.sha256===pin(apiFile).sha256));
assert(prior.inputs.some(p=>p.file===manifest.source.file&&p.sha256===manifest.source.sha256));
const a=prior.cases.find(c=>c.name==='lexer');assert(a&&a.verified&&a.source.file===logicalPath);
assert.equal(physicalArg,path.join(root,'selfhost/build/phase140/session-screen03/lexer-b.bend'));
const seedFile=path.join(root,'selfhost/build/phase143/integrated-hosted-lexer01/input.json'),seed=read(seedFile);
const source=pin(physicalArg),logicalSource=pin(logicalPath);
assert.deepEqual(logicalSource,a.source);assert.notEqual(source.sha256,logicalSource.sha256);
const inputs=[pin(import.meta.filename),pin(process.execPath),pin(apiFile),ar.api,...ar.inputs,
 pin(manifestFile),manifest.source,pin(priorFile),a.source,a.qbe,prior.runtime,pin(seedFile),seed.base,seed.carrier,source];
for(const p of inputs)assert.deepEqual(pin(p.file),p);
fs.mkdirSync(out);
const report={kind:'phase144-hosted-revision-oracle',complete:false,inputs,
 compilerSource:manifest.source,checkedApi:pin(apiFile),api:ar.api,runtime:prior.runtime,
 request:{logicalPath,logicalSource,source},priorEmission:pin(priorFile),
 runtimeRole:'Historical A-emission native link context only. Hosted emission neither links nor executes this runtime; native smoke must bind its own actual runtime.',
 scope:'Fresh checked hosted emission of B source bytes at the same logical A path. Exact source/API identity; sealed Bend cursor with unchanged final verifier. QBE oracle for native differential smoke; no generated-program execution or native qualification.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const started=performance.now();save();
try{
 const api=(await import(pathToFileURL(ar.api.file))).default;
 const prep=api.p88_cache_prepare(seed.base.file,fs.readFileSync(seed.base.file,'utf8'),fs.readFileSync(seed.carrier.file,'utf8'),seed.stamp);
 assert.equal(prep.$,'P86PreparationReady');
 const plan=api.p86_plan(prep.seed,logicalPath,fs.readFileSync(source.file,'utf8'));
 assert.equal(plan.$,'P86PlanReady');
 const emitted=api.p134e_plan(plan);assert.equal(emitted.$,'P134Planned');
 let cursor=api.p134e_begin(emitted.plan),pieces=0,bytes=0;
 const file=path.join(out,'program.ssa'),fd=fs.openSync(file,'wx');
 try{while(true){const next=api.p134e_next(cursor);if(next.$==='P134Done')break;
  assert.equal(next.$,'P134Piece');assert.equal(typeof next.text,'string');assert.equal(typeof next.legacy_end,'boolean');
  assert(++pieces<=20000);bytes+=Buffer.byteLength(next.text)+(next.legacy_end?1:0);assert(bytes<=32*1024*1024);
  fs.writeSync(fd,next.text);if(next.legacy_end)fs.writeSync(fd,'\n');cursor=next.next;
 }}finally{fs.closeSync(fd);}
 report.qbe=pin(file);report.pieces=pieces;report.verified=true;
 assert(bytes===report.qbe.bytes&&bytes>0);
 for(const p of inputs)assert.deepEqual(pin(p.file),p);
 report.complete=true;
}catch(error){report.error=String(error.stack||error);process.exitCode=1;}
finally{report.seconds=(performance.now()-started)/1000;save();console.log(JSON.stringify({complete:report.complete,request:report.request,qbe:report.qbe,error:report.error}));}
