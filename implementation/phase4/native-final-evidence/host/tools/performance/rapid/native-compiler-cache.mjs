#!/usr/bin/env node
// Cache host-local C builds only after Bend checking and emission. Preprocessing
// on every lookup makes changes to included headers part of the cache identity.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {spawn} from 'node:child_process';
import {nativeBuildPlan} from '../../native-build.mjs';

const [input,output,cacheRoot,...options]=process.argv.slice(2);
if(!input||!output||!cacheRoot||options.some(option=>!/^--(?:opt=O[0123]|timeout-ms=\d+)$/.test(option)))
  throw Error('usage: node native-compiler-cache.mjs INPUT.c OUTPUT_BINARY CACHE_DIRECTORY [--opt=O1] [--timeout-ms=60000]');
const value=(name,fallback)=>options.find(option=>option.startsWith(`--${name}=`))?.slice(name.length+3)??fallback;
const optimization=value('opt','O1'),timeoutMs=Number(value('timeout-ms','60000'));
if(!Number.isSafeInteger(timeoutMs)||timeoutMs<1)throw Error('Invalid timeout');
const source=fs.realpathSync(input),binary=path.resolve(output),cache=path.resolve(cacheRoot);
if(fs.existsSync(binary)||fs.existsSync(binary+'.build.json'))throw Error('Output already exists; use a fresh output path');
const sha=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
const sourceBytes=fs.readFileSync(source),sourceSha256=sha(sourceBytes);
const plan=nativeBuildPlan({source:sourceBytes.toString('utf8'),file:source,binary,target:'cpu'});
const toolSha256=sha(fs.readFileSync(new URL('../../native-build.mjs',import.meta.url)));
const cacheToolSha256=sha(fs.readFileSync(import.meta.filename));
// Keep input paths: __FILE__, relative includes and foreign code may observe them.
const cachePlan={...plan,args:plan.args.map(argument=>argument===binary?'$OUTPUT':argument==='-O3'?`-${optimization}`:argument)};
const reportFile=binary+'.build.json',started=performance.now();
const report={kind:'native-content-addressed-build',version:2,started:new Date().toISOString(),complete:false,cacheHit:false,
  input:source,inputSha256:sourceSha256,output:binary,cacheRoot:cache,optimization,timeoutMs,plan,cachePlan,toolSha256,cacheToolSha256,
  scope:'Host-local cache. Preprocessed headers, C bytes, compiler executable and full version are identified. System linker and libraries must remain stable; this is not a hermetic toolchain. Bend checking and emission are separate required artifacts.'};
fs.mkdirSync(path.dirname(binary),{recursive:true});fs.mkdirSync(cache,{recursive:true});
const temporary=fs.mkdtempSync(path.join(cache,'.build-'));
const save=()=>fs.writeFileSync(reportFile,JSON.stringify(report,null,2)+'\n');
let commandId=0;
function command(command,args){
  const remaining=timeoutMs-(performance.now()-started);
  if(remaining<=0)return Promise.reject(Error('Native cache build exceeded deadline'));
  return new Promise((resolve,reject)=>{
    const id=++commandId,stdoutFile=path.join(temporary,id+'.stdout'),stderrFile=path.join(temporary,id+'.stderr');
    const stdoutFd=fs.openSync(stdoutFile,'wx'),stderrFd=fs.openSync(stderrFile,'wx');
    let failure=null;
    const child=spawn(command,args,{cwd:path.dirname(source),env:process.env,stdio:['ignore',stdoutFd,stderrFd],detached:process.platform!=='win32'});
    fs.closeSync(stdoutFd);fs.closeSync(stderrFd);
    const kill=()=>{try{if(process.platform!=='win32')process.kill(-child.pid,'SIGKILL');else child.kill('SIGKILL');}catch{}};
    const alarm=setTimeout(()=>{failure=Error('Native cache build exceeded deadline');kill();},remaining);
    const oversized=()=>fs.statSync(stdoutFile).size+fs.statSync(stderrFile).size>2**20;
    const monitor=setInterval(()=>{if(oversized()){failure=Error('Native compiler log exceeded limit');kill();}},10);
    child.on('error',error=>{failure=error;});
    child.on('close',(code,signal)=>{
      clearTimeout(alarm);clearInterval(monitor);
      if(oversized())failure=Error('Native compiler log exceeded limit');
      if(failure){reject(failure);return;}
      const stdout=fs.readFileSync(stdoutFile,'utf8'),stderr=fs.readFileSync(stderrFile,'utf8');
      if(code!==0)reject(Error(`${command} failed (${code??signal}): ${stderr}`));else resolve({stdout,stderr});
    });
  });
}
function executable(name){
  const candidates=name.includes(path.sep)?[path.resolve(name)]:(process.env.PATH||'').split(path.delimiter).map(dir=>path.resolve(dir,name));
  for(const file of candidates)try{fs.accessSync(file,fs.constants.X_OK);if(fs.statSync(file).isFile())return fs.realpathSync(file);}catch{}
  throw Error('Compiler executable not found: '+name);
}
async function compilerIdentity(){
  const numbered=[...new Set((process.env.PATH||'').split(path.delimiter).flatMap(dir=>{try{return fs.readdirSync(dir);}catch{return [];}}).filter(name=>/^clang-\d+$/.test(name)))].sort((a,b)=>Number(b.slice(6))-Number(a.slice(6)));
  for(const name of process.env.CC?[process.env.CC]:['clang',...numbered]){
    let file;try{file=executable(name);}catch{continue;}
    const version=(await command(file,['--version'])).stdout,match=/^(Apple )?(?:\w+ )?clang version (\d+)/m.exec(version);
    if(match&&Number(match[2])>=14)return {command:file,version:version.trim(),executableSha256:sha(fs.readFileSync(file))};
  }
  throw Error('Native CPU cache builds require Clang 14 or newer');
}
async function preprocess(compiler){
  const preprocessed=path.join(temporary,'input.i');
  const args=plan.args.filter(arg=>!arg.startsWith('-l')).map(arg=>arg===binary?preprocessed:arg==='-O3'?`-${optimization}`:arg);
  await command(compiler.command,['-E',...args]);
  return sha(fs.readFileSync(preprocessed));
}
let lock=null,lockFd=null;
try {
  const compiler=await compilerIdentity();report.compiler=compiler;
  const preprocessingStarted=performance.now(),preprocessedSha256=await preprocess(compiler);report.preprocessMs=performance.now()-preprocessingStarted;
  const environment=Object.fromEntries(['PATH','CPATH','C_INCLUDE_PATH','CPLUS_INCLUDE_PATH','OBJC_INCLUDE_PATH','LIBRARY_PATH','SDKROOT','MACOSX_DEPLOYMENT_TARGET','SOURCE_DATE_EPOCH'].map(key=>[key,process.env[key]??null]));
  const identity={version:2,sourceSha256,preprocessedSha256,optimization,plan:cachePlan,compiler,toolSha256,cacheToolSha256,environment,platform:process.platform,arch:process.arch};
  const key=sha(JSON.stringify(identity));Object.assign(report,{key,preprocessedSha256,environment});
  const entry=path.join(cache,key+'.json'),cachedBinary=path.join(cache,key+'.bin');lock=path.join(cache,key+'.lock');
  try{lockFd=fs.openSync(lock,'wx');}catch{throw Error('Cache entry is locked by another build: '+key);}
  let record=null;
  if(fs.existsSync(entry)||fs.existsSync(cachedBinary)){
    try{record=JSON.parse(fs.readFileSync(entry,'utf8'));}catch{throw Error('Corrupt native cache record: '+key);}
    if(record.key!==key||sha(JSON.stringify(record.identity))!==key||typeof record.binarySha256!=='string'||!fs.existsSync(cachedBinary)||sha(fs.readFileSync(cachedBinary))!==record.binarySha256)
      throw Error('Corrupt native cache entry: '+key);
    report.cacheHit=true;
  }else{
    const staged=path.join(temporary,'compiler'),args=plan.args.map(arg=>arg===binary?staged:arg==='-O3'?`-${optimization}`:arg);
    const compileStarted=performance.now();const logs=await command(compiler.command,args);report.compileMs=performance.now()-compileStarted;report.args=args;Object.assign(report,logs);
    if(sha(fs.readFileSync(source))!==sourceSha256||await preprocess(compiler)!==preprocessedSha256||sha(fs.readFileSync(compiler.command))!==compiler.executableSha256)throw Error('Native build inputs changed during compilation');
    record={key,identity,binarySha256:sha(fs.readFileSync(staged)),created:new Date().toISOString()};
    // Publish the binary before its record while holding the lock. Partial entries
    // after an interrupted publication fail closed on the next attempt.
    fs.renameSync(staged,cachedBinary);
    const stagedRecord=path.join(temporary,'record.json');fs.writeFileSync(stagedRecord,JSON.stringify(record,null,2)+'\n');fs.renameSync(stagedRecord,entry);
  }
  if(sha(fs.readFileSync(source))!==sourceSha256||sha(fs.readFileSync(compiler.command))!==compiler.executableSha256)throw Error('Native build inputs changed before publication');
  const stagedOutput=binary+'.tmp-'+process.pid;fs.copyFileSync(cachedBinary,stagedOutput);
  if(sha(fs.readFileSync(stagedOutput))!==record.binarySha256){fs.rmSync(stagedOutput);throw Error('Native cached binary changed during publication');}
  // Exclusive publication refuses a concurrently created output.
  fs.linkSync(stagedOutput,binary);fs.unlinkSync(stagedOutput);
  Object.assign(report,{record,binarySha256:record.binarySha256,complete:true,finished:new Date().toISOString()});save();console.log(JSON.stringify(report));
}catch(error){report.error=error.message;report.finished=new Date().toISOString();save();console.error(JSON.stringify(report));process.exitCode=1;}
finally{if(lockFd!==null){fs.closeSync(lockFd);fs.unlinkSync(lock);}fs.rmSync(temporary,{recursive:true,force:true});}
