// Measurement transport only. Both lowerers receive the same checked Bend request.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseFile,candidateFile,outArg,...sourceArgs]=process.argv.slice(2);
if(!sourceArgs.length) throw Error('BASE_API CANDIDATE_API FRESH_OUT SOURCE...');
const root=path.resolve(import.meta.dirname,'../../../..'),out=path.resolve(outArg);
if(fs.existsSync(out)||!out.startsWith(root+'/selfhost/build/phase112/')) throw Error('Fresh Phase112 directory required');
fs.mkdirSync(out,{recursive:true});
const pin=file=>({file:path.resolve(file),bytes:fs.statSync(file).size,sha256:crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const verify=row=>{const got=pin(row.file);if(got.bytes!==row.bytes||got.sha256!==row.sha256)throw Error('Input changed '+row.file);};
async function load(file){
  const receipt=JSON.parse(fs.readFileSync(path.join(path.dirname(file),'report.json')));
  if(!receipt.complete||!receipt.checked)throw Error('Unchecked API');verify(receipt.api);
  return (await import(pathToFileURL(path.resolve(file)))).default;
}
const apis={baseline:await load(baseFile),candidate:await load(candidateFile)};
const assets=JSON.parse(fs.readFileSync(path.join(root,'selfhost/tools/performance/phase111/native-assets01.json')));
verify(assets.base);verify(assets.cache.carrier);
const inputPins=[pin(import.meta.filename),pin(baseFile),pin(candidateFile),...sourceArgs.map(pin),assets.base,assets.cache.carrier];
const report={kind:'phase112-paired-lowering',complete:false,inputs:inputPins,rows:[],scope:'Hosted Bend lowering on the same checked request. Warm in-process alternating measurements, not native compiler latency.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const prepared=apis.baseline.p88_cache_prepare(assets.base.file,fs.readFileSync(assets.base.file,'utf8'),fs.readFileSync(assets.cache.carrier.file,'utf8'),assets.cache.stamp);
if(prepared.$!=='P86PreparationReady')throw Error(prepared.error);
function product(api,program){
  const error=api.p111_verify_program(program);if(error)throw Error(error);
  let chunks=api.p111q_chunks(program),hash=crypto.createHash('sha256'),bytes=0;
  while(chunks.$==='Con'){const raw=Buffer.from(chunks.head+'\n');hash.update(raw);bytes+=raw.length;chunks=chunks.tail;}
  if(chunks.$!=='Nil')throw Error('Malformed chunks');return{sha256:hash.digest('hex'),bytes};
}
try{
  for(const sourceArg of sourceArgs){
    const source=path.resolve(sourceArg),plan=apis.baseline.p86_plan(prepared.seed,source,fs.readFileSync(source,'utf8'));
    if(plan.$!=='P86PlanReady')throw Error(plan.error);
    for(const api of Object.values(apis)){const error=api.p111_runtime_admission(plan.request);if(error)throw Error(error);}
    const row={source:pin(source),rounds:[],products:{}};report.rows.push(row);save();
    for(let round=0;round<4;round++){
      const sample={round,warmup:round===0};
      for(const name of round%2?['candidate','baseline']:['baseline','candidate']){
        const api=apis[name],start=performance.now(),result=api.p111_lower_request(plan.request);
        sample[name]=(performance.now()-start)/1000;
        if(result.error)throw Error(result.error);
        if(round===0)row.products[name]=product(api,result.program);
      }
      row.rounds.push(sample);save();
    }
    row.exact=JSON.stringify(row.products.baseline)===JSON.stringify(row.products.candidate);
    if(!row.exact)throw Error('QBE changed for '+source);
    console.log(JSON.stringify(row));
  }
  inputPins.forEach(verify);report.complete=true;save();
}catch(e){report.error=String(e);save();throw e;}
