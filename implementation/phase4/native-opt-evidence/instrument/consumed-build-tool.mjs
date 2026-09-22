// Experimental optimization builds of an already checked, immutable native C file.
// No production cache entries or cache-key policy are changed.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [configFile, outputArgument] = process.argv.slice(2);
if (!outputArgument) throw Error('Usage: native-opt-build.mjs CONFIG NEW_DIRECTORY');
const config = JSON.parse(fs.readFileSync(configFile)), output = path.resolve(outputArgument);
fs.mkdirSync(output, {recursive: false});
const sha = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const read = file => JSON.parse(fs.readFileSync(file));
const previous = read(config.referenceBuild), checked = read(config.checkedReport), sequence = read(config.environmentReport);
assert.equal(previous.complete, true); assert.equal(checked.complete, true);
assert.equal(sha(previous.input), previous.inputSha256); assert.equal(sha(previous.input), checked.c.sha256);
assert.equal(sha(previous.compiler.command), previous.compiler.executableSha256);
const env = {...process.env, ...sequence.environment}; delete env.NODE_OPTIONS;
const {spawnFileCapture} = await import(pathToFileURL(config.captureTool));
const flags = ['-std=c11', '-' + (config.optimization ?? 'O3'), ...(config.extraFlags ?? [])];
const binary = path.join(output, 'compiler'), object = path.join(output, 'compiler.o');
const consumed = [import.meta.filename, configFile, config.referenceBuild, config.checkedReport, config.environmentReport, config.captureTool, previous.input, previous.compiler.command, ...(config.extraInputs ?? []), ...(config.profileArchive ? [config.profileArchive] : [])];
const identity = Object.fromEntries(consumed.map(file => [file, sha(file)]));
const report = {kind: 'phase4-native-optimization-build', complete: false, started: new Date().toISOString(), config, identity, compiler: previous.compiler, checkedC: {file: previous.input, sha256: checked.c.sha256, report: config.checkedReport}, environment: sequence.environment, flags, phases: [], binary, cpu: config.cpu, node: process.version};
const save = () => fs.writeFileSync(path.join(output, 'report.json'), JSON.stringify(report, null, 2) + '\n'); save();
async function command(name, args, timeoutMs = config.timeoutMs ?? 600000) {
  const start = performance.now(), row = {name, command: [previous.compiler.command, ...args], timeoutMs, started: new Date().toISOString()}; report.phases.push(row); save();
  const result = await spawnFileCapture(previous.compiler.command, args, {env, timeout: timeoutMs, maxBuffer: 32 * 1024 * 1024});
  const stdout = path.join(output, name + '.stdout'), stderr = path.join(output, name + '.stderr'); fs.writeFileSync(stdout, result.stdout); fs.writeFileSync(stderr, result.stderr);
  Object.assign(row, {milliseconds: performance.now() - start, status: result.status, signal: result.signal, error: result.error?.message, stdout, stderr, stdoutSha256: sha(stdout), stderrSha256: sha(stderr), finished: new Date().toISOString()}); save();
  if (result.error || result.status !== 0) throw Error(name + ' failed: ' + (result.error?.message ?? result.stderr));
  return result;
}
try {
  const dependencies = path.join(output, 'dependencies.d');
  await command('preprocess', [...flags, '-E', '-MD', '-MF', dependencies, previous.input], 60000);
  const dependenciesText = fs.readFileSync(dependencies, 'utf8').replace(/\\\n/g, ' '), headerFiles = [...new Set(dependenciesText.slice(dependenciesText.indexOf(':') + 1).trim().split(/\s+/).map(file => fs.realpathSync(file)))];
  report.headers = Object.fromEntries(headerFiles.map(file => [file, sha(file)]));
  report.preprocessedSha256 = sha(path.join(output, 'preprocess.stdout'));
  report.samePreprocessedAsO2 = report.preprocessedSha256 === previous.preprocessedSha256; save();
  if (config.profileArchive) {
    await command('compile-instrumented', [...flags, '-c', previous.input, '-o', object]);
    await command('link-instrumented', [object, '-Wl,-u,__llvm_profile_runtime', config.profileArchive, '-lpthread', '-lm', '-o', binary], 60000);
  } else await command('compile', [...flags, previous.input, '-lpthread', '-lm', '-o', binary]);
  report.changedInputs = Object.entries({...identity, ...report.headers}).filter(([file, before]) => sha(file) !== before).map(([file]) => file);
  assert.deepEqual(report.changedInputs, []); report.binarySha256 = sha(binary); report.complete = true;
} catch (error) { report.error = error.stack; process.exitCode = 1; }
finally { report.finished = new Date().toISOString(); save(); console.log(JSON.stringify({complete: report.complete, output, error: report.error})); }
