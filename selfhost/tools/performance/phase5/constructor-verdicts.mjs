// Observe only the authoritative checker calls already made by the normal host.
// This is diagnostic-change evidence, not a replacement checker or oracle.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {verifyAttempt,identity,verifyIdentity} from '../../development/workflow.mjs';

const [attemptArg,casesArg,outputArg]=process.argv.slice(2);
if(!outputArg||fs.existsSync(outputArg))throw Error('Usage: constructor-verdicts.mjs VERIFIED_ATTEMPT CASES.json NEW_REPORT');
const attempt=fs.realpathSync(attemptArg),casesFile=fs.realpathSync(casesArg),m=await verifyAttempt(attempt);
assert.equal(m.artifactKind,'checked-b1');
const document=JSON.parse(fs.readFileSync(casesFile)),cases=Array.isArray(document)?document:document.cases;
const records=cases.map(row=>({...row,file:fs.realpathSync(path.resolve(path.dirname(casesFile),row.file))}));
const inputs=[import.meta.filename,path.join(import.meta.dirname,'../../development/workflow.mjs'),path.join(attempt,'attempt.json'),casesFile,...records.map(row=>row.file)].map(identity);
const report={kind:'phase5-authoritative-constructor-verdicts',complete:false,api:m.api,attempt:inputs[2],inputs,rows:[]};
const save=()=>fs.writeFileSync(outputArg,JSON.stringify(report,null,2)+'\n');
try {
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_')||key==='NODE_OPTIONS')delete process.env[key];
  Object.assign(process.env,{BEND_TYPED_API:m.api.file,BEND_TYPED_RUNTIME:m.runtime.file,BEND_BASE:m.base.file,BEND_UPSTREAM:m.config.upstream});
  const D=await import(pathToFileURL(path.join(m.snapshot.root,'tools/typed-driver.mjs'))),api=await D.loadApi();
  await D.prepareBase(api);
  for(const row of records){
    const calls=[],wrapped={...api};
    for(const name of ['check_book','check_from_exact_prefix'])if(api[name])wrapped[name]=(...args)=>{const result=api[name](...args);calls.push({name,error:result});return result;};
    const result=await D.inspect(row.file,{api:wrapped,mode:'check'});
    assert.equal(calls.length,1,'Expected one authoritative host checker call: '+row.id);
    assert.equal(typeof calls[0].error,'string');
    report.rows.push({id:row.id,source:identity(row.file),authoritative:calls[0],result});save();
  }
  await verifyAttempt(attempt);inputs.forEach(verifyIdentity);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,cases:report.rows.length,error:report.error}));
