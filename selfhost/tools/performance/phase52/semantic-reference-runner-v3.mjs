// Reference-only oracle qualification; never a candidate or differential result.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';
const [manifestFile,outArg]=process.argv.slice(2);assert(manifestFile&&outArg);const out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const identity=file=>({file:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const verify=(row,base)=>{const file=path.resolve(base,row.file??row.path);assert.equal(identity(file).sha256,row.sha256);return file;};
const m=JSON.parse(fs.readFileSync(manifestFile,'utf8'));assert(m.complete&&m.passed);assert.deepEqual(Object.keys(m.roles),['typescript']);
const catalogFile=verify(m.catalog,path.dirname(path.resolve(manifestFile))),catalog=JSON.parse(fs.readFileSync(catalogFile,'utf8'));assert.equal(catalog.kind,'phase52-direct-semantic-catalog');
const worker=path.join(import.meta.dirname,'semantic-worker-v2.mjs'),programWorker=path.join(import.meta.dirname,'semantic-program-worker-v2.mjs'),reportFile=path.join(out,'report.json');
const report={kind:'phase52-upstream-only-semantic-oracle-controls',complete:false,pass:false,executed:true,candidateExecuted:false,differentialObservations:0,selectedScope:catalog.selectedScope??{fixtures:18,scenarios:59,kind:'full-independent-plan'},inputs:[identity(manifestFile),identity(catalogFile),identity(import.meta.filename),identity(worker),identity(programWorker)],observations:[],programAdapter:{identity:identity(programWorker),code:fs.readFileSync(programWorker,'utf8')},scope:'Pinned TypeScript only. Frozen independent fixture values/errors and observed hook/getter traces. No candidate, differential or performance qualification.'};fs.writeFileSync(reportFile,JSON.stringify(report,null,2)+'\n',{flag:'wx'});
try{
 for(const c of catalog.cases){
  const source=verify(c.source,path.dirname(catalogFile));for(const input of c.auxiliary??[])report.inputs.push(identity(verify(input,path.dirname(catalogFile))));
  const module=path.resolve(path.dirname(path.resolve(manifestFile)),m.roles.typescript.modules[c.id]),receiptFile=module+'.json',receipt=JSON.parse(fs.readFileSync(receiptFile,'utf8'));
  assert.equal(receipt.kind,'bend-program-checked-emission');assert(receipt.complete&&receipt.observation.checked&&receipt.observation.status==='ok');assert.equal(receipt.compiler.kind,'checked-pinned-typescript');assert.equal(receipt.compiler.upstreamCommit,catalog.upstreamCommit);
  verify(receipt.output,path.dirname(receiptFile));assert.equal(fs.realpathSync(receipt.output.file??receipt.output.path),fs.realpathSync(module));assert.equal(receipt.input.sha256,identity(source).sha256);for(const input of receipt.compiler.sources)verify(input,path.dirname(receiptFile));report.inputs.push(identity(source),identity(module),identity(receiptFile));
  for(const test of c.tests){
   const prefix=path.join(out,c.id+'--'+test.id),config=prefix+'.test.json';fs.writeFileSync(config,JSON.stringify(test,null,2)+'\n',{flag:'wx'});
   const row={fixture:c.id,test:test.id,role:'typescript',pass:false};
   const args=c.mode==='program'?[programWorker,module]:[worker,module,config,prefix+'.observation.json'];
   const run=spawnSync(process.execPath,['--stack-size=4096','--max-old-space-size=1024',...args],{encoding:'utf8',timeout:30000,maxBuffer:1024*1024});
   fs.writeFileSync(prefix+'.stdout',run.stdout??'',{flag:'wx'});fs.writeFileSync(prefix+'.stderr',run.stderr??'',{flag:'wx'});
   row.execution={command:[process.execPath,'--stack-size=4096','--max-old-space-size=1024',...args],status:run.status,signal:run.signal,error:run.error?.message??null};
   try{
    assert(!run.error&&!run.signal,String(run.error??run.signal));
    if(c.mode==='program'){assert.equal(run.status,test.exitCode);assert.equal(run.stdout,test.stdout);row.observation={stdout:run.stdout,stderr:run.stderr};}
    else{assert.equal(run.status,0,run.stderr);const d=JSON.parse(fs.readFileSync(prefix+'.observation.json','utf8'));assert(d.complete);row.observation=d;}
    row.pass=true;
   }catch(error){row.error=error.stack??String(error);if(fs.existsSync(prefix+'.observation.json'))row.observation=JSON.parse(fs.readFileSync(prefix+'.observation.json','utf8'));}
   report.observations.push(row);
  }
 }
 report.complete=true;report.counts={pass:report.observations.filter(x=>x.pass).length,fail:report.observations.filter(x=>!x.pass).length,total:report.observations.length};report.pass=report.counts.fail===0&&report.counts.total===catalog.cases.reduce((n,c)=>n+c.tests.length,0);if(!report.pass)process.exitCode=1;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
fs.writeFileSync(reportFile,JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,pass:report.pass,counts:report.counts,error:report.error}));
