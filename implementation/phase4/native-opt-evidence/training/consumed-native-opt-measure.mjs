// Controlled fresh-process comparison of frozen native compiler binaries.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [configFile, outputArgument] = process.argv.slice(2);
if (!outputArgument) throw Error('Usage: native-opt-measure.mjs CONFIG NEW_DIRECTORY');
const config = JSON.parse(fs.readFileSync(configFile)), output = path.resolve(outputArgument), sha = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
fs.mkdirSync(output, {recursive: false});
const {spawnFileCapture} = await import(pathToFileURL(config.captureTool));
const env = {...process.env, ...JSON.parse(fs.readFileSync(config.environmentReport)).environment, ...(config.extraEnvironment ?? {})}; delete env.NODE_OPTIONS;
const files = [import.meta.filename, configFile, config.captureTool, config.launcher, config.environmentReport, config.runtime, ...(config.extraInputs ?? [])];
for (const variant of config.variants) {
  const build = JSON.parse(fs.readFileSync(variant.buildReport)); assert.equal(build.complete, true); assert.equal(sha(variant.binary), build.binarySha256);
  files.push(variant.binary, variant.buildReport);
}
for (const workload of config.workloads) {
  const manifest = JSON.parse(fs.readFileSync(workload.manifest)); files.push(workload.manifest, manifest.main, manifest.base);
  for (const entry of [...(manifest.modules ?? []), ...(manifest.assets ?? [])]) files.push(entry.path);
}
const identity = Object.fromEntries([...new Set(files)].map(file => [file, sha(file)]));
const report = {kind: 'phase4-native-optimization-measurement', complete: false, started: new Date().toISOString(), config, identity, cpu: config.cpu, node: {version: process.version, executableSha256: sha(process.execPath)}, rows: [], commands: []};
const save = () => fs.writeFileSync(path.join(output, 'report.json'), JSON.stringify(report, null, 2) + '\n'); save();
async function command(name, args, timeout) {
  const cmd = ['taskset', '-c', String(config.cpu), process.execPath, '--stack-size=4096', '--max-old-space-size=4096', ...args], start = performance.now();
  const row = {name, command: cmd, timeoutMs: timeout, started: new Date().toISOString()}; report.commands.push(row); save();
  const result = await spawnFileCapture(cmd[0], cmd.slice(1), {env, timeout, maxBuffer: 16 * 1024 * 1024});
  const stdout = path.join(output, name + '.stdout'), stderr = path.join(output, name + '.stderr'); fs.writeFileSync(stdout, result.stdout); fs.writeFileSync(stderr, result.stderr);
  Object.assign(row, {wallMs: performance.now() - start, status: result.status, signal: result.signal, error: result.error?.message, stdout, stderr, stdoutSha256: sha(stdout), stderrSha256: sha(stderr), finished: new Date().toISOString()}); save();
  if (result.error || result.status !== 0) throw Error(name + ': ' + (result.error?.message ?? result.stderr));
  return {result, row};
}
try {
  for (const workload of config.workloads) {
    let expected = workload.expectedOutputSha256;
    for (let round = 0; round < (config.repetitions ?? 3); round++) for (const variant of round % 2 ? [...config.variants].reverse() : config.variants) {
      const name = workload.id + '-' + round + '-' + variant.id, emitted = path.join(output, name + '.mjs'); console.log('RUN ' + name);
      const profilesBefore = config.profileDirectory ? new Set(fs.readdirSync(config.profileDirectory)) : null;
      const compiled = await command(name, [config.launcher, variant.binary, workload.manifest, config.runtime, emitted, workload.mode ?? 'program', '--cpu=' + config.cpu, '--timeout-ms=' + (config.timeoutMs ?? 600000)], (config.timeoutMs ?? 600000) + 20000);
      const profilesCreated = profilesBefore ? fs.readdirSync(config.profileDirectory).filter(file => !profilesBefore.has(file) && file.endsWith('.profraw')).map(file => {const absolute = path.join(config.profileDirectory, file); return {file: absolute, sha256: sha(absolute), bytes: fs.statSync(absolute).size};}) : [];
      if (profilesBefore) assert.ok(profilesCreated.length > 0, 'Instrumented compilation must publish a fresh raw profile');
      const result = JSON.parse(compiled.result.stdout); assert.equal(result.published, true); expected ??= result.outputSha256; assert.equal(result.outputSha256, expected); assert.equal(sha(emitted), expected);
      const checked = await command(name + (workload.mode === 'library' ? '-syntax' : '-execute'), workload.mode === 'library' ? ['--check', emitted] : [emitted], 30000);
      if (workload.mode !== 'library') assert.equal(checked.result.stdout, workload.expectedStdout);
      report.rows.push({workload: workload.id, variant: variant.id, round, profilesCreated, compilationProcessWallMs: compiled.row.wallMs, result, exactOutputSha256: expected, executionOrSyntax: {status: checked.result.status, stdout: checked.result.stdout, stderr: checked.result.stderr}}); save();
    }
  }
  report.changedInputs = Object.entries(identity).filter(([file, before]) => sha(file) !== before).map(([file]) => file); assert.deepEqual(report.changedInputs, []); report.complete = true;
} catch (error) { report.error = error.stack; process.exitCode = 1; }
finally { report.finished = new Date().toISOString(); save(); console.log(JSON.stringify({complete: report.complete, output, error: report.error})); }
