// Integration proof that inspect transports data and never executes user JS.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {spawn} from 'node:child_process';import {createHash} from 'node:crypto';import {fileURLToPath} from 'node:url';
const [configFile,outArg]=process.argv.slice(2);if(!outArg)throw Error('Usage: private-boundary.mjs CONFIG NEW_DIRECTORY');
const cfg=JSON.parse(fs.readFileSync(configFile)),out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
const resolve=p=>fs.realpathSync(path.resolve(path.dirname(configFile),p)),sha=p=>createHash('sha256').update(fs.readFileSync(p)).digest('hex'),id=p=>({path:fs.realpathSync(p),sha256:sha(p)}),save=(p,x)=>fs.writeFileSync(p,JSON.stringify(x,null,2)+'\n');
const worker=fileURLToPath(new URL('./private-worker.mjs',import.meta.url)),base=resolve(cfg.base),runtime=resolve(cfg.runtime),sentinel=path.join(out,'FOREIGN_EXECUTED'),foreign=path.join(out,'poison.js'),input=path.join(out,'foreign.bend');
fs.writeFileSync(foreign,`require('node:fs').writeFileSync(${JSON.stringify(sentinel)},'executed');\nthrow Error('PRIVATE_FOREIGN_EXECUTION_TRAP');\nfunction poison(x){return x;}\n`);
fs.writeFileSync(input,'import Base\n\nlaw poison:\n  U32 -> IO(U32)\ndef poison(x):\n  import "./poison.js"\n\nlaw main:\n  IO(U32)\ndef main():\n  do IO<U32>:\n    x : U32 <- poison(1)\n    return x\n');
const bad=path.join(out,'bad.bend');fs.writeFileSync(bad,'import Base\ndef main() -> U32:\n  "🙂 wrong type"\n');
const identities=Object.fromEntries([worker,fileURLToPath(import.meta.url),fs.realpathSync(configFile),process.execPath,base,runtime,foreign,input,bad].map(p=>[p,id(p)])),variants=Object.entries(cfg.variants).map(([name,v])=>({name,api:resolve(v.api),host:resolve(v.host)}));
for(const v of variants)for(const p of [v.api,v.host,...['compiler-abi','node-resource-args','assemble','native-build'].map(n=>path.join(path.dirname(v.host),n+'.mjs'))])identities[p]=id(p);
const report={kind:'private-inspect-boundary-integration',complete:false,identities,rows:[],foreignNeverExecuted:false};const flush=()=>save(path.join(out,'report.json'),report);flush();
try{
 for(const test of [{name:'foreign-check',input,mode:'check',status:'ok',phase:'check'},{name:'foreign-compile',input,mode:'compile',status:'ok',phase:'compile'},{name:'exact-unicode-rejection',input:bad,mode:'check',status:'error',phase:'check'}])for(const v of variants){
  const name=test.name+'-'+v.name,prefix=path.join(out,name),config=prefix+'.config.json',request=prefix+'.request.json',result=prefix+'.result.json';save(config,{api:v.api,host:v.host,base,runtime,identities});save(request,{input:test.input,mode:test.mode});
  const a=fs.openSync(prefix+'.stdout','wx'),b=fs.openSync(prefix+'.stderr','wx');let timedOut=false;const observation=await new Promise(resolve=>{const child=spawn('taskset',['-c',String(cfg.cpu??0),process.execPath,'--stack-size=4096','--max-old-space-size=3072',worker,config,request,result],{env:{...process.env,NODE_OPTIONS:''},stdio:['ignore',a,b],detached:true});const timer=setTimeout(()=>{timedOut=true;try{process.kill(-child.pid,'SIGKILL');}catch{}},60000);child.once('error',e=>{clearTimeout(timer);resolve({error:String(e)});});child.once('close',(status,signal)=>{clearTimeout(timer);resolve({status,signal});});});fs.closeSync(a);fs.closeSync(b);
  const row={name,...observation,timedOut,passed:false};report.rows.push(row);assert.equal(row.status,0);assert.equal(row.timedOut,false);row.observation=JSON.parse(fs.readFileSync(result));assert.equal(row.observation.result.status,test.status);assert.equal(row.observation.result.phase,test.phase);assert.equal(row.observation.result.checked,true);
  const previous=report.rows.find(r=>r!==row&&r.name.startsWith(test.name+'-'));if(previous){assert.deepEqual(row.observation.result,previous.observation.result);assert.equal(row.observation.emitted?.sha256,previous.observation.emitted?.sha256);}
  if(test.mode==='compile')assert.match(fs.readFileSync(row.observation.emitted.file,'utf8'),/PRIVATE_FOREIGN_EXECUTION_TRAP/);
  assert.equal(fs.existsSync(sentinel),false,'Compiler executed a user foreign source');row.passed=true;flush();
 }
 for(const [file,before] of Object.entries(identities))assert.deepEqual(id(file),before);report.foreignNeverExecuted=true;report.complete=report.rows.every(x=>x.passed);
}catch(error){report.error=error.stack;process.exitCode=1;}flush();console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));
