// Merge only profiles from completed, byte-verified training of one checked C image.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [configFile, outputArgument] = process.argv.slice(2);
if (!outputArgument) throw Error('Usage: native-opt-profile.mjs CONFIG NEW_DIRECTORY');
const config = JSON.parse(fs.readFileSync(configFile)), output = path.resolve(outputArgument), sha = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
fs.mkdirSync(output, {recursive: false});
const training = JSON.parse(fs.readFileSync(config.trainingReport)); assert.equal(training.complete, true); assert.deepEqual(training.changedInputs, []);
assert.equal(training.config.variants.length, 1);
const buildFile = training.config.variants[0].buildReport, build = JSON.parse(fs.readFileSync(buildFile)); assert.equal(build.complete, true); assert.equal(sha(build.binary), build.binarySha256);
const profiles = training.rows.flatMap(row => row.profilesCreated); assert.ok(profiles.length > 0); for (const profile of profiles) assert.equal(sha(profile.file), profile.sha256);
const files = [import.meta.filename, configFile, config.trainingReport, buildFile, build.binary, build.checkedC.file, config.tool, config.captureTool, config.environmentReport, ...(config.extraInputs ?? []), ...profiles.map(profile => profile.file)];
const identity = Object.fromEntries(files.map(file => [file, sha(file)])); assert.equal(sha(build.checkedC.file), build.checkedC.sha256);
const {spawnFileCapture} = await import(pathToFileURL(config.captureTool)), env = {...process.env, ...JSON.parse(fs.readFileSync(config.environmentReport)).environment};
const report = {kind: 'phase4-native-profile-merge', complete: false, started: new Date().toISOString(), identity, checkedC: build.checkedC, trainingReport: config.trainingReport, trainingOutputChecksums: training.rows.map(row => ({workload: row.workload, sha256: row.exactOutputSha256})), profiles, commands: []};
const save = () => fs.writeFileSync(path.join(output, 'report.json'), JSON.stringify(report, null, 2) + '\n'); save();
async function command(name, args) {
  const start = performance.now(), result = await spawnFileCapture(config.tool, args, {env, timeout: 60000, maxBuffer: 32 * 1024 * 1024});
  const stdout = path.join(output, name + '.stdout'), stderr = path.join(output, name + '.stderr'); fs.writeFileSync(stdout, result.stdout); fs.writeFileSync(stderr, result.stderr);
  report.commands.push({name, command: [config.tool, ...args], milliseconds: performance.now() - start, status: result.status, signal: result.signal, error: result.error?.message, stdout, stderr, stdoutSha256: sha(stdout), stderrSha256: sha(stderr)}); save();
  if (result.error || result.status !== 0) throw Error(name + ' failed: ' + (result.error?.message ?? result.stderr));
}
try {
  await command('version', ['merge', '--version']);
  const profile = path.join(output, 'compiler.profdata');
  await command('merge', ['merge', '--failure-mode=any', '--num-threads=1', '-o', profile, ...profiles.map(item => item.file)]);
  await command('show', ['show', '--all-functions', '--counts', profile]);
  report.profile = {file: profile, sha256: sha(profile), bytes: fs.statSync(profile).size};
  report.changedInputs = Object.entries(identity).filter(([file, before]) => sha(file) !== before).map(([file]) => file); assert.deepEqual(report.changedInputs, []); report.complete = true;
} catch (error) { report.error = error.stack; process.exitCode = 1; }
finally { report.finished = new Date().toISOString(); save(); console.log(JSON.stringify({complete: report.complete, profile: report.profile, error: report.error})); }
