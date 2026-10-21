// Diagnostic transport for the checked Bend entry. No host semantic lowering.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';

// Diagnostic-only revision: retain the exact request-bound entry and stages.
// Generated Bend helpers call lexical functions, so replacing API-object members
// would not instrument their internal calls. Capture the actual host stack.
try { Error.stackTraceLimit = Math.max(Number(Error.stackTraceLimit) || 10, 64); } catch {}
function exceptionDetails(error) {
  let stack = null, name = null, message = null;
  try { if (typeof error?.stack === 'string') stack = error.stack; } catch {}
  try { if (typeof error?.name === 'string') name = error.name; } catch {}
  try { if (typeof error?.message === 'string') message = error.message; } catch {}
  return {name, message, stack};
}

const args = process.argv.slice(2);
const [apiArg, inputArg, outArg, mode = 'cache', pipeline = 'direct'] = args;
if (args.length < 3 || args.length > 5 || !['cache', 'live'].includes(mode) || pipeline!=='array')
  throw Error('Usage: staged-emit-v2.mjs CHECKED_API INPUT FRESH_OUT [cache|live] [direct|array]');
const root = path.resolve(import.meta.dirname, '../../../..');
const apiFile = path.resolve(apiArg), source = path.resolve(inputArg), out = path.resolve(outArg);
if (!out.startsWith(root + '/selfhost/build/phase111/') || fs.existsSync(out))
  throw Error('Fresh Phase111 output required');

// Streaming pins avoid a second complete QBE/source buffer during accounting.
function pin(file) {
  file = path.resolve(file);
  const fd = fs.openSync(file, 'r'), hash = crypto.createHash('sha256');
  const buffer = Buffer.allocUnsafe(1024 * 1024);
  let bytes = 0;
  try {
    for (;;) {
      const count = fs.readSync(fd, buffer, 0, buffer.length, null);
      if (!count) break;
      bytes += count;
      hash.update(buffer.subarray(0, count));
    }
  } finally { fs.closeSync(fd); }
  return {file, bytes, sha256: hash.digest('hex')};
}
function verify(row) {
  const actual = pin(row.file);
  if (actual.bytes !== row.bytes || actual.sha256 !== row.sha256)
    throw Error('Changed input ' + row.file);
}
function memory() {
  const result = {};
  try {
    const status = fs.readFileSync('/proc/self/status', 'utf8');
    for (const [field, label] of [['VmRSS', 'rssBytes'], ['VmHWM', 'processLifetimeMaxRssBytes']]) {
      const match = status.match(new RegExp('^' + field + ':\\s+(\\d+) kB$', 'm'));
      if (match) result[label] = Number(match[1]) * 1024;
    }
  } catch {}
  try { result.heapUsedBytes = process.memoryUsage().heapUsed; } catch {}
  return result;
}
function tagged(value, tag, label) {
  if (value?.$ !== tag) throw Error('Unexpected ' + label + ' tag: ' + String(value?.$));
  return value;
}
function errorText(value, label) {
  if (typeof value !== 'string') throw Error('Non-string ' + label + ' diagnostic');
  return value;
}
function listCount(list, label, visit = () => {}) {
  let count = 0, cursor = list;
  while (cursor?.$ === 'Con') {
    visit(cursor.head);
    count++;
    cursor = cursor.tail;
  }
  if (cursor?.$ !== 'Nil') throw Error('Invalid ' + label + ' list tail');
  return count;
}
function u32(value, label) {
  if (!Number.isInteger(value) || value < 0 || value > 0xffffffff)
    throw Error('Invalid U32 diagnostic field ' + label);
  return value;
}
function programCounts(program) {
  tagged(program, 'P111Program', 'program');
  const counts = {segments: 0, maxArity: 0, maxIncoming: 0, maxResult: 0,
    constructors: 0, maxConstructorArity: 0};
  counts.segments = listCount(program.segments, 'segments', segment => {
    tagged(segment, 'N111Segment', 'segment');
    for (const [field, key] of [['arity', 'maxArity'], ['incoming', 'maxIncoming'], ['result', 'maxResult']]) {
      const value = u32(segment[field], field);
      if (value > counts[key]) { counts[key] = value; counts[key + 'Segment'] = segment.name; }
    }
  });
  counts.constructors = listCount(program.constructors, 'constructors', constructor => {
    tagged(constructor, 'N_Constructor', 'constructor');
    const arity = u32(constructor.arity, 'constructor arity');
    if (arity > counts.maxConstructorArity) {
      counts.maxConstructorArity = arity;
      counts.maxConstructorArityName = constructor.name;
    }
  });
  counts.showWords = listCount(program.show, 'show words');
  counts.showNames = listCount(program.show_names, 'show names');
  counts.effects = listCount(program.effects, 'effects');
  return counts;
}

const apiRecordFile = path.join(path.dirname(apiFile), 'report.json');
const apiRecord = JSON.parse(fs.readFileSync(apiRecordFile));
const prefix = pipeline === 'array' ? 'p113a' : 'p113d';
const admitted = pipeline === 'array' ? 'p113a_admitted_chunks' : 'p113e_admitted_chunks';
const lowering = prefix + '_lower_request', verifier = prefix + '_verify';
const renderer = apiRecord.exports?.includes(admitted) ? admitted : prefix + '_chunks';
const rendererReverifies = renderer !== admitted;
const requiredExports = ['p88_cache_prepare', 'p86_prepare', 'p86_plan', 'p111_runtime_admission', 'p111_emit_admitted'];
if (!apiRecord.complete || !apiRecord.checked ||
    !requiredExports.every(name => apiRecord.exports?.includes(name)))
  throw Error('Complete checked API with all staged exports required');
verify(apiRecord.api);
if (path.resolve(apiRecord.api.file) !== apiFile) throw Error('API differs from checked receipt');
const selectionFile = path.join(root, 'selfhost/tools/native/selection.json');
const selection = JSON.parse(fs.readFileSync(selectionFile));
verify(selection.admission);
const admission = JSON.parse(fs.readFileSync(selection.admission.file));
if (!admission.complete || !admission.qualified) throw Error('Native seed admission incomplete');
const {base, cache} = admission.assets;
verify(base);
if (mode === 'cache') verify(cache.carrier);
const inputs = [pin(import.meta.filename), pin(apiFile), pin(apiRecordFile), pin(source),
  pin(selectionFile), selection.admission, base, ...(mode === 'cache' ? [cache.carrier] : []),
  pin(process.execPath)];
fs.mkdirSync(out, {recursive: true});
fs.copyFileSync(import.meta.filename, path.join(out, 'staged-emit-method.mjs'));
const report = {kind: 'phase118-integrated-checked-source-qbe-emission', complete: false, mode, pipeline,
  transportVersion: 118, entry: 'p111_emit_admitted', explicitVerificationPasses: 1,
  diagnostics: {version: 2, exceptionStack: true, requestedStackFrames: 64,
    integratedEntryUnchanged: true, stagedReplay: false, requestCheckpoint: false},
  admittedRendererGuard: 'Pinned request-bound Bend entry invokes original IR verification and derived-worker checking before emitting. No host semantic transformation.',
  inputs, requiredExports, startedUtc: new Date().toISOString(), stages: [], sourceChecked: false,
  runtimeAdmitted: false, irVerified: false, compilerHost: 'checked Bend source API acquired by pinned TypeScript',
  composition: 'prepare -> p86_plan -> runtime admission -> actual integrated Bend entry -> exact chunk write',
  timingScope: 'compilerSeconds sums only marked Bend API stages. List counting, import/read, output hashing and write are separate. totalSeconds starts after preflight authentication; outer guard includes process startup and preflight.',
  memoryScope: 'Host process RSS snapshots and Linux lifetime high-water RSS; not isolated per-stage peaks or full process-tree RSS. No forced GC.',
  scope: 'Staged acquisition diagnosis. List walks count metadata only; no graph JSON, semantic transformation, native compiler or self-host qualification.'};
const save = () => fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
const totalStart = performance.now();
let activeStage;
async function stage(name, action, compiler = false) {
  activeStage = name;
  const row = {name, status: 'running', compiler, startedUtc: new Date().toISOString(), before: memory()};
  report.stages.push(row);
  save();
  console.log(JSON.stringify({stage: name, status: 'running', memory: row.before}));
  const start = performance.now();
  try {
    const result = await action();
    row.status = 'complete';
    return result;
  } catch (error) {
    row.status = 'failed';
    row.error = String(error);
    row.exception = exceptionDetails(error);
    throw error;
  } finally {
    row.seconds = (performance.now() - start) / 1000;
    row.after = memory();
    save();
    console.log(JSON.stringify({stage: name, status: row.status, seconds: row.seconds, memory: row.after}));
  }
}
function reject(diagnostic, prefix = '') {
  report.diagnostic = prefix + errorText(diagnostic, activeStage);
  throw Error(report.diagnostic);
}

save();
try {
  const api = await stage('api-import', async () => (await import(pathToFileURL(apiFile))).default);
  if (!requiredExports.every(name => typeof api[name] === 'function'))
    throw Error('Checked API does not expose required functions');
  let sourceText, baseText, carrierText;
  await stage('input-read', () => {
    sourceText = fs.readFileSync(source, 'utf8');
    baseText = fs.readFileSync(base.file, 'utf8');
    carrierText = mode === 'cache' ? fs.readFileSync(cache.carrier.file, 'utf8') : '';
  });
  let prepared = await stage('preparation', () => {
    const result = mode === 'cache'
      ? api.p88_cache_prepare(base.file, baseText, carrierText, cache.stamp)
      : api.p86_prepare(base.file, baseText);
    if (result?.$ === 'P86PreparationError') reject(result.error);
    return tagged(result, 'P86PreparationReady', 'preparation');
  }, true);
  baseText = carrierText = null;
  let plan = await stage('frontend', () => {
    const result = api.p86_plan(prepared.seed, source, sourceText);
    if (result?.$ === 'P86PlanError') reject(result.error);
    tagged(result, 'P86PlanReady', 'frontend plan');
    tagged(result.request, 'NR_Request', 'checked request');
    report.sourceChecked = true;
    report.verdict = errorText(result.verdict, 'frontend verdict');
    return result;
  }, true);
  prepared = sourceText = null;
  await stage('frontend-counts', () => {
    report.requestCounts = {};
    for (const field of ['source', 'book', 'names', 'paths', 'scope'])
      report.requestCounts[field] = listCount(plan.request[field], 'request ' + field);
  });
  await stage('runtime-admission', () => {
    const error = errorText(api.p111_runtime_admission(plan.request), 'runtime admission');
    if (error) reject(error, 'compile: ');
    report.runtimeAdmitted = true;
  }, true);
  let chunks = await stage('integrated-compiler', () => {
    const result=tagged(api.p111_emit_admitted(plan.request,''),'P111Emission','integrated compiler');
    const error=errorText(result.error,'integrated compiler');
    if(error)reject(error);
    report.irVerified=true;
    return result.chunks;
  },true);
  plan=null;
  await stage('write', () => {
    const target = path.join(out, 'program.ssa'), fd = fs.openSync(target, 'wx');
    let cursor = chunks, count = 0, bytes = 0;
    try {
      while (cursor?.$ === 'Con') {
        if (typeof cursor.head !== 'string') throw Error('Invalid emitted chunk');
        const buffer = Buffer.from(cursor.head + '\n');
        let offset = 0;
        while (offset < buffer.length) {
          const written = fs.writeSync(fd, buffer, offset, buffer.length - offset);
          if (written <= 0) throw Error('Incomplete QBE write');
          offset += written;
        }
        bytes += buffer.length;
        count++;
        cursor = cursor.tail;
      }
      if (cursor?.$ !== 'Nil' || count === 0) throw Error('Invalid emitted chunk list');
    } finally { fs.closeSync(fd); }
    report.chunks = count;
    report.writtenBytes = bytes;
  });
  chunks = null;
  await stage('output-authentication', () => {
    report.product = pin(path.join(out, 'program.ssa'));
    if (report.product.bytes !== report.writtenBytes) throw Error('Written QBE length changed');
    for (const row of inputs) verify(row);
  });
  report.complete = true;
} catch (error) {
  report.failedStage = activeStage;
  report.error = String(error);
  report.exception = exceptionDetails(error);
  if (report.exception.stack !== null) {
    try {
      const stackFile = path.join(out, 'error-stack.txt');
      fs.writeFileSync(stackFile, report.exception.stack + '\n', {flag: 'wx'});
      report.errorStack = pin(stackFile);
    } catch (captureError) {
      report.errorStackCaptureError = String(captureError);
    }
  }
  process.exitCode = 1;
} finally {
  report.compilerSeconds = report.stages.filter(row => row.compiler).reduce((sum, row) => sum + row.seconds, 0);
  report.writeSeconds = report.stages.find(row => row.name === 'write')?.seconds ?? 0;
  report.totalSeconds = (performance.now() - totalStart) / 1000;
  report.finishedUtc = new Date().toISOString();
  report.memory = memory();
  save();
  console.log(JSON.stringify({complete: report.complete, failedStage: report.failedStage,
    compilerSeconds: report.compilerSeconds, writeSeconds: report.writeSeconds,
    totalSeconds: report.totalSeconds, counts: report.counts, bytes: report.product?.bytes}));
}
