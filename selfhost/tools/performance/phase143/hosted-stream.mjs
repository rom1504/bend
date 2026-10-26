// Byte observer only. All compiler operations execute the exact checked Bend API.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [inputFile]=process.argv.slice(2);
assert(inputFile,'Authenticated launcher input required');
const input=JSON.parse(fs.readFileSync(inputFile,'utf8'));
const report={kind:'phase143-hosted-stream-stages',complete:false,timings:{},pieces:0,legacyEnds:0,maxPieceBytes:0,bytes:0,
 scope:'Ordinary cold checked Bend API: prepared Base, complete frontend, complete admitted backend, emission registry and cursor rendering. No incremental-session cache. Output encoding, writing and hashing are separately timed.'};
const started=performance.now(),seconds=()=>performance.now()/1000;
const save=()=>fs.writeFileSync(input.stages,JSON.stringify(report,null,2)+'\n');
const measure=(name,f)=>{const t=seconds(),value=f();report.timings[name]=(report.timings[name]||0)+seconds()-t;return value;};
const tag=(v,name)=>{assert.equal(v?.$,name,`Expected ${name}, got ${v?.$}; ${v?.error||''}`);return v;};
const digest=crypto.createHash('sha256'),lf=Buffer.from('\n');
let fd;
function emit(buffer){
 assert(buffer.length<=64*1024*1024,'One cursor piece exceeds 64 MiB bound');
 report.bytes+=buffer.length;assert(report.bytes<=512*1024*1024,'Output exceeds 512 MiB bound');
 measure('outputWriteSeconds',()=>{let at=0;while(at<buffer.length){const n=fs.writeSync(fd,buffer,at,buffer.length-at);assert(n>0,'Short output write');at+=n;}});
 measure('outputDigestSeconds',()=>digest.update(buffer));
}
try{
 const importStart=seconds();
 const api=(await import(pathToFileURL(input.api.file))).default;
 report.timings.apiImportSeconds=seconds()-importStart;
 const texts=measure('sourceBaseCarrierReadSeconds',()=>({source:fs.readFileSync(input.source.file,'utf8'),base:fs.readFileSync(input.base.file,'utf8'),carrier:fs.readFileSync(input.carrier.file,'utf8')}));
 const preparation=measure('basePreparationSeconds',()=>tag(api.p88_cache_prepare(input.base.file,texts.base,texts.carrier,input.stamp),'P86PreparationReady'));
 save();
 const plan=measure('frontendSeconds',()=>tag(api.p86_plan(preparation.seed,input.source.file,texts.source),'P86PlanReady'));
 save();
 const emission=measure('backendInclusiveSeconds',()=>tag(api.p134e_plan(plan),'P134Planned'));
 save();
 let cursor=measure('registrySeconds',()=>api.p134e_begin(emission.plan));
 fd=measure('outputOpenSeconds',()=>fs.openSync(input.output,'wx'));
 const renderStarted=seconds();
 while(true){
  const step=measure('bendCursorRenderingSeconds',()=>api.p134e_next(cursor));
  if(step.$==='P134Done')break;
  tag(step,'P134Piece');assert.equal(typeof step.text,'string');assert.equal(typeof step.legacy_end,'boolean');
  assert(++report.pieces<=2000000,'Cursor exceeds bounded piece count');
  const buffer=measure('outputUTF8EncodingSeconds',()=>Buffer.from(step.text,'utf8'));
  report.maxPieceBytes=Math.max(report.maxPieceBytes,buffer.length);
  emit(buffer);
  if(step.legacy_end){emit(lf);report.legacyEnds++;}
  cursor=step.next;
 }
 report.timings.renderLoopInclusiveSeconds=seconds()-renderStarted;
 measure('outputCloseSeconds',()=>fs.closeSync(fd));fd=undefined;
 report.sha256=measure('outputDigestFinalizeSeconds',()=>digest.digest('hex'));
 assert.equal(report.bytes,input.expected.bytes,'Expected output byte count');
 assert.equal(report.sha256,input.expected.sha256,'Expected output digest');
 report.exactExpectedBytes=true;
 report.compilerStageSeconds=['basePreparationSeconds','frontendSeconds','backendInclusiveSeconds','registrySeconds','bendCursorRenderingSeconds'].reduce((n,k)=>n+(report.timings[k]||0),0);
 report.renderLoopObserverResidualSeconds=report.timings.renderLoopInclusiveSeconds-['bendCursorRenderingSeconds','outputUTF8EncodingSeconds','outputWriteSeconds','outputDigestSeconds'].reduce((n,k)=>n+(report.timings[k]||0),0);
 report.complete=true;
}catch(error){report.error=String(error.stack||error);process.exitCode=1;}
finally{
 if(fd!==undefined)fs.closeSync(fd);
 report.observerSeconds=(performance.now()-started)/1000;
 report.peakRssBytes=process.resourceUsage().maxRSS*1024;
 save();console.log(JSON.stringify({complete:report.complete,seconds:report.observerSeconds,bytes:report.bytes,error:report.error}));
}
