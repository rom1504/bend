// Source-first cold numeric controls plus strict differential evaluation-order gates.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';
const [standardFile,referenceFile,outArg]=process.argv.slice(2);
assert(standardFile&&referenceFile&&outArg);
const out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const identity=file=>({file:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const report={kind:'phase66-independent-typescript-numeric-reference',candidateExecuted:false,complete:false,pass:false,inputs:[],observations:[],scope:'Fresh HEAD TypeScript only. All original34 independent numeric/order oracles are measured, including first/repeated NaN payloads. Oracle failures remain explicit; no previous defect count is assumed and no candidate qualification occurs.'};
const pin=file=>{const row=identity(file);report.inputs.push(row);return row.file;};
const verify=(row,base)=>{const file=path.resolve(base,row.file??row.path);assert.equal(identity(file).sha256,row.sha256);return pin(file);};
const read=file=>JSON.parse(fs.readFileSync(pin(file),'utf8'));
const numericWorker=pin(path.join("/home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase53",'semantic-numeric-worker-v1.mjs'));
const orderWorker=pin(path.join("/home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase53",'semantic-worker-v1.mjs'));
pin(import.meta.filename);pin(path.join("/home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase53",'semantic-runtime-v1.mjs'));pin(path.join("/home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase53",'semantic-oracle-correction-v2.json'));
const planFile=path.join("/home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase53",'semantic-numeric-plan-v1.json'),plan=read(planFile);
try {
 const standard=read(standardFile),reference=read(referenceFile);
 assert(standard.complete&&standard.passed&&reference.complete&&reference.passed);
 assert.deepEqual(Object.keys(standard.roles),['typescript']);assert.deepEqual(Object.keys(reference.roles),['typescript']);
 const catalogFile=verify(reference.catalog,path.dirname(path.resolve(referenceFile))),catalog=read(catalogFile);
 assert.equal(catalog.upstreamCommit,'059266225b77c8ca256ac6b25ee5c21449bab151');assert.equal(catalog.cases.length,2);
 const standardCatalogFile=verify(standard.catalog,path.dirname(path.resolve(standardFile))),standardCatalog=read(standardCatalogFile);
 assert.equal(standardCatalog.upstreamCommit,catalog.upstreamCommit);
 const sourceTable=standardCatalog.cases.find(c=>c.id==='f32_table_nan_bits');assert(sourceTable);
 function moduleFor(role,caseRow,file,catalogOrigin){
  const module=fs.realpathSync(file),receiptFile=module+'.json',receipt=read(receiptFile);
  assert.equal(receipt.kind,'bend-program-checked-emission');assert(receipt.complete&&receipt.observation.checked&&receipt.observation.status==='ok');
  assert.equal(verify(receipt.output,path.dirname(receiptFile)),module);
  const source=verify(caseRow.source,path.dirname(catalogOrigin));assert.equal(receipt.input.sha256,identity(source).sha256);
  assert.equal(receipt.compiler.upstreamCommit,catalog.upstreamCommit);
  assert.equal(role,'typescript');assert.equal(receipt.compiler.kind,'checked-pinned-typescript');for(const row of receipt.compiler.sources)verify(row,path.dirname(receiptFile));
  return pin(module);
 }
 const modules={typescript:{}};
 for(const role of ['typescript']){
  const group=reference;
  for(const caseRow of catalog.cases)modules[role][caseRow.id]=moduleFor(role,caseRow,group.roles[role].modules[caseRow.id],catalogFile);
  modules[role].originalTable=moduleFor(role,sourceTable,standard.roles[role].modules[sourceTable.id],standardCatalogFile);
 }
 function execute(name,caseId,config,numeric,referenceRequired){
  const configFile=path.join(out,name+'.json');fs.writeFileSync(configFile,JSON.stringify(config,null,2)+'\n',{flag:'wx'});pin(configFile);
  const row={id:name,sourceCase:caseId,referenceRequired,roles:{}};
  for(const role of ['typescript']){
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
  row.referencePass=row.roles.typescript.oraclePass;
  row.pass=row.referencePass;
  report.observations.push(row);
 }
 for(let fresh=0;fresh<plan.sourceTable.freshProcesses;fresh++)execute('original-cold-'+fresh,'originalTable',plan.sourceTable,true,false);
 for(let fresh=0;fresh<plan.renamedTable.freshProcesses;fresh++)execute('renamed-cold-'+fresh,'renamed-nan-table',plan.renamedTable,true,false);
 for(const row of plan.roundtrips)execute(row.id,'numeric-order',row,true,row.kind!=='nan-payload');
 for(const row of plan.arithmetic)execute(row.id,'numeric-order',row,true,true);
 const orderCase=catalog.cases.find(c=>c.id==='numeric-order');assert.equal(orderCase.tests.length,8);
 for(const test of orderCase.tests)execute(test.id,'numeric-order',test,false,true);
 report.inputs=[...new Map(report.inputs.map(row=>[row.file,row])).values()];
 report.changedInputs=report.inputs.filter(row=>{try{return identity(row.file).sha256!==row.sha256;}catch{return true;}});assert.equal(report.changedInputs.length,0);
 report.complete=true;report.counts={referencePass:report.observations.filter(r=>r.referencePass).length,referenceFailures:report.observations.filter(r=>!r.referencePass).map(r=>r.id),total:report.observations.length};
 assert.equal(report.observations.length,34);report.healthy=report.observations.every(row=>row.roles.typescript.healthy);report.pass=report.observations.every(row=>row.pass);if(!report.pass)process.exitCode=1;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,counts:report.counts,error:report.error}));
