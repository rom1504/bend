// Read-only compiler analysis: no host semantic lowering or target execution.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [apiArg,inputArg,outArg,mode='cache']=process.argv.slice(2);
if(process.argv.length<5||process.argv.length>6||!['cache','live'].includes(mode))
  throw Error('Usage: audit.mjs CHECKED_API INPUT FRESH_PHASE113_OUT [cache|live]');
const root=path.resolve(import.meta.dirname,'../../../../..');
const apiFile=path.resolve(apiArg),source=path.resolve(inputArg),out=path.resolve(outArg);
if(!out.startsWith(root+'/selfhost/build/phase113/')||fs.existsSync(out))
  throw Error('Fresh Phase113 output required');
function pin(file) {
  file=path.resolve(file);
  const bytes=fs.readFileSync(file);
  return {file,bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex')};
}
function verify(row) {
  const got=pin(row.file);
  if(got.bytes!==row.bytes||got.sha256!==row.sha256)throw Error('Changed input '+row.file);
}
function tagged(value,tag) {
  if(value?.$!==tag)throw Error('Expected '+tag+', got '+String(value?.$));
  return value;
}
function diagnostic(value,label) {
  if(typeof value!=='string')throw Error('Non-string diagnostic '+label);
  if(value)throw Error(label+': '+value);
}
function count(values) {
  let n=0;
  while(values?.$==='Con'){n++;values=values.tail;}
  if(values?.$!=='Nil')throw Error('Invalid metadata list');
  return n;
}
const receiptFile=path.join(path.dirname(apiFile),'report.json');
const receipt=JSON.parse(fs.readFileSync(receiptFile));
const required=['p86_plan','p111_runtime_admission','p113d_lower_request',
  'p113d_verify','p113i_optimize','p113j_audit',mode==='cache'?'p88_cache_prepare':'p86_prepare'];
if(!receipt.complete||!receipt.checked||!required.every(x=>receipt.exports?.includes(x)))
  throw Error('Complete checked API with audit exports required');
verify(receipt.api);
if(path.resolve(receipt.api.file)!==apiFile)throw Error('API differs from checked receipt');
const selectionFile=path.join(root,'selfhost/tools/native/selection.json');
const selection=JSON.parse(fs.readFileSync(selectionFile));
verify(selection.admission);
const admission=JSON.parse(fs.readFileSync(selection.admission.file));
if(!admission.complete||!admission.qualified)throw Error('Native seed admission incomplete');
const {base,cache}=admission.assets;
verify(base);
if(mode==='cache')verify(cache.carrier);
const inputs=[pin(import.meta.filename),pin(apiFile),pin(receiptFile),pin(source),
  pin(selectionFile),selection.admission,base,...(mode==='cache'?[cache.carrier]:[]),pin(process.execPath)];
fs.mkdirSync(out,{recursive:true});
fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase113-checked-direct-inlining-audit',complete:false,mode,inputs,
  requiredExports:required,stages:[],sourceChecked:false,runtimeAdmitted:false,
  scope:'Checked frontend and runtime admission, Bend before/after IR verification and audit text. No QBE build, native execution, performance qualification, or host semantic transformation.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
async function stage(name,action) {
  const row={name,status:'running'};report.stages.push(row);save();
  const started=performance.now();
  try {const result=await action();row.status='complete';return result;}
  catch(error){row.status='failed';row.error=String(error);throw error;}
  finally{row.seconds=(performance.now()-started)/1000;save();console.log(JSON.stringify(row));}
}
save();
try {
  const api=await stage('api-import',async()=>(await import(pathToFileURL(apiFile))).default);
  const prepared=await stage('preparation',()=>{
    const baseText=fs.readFileSync(base.file,'utf8');
    const value=mode==='cache'
      ?api.p88_cache_prepare(base.file,baseText,fs.readFileSync(cache.carrier.file,'utf8'),cache.stamp)
      :api.p86_prepare(base.file,baseText);
    if(value?.$==='P86PreparationError')throw Error(value.error);
    return tagged(value,'P86PreparationReady');
  });
  const plan=await stage('frontend',()=>{
    const value=api.p86_plan(prepared.seed,source,fs.readFileSync(source,'utf8'));
    if(value?.$==='P86PlanError')throw Error(value.error);
    tagged(value,'P86PlanReady');tagged(value.request,'NR_Request');
    report.sourceChecked=true;report.verdict=value.verdict;
    return value;
  });
  await stage('runtime-admission',()=>{
    diagnostic(api.p111_runtime_admission(plan.request),'runtime admission');
    report.runtimeAdmitted=true;
  });
  const rawEntry=['p113pl_lower_request','p113i_scalar_lower_request'].find(
    name=>receipt.exports.includes(name)&&typeof api[name]==='function');
  report.loweringEntry=rawEntry??'p113d_lower_request';
  report.beforeInliningAvailable=Boolean(rawEntry);
  report.beforeScope=rawEntry?'Unoptimized direct lowerer output':'Public entry output; may already include inlining';
  const before=await stage('lower-before',()=>{
    const value=tagged(api[report.loweringEntry](plan.request),'P113DLowered');
    diagnostic(value.error,'lowering');return tagged(value.program,'P113DProgram');
  });
  await stage('verify-before',()=>diagnostic(api.p113d_verify(before),'before IR'));
  const after=await stage('optimize',()=>tagged(api.p113i_optimize(before),'P113DProgram'));
  await stage('verify-after',()=>diagnostic(api.p113d_verify(after),'after IR'));
  await stage('write-audits',()=>{
    report.functionCounts={before:count(before.functions),after:count(after.functions)};
    report.outputs=[];
    for(const [name,program] of [['before',before],['after',after]]) {
      const text=api.p113j_audit(program);
      if(typeof text!=='string')throw Error('Non-string audit');
      const file=path.join(out,name+'.txt');
      fs.writeFileSync(file,text,{flag:'wx'});report.outputs.push(pin(file));
    }
  });
  for(const row of inputs)verify(row);
  report.complete=true;
}catch(error){report.error=String(error);process.exitCode=1;}
finally{save();}
