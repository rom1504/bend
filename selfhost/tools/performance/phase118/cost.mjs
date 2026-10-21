// Matched hosted compilation cost only. Every compiler decision stays in Bend.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';

const root = path.resolve(import.meta.dirname, '../../../..');
const [apiArg, sourceArg, outArg, ...requested] = process.argv.slice(2);
if (!apiArg || !sourceArg || !outArg) throw Error('Usage: bun cost.mjs CANDIDATE_API_REPORT SOURCE_MANIFEST FRESH_OUTPUT [CASE ...]');
if (!process.versions.bun) throw Error('Run both hosted compilers under the same pinned Bun');
if (!process.env.P118_PARENT_API_REPORT) throw Error('P118_PARENT_API_REPORT must name a checked Phase117 same-source API exporting p111_emit_admitted; selected Phase117 API lacks that export');
if (!process.env.P118_RUNTIME_REPORT) throw Error('P118_RUNTIME_REPORT must identify the candidate target runtime (not executed here)');
const out = path.resolve(outArg);
if (fs.existsSync(out) || !out.startsWith(root + '/selfhost/build/phase118/')) throw Error('Fresh Phase118 output directory required');
const read = file => JSON.parse(fs.readFileSync(file, 'utf8'));
const pin = file => {
  file = path.resolve(file);
  const bytes = fs.readFileSync(file);
  return {file, bytes: bytes.length, sha256: crypto.createHash('sha256').update(bytes).digest('hex')};
};
const same = (a, b) => a?.file === b?.file && a?.bytes === b?.bytes && a?.sha256 === b?.sha256;
const verify = record => { if (!same(pin(record.file), record)) throw Error('Changed input: ' + record.file); };
const tag = (value, name) => { if (value?.$ !== name) throw Error('Expected ' + name + ': ' + (value?.error ?? value?.$)); return value; };
const good = error => { if (typeof error !== 'string' || error) throw Error('Bend diagnostic: ' + error); };
const parentFile = path.join(root, 'implementation/phase117/selection.json');
const parent = read(parentFile), candidate = read(apiArg), source = read(sourceArg);
const baselineFile = path.resolve(process.env.P118_PARENT_API_REPORT), baseline = read(baselineFile);
const runtimeFile = path.resolve(process.env.P118_RUNTIME_REPORT), runtime = read(runtimeFile);
const required = ['p88_cache_prepare', 'p86_plan', 'p111_runtime_admission', 'p111_emit_admitted'];
for (const [role, api, expected] of [['baseline', baseline, parent.source], ['candidate', candidate, source.source]]) {
  if (!api.complete || !api.checked || !api.inputs?.some(x => same(x, expected))) throw Error(role + ': API not checked against exact compiler source');
  if (!required.every(name => api.exports?.includes(name))) throw Error(role + ': missing matched entry export');
}
if (!source.complete || !runtime.complete || !runtime.object || !runtime.source) throw Error('Incomplete candidate source/runtime identity');
const manifestFile = process.env.P118_CASE_MANIFEST ? path.resolve(process.env.P118_CASE_MANIFEST) : path.join(root, 'selfhost/tools/performance/phase112/benchmark45/manifest01.json');
const manifest = read(manifestFile);
const names = requested.length ? requested : ['coverage-map-churn-128', 'coverage-list-pipeline-128', 'lexer', 'tree-bitonic', 'coverage-closures-256', 'editdist', 'variation-local-fold-128-0', 'coverage-numeric-recurrence-1024'];
if (new Set(names).size !== names.length) throw Error('Duplicate case names');
const cases = names.map(name => { const item = manifest.cases.find(x => x.name === name); if (!item) throw Error('Unknown frozen case: ' + name); return item; });
const nativeFile = path.join(root, 'selfhost/tools/native/selection.json'), native = read(nativeFile);
verify(native.admission);
const admission = read(native.admission.file);
if (!admission.complete || !admission.qualified) throw Error('Unqualified frozen Base/cache');
const {base, cache} = admission.assets;
const identities = {
  baseline: {source: parent.source, api: baseline.api, runtime: parent.runtime, apiReport: pin(baselineFile)},
  candidate: {source: source.source, api: candidate.api, runtime: runtime.object, runtimeSource: runtime.source, apiReport: pin(apiArg), sourceManifest: pin(sourceArg), runtimeReport: pin(runtimeFile)},
};
const inputs = [pin(import.meta.filename), pin(process.execPath), pin(parentFile), pin(manifestFile), pin(nativeFile), native.admission, base, cache.carrier,
  parent.source, parent.runtime, pin(baselineFile), baseline.api, ...baseline.inputs,
  pin(apiArg), candidate.api, ...candidate.inputs, pin(sourceArg), source.source, ...source.inputs,
  pin(runtimeFile), runtime.source, runtime.object, ...runtime.inputs,
  ...cases.flatMap(item => [item.source, item.expectedStdoutEvidence])];
const expected = {};
for (const role of ['baseline', 'candidate']) {
  const file = process.env[role === 'baseline' ? 'P118_PARENT_EMISSION_REPORT' : 'P118_EXPECT_EMISSION_REPORT'];
  if (!file) continue;
  const evidence = read(file);
  if (!evidence.complete || !same(evidence.source, identities[role].source)) throw Error(role + ': emission evidence has different source');
  expected[role] = new Map(cases.map(item => {
    const row = evidence.cases?.find(x => x.name === item.name);
    if (!row?.verified || !row.qbe || !same(row.source, item.source)) throw Error(role + ': missing verified emission for ' + item.name);
    inputs.push(row.qbe);
    return [item.name, row.qbe];
  }));
  inputs.push(pin(file));
}
const uniqueInputs = [...new Map(inputs.map(record => [record.file, record])).values()];
for (const record of inputs) verify(record);
fs.mkdirSync(out);
fs.copyFileSync(import.meta.filename, path.join(out, 'method.mjs'));
const report = {
  kind: 'phase118-matched-integrated-hosted-cost', complete: false, identities, inputs: uniqueInputs,
  host: {bun: process.versions.bun, executable: pin(process.execPath), pid: process.pid, cpuAffinity: fs.readFileSync('/proc/self/status', 'utf8').match(/^Cpus_allowed_list:\s*(.*)$/m)?.[1] ?? null},
  method: {entry: 'p111_emit_admitted', warmups: 1, measuredRounds: 3, preparedSeed: 'separate per API from identical authenticated Base/cache bytes; no cross-compiler checked-IR reuse',
    timing: 'wholePreparedSeconds = frontend + runtime admission + complete admitted entry; includes Bend lowering, planning, verification and QBE chunk rendering; host output serialization/hash is reported separately',
    order: 'case order rotates each round; baseline/candidate pair order alternates by round and case position',
    qualification: 'Successful checked emission plus per-role deterministic bytes. Optional exact frozen-emission replay. No target execution, native compiler timing, upstream timing, or standalone semantic equivalence claim.'},
  caseNames: names, import: [], preparation: [], rows: [], summaries: [],
};
const save = () => fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
const digest = chunks => {
  const hash = crypto.createHash('sha256'); let bytes = 0, count = 0, hasEntry = false;
  while (chunks?.$ === 'Con') {
    if (typeof chunks.head !== 'string') throw Error('Non-string QBE chunk');
    const text = chunks.head + '\n'; hash.update(text); bytes += Buffer.byteLength(text); count++;
    hasEntry ||= chunks.head.includes('export function'); chunks = chunks.tail;
  }
  tag(chunks, 'Nil'); if (!hasEntry || !bytes) throw Error('Empty/refused QBE emission');
  return {sha256: hash.digest('hex'), bytes, chunks: count};
};
const median = values => [...values].sort((a, b) => a - b)[Math.floor(values.length / 2)];
const start = performance.now(); save();
try {
  const apis = {}, seeds = {}, stable = new Map();
  const baseText = fs.readFileSync(base.file, 'utf8'), carrierText = fs.readFileSync(cache.carrier.file, 'utf8');
  const sourceTexts = new Map(cases.map(item => [item.name, fs.readFileSync(item.source.file, 'utf8')]));
  for (const role of ['baseline', 'candidate']) {
    let clock = performance.now(); apis[role] = (await import(pathToFileURL(identities[role].api.file))).default;
    report.import.push({role, seconds: (performance.now() - clock) / 1000});
    if (!required.every(name => typeof apis[role][name] === 'function')) throw Error(role + ': actual API missing export');
    clock = performance.now(); seeds[role] = tag(apis[role].p88_cache_prepare(base.file, baseText, carrierText, cache.stamp), 'P86PreparationReady').seed;
    report.preparation.push({role, seconds: (performance.now() - clock) / 1000}); save();
  }
  for (let round = -1; round < 3; round++) {
    const shift = round < 0 ? 0 : round % cases.length;
    const ordered = [...cases.slice(shift), ...cases.slice(0, shift)];
    for (const [position, item] of ordered.entries()) {
      const roles = (round + position + 1) % 2 ? ['candidate', 'baseline'] : ['baseline', 'candidate'];
      for (const [pairPosition, role] of roles.entries()) {
        const api = apis[role], stages = {}, begin = performance.now(); let clock = begin;
        const request = tag(api.p86_plan(seeds[role], item.source.file, sourceTexts.get(item.name)), 'P86PlanReady').request;
        stages.frontendSeconds = (performance.now() - clock) / 1000; clock = performance.now();
        const error = api.p111_runtime_admission(request); good(error);
        stages.admissionSeconds = (performance.now() - clock) / 1000; clock = performance.now();
        const emitted = tag(api.p111_emit_admitted(request, error), 'P111Emission'); good(emitted.error);
        stages.admittedSeconds = (performance.now() - clock) / 1000;
        const wholePreparedSeconds = (performance.now() - begin) / 1000; clock = performance.now();
        const output = digest(emitted.chunks), serializationHashSeconds = (performance.now() - clock) / 1000;
        const key = role + ':' + item.name, prior = stable.get(key);
        if (prior && (prior.sha256 !== output.sha256 || prior.bytes !== output.bytes)) throw Error('Nondeterministic output: ' + key);
        stable.set(key, output);
        const wanted = expected[role]?.get(item.name);
        if (wanted && (wanted.sha256 !== output.sha256 || wanted.bytes !== output.bytes)) throw Error('Frozen-emission mismatch: ' + key);
        report.rows.push({name: item.name, source: item.source, role, round, warmup: round < 0, position, pairPosition, wholePreparedSeconds, stages, serializationHashSeconds, output, exactEmissionReplay: wanted ?? null});
        save();
      }
      console.log(JSON.stringify({round, name: item.name, complete: true}));
    }
  }
  for (const name of names) {
    const byRole = Object.fromEntries(['baseline', 'candidate'].map(role => {
      const rows = report.rows.filter(row => row.name === name && row.role === role && !row.warmup);
      return [role, {wholePreparedMedian: median(rows.map(row => row.wholePreparedSeconds)), admittedMedian: median(rows.map(row => row.stages.admittedSeconds)), frontendMedian: median(rows.map(row => row.stages.frontendSeconds)), output: rows[0].output}];
    }));
    report.summaries.push({name, ...byRole, candidateOverParent: byRole.candidate.wholePreparedMedian / byRole.baseline.wholePreparedMedian, admittedCandidateOverParent: byRole.candidate.admittedMedian / byRole.baseline.admittedMedian});
  }
  report.geometricCandidateOverParent = Math.exp(report.summaries.reduce((sum, row) => sum + Math.log(row.candidateOverParent), 0) / names.length);
  report.geometricAdmittedCandidateOverParent = Math.exp(report.summaries.reduce((sum, row) => sum + Math.log(row.admittedCandidateOverParent), 0) / names.length);
  for (const record of report.inputs) verify(record);
  report.complete = true;
} catch (error) { report.error = String(error); process.exitCode = 1; }
finally { report.seconds = (performance.now() - start) / 1000; report.peakRss = process.resourceUsage().maxRSS * 1024; save(); }
