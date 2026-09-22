// Keep diagnostic sampling separate from the fast edit loop and large proofs.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {spawn} from 'node:child_process';

const [configArgument, outputArgument] = process.argv.slice(2);
if (!outputArgument) throw Error('Usage: bounded-profile.mjs CONFIG.json NEW_DIRECTORY');
const configFile = fs.realpathSync(configArgument);
const config = JSON.parse(fs.readFileSync(configFile));
const out = path.resolve(outputArgument);
fs.mkdirSync(out, {recursive: false});
const sha = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const input = fs.realpathSync(path.resolve(path.dirname(configFile), config.input));
const cpu = config.cpu ?? 1, timeoutMs = config.profileTimeoutMs ?? 120000;
assert.ok(Number.isInteger(cpu) && cpu >= 0);
assert.ok(Number.isInteger(timeoutMs) && timeoutMs > 0 && timeoutMs <= 180000, 'Diagnostic profiles are limited to three minutes');
assert.ok(fs.statSync(input).size <= 128 * 1024, 'Use a small representative workload; full-source CPU sampling is deliberately disabled');
assert.ok((config.intervalUs ?? 1000) >= 1000, 'Sampling intervals below 1ms are disabled');
const original = path.join(import.meta.dirname, 'cpu-profile.mjs');
const worker = path.join(out, 'cpu-profile.mjs'); fs.copyFileSync(original, worker);
const configCopy = path.join(out, 'config.json');
const frozenConfig = {...config};
for (const key of ['api', 'driver', 'base', 'runtime', 'input']) frozenConfig[key] = fs.realpathSync(path.resolve(path.dirname(configFile), config[key]));
fs.writeFileSync(configCopy, JSON.stringify(frozenConfig, null, 2) + '\n');
const report = {kind: 'phase4-bounded-profile-launch', complete: false, started: new Date().toISOString(), cpu, timeoutMs, config: {file: configCopy, sha256: sha(configCopy)}, worker: {file: worker, sha256: sha(worker)}, input: {file: input, sha256: sha(input)}, node: {path: process.execPath, version: process.version}, args: ['--stack-size=4096', '--max-old-space-size=3072'], timedOut: false};
const flush = () => fs.writeFileSync(path.join(out, 'launch.json'), JSON.stringify(report, null, 2) + '\n');
flush();
const a = fs.openSync(path.join(out, 'stdout.log'), 'wx'), b = fs.openSync(path.join(out, 'stderr.log'), 'wx');
const start = performance.now();
try {
  await new Promise((accept, reject) => {
    const child = spawn('taskset', ['-c', String(cpu), process.execPath, ...report.args, worker, configCopy, path.join(out, 'profile')], {stdio: ['ignore', a, b], detached: true, env: {...process.env, NODE_OPTIONS: ''}});
    report.pid = child.pid; flush();
    const timer = setTimeout(() => {
      report.timedOut = true; flush();
      try { process.kill(-child.pid, 'SIGKILL'); } catch (error) { if (error.code !== 'ESRCH') report.killError = error.message; }
    }, timeoutMs);
    child.once('error', error => { clearTimeout(timer); reject(error); });
    child.once('close', (code, signal) => { clearTimeout(timer); report.exitCode = code; report.signal = signal; accept(); });
  });
  const file = path.join(out, 'profile/report.json');
  report.childReport = fs.existsSync(file) ? {file, sha256: sha(file), complete: JSON.parse(fs.readFileSync(file)).complete} : null;
  report.complete = report.exitCode === 0 && !report.signal && !report.timedOut && report.childReport?.complete === true;
} catch (error) { report.error = error?.stack || String(error); }
finally { fs.closeSync(a); fs.closeSync(b); }
report.wallMs = performance.now() - start; report.finished = new Date().toISOString(); flush();
console.log(JSON.stringify({complete: report.complete, wallMs: report.wallMs, timedOut: report.timedOut, exitCode: report.exitCode, signal: report.signal, error: report.error}));
if (!report.complete) process.exitCode = 1;
