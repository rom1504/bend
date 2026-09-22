import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import {runProbe} from '../../tools/conformance/run-probe.mjs';

function fixture(t,body) {
  const workdir=fs.mkdtempSync(path.join(os.tmpdir(),'bend-isolated-capture-'));
  t.after(()=>fs.rmSync(workdir,{recursive:true,force:true}));
  const worker=path.join(workdir,'worker.mjs'),response=path.join(workdir,'response.json');
  fs.writeFileSync(worker,"import fs from 'node:fs';const request=JSON.parse(fs.readFileSync(process.argv[2]));\n"+body);
  return {worker,request:{workdir,response,timeoutMs:3000}};
}
test('isolated capture rejects combined fast descriptor overflow despite a valid response',async t=>{
  const f=fixture(t,"fs.writeSync(1,Buffer.alloc(600000,120));fs.writeSync(2,Buffer.alloc(600000,121));fs.writeFileSync(request.response,JSON.stringify({status:'ok'}));");
  const result=await runProbe(f.request,{worker:f.worker});
  assert.equal(result.status,'crash');assert.match(result.reason,/output limit/);
  for(const name of ['worker.stdout','worker.stderr'])assert.ok(fs.statSync(path.join(f.request.workdir,name)).size<=2**20);
});
test('isolated capture does not accept a valid response from a signalled worker',async t=>{
  const f=fixture(t,"fs.writeFileSync(request.response,JSON.stringify({status:'ok'}));process.kill(process.pid,'SIGTERM');");
  const result=await runProbe(f.request,{worker:f.worker});
  assert.equal(result.status,'crash');assert.equal(result.signal,'SIGTERM');
});
test('isolated capture preserves a normal nonzero compiler rejection',async t=>{
  const expected={status:'error',phase:'check',checked:true,diagnostic:'controlled',exitCode:1};
  const f=fixture(t,'fs.writeFileSync(request.response,'+JSON.stringify(JSON.stringify(expected))+');process.exitCode=1;');
  assert.deepEqual(await runProbe(f.request,{worker:f.worker}),expected);
});
test('isolated capture cannot reuse a stale response when a worker produces none',async t=>{
  const f=fixture(t,'// no response');fs.writeFileSync(f.request.response,JSON.stringify({status:'ok'}));
  const result=await runProbe(f.request,{worker:f.worker});
  assert.equal(result.status,'crash');assert.match(result.reason,/no valid result/);
});
