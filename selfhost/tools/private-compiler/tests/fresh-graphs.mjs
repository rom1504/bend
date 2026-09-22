// The internal IPC session must parse fresh source on every request, even though
// public finite batches additionally require lifetime-stable source identities.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {spawn} from 'node:child_process';
import {identity,verifyImage,readJson,writeJson} from '../common.mjs';
const [imageArg,outArg]=process.argv.slice(2);if(!outArg)throw Error('Usage: fresh-graphs.mjs REAL_IMAGE NEW_DIRECTORY');
const image=fs.realpathSync(imageArg),out=path.resolve(outArg);fs.mkdirSync(out);const source=path.join(out,'main.bend'),node={...identity(process.execPath),version:process.version},manifest=verifyImage(image).manifestIdentity,config=path.join(out,'config.json');writeJson(config,{image,directory:out,node});
const a=fs.openSync(path.join(out,'stdout'),'wx'),b=fs.openSync(path.join(out,'stderr'),'wx'),p=spawn('taskset',['-c','0',process.execPath,'--stack-size=4096','--max-old-space-size=3072',path.join(image,'runner/batch-worker.mjs'),config],{stdio:['ignore',a,b,'ipc'],detached:true,env:{...process.env,NODE_OPTIONS:''}});
const queue=[];let waiting,closed;const done=new Promise(resolve=>p.once('close',(status,signal)=>{closed={status,signal};if(waiting){waiting({kind:'closed',...closed});waiting=null;}resolve(closed);}));p.on('message',m=>{if(waiting){waiting(m);waiting=null;}else queue.push(m);});p.on('error',error=>{if(waiting){waiting({kind:'error',error:String(error)});waiting=null;}});
const next=()=>new Promise((resolve,reject)=>{const timer=setTimeout(()=>{waiting=null;reject(Error('Protocol timeout'));},60000),accept=x=>{clearTimeout(timer);resolve(x);};if(queue.length)accept(queue.shift());else if(closed)accept({kind:'closed',...closed});else waiting=accept;});
const report={kind:'private-session-fresh-source-regression',complete:false,manifest,node,rows:[]};
try{
 assert.equal((await next()).kind,'ready');
 for(const [i,text] of ['before','after'].entries()){
  fs.writeFileSync(source,'import Base\nlaw main:\n  IO(Unit)\ndef main():\n  IO.print('+JSON.stringify(text)+')\n');fs.mkdirSync(path.join(out,String(i).padStart(3,'0')));
  p.send({kind:'request',index:i,request:{input:source,mode:'compile'}});const response=await next();assert.equal(response.kind,'result');assert.equal(response.index,i);
  const observation=readJson(path.join(out,String(i).padStart(3,'0'),'result.json'));assert.equal(observation.result.status,'ok');assert.equal(observation.result.checked,true);assert.ok(fs.readFileSync(observation.emitted.file,'utf8').includes(JSON.stringify(text)));report.rows.push(observation);
 }
 assert.notEqual(report.rows[0].emitted.sha256,report.rows[1].emitted.sha256);assert.notEqual(report.rows[0].inputs.files.find(x=>x.file===source).sha256,report.rows[1].inputs.files.find(x=>x.file===source).sha256);
 p.send({kind:'finish'});assert.equal((await next()).kind,'finished');assert.deepEqual(await done,{status:0,signal:null});verifyImage(image);report.complete=true;
}catch(error){report.error=error.stack;try{process.kill(-p.pid,'SIGKILL');}catch{};await done;process.exitCode=1;}finally{fs.closeSync(a);fs.closeSync(b);writeJson(path.join(out,'report.json'),report);}console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));
