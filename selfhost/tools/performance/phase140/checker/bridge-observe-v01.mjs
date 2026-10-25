// Test-only orchestration. Source loading, freshening, checking and reuse execute
// in the independently checked Bend API. Graph equality observes every field.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [apiFile,outArg] = process.argv.slice(2);
const root=path.resolve(import.meta.dirname,'../../../../..');
const out=path.resolve(outArg);
assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase140/'));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=p=>assert.deepEqual(pin(p.file),p);
const apiReport=JSON.parse(fs.readFileSync(apiFile));assert(apiReport.complete&&apiReport.checked);
const source=apiReport.inputs.find(x=>x.file.endsWith('/compiler.bend'));
const sourceManifest=path.join(path.dirname(source.file),'manifest.json');
const manifest=JSON.parse(fs.readFileSync(sourceManifest));assert.deepEqual(manifest.source,source);
const carrierFile=path.join(root,'selfhost/build/phase130/base-carrier01/receipt.json');
const carrier=JSON.parse(fs.readFileSync(carrierFile));assert(carrier.complete);
const base=carrier.inputs.find(x=>x.file.endsWith('/upstream-phase66/bend2/base.bend'));assert(base);verify(base);verify(carrier.carrier);
const inputs=[pin(carrierFile),base,carrier.carrier,pin(import.meta.filename),pin(apiFile),pin(sourceManifest),apiReport.api,...apiReport.inputs,...manifest.inputs,pin(process.execPath)];
inputs.forEach(verify);fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={complete:false,kind:'phase140-prepared-base-checker-bridge',source,api:apiReport.api,inputs,rows:[],scope:'Actual checked Bend frontend/checker/reuse plus independent full object-field equality; no native qualification or performance claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
function eq(a,b){
 const todo=[[a,b]],seen=new WeakMap();let objects=0,scalars=0;
 while(todo.length){const[x,y]=todo.pop();if(Object.is(x,y)){scalars++;continue;}
  if(x===null||y===null||typeof x!=='object'||typeof y!=='object'){assert.deepEqual(x,y);scalars++;continue;}
  let ys=seen.get(x);if(ys?.has(y))continue;if(!ys){ys=new WeakSet();seen.set(x,ys)}ys.add(y);objects++;
  const kx=Object.keys(x).sort(),ky=Object.keys(y).sort();assert.deepEqual(kx,ky);for(const k of kx)todo.push([x[k],y[k]]);
 }return{objects,scalars};
}
const list=xs=>{const a=[];while(xs.$==='Con'){a.push(xs.head);xs=xs.tail}assert.equal(xs.$,'Nil');return a};
try{
 const api=(await import(pathToFileURL(apiReport.api.file))).default;
 const rows=list(api.p140cc_controls());report.finite=rows;save();assert.equal(rows.length,15);assert(rows.every(x=>x.endsWith(':pass')));
 const prep=api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(carrier.carrier.file,'utf8'),carrier.stamp);
 assert.equal(prep.$,'P86PreparationReady');const seed=prep.seed;
 const epoch='checker:'+source.sha256+';base:'+base.sha256+';carrier:'+carrier.carrier.sha256;
 const xs=items=>items.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
 const load=text=>{
  const begin=api.f_source_end(seed.source),filename='/phase140/checker.bend';
  const src=api.f_source_located({$:'FSource',name:filename,path:filename,text},begin,begin+api.p86_width(text,0)+1);
  const header=api.f_source_header(src);assert.equal(header.error,'');
  const first=api.f_prefix_complete_ready_seed(seed.source,'',api.f_prefix_graph_empty(),api.f_source_path(seed.source),api.f_source_text(seed.source),seed.book,seed.ready);
  assert.equal(first.parsed.error,'');
  const second=api.f_prefix_complete_source(src,'',header,xs([src,seed.source]),first.carrier,'/phase140');
  assert.equal(second.parsed.error,'');
  const loaded=api.f_prefix_graph_trace(second.carrier,xs([src,seed.source]),seed.fresh);
  assert.equal(loaded.trace.result.error,'');assert.equal(loaded.ready,true);return loaded;
 };
 const head='import Base\ntype Bit is Data:\n  Off{}\n  Onn{}\ndef keep() -> Bit:\n  Off{}\n';
 const suffix='def edit() -> Bit:\n  Off{}\n';
 const original=load(head+suffix);
 const acquired=api.p140cb_check(epoch,original,seed.world,{$:'P140CPEmpty'},2,{$:'Nil'});
 assert.equal(acquired.result.error,'');assert.equal(acquired.reused,false);
 assert.equal(acquired.checkpoint.$,'P140CPSaved');
 report.seedEquality=eq(acquired.result,api.check_program_diagnostic_world(original,{$:'Nil'},seed.world));
 report.saved={cut:acquired.checkpoint.cut,steps:acquired.checkpoint.steps,bound:acquired.checkpoint.bound};save();
 let cache=acquired.checkpoint;
 for(const[name,text,hit]of[
  ['noop',head+suffix,true],['body',head+suffix.replace('Off{}','Onn{}'),true],
  ['invalid-suffix',head+suffix.replace('Off{}','Bit'),true],
  ['invalid-prefix',head.replace('def keep() -> Bit:\n  Off{}','def keep() -> Bit:\n  Bit')+suffix,false],
  ['recovery',head+suffix.replace('Off{}','Onn{}'),true],
  ['header',head+suffix.replace('-> Bit','-> Data'),false]
 ]){
  const current=load(text),fresh=api.check_program_diagnostic_world(current,{$:'Nil'},seed.world);
  const got=api.p140cb_check(epoch,current,seed.world,cache,2,{$:'Nil'});
  const row={name,expectedHit:hit,actualHit:got.reused,skipped:got.skipped,reason:got.reason,error:got.result.error};report.rows.push(row);
  assert.equal(got.reused,hit);row.equality=eq(got.result,fresh);assert.equal(api.p140ce_result(got.result,fresh),true);
  if(name==='invalid-prefix')assert.equal(got.checkpoint,cache,'early failure must retain exact old checkpoint');
  row.complete=true;save();
 }
 inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e);process.exitCode=1;}finally{save();console.log(JSON.stringify({complete:report.complete,finite:report.finite,rows:report.rows,error:report.error}));}
