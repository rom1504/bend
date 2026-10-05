// Independently validate the composition oracle before testing a candidate.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';
const [manifestArgument,outArgument]=process.argv.slice(2);
assert(manifestArgument&&outArgument);
const out=path.resolve(outArgument);assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const inputs=[];
const identity=file=>({file:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const pin=file=>{const row=identity(file);inputs.push(row);return row.file;};
const verify=(row,origin)=>{const file=path.resolve(origin,row.file??row.path);assert.equal(identity(file).sha256,row.sha256);return pin(file);};
const read=file=>JSON.parse(fs.readFileSync(pin(file),'utf8'));
const report={kind:'phase53-independent-composition-reference-controls',complete:false,pass:false,executed:true,inputs,observations:[],scope:'Pinned TypeScript only; every independent value/error/event oracle is mandatory. No candidate qualification.'};
try{
 pin(import.meta.filename);
 const worker=pin(path.join(import.meta.dirname,'semantic-worker-v1.mjs'));
 const manifestFile=pin(manifestArgument),m=read(manifestFile);assert(m.complete&&m.passed);assert.deepEqual(Object.keys(m.roles),['typescript']);
 const catalogFile=verify(m.catalog,path.dirname(manifestFile)),catalog=read(catalogFile);assert.equal(catalog.cases.length,1);
 const c=catalog.cases[0];assert.equal(c.id,'composition-order');assert.equal(c.tests.length,14);
 const source=verify(c.source,path.dirname(catalogFile)),module=pin(m.roles.typescript.modules[c.id]),receiptFile=module+'.json',receipt=read(receiptFile);
 assert.equal(receipt.kind,'bend-program-checked-emission');assert(receipt.complete&&receipt.observation.checked&&receipt.observation.status==='ok');assert.equal(verify(receipt.output,path.dirname(receiptFile)),module);
 assert.equal(receipt.input.sha256,identity(source).sha256);assert.equal(receipt.compiler.kind,'checked-pinned-typescript');assert.equal(receipt.compiler.upstreamCommit,catalog.upstreamCommit);
 for(const row of receipt.compiler.sources)verify(row,path.dirname(receiptFile));
 for(const test of c.tests){
  const stem=path.join(out,test.id),config=stem+'--config.json',observationFile=stem+'.json';fs.writeFileSync(config,JSON.stringify(test,null,2)+'\n',{flag:'wx'});pin(config);
  const result=spawnSync(process.execPath,['--max-old-space-size=1024','--stack-size=4096',worker,module,config,observationFile],{encoding:'utf8',timeout:30000,maxBuffer:1024*1024});
  fs.writeFileSync(stem+'.stdout',result.stdout??'',{flag:'wx'});fs.writeFileSync(stem+'.stderr',result.stderr??'',{flag:'wx'});
  const observation=fs.existsSync(observationFile)?read(observationFile):null;
  let pass=!result.error&&!result.signal&&result.status===0&&observation?.complete&&!observation.failure;
  pass=pass&&observation.outcome===(test.expectedError?'throw':'return');
  if(test.expectedError)pass=pass&&observation.error?.message?.includes(test.expectedError);
  else pass=pass&&JSON.stringify(observation.value)===JSON.stringify(test.expected);
  pass=pass&&JSON.stringify(observation.events)===JSON.stringify(test.expectedEvents);
  report.observations.push({id:test.id,pass:!!pass,status:result.status,error:result.error?.message??null,signal:result.signal,observation});
 }
 report.inputs=[...new Map(inputs.map(row=>[row.file,row])).values()];
 report.changedInputs=report.inputs.filter(row=>{try{return identity(row.file).sha256!==row.sha256;}catch{return true;}});assert.equal(report.changedInputs.length,0);
 report.complete=true;report.counts={pass:report.observations.filter(row=>row.pass).length,total:report.observations.length};report.pass=report.counts.pass===14;
}catch(error){report.error=error.stack??String(error);}
if(!report.pass)process.exitCode=1;
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,counts:report.counts,error:report.error}));
