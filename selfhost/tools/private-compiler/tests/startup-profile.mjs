// Bounded diagnostic only: profiles one real canonical request, including its
// Node binary hashing. These instrumented times are not benchmark medians.
import fs from 'node:fs';import path from 'node:path';import {spawn} from 'node:child_process';import {fileURLToPath} from 'node:url';
const [image,input,output]=process.argv.slice(2);if(!output)throw Error('Usage: startup-profile.mjs IMAGE INPUT NEW_DIRECTORY');
const out=path.resolve(output);fs.mkdirSync(out);const loader=fileURLToPath(new URL('./startup-loader.mjs',import.meta.url)),worker=fileURLToPath(new URL('../worker.mjs',import.meta.url));
// Invoke the immutable worker directly with loader instrumentation, so no
// production option admits arbitrary loader code. Parent CLI profile is a
// separate Node --import invocation using the same loader.
const request={input:path.resolve(input),mode:'compile',withReport:false};fs.writeFileSync(path.join(out,'request.json'),JSON.stringify(request));
const a=fs.openSync(path.join(out,'stdout'),'wx'),b=fs.openSync(path.join(out,'stderr'),'wx'),start=performance.now();let timeout=false;
const result=await new Promise(resolve=>{const p=spawn(process.execPath,['--stack-size=4096','--max-old-space-size=3072','--import',loader,worker,path.resolve(image),path.join(out,'request.json'),out],{stdio:['ignore',a,b],detached:true,env:{...process.env,NODE_OPTIONS:'',BEND_PRIVATE_STARTUP_PROFILE:path.join(out,'cost')}});const timer=setTimeout(()=>{timeout=true;try{process.kill(-p.pid,'SIGKILL');}catch{}},60000);p.once('error',error=>{clearTimeout(timer);resolve({error:String(error)});});p.once('close',(status,signal)=>{clearTimeout(timer);resolve({status,signal});});});fs.closeSync(a);fs.closeSync(b);fs.writeFileSync(path.join(out,'profile-launch.json'),JSON.stringify({...result,timeout,wallMs:performance.now()-start},null,2)+'\n');if(result.status!==0||timeout)process.exitCode=1;
