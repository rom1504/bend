// Native component trials; exact canonical tree bytes are the correctness oracle.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [configFile, outArg] = process.argv.slice(2);
if (!outArg) throw Error('Usage: native-annotation-measure.mjs CONFIG NEW_DIRECTORY');
const cfg = JSON.parse(fs.readFileSync(configFile)), out = path.resolve(outArg);
assert.ok(Array.isArray(cfg.fixtures) && cfg.fixtures.length > 0, 'Nonempty fixtures required');
assert.ok(Array.isArray(cfg.variants) && cfg.variants.length > 0, 'Nonempty variants required');
assert.ok(Number.isSafeInteger(cfg.rounds ?? 1) && (cfg.rounds ?? 1) > 0, 'Positive integer rounds required');
assert.ok(Number.isSafeInteger(cfg.timeoutMs ?? 120000) && (cfg.timeoutMs ?? 120000) > 0, 'Positive deadline required');
for (const row of [...cfg.fixtures, ...cfg.variants]) assert.match(row.id, /^[A-Za-z0-9_-]+$/, 'IDs must be safe output basenames');
assert.equal(new Set(cfg.fixtures.map(f => f.id)).size, cfg.fixtures.length);
assert.equal(new Set(cfg.variants.map(v => v.id)).size, cfg.variants.length);
for (const variant of cfg.variants) {assert.ok(['serial','fork2','fork4'].includes(variant.mode)); assert.ok(Number.isInteger(variant.threads) && variant.threads > 0 && variant.threads <= 128); assert.match(variant.cpus, /^\d+(,\d+)*$/);}
fs.mkdirSync(out, {recursive: false});
const sha = f => crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const build = JSON.parse(fs.readFileSync(cfg.buildReport)), cBuild = JSON.parse(fs.readFileSync(cfg.binary + '.build.json'));
assert.equal(build.complete, true); assert.equal(cBuild.complete, true);
assert.equal(sha(build.source), build.sourceSha256); assert.equal(sha(build.c.file), build.c.sha256); assert.equal(sha(cfg.binary), cBuild.binarySha256);
assert.equal(sha(cBuild.input), build.c.sha256);
const oracle = JSON.parse(fs.readFileSync(cfg.oracleReport)); assert.equal(oracle.complete, true);
for (const [file, before] of Object.entries(oracle.identity)) assert.equal(sha(file), before, 'Oracle input drift: ' + file);
assert.equal(fs.realpathSync(oracle.config.build), fs.realpathSync(path.dirname(cfg.buildReport)), 'Oracle used a different checked wrapper build');
assert.equal(oracle.identity[cfg.buildReport], sha(cfg.buildReport), 'Oracle build-report identity differs');
assert.equal(fs.realpathSync(cfg.base), fs.realpathSync(oracle.config.base), 'Oracle Base physical identity differs');
assert.equal(sha(cfg.base), oracle.identity[oracle.config.base], 'Oracle Base bytes differ');
for (const fixture of cfg.fixtures) {
  const original = oracle.config.fixtures.find(f => f.id === fixture.id); assert.ok(original, 'Fixture absent from oracle: ' + fixture.id);
  assert.equal(fs.realpathSync(fixture.file), fs.realpathSync(original.file), 'Fixture physical identity differs');
  assert.equal(sha(fixture.file), oracle.identity[original.file], 'Fixture bytes differ from oracle');
}
const expected = new Map(oracle.rows.filter(r => r.scenario === 'normal' && r.mode === 'serial').map(r => [r.fixture, r]));
const resourceHelper = path.join(import.meta.dirname, 'native-annotation-resource.py');
const files = [import.meta.filename, resourceHelper, configFile, cfg.buildReport, cfg.binary + '.build.json', cfg.binary, build.source, build.c.file, cfg.oracleReport, cfg.captureTool, cfg.base, ...cfg.fixtures.map(f => f.file), ...cfg.fixtures.map(f => expected.get(f.id).expectedFile)];
const identity = Object.fromEntries(files.map(f => [f, sha(f)]));
for (const fixture of cfg.fixtures) assert.equal(sha(expected.get(fixture.id).expectedFile), expected.get(fixture.id).sha256);
const {spawnFileCapture} = await import(pathToFileURL(cfg.captureTool));
const report = {kind: 'phase4-native-annotation-component', complete: false, started: new Date().toISOString(), cfg, identity, samples: [], scope: 'Fresh native processes; prepare/check/specialize outside component clock. Component timer includes annotation, splitting/join for fork modes, full structural digest. Exact output bytes checked against frozen-B1 tree oracle. Exact canonical serialization occurs after the component clock; process wall includes preparation, serialization and file output. No full-source or emitted-user-program speed claim.'};
const save = () => fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n'); save();
try {
  for (let round = 0; round < (cfg.rounds ?? 1); ++round) for (const fixture of cfg.fixtures) for (const variant of (round % 2 ? [...cfg.variants].reverse() : cfg.variants)) {
    const stem = `${round}-${fixture.id}-${variant.id}`, output = path.join(out, stem + '.tree');
    assert.equal(fs.existsSync(output), false, 'Output already exists');
    const command = ['taskset', '-c', variant.cpus, 'python3', resourceHelper, cfg.binary, '--threads', String(variant.threads), fs.realpathSync(fixture.file), fs.realpathSync(cfg.base), output, variant.mode];
    const sample = {round, fixture: fixture.id, variant, command, output, started: new Date().toISOString()}; report.samples.push(sample); save(); console.log('RUN ' + stem);
    const start = performance.now(), result = await spawnFileCapture(command[0], command.slice(1), {timeout: cfg.timeoutMs ?? 120000, maxBuffer: 1024 * 1024});
    Object.assign(sample, {wallMs: performance.now() - start, status: result.status, signal: result.signal, error: result.error?.message, stdout: result.stdout, stderr: result.stderr, finished: new Date().toISOString()}); save();
    assert.ok(!result.error); assert.equal(result.signal, null); assert.equal(result.status, 0);
    const resources = /ANNOTATION_RESOURCE wall=([\d.]+) user=([\d.]+) sys=([\d.]+) rssKiB=(\d+)/.exec(result.stderr);
    assert.ok(resources, 'Missing independent process resources');
    Object.assign(sample, {resourceWallSeconds: +resources[1], userSeconds: +resources[2], systemSeconds: +resources[3], peakRssKiB: +resources[4], componentMs: +/annotation_consume_ms=(\d+)/.exec(result.stderr)[1], prepareMs: +/prepare_ms=(\d+)/.exec(result.stderr)[1], digest: +/digest=(\d+)/.exec(result.stderr)[1], selected: +/selected=(\d+)/.exec(result.stderr)[1]});
    assert.deepEqual(fs.readFileSync(output), fs.readFileSync(expected.get(fixture.id).expectedFile), 'Exact native annotated tree differs');
    if (expected.get(fixture.id).structuralDigest !== undefined) assert.equal(sample.digest, expected.get(fixture.id).structuralDigest, 'Native structural digest differs');
    sample.exactTree = true; sample.sha256 = sha(output); save();
  }
  report.changedInputs = Object.entries(identity).filter(([f,h]) => sha(f) !== h).map(([f]) => f); assert.deepEqual(report.changedInputs, []); report.complete = true;
} catch (error) { report.error = error.stack; process.exitCode = 1; }
finally {report.finished = new Date().toISOString(); save(); console.log(JSON.stringify({complete: report.complete, error: report.error, samples: report.samples.length}));}
