import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {spawn} from 'node:child_process';

const hash=value=>crypto.createHash('sha256').update(JSON.stringify(value)).digest('hex');
const save=(file,value)=>{const temporary=file+'.tmp-'+process.pid;fs.writeFileSync(temporary,JSON.stringify(value,null,2)+'\n');fs.renameSync(temporary,file);};
const fileHash=file=>crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const requestDigest=request=>{const {workerSession,...identity}=request;return hash(identity);};
const prefixDigest=(previous,entry)=>hash({previous,request:entry.requestDigest,result:entry.resultDigest});
export function validatePersistentReplay(request,session,workerNodeArgs=[]){
  if(session.version!==2)throw Error('Persistent session lacks replay integrity metadata');
  if(session.adapter!==request.adapter||session.identityFile!==request.identityFile||JSON.stringify(session.workerNodeArgs)!==JSON.stringify(workerNodeArgs))throw Error('Persistent session identity differs from retained request');
  if(fs.realpathSync(session.worker)!==session.workerCanonical||fileHash(session.worker)!==session.workerSha256||fileHash(session.adapter)!==session.adapterSha256||fileHash(session.identityFile)!==session.identitySha256)throw Error('Persistent session artifact changed');
  const index=request.workerSession?.index;
  if(!Number.isSafeInteger(index)||index<0||index>=session.requests.length)throw Error('Persistent session index is invalid');
  let prefix=null;
  for(let i=0;i<=index;i++){
    const entry=session.requests[i];
    if(!entry?.request||entry.request.adapter!==session.adapter||entry.request.identityFile!==session.identityFile||entry.requestDigest!==requestDigest(entry.request)||!/^([a-f0-9]{64})$/.test(entry.resultDigest||''))throw Error('Persistent session prefix is incomplete or changed');
    prefix=prefixDigest(prefix,entry);
    if(entry.prefixDigest!==prefix)throw Error('Persistent session prefix changed');
  }
  if(session.requests[index].requestDigest!==requestDigest(request)||request.workerSession.prefixDigest!==prefix)throw Error('Retained request differs from persistent session prefix');
  return index;
}
export function resultDigest(result){return hash(result);}

// One runner has exactly one in-flight request. Requests are sent through a
// bounded file queue so supervisors do not depend on inherited stdin delivery;
// the worker's FD3 notification is still consumed when available.
export function createPersistentRunner({directory,workerNodeArgs=[],worker=path.join(import.meta.dirname,'persistent-worker.mjs'),recycleAfter=64,rssLimitMb=1024}={}) {
  if(!Number.isSafeInteger(recycleAfter)||recycleAfter<1||!Number.isSafeInteger(rssLimitMb)||rssLimitMb<1)throw Error('Invalid persistent worker limits');
  fs.mkdirSync(directory,{recursive:true});
  let child=null,active=null,generation=0,sequence=0,protocolBuffer='',session=null,sessionFile=null,queueDirectory=null,poller=null,stopped=false,completedIds=new Map();
  const errors=[],stats={starts:0,requests:0,recycles:0,timeouts:0,failures:0,maxRssBytes:0};
  function flush(){if(sessionFile)save(sessionFile,session);}
  function stopPoller(){if(poller){clearInterval(poller);poller=null;}}
  function kill(reason='closed'){
    stopPoller();
    if(!child)return;
    const old=child;child=null;
    try{if(process.platform!=='win32')process.kill(-old.pid,'SIGKILL');else old.kill('SIGKILL');}catch{}
    session.closed=true;session.closeReason=reason;session.finished=new Date().toISOString();flush();
  }
  function finish(result,{rss=0,restart=false}={}) {
    if(!active)return;
    const current=active;active=null;completedIds.set(current.id,current.message?hash(current.message):null);clearTimeout(current.alarm);
    if(!fs.existsSync(path.join(current.request.workdir,'worker.stdout')))fs.writeFileSync(path.join(current.request.workdir,'worker.stdout'),current.stdout.subarray(0,2**20));
    if(!fs.existsSync(path.join(current.request.workdir,'worker.stderr')))fs.writeFileSync(path.join(current.request.workdir,'worker.stderr'),current.stderr.subarray(0,2**20));
    session.requests[current.index].resultDigest=resultDigest(result);
    session.requests[current.index].status=result.status;
    const entry=session.requests[current.index];entry.prefixDigest=prefixDigest(current.index?session.requests[current.index-1].prefixDigest:null,entry);
    current.request.workerSession={file:sessionFile,index:current.index,prefixDigest:entry.prefixDigest};
    save(path.join(current.request.workdir,'request.json'),current.request);flush();
    stats.requests++;stats.maxRssBytes=Math.max(stats.maxRssBytes,rss);
    const execution={mode:'persistent',session:sessionFile,index:current.index,generation:current.generation,pid:current.pid,rssBytes:rss,includesStartup:current.index===0};
    if(restart||result.status==='crash'||result.status==='timeout'){stats.failures++;kill(result.status);}
    else if(session.requests.length>=recycleAfter||rss>rssLimitMb*2**20){stats.recycles++;kill(rss>rssLimitMb*2**20?'rss-recycle':'request-recycle');}
    current.resolve({result,worker:execution});
  }
  function fault(reason){
    if(active)finish({status:'crash',phase:'worker',reason},{restart:true});
    else {errors.push(reason);kill('idle-protocol-failure');}
  }
  function completed(){
    if(!active?.message||!active.stdoutEnded||!active.stderrEnded)return;
    const message=active.message;
    try{
      if(fs.statSync(active.request.response).size>2**22)throw Error('Worker response exceeded output limit.');
      if(fileHash(active.request.response)!==message.responseSha256)throw Error('Persistent response identity changed');
      const result=JSON.parse(fs.readFileSync(active.request.response,'utf8'));
      if(!['ok','error','unsupported','timeout','crash'].includes(result?.status))throw Error('Invalid persistent probe result');
      const logs=['stdout','stderr'].map(which=>{
        const file=active.request[which==='stdout'?'workerStdout':'workerStderr'];
        if(fs.statSync(file).size>2**20)throw Error('Probe exceeded output limit.');
        const captured=fs.readFileSync(file);
        return {file,bytes:Buffer.concat([captured,active[which]])};
      });
      if(logs.reduce((size,log)=>size+log.bytes.length,0)>2**20)throw Error('Probe exceeded output limit.');
      for(const log of logs)fs.writeFileSync(log.file,log.bytes);
      finish(result,{rss:message.rss});
    }catch(error){fault(error.message);}
  }
  function acceptCompletion(message){
    if(completedIds.has(message?.id)){
      if(completedIds.get(message.id)!==hash(message))fault('Conflicting late persistent completion');
      return;
    }
    if(!active||message?.id!==active.id||message.token!==active.token){fault('Out-of-sequence persistent completion');return;}
    if(message.error){fault(String(message.error));return;}
    if(message.done!==true||!Number.isSafeInteger(message.rss)||message.rss<0||typeof message.logOverflow!=='boolean'||!/^[a-f0-9]{64}$/.test(message.responseSha256||'')){fault('Invalid persistent completion');return;}
    if(message.logOverflow){fault('Probe exceeded output limit.');return;}
    if(active.message&&hash(active.message)!==hash(message)){fault('Conflicting persistent completions');return;}
    active.message=message;completed();
  }
  function pollDone(){
    if(!active||!fs.existsSync(active.done))return;
    try{
      if(fs.statSync(active.done).size>16384)throw Error('Persistent completion exceeded output limit');
      acceptCompletion(JSON.parse(fs.readFileSync(active.done,'utf8')));
    }catch(error){fault(error.message);}
  }
  function start(request){
    do{generation++;}while(fs.existsSync(path.join(directory,`session-${generation}.json`))||fs.existsSync(path.join(directory,`queue-${generation}`)));
    sequence=0;protocolBuffer='';completedIds=new Map();
    sessionFile=path.join(directory,`session-${generation}.json`);queueDirectory=path.join(directory,`queue-${generation}`);fs.mkdirSync(queueDirectory,{recursive:true});
    session={version:2,adapter:request.adapter,adapterSha256:fileHash(request.adapter),identityFile:request.identityFile,identitySha256:fileHash(request.identityFile),workerNodeArgs:[...workerNodeArgs],worker,workerCanonical:fs.realpathSync(worker),workerSha256:fileHash(worker),queueDirectory,recycleAfter,rssLimitMb,started:new Date().toISOString(),closed:false,requests:[]};flush();
    const environment={...process.env};delete environment.NODE_OPTIONS;
    child=spawn(process.execPath,[...workerNodeArgs,worker,request.adapter,queueDirectory],{cwd:directory,env:environment,stdio:['pipe','pipe','pipe','pipe'],detached:process.platform!=='win32'});
    const launched=child;stats.starts++;poller=setInterval(pollDone,5);
    const capture=which=>data=>{
      if(child!==launched)return;
      // Both pipe boundaries must arrive before a request may complete.
      if(!active){fault('Worker emitted output outside a request');return;}
      if(active[which+'Ended']){fault('Worker emitted output after its request boundary');return;}
      active[which]=Buffer.concat([active[which],data]);
      const boundary=active[which].indexOf(active.end);
      if(boundary>=0){
        if(boundary+active.end.length!==active[which].length){fault('Output after persistent request boundary');return;}
        active[which]=active[which].subarray(0,boundary);active[which+'Ended']=true;
      }
      if(active.stdout.length+active.stderr.length>2**20+(active.stdoutEnded?0:active.end.length)+(active.stderrEnded?0:active.end.length)){finish({status:'crash',phase:'worker',reason:'Probe exceeded output limit.'},{restart:true});return;}
      completed();
    };
    child.stdout.on('data',capture('stdout'));child.stderr.on('data',capture('stderr'));
    child.stdio[3].setEncoding('utf8');
    child.stdio[3].on('data',chunk=>{
      if(child!==launched)return;
      protocolBuffer+=chunk;
      if(Buffer.byteLength(protocolBuffer)>16384){fault('Persistent protocol exceeded output limit');return;}
      while(protocolBuffer.includes('\n')){
        const at=protocolBuffer.indexOf('\n'),line=protocolBuffer.slice(0,at);protocolBuffer=protocolBuffer.slice(at+1);
        let message;try{message=JSON.parse(line);}catch{fault('Malformed persistent worker response');return;}
        acceptCompletion(message);
        if(child!==launched)return;
      }
    });
    child.on('error',error=>{if(child===launched)fault(error.message);});
    child.on('close',(code,signal)=>{if(child===launched)fault(`Persistent worker exited unexpectedly (${code??signal})`);});
  }
  return {
    stats,errors,
    run(request){
      if(stopped)throw Error('Persistent runner is closed');
      if(active)throw Error('Persistent runner already has an active request');
      if(!Number.isSafeInteger(request.timeoutMs)||request.timeoutMs<1||request.timeoutMs>2147483647)throw Error('Invalid persistent request timeout');
      return new Promise(resolve=>{
        if(child&&(session.adapter!==request.adapter||session.identityFile!==request.identityFile))kill('identity-change');
        if(!child)start(request);
        const index=session.requests.length,id=++sequence,token=crypto.randomBytes(16).toString('hex');
        request.workerSession={file:sessionFile,index};
        const file=path.join(request.workdir,'request.json'),done=path.join(request.workdir,'worker.done'),workerStdout=path.join(request.workdir,'worker.stdout'),workerStderr=path.join(request.workdir,'worker.stderr');
        for(const stale of [done,request.response,workerStdout,workerStderr])fs.rmSync(stale,{force:true});
        save(file,{...request,done,workerStdout,workerStderr});
        const recorded=structuredClone({...request,done,workerStdout,workerStderr});
        session.requests.push({request:recorded,requestDigest:requestDigest(recorded)});flush();
        active={id,token,index,request:{...request,done,workerStdout,workerStderr},resolve,pid:child.pid,generation,stdout:Buffer.alloc(0),stderr:Buffer.alloc(0),end:Buffer.from('\0BEND-END-'+token+'\0'),done,alarm:null,message:null};
        active.alarm=setTimeout(()=>{stats.timeouts++;finish({status:'timeout',reason:`Probe exceeded ${request.timeoutMs} ms.`},{restart:true});},request.timeoutMs);
        const command=JSON.stringify({id,file,token,streamMarkers:true});
        if(Buffer.byteLength(command)>16384){fault('Worker command exceeds limit');return;}
        const queued=path.join(queueDirectory,`${id}-${token}.json`),staged=queued+'.tmp-'+process.pid;fs.writeFileSync(staged,command);fs.renameSync(staged,queued);
      });
    },
    close(){stopped=true;if(active)finish({status:'crash',phase:'worker',reason:'Persistent runner closed during request'},{restart:true});kill();},
  };
}
