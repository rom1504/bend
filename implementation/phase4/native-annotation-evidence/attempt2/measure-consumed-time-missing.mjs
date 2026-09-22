// Native component trials; exact canonical tree bytes are the correctness oracle.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [configFile, outArg] = process.argv.slice(2);
if (!outArg) throw Error('Usage: native-annotation-measure.mjs CONFIG NEW_DIRECTORY');
const cfg = JSON.parse(fs.readFileSync(configFile)), out = path.resolve(outArg);
fs.mkdirSync(out, {recursive: false});
const sha = f => crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const build = JSON.parse(fs.readFileSync(cfg.buildReport)), cBuild = JSON.parse(fs.readFileSync(cfg.binary + '.build.json'));
assert.equal(build.complete, true); assert.equal(cBuild.complete, true);
assert.equal(sha(build.source), build.sourceSha256); assert.equal(sha(build.c.file), build.c.sha256); assert.equal(sha(cfg.binary), cBuild.binarySha256);
assert.equal(sha(cBuild.input), build.c.sha256);
const oracle = JSON.parse(fs.readFileSync(cfg.oracleReport)); assert.equal(oracle.complete, true);
const expected = new Map(oracle.rows.filter(r => r.scenario === 'normal' && r.mode === 'serial').map(r => [r.fixture, r]));
const files = [import.meta.filename, configFile, cfg.buildReport, cfg.binary + '.build.json', cfg.binary, build.source, build.c.file, cfg.oracleReport, cfg.captureTool, cfg.base, ...cfg.fixtures.map(f => f.file), ...cfg.fixtures.map(f => expected.get(f.id).expectedFile)];
const identity = Object.fromEntries(files.map(f => [f, sha(f)]));
for (const fixture of cfg.fixtures) assert.equal(sha(expected.get(fixture.id).expectedFile), expected.get(fixture.id).sha256);
const {spawnFileCapture} = await import(pathToFileURL(cfg.captureTool));
const report = {kind: 'phase4-native-annotation-component', complete: false, started: new Date().toISOString(), cfg, identity, samples: [], scope: 'Fresh native processes; prepare/check/specialize outside component clock. Component timer includes annotation, splitting/join for fork modes, complete canonical serialization and digest. Exact output bytes checked against frozen-B1 tree oracle. Process wall includes preparation and file output. No full-source or emitted-user-program speed claim.'};
const save = () => fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n'); save();
try {
  for (let round = 0; round < (cfg.rounds ?? 1); ++round) for (const fixture of cfg.fixtures) for (const variant of (round % 2 ? [...cfg.variants].reverse() : cfg.variants)) {
    const stem = `${round}-${fixture.id}-${variant.id}`, output = path.join(out, stem + '.tree');
    const command = ['taskset', '-c', variant.cpus, '/usr/bin/time', '-f', 'ANNOTATION_RESOURCE wall=%e user=%U sys=%S rssKiB=%M', cfg.binary, '--threads', String(variant.threads), fs.realpathSync(fixture.file), fs.realpathSync(cfg.base), output, variant.mode];
    const sample = {round, fixture: fixture.id, variant, command, output, started: new Date().toISOString()}; report.samples.push(sample); save(); console.log('RUN ' + stem);
    const start = performance.now(), result = await spawnFileCapture(command[0], command.slice(1), {timeout: cfg.timeoutMs ?? 120000, maxBuffer: 1024 * 1024});
    Object.assign(sample, {wallMs: performance.now() - start, status: result.status, signal: result.signal, error: result.error?.message, stdout: result.stdout, stderr: result.stderr, finished: new Date().toISOString()}); save();
    assert.ok(!result.error); assert.equal(result.signal, null); assert.equal(result.status, 0);
    const resources = /ANNOTATION_RESOURCE wall=([\d.]+) user=([\d.]+) sys=([\d.]+) rssKiB=(\d+)/.exec(result.stderr);
    assert.ok(resources, 'Missing independent process resources');
    Object.assign(sample, {resourceWallSeconds: +resources[1], userSeconds: +resources[2], systemSeconds: +resources[3], peakRssKiB: +resources[4], componentMs: +/annotation_consume_ms=(\d+)/.exec(result.stderr)[1], prepareMs: +/prepare_ms=(\d+)/.exec(result.stderr)[1], digest: +/digest=(\d+)/.exec(result.stderr)[1], selected: +/selected=(\d+)/.exec(result.stderr)[1]});
    assert.deepEqual(fs.readFileSync(output), fs.readFileSync(expected.get(fixture.id).expectedFile), 'Exact native annotated tree differs');
    sample.exactTree = true; sample.sha256 = sha(output); save();
  }
  report.changedInputs = Object.entries(identity).filter(([f,h]) => sha(f) !== h).map(([f]) => f); assert.deepEqual(report.changedInputs, []); report.complete = true;
} catch (error) { report.error = error.stack; process.exitCode = 1; }
finally {report.finished = new Date().toISOString(); save(); console.log(JSON.stringify({complete: report.complete, error: report.error, samples: report.samples.length}));}
