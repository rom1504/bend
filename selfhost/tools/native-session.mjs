#!/usr/bin/env node
// Serial Bend-to-C requests keep the generated compiler warm. Source graphs
// are rediscovered and checked on every call; no compiled-program cache.
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {createInterface} from 'node:readline';
import {pathToFileURL} from 'node:url';
import * as D from './typed-driver.mjs';
const hash=file=>createHash('sha256').update(fs.readFileSync(file)).digest('hex');
let loadedIdentity;
export async function createNativeSession({maxRequests=128,rssMiB=1024}={}) {
  if(!Number.isSafeInteger(maxRequests)||maxRequests<1||!Number.isFinite(rssMiB)||rssMiB<64)throw Error('Invalid session limits');
  const files=[D.apiPath,D.runtimePath,D.basePath,D.driverPath,D.compilerAbiPath,D.baseCacheGraphPath,path.join(D.project,'src/compiler.json')];
  const inputs=Object.freeze(files.map(file=>Object.freeze({file:fs.realpathSync(file),sha256:hash(file)})));
  const stable=()=>{for(let i=0;i<files.length;i++)if(fs.realpathSync(files[i])!==inputs[i].file||hash(files[i])!==inputs[i].sha256)throw Error('Compiler or Base changed; restart the native session');};
  const identity=JSON.stringify(inputs);
  if(loadedIdentity&&loadedIdentity!==identity)throw Error('Compiler or Base changed; restart the process');
  await D.loadApi();stable();loadedIdentity=identity;let count=0,busy=false,closed=false;
  return Object.freeze({inputs,async compile(input) {
    if(closed||count>=maxRequests)throw Error('Native session exhausted; restart it');
    if(busy)throw Error('Native session requires serial requests');
    busy=true;count++;
    try {
      stable();const start=performance.now();
      const result=await D.inspect(path.resolve(input),{mode:'native',withReport:true});
      const requestMs=performance.now()-start;stable();
      const rssBytes=process.memoryUsage().rss;
      closed=count>=maxRequests||rssBytes>=rssMiB*1024*1024;
      return {...result,requestMs,rssBytes,request:count,recycle:closed};
    } catch(error){closed=true;throw error;} finally{busy=false;}
  }});
}

if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){
  if(process.argv.includes('--help'))console.log('Native compilation session: one JSON {id,input,output} per stdin line; one JSON result per stdout line. output is a .c file. Requests run serially; recycle:true requires a new process. Use Node --stack-size=4096 --max-old-space-size=1024.');
  else {
    const session=await createNativeSession();
    for await(const line of createInterface({input:process.stdin,crlfDelay:Infinity})) {
      let request,result;
      try {
        request=JSON.parse(line);
        if(typeof request?.input!=='string'||typeof request?.output!=='string'||!request.output.endsWith('.c'))throw Error('Expected input and .c output paths');
        result=await session.compile(request.input);
        const {code,...details}=result;
        if(result.status==='ok') {
          const output=path.resolve(request.output),canonical=fs.existsSync(output)?fs.realpathSync(output):output;
          if([...session.inputs.map(x=>x.file),...(result.files??[]).map(f=>fs.realpathSync(f))].includes(canonical))throw Error('Output aliases a compiler or source input');
          const temporary=output+'.session-'+process.pid;fs.writeFileSync(temporary,code,{flag:'wx'});
          try{fs.renameSync(temporary,output);}finally{fs.rmSync(temporary,{force:true});}
          Object.assign(details,{output,bytes:Buffer.byteLength(code),sha256:createHash('sha256').update(code).digest('hex')});
        }
        console.log(JSON.stringify({id:request.id,...details}));
      }catch(error){console.log(JSON.stringify({id:request?.id,status:'error',diagnostic:String(error.message??error),recycle:true}));break;}
      if(result.recycle)break;
    }
  }
}
