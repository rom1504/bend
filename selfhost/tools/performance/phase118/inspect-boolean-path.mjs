// Exact Bend data transport only. No optimization, IR rewriting, or text parsing.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';

const root=path.resolve(import.meta.dirname,'../../../..');
const [apiArg,sourceArg,outArg,caseName,...names]=process.argv.slice(2);
if(!apiArg||!sourceArg||!outArg||!caseName||!names.length)
  throw Error('API_REPORT SOURCE_MANIFEST FRESH_OUT CASE FUNCTION [FUNCTION ...] required');
const out=path.resolve(outArg);
if(fs.existsSync(out)||!out.startsWith(root+'/selfhost/build/phase118/'))
  throw Error('Fresh Phase118 output required');
const read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
const pin=p=>{const file=path.resolve(p),b=fs.readFileSync(file);return {file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=r=>{const p=pin(r.file);if(p.bytes!==r.bytes||p.sha256!==r.sha256)throw Error('Changed input '+r.file)};
const tag=(x,t)=>{if(x?.$!==t)throw Error('Expected '+t+'; got '+x?.$+': '+(x?.error??''));return x};
const good=e=>{if(typeof e!=='string'||e)throw Error('Bend diagnostic '+e)};
const apiReport=read(apiArg),source=read(sourceArg);
if(!apiReport.complete||!apiReport.checked||!source.complete||
   !apiReport.inputs.some(r=>r.file===source.source.file&&r.sha256===source.source.sha256))
  throw Error('Checked API/source identity required');
const manifestFile=process.env.P118_CASE_MANIFEST?path.resolve(process.env.P118_CASE_MANIFEST):
  path.join(root,'selfhost/tools/performance/phase112/benchmark45/manifest01.json');
const manifest=read(manifestFile),fixture=manifest.cases.find(c=>c.name===caseName);
if(!fixture)throw Error('Unknown fixture '+caseName);
const selectionFile=path.join(root,'selfhost/tools/native/selection.json');
const selection=read(selectionFile);verify(selection.admission);
const admission=read(selection.admission.file);
if(!admission.complete||!admission.qualified)throw Error('Unqualified prepared Base');
const {base,cache}=admission.assets;
const inputs=[pin(import.meta.filename),pin(apiArg),pin(sourceArg),apiReport.api,source.source,
  ...source.inputs,pin(manifestFile),fixture.source,fixture.expectedStdoutEvidence,
  pin(selectionFile),selection.admission,base,cache.carrier,pin(process.execPath)];
for(const r of inputs)verify(r);
fs.mkdirSync(out);
fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase118-exact-structured-IR-inspection',complete:false,inputs,
  case:caseName,functionNames:names,source:source.source,api:apiReport.api,stages:{},
  scope:'Selected exact post-lowering P113DFunction data; checked Bend performs selection and verification. Host only serializes the returned value. No target execution.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();const started=performance.now();
try{
  const api=(await import(pathToFileURL(apiReport.api.file))).default;
  if(typeof api.p118bp_request!=='function')throw Error('Missing checked inspection export');
  let t=performance.now();
  const prep=tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),
    fs.readFileSync(cache.carrier.file,'utf8'),cache.stamp),'P86PreparationReady');
  report.stages.prepareSeconds=(performance.now()-t)/1000;
  t=performance.now();
  const request=tag(api.p86_plan(prep.seed,fixture.source.file,
    fs.readFileSync(fixture.source.file,'utf8')),'P86PlanReady').request;
  report.stages.frontendSeconds=(performance.now()-t)/1000;
  good(api.p111_runtime_admission(request));
  let bendNames={$:'Nil'};
  for(let i=names.length-1;i>=0;i--)bendNames={$:'Con',head:names[i],tail:bendNames};
  t=performance.now();
  const exact=tag(api.p118bp_request(request,bendNames),'P118BPInspection');
  good(exact.error);
  report.stages.inspectionSeconds=(performance.now()-t)/1000;
  const outputFile=path.join(out,'functions.json');
  fs.writeFileSync(outputFile,JSON.stringify(exact,null,2)+'\n');
  report.output=pin(outputFile);
  for(const r of inputs)verify(r);
  report.complete=true;
}catch(e){report.error=String(e);process.exitCode=1}
finally{
  report.seconds=(performance.now()-started)/1000;
  report.peakRss=process.resourceUsage().maxRSS*1024;
  save();console.log(JSON.stringify({complete:report.complete,case:caseName,output:report.output,error:report.error}));
}
