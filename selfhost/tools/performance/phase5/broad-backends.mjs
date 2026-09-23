// Bounded complete eligible JS/native inventory. Keep failures and partial progress.
import fs from 'node:fs';import path from 'node:path';import {pathToFileURL} from 'node:url';
import {verifyAttempt,identity,verifyIdentity,validatedCache} from '../../development/workflow.mjs';
import {verifyEqualityDerivation} from '../../development/equality.mjs';
import {supervise} from '../../development/process.mjs';
const read=f=>JSON.parse(fs.readFileSync(f)),write=(f,v)=>fs.writeFileSync(f,JSON.stringify(v,null,2)+'\n',{flag:'wx'});

export function parseProgress(text){
 const lines=text.split('\n'),rows=[],invalidLines=[];let trailingFragmentBytes=0;
 for(let i=0;i<lines.length;i++){if(!lines[i].trim())continue;try{const row=JSON.parse(lines[i]);if(!row||typeof row!=='object'||typeof row.id!=='string'||typeof row.lane!=='string')throw Error('Not an observation');rows.push(row);}catch(error){if(i===lines.length-1)trailingFragmentBytes=Buffer.byteLength(lines[i]);else invalidLines.push({line:i+1,error:String(error)});}}
 return {rows,invalidLines,trailingFragmentBytes};
}
export function infrastructureCounts(results){
 const counts={crash:0,timeout:0,unsupported:0,'hardware-gated':0};for(const row of results){const status=Object.hasOwn(counts,row.status)?row.status:row.result?.status;if(Object.hasOwn(counts,status))counts[status]++;}return counts;
}
export function pairedCoverageComplete(execution,rows,paired,count=1981){
 return !execution.error&&!execution.signal&&!execution.timedOut&&!execution.overflow&&[0,1].includes(execution.exitCode)&&!paired?.error&&Array.isArray(paired?.rows)&&paired.rows.length===count&&Array.isArray(paired.missing)&&paired.missing.length===0&&['reference','candidate'].every(n=>rows[n]?.observations===count&&rows[n].adapterChangedDuringRun===false&&Array.isArray(rows[n].changedInputs)&&!rows[n].changedInputs.length&&Array.isArray(rows[n].changedArtifacts)&&!rows[n].changedArtifacts.length);
}
function verifyDerived(report,m){const d=verifyEqualityDerivation(report);if(d.metadata.original.api.canonicalPath!==m.api.canonicalPath||d.metadata.original.api.sha256!==m.api.sha256||d.metadata.original.bootstrapReport.sha256!==m.bootstrapReport.sha256)throw Error('Derived compiler does not belong to this genuine checked attempt');return d;}
async function main(){
const[mode,input,outArg,derivationArg,...extra]=process.argv.slice(2);if(!outArg||extra.length||!['prepare','run'].includes(mode)||(derivationArg&&(mode!=='prepare'||!derivationArg.startsWith('--derivation='))))throw Error('Usage: broad-backends.mjs prepare ATTEMPT NEW_SNAPSHOT [--derivation=REPORT] | run SNAPSHOT NEW_OUTPUT');
const out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
if(mode==='prepare'){
 const attempt=fs.realpathSync(input),m=await verifyAttempt(attempt);if(m.artifactKind!=='checked-b1')throw Error('Require genuine normal checked B1');
 const derivation=derivationArg?verifyDerived(fs.realpathSync(derivationArg.slice('--derivation='.length)),m):null,api=derivation?derivation.metadata.output:m.api;
 const inventoryTool=path.join(m.snapshot.root,'tools/conformance/inventory.mjs'),{inventory,probes}=await import(pathToFileURL(inventoryTool)),manifest=inventory(m.config.upstream);
 const lanes=['js','native'],cases=manifest.tests.map(test=>({id:test.id,lanes:lanes.filter(l=>probes(test).some(p=>p.lane===l))})).filter(c=>c.lanes.length);
 const eligibility=Object.fromEntries(lanes.map(l=>[l,{eligible:cases.filter(c=>c.lanes.includes(l)).length,ineligible:manifest.tests.filter(t=>!probes(t).some(p=>p.lane===l)).map(t=>({id:t.id,reason:!t.main?'No main entry point':'Fixture excludes this backend'}))}]));
 if(manifest.total!==1378||eligibility.js.eligible!==999||eligibility.native.eligible!==982)throw Error('Inventory changed; review broad scope before running');
 const selection=path.join(out,'selection.json');write(selection,{cases});
 const inputs=[identity(import.meta.filename),...['workflow','process'].map(n=>identity(new URL('../../development/'+n+'.mjs',import.meta.url).pathname)),identity(path.join(attempt,'attempt.json')),m.api,m.runtime,m.base,m.bootstrapReport,identity(inventoryTool),identity(path.join(m.snapshot.root,'tools/conformance/target.mjs')),identity(selection),identity(process.execPath)];
 for(const t of manifest.tests)inputs.push(identity(t.file));
 if(derivation)inputs.push(identity(derivation.report),api,identity(new URL('../../development/equality.mjs',import.meta.url).pathname));
 const cache=validatedCache(path.join(m.snapshot.root,'build/typed/cache'),api.file,m.base.file);inputs.push(identity(cache.file));
 const config={upstream:m.config.upstream,api:m.api.file,runtime:m.runtime.file,bootstrapReport:m.bootstrapReport.file,selection,jobs:4,workerMode:'isolated',heapMb:4096,stackKb:4096,rssLimitMb:4096,timeoutMs:120000,retain:'all'};
 if(derivation){delete config.api;delete config.runtime;delete config.bootstrapReport;config.candidateAdapter=path.join(m.snapshot.root,'tools/conformance/adapters/typed.mjs');inputs.push(identity(config.candidateAdapter));}
 const configFile=path.join(out,'config.json');write(configFile,config);inputs.push(identity(configFile));
 const report={kind:'phase5-broad-backend-preparation',complete:true,prepared:new Date().toISOString(),attempt,api,checkedParent:m.api,runtime:m.runtime,base:m.base,derivation:derivation?identity(derivation.report):null,bootstrap:m.bootstrapReport,target:path.join(m.snapshot.root,'tools/conformance/target.mjs'),configFile,inputs,nodeVersion:process.version,eligibility,eligibleObservationsPerCompiler:1981,totalFixtures:1378,scope:'Fresh pinned TypeScript and explicitly identified checked/derived Bend observations on every eligible JS/native probe. Ineligible fixtures listed separately; known failures, unsupported cases and timeouts retained. No whole-language or performance claim.'};inputs.forEach(verifyIdentity);write(path.join(out,'snapshot.json'),report);console.log(JSON.stringify({prepared:true,eligible:1981,ineligible:{js:379,native:396}}));
}else{
 const snapshot=fs.realpathSync(path.join(input,'snapshot.json')),s=read(snapshot);if(s.kind!=='phase5-broad-backend-preparation'||!s.complete)throw Error('Invalid preparation');
 s.inputs.forEach(verifyIdentity);if(process.version!==s.nodeVersion)throw Error('Node version drift');const checked=await verifyAttempt(s.attempt);if(s.derivation){const d=verifyDerived(s.derivation.file,checked);if(d.metadata.output.sha256!==s.api.sha256||d.metadata.output.canonicalPath!==s.api.canonicalPath)throw Error('Derived output identity mismatch');}
 const env={...process.env};for(const k of Object.keys(env))if(k.startsWith('BEND_')||k==='NODE_OPTIONS')delete env[k];
 Object.assign(env,{BEND_TYPED_API:s.api.file,BEND_TYPED_RUNTIME:s.runtime.file,BEND_BASE:s.base.file});
 const toolchain=['CC','CPATH','LIBRARY_PATH','LD_LIBRARY_PATH'];if(toolchain.some(k=>!env[k]))throw Error('Set the recorded Clang environment before running');
 const inputs=[...s.inputs,identity(snapshot),identity(fs.realpathSync(env.CC))];const directory=path.join(out,'paired');
 const report={kind:'phase5-broad-backend-execution',complete:false,started:new Date().toISOString(),artifactKind:s.derivation?'derived-b1-equality':'checked-b1',newBootstrap:false,api:s.api,checkedParent:s.checkedParent,derivation:s.derivation,inputs,eligibility:s.eligibility,toolchain:Object.fromEntries(toolchain.map(k=>[k,env[k]])),scope:s.scope,resourceScope:'Four isolated workers shareCPU0,1,2,3;4GiBheap each;120-second probe deadline;45-minute parent limit. No timing comparison.',rows:{}};
 const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
 try{
  report.execution=await supervise('taskset',['-c','0,1,2,3',process.execPath,'--stack-size=4096','--max-old-space-size=4096',s.target,s.configFile,directory],{directory:path.join(out,'process'),env,timeoutMs:2695000});
  for(const n of ['reference','candidate']){
   const f=path.join(directory,n+'.json'),progress=path.join(directory,n+'.progress.jsonl');
   if(fs.existsSync(f)){const r=read(f);report.rows[n]={file:identity(f),observations:r.results.length,summary:r.summary,selectedComplete:r.selectedComplete,changedInputs:r.changedInputs,changedArtifacts:r.identity.changedArtifacts,adapterChangedDuringRun:r.identity.adapterChangedDuringRun,infrastructureFailures:infrastructureCounts(r.results)};}
   else{const parsed=parseProgress(fs.existsSync(progress)?fs.readFileSync(progress,'utf8'):'');report.rows[n]={complete:false,progress:fs.existsSync(progress)?identity(progress):null,completedObservations:parsed.rows.length,infrastructureFailures:infrastructureCounts(parsed.rows),invalidProgressLines:parsed.invalidLines,trailingFragmentBytes:parsed.trailingFragmentBytes};}
  }
  const pair=path.join(directory,'paired.json');let paired=null;if(fs.existsSync(pair)){const p=read(pair);paired=p;report.paired=identity(pair);report.exactDifferences=p.rows?.filter(r=>!r.exactAgreement).length;report.semanticDifferences=p.rows?.filter(r=>!r.semanticAgreement).length;report.selectedComplete=p.selectedComplete;}
  const after=await verifyAttempt(s.attempt);if(s.derivation)verifyDerived(s.derivation.file,after);inputs.forEach(verifyIdentity);report.inputsVerified=true;
  report.complete=pairedCoverageComplete(report.execution,report.rows,paired);
  report.infrastructureHealthy=report.complete&&Object.values(report.rows).every(row=>Object.values(row.infrastructureFailures).every(n=>n===0));
  report.completionMeaning='Complete paired coverage with unchanged inputs/adapter. Strict fixture pass and infrastructure health are separate; known failures never become a full-conformance pass.';
  report.finished=new Date().toISOString();save();if(!report.complete)process.exitCode=1;
 }catch(error){report.error=String(error.stack??error);report.finished=new Date().toISOString();save();throw error;}
}

}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href)await main();
