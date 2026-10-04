#!/usr/bin/env node
// Executes a public-call diagnostic benchmark. Run each emitted variant in a fresh process.
// node [--trace-opt --trace-deopt] v8-probe.mjs MODULE NEW_OUT [clean|trace|cpu] [N=4096] [SEED=17] [CALLS=8192] [WARMUPS=8192]
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { pathToFileURL } from 'node:url';
import { performance } from 'node:perf_hooks';
import inspector from 'node:inspector';
const [moduleArg, outArg, mode = 'clean', nArg = '4096', seedArg = '17', callsArg = '8192', warmArg = '8192'] = process.argv.slice(2);
if (!moduleArg || !outArg || !['clean', 'trace', 'cpu'].includes(mode)) throw Error('usage: v8-probe.mjs MODULE NEW_OUT [clean|trace|cpu] [N] [SEED] [CALLS] [WARMUPS]');
const modulePath = fs.realpathSync(moduleArg), out = path.resolve(outArg);
const n = Number(nArg), seed = Number(seedArg), calls = Number(callsArg), warmups = Number(warmArg);
for (const [key, value] of Object.entries({ n, seed, calls, warmups })) if (!Number.isSafeInteger(value) || value < 0 || value > 0xffffffff) throw Error(`invalid ${key}`);
if (!calls) throw Error('calls must be positive');
if (n > 1000000 || calls > 1000000 || warmups > 1000000) throw Error('n/calls/warmups must not exceed 1000000');
const instrumentation = process.execArgv.filter(x => /trace|prof|inspect|allow-natives-syntax|no-opt|jitless/.test(x));
if (mode === 'clean' && instrumentation.length) throw Error(`clean mode refuses instrumentation: ${instrumentation.join(' ')}`);
if (mode === 'trace' && !(process.execArgv.includes('--trace-opt') && process.execArgv.includes('--trace-deopt'))) throw Error('trace mode requires --trace-opt --trace-deopt');
fs.mkdirSync(out); // Refuse replacement of a consumed output directory.
const sha = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const sourceBytes = fs.readFileSync(modulePath), producerPath = fs.realpathSync(process.argv[1]);
const producerSha256 = sha(fs.readFileSync(producerPath)), moduleSha256 = sha(sourceBytes);
const nodePath = fs.realpathSync(process.execPath), nodeSha256 = sha(fs.readFileSync(nodePath));
const mask = 0xffffffffn;
function oracle(count, initial) {
  const a = Array(128).fill(BigInt(initial));
  let acc = 0n;
  for (let i = 0; i < count; i++) {
    const j = i % 128;
    acc = (acc + a[j]) & mask;
    a[j] = (acc ^ BigInt(i)) & mask;
  }
  return Number(acc);
}
const expected = oracle(n, seed);
if (n === 4096 && seed === 17 && expected !== 2339999928) throw Error('independent maintained-input oracle failed');
function checksumOracle(count) {
  let h = 2166136261n;
  for (let i = 0; i < count; i++) h = ((h * 16777619n) ^ ((BigInt(expected) + BigInt(i)) & mask)) & mask;
  return Number(h);
}
const expectedMeasuredChecksum = checksumOracle(calls), expectedWarmChecksum = checksumOracle(warmups);
const mark = phase => process.stdout.write(`P47_V8 ${phase}\n`);
mark('import-start');
const importStart = performance.now();
const module = await import(pathToFileURL(modulePath).href);
const importMs = performance.now() - importStart;
const bench = module.default?.bench;
if (typeof bench !== 'function') throw Error('module must export default.bench');
mark('import-end');
const firstStart = performance.now();
const first = bench(n, seed);
const firstCallMs = performance.now() - firstStart;
if (first !== expected) throw Error(`first result ${String(first)} != ${expected}`);
// Keep this common harness identical between variants. Every result is checked and
// participates in an externally recorded digest; returned work cannot be discarded.
function runPublicCalls(count) {
  let h = 2166136261;
  for (let i = 0; i < count; i++) {
    const value = bench(n, seed);
    if (value !== expected) throw Error(`result at ${i}: ${String(value)} != ${expected}`);
    h = (Math.imul(h, 16777619) ^ ((value + i) >>> 0)) >>> 0;
  }
  return h;
}
mark('warmup-start');
const warmStart = performance.now();
const warmChecksum = runPublicCalls(warmups);
const warmMs = performance.now() - warmStart;
if (warmChecksum !== expectedWarmChecksum) throw Error('warm checksum mismatch');
mark('warmup-end');
let session;
const post = (method, params = {}) => new Promise((resolve, reject) => session.post(method, params, (error, result) => error ? reject(error) : resolve(result)));
if (mode === 'cpu') {
  session = new inspector.Session(); session.connect();
  await post('Profiler.enable'); await post('Profiler.setSamplingInterval', { interval: 1000 });
  await post('Profiler.start');
}
mark('measure-start');
const start = performance.now();
const checksum = runPublicCalls(calls);
const elapsedMs = performance.now() - start;
mark('measure-end');
if (checksum !== expectedMeasuredChecksum) throw Error('measured checksum mismatch');
let cpuSummary;
if (session) {
  const { profile } = await post('Profiler.stop');
  fs.writeFileSync(path.join(out, 'profile.cpuprofile'), JSON.stringify(profile), { flag: 'wx' });
  const total = (profile.samples ?? []).length;
  cpuSummary = { samples: total, topSelf: profile.nodes.filter(x => x.hitCount).sort((a, b) => b.hitCount - a.hitCount).slice(0, 25).map(x => ({ ...x.callFrame, samples: x.hitCount, share: total ? x.hitCount / total : null })) };
  await post('Profiler.disable'); session.disconnect();
}
for (const [file, expectedHash] of [[producerPath, producerSha256], [modulePath, moduleSha256], [nodePath, nodeSha256]]) {
  if (sha(fs.readFileSync(file)) !== expectedHash) throw Error(`consumed input changed during run: ${file}`);
}
const report = {
  complete: true, passed: true, inputRehashPassed: true,
  schemaVersion: 1, kind: 'phase47-v8-public-call-diagnostic', mode,
  timingClass: mode === 'clean' ? 'clean-public-call' : 'instrumented-diagnostic-only',
  productionSafety: 'not-established-by-this-performance-driver',
  createdUtc: new Date().toISOString(),
  producer: { path: producerPath, sha256: producerSha256 },
  module: { path: modulePath, sha256: moduleSha256, bytes: sourceBytes.length },
  runtime: { executable: nodePath, sha256: nodeSha256, versions: process.versions, execArgv: process.execArgv, platform: process.platform, arch: process.arch },
  input: { n, seed, calls, warmups }, expected, first, checksum, warmChecksum,
  timing: { importMs, firstCallMs, warmMs, elapsedMs, microsecondsPerCall: elapsedMs * 1000 / calls },
  cpuSummary,
  caveats: ['Single process and variant; compare replicated rotated clean runs.', 'Public wrapper and admission checks are included.', 'Trace/CPU times must not be pooled with clean times.', 'Zero-iteration calibration changes executed body and may change JIT decisions.', 'CPU hit shares are sampled and compositional; function names may repeat at different source positions.']
};
fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n', { flag: 'wx' });
process.stdout.write(JSON.stringify({ mode, moduleSha256: report.module.sha256, input: report.input, expected, checksum, microsecondsPerCall: report.timing.microsecondsPerCall }) + '\n');
