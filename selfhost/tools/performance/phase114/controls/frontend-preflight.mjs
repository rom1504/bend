// Root-only checked frontend preflight: no lowering, QBE, assembler or target.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [apiArg,manifestArg,outArg,...names]=process.argv.slice(2);
if(!apiArg||!manifestArg||!outArg)throw Error('Usage: frontend-preflight.mjs CHECKED_API MANIFEST FRESH_PHASE114_OUT [CASE ...]');
const root=path.resolve(import.meta.dirname,'../../../../..'),apiFile=path.resolve(apiArg),manifestFile=path.resolve(manifestArg),out=path.resolve(outArg);
if(!out.startsWith(root+'/selfhost/build/phase114/')||fs.existsSync(out))throw Error('Fresh Phase114 output required');
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return {file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const verify=row=>{const a=pin(path.resolve(root,row.file));if(a.bytes!==row.bytes||a.sha256!==row.sha256)throw Error('Changed '+row.file);return a;};
const receiptFile=path.join(path.dirname(apiFile),'report.json'),receipt=JSON.parse(fs.readFileSync(receiptFile));
if(!receipt.complete||!receipt.checked||!['p88_cache_prepare','p86_plan'].every(x=>receipt.exports?.includes(x)))throw Error('Checked frontend API required');
if(path.resolve(receipt.api.file)!==apiFile)throw Error('API receipt mismatch');verify(receipt.api);
const manifest=JSON.parse(fs.readFileSync(manifestFile));for(const row of manifest.inputs)verify(row);
const cases=manifest.cases.filter(c=>names.length===0||names.includes(c.name));
if(cases.length===0||names.some(n=>!cases.some(c=>c.name===n)))throw Error('Unknown/empty fixture selection');
const selectionFile=path.join(root,'selfhost/tools/native/selection.json');
const selection=JSON.parse(fs.readFileSync(selectionFile));verify(selection.admission);
const admission=JSON.parse(fs.readFileSync(selection.admission.file));
if(!admission.complete||!admission.qualified)throw Error('Native source assets not admitted');
const {base,cache}=admission.assets;verify(base);verify(cache.carrier);
fs.mkdirSync(out,{recursive:true});fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase114-independent-source-frontend-preflight',complete:false,cases:[],
 inputs:[pin(import.meta.filename),pin(apiFile),pin(receiptFile),pin(manifestFile),pin(selectionFile),selection.admission,base,cache.carrier],
 scope:'Checked mature Bend frontend only. Shared immutable prepared Base seed; fresh source request per fixture. No backend lowering, generated program, target execution or performance claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try {
 const api=(await import(pathToFileURL(apiFile))).default;
 let start=performance.now();
 const prepared=api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(cache.carrier.file,'utf8'),cache.stamp);
 report.preparationSeconds=(performance.now()-start)/1000;
 if(prepared?.$!=='P86PreparationReady')throw Error('Preparation: '+String(prepared?.error));
 for(const c of cases) {
  const source=path.resolve(root,c.source),row={name:c.name,source:pin(source),sourceChecked:false};
  report.cases.push(row);start=performance.now();save();
  try {
   const result=api.p86_plan(prepared.seed,source,fs.readFileSync(source,'utf8'));
   row.resultTag=result?.$;
   if(result?.$==='P86PlanReady'){row.sourceChecked=true;row.verdict=result.verdict;}
   else row.diagnostic=result?.error??'Unexpected frontend result';
  }catch(error){row.diagnostic=String(error);}
  row.seconds=(performance.now()-start)/1000;save();console.log(JSON.stringify(row));
 }
 report.complete=report.cases.every(x=>x.sourceChecked);
 for(const input of report.inputs)verify(input);
 for(const c of report.cases)verify(c.source);
}catch(error){report.error=String(error);throw error;}
finally{save();}
if(!report.complete)process.exitCode=1;
