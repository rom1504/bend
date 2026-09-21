import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import test from 'node:test';
import {inventory,probes} from '../../tools/conformance/inventory.mjs';
const project=path.resolve(import.meta.dirname,'../..');
const upstream=process.env.BEND_UPSTREAM||path.resolve(project,'../upstream-bend');
const available=fs.existsSync(path.join(upstream,'tests'));
test('pinned corpus is exhaustive and includes every negative namespace',{skip:!available},()=>{
  const inv=inventory(upstream);
  assert.equal(inv.total,1378);
  assert.equal(Object.keys(inv.namespaces).length,24);
  assert.equal(inv.tests.filter(t=>t.negative).length,459);
  assert.equal(inv.tests.filter(t=>!t.hasExpectation).length,0);
  assert.equal(new Set(inv.tests.map(t=>t.id)).size,inv.total);
  assert.equal(inv.effects.length,80);
  for(const fixture of inv.tests) {
    assert.ok(probes(fixture).some(p=>p.lane==='check'));
    if(fixture.main) assert.ok(probes(fixture).some(p=>p.lane==='interpreter')); 
    if(fixture.foreign.length) {
      for(const lane of fixture.backends) assert.ok(fixture.foreign.some(f=>f.backend===lane));
    }
  }
});
test('infinite compiler probe is killed and filtered run cannot claim completeness',{skip:!available},()=>{
  const temporary=fs.mkdtempSync(path.join(os.tmpdir(),'bend-harness-test-'));
  try {
    const adapter=path.join(temporary,'hang.mjs'),output=path.join(temporary,'result.json');
    fs.writeFileSync(adapter,"export const capabilities={parse:true}; export async function probe(){while(true){}}\n");
    const id=inventory(upstream).tests[0].id.replace(/[.*+?^${}()|[\]\\]/g,'\\$&');
    const child=spawnSync(process.execPath,[path.join(project,'tools/conformance/run.mjs'),'--upstream',upstream,'--adapter',adapter,
      '--output',output,'--filter','^'+id+'$','--lanes','parse','--timeout','100','--jobs','1'],
      {encoding:'utf8',timeout:10000});
    assert.equal(child.status,1,child.stderr);
    const report=JSON.parse(fs.readFileSync(output,'utf8'));
    assert.equal(report.complete,false);
    assert.equal(report.summary.excludedTests,1377);
    assert.equal(report.results[0].status,'timeout');
  } finally {fs.rmSync(temporary,{recursive:true,force:true});}
});
