// Checked Bend owns source preparation and selector analysis. Host transport only.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';

const here=path.dirname(import.meta.filename),root=path.resolve(here,'../../../../..');
const [apiArg,sourceArg,outArg]=process.argv.slice(2);
assert(apiArg&&sourceArg&&outArg,'Usage: inspect.mjs API_REPORT SOURCE_MANIFEST FRESH_PHASE126_OUT');
const out=path.resolve(outArg),read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase126/'),'Fresh Phase126 output required');
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=r=>{const p=pin(r.file);assert.equal(p.bytes,r.bytes,'Changed size: '+r.file);assert.equal(p.sha256,r.sha256,'Changed hash: '+r.file)};
const apiReport=read(apiArg),source=read(sourceArg),inventoryFile=path.join(here,'manifest01.json'),inventory=read(inventoryFile);
assert(apiReport.complete&&apiReport.checked&&source.complete,'Checked complete API/source required');
assert(apiReport.inputs.some(p=>p.file===source.source.file&&p.sha256===source.source.sha256),'API/source mismatch');
for(const p of inventory.modules){verify(p);assert(source.inputs.some(x=>x.sha256===p.sha256&&x.bytes===p.bytes),'Missing frozen selector module: '+p.file)}
const selectionFile=path.join(root,'selfhost/tools/native/selection.json'),selection=read(selectionFile);
verify(selection.admission);const admission=read(selection.admission.file);
assert(admission.complete&&admission.qualified,'Qualified prepared Base required');
const {base,cache}=admission.assets;
const expectationsFile=path.join(here,'inspect-expectations.json'),expectations=read(expectationsFile);
const referenceFile=path.join(here,'scene-reference-rows.json'),reference=read(referenceFile);
const ordinaryCases=read(inventory.controls.file),ordinary=ordinaryCases.cases[0];
const ray=inventory.evidence.find(p=>p.file===path.resolve(root,reference.source));assert(ray,'Missing source-bound ray reference');
const inputs=[pin(import.meta.filename),pin(process.execPath),pin(apiArg),pin(sourceArg),apiReport.api,source.source,
  ...apiReport.inputs,...source.inputs,pin(inventoryFile),...inventory.modules,inventory.controls,
  ordinary.source,ordinary.expected,ordinary.oracleExplanation,pin(expectationsFile),pin(referenceFile),ray,
  ...inventory.evidence,pin(selectionFile),selection.admission,base,cache.carrier];
inputs.forEach(verify);fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase126-request-bound-selector-inspection',complete:false,targetsRun:false,api:apiReport.api,
  source:source.source,inputs,cases:[],scope:'Actual checked request preparation and Bend selector analysis only. No host evaluation, source rewriting, IR construction, native assembly, or target execution. Ray rows are corroborated prior upstream data; ordinary rows/refusals are independent expectations.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const tag=(v,t)=>{assert.equal(v?.$,t,'Expected '+t+', got '+v?.$+': '+(v?.error??''));return v};
const numbers=v=>{const result=[];while(v?.$==='Con'){assert(Number.isInteger(v.head)&&v.head>=0&&v.head<=0xffffffff);result.push(v.head);v=v.tail}tag(v,'Nil');return result};
const start=performance.now();
try{
  const api=(await import(pathToFileURL(apiReport.api.file))).default;
  for(const name of ['p88_cache_prepare','p86_plan','p111_runtime_admission','p126s_inspect','p126s_projection_control'])assert.equal(typeof api[name],'function','Missing API '+name);
  let t=performance.now();const preparation=tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(cache.carrier.file,'utf8'),cache.stamp),'P86PreparationReady');
  report.prepareSeconds=(performance.now()-t)/1000;
  report.projection=api.p126s_projection_control();assert.equal(report.projection,'table-projection:pass');save();
  for(const item of [{name:'ordinary',source:ordinary.source,expected:expectations.rows},{name:'active-ray',source:ray,expected:reference.rawF32Bits}]){
    verify(item.source);const row={name:item.name,source:item.source,rows:[]};report.cases.push(row);save();
    t=performance.now();const request=tag(api.p86_plan(preparation.seed,item.source.file,fs.readFileSync(item.source.file,'utf8')),'P86PlanReady').request;
    row.frontendSeconds=(performance.now()-t)/1000;assert.equal(api.p111_runtime_admission(request),'');
    for(const [name,expected] of Object.entries(item.expected)){
      t=performance.now();const result=api.p126s_inspect(request,name);
      const actual=result?.$==='None'?null:numbers(tag(result,'Some').value);
      row.rows.push({name,expected,actual,seconds:(performance.now()-t)/1000,passed:false});save();
      assert.deepEqual(actual,expected,'Selector '+name);row.rows.at(-1).passed=true;save();
    }
    row.complete=true;save();console.log(JSON.stringify(row));
  }
  inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error);process.exitCode=1}
finally{report.seconds=(performance.now()-start)/1000;report.peakRss=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,error:report.error}))}
