// Root runs this serial checked acquisition under the shared resource supervisor.
// Compilation time here is excluded from generated-program execution timings.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';
import {verifyAttempt} from '../../../development/workflow.mjs';
const [baselineArg,candidateArg,upstreamArg,outArg]=process.argv.slice(2);
assert(baselineArg&&candidateArg&&upstreamArg&&outArg,
 'Usage: native-cast-acquire-v1.mjs PHASE36_ATTEMPT CANDIDATE_ATTEMPT UPSTREAM NEW_OUT');
const out=path.resolve(outArg);assert(!fs.existsSync(out));
const identity=file=>({path:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex'),bytes:fs.statSync(file).size});
const inputs=new Map();
function track(file,expected){const actual=identity(file);if(expected){assert.equal(actual.sha256,expected.sha256);if('bytes'in expected)assert.equal(actual.bytes,expected.bytes);}
 if(inputs.has(actual.path))assert.deepEqual(actual,inputs.get(actual.path));else inputs.set(actual.path,actual);return actual;}
const pointer=row=>track(row.file??row.path,row);
const here=import.meta.dirname,sourceFile=path.join(here,'native-cast-fixture-v1.bend'),fixtureFile=path.join(here,'native-cast-fixture-v1.json');
const fixture=JSON.parse(fs.readFileSync(track(fixtureFile).path));track(sourceFile,fixture.source);
const catalog=track(path.join(here,'../catalog.json')),catalogData=JSON.parse(fs.readFileSync(catalog.path));
assert.equal(catalogData.upstreamCommit,fixture.upstreamCommit);
const worker=track(path.join(here,'../../programs/emit-worker.mjs'));
const attempts=[];
for(const input of[baselineArg,candidateArg]){
 const directory=fs.realpathSync(input),receipt=track(path.join(directory,'attempt.json')),attempt=await verifyAttempt(directory);
 for(const key of['api','runtime','base'])pointer(attempt[key]);
 for(const row of attempt.snapshot.sources)pointer(row.frozen);
 attempts.push({directory,receipt,attempt});
}
assert.equal(attempts[0].attempt.api.sha256,'93e55ad7ee456eebb5fa3dd9606c2cf262ea386c6f66bfd891ffe187d8f50a75');
const upstream=fs.realpathSync(upstreamArg);
for(const name of['bend2/bend.ts','bend2/comp.ts','bend2/base.bend'])track(path.join(upstream,name));
track(import.meta.filename);track(process.execPath);
fs.mkdirSync(out);
const report={kind:'phase37-native-cast-actual-acquisition',complete:false,pass:false,producer:identity(import.meta.filename),
 node:{...identity(process.execPath),version:process.version},fixture:identity(fixtureFile),source:identity(sourceFile),
 attempts:attempts.map(row=>({receipt:row.receipt,api:row.attempt.api})),catalog,worker,modules:[],errors:[],inputs:[],
 scope:'Three checked emissions of the same frozen source, serial workers, explicit Phase37 catalog. No execution timing or optimizer substitution.'};
const save=()=>fs.writeFileSync(path.join(out,'acquire.json'),JSON.stringify(report,null,2)+'\n');
save();fs.copyFileSync(import.meta.filename,path.join(out,'consumed-acquire.mjs'));
try{
 for(const [index,role]of['original','candidate','typescript'].entries()){
  const moduleFile=path.join(out,role+'.mjs'),selection=index<2?attempts[index].directory:'upstream:'+upstream;
  const args=['--max-old-space-size=1024','--stack-size=4096',worker.path,selection,sourceFile,moduleFile,catalog.path];
  const execution=spawnSync(process.execPath,args,{encoding:'utf8',timeout:180000,maxBuffer:1048576});
  fs.writeFileSync(path.join(out,role+'.stdout'),execution.stdout??'',{flag:'wx'});
  fs.writeFileSync(path.join(out,role+'.stderr'),execution.stderr??'',{flag:'wx'});
  const row={role,command:[process.execPath,...args],exitCode:execution.status,signal:execution.signal,error:execution.error?.message};
  report.modules.push(row);save();
  assert.equal(execution.status,0,role+' checked emission failed');assert.equal(execution.error,undefined);
  const receipt=track(moduleFile+'.json'),emission=JSON.parse(fs.readFileSync(receipt.path));
  assert.equal(emission.kind,'bend-program-checked-emission');assert.equal(emission.complete,true);
  assert.equal(emission.observation.checked,true);assert.equal(emission.observation.status,'ok');
  assert.equal(emission.compiler.upstreamCommit,fixture.upstreamCommit);
  assert.equal(pointer(emission.input).path,fs.realpathSync(sourceFile));assert.equal(emission.input.sha256,fixture.source.sha256);
  assert.equal(pointer(emission.catalog).sha256,catalog.sha256);assert.equal(pointer(emission.producer).sha256,worker.sha256);
  emission.verifiers.forEach(pointer);
  if(index<2){
   assert.equal(emission.compiler.kind,'checked-development-attempt');
   assert.equal(pointer(emission.attempt).sha256,attempts[index].receipt.sha256);
   for(const key of['api','runtime','base'])assert.equal(pointer(emission.compiler[key]).sha256,attempts[index].attempt[key].sha256);
   pointer(emission.compiler.driver);
  }else{assert.equal(emission.compiler.kind,'checked-pinned-typescript');emission.compiler.sources.forEach(pointer);}
  row.module=track(moduleFile,emission.output);row.receipt=receipt;row.compiler=emission.compiler;save();
 }
 for(const row of attempts)await verifyAttempt(row.directory);
 for(const expected of inputs.values())assert.deepEqual(identity(expected.path),expected);
 report.complete=true;report.pass=true;
}catch(error){report.errors.push(error.stack??String(error));process.exitCode=1;}
report.inputs=[...inputs.values()];save();
console.log(JSON.stringify({complete:report.complete,pass:report.pass,modules:report.modules.length,errors:report.errors}));
