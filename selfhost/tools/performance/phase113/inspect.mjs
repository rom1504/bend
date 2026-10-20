// Authenticated diagnostic transport. All lowering and admission stay in Bend.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [apiArg, inputArg, outArg, ...options] = process.argv.slice(2);
if (!apiArg || !inputArg || !outArg || options.some(x => x.startsWith('--') && !['--actual', '--live'].includes(x)))
  throw Error('Usage: inspect.mjs CHECKED_API SOURCE FRESH_PHASE111_OUT [--actual] [--live] [exact-function-name ...]');
const actual = options.includes('--actual'), mode = options.includes('--live') ? 'live' : 'cache';
const names = [...new Set(options.filter(x => !x.startsWith('--')))];
const root = path.resolve(import.meta.dirname, '../../../..');
const apiFile = path.resolve(apiArg), source = path.resolve(inputArg), out = path.resolve(outArg);
const outputRoot = path.join(root, 'selfhost/build/phase111');
if (!out.startsWith(outputRoot + path.sep) || fs.existsSync(out))
  throw Error('Fresh Phase111 output required');
// Do not follow an output-directory symlink beyond the authenticated workspace.
let parent = path.dirname(out);
while (!fs.existsSync(parent)) parent = path.dirname(parent);
if (fs.realpathSync(parent) !== parent) throw Error('Symlink output parent refused');

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
  if (!row || typeof row.file !== 'string') throw Error('Invalid authentication row');
  const found = pin(row.file);
  if (found.bytes !== row.bytes || found.sha256 !== row.sha256) throw Error('Changed input ' + row.file);
}
const json = value => JSON.stringify(value, (_, v) => typeof v === 'bigint' ? {$bigint: v.toString()} : v, 2) + '\n';
function tagged(value, tag, label = tag) {
  if (value?.$ !== tag) throw Error('Unexpected ' + label + ' tag: ' + String(value?.$));
  return value;
}
function text(value, label) {
  if (typeof value !== 'string') throw Error('Non-string ' + label);
  return value;
}
function u32(value, label) {
  if (!Number.isInteger(value) || value < 0 || value > 0xffffffff) throw Error('Invalid U32 ' + label);
  return value;
}
function truth(value) {
  if (value === true || value?.$ === 'True') return true;
  if (value === false || value?.$ === 'False') return false;
  throw Error('Unexpected Bool');
}
function list(xs, label, visit = () => {}) {
  let count = 0;
  while (xs?.$ === 'Con') { visit(xs.head); count++; xs = xs.tail; }
  if (xs?.$ !== 'Nil') throw Error('Invalid ' + label + ' list tail');
  return count;
}
function array(xs, label) {
  const rows = [];
  list(xs, label, row => rows.push(row));
  return rows;
}
function memory() {
  const result = {heapUsedBytes: process.memoryUsage().heapUsed};
  try {
    const status = fs.readFileSync('/proc/self/status', 'utf8');
    for (const [field, key] of [['VmRSS', 'rssBytes'], ['VmHWM', 'processLifetimeMaxRssBytes']]) {
      const match = status.match(new RegExp('^' + field + ':\\s+(\\d+) kB$', 'm'));
      if (match) result[key] = Number(match[1]) * 1024;
    }
  } catch {}
  return result;
}
const frequency = () => Object.create(null);
const increment = (table, key) => { table[key] = (table[key] ?? 0) + 1; };
function emptyCounts() {
  return {directStatements: 0, scalarStatements: 0, directTags: frequency(),
    scalarTags: frequency(), runtimeImports: frequency(), directCalls: frequency()};
}
function statementCounts(body) {
  const counts = emptyCounts(), stack = [{body, scalar: false}];
  while (stack.length) {
    const {body: current, scalar} = stack.pop();
    list(current, scalar ? 'scalar body' : 'direct body', stmt => {
      const tag = text(stmt?.$, 'statement tag');
      if (scalar) {
        counts.scalarStatements++;
        increment(counts.scalarTags, tag);
        if (tag === 'N111Call') increment(counts.runtimeImports, text(stmt.symbol, 'import symbol'));
        if (tag === 'N111If') stack.push({body: stmt.no, scalar: true}, {body: stmt.yes, scalar: true});
      } else {
        counts.directStatements++;
        increment(counts.directTags, tag);
        if (tag === 'P113DScalar') stack.push({body: {$: 'Con', head: stmt.stmt, tail: {$: 'Nil'}}, scalar: true});
        if (tag === 'P113DIf') stack.push({body: stmt.no, scalar: false}, {body: stmt.yes, scalar: false});
        if (tag === 'P113DCall') increment(counts.directCalls, text(stmt.target, 'direct target'));
      }
    });
  }
  return counts;
}
function addCounts(total, row) {
  for (const key of ['directStatements', 'scalarStatements']) total[key] += row[key];
  for (const key of ['directTags', 'scalarTags', 'runtimeImports', 'directCalls'])
    for (const [name, count] of Object.entries(row[key])) total[key][name] = (total[key][name] ?? 0) + count;
}
function functionSummary(fn) {
  tagged(fn, 'P113DFunction');
  const params = array(fn.params, 'parameters').map(param => {
    tagged(param, 'NC_Binding');
    return {id: u32(param.id, 'parameter id'), word: text(param.word, 'parameter word'),
      kind: text(param.kind?.$, 'parameter kind')};
  });
  return {name: text(fn.name, 'function name'), params, arity: params.length,
    result: u32(fn.result, 'result count'), public: truth(fn.public), counts: statementCounts(fn.body)};
}

const requiredExports = [mode === 'cache' ? 'p88_cache_prepare' : 'p86_prepare', 'p86_plan',
  'p111_runtime_admission', 'p113d_inspect_request', ...(actual ? ['p113d_lower_request', 'p113d_verify'] : [])];
const apiRecordFile = path.join(path.dirname(apiFile), 'report.json');
const apiRecord = JSON.parse(fs.readFileSync(apiRecordFile));
if (!apiRecord.complete || !apiRecord.checked || !requiredExports.every(name => apiRecord.exports?.includes(name)))
  throw Error('Complete checked API with all inspection exports required');
verify(apiRecord.api);
if (path.resolve(apiRecord.api.file) !== apiFile) throw Error('API differs from checked receipt');
if (!Array.isArray(apiRecord.inputs) || !apiRecord.inputs.length) throw Error('API acquisition input pins required');
for (const row of apiRecord.inputs) verify(row);
const selectionFile = path.join(root, 'selfhost/tools/native/selection.json');
const selection = JSON.parse(fs.readFileSync(selectionFile));
if (!selection.complete) throw Error('Native seed selection incomplete');
verify(selection.admission);
const admission = JSON.parse(fs.readFileSync(selection.admission.file));
if (!admission.complete || !admission.qualified) throw Error('Native seed admission incomplete');
const {base, cache} = admission.assets;
verify(base);
if (mode === 'cache') verify(cache.carrier);
const inputs = [pin(import.meta.filename), pin(apiFile), pin(apiRecordFile), pin(source),
  pin(selectionFile), selection.admission, base, ...(mode === 'cache' ? [cache.carrier] : []),
  pin(process.execPath), ...apiRecord.inputs];
fs.mkdirSync(out, {recursive: true});
const methodFile = path.join(out, 'inspect-method.mjs');
fs.copyFileSync(import.meta.filename, methodFile);
const report = {kind: 'phase113-checked-direct-function-inspection', complete: false, mode, actualRequested: actual,
  requestedNames: names, inputs, method: pin(methodFile), requiredExports, apiAcquisition: apiRecord,
  seed: {selection: pin(selectionFile), admission: selection.admission, base,
    ...(mode === 'cache' ? {cacheCarrier: cache.carrier, cacheStamp: cache.stamp} : {})},
  startedUtc: new Date().toISOString(), stages: [], sourceChecked: false, runtimeAdmitted: false,
  irVerified: false, products: [], compilerHost: 'checked Bend source API acquired by pinned TypeScript',
  composition: 'prepare -> p86_plan -> runtime admission -> p113d_inspect_request -> host metadata walk; optional separate p113d_lower_request -> p113d_verify',
  timingScope: 'Preparation/frontend/runtime gates, diagnostic inspection, optional actual lowering/verification, and host summaries have separate stages. No emission or native execution. Diagnostic cost is not an ordinary compilation measurement.',
  countScope: 'Each statement occurrence is counted, including both branch arms. Scalar wrappers and wrapped scalar nodes have separate totals. runtimeImports counts every N111Call.symbol; directCalls counts P113DCall.target. These are static IR counts, not dynamic frequencies.',
  decisionScope: 'Candidate errors and call dependencies are returned by Bend. An empty local error does not imply final admission. actualAdmitted, when requested, is exact membership in the verified p113d_lower_request program.functions list. Host code makes no eligibility decisions.',
  rawScope: 'Only requested exact candidate/function names are serialized. Tagged IR records are retained; any BigInt is encoded as {$bigint: decimalString}.',
  memoryScope: 'Process RSS snapshots and lifetime high-water RSS; no forced GC or isolated stage peaks.'};
const save = () => fs.writeFileSync(path.join(out, 'report.json'), json(report));
const totalStart = performance.now();
let activeStage;
async function stage(name, category, action) {
  activeStage = name;
  const row = {name, category, status: 'running', before: memory()};
  report.stages.push(row); save();
  console.log(JSON.stringify({stage: name, status: 'running'}));
  const started = performance.now();
  try { const result = await action(); row.status = 'complete'; return result; }
  catch (error) { row.status = 'failed'; row.error = String(error); throw error; }
  finally {
    row.seconds = (performance.now() - started) / 1000; row.after = memory(); save();
    console.log(JSON.stringify({stage: name, status: row.status, seconds: row.seconds}));
  }
}
function reject(error, label) {
  text(error, label);
  if (error) throw Error(label + ': ' + error);
}
function writeProduct(name, value) {
  const file = path.join(out, name);
  fs.writeFileSync(file, json(value), {flag: 'wx'});
  report.products.push(pin(file));
}

save();
try {
  const api = await stage('api-import', 'host', async () => (await import(pathToFileURL(apiFile))).default);
  if (!requiredExports.every(name => typeof api[name] === 'function')) throw Error('Missing checked API function');
  let sourceText, baseText, carrierText;
  await stage('input-read', 'host', () => {
    sourceText = fs.readFileSync(source, 'utf8'); baseText = fs.readFileSync(base.file, 'utf8');
    carrierText = mode === 'cache' ? fs.readFileSync(cache.carrier.file, 'utf8') : '';
  });
  let prepared = await stage('preparation', 'frontend', () => {
    const value = mode === 'cache' ? api.p88_cache_prepare(base.file, baseText, carrierText, cache.stamp)
      : api.p86_prepare(base.file, baseText);
    if (value?.$ === 'P86PreparationError') throw Error(text(value.error, 'preparation'));
    return tagged(value, 'P86PreparationReady');
  });
  baseText = carrierText = null;
  let plan = await stage('frontend', 'frontend', () => {
    const value = api.p86_plan(prepared.seed, source, sourceText);
    if (value?.$ === 'P86PlanError') throw Error(text(value.error, 'frontend'));
    tagged(value, 'P86PlanReady'); tagged(value.request, 'NR_Request');
    report.sourceChecked = true; report.verdict = text(value.verdict, 'verdict');
    return value;
  });
  prepared = sourceText = null;
  await stage('request-counts', 'host', () => {
    report.requestCounts = {};
    for (const field of ['source', 'book', 'names', 'paths', 'scope'])
      report.requestCounts[field] = list(plan.request[field], 'request ' + field);
  });
  await stage('runtime-admission', 'frontend', () => {
    reject(api.p111_runtime_admission(plan.request), 'runtime admission'); report.runtimeAdmitted = true;
  });
  let candidates = await stage('candidate-inspection', 'diagnostic', () => api.p113d_inspect_request(plan.request));
  const rawCandidates = [], wanted = new Set(names);
  await stage('candidate-summary', 'host', () => {
    report.candidates = []; report.candidateCounts = emptyCounts(); report.candidateErrors = frequency();
    list(candidates, 'candidates', candidate => {
      tagged(candidate, 'P113DCandidate');
      const row = functionSummary(candidate.function);
      row.error = text(candidate.error, 'candidate error');
      row.callDependencies = array(candidate.calls, 'call dependencies').map(name => text(name, 'dependency'));
      increment(report.candidateErrors, row.error);
      addCounts(report.candidateCounts, row.counts); report.candidates.push(row);
      if (wanted.has(row.name)) rawCandidates.push(candidate);
    });
    report.candidateCount = report.candidates.length;
  });
  candidates = null;
  const rawFunctions = [];
  if (actual) {
    let program = await stage('actual-lowering', 'actual', () => {
      const value = tagged(api.p113d_lower_request(plan.request), 'P113DLowered');
      reject(value.error, 'actual lowering');
      return tagged(value.program, 'P113DProgram');
    });
    await stage('actual-verification', 'actual', () => {
      reject(api.p113d_verify(program), 'actual verification'); report.irVerified = true;
    });
    await stage('actual-summary', 'host', () => {
      report.actualFunctions = []; report.actualCounts = emptyCounts();
      list(program.functions, 'actual functions', fn => {
        const row = functionSummary(fn);
        addCounts(report.actualCounts, row.counts); report.actualFunctions.push(row);
        if (wanted.has(row.name)) rawFunctions.push(fn);
      });
      const admitted = new Set(report.actualFunctions.map(row => row.name));
      for (const row of report.candidates) row.actualAdmitted = admitted.has(row.name);
      report.actualFunctionCount = report.actualFunctions.length;
    });
    program = null;
  }
  plan = null;
  await stage('selected-raw-write', 'host', () => {
    if (names.length) {
      const found = new Set([...rawCandidates.map(row => row.function.name), ...rawFunctions.map(row => row.name)]);
      report.unmatchedNames = names.filter(name => !found.has(name));
      writeProduct('selected-ir.json', {requestedNames: names, unmatchedNames: report.unmatchedNames,
        candidates: rawCandidates, actualFunctions: rawFunctions});
    }
  });
  await stage('input-output-authentication', 'host', () => {
    for (const row of [...inputs, report.method, ...report.products]) verify(row);
  });
  report.complete = true;
} catch (error) {
  report.failedStage = activeStage; report.error = String(error); process.exitCode = 1;
} finally {
  report.secondsByCategory = {};
  for (const row of report.stages)
    report.secondsByCategory[row.category] = (report.secondsByCategory[row.category] ?? 0) + row.seconds;
  report.totalSeconds = (performance.now() - totalStart) / 1000;
  report.finishedUtc = new Date().toISOString(); report.memory = memory(); save();
  console.log(JSON.stringify({complete: report.complete, failedStage: report.failedStage,
    candidates: report.candidateCount, actualFunctions: report.actualFunctionCount,
    secondsByCategory: report.secondsByCategory, totalSeconds: report.totalSeconds}));
}
