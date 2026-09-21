#!/usr/bin/env node
// Merge complete, disjoint probe groups without replacing or dropping verdicts.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {probes,sha256} from './inventory.mjs';

export function mergeReports(entries) {
  assert.ok(entries.length, 'No reports supplied');
  const first=entries[0].report, expected=new Map(), seen=new Set(), results=[];
  const key=r=>r.id+'\0'+r.lane;
  for(const test of first.inventory.tests) for(const probe of probes(test)) {
    const k=key({id:test.id,...probe});
    assert.ok(!expected.has(k),'Duplicate fixture in inventory');
    expected.set(k,test);
  }
  for(const {file,report:r} of entries) {
    assert.ok(r.finished,`Unfinished report: ${file}`);
    assert.deepEqual(r.inventory,first.inventory,'Different pinned fixture inventories');
    assert.deepEqual(r.host,first.host,'Different execution hosts');
    assert.deepEqual(r.identity,first.identity,'Different compiler or host artifacts');
    assert.equal(r.identity.adapterChangedDuringRun,false,'Adapter changed during run');
    assert.deepEqual(r.identity.changedArtifacts,[],'Artifacts changed during run');
    assert.equal(r.identity.finalAdapterSha256,r.identity.adapterSha256,'Adapter hash mismatch');
    for(const [name,artifact] of Object.entries(r.identity.artifacts))
      assert.equal(r.identity.finalArtifactHashes[name],artifact.sha256,'Artifact hash mismatch');
    for(const option of ['upstream','adapter','timeout','gpu'])
      assert.deepEqual(r.options[option],first.options[option],`Different ${option} policies`);
    for(const row of r.results) {
      const k=key(row),test=expected.get(k);
      assert.ok(test,`Unexpected probe: ${row.id} ${row.lane}`);
      assert.ok(!seen.has(k),`Duplicate probe: ${row.id} ${row.lane}`);
      assert.equal(row.negative,test.negative,'Incorrect negative classification');
      assert.equal(row.namespace,test.namespace,'Incorrect namespace');
      seen.add(k);results.push(row);
    }
  }
  assert.equal(seen.size,expected.size,`Missing probes: ${expected.size-seen.size}`);
  const lanes=['parse','check','interpreter','js','native','metal','cuda'];
  results.sort((a,b)=>a.id.localeCompare(b.id)||lanes.indexOf(a.lane)-lanes.indexOf(b.lane));
  const counts=rows=>rows.reduce((out,r)=>(out[r.status]=(out[r.status]||0)+1,out),{});
  return {
    schemaVersion:1,method:'disjoint-shards',coverageComplete:true,
    started:entries.map(e=>e.report.started).sort()[0],
    finished:entries.map(e=>e.report.finished).sort().at(-1),
    host:first.host,options:{...first.options,filter:'',lanes:lanes.join(','),jobs:null,output:null},
    identity:first.identity,
    complete:results.every(r=>r.status==='pass'||r.status==='not-applicable'||(r.lane==='parse'&&r.status==='observed')),
    shards:entries.map(({file,sha256,report})=>({file,sha256,started:report.started,finished:report.finished,options:report.options,probes:report.results.length})),
    summary:{tests:first.inventory.total,allTests:first.inventory.total,excludedTests:0,probes:results.length,
      statuses:counts(results),lanes:Object.fromEntries(lanes.map(l=>[l,counts(results.filter(r=>r.lane===l))])),
      namespaces:Object.fromEntries(Object.keys(first.inventory.namespaces).map(n=>[n,counts(results.filter(r=>r.namespace===n))])),
      checkerRejections:results.filter(r=>r.evidence==='checker-rejection').length,
      frontendRejections:results.filter(r=>r.evidence==='frontend-rejection').length,
      uncheckedExecutions:results.filter(r=>r.evidence==='unchecked-execution').length},
    inventory:first.inventory,results
  };
}

if(process.argv[1]&&path.resolve(process.argv[1])===fileURLToPath(import.meta.url)) {
  const [output,...files]=process.argv.slice(2);
  if(!output||!files.length)throw Error('Usage: merge-reports.mjs OUTPUT.json SHARD.json ...');
  const report=mergeReports(files.map(file=>{
    const bytes=fs.readFileSync(file);return {file,sha256:sha256(bytes),report:JSON.parse(bytes)};
  }));
  fs.writeFileSync(output,JSON.stringify(report,null,2)+'\n');
  console.log(JSON.stringify({coverageComplete:report.coverageComplete,complete:report.complete,probes:report.results.length}));
}
