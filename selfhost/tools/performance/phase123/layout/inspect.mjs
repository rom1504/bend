// Read-only checked-book layout queries; no emission or generated target run.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../../..');const [receiptFile,outArg]=process.argv.slice(2),out=path.resolve(outArg);
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const read=f=>JSON.parse(fs.readFileSync(f));const verify=p=>assert.deepEqual(pin(p.file),p);
assert(out.startsWith(root+'/selfhost/build/phase123/')&&!fs.existsSync(out));
const a=read(receiptFile);assert(a.complete&&a.checked);
const selectionFile=path.join(root,'selfhost/tools/native/selection.json'),s=read(selectionFile);verify(s.admission);const admission=read(s.admission.file);assert(admission.complete&&admission.qualified);const{base,cache}=admission.assets;
const manifestFile=path.join(import.meta.dirname,'cases.json'),manifest=read(manifestFile);
const frozenFile=path.join(root,'selfhost/tools/performance/phase112/benchmark45/manifest01.json');
const cases=[{...read(frozenFile).cases.find(x=>x.name==='test-rle-roundtrip'),roots:['rle','rle.step']},...manifest.cases.map((x,i)=>({...x,roots:[['advance123','unwrap123','inspect123'][i]]}))];
const inputs=[pin(import.meta.filename),pin(process.execPath),pin(receiptFile),a.api,...a.inputs,pin(selectionFile),s.admission,base,cache.carrier,pin(manifestFile),pin(frozenFile),...cases.map(x=>x.source)];inputs.forEach(verify);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));const report={complete:false,inputs,rows:[],scope:'Checked source and finite native layout admission; no emitted-program correctness or timing claim.'};const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try{
 const api=(await import(pathToFileURL(a.api.file))).default;const prep=api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(cache.carrier.file,'utf8'),cache.stamp);assert.equal(prep.$,'P86PreparationReady');
 for(const c of cases){
  const plan=api.p86_plan(prep.seed,c.source.file,fs.readFileSync(c.source.file,'utf8'));
  if(plan.$!=='P86PlanReady'){report.rows.push({name:c.name,error:plan.error});save();continue}
  for(const name of c.roots){report.rows.push({case:c.name,name,signature:api.p123l_inspect(plan.request,name),type:api.p123l_type(plan.request,name)});save()}
 }
 inputs.forEach(verify);report.complete=true;report.allSourcesChecked=report.rows.every(x=>!x.error);
}catch(error){report.error=String(error);process.exitCode=1}finally{save();console.log(JSON.stringify({complete:report.complete,allSourcesChecked:report.allSourcesChecked,queries:report.rows.length,error:report.error}))}
