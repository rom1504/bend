// One immutable adapter session with a bounded, file-framed request queue.
// The queue keeps the worker usable when a host supervisor closes inherited
// stdin; FD3 remains an optional low-latency completion notification.
import fs from 'node:fs';
import path from 'node:path';
import readline from 'node:readline';
import crypto from 'node:crypto';
const atomicWrite=(file,bytes)=>{const temporary=file+'.tmp-'+process.pid;fs.writeFileSync(temporary,bytes);fs.renameSync(temporary,file);};
import {pathToFileURL} from 'node:url';

const adapterPath=path.resolve(process.argv[2]),homeDirectory=process.cwd();
const queueDirectory=path.resolve(process.argv[3]||path.join(homeDirectory,'.persistent-queue'));
fs.mkdirSync(queueDirectory,{recursive:true});
const adapter=await import(pathToFileURL(adapterPath));
if(!Array.isArray(adapter.persistentLanes)||typeof adapter.createPersistentSession!=='function')
  throw Error('Adapter has no persistent frontend contract');
const session=await adapter.createPersistentSession();
if(typeof session?.probe!=='function')throw Error('Invalid persistent session');
let busy=false,stopping=false;
let captureTarget=null;
const nativeStdoutWrite=process.stdout.write.bind(process.stdout),nativeStderrWrite=process.stderr.write.bind(process.stderr);
function captureWrite(which,chunk,encoding,callback){
  if(!captureTarget)return (which==='stdout'?nativeStdoutWrite:nativeStderrWrite)(chunk,encoding,callback);
  const bytes=Buffer.isBuffer(chunk)?chunk:Buffer.from(String(chunk),typeof encoding==='string'?encoding:'utf8');
  const room=Math.max(0,2**20-captureTarget.stdout.length-captureTarget.stderr.length),take=bytes.subarray(0,room);captureTarget[which]=Buffer.concat([captureTarget[which],take]);if(take.length<bytes.length)captureTarget.overflow=true;
  const done=typeof encoding==='function'?encoding:callback;if(typeof done==='function')done();return true;
}
process.stdout.write=(chunk,encoding,callback)=>captureWrite('stdout',chunk,encoding,callback);
process.stderr.write=(chunk,encoding,callback)=>captureWrite('stderr',chunk,encoding,callback);
function protocol(value){try{fs.writeSync(3,JSON.stringify(value)+'\n');}catch{}}
function validResult(result){return result&&['ok','error','unsupported','timeout','crash'].includes(result.status)}
async function processCommand(command){
  if(!Number.isSafeInteger(command.id)||typeof command.file!=='string'||!/^[a-f0-9]{32}$/.test(command.token))throw Error('Invalid worker command');
  if(fs.statSync(command.file).size>2**14)throw Error('Worker command exceeds limit');
  const request=JSON.parse(fs.readFileSync(command.file,'utf8'));
  if(path.resolve(request.adapter)!==adapterPath||!adapter.persistentLanes.includes(request.lane))throw Error('Request outside persistent adapter contract');
  if(typeof request.response!=='string'||typeof request.done!=='string')throw Error('Persistent request is missing response paths');
  process.chdir(request.workdir);
  captureTarget={stdout:Buffer.alloc(0),stderr:Buffer.alloc(0),overflow:false};
  let result;
  try {result=await session.probe(request);} catch(error) {result={status:'crash',phase:'adapter',reason:error.stack||String(error)};}
  if(!validResult(result))throw Error('Adapter returned an invalid probe result');
  const response=JSON.stringify(result);
  if(Buffer.byteLength(response)>2**22)throw Error('Worker response exceeded output limit');
  atomicWrite(request.response,response);
  const logs=captureTarget;captureTarget=null;
  if(typeof request.workerStdout==='string')atomicWrite(request.workerStdout,logs.stdout);
  if(typeof request.workerStderr==='string')atomicWrite(request.workerStderr,logs.stderr);
  process.chdir(homeDirectory);
  if(command.streamMarkers!==false){
    const end='\0BEND-END-'+command.token+'\0';
    try {await Promise.all([process.stdout,process.stderr].map(stream=>new Promise(resolve=>stream.write('',resolve))));}catch{}
    try {fs.writeSync(1,end);fs.writeSync(2,end);}catch{}
  }
  const done={id:command.id,token:command.token,done:true,rss:process.memoryUsage().rss,logOverflow:logs.overflow,responseSha256:crypto.createHash('sha256').update(response).digest('hex')};
  atomicWrite(request.done,JSON.stringify(done));
  protocol(done);
}
async function runCommand(command,source){
  if(busy||stopping){protocol({id:command?.id,token:command?.token,error:'Concurrent worker command'});return;}
  busy=true;
  try {await processCommand(command);}
  catch(error){
    captureTarget=null;
    try {process.chdir(homeDirectory);}catch{}
    try {const request=JSON.parse(fs.readFileSync(command.file,'utf8'));if(typeof request.done==='string')atomicWrite(request.done,JSON.stringify({id:command.id,token:command.token,error:error.stack||String(error)}));}catch{}
    protocol({id:command.id,token:command.token,error:error.stack||String(error)});
    if(source==='stdin'){process.exitCode=1;lines.close();}
  } finally {busy=false;}
}
function queueFiles(){return fs.readdirSync(queueDirectory).filter(name=>name.endsWith('.json')).sort();}
async function pollQueue(){
  if(busy||stopping)return;
  const name=queueFiles()[0];if(!name)return;
  const file=path.join(queueDirectory,name),active=file+'.active';
  try {fs.renameSync(file,active);}catch{return;}
  let command;
  try {if(fs.statSync(active).size>2**14)throw Error('Worker command exceeds limit');command=JSON.parse(fs.readFileSync(active,'utf8'));}catch(error){try{fs.unlinkSync(active);}catch{};protocol({error:error.message});return;}
  try {await runCommand(command,'queue');} finally {try{fs.unlinkSync(active);}catch{}}
}
const lines=readline.createInterface({input:process.stdin,crlfDelay:Infinity});
// The timer is deliberate: a supervisor may attach an immediately-closed
// stdin, while the file queue still has a valid request to process.
const poller=setInterval(pollQueue,5);
process.stdin.resume();
lines.on('line',line=>{
  if(Buffer.byteLength(line)>2**14){protocol({error:'Concurrent or oversized worker command'});process.exit(1);return;}
  let command;try{command=JSON.parse(line);}catch{protocol({error:'Malformed worker command'});process.exit(1);return;}
  runCommand(command,'stdin');
});
process.on('SIGTERM',async()=>{stopping=true;clearInterval(poller);try{await session.close?.();}finally{process.exit(0);}});
