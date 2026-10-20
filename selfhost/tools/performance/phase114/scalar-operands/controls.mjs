// Root-only ordinary-source diagnostic. No fabricated IR and no native execution.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [apiArg,outArg,...extra]=process.argv.slice(2);
if(!apiArg||!outArg||extra.length)throw Error('Usage: controls.mjs CHECKED_API FRESH_PHASE114_OUT');
const here=import.meta.dirname,root=path.resolve(here,'../../../../..');
const apiFile=path.resolve(apiArg),out=path.resolve(outArg);
if(!out.startsWith(root+'/selfhost/build/phase114/')||fs.existsSync(out))throw Error('Fresh Phase114 output required');
const pin=file=>{file=path.resolve(root,file);const bytes=fs.readFileSync(file);return {file,bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex')};};
const verify=row=>{const current=pin(row.file);if(current.bytes!==row.bytes||current.sha256!==row.sha256)throw Error('Changed input '+row.file);return current;};
const list=value=>{const out=[];for(;value?.$==='Con';value=value.tail)out.push(value.head);if(value?.$!=='Nil')throw Error('Invalid Bend list');return out;};
const tagged=(value,name)=>{if(value?.$!==name)throw Error('Expected '+name+', got '+String(value?.$));return value;};
const empty=(value,label)=>{if(typeof value!=='string'||value!=='')throw Error(label+': '+String(value));};
const receiptFile=path.join(path.dirname(apiFile),'report.json'),receipt=JSON.parse(fs.readFileSync(receiptFile));
const required=['p88_cache_prepare','p86_plan','p111_runtime_admission','p113a_lower_request','p113a_verify','p114so_buffers','p114so_private_original','p113e_private','p111q_ids'];
if(!receipt.complete||!receipt.checked||!required.every(x=>receipt.exports?.includes(x)))throw Error('Complete checked API and diagnostic exports required');
if(path.resolve(receipt.api.file)!==apiFile)throw Error('API receipt mismatch');verify(receipt.api);
const manifestFile=path.join(here,'controls/manifest01.json'),manifest=JSON.parse(fs.readFileSync(manifestFile));
manifest.inputs.forEach(verify);
const selectionFile=path.join(root,'selfhost/tools/native/selection.json'),selection=JSON.parse(fs.readFileSync(selectionFile));
verify(selection.admission);
const admission=JSON.parse(fs.readFileSync(selection.admission.file));
if(!admission.complete||!admission.qualified)throw Error('Qualified immutable Base/cache assets required');
const {base,cache}=admission.assets;verify(base);verify(cache.carrier);
fs.mkdirSync(out,{recursive:true});fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase114-scalar-operands-ordinary-source-structural-controls',complete:false,requiredExports:required,cases:[],
 inputs:[pin(import.meta.filename),pin(apiFile),pin(receiptFile),pin(manifestFile),pin(selectionFile),selection.admission,base,cache.carrier,...manifest.inputs.map(verify)],
 scope:'Actual checked Bend source, unchanged runtime admission and final IR verification. Paired old/new rendering of identical admitted private function. Native complete stdout and runtime speed require separate root jobs; static store reductions are not performance measurements.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const floatOps=text=>[...text.matchAll(/ =([sw]) (add|sub|mul|div|ceqs|cnes|clts|cles|cgts|cges|uwtof)\b/g)].map(x=>x[1]+':'+x[2]);
const stores=text=>(text.match(/^storel /gm)||[]).length;
function witness(api,fn,ids,name,expectation){
 const buffers=list(api.p114so_buffers(fn.body)),before=api.p114so_private_original(fn,ids),after=api.p113e_private(fn,ids);
 if(typeof before!=='string'||typeof after!=='string')throw Error('Non-string renderer result');
 const beforePath=path.join(out,name+'-before.ssa'),afterPath=path.join(out,name+'-after.ssa');
 fs.writeFileSync(beforePath,before);fs.writeFileSync(afterPath,after);
 const row={name,actualFunction:fn.name,expectation,buffers,before:pin(beforePath),after:pin(afterPath),storesBefore:stores(before),storesAfter:stores(after),floatOpsBefore:floatOps(before),floatOpsAfter:floatOps(after),gates:{}};
 row.gates.sameFloatOperationSequence=JSON.stringify(row.floatOpsBefore)===JSON.stringify(row.floatOpsAfter);
 if(expectation==='rewrite'){
  row.gates.scratchAdmitted=buffers.includes('scratch');
  row.gates.storesRemoved=row.storesAfter<row.storesBefore;
  row.gates.floatOperationPresent=row.floatOpsBefore.length>0;
 }else{
  row.gates.scratchNotAdmitted=!buffers.includes('scratch');
  row.gates.fallbackExactlyRetained=before===after;
  row.gates.unsupportedOperationRetained=before.includes('$p111_rt_op');
 }
 row.pass=Object.values(row.gates).every(Boolean);return row;
}
try{
 const api=(await import(pathToFileURL(apiFile))).default;
 if(!required.every(x=>typeof api[x]==='function'))throw Error('Missing checked API export');
 const start=performance.now();
 const prepared=tagged(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(cache.carrier.file,'utf8'),cache.stamp),'P86PreparationReady');
 report.preparationSeconds=(performance.now()-start)/1000;
 for(const fixture of manifest.cases){
  const row={name:fixture.name,source:verify(fixture.sourcePin),expected:verify(fixture.expected),sourceChecked:false,runtimeAdmitted:false,irVerified:false,witnesses:[]};
  report.cases.push(row);save();
  const source=row.source.file,plan=tagged(api.p86_plan(prepared.seed,source,fs.readFileSync(source,'utf8')),'P86PlanReady');
  row.sourceChecked=true;row.verdict=plan.verdict;
  empty(api.p111_runtime_admission(plan.request),'runtime admission');row.runtimeAdmitted=true;
  const lowered=tagged(api.p113a_lower_request(plan.request),'P113ALowered');empty(lowered.error,'lowering');
  const program=tagged(lowered.program,'P113AProgram');empty(api.p113a_verify(program),'IR verification');row.irVerified=true;
  const direct=tagged(program.original,'P113DProgram'),functions=list(direct.functions),ids=api.p111q_ids(direct.original.program);
  row.directFunctions=functions.map(x=>x.name);
  for(const [name,expectation] of [['arithmetic','rewrite'],['convert','rewrite'],['mixed','retain']]){
   const found=functions.filter(x=>x.name==='$direct.'+name);
   if(found.length!==1)throw Error('Required actual admitted worker missing/ambiguous: '+name);
   row.witnesses.push(witness(api,found[0],ids,name,expectation));save();
  }
  row.pass=row.witnesses.every(x=>x.pass);save();
 }
 report.complete=report.cases.length===manifest.cases.length&&report.cases.every(x=>x.pass);
 report.inputs.forEach(verify);
}catch(error){report.error=String(error);process.exitCode=1;}
finally{save();}
console.log(JSON.stringify({complete:report.complete,cases:report.cases.map(x=>({name:x.name,pass:x.pass,witnesses:x.witnesses.map(y=>({name:y.name,pass:y.pass,gates:y.gates}))})),error:report.error}));
if(!report.complete)process.exitCode=1;
