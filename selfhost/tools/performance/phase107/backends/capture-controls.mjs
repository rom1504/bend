// Test the trusted host capture boundary; no machine backend runs here.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {inspect,loadApi,apiPath,basePath,driverPath} from '../../../typed-driver.mjs';
const [sourceArg,outputArg] = process.argv.slice(2);
const source = path.resolve(sourceArg), output = path.resolve(outputArg);
assert(!fs.existsSync(output));
fs.mkdirSync(output,{recursive:true});
const pin = file => ({file,bytes:fs.statSync(file).size,
  sha256:crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const report = {complete:false,inputs:[source,apiPath,basePath,driverPath,import.meta.filename].map(pin),rows:[]};
const run = async(name,file,options) => {
  const start=performance.now(), result=await inspect(file,options);
  const {checkedGraph,...observation}=result;
  report.rows.push({name,seconds:(performance.now()-start)/1000,observation,
    ...(checkedGraph?{graphSha256:crypto.createHash('sha256').update(JSON.stringify(checkedGraph)).digest('hex')}: {})});
  return result;
};
try {
  const captured=await run('owned-capture',source,{mode:'native',captureCheckedGraph:true});
  assert.equal(captured.status,'ok',captured.diagnostic||captured.reason);
  assert.equal(captured.checked,true); assert.equal(captured.typeAccepted,true);
  assert.equal(captured.foreignValidated,false); assert(captured.checkedGraph);
  assert(!Object.hasOwn(captured,'code')); assert(!Object.hasOwn(captured,'context'));
  assert(captured.files.includes(source));
  const api=await loadApi();
  let previous;
  const wrapped={...api,annotate_selected:(...args)=>{
    previous=api.annotate_selected(...args);return previous;
  },nc_compile_checked:()=>({source:'capture-control',error:''}),
    nc_compile:()=>({source:'capture-control',error:''})};
  const legacy=await run('legacy-wrapper-control',source,{mode:'native',api:wrapped});
  assert.equal(legacy.status,'ok',legacy.diagnostic||legacy.reason);
  assert.deepEqual(captured.checkedGraph,previous);
  report.sameGraphAsLegacy=true;
  for (const [name,options] of [
    ['injected-api',{mode:'native',captureCheckedGraph:true,api:{}}],
    ['wrong-mode',{mode:'parse',captureCheckedGraph:true}],
    ['wrong-option-type',{mode:'native',captureCheckedGraph:'yes'}],
  ]) {
    const result=await run(name,source,options);
    assert.equal(result.status,'error'); assert.equal(result.phase,'load');
    assert(!Object.hasOwn(result,'checkedGraph'));
    assert.match(result.diagnostic,/captureCheckedGraph/);
  }
  const bad=path.resolve(import.meta.dirname,'../../../../tests/conformance/typed-smoke/bad-type.bend');
  const rejection=await run('invalid-source',bad,{mode:'native',captureCheckedGraph:true});
  assert.equal(rejection.status,'error'); assert.equal(rejection.phase,'check');
  assert.equal(rejection.typeAccepted,false); assert(!Object.hasOwn(rejection,'checkedGraph'));
  for(const item of report.inputs)assert.deepEqual(pin(item.file),item);
  report.complete=true;
} finally {
  fs.writeFileSync(path.join(output,'report.json'),JSON.stringify(report,null,2)+'\n');
}
console.log(JSON.stringify({complete:true,checks:report.rows.length,sameGraphAsLegacy:report.sameGraphAsLegacy}));
