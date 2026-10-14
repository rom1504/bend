// ROOT-RUN ONLY: deliberately block the main event loop for about two seconds.
import fs from 'node:fs';
import path from 'node:path';
const out=path.resolve(process.env.P90_JS_PROFILE_OUT??'');
if(!process.env.P90_JS_PROFILE_OUT)throw new Error('Missing profile output directory');
const nowUs=()=>Number(process.hrtime.bigint()/1000n);
const report={kind:'phase90-synchronous-profile-control',mainStartedUs:nowUs(),durationMs:2000,completed:false};
fs.writeFileSync(path.join(out,'control.json'),JSON.stringify(report,null,2)+'\n');
function busySpin(durationMs){
  const until=performance.now()+durationMs;let value=1;
  while(performance.now()<until){value=(Math.imul(value,1664525)+1013904223)>>>0;}
  return value;
}
report.value=busySpin(report.durationMs);report.mainFinishedUs=nowUs();report.completed=true;
fs.writeFileSync(path.join(out,'control.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(report));
