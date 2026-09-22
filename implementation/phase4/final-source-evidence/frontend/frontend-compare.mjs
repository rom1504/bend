// Compare complete observation inventories, including known failures. A harness
// verdict is not interchangeable with the compiler observation that produced it.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';

const [candidate, reference, previousCandidate, previousReference, output] = process.argv.slice(2);
if (!output) throw Error('Usage: frontend-compare.mjs CANDIDATE REFERENCE PREVIOUS_CANDIDATE PREVIOUS_REFERENCE NEW_OUTPUT_JSON');
const files = {candidate, reference, previousCandidate, previousReference};
const reports = {}, maps = {}, identities = {};
const sha = file => createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const key = row => row.id + '::' + row.lane;
const inventory = report => report.inventory.tests.map(row => [row.id, row.sha256]).sort((a, b) => a[0].localeCompare(b[0]));
const observation = row => {
  const value = row.result ?? {};
  return {
    semantic: Object.fromEntries(['status', 'phase', 'checked', 'exitCode', 'signal'].map(name => [name, value[name] ?? null])),
    text: value.diagnostic ?? value.output ?? value.stdout ?? '',
  };
};
const same = (a, b) => JSON.stringify(observation(a)) === JSON.stringify(observation(b));
const sameSemantic = (a, b) => JSON.stringify(observation(a).semantic) === JSON.stringify(observation(b).semantic);
for (const [name, argument] of Object.entries(files)) {
  const file = fs.realpathSync(argument), report = JSON.parse(fs.readFileSync(file));
  identities[name] = {file: path.resolve(argument), canonicalPath: file, sha256: sha(file)};
  assert.equal(report.inventory.total, 1378, name + ': incomplete fixture inventory');
  assert.equal(report.results.length, 2756, name + ': incomplete observation inventory');
  assert.equal(report.changedInputs.length, 0, name + ': changed fixture inputs');
  assert.equal(report.identity.changedArtifacts.length, 0, name + ': changed compiler artifacts');
  assert.equal(report.identity.adapterChangedDuringRun, false, name + ': changed adapter');
  assert.ok(report.workers.every(worker => worker.errors.length === 0), name + ': worker infrastructure errors');
  assert.ok(report.results.every(row => !['timeout', 'crash', 'unsupported'].includes(row.result?.status) && !['timeout', 'crash', 'unsupported'].includes(row.status)), name + ': incomplete observation');
  reports[name] = report;
  maps[name] = new Map(report.results.map(row => [key(row), row]));
  assert.equal(maps[name].size, report.results.length, name + ': duplicate probe keys');
}
for (const [name, report] of Object.entries(reports)) {
  assert.deepEqual(inventory(report), inventory(reports.candidate), name + ': different fixture bytes');
  assert.deepEqual([...maps[name].keys()].sort(), [...maps.candidate.keys()].sort(), name + ': different probes');
}
const changes = [], referenceChanges = [], mismatches = [], added = [], resolved = [];
for (const id of [...maps.candidate.keys()].sort()) {
  const now = maps.candidate.get(id), ref = maps.reference.get(id);
  const old = maps.previousCandidate.get(id), oldRef = maps.previousReference.get(id);
  if (!same(now, old)) changes.push({key: id, previous: observation(old), current: observation(now), previousVerdict: old.status, currentVerdict: now.status});
  if (!same(ref, oldRef)) referenceChanges.push({key: id, previous: observation(oldRef), current: observation(ref)});
  if (!same(now, ref)) {
    const row = {key: id, kind: sameSemantic(now, ref) ? 'exact-diagnostic-or-report' : 'acceptance-or-phase', candidate: observation(now), reference: observation(ref), existedPreviously: !same(old, oldRef)};
    mismatches.push(row);
    if (!row.existedPreviously) added.push(row);
  } else if (!same(old, oldRef)) resolved.push(id);
}
for (const input of Object.values(identities)) {
  assert.equal(fs.realpathSync(input.file), input.canonicalPath);
  assert.equal(sha(input.file), input.sha256, 'Comparison input changed');
}
const result = {
  kind: 'phase4-exact-frontend-comparison', complete: true,
  scope: 'All pinned parse/check observations and exact diagnostics, including retained failures. Workflow times are unpaired observations; this is not full-language conformance.',
  files: identities, fixtureCount: 1378, probeCount: 2756, sameFixtureBytes: true, inputsUnchanged: true,
  historicalBehaviorChanges: changes, referenceChanges, liveMismatches: mismatches,
  newLiveMismatches: added, resolvedLiveMismatches: resolved,
  behaviorPreserved: changes.length === 0 && referenceChanges.length === 0,
  summaries: Object.fromEntries(Object.entries(reports).map(([name, report]) => [name, report.summary])),
  workflowMilliseconds: Object.fromEntries(['candidate', 'reference'].map(name => [name, Date.parse(reports[name].finished) - Date.parse(reports[name].started)])),
  workerStats: Object.fromEntries(['candidate', 'reference'].map(name => [name, reports[name].workers])),
  fullConformance: Object.fromEntries(['candidate', 'reference'].map(name => [name, reports[name].complete])),
};
fs.writeFileSync(output, JSON.stringify(result, null, 2) + '\n', {flag: 'wx'});
console.log(JSON.stringify({complete: result.complete, behaviorPreserved: result.behaviorPreserved, changes: changes.length, referenceChanges: referenceChanges.length, mismatches: mismatches.length, added: added.length, resolved: resolved.length}));
