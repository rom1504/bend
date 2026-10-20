// Diagnostic transport for the checked Bend entry. No host semantic lowering.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';

const args = process.argv.slice(2);
const [apiArg, inputArg, outArg, mode = 'cache', pipeline = 'array', scaling = 'baseline'] = args;
if (args.length < 3 || args.length > 6 || !['cache', 'live'].includes(mode) || !['direct','array'].includes(pipeline) || !['baseline','cached'].includes(scaling))
  throw Error('Usage: staged-emit.mjs CHECKED_API INPUT FRESH_OUT [cache|live] [direct|array] [baseline|cached]');
const root = path.resolve(import.meta.dirname, '../../../../..');
const apiFile = path.resolve(apiArg), source = path.resolve(inputArg), out = path.resolve(outArg);
if (!['phase111','phase114'].some(phase => out.startsWith(root + '/selfhost/build/' + phase + '/')) || fs.existsSync(out))
  throw Error('Fresh Phase111 or Phase114 output required');

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
const splitExports = ['p113pl_lower_request', ...(scaling === 'baseline'
  ? ['p113i_lowered','p113k_lowered']
  : ['p114s_open_lowered','p114s_inline_lowered','p114s_ranges_lowered','p114s_close_lowered'])];
const requiredExports = ['p88_cache_prepare', 'p86_prepare', 'p86_plan',
  'p111_runtime_admission', ...splitExports, verifier, renderer,
  ...(pipeline === 'array' ? ['p113a_certificate','p113a_finish'] : [])];
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
const parentMethod = pin(path.join(root, 'selfhost/tools/performance/phase113/staged-emit-v2.mjs'));
const inputs = [pin(import.meta.filename), parentMethod, pin(apiFile), pin(apiRecordFile), pin(source),
  pin(selectionFile), selection.admission, base, ...(mode === 'cache' ? [cache.carrier] : []),
  pin(process.execPath)];
fs.mkdirSync(out, {recursive: true});
fs.copyFileSync(import.meta.filename, path.join(out, 'staged-emit-method.mjs'));
const report = {kind: 'phase114-split-checked-source-qbe-emission', complete: false, mode, pipeline,
  transportVersion: 1, scaling, derivedFrom: parentMethod, lowering, verifier, renderer, rendererReverifies, explicitVerificationPasses: 1,
  admittedRendererGuard: 'Only called after successful explicit verification of the same in-memory program; no replacement or host semantic transformation.',
  inputs, requiredExports, startedUtc: new Date().toISOString(), stages: [], sourceChecked: false,
  runtimeAdmitted: false, irVerified: false, compilerHost: 'checked Bend source API acquired by pinned TypeScript',
  composition: 'prepare -> p86_plan -> runtime admission -> array certificate -> product lowering -> inlining -> ranges -> unchanged final verify -> QBE chunks -> exact chunk write',
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
  let certificate = pipeline === 'array' ? await stage('array-certificate', () =>
    tagged(api.p113a_certificate(plan.request),'P113ACertificate','array certificate'), true) : null;
  let lowered = await stage('product-lowering', () =>
    tagged(api.p113pl_lower_request(plan.request),'P113DLowered','product lowering'), true);
  if (errorText(lowered.error,'product lowering')) reject(lowered.error,'native lowering: ');
  report.functionCounts = {planned: listCount(lowered.program.functions,'planned functions')};
  if (scaling === 'baseline') {
    lowered = await stage('inlining-with-verification', () =>
      tagged(api.p113i_lowered(lowered),'P113DLowered','inlined lowering'), true);
    report.functionCounts.inlined = listCount(lowered.program.functions,'inlined functions');
    lowered = await stage('ranges-with-verification', () =>
      tagged(api.p113k_lowered(lowered),'P113DLowered','range lowering'), true);
  } else {
    let boundary = await stage('verification-boundary', () =>
      tagged(api.p114s_open_lowered(lowered),'P114SLowered','verification boundary'), true);
    lowered = null;
    boundary = await stage('inlining-with-direct-verification', () =>
      tagged(api.p114s_inline_lowered(boundary),'P114SLowered','inlined boundary'), true);
    report.functionCounts.inlined = listCount(boundary.boundary.functions,'inlined functions');
    boundary = await stage('ranges-with-direct-verification', () =>
      tagged(api.p114s_ranges_lowered(boundary),'P114SLowered','range boundary'), true);
    lowered = await stage('close-verification-boundary', () =>
      tagged(api.p114s_close_lowered(boundary),'P113DLowered','closed boundary'), true);
    boundary = null;
  }
  if (errorText(lowered.error,'optimized lowering')) reject(lowered.error,'native lowering: ');
  report.functionCounts.ranged = listCount(lowered.program.functions,'ranged functions');
  let program = pipeline === 'array' ? await stage('array-facade', () =>
    tagged(api.p113a_finish(certificate,lowered),'P113ALowered','array lowering').program, true)
    : lowered.program;
  tagged(program,pipeline === 'array' ? 'P113AProgram' : 'P113DProgram','lowered program');
  lowered = certificate = null;
  plan = null;
  await stage('program-counts', () => {
    const direct = tagged(pipeline === 'array' ? program.original : program, 'P113DProgram', 'direct program');
    const base = tagged(direct.original, 'P112StaticProgram', 'static program');
    report.counts = programCounts(base.program);
    report.counts.staticNodes = listCount(base.nodes, 'static nodes');
    report.counts.directFunctions = listCount(direct.functions, 'direct functions');
    if (pipeline === 'array') {
      const certificate = tagged(program.certificate, 'P113ACertificate', 'array certificate');
      const flag = value => {
        if (typeof value === 'boolean') return value;
        if (!['True','False'].includes(value?.$)) throw Error('Invalid array certificate flag');
        return value.$ === 'True';
      };
      report.arrayCertificate = {scalar: flag(certificate.scalar), unshared: flag(certificate.unshared)};
      report.arrayCertificate.enabled = report.arrayCertificate.scalar && report.arrayCertificate.unshared;
    }
  });
  await stage('ir-verification', () => {
    const error = errorText(api[verifier](program), 'IR verification');
    if (error) reject(error, 'structured IR: ');
    report.irVerified = true;
  }, true);
  let chunks = await stage('qbe-emission', () => {
    if (!report.irVerified) throw Error('Renderer requires successful explicit verification');
    return api[renderer](program);
  }, true);
  program = null;
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
