// Untimed independent differential controller; caller supplies outer resource supervision.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';
const [manifestFile,outArgument]=process.argv.slice(2);assert(manifestFile&&outArgument);
const out=path.resolve(outArgument);assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const identity=file=>({file:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const verify=(row,base)=>{const file=path.resolve(base,row.file??row.path);assert.equal(identity(file).sha256,row.sha256);return file;};
const m=JSON.parse(fs.readFileSync(manifestFile,'utf8')),catalogFile=verify(m.catalog,path.dirname(path.resolve(manifestFile))),catalog=JSON.parse(fs.readFileSync(catalogFile,'utf8'));
assert.equal(catalog.kind,'phase52-direct-semantic-catalog');assert.deepEqual(Object.keys(m.roles).sort(),['direct','typescript']);
const selectedAttempt=verify(m.roles.direct.attempt,path.dirname(path.resolve(manifestFile)));
const directIdentity={};
const worker=path.join(import.meta.dirname,'semantic-worker-v4.mjs'),programWorker=path.join(import.meta.dirname,'semantic-program-worker-v2.mjs'),directProgramWorker=path.join(import.meta.dirname,'semantic-direct-program-worker-v1.mjs');
const report={kind:'phase52-independent-direct-differential-semantics',complete:false,pass:false,executed:true,selectedScope:catalog.selectedScope??{fixtures:18,scenarios:59,kind:'full-independent-plan'},inputs:[identity(manifestFile),identity(catalogFile),identity(import.meta.filename),identity(worker),identity(programWorker),identity(directProgramWorker)],observations:[],programAdapters:{typescript:{moduleForm:'CommonJS',identity:identity(programWorker),code:fs.readFileSync(programWorker,'utf8')},direct:{moduleForm:'ESM',identity:identity(directProgramWorker),code:fs.readFileSync(directProgramWorker,'utf8')}},scope:'Default callable library and selected CLI effects. Independent value/error oracles plus exact TS differential results/events; no legacy G obligations or universal conformance claim.'};
try{
 for(const c of catalog.cases){
  const source=verify(c.source,path.dirname(catalogFile));report.inputs.push(identity(source));for(const input of c.auxiliary??[])report.inputs.push(identity(verify(input,path.dirname(catalogFile))));
  const modules={};
  for(const role of ['typescript','direct']){
   const file=path.resolve(path.dirname(path.resolve(manifestFile)),m.roles[role].modules[c.id]);const receiptFile=file+'.json',receipt=JSON.parse(fs.readFileSync(receiptFile,'utf8'));
   assert.equal(receipt.kind,'bend-program-checked-emission');assert(receipt.complete&&receipt.observation.checked&&receipt.observation.status==='ok');
   verify(receipt.output,path.dirname(receiptFile));assert.equal(fs.realpathSync(receipt.output.file??receipt.output.path),fs.realpathSync(file));assert.equal(receipt.input.sha256,identity(source).sha256);
   if(role==='direct'){assert.equal(receipt.compiler.backend,'direct');assert.equal(receipt.compiler.callingContract,'upstream-compatible-direct-v1');assert.equal(receipt.compiler.kind,'checked-development-attempt');assert(receipt.attempt);verify(receipt.attempt,path.dirname(receiptFile));assert.equal(receipt.attempt.sha256,m.roles.direct.attempt.sha256);for(const key of ['api','runtime','base','driver']){assert(receipt.compiler[key]);verify(receipt.compiler[key],path.dirname(receiptFile));if(directIdentity[key])assert.equal(receipt.compiler[key].sha256,directIdentity[key]);else directIdentity[key]=receipt.compiler[key].sha256;}for(const input of receipt.emissionInputs??[])verify(input,path.dirname(receiptFile));}
   else {assert.equal(receipt.compiler.kind,'checked-pinned-typescript');for(const input of receipt.compiler.sources)verify(input,path.dirname(receiptFile));}
   assert.equal(receipt.compiler.upstreamCommit,catalog.upstreamCommit);modules[role]=file;report.inputs.push(identity(file),identity(receiptFile));
  }
  for(const test of c.tests){
   const row={fixture:c.id,test:test.id,roles:{}};const config=path.join(out,c.id+'--'+test.id+'.json');fs.writeFileSync(config,JSON.stringify(test,null,2)+'\n',{flag:'wx'});
   try {
   const roleFailures=[];
   for(const role of ['typescript','direct']){
    try {
    const log=path.join(out,c.id+'--'+test.id+'--'+role),args=c.mode==='program'?[role==='direct'?directProgramWorker:programWorker,modules[role]]:[worker,modules[role],config,log+'.json'];
    const run=spawnSync(process.execPath,['--stack-size=4096','--max-old-space-size=1024',...args],{encoding:'utf8',timeout:30000,maxBuffer:1024*1024});
    fs.writeFileSync(log+'.stdout',run.stdout??'',{flag:'wx'});fs.writeFileSync(log+'.stderr',run.stderr??'',{flag:'wx'});
    assert(!run.error&&!run.signal,'execution failed '+String(run.error??run.signal));
    if(c.mode==='program'){assert.equal(run.status,test.exitCode);assert.equal(run.stdout,test.stdout);row.roles[role]={status:run.status,stdout:run.stdout,stderr:run.stderr};}
    else {assert.equal(run.status,0,run.stderr);const observation=JSON.parse(fs.readFileSync(log+'.json','utf8'));assert(observation.complete);row.roles[role]={outcome:observation.outcome,...(observation.outcome==='return'?{value:observation.value}:{error:observation.error}),events:observation.events};}
    } catch(error) {roleFailures.push({role,error:error.stack??String(error)});const raw=path.join(out,c.id+'--'+test.id+'--'+role+'.json');if(fs.existsSync(raw))row.rawObservations={...row.rawObservations,[role]:JSON.parse(fs.readFileSync(raw,'utf8'))};}
   }
   if(roleFailures.length){row.roleFailures=roleFailures;if(row.rawObservations?.typescript&&row.rawObservations?.direct){row.observedValues={typescript:row.rawObservations.typescript.value,direct:row.rawObservations.direct.value};row.observedValueAgreement=JSON.stringify(row.observedValues.typescript)===JSON.stringify(row.observedValues.direct);}if(c.id==='f32_table_nan_bits'&&test.id==='nan-table-bits'&&test.expected===40)row.limitation='Both roles observed independently; source golden40 retained. Upstream JS literal NaN table loses signaling payload distinctions; host JS NaN conversion is not the C golden contract. This classification never converts an oracle or differential failure to PASS.';assert.equal(roleFailures.length,0,'one or more role source oracles failed');}
   assert.deepEqual(row.roles.direct,row.roles.typescript,'TS callable/observable contract mismatch '+c.id+'/'+test.id);row.pass=true;
   }catch(error){row.pass=false;row.error=error.stack??String(error);for(const role of ['typescript','direct']){const f=path.join(out,c.id+'--'+test.id+'--'+role+'.json');if(fs.existsSync(f))row.rawObservations={...row.rawObservations,[role]:JSON.parse(fs.readFileSync(f,'utf8'))};}}
   report.observations.push(row);
  }
 }
 report.complete=true;report.counts={pass:report.observations.filter(x=>x.pass).length,fail:report.observations.filter(x=>!x.pass).length,total:report.observations.length};report.pass=report.counts.fail===0&&report.counts.total===catalog.cases.reduce((n,c)=>n+c.tests.length,0);if(!report.pass)process.exitCode=1;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:report.complete,pass:report.pass,observations:report.observations.length,error:report.error}));
