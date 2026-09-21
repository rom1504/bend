import assert from 'node:assert/strict';
import {test} from 'node:test';
import {mergeReports} from '../../tools/conformance/merge-reports.mjs';

function reports() {
  const tests=['a','b'].map(id=>({id,namespace:'unit',negative:false,main:false}));
  const base={started:'2026-01-01',finished:'2026-01-02',host:{node:'test'},
    inventory:{total:2,tests,namespaces:{unit:{total:2}}},
    identity:{adapterSha256:'adapter',finalAdapterSha256:'adapter',adapterChangedDuringRun:false,
      artifacts:{compiler:{file:'compiler',sha256:'api'}},finalArtifactHashes:{compiler:'api'},changedArtifacts:[]},
    options:{upstream:'upstream',adapter:'adapter',timeout:300000,gpu:''}};
  return tests.map(t=>({file:t.id,sha256:t.id,report:{...structuredClone(base),
    results:['parse','check'].map(lane=>({id:t.id,namespace:t.namespace,negative:false,lane,status:'pass'}))}}));
}
test('disjoint coverage preserves failed verdicts and distinguishes coverage from conformance',()=>{
  const r=reports();r[1].report.results[1].status='timeout';
  const merged=mergeReports(r);
  assert.equal(merged.coverageComplete,true);assert.equal(merged.complete,false);
  assert.equal(merged.results.length,4);assert.equal(merged.summary.statuses.timeout,1);
  assert.deepEqual(merged.results.at(-1),r[1].report.results[1]);
});
test('missing, duplicate and unexpected probes cannot make a complete merged report',()=>{
  assert.throws(()=>mergeReports(reports().slice(0,1)),/Missing probes/);
  const duplicate=reports();duplicate.push(duplicate[0]);assert.throws(()=>mergeReports(duplicate),/Duplicate probe/);
  const extra=reports();extra[0].report.results[0].lane='native';assert.throws(()=>mergeReports(extra),/Unexpected probe/);
});
test('changed artifacts, policies, inventories and unfinished runs are rejected',()=>{
  for(const edit of [
    r=>{r.identity.changedArtifacts=['compiler'];},
    r=>{r.identity.finalArtifactHashes.compiler='changed';},
    r=>{r.options.timeout=600000;},
    r=>{r.host.workerNodeArgs=['--stack-size=8192'];},
    r=>{r.inventory.tests[0].negative=true;},
    r=>{delete r.finished;}
  ]){const rows=reports();edit(rows[1].report);assert.throws(()=>mergeReports(rows));}
});
