// Paired checked-Bend entry experiments. This deliberately excludes preparation.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [apiPath, sourcePath, expectedPath, output, candidate='p128raw_emit_admitted'] = process.argv.slice(2);
const read=p=>JSON.parse(fs.readFileSync(p));
const pin=p=>{p=path.resolve(p);const b=fs.readFileSync(p);return{file:p,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const verify=p=>{const a=pin(p.file);if(a.sha256!==p.sha256||a.bytes!==p.bytes)throw Error('Changed '+p.file);};
const ar=read(apiPath);if(!ar.complete||!ar.checked||!ar.exports.includes(candidate))throw Error('Unchecked entry');
verify(ar.api);ar.inputs.forEach(verify);
const selection=read('selfhost/tools/native/selection.json');verify(selection.admission);
const adm=read(selection.admission.file);if(!adm.complete||!adm.qualified)throw Error('Unqualified base');
const {base,cache}=adm.assets;verify(base);verify(cache.carrier);
const api=(await import(pathToFileURL(ar.api.file))).default;
const started=performance.now();
const prep=api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(cache.carrier.file,'utf8'),cache.stamp);
if(prep.$!=='P86PreparationReady')throw Error(JSON.stringify(prep));
const plan=api.p86_plan(prep.seed,path.resolve(sourcePath),fs.readFileSync(sourcePath,'utf8'));
if(plan.$!=='P86PlanReady')throw Error(JSON.stringify(plan));
const error=api.p111_runtime_admission(plan.request);if(error!=='')throw Error(error);
const expected=fs.readFileSync(expectedPath,'utf8');
const report={complete:false,scope:'Same checked API and prepared immutable request; paired integrated compiler entry time only. Not cold native latency.',preparationAndFrontendSeconds:(performance.now()-started)/1000,
 inputs:[pin(import.meta.filename),pin(apiPath),ar.api,pin(sourcePath),pin(expectedPath),selection.admission,base,cache.carrier],rows:[]};
if(fs.existsSync(output))throw Error('Fresh report required');
const save=()=>fs.writeFileSync(output,JSON.stringify(report,null,2)+'\n');save();
for(let round=0;round<3;round++){
 const names=round%2?[candidate,'p111_emit_admitted']:['p111_emit_admitted',candidate];
 for(const entry of names){
  const t=performance.now(),e=api[entry](plan.request,'');const seconds=(performance.now()-t)/1000;
  if(e.$!=='P111Emission'||e.error!=='')throw Error(JSON.stringify(e));
  const chunks=[];let xs=e.chunks;while(xs?.$==='Con'){chunks.push(xs.head+'\n');xs=xs.tail;}
  if(xs?.$!=='Nil'||chunks.join('')!==expected)throw Error('QBE identity failure');
  report.rows.push({round,entry,seconds,exactQbe:true});save();
 }
}
report.inputs.forEach(verify);report.complete=true;save();console.log(JSON.stringify(report.rows));
