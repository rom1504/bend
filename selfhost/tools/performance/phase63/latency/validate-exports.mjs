// Root-only checked-API validation; this does not execute benchmark programs.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
const [referenceFile,out]=process.argv.slice(2);
assert.ok(referenceFile&&out&&!fs.existsSync(out));
const identity=file=>({file:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const inputs=[];
const pin=value=>{const id=identity(typeof value==='string'?value:value.file);if(typeof value!=='string')assert.equal(id.sha256,value.sha256);inputs.push(id);return id;};
const read=value=>JSON.parse(fs.readFileSync(pin(value).file,'utf8'));
const result={kind:'phase63-checked-export-validation',complete:false,pass:false,inputs};
try {
  const reference=read(referenceFile);assert.equal(reference.kind,'phase61-checked-bootstrap-export-reference');
  const attempt=await verifyAttempt(path.dirname(pin(reference.attempt).file));
  const boot=read(reference.bootstrap),admission=read(reference.admission);
  assert.deepEqual(reference.roots,boot.exports);assert.equal(reference.roots.length,94);
  assert.equal(pin(path.join(attempt.snapshot.root,'tools/typed-driver.mjs')).sha256,pin(admission.driver).sha256);
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
  process.env.BEND_TYPED_API=attempt.api.file;process.env.BEND_TYPED_RUNTIME=attempt.runtime.file;process.env.BEND_BASE=attempt.base.file;
  const D=await import(pathToFileURL(path.join(attempt.snapshot.root,'tools/typed-driver.mjs')));
  const api=await D.loadApi(),module=await import(pathToFileURL(pin(attempt.api).file));
  assert.deepEqual(Object.keys(module.default).sort(),[...reference.roots].sort());
  for(const name of reference.roots)assert.equal(typeof api[name],'function',name);
  for(const item of inputs)assert.deepEqual(identity(item.file),item);
  result.reference=identity(referenceFile);result.attempt=reference.attempt;result.api=pin(attempt.api);
  result.roots=reference.roots;result.complete=result.pass=true;
} catch(error){result.error=String(error?.stack??error);process.exitCode=1}
finally{fs.writeFileSync(out,JSON.stringify(result,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:result.complete,pass:result.pass,error:result.error}));}
