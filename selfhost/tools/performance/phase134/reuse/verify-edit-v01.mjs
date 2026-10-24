// Whole request comparison; compiler decisions and verification remain in Bend.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../../..');
const [apiFile,referenceFile,outArg]=process.argv.slice(2),out=path.resolve(outArg);
assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase134/'));
const read=f=>JSON.parse(fs.readFileSync(f));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const digest=s=>({bytes:Buffer.byteLength(s),sha256:crypto.createHash('sha256').update(s).digest('hex')});
const inputs=new Map(),add=p=>{assert.deepEqual(pin(p.file),p);inputs.set(p.file,p);return p},file=f=>add(pin(f));
const ar=read(apiFile),reference=read(referenceFile);file(apiFile);file(referenceFile);file(import.meta.filename);file(process.execPath);assert(ar.checked&&ar.complete&&reference.complete);ar.inputs.forEach(add);add(ar.api);
const selectedFile=path.join(root,'implementation/phase131/final/candidate.json'),selected=read(selectedFile);file(selectedFile);assert(selected.nativeQualified);assert.deepEqual(selected.source,reference.source);
add(selected.preferredCarrierReceipt);add(selected.preferredCarrier);const compact=read(selected.preferredCarrierReceipt.file);compact.inputs.forEach(add);const base=compact.inputs.find(x=>x.file.endsWith('/bend2/base.bend'));assert(base);
const lexer=reference.cases.find(c=>c.name==='lexer');assert(lexer);add(lexer.source);add(lexer.expectedQbe);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase134-verification-reuse-real-edit',complete:false,rows:[],scope:'Within-request reuse of exact unchanged verified functions; no cross-revision cache. Existing fresh pipeline is independent reference; final verifier unchanged. Hosted diagnostic observations, not native performance qualification.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
const tag=(v,n)=>{assert.equal(v?.$,n);return v};
const text=e=>{tag(e,'P111Emission');assert.equal(e.error,'');let p=e.chunks,a=[];while(p?.$==='Con'){a.push(p.head+'\n');p=p.tail}tag(p,'Nil');return a.join('')};
const timed=f=>{const s=performance.now(),result=f();return{result,seconds:(performance.now()-s)/1000}};
const begin=performance.now();
try{
 const api=(await import(pathToFileURL(ar.api.file))).default;
 const prep=tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(selected.preferredCarrier.file,'utf8'),selected.preferredStamp),'P86PreparationReady');
 const original=fs.readFileSync(lexer.source.file,'utf8'),needle='U32.shln(x, 13n)';assert.equal(original.split(needle).length,2);const edited=original.replace(needle,'U32.shln(x, 12n)');
 const editFile=path.join(out,'lexer-edited.bend');fs.writeFileSync(editFile,edited);file(editFile);
 const req0=tag(api.p86_plan(prep.seed,lexer.source.file,original),'P86PlanReady').request;
 assert.equal(api.p111_runtime_admission(req0),'');const old=text(api.p111_emit_admitted(req0,''));assert.equal(old,fs.readFileSync(lexer.expectedQbe.file,'utf8'));report.oldFrozenIdentity=digest(old);save();
 const req=tag(api.p86_plan(prep.seed,lexer.source.file,edited),'P86PlanReady').request;assert.equal(api.p111_runtime_admission(req),'');
 for(let round=0;round<2;round++){
  let before,after;if(round){after=timed(()=>api.p134v_emit(req,''));before=timed(()=>api.p111_emit_admitted(req,''));}
  else{before=timed(()=>api.p111_emit_admitted(req,''));after=timed(()=>api.p134v_emit(req,''));}
  const expected=text(before.result),actual=text(after.result);assert.equal(actual,expected);assert.notEqual(actual,old);
  report.rows.push({round,order:round?'reuse/fresh':'fresh/reuse',freshSeconds:before.seconds,reuseSeconds:after.seconds,wholeOutputEquality:true,editedOutput:digest(actual)});save();
 }
 for(const p of inputs.values())add(p);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}finally{report.seconds=(performance.now()-begin)/1000;report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,rows:report.rows,error:report.error}));}
