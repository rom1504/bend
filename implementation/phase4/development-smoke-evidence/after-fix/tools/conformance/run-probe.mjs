import fs from 'node:fs';
import path from 'node:path';
import {spawn} from 'node:child_process';
export function runProbe(request,{workerNodeArgs=[],worker=path.join(import.meta.dirname,'worker.mjs')}={}) {
  return new Promise(resolve=>{
    const file=path.join(request.workdir,'request.json');fs.writeFileSync(file,JSON.stringify(request,null,2)+'\n');
    fs.rmSync(request.response,{force:true});
    const captureDirectory=fs.mkdtempSync(path.join(request.workdir,'.worker-capture-'));
    const stdoutFile=path.join(captureDirectory,'stdout'),stderrFile=path.join(captureDirectory,'stderr');
    const a=fs.openSync(stdoutFile,'wx'),b=fs.openSync(stderrFile,'wx');
    const child=spawn(process.execPath,[...workerNodeArgs,worker,file],{cwd:request.workdir,stdio:['ignore',a,b],detached:process.platform!=='win32'});
    fs.closeSync(a);fs.closeSync(b);
    let timedOut=false,overflow=false,spawnError=null,settled=false;
    const limit=2**20;
    const read=(name,tail=false)=>{
      const size=fs.statSync(name).size,length=Math.min(size,tail?16384:limit),buffer=Buffer.alloc(length),fd=fs.openSync(name,'r');
      try{fs.readSync(fd,buffer,0,length,tail?size-length:0);return buffer;}finally{fs.closeSync(fd);}
    };
    const finish=result=>{
      if(settled)return;settled=true;
      fs.writeFileSync(path.join(request.workdir,'worker.stdout'),read(stdoutFile));
      fs.writeFileSync(path.join(request.workdir,'worker.stderr'),read(stderrFile));
      fs.rmSync(captureDirectory,{recursive:true,force:true});resolve(result);
    };
    function stop(){try{if(process.platform!=='win32')process.kill(-child.pid,'SIGKILL');else child.kill('SIGKILL')}catch{}}
    const exceeded=()=>fs.statSync(stdoutFile).size+fs.statSync(stderrFile).size>limit;
    const monitor=setInterval(()=>{if(exceeded()){overflow=true;stop()}},10);
    const alarm=setTimeout(()=>{timedOut=true;stop()},request.timeoutMs);
    child.on('error',error=>{spawnError=error;stop()});
    child.on('close',(code,signal)=>{
      clearTimeout(alarm);clearInterval(monitor);stop();
      // A short-lived writer may finish between polls. Check final byte counts
      // before trusting its response. Spawn errors and signals invalidate even a
      // well-formed response; ordinary compiler rejection exit codes remain valid.
      overflow ||= exceeded();
      const output=()=>({stdout:read(stdoutFile,true).toString('utf8'),stderr:read(stderrFile,true).toString('utf8')});
      if(timedOut)return finish({status:'timeout',reason:`Probe exceeded ${request.timeoutMs} ms.`,...output()});
      if(overflow)return finish({status:'crash',reason:'Probe exceeded output limit.',...output()});
      if(spawnError)return finish({status:'crash',reason:spawnError.message,exitCode:code,signal,...output()});
      if(signal)return finish({status:'crash',reason:'Worker terminated by '+signal,exitCode:code,signal,...output()});
      try{if(fs.statSync(request.response).size>2**22)return finish({status:'crash',reason:'Worker response exceeded output limit.'});finish(JSON.parse(fs.readFileSync(request.response,'utf8')))}catch{finish({status:'crash',reason:'Worker returned no valid result',exitCode:code,...output()})}
    });
  });
}
