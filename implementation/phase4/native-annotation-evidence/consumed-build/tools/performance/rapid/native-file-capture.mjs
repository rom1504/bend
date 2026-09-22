// Attempt-local async process transport. Compiler/manifest algorithms unchanged.
import fs from 'node:fs';import os from 'node:os';import path from 'node:path';import {spawn} from 'node:child_process';
export async function spawnFileCapture(command,args,{encoding='utf8',timeout=120000,maxBuffer=16*1024*1024,cwd,env=process.env}={}){
 const dir=fs.mkdtempSync(path.join(os.tmpdir(),'bend-native-capture-')),stdout=path.join(dir,'stdout'),stderr=path.join(dir,'stderr'),a=fs.openSync(stdout,'wx'),b=fs.openSync(stderr,'wx');
 return await new Promise(resolve=>{
  const child=spawn(command,args,{cwd,env,stdio:['ignore',a,b],detached:process.platform!=='win32'});fs.closeSync(a);fs.closeSync(b);let error=null;
  const kill=()=>{try{if(process.platform!=='win32')process.kill(-child.pid,'SIGKILL');else child.kill('SIGKILL');}catch{}};
  const alarm=setTimeout(()=>{error=Object.assign(Error('Process exceeded '+timeout+' ms'),{code:'ETIMEDOUT'});kill();},timeout);
  const over=()=>fs.statSync(stdout).size+fs.statSync(stderr).size>maxBuffer;
  const monitor=setInterval(()=>{if(over()){error=Error('Process output exceeded limit');kill();}},10);
  child.on('error',e=>error=e);child.on('close',(status,signal)=>{clearTimeout(alarm);clearInterval(monitor);if(over())error=Error('Process output exceeded limit');const result={status,signal,error,stdout:fs.readFileSync(stdout).subarray(0,maxBuffer).toString(encoding),stderr:fs.readFileSync(stderr).subarray(0,maxBuffer).toString(encoding)};fs.rmSync(dir,{recursive:true,force:true});resolve(result);});
 });
}
