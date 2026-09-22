// File-backed supervision for the finite development phases. Probe scheduling,
// compiler verdicts and replay remain owned by tools/conformance.
import fs from 'node:fs';
import path from 'node:path';
import {spawn} from 'node:child_process';

export async function supervise(command, args, {directory, env, timeoutMs, maxBytes=16*1024*1024}={}) {
  if(!Number.isSafeInteger(timeoutMs)||timeoutMs<1||timeoutMs>3600000)throw Error('Invalid phase deadline');
  if(!Number.isSafeInteger(maxBytes)||maxBytes<1)throw Error('Invalid capture limit');
  fs.mkdirSync(directory,{recursive:false});
  const stdout=path.join(directory,'stdout'),stderr=path.join(directory,'stderr');
  const a=fs.openSync(stdout,'wx'),b=fs.openSync(stderr,'wx'),start=performance.now();
  let timedOut=false,overflow=false,error=null,child;
  const bytes=()=>fs.fstatSync(a).size+fs.fstatSync(b).size;
  // Persistent conformance workers create their own process groups. Remember
  // descendants as well as the outer command so a phase deadline cannot leave
  // an orphaned compiler running. Start ticks protect against PID reuse.
  const seen=new Map();
  const startTicks=pid=>{try{const text=fs.readFileSync(`/proc/${pid}/stat`,'utf8');return text.slice(text.lastIndexOf(')')+2).split(' ')[19];}catch{return null;}};
  const sample=pid=>{const ticks=startTicks(pid);if(ticks===null)return;seen.set(pid,ticks);try{for(const id of fs.readFileSync(`/proc/${pid}/task/${pid}/children`,'utf8').trim().split(/\s+/).filter(Boolean))sample(Number(id));}catch{}};
  const stop=()=>{
    if(!child?.pid)return;
    if(process.platform==='linux'){
      sample(child.pid);
      for(const [pid,ticks] of [...seen].reverse())if(startTicks(pid)===ticks){try{process.kill(-pid,'SIGKILL');}catch{}try{process.kill(pid,'SIGKILL');}catch{}}
    }
    try{process.kill(-child.pid,'SIGKILL');}catch{try{child.kill('SIGKILL');}catch{}}
  };
  try {
    const outcome=await new Promise(resolve=>{
      try{child=spawn(command,args,{env,stdio:['ignore',a,b],detached:process.platform!=='win32'});}
      catch(e){resolve({exitCode:null,signal:null});error=String(e);return;}
      const timer=setTimeout(()=>{timedOut=true;stop();},timeoutMs);
      const monitor=setInterval(()=>{if(child.pid&&process.platform==='linux')sample(child.pid);if(bytes()>maxBytes){overflow=true;stop();}},25);
      child.once('error',e=>{error=String(e);stop();});
      child.once('close',(exitCode,signal)=>{clearTimeout(timer);clearInterval(monitor);stop();resolve({exitCode,signal});});
    });
    const logBytes=bytes();overflow ||= logBytes>maxBytes;
    return {command,args,stdout,stderr,timeoutMs,maxBytes,...outcome,error,timedOut,overflow,logBytes,wallMs:performance.now()-start};
  } finally {fs.closeSync(a);fs.closeSync(b);}
}

export function requireExecution(result, allowed=[0]) {
  if(result.error||result.signal||result.timedOut||result.overflow||!allowed.includes(result.exitCode))
    throw Error('Development phase failed; inspect '+result.stderr);
}
