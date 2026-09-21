import fs from 'node:fs';
import path from 'node:path';
import {spawn} from 'node:child_process';
export function runProbe(request,{workerNodeArgs=[],worker=path.join(import.meta.dirname,'worker.mjs')}={}) {
  return new Promise(resolve=>{
    const file=path.join(request.workdir,'request.json');fs.writeFileSync(file,JSON.stringify(request,null,2)+'\n');
    const child=spawn(process.execPath,[...workerNodeArgs,worker,file],{cwd:request.workdir,stdio:['ignore','pipe','pipe'],detached:process.platform!=='win32'});
    let stdout='',stderr='',timedOut=false,overflow=false,settled=false;
    const finish=result=>{if(settled)return;settled=true;fs.writeFileSync(path.join(request.workdir,'worker.stdout'),stdout.slice(0,2**20));fs.writeFileSync(path.join(request.workdir,'worker.stderr'),stderr.slice(0,2**20));resolve(result)};
    function stop(){try{if(process.platform!=='win32')process.kill(-child.pid,'SIGKILL');else child.kill('SIGKILL')}catch{}}
    const capture=which=>data=>{if(which==='stdout')stdout+=data;else stderr+=data;if(stdout.length+stderr.length>2**20){overflow=true;stop()}};
    child.stdout.on('data',capture('stdout'));child.stderr.on('data',capture('stderr'));
    const alarm=setTimeout(()=>{timedOut=true;stop()},request.timeoutMs);
    child.on('error',error=>{clearTimeout(alarm);finish({status:'crash',reason:error.message})});
    child.on('close',code=>{
      clearTimeout(alarm);stop();
      if(timedOut)return finish({status:'timeout',reason:`Probe exceeded ${request.timeoutMs} ms.`,stdout:stdout.slice(-16384),stderr:stderr.slice(-16384)});
      if(overflow)return finish({status:'crash',reason:'Probe exceeded output limit.',stdout:stdout.slice(-16384),stderr:stderr.slice(-16384)});
      try{if(fs.statSync(request.response).size>2**22)return finish({status:'crash',reason:'Worker response exceeded output limit.'});finish(JSON.parse(fs.readFileSync(request.response,'utf8')))}catch{finish({status:'crash',reason:'Worker returned no valid result',exitCode:code,stdout,stderr})}
    });
  });
}
