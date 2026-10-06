// Representative unchanged native emission and CPU execution; caller owns guard.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../development/workflow.mjs';
const [attemptArgument,outArgument]=process.argv.slice(2);assert(attemptArgument&&outArgument);
const out=path.resolve(outArgument);assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const inputs=[];
const identity=file=>({file:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const pin=file=>{const row=identity(file);inputs.push(row);return row.file;};
const verify=row=>{assert.equal(identity(row.file).sha256,row.sha256);return pin(row.file);};
const planFile=pin(path.join(import.meta.dirname,'semantic-plan-v1.json')),plan=JSON.parse(fs.readFileSync(planFile));
const project=path.resolve(import.meta.dirname,'../../..');
const report={kind:'phase54-native-representative-retention',complete:false,pass:false,executed:true,inputs,rows:[],scope:'Three frozen U32/F32/array representative sources. Baseline and candidate full C bytes equal; both CPU builds/runs satisfy independent source stdout. No broad native conformance or benchmark claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try{
 pin(import.meta.filename);pin(path.join(project,'tools/development/workflow.mjs'));
 verify(plan.installedBaseline);
 assert.equal(identity(path.join(project,'dist/typed-api.mjs')).sha256,plan.installedAPI);pin(path.join(project,'dist/typed-api.mjs'));
 const oldAcquisition=JSON.parse(fs.readFileSync(verify(plan.baselineSemantic.source)));
 const baselineAttempt=path.dirname(oldAcquisition.roles.direct.attempt.file);
 const roles={baseline:fs.realpathSync(baselineAttempt),candidate:fs.realpathSync(attemptArgument)};
 const compilers={};
 for(const [role,directory]of Object.entries(roles)){
  const m=await verifyAttempt(directory);assert(m.checked);
  if(role==='baseline')assert.equal(m.api.sha256,plan.installedAPI);
  pin(path.join(directory,'attempt.json'));
  for(const key of ['api','runtime','base','node'])verify(m[key]);
  const driverFile=path.join(m.snapshot.root,'tools/typed-driver.mjs');pin(driverFile);
  const buildFile=path.join(m.snapshot.root,'tools/native-build.mjs');pin(buildFile);
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
  process.env.BEND_TYPED_API=m.api.file;process.env.BEND_TYPED_RUNTIME=m.runtime.file;process.env.BEND_BASE=m.base.file;
  const driver=await import(pathToFileURL(driverFile));const api=await driver.loadApi();
  compilers[role]={manifest:m,driver,api,native:await import(pathToFileURL(buildFile))};
 }
 for(const item of plan.nativeRepresentatives){
  const source=verify(item.source),id=path.basename(source,'.bend'),row={id,source:item.source,expectedStdout:item.expectedStdout,roles:{},sameCBytes:false,pass:false};report.rows.push(row);save();
  for(const [role,compiler]of Object.entries(compilers)){
   const emission=await compiler.driver.inspect(source,{mode:'native',api:compiler.api});
   assert.equal(emission.status,'ok',JSON.stringify(emission));assert.equal(emission.checked,true);assert.equal(emission.exitCode,0);assert.equal(typeof emission.code,'string');
   for(const file of emission.files)pin(file);
   const file=path.join(out,id+'--'+role+'.c'),binary=path.join(out,id+'--'+role);fs.writeFileSync(file,emission.code,{flag:'wx'});
   const record={api:compiler.manifest.api,runtime:compiler.manifest.runtime,base:compiler.manifest.base,driver:identity(compiler.driver.project+'/tools/typed-driver.mjs'),nativeInputs:emission.files.map(identity),code:identity(file)};row.roles[role]=record;pin(file);save();
   record.build=compiler.native.buildNative({source:emission.code,file,binary,target:'cpu',cwd:project,timeoutMs:120000});save();assert.equal(record.build.status,'ok',JSON.stringify(record.build));
   record.binary=identity(binary);pin(binary);
   const run=spawnSync(binary,[],{cwd:project,encoding:'utf8',timeout:30000,maxBuffer:1024*1024});
   fs.writeFileSync(file+'.stdout',run.stdout??'',{flag:'wx'});fs.writeFileSync(file+'.stderr',run.stderr??'',{flag:'wx'});
   record.execution={status:run.status,error:run.error?.message??null,signal:run.signal,stdout:run.stdout,stderr:run.stderr};save();assert(!run.error&&!run.signal);assert.equal(run.status,0);assert.equal(run.stdout,item.expectedStdout);
  }
  row.sameCBytes=fs.readFileSync(row.roles.baseline.code.file).equals(fs.readFileSync(row.roles.candidate.code.file));assert(row.sameCBytes,id+' complete C bytes changed');row.pass=true;save();
 }
 report.inputs=[...new Map(inputs.map(row=>[row.file,row])).values()];report.changedInputs=report.inputs.filter(row=>identity(row.file).sha256!==row.sha256);assert.equal(report.changedInputs.length,0);
 report.complete=true;report.pass=report.rows.length===3&&report.rows.every(row=>row.pass);
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,rows:report.rows.length,error:report.error}));
