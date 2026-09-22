// Exact whole-source gate for the surviving P4-024 derived image. Not a bootstrap.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {spawn} from 'node:child_process';
import {identity, verifyIdentity} from '../../private-compiler/common.mjs';
import {nativeB1Equality} from './analysis-b1-equality.mjs';

const [pilotArg, proofArg, outputArg] = process.argv.slice(2);
if (!outputArg || process.argv.length !== 5) throw Error('Usage: derived-b1-full.mjs PILOT_REPORT FIXEDPOINT_REPORT NEW_DIRECTORY');
const out = path.resolve(outputArg);
fs.mkdirSync(out, {recursive: false});
const report = {kind: 'phase4-derived-b1-full-source', complete: false,
  newBootstrap: false, started: new Date().toISOString(), inputs: [],
  scope: 'One complete-source correctness gate for a guarded derived B1 image. No paired performance or new bootstrap claim.',
  cpu: 2, timeoutMs: 900000};
const save = () => fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
const capture = file => {
  const item = identity(file);
  const old = report.inputs.find(row => row.file === item.file);
  if (old) assert.deepEqual(item, old);
  else report.inputs.push(item);
  return item.file;
};
const recorded = item => { verifyIdentity(item); capture(item.file); };
const read = file => JSON.parse(fs.readFileSync(capture(file)));
try {
  capture(import.meta.filename); capture(process.execPath);
  capture(new URL('../../private-compiler/common.mjs', import.meta.url));
  capture(new URL('./analysis-b1-equality.mjs', import.meta.url));
  const pilot = read(pilotArg), proof = read(proofArg);
  assert.equal(pilot.complete, true); assert.equal(pilot.inputsUnchanged, true);
  assert.equal(pilot.materialCoreGate, true); assert.equal(pilot.newBootstrap, false);
  assert.equal(pilot.pairRequestReductionsPercent.length, 2);
  assert.ok(pilot.pairRequestReductionsPercent.every(value => Number.isFinite(value) && value >= 5));
  pilot.inputs.forEach(recorded);
  assert.equal(pilot.rows.length, 12);
  assert.ok(pilot.rows.every(row => row.passed === true && row.execution.status === 0 && row.execution.signal === null && !row.execution.error && !row.execution.timedOut));
  for (let repetition = 0; repetition < 2; repetition++) {
    const rows = pilot.rows.filter(row => row.workload === 'core' && row.repetition === repetition);
    assert.equal(rows.length, 2);
    const controlMs = rows.find(row => row.variant === 'control').observation.requestMs;
    const candidateMs = rows.find(row => row.variant === 'candidate').observation.requestMs;
    assert.ok(Number.isFinite(controlMs) && Number.isFinite(candidateMs) && controlMs > 0 && candidateMs > 0);
    assert.ok(100 * (1 - candidateMs / controlMs) >= 5);
  }
  const preparation = read(pilot.inputs[0].file);
  assert.equal(preparation.kind, 'phase4-b1-native-equality-preparation');
  assert.equal(preparation.complete, true); assert.equal(preparation.newBootstrap, false);
  preparation.inputs.forEach(recorded); preparation.variants.forEach(recorded);
  const control = preparation.variants.find(row => row.id === 'control');
  const candidate = preparation.variants.find(row => row.id === 'candidate');
  assert.equal(fs.readFileSync(candidate.file, 'utf8'), nativeB1Equality(fs.readFileSync(control.file, 'utf8')).source);
  assert.equal(proof.complete, true); assert.equal(proof.stages.length, 2);
  for (const item of [proof.sourceIdentity, proof.initialCompiler, proof.base, proof.driver, ...proof.hostHelpers]) recorded(item);
  assert.equal(proof.initialCompiler.sha256, control.sha256);
  assert.deepEqual(pilot.checkedSeed.source, proof.sourceIdentity);
  assert.equal(proof.stages[0].compilerSha256, control.sha256);
  assert.equal(proof.stages[1].compilerSha256, proof.stages[0].outputSha256);
  for (const stage of proof.stages) {
    assert.equal(stage.code, 0); assert.equal(stage.signal, null); assert.equal(stage.inputsVerified, true);
    assert.equal(identity(capture(stage.output)).sha256, stage.outputSha256);
  }
  assert.equal(proof.stages[0].outputSha256, proof.stages[1].outputSha256);
  const expected = capture(proof.stages[0].output), source = capture(proof.source);
  assert.equal(identity(source).sha256, '34c6ef63931e522a96a4203f8bbd8e103d3a27636cce5dd42d9ec57a8587d122');
  assert.equal(identity(expected).sha256, 'b33b38e32a263bf78e1d43cf459b7abf9a41d78d112d71a25f87ddba7bd09bf8');
  const pilotDir = path.dirname(path.resolve(pilotArg));
  const priorConfig = read(path.join(pilotDir, 'core-0-candidate.config.json'));
  assert.equal(priorConfig.api, candidate.file);
  assert.equal(identity(priorConfig.base).sha256, proof.base.sha256);
  assert.equal(identity(priorConfig.base).canonicalPath, proof.base.canonicalPath);
  assert.equal(identity(priorConfig.runtime).sha256, proof.runtimeSha256);
  for (const [file, before] of Object.entries(priorConfig.identities)) {
    const actual = identity(capture(file));
    assert.deepEqual({path: actual.canonicalPath, sha256: actual.sha256}, before);
  }
  const workerOriginal = capture(path.join(pilotDir, 'worker.mjs'));
  const worker = path.join(out, 'worker.mjs');
  fs.copyFileSync(workerOriginal, worker); capture(worker);
  const config = path.join(out, 'config.json'), request = path.join(out, 'request.json');
  fs.writeFileSync(request, JSON.stringify({input: source, mode: 'library'}, null, 2) + '\n'); capture(request);
  fs.writeFileSync(config, JSON.stringify({...priorConfig, identities: Object.fromEntries(report.inputs.map(item =>
    [item.file, {path: item.canonicalPath, sha256: item.sha256}]))}, null, 2) + '\n'); capture(config);
  report.api = candidate; report.source = identity(source); report.expected = identity(expected);
  report.cachePolicy = 'Reuse the pilot candidate’s validated Base cache; frozen cache bytes are inputs. OS caches not flushed.';
  report.command = ['taskset', '-c', '2', process.execPath, '--stack-size=4096', '--max-old-space-size=12288',
    worker, config, request, path.join(out, 'result.json')];
  save(); report.inputs.forEach(verifyIdentity);
  const stdout = fs.openSync(path.join(out, 'stdout.log'), 'wx'), stderr = fs.openSync(path.join(out, 'stderr.log'), 'wx');
  const start = performance.now();
  try {
    report.execution = await new Promise(resolve => {
      const child = spawn(report.command[0], report.command.slice(1), {
        stdio: ['ignore', stdout, stderr], detached: true, env: {...process.env, NODE_OPTIONS: ''}});
      let timedOut = false;
      const timer = setTimeout(() => {timedOut = true; try {process.kill(-child.pid, 'SIGKILL');} catch {}}, report.timeoutMs);
      child.once('error', error => {clearTimeout(timer); resolve({error: String(error), timedOut});});
      child.once('close', (status, signal) => {clearTimeout(timer); resolve({status, signal, timedOut});});
    });
  } finally {fs.closeSync(stdout); fs.closeSync(stderr);}
  report.wallMs = performance.now() - start;
  assert.equal(report.execution.status, 0); assert.equal(report.execution.signal, null);
  assert.equal(report.execution.timedOut, false); assert.ok(!report.execution.error);
  const result = read(path.join(out, 'result.json'));
  assert.equal(result.result.status, 'ok'); assert.equal(result.result.phase, 'compile'); assert.equal(result.result.checked, true);
  assert.equal(result.apiSha256, candidate.sha256);
  assert.match(result.affinity, /^Cpus_allowed_list:\s+2$/);
  const generated = capture(result.emitted.file);
  assert.equal(identity(generated).sha256, result.emitted.sha256);
  assert.deepEqual(fs.readFileSync(generated), fs.readFileSync(expected));
  report.observation = result; report.emitted = identity(generated);
  report.inputs.forEach(verifyIdentity); report.inputsUnchanged = true; report.complete = true;
} catch (error) {report.error = error.stack; process.exitCode = 1;}
report.finished = new Date().toISOString(); save();
console.log(JSON.stringify({complete: report.complete, wallMs: report.wallMs, error: report.error}));
