// Bounded complete eligible JS/native inventory. Keep failures and partial progress.
import fs from 'node:fs';import path from 'node:path';import {pathToFileURL} from 'node:url';
import {verifyAttempt,identity,verifyIdentity} from '../../development/workflow.mjs';
import {supervise} from '../../development/process.mjs';
const read=f=>JSON.parse(fs.readFileSync(f)),write=(f,v)=>fs.writeFileSync(f,JSON.stringify(v,null,2)+'\n',{flag:'wx'});
const[mode,input,outArg]=process.argv.slice(2);if(!outArg||!['prepare','run'].includes(mode))throw Error('Usage: broad-backends.mjs prepare ATTEMPT NEW_SNAPSHOT | run SNAPSHOT NEW_OUTPUT');
const out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
if(mode==='prepare'){
 const attempt=fs.realpathSync(input),m=await verifyAttempt(attempt);if(m.artifactKind!=='checked-b1')throw Error('Require genuine normal checked B1');
 const inventoryTool=path.join(m.snapshot.root,'tools/conformance/inventory.mjs'),{inventory,probes}=await import(pathToFileURL(inventoryTool)),manifest=inventory(m.config.upstream);
 const lanes=['js','native'],cases=manifest.tests.map(test=>({id:test.id,lanes:lanes.filter(l=>probes(test).some(p=>p.lane===l))})).filter(c=>c.lanes.length);
 const eligibility=Object.fromEntries(lanes.map(l=>[l,{eligible:cases.filter(c=>c.lanes.includes(l)).length,ineligible:manifest.tests.filter(t=>!probes(t).some(p=>p.lane===l)).map(t=>({id:t.id,reason:!t.main?'No main entry point':'Fixture excludes this backend'}))}]));
 if(manifest.total!==1378||eligibility.js.eligible!==999||eligibility.native.eligible!==982)throw Error('Inventory changed; review broad scope before running');
 const selection=path.join(out,'selection.json');write(selection,{cases});
 const inputs=[identity(import.meta.filename),...['workflow','process'].map(n=>identity(new URL('../../development/'+n+'.mjs',import.meta.url).pathname)),identity(path.join(attempt,'attempt.json')),m.api,m.runtime,m.base,m.bootstrapReport,identity(inventoryTool),identity(path.join(m.snapshot.root,'tools/conformance/target.mjs')),identity(selection),identity(process.execPath)];
 for(const t of manifest.tests)inputs.push(identity(t.file));
 const config={upstream:m.config.upstream,api:m.api.file,runtime:m.runtime.file,bootstrapReport:m.bootstrapReport.file,selection,jobs:3,workerMode:'isolated',heapMb:4096,stackKb:4096,rssLimitMb:4096,timeoutMs:120000,retain:'all'};
 const configFile=path.join(out,'config.json');write(configFile,config);inputs.push(identity(configFile));
 const report={kind:'phase5-broad-backend-preparation',complete:true,prepared:new Date().toISOString(),attempt,api:m.api,bootstrap:m.bootstrapReport,target:path.join(m.snapshot.root,'tools/conformance/target.mjs'),configFile,inputs,nodeVersion:process.version,eligibility,eligibleObservationsPerCompiler:1981,totalFixtures:1378,scope:'Fresh pinned TypeScript and checked Bend observations on every eligible JS/native probe. Ineligible fixtures listed separately; known failures, unsupported cases and timeouts retained. No whole-language or performance claim.'};inputs.forEach(verifyIdentity);write(path.join(out,'snapshot.json'),report);console.log(JSON.stringify({prepared:true,eligible:1981,ineligible:{js:379,native:396}}));
}else{
 const snapshot=fs.realpathSync(path.join(input,'snapshot.json')),s=read(snapshot);if(s.kind!=='phase5-broad-backend-preparation'||!s.complete)throw Error('Invalid preparation');
 s.inputs.forEach(verifyIdentity);if(process.version!==s.nodeVersion)throw Error('Node version drift');await verifyAttempt(s.attempt);
 const env={...process.env};for(const k of Object.keys(env))if(k.startsWith('BEND_')||k==='NODE_OPTIONS')delete env[k];
 const toolchain=['CC','CPATH','LIBRARY_PATH','LD_LIBRARY_PATH'];if(toolchain.some(k=>!env[k]))throw Error('Set the recorded Clang environment before running');
 const inputs=[...s.inputs,identity(snapshot),identity(fs.realpathSync(env.CC))];const directory=path.join(out,'paired');
 const report={kind:'phase5-broad-backend-execution',complete:false,started:new Date().toISOString(),inputs,eligibility:s.eligibility,toolchain:Object.fromEntries(toolchain.map(k=>[k,env[k]])),scope:s.scope,resourceScope:'Three isolated workers shareCPU1,2,3;4GiBheap each;120-second probe deadline;45-minute parent limit. No timing comparison.',rows:{}};
 const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
 try{
  report.execution=await supervise('taskset',['-c','1,2,3',process.execPath,'--stack-size=4096','--max-old-space-size=4096',s.target,s.configFile,directory],{directory:path.join(out,'process'),env,timeoutMs:2695000});
  for(const n of ['reference','candidate']){
   const f=path.join(directory,n+'.json'),progress=path.join(directory,n+'.progress.jsonl');
   if(fs.existsSync(f)){const r=read(f);report.rows[n]={file:identity(f),observations:r.results.length,summary:r.summary,selectedComplete:r.selectedComplete,changedInputs:r.changedInputs,changedArtifacts:r.identity.changedArtifacts};}
   else report.rows[n]={complete:false,progress:fs.existsSync(progress)?identity(progress):null,completedObservations:fs.existsSync(progress)?fs.readFileSync(progress,'utf8').trim().split('\n').filter(Boolean).length:0};
  }
  const pair=path.join(directory,'paired.json');if(fs.existsSync(pair)){const p=read(pair);report.paired=identity(pair);report.exactDifferences=p.rows?.filter(r=>!r.exactAgreement).length;report.semanticDifferences=p.rows?.filter(r=>!r.semanticAgreement).length;report.selectedComplete=p.selectedComplete;}
  await verifyAttempt(s.attempt);inputs.forEach(verifyIdentity);report.inputsVerified=true;
  report.complete=!report.execution.error&&!report.execution.signal&&!report.execution.timedOut&&!report.execution.overflow&&[0,1].includes(report.execution.exitCode)&&['reference','candidate'].every(n=>report.rows[n].observations===1981&&!report.rows[n].changedInputs.length&&!report.rows[n].changedArtifacts.length);
  report.finished=new Date().toISOString();save();if(!report.complete)process.exitCode=1;
 }catch(error){report.error=String(error.stack??error);report.finished=new Date().toISOString();save();throw error;}
}
