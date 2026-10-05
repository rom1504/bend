// Source-first cold numeric controls plus strict differential evaluation-order gates.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';
const [directFile,referenceFile,outArg]=process.argv.slice(2);
assert(directFile&&referenceFile&&outArg);
const out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const identity=file=>({file:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const report={kind:'phase53-independent-composition-order-controls',complete:false,pass:false,inputs:[],observations:[],scope:'Every composition value/error/event oracle and exact upstream differential observation is mandatory. No reference exception or candidate waiver.'};
const pin=file=>{const row=identity(file);report.inputs.push(row);return row.file;};
const verify=(row,base)=>{const file=path.resolve(base,row.file??row.path);assert.equal(identity(file).sha256,row.sha256);return pin(file);};
const read=file=>JSON.parse(fs.readFileSync(pin(file),'utf8'));
const numericWorker=pin(path.join(import.meta.dirname,'semantic-numeric-worker-v1.mjs'));
const orderWorker=pin(path.join(import.meta.dirname,'semantic-worker-v1.mjs'));
pin(import.meta.filename);pin(path.join(import.meta.dirname,'semantic-composition-v1.mjs'));pin(path.join(import.meta.dirname,'semantic-oracle-correction-v2.json'));
pin(path.join(import.meta.dirname,'semantic-runtime-v1.mjs'));pin(path.join(import.meta.dirname,'semantic-oracle-correction-v2.json'));
try {
 const direct=read(directFile),reference=read(referenceFile);
 assert(direct.complete&&direct.passed&&reference.complete&&reference.passed);
 const attemptFile=verify(direct.roles.direct.attempt,path.dirname(path.resolve(directFile))),attempt=read(attemptFile);
 assert(attempt.checked);
 const snapshot=fs.realpathSync(attempt.snapshot.root);const frozenSources=new Map(attempt.snapshot.sources.map(row=>[fs.realpathSync(row.frozen.file),row.frozen.sha256]));
 const catalogFile=verify(direct.catalog,path.dirname(path.resolve(directFile))),catalog=read(catalogFile);
 assert.deepEqual(direct.catalog,reference.catalog);assert.equal(catalog.cases.length,1);
 function moduleFor(role,caseRow,file,catalogOrigin){
  const module=fs.realpathSync(file),receiptFile=module+'.json',receipt=read(receiptFile);
  assert.equal(receipt.kind,'bend-program-checked-emission');assert(receipt.complete&&receipt.observation.checked&&receipt.observation.status==='ok');
  assert.equal(verify(receipt.output,path.dirname(receiptFile)),module);
  const source=verify(caseRow.source,path.dirname(catalogOrigin));assert.equal(receipt.input.sha256,identity(source).sha256);
  assert.equal(receipt.compiler.upstreamCommit,catalog.upstreamCommit);
  if(role==='direct'){
   assert.equal(receipt.compiler.kind,'checked-development-attempt');assert.equal(receipt.compiler.backend,'direct');assert.equal(receipt.compiler.callingContract,'upstream-compatible-direct-v1');assert.equal(receipt.observation.exitCode,0);
   assert.equal(verify(receipt.attempt,path.dirname(receiptFile)),attemptFile);
   for(const key of ['api','runtime','base'])assert.equal(receipt.compiler[key].sha256,attempt[key].sha256);
   assert.equal(fs.realpathSync(receipt.compiler.driver.file),path.join(snapshot,'tools/typed-driver.mjs'));
   assert.equal(fs.realpathSync(receipt.compiler.directRuntime.file),path.join(snapshot,'src/runtime/js/direct.mjs'));
   for(const key of ['driver','directRuntime'])assert.equal(receipt.compiler[key].sha256,frozenSources.get(fs.realpathSync(receipt.compiler[key].file)));
   for(const key of ['api','runtime','base','driver','directRuntime'])verify(receipt.compiler[key],path.dirname(receiptFile));
   assert(receipt.emissionInputs.length>=3);for(const row of receipt.emissionInputs)verify(row,path.dirname(receiptFile));
  }else{assert.equal(receipt.compiler.kind,'checked-pinned-typescript');for(const row of receipt.compiler.sources)verify(row,path.dirname(receiptFile));}
  return pin(module);
 }
 const modules={direct:{},typescript:{}};
 for(const role of ['direct','typescript']){
  const group=role==='direct'?direct:reference;
  for(const caseRow of catalog.cases)modules[role][caseRow.id]=moduleFor(role,caseRow,group.roles[role].modules[caseRow.id],catalogFile);

 }
 function execute(name,caseId,config,numeric,referenceRequired){
  const configFile=path.join(out,name+'.json');fs.writeFileSync(configFile,JSON.stringify(config,null,2)+'\n',{flag:'wx'});pin(configFile);
  const row={id:name,sourceCase:caseId,referenceRequired,roles:{}};
  for(const role of ['typescript','direct']){
   const stem=path.join(out,name+'--'+role),resultFile=stem+'.json';
   const args=['--stack-size=4096','--max-old-space-size=1024',numeric?numericWorker:orderWorker,modules[role][caseId],configFile,resultFile];
   const result=spawnSync(process.execPath,args,{encoding:'utf8',timeout:30000,maxBuffer:1024*1024});
   fs.writeFileSync(stem+'.stdout',result.stdout??'',{flag:'wx'});fs.writeFileSync(stem+'.stderr',result.stderr??'',{flag:'wx'});
   const observation=fs.existsSync(resultFile)?read(resultFile):null;
   let healthy=!result.error&&!result.signal&&result.status===0&&observation?.complete;
   if(!numeric&&healthy){
    healthy=!observation.failure&&observation.outcome===(config.expectedError?'throw':'return');
    if(config.expectedError)healthy=healthy&&observation.error?.message?.includes(config.expectedError);
    else if(config.expected!==undefined)healthy=healthy&&JSON.stringify(observation.value)===JSON.stringify(config.expected);
   }
   row.roles[role]={healthy,status:result.status,error:result.error?.message??null,signal:result.signal,observation};
   if(numeric)row.roles[role].oraclePass=!!(healthy&&observation.oraclePass);
   else row.roles[role].oraclePass=!!healthy;
  }
  row.candidatePass=row.roles.direct.oraclePass;
  row.referencePass=row.roles.typescript.oraclePass;
  if(!numeric){row.differentialAgreement=JSON.stringify(row.roles.direct.observation)===JSON.stringify(row.roles.typescript.observation);}
  // Numeric reference payload failures are reported, not silently declared agreements.
  row.pass=row.candidatePass&&row.roles.typescript.healthy&&(!referenceRequired||row.referencePass)&&(!numeric?row.differentialAgreement:true);
  report.observations.push(row);
 }
 const orderCase=catalog.cases.find(c=>c.id==='composition-order');assert.equal(orderCase.tests.length,14);
 for(const test of orderCase.tests)execute(test.id,'composition-order',test,false,true);
 report.inputs=[...new Map(report.inputs.map(row=>[row.file,row])).values()];
 report.changedInputs=report.inputs.filter(row=>{try{return identity(row.file).sha256!==row.sha256;}catch{return true;}});assert.equal(report.changedInputs.length,0);
 report.complete=true;report.counts={candidatePass:report.observations.filter(r=>r.candidatePass).length,referencePass:report.observations.filter(r=>r.referencePass).length,referenceFailures:report.observations.filter(r=>!r.referencePass).map(r=>r.id),total:report.observations.length};
 report.pass=report.observations.every(row=>row.pass);if(!report.pass)process.exitCode=1;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,counts:report.counts,error:report.error}));
