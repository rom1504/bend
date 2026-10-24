// Metadata and byte transport only. Checked Bend owns every compiler operation.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../../..');
const [apiFile,referenceFile,outFile,group='cases']=process.argv.slice(2);
assert(['cases','wrappers'].includes(group));
const out=path.resolve(outFile);assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase134/'));
const read=f=>JSON.parse(fs.readFileSync(f));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=p=>assert.deepEqual(pin(p.file),p);
const ar=read(apiFile),reference=read(referenceFile),selectedFile=path.join(root,'implementation/phase131/final/candidate.json'),selected=read(selectedFile);
assert(ar.complete&&ar.checked&&reference.complete&&selected.nativeQualified);
assert.deepEqual(reference.source,selected.source);
const carrierReceipt=read(selected.preferredCarrierReceipt.file);
const base=carrierReceipt.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));assert(base);
const source=ar.inputs.find(p=>p.file.endsWith('/compiler.bend'));assert(source);
const inputs=[pin(import.meta.filename),pin(process.execPath),pin(apiFile),...ar.inputs,ar.api,pin(referenceFile),...reference.inputs,
 pin(selectedFile),selected.preferredCarrierReceipt,selected.preferredCarrier,base,
 ...reference[group].flatMap(c=>[c.source,c.expectedQbe])];inputs.forEach(verify);
const required=['p88_cache_prepare','p86_plan','p111_runtime_admission','p111_emit_admitted','p134e_compile_source','p134e_begin','p134e_next'];
for(const n of required)assert(ar.exports.includes(n));
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase134-hosted-emission-byte-differential',complete:false,group,inputs,source,cases:[],
 scope:'Checked pure API and (three-case group only) deferred Bend cursor compared byte-for-byte with independently qualified Phase131 native products. No native candidate execution or timing claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const tag=(v,name)=>{assert.equal(v?.$,name);return v};
const chunks=v=>{const a=[];while(v?.$==='Con'){assert.equal(typeof v.head,'string');a.push(v.head+'\n');v=v.tail}tag(v,'Nil');return a.join('')};
const start=performance.now();
try{
 const api=(await import(pathToFileURL(ar.api.file))).default;
 const baseText=fs.readFileSync(base.file,'utf8'),carrierText=fs.readFileSync(selected.preferredCarrier.file,'utf8');
 const prep=tag(api.p88_cache_prepare(base.file,baseText,carrierText,selected.preferredStamp),'P86PreparationReady');
 for(const c of reference[group]){
  const row={name:c.name,source:c.source,expected:c.expectedQbe};report.cases.push(row);save();
  const text=fs.readFileSync(c.source.file,'utf8');const t=performance.now();
  const req=tag(api.p86_plan(prep.seed,c.source.file,text),'P86PlanReady').request;
  assert.equal(api.p111_runtime_admission(req),'');
  const pure=tag(api.p111_emit_admitted(req,''),'P111Emission');assert.equal(pure.error,'');
  const output=chunks(pure.chunks);assert.equal(output,fs.readFileSync(c.expectedQbe.file,'utf8'));
  row.pureSeconds=(performance.now()-t)/1000;
  const dest=path.join(out,c.name+'.ssa');fs.writeFileSync(dest,output);row.actual=pin(dest);row.exactNativeReference=true;
  if(group==='cases'){
   const plan=tag(api.p134e_compile_source(c.source.file,text,base.file,baseText,carrierText,selected.preferredStamp,true),'P134Planned');
   let cursor=api.p134e_begin(plan.plan),at=0,pieces=0,maxPieceBytes=0,ends=0;
   while(true){const step=api.p134e_next(cursor);if(step.$==='P134Done')break;tag(step,'P134Piece');assert.equal(typeof step.text,'string');
    assert.equal(output.slice(at,at+step.text.length),step.text);at+=step.text.length;pieces++;maxPieceBytes=Math.max(maxPieceBytes,Buffer.byteLength(step.text));
    assert.equal(typeof step.legacy_end,'boolean');if(step.legacy_end){assert.equal(output[at],'\n');at++;ends++}cursor=step.next;}
   assert.equal(at,output.length);row.cursor={exact:true,pieces,maxPieceBytes,legacyEnds:ends};
  }
  row.complete=true;save();console.log(JSON.stringify(row));
 }
 inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e);process.exitCode=1}
finally{report.seconds=(performance.now()-start)/1000;report.peakRssBytes=process.resourceUsage().maxRSS*1024;save()}
