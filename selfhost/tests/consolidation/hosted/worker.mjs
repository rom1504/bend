// One fresh hosted compiler image per process. Root supplies the outer guard.
import fs from 'node:fs';
import path from 'node:path';
import {pin,verify,requireThat,inspectHosted} from '../../../tools/build/hosted.mjs';
const [inputFile,outArg]=process.argv.slice(2),input=JSON.parse(fs.readFileSync(inputFile,'utf8')),out=path.resolve(outArg);
requireThat(!fs.existsSync(out),'Fresh worker output required');fs.mkdirSync(out,{recursive:true});
const inputs=[pin(import.meta.filename),pin(inputFile),pin(process.execPath),...(input.inputs??[])];inputs.forEach(verify);
const report={kind:'bend-hosted-continuity-worker',complete:false,inputs,image:input.image,source:input.source,mode:input.mode,backend:input.backend};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try{
  const start=performance.now(),got=await inspectHosted(input);report.seconds=(performance.now()-start)/1000;
  const {code,...observation}=got.result;report.observation=observation;report.cache=got.cache;inputs.push(...got.inputs);
  if(typeof code==='string'){const file=path.join(out,input.mode==='native'?'program.c':'program.mjs');fs.writeFileSync(file,code,{flag:'wx'});report.product=pin(file);}
  inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
save();
