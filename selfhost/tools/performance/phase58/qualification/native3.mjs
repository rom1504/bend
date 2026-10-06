// Three inherited independent native oracles; one outer root-owned guard.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {spawnSync} from 'node:child_process';import {pathToFileURL} from 'node:url';
import {stageChecked} from './checked-image.mjs';import {identity,verify} from '../../phase54/bootstrap/adapter.mjs';
const [baselineArg,candidateArg,outArg]=process.argv.slice(2);assert(baselineArg&&candidateArg&&outArg);
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);assert(out.startsWith(path.join(root,'selfhost/build/phase58')+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const inputs=new Map(),pin=item=>{const row=identity(typeof item==='object'?item.file:item);if(typeof item==='object')assert.equal(row.sha256,item.sha256);if(inputs.has(row.file))assert.deepEqual(inputs.get(row.file),row);else inputs.set(row.file,row);return row;};
const read=file=>JSON.parse(fs.readFileSync(pin(file).file,'utf8'));
const policyFile=path.join(root,'selfhost/tools/performance/phase55/semantic-plan-v1.json'),policy=read(policyFile);
const report={kind:'phase58-native3-private-retention',complete:false,pass:false,rows:[],roles:{},policy:pin(policyFile),environment:Object.fromEntries(['CC','CPATH','LIBRARY_PATH','LD_LIBRARY_PATH'].map(k=>[k,process.env[k]??null])),scope:'Unchanged inherited three C/stdout oracles, exact complete C-byte equality, separately staged private baseline and candidate caches. No closed historical project is imported. Not broad native conformance or timing evidence.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
try{
 for(const file of [import.meta.filename,path.join(import.meta.dirname,'checked-image.mjs'),path.join(root,'selfhost/tools/performance/phase55/semantic-native-v1.mjs'),process.execPath])pin(file);
 for(const [key,value]of Object.entries(policy.nativeEnvironment))assert.equal(process.env[key],value,key);assert.equal(policy.nativeRepresentatives.length,3);
 const roles={};for(const [role,directory]of [['baseline',baselineArg],['candidate',candidateArg]]){const state=await stageChecked(path.resolve(directory),path.join(out,role));if(role==='baseline')assert.equal(state.attempt.api.sha256,'128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea');roles[role]=state;report.roles[role]={image:state.image,copies:state.copies};for(const row of state.inputs)pin(row);save();}
 for(const item of policy.nativeRepresentatives){
  const source=pin(item.source),id=path.basename(source.file,'.bend'),row={id,source,expectedStdout:item.expectedStdout,roles:{},pass:false};report.rows.push(row);save();
  for(const [role,state]of Object.entries(roles)){
   const result=await state.D.inspect(source.file,{mode:'native',api:state.api});assert.equal(result.status,'ok',result.diagnostic);assert.equal(result.checked,true);assert.equal(result.exitCode,0);assert.equal(typeof result.code,'string');
   const file=path.join(out,id+'--'+role+'.c'),binary=path.join(out,id+'--'+role);fs.writeFileSync(file,result.code,{flag:'wx'});
   const record={code:pin(file),emissionInputs:result.files.map(pin)};row.roles[role]=record;save();
   const nativeFile=path.join(state.project,'tools/native-build.mjs');pin(nativeFile);const native=await import(pathToFileURL(nativeFile));
   record.build=native.buildNative({source:result.code,file,binary,target:'cpu',cwd:state.project,timeoutMs:120000});save();assert.equal(record.build.status,'ok',JSON.stringify(record.build));record.binary=pin(binary);
   const run=spawnSync(binary,[],{cwd:state.project,encoding:'utf8',timeout:30000,maxBuffer:1024*1024});record.execution={status:run.status,signal:run.signal,error:run.error?.message??null,stdout:run.stdout,stderr:run.stderr};save();assert(!run.error&&!run.signal);assert.equal(run.status,0);assert.equal(run.stdout,item.expectedStdout);
  }
  row.byteEqual=fs.readFileSync(row.roles.baseline.code.file).equals(fs.readFileSync(row.roles.candidate.code.file));assert(row.byteEqual,id);row.pass=true;save();
 }
 for(const [role,state]of Object.entries(roles))report.roles[role].verification=await state.verifyFinal();for(const row of inputs.values())verify(row);report.complete=report.pass=report.rows.length===3&&report.rows.every(x=>x.pass);report.inputsUnchanged=true;
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,rows:report.rows.length,error:report.error?.message}));
