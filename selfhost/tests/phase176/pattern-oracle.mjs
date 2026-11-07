import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../tools/build/hosted.mjs';
const [baseline,candidate,outArg]=process.argv.slice(2),out=path.resolve(outArg);
need(!fs.existsSync(out)&&out.startsWith(workspace+'/selfhost/build/'),'fresh output');fs.mkdirSync(out,{recursive:true});
const report={kind:'phase176-upstream-checked-workload-observation',complete:false,inputs:[pin(import.meta.filename),pin(process.execPath)],values:[]};
try{
  for(const file of [baseline,candidate]){
    const r=JSON.parse(fs.readFileSync(file));need(r.complete&&r.checked,'checked API required');
    report.inputs.push(pin(file),r.api,r.source,...r.inputs);report.inputs.forEach(verify);
    const api=(await import(pathToFileURL(r.api.file))).default,v=api.p176pn_run();
    need(Number.isInteger(v)&&v>=0&&v<=4294967295,'U32 observation');report.values.push(v);
  }
  need(report.values[0]===report.values[1],'different checked native workload observations');
  fs.writeFileSync(path.join(out,'expected.stdout'),String(report.values[0])+'\n');
  report.expected=pin(path.join(out,'expected.stdout'));report.inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,values:report.values,error:report.error}));
