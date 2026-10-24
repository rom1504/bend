// Independent byte bridge: Bend provides complete payload/boundary views;
// host writes the narrow wire format, never parses or transforms QBE semantics.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import assert from 'node:assert/strict';import{pathToFileURL}from'node:url';
const root=path.resolve(import.meta.dirname,'../../../../..'),[apiArg,outArg]=process.argv.slice(2),out=path.resolve(outArg);assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase135/'));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};const read=f=>JSON.parse(fs.readFileSync(f));const inputs=new Map(),add=p=>{assert.deepEqual(pin(p.file),p);inputs.set(p.file,p);return p},file=f=>add(pin(f));
const ar=read(apiArg),refFile=root+'/selfhost/build/phase134/reference03.json',ref=read(refFile),selectedFile=root+'/implementation/phase131/final/candidate.json',selected=read(selectedFile);file(apiArg);file(refFile);file(selectedFile);file(import.meta.filename);file(process.execPath);assert(ar.complete&&ar.checked);ar.inputs.forEach(add);add(ar.api);add(selected.preferredCarrierReceipt);add(selected.preferredCarrier);const cr=read(selected.preferredCarrierReceipt.file);cr.inputs.forEach(add);const base=cr.inputs.find(x=>x.file.endsWith('/bend2/base.bend'));assert(base);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');let r={complete:false,rows:[],scope:'Checked Bend frame-view payload equals independent frozen native QBE. Host serializes the documented byte framing for cheap machine falsification; actual Bend IO frame writer requires native checks.'};const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify({...r,inputs:[...inputs.values()]},null,2)+'\n');save();
try{
 const api=(await import(pathToFileURL(ar.api.file))).default;const probe=api.p135m_next({$:'P134Main'});assert.equal(probe.$,'P135MFrame');assert.equal(probe.family,2);assert.equal(typeof probe.complete,'boolean');assert.equal(typeof probe.legacy_end,'boolean');assert.equal(probe.complete,true);assert.equal(probe.legacy_end,true);r.protocolShapeProbe=true;save();const prep=api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(selected.preferredCarrier.file,'utf8'),selected.preferredStamp);assert.equal(prep.$,'P86PreparationReady');
 for(const c of ref.cases){
  add(c.source);add(c.expectedQbe);const started=performance.now(),plan=api.p86_plan(prep.seed,c.source.file,fs.readFileSync(c.source.file,'utf8'));assert.equal(plan.$,'P86PlanReady',plan.error);const e=api.p134u_request(plan.request,api.p111_runtime_admission(plan.request),{$:'P134UCache',inline:{$:'Nil'},ranges:{$:'Nil'}});assert.equal(e.$,'P134UEmission');assert.equal(e.emission.$,'P134Planned');let cursor=api.p134e_begin(e.emission.plan);
  const dest=out+'/'+c.name+'.frames',fd=fs.openSync(dest,'wx'),hash=crypto.createHash('sha256');let size=0,frames=0,kind=3,unit=0,count=0,units=0,maxPiece=0;
  const header=(verb,k,u)=>fs.writeSync(fd,`# P135/1 ${verb} ${k} ${u}\n`);
  try{while(true){const f=api.p135m_next(cursor);if(f.$==='P135MDone')break;assert.equal(f.$,'P135MFrame');assert([0,1,2].includes(f.family));assert.equal(typeof f.complete,'boolean');assert.equal(typeof f.legacy_end,'boolean');const complete=f.complete,ending=f.legacy_end;
    if(f.family!==kind||(f.family===0&&count>=1000)){if(kind!==3){header('END',kind,unit);unit++}kind=f.family;count=0;header('BEGIN',kind,unit);units++}
    const b=Buffer.from(f.text+(ending?'\n':''),'utf8');hash.update(b);size+=b.length;maxPiece=Math.max(maxPiece,b.length);fs.writeSync(fd,b);count+=Number(complete);cursor=f.next;frames++;assert(frames<100000)
   }if(kind!==3)header('END',kind,unit);fs.writeSync(fd,`# P135/1 DONE ${units}\n`)
  }finally{fs.closeSync(fd)}
  const digest={bytes:size,sha256:hash.digest('hex')};assert.deepEqual(digest,{bytes:c.expectedQbe.bytes,sha256:c.expectedQbe.sha256});r.rows.push({name:c.name,source:c.source,expectedQbe:c.expectedQbe,frames,units,maximumPieceBytes:maxPiece,payload:digest,framed:pin(dest),exact:true,seconds:(performance.now()-started)/1000});save()
 }
 for(const p of inputs.values())add(p);r.complete=true
}catch(e){r.error=String(e.stack||e);process.exitCode=1}finally{save();console.log(JSON.stringify(r))}
