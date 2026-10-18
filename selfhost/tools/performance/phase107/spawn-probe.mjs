// Process-launch ablation: imports actual compiler images before timed launches.
import {spawnSync,spawn} from 'node:child_process';import fs from 'node:fs';import {pathToFileURL} from 'node:url';
const [apiArg,outArg]=process.argv.slice(2);await import(pathToFileURL(apiArg));await import('../../../dist/typed-api.mjs');
const rows=[];
for(let round=0;round<10;round++)for(const method of ['node-sync','node-async','bun-native']){
 const start=performance.now();let code;
 if(method==='node-sync')code=spawnSync('/usr/bin/true',[],{stdio:'ignore'}).status;
 else if(method==='node-async')code=await new Promise((resolve,reject)=>{const p=spawn('/usr/bin/true',[],{stdio:'ignore'});p.once('error',reject);p.once('close',resolve);});
 else{const p=Bun.spawn(['/usr/bin/true'],{stdout:'ignore',stderr:'ignore'});code=await p.exited;}
 if(code!==0)throw Error('launch failed');rows.push({round,method,seconds:(performance.now()-start)/1000});
}
fs.writeFileSync(outArg,JSON.stringify({complete:true,rows},null,2)+'\n');
