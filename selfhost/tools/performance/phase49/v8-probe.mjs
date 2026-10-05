#!/usr/bin/env node
// node [--trace-opt --trace-deopt --trace-gc] v8-probe.mjs CONFIG_JSON NEW_OUT
// CONFIG: {module:{path,sha256},exportName,args,expected,calls,warmups,mode}
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { pathToFileURL, fileURLToPath } from 'node:url';
import { performance } from 'node:perf_hooks';
import { Session } from 'node:inspector/promises';
import { summarizeCpu, summarizeAllocation } from '../programs/profile.mjs';

const [configArg, outArg] = process.argv.slice(2);
assert.ok(configArg && outArg && process.argv.length === 4,
  'usage: v8-probe.mjs CONFIG_JSON NEW_OUT');
const out = path.resolve(outArg);
fs.mkdirSync(out); // A consumed directory must never be replaced.
const started = performance.now(), inputs = [];
const report = { kind: 'phase49-v8-public-call-diagnostic', schemaVersion: 1,
  complete: false, passed: false, stage: 'configuration', inputs,
  createdUtc: new Date().toISOString(), productionSafety: 'not-established-by-this-driver' };
let session, profiling = false, profileMethod;
const sha = file => createHash('sha256').update(fs.readFileSync(file)).digest('hex');
function pin(file, expected) {
  file = fs.realpathSync(file);
  const row = { file, sha256: sha(file), bytes: fs.statSync(file).size };
  if (expected !== undefined) assert.equal(row.sha256, expected, `identity: ${file}`);
  inputs.push(row);
  return row;
}
const mark = phase => process.stdout.write(`P49_V8 ${phase}\n`);
function numericJson(value) {
  if (typeof value === 'number') assert.ok(Number.isFinite(value), 'nonfinite JSON number');
  else if (Array.isArray(value)) value.forEach(numericJson);
  else if (value && typeof value === 'object') Object.values(value).forEach(numericJson);
}
// Independent BigInt implementation of the recorded wrapping U32 digest.
function digestOracle(value, count) {
  let h = 2166136261n;
  const word = BigInt(value >>> 0), mask = 0xffffffffn;
  for (let i = 0; i < count; i++) h = ((h * 16777619n) ^ ((word + BigInt(i)) & mask)) & mask;
  return Number(h);
}
try {
  report.producer = pin(import.meta.filename);
  report.summaryProducer = pin(fileURLToPath(new URL('../programs/profile.mjs', import.meta.url)));
  report.configuration = pin(configArg);
  const config = JSON.parse(fs.readFileSync(report.configuration.file, 'utf8'));
  const { exportName = 'main.out', args = [], expected = 11,
    calls = 16384, warmups = 8192, mode = 'clean' } = config;
  assert.equal(process.version, 'v24.18.0', 'requires the pinned Node version');
  assert.ok(!process.env.NODE_OPTIONS, 'NODE_OPTIONS must be empty for an explicit runtime configuration');
  assert.ok(['clean', 'trace', 'cpu', 'allocation'].includes(mode), 'invalid mode');
  const traces = new Set(['--trace-opt', '--trace-deopt', '--trace-gc', '--trace-gc-nvp', '--trace-turbo-inlining']);
  for (const flag of process.execArgv) assert.ok(
    /^--(?:stack-size|max-old-space-size)=\d+$/.test(flag) || (mode === 'trace' && traces.has(flag)),
    `unsupported or mixed instrumentation flag: ${flag}`);
  if (mode === 'trace') assert.ok(process.execArgv.includes('--trace-opt')
    && process.execArgv.includes('--trace-deopt'), 'trace mode requires --trace-opt --trace-deopt');
  assert.ok(typeof exportName === 'string' && exportName.length > 0 && Array.isArray(args));
  assert.ok(typeof expected === 'number' && Number.isFinite(expected), 'expected must be a finite number');
  numericJson(args);
  for (const [key, value] of Object.entries({ calls, warmups })) assert.ok(
    Number.isSafeInteger(value) && value >= (key === 'calls' ? 1 : 0) && value <= 2 ** 22, `invalid ${key}`);
  assert.ok(config.module && typeof config.module.path === 'string'
    && /^[0-9a-f]{64}$/.test(config.module.sha256), 'module path and exact SHA-256 required');
  report.module = pin(config.module.path, config.module.sha256);
  report.node = { ...pin(process.execPath), versions: process.versions,
    execArgv: process.execArgv, platform: process.platform, arch: process.arch };
  report.input = { exportName, args, expected, calls, warmups };
  report.mode = mode;
  report.timingClass = mode === 'clean' ? 'clean-public-call' : 'instrumented-diagnostic-only';
  report.timingBoundary = 'Public calls, exact result checks, loop and U32 digest; import, first call, warmup, inspector setup, serialization and final hashing excluded.';
  report.digestAlgorithm = 'h0=2166136261; h=(imul(h,16777619)^((ToUint32(result)+index)>>>0))>>>0. Exact numeric equality is checked separately, including signed zero.';
  try { report.affinity = fs.readFileSync('/proc/self/status', 'utf8').split('\n').find(x => x.startsWith('Cpus_allowed_list:')); }
  catch { report.affinity = null; }
  const warmExpected = digestOracle(expected, warmups), measuredExpected = digestOracle(expected, calls);
  const moduleUrl = pathToFileURL(report.module.file).href;
  report.stage = 'import'; mark('import-start');
  let at = performance.now();
  const imported = await import(moduleUrl);
  report.importMs = performance.now() - at; mark('import-end');
  const fn = imported.default?.[exportName] ?? imported[exportName];
  assert.equal(typeof fn, 'function', `missing public function: ${exportName}`);
  function invoke() {
    const value = fn(...args);
    if (!Object.is(value, expected)) throw Error(`wrong public result during ${report.stage}: ${String(value)}`);
    return value;
  }
  function run(count) {
    let h = 2166136261;
    for (let i = 0; i < count; i++) h = (Math.imul(h, 16777619) ^ (((invoke() >>> 0) + i) >>> 0)) >>> 0;
    return h;
  }
  report.stage = 'first-call'; at = performance.now();
  report.firstResult = invoke(); report.firstCallMs = performance.now() - at;
  report.stage = 'warmup'; mark('warmup-start'); at = performance.now();
  report.warmChecksum = run(warmups); report.warmMs = performance.now() - at;
  assert.equal(report.warmChecksum, warmExpected, 'warmup digest'); mark('warmup-end');
  if (mode === 'cpu' || mode === 'allocation') {
    session = new Session(); session.connect();
    if (mode === 'cpu') {
      await session.post('Profiler.enable');
      await session.post('Profiler.setSamplingInterval', { interval: 1000 });
      report.sampling = { intervalMicroseconds: 1000 }; profileMethod = 'Profiler.stop';
    } else {
      await session.post('HeapProfiler.enable'); profileMethod = 'HeapProfiler.stopSampling';
      report.sampling = { samplingInterval: 32768,
        includeObjectsCollectedByMajorGC: true, includeObjectsCollectedByMinorGC: true };
    }
  }
  report.stage = 'measure'; mark('measure-start');
  if (session) {
    await session.post(mode === 'cpu' ? 'Profiler.start' : 'HeapProfiler.startSampling',
      mode === 'cpu' ? {} : report.sampling);
    profiling = true;
  }
  let failure;
  at = performance.now();
  try { report.checksum = run(calls); }
  catch (error) { failure = error; }
  report.elapsedMs = performance.now() - at;
  if (session) {
    const { profile } = await session.post(profileMethod); profiling = false;
    const file = path.join(out, mode === 'cpu' ? 'profile.cpuprofile' : 'allocation.heapprofile');
    fs.writeFileSync(file, JSON.stringify(profile) + '\n', { flag: 'wx' });
    report.profile = pin(file);
    report.summary = mode === 'cpu' ? summarizeCpu(profile, moduleUrl) : summarizeAllocation(profile, moduleUrl);
    report.summary.callerHarnessUrl = import.meta.url;
    if (mode === 'allocation') report.estimatedBytesPerCall = failure ? null : report.summary.estimatedBytes / calls;
  }
  mark('measure-end');
  if (failure) throw failure;
  assert.equal(report.checksum, measuredExpected, 'measurement digest');
  report.microsecondsPerCall = report.elapsedMs * 1000 / calls;
  report.validatedCalls = 1 + warmups + calls;
  report.caveats = ['Single process: use fresh rotated repetitions for comparisons.',
    'Every call includes ordinary public wrapper, validation and digest overhead.',
    'Instrumented durations are diagnostic only; never pool with clean timing.',
    'Allocation samples estimate allocated bytes, including collected objects; not retained heap, exact allocations or events.',
    'Profile windows also include inspector start/stop boundary overhead.',
    'Shared summary categories identify profile.mjs as harness; this driver frame URL is reported separately and may be categorized as other.',
    'The result digest uses U32 coercion, while every result separately passes exact Object.is validation.'];
  report.stage = 'done'; report.complete = report.passed = true;
} catch (error) {
  report.error = error.stack ?? String(error); process.exitCode = 1;
} finally {
  if (profiling) { try { await session.post(profileMethod); } catch {} }
  session?.disconnect();
  try {
    for (const input of inputs) assert.equal(sha(input.file), input.sha256, `changed input: ${input.file}`);
    report.inputRehashPassed = true;
  } catch (error) {
    report.complete = report.passed = false; report.identityError = error.stack ?? String(error); process.exitCode = 1;
  }
  report.wallMs = performance.now() - started;
  report.resourceUsage = process.resourceUsage();
  fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n', { flag: 'wx' });
  process.stdout.write(JSON.stringify({ complete: report.complete, passed: report.passed, mode: report.mode,
    checksum: report.checksum, microsecondsPerCall: report.microsecondsPerCall,
    estimatedBytesPerCall: report.estimatedBytesPerCall, error: report.error, identityError: report.identityError }) + '\n');
}
