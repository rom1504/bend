import fs from 'node:fs';
import path from 'node:path';
import {sha256} from './inventory.mjs';
import {runProbe} from './run-probe.mjs';
import {createPersistentRunner,resultDigest,validatePersistentReplay} from './persistent-probe.mjs';
import {judge} from './judge.mjs';
import {successful} from './selection.mjs';
const [file]=process.argv.slice(2);
if(!file)throw Error('usage: node replay.mjs RETAINED_REQUEST.json');
const old=JSON.parse(fs.readFileSync(file,'utf8')),identity=JSON.parse(fs.readFileSync(old.identityFile,'utf8'));
const verify=()=>{for(const [input,canonical] of Object.entries(identity.inputPaths||{}))if((fs.existsSync(input)?fs.realpathSync(input):null)!==canonical)throw Error('Replay input path changed: '+input);for(const [input,hash] of Object.entries(identity.inputHashes))if((fs.existsSync(input)?sha256(fs.readFileSync(input)):null)!==hash)throw Error('Replay input changed: '+input);for(const artifact of Object.values(identity.identity.artifacts))if(sha256(fs.readFileSync(artifact.file))!==artifact.sha256)throw Error('Replay artifact changed: '+artifact.file);if(sha256(fs.readFileSync(old.adapter))!==identity.identity.adapterSha256)throw Error('Replay adapter changed')};
if(identity.node!==process.execPath||identity.nodeVersion!==process.version)throw Error('Exact replay requires the recorded Node executable and version');
verify();for(const key of identity.environmentKeys||[])delete process.env[key];Object.assign(process.env,identity.environment);
const workdir=fs.mkdtempSync(path.join(path.dirname(path.dirname(path.resolve(file))),'replay-'));
const persistent=identity.identity?.workerMode==='persistent'&&!process.argv.includes('--isolated');
if(persistent&&!old.workerSession)throw Error('Retained persistent request is missing its session prefix');
let request,result,worker=null;
if(persistent){
  const sessionFile=fs.realpathSync(old.workerSession.file),session=JSON.parse(fs.readFileSync(sessionFile,'utf8'));
  validatePersistentReplay(old,session,identity.workerNodeArgs||[]);
  const runner=createPersistentRunner({directory:path.join(workdir,'worker'),workerNodeArgs:identity.workerNodeArgs,worker:session.worker,recycleAfter:session.recycleAfter,rssLimitMb:session.rssLimitMb});
  try {
    for(let i=0;i<=old.workerSession.index;i++){
      const recorded=session.requests[i]?.request;
      if(!recorded)throw Error('Persistent session prefix is incomplete');
      const dir=path.join(workdir,`request-${i}`);fs.mkdirSync(dir,{recursive:true});
      const replayRequest={...recorded,workdir:dir,response:path.join(dir,'response.json'),workerSession:undefined};
      const execution=await runner.run(replayRequest);const observed=execution.result;
      if(resultDigest(observed)!==session.requests[i].resultDigest)throw Error(`Persistent replay result changed at request ${i}`);
      if(i===old.workerSession.index){request=replayRequest;result=observed;worker=execution.worker;}
    }
  } finally {runner.close();}
}else{
  request={...old,workdir,response:path.join(workdir,'response.json')};
  result=await runProbe(request,{workerNodeArgs:identity.workerNodeArgs});
}
verify();
const verdict=judge(request.test,request.lane,result,identity.identity.capabilities);
const report={original:path.resolve(file),originalSha256:sha256(fs.readFileSync(file)),workdir,result,...worker?{worker}:{},...verdict};
fs.writeFileSync(path.join(workdir,'replay.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report,null,2));
if(!successful({...verdict,lane:request.lane}))process.exitCode=1;
