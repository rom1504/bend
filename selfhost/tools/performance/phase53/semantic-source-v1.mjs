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
const defectFile=path.join(import.meta.dirname,'semantic-reference-defect-v1.json');const defect=JSON.parse(fs.readFileSync(defectFile,'utf8'));assert.equal(defect.fixture,'f32_table_nan_bits');assert.equal(defect.test,'nan-table-bits');assert.equal(defect.unchangedSourceGolden,40);assert.equal(defect.requiredCandidateValue,40);assert.equal(defect.knownPinnedTypeScriptValue,1);assert.equal(defect.pinnedUpstream,catalog.upstreamCommit);verify(defect.source,import.meta.dirname);
const selected=JSON.parse(fs.readFileSync(selectedAttempt,'utf8'));assert.equal(selected.checked,true);const acquisitionFile=verify(m.parents[0],path.dirname(path.resolve(manifestFile)));const acquisition=JSON.parse(fs.readFileSync(acquisitionFile,'utf8'));assert(acquisition.complete&&acquisition.passed);assert.deepEqual(acquisition.roles.direct,m.roles.direct);assert.deepEqual(acquisition.catalog,m.catalog);const snapshotRoot=fs.realpathSync(selected.snapshot.root);const frozenSources=new Map(selected.snapshot.sources.map(row=>[fs.realpathSync(row.frozen.file),row.frozen.sha256]));
const directIdentity={};
const retained=path.join(import.meta.dirname,'../phase52');
const worker=path.join(retained,'semantic-worker-v4.mjs'),programWorker=path.join(retained,'semantic-program-worker-v2.mjs'),directProgramWorker=path.join(retained,'semantic-direct-program-worker-v1.mjs');
assert.equal(catalog.cases.length,29);assert.equal(catalog.cases.reduce((n,c)=>n+c.tests.length,0),96);
const report={kind:'phase53-independent-source-semantic-qualification',complete:false,pass:false,executed:true,selectedScope:catalog.selectedScope??{fixtures:18,scenarios:59,kind:'full-independent-plan'},inputs:[identity(selectedAttempt),identity(acquisitionFile),identity(verify(defect.parentController,import.meta.dirname)),identity(defectFile),identity(path.join(retained,'semantic-runner-v9.mjs')),identity(manifestFile),identity(catalogFile),identity(import.meta.filename),identity(worker),identity(programWorker),identity(directProgramWorker)],observations:[],programAdapters:{typescript:{moduleForm:'CommonJS',identity:identity(programWorker),code:fs.readFileSync(programWorker,'utf8')},direct:{moduleForm:'ESM',identity:identity(directProgramWorker),code:fs.readFileSync(directProgramWorker,'utf8')}},scope:'Candidate source-oracle qualification on all unchanged96 scenarios. TS source-oracle and differential counts remain separate. Only the exact frozen signaling-NaN table fixture may record TS1 defect versus independently required candidate40; every other TS/candidate divergence or error fails. No dropped scenario, legacy G or universal conformance claim.'};
try{
 for(const c of catalog.cases){
  const source=verify(c.source,path.dirname(catalogFile));report.inputs.push(identity(source));for(const input of c.auxiliary??[])report.inputs.push(identity(verify(input,path.dirname(catalogFile))));
  const modules={};
  for(const role of ['typescript','direct']){
   const file=path.resolve(path.dirname(path.resolve(manifestFile)),m.roles[role].modules[c.id]);const receiptFile=file+'.json',receipt=JSON.parse(fs.readFileSync(receiptFile,'utf8'));
   assert.equal(receipt.kind,'bend-program-checked-emission');assert(receipt.complete&&receipt.observation.checked&&receipt.observation.status==='ok');
   verify(receipt.output,path.dirname(receiptFile));assert.equal(fs.realpathSync(receipt.output.file??receipt.output.path),fs.realpathSync(file));assert.equal(receipt.input.sha256,identity(source).sha256);
   if(role==='direct'){assert.equal(receipt.compiler.backend,'direct');assert.equal(receipt.compiler.callingContract,'upstream-compatible-direct-v1');assert.equal(receipt.compiler.kind,'checked-development-attempt');assert(receipt.attempt);verify(receipt.attempt,path.dirname(receiptFile));assert.equal(receipt.attempt.sha256,m.roles.direct.attempt.sha256);assert.equal(receipt.observation.exitCode,0);for(const key of ['api','runtime','base'])assert.equal(receipt.compiler[key].sha256,selected[key].sha256);assert.equal(fs.realpathSync(receipt.compiler.driver.file),path.join(snapshotRoot,'tools/typed-driver.mjs'));assert.equal(fs.realpathSync(receipt.compiler.directRuntime.file),path.join(snapshotRoot,'src/runtime/js/direct.mjs'));for(const key of ['driver','directRuntime'])assert.equal(receipt.compiler[key].sha256,frozenSources.get(fs.realpathSync(receipt.compiler[key].file)));for(const key of ['api','runtime','base','driver','directRuntime']){assert(receipt.compiler[key]);report.inputs.push(identity(verify(receipt.compiler[key],path.dirname(receiptFile))));if(directIdentity[key])assert.equal(receipt.compiler[key].sha256,directIdentity[key]);else directIdentity[key]=receipt.compiler[key].sha256;}assert(Array.isArray(receipt.emissionInputs)&&receipt.emissionInputs.length>=3);for(const input of receipt.emissionInputs)report.inputs.push(identity(verify(input,path.dirname(receiptFile))));}
   else {assert.equal(receipt.compiler.kind,'checked-pinned-typescript');for(const input of receipt.compiler.sources)report.inputs.push(identity(verify(input,path.dirname(receiptFile))));}
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
   row.candidateSourcePass=!!row.roles.direct;row.referenceSourcePass=!!row.roles.typescript;
   if(roleFailures.length){
    row.roleFailures=roleFailures;
    const reference=row.rawObservations?.typescript;
    const exactDefect=c.id==='f32_table_nan_bits'&&test.id==='nan-table-bits'&&test.expected===40&&c.source.sha256==='31831beb2bf79da469bfca1e65448bb8c0a48082d966e0059165e4b569864d0a';
    const known=exactDefect&&roleFailures.length===1&&roleFailures[0].role==='typescript'&&reference?.value===1&&reference.complete===false&&reference.error?.name==='AssertionError'&&reference.error.message.includes('independent expected value')&&row.roles.direct?.outcome==='return'&&row.roles.direct.value===40;
    if(known){row.knownReferenceDefect=true;row.referenceSourcePass=false;row.differentialAgreement=false;row.observedValues={typescript:1,direct:40};row.pass=true;row.scope='Candidate satisfies unchanged source golden40. Exact frozen TS signaling-NaN table defect remains failed and different; not a differential pass or a generalized exception.';report.observations.push(row);continue;}
    assert.equal(roleFailures.length,0,'source oracle failed outside exact independently documented TS table defect');
   }
   assert.deepEqual(row.roles.direct,row.roles.typescript,'TS callable/observable contract mismatch '+c.id+'/'+test.id);row.differentialAgreement=true;row.pass=true;
   }catch(error){row.pass=false;row.error=error.stack??String(error);for(const role of ['typescript','direct']){const f=path.join(out,c.id+'--'+test.id+'--'+role+'.json');if(fs.existsSync(f))row.rawObservations={...row.rawObservations,[role]:JSON.parse(fs.readFileSync(f,'utf8'))};}}
   report.observations.push(row);
  }
 }
 report.inputs=[...new Map(report.inputs.map(x=>[x.file,x])).values()];report.changedInputs=report.inputs.filter(row=>{try{return identity(row.file).sha256!==row.sha256;}catch{return true;}});assert.equal(report.changedInputs.length,0,'consumed identities changed during execution');report.complete=true;report.counts={candidateSourcePass:report.observations.filter(x=>x.candidateSourcePass).length,referenceSourcePass:report.observations.filter(x=>x.referenceSourcePass).length,differentialAgreement:report.observations.filter(x=>x.differentialAgreement).length,knownReferenceDefects:report.observations.filter(x=>x.knownReferenceDefect).length,total:report.observations.length};report.pass=report.observations.every(x=>x.pass)&&report.counts.candidateSourcePass===96&&report.counts.total===96;if(!report.pass)process.exitCode=1;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:report.complete,pass:report.pass,observations:report.observations.length,error:report.error}));
