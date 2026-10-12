// Root executes this process under its CPU3 resource guard. Source-only until then.
// Original bytes stay exact; appended observation wrappers call original closures.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';
import {requiredOccurrenceSetHelpers, runOccurrenceSetControls} from './occurrence-set-controls-v1.mjs';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../../../../..');
const [baselineArg, candidateArg, outArg] = process.argv.slice(2);
assert(baselineArg && candidateArg && outArg,
  'usage: node run-occurrence-set-controls-v1.mjs BASELINE_B1_API CANDIDATE_B1_API FRESH_PHASE70_OUTPUT');
const output = path.resolve(outArg);
const raw = path.join(root, 'selfhost/build/phase70');
assert(output.startsWith(raw + path.sep) && !fs.existsSync(output), 'fresh Phase70 output required');
fs.mkdirSync(output, {recursive: true});
const sha = bytes => createHash('sha256').update(bytes).digest('hex');
const pin = file => {
  const bytes = fs.readFileSync(file);
  return {file: path.resolve(file), sha256: sha(bytes), bytes: bytes.length};
};
const originals = [];
const reportFile = path.join(output, 'report.json');
const report = {
  kind: 'phase70-occurrence-set-paired-controls', complete: false, pass: false,
  scope: 'Append-only diagnostic exports and observation wrappers over caller-bound checked B1 images; full summary equality and insertion counts, no timing/C/native claim.',
  inputs: [pin(fileURLToPath(import.meta.url)), pin(path.join(here, 'occurrence-set-controls-v1.mjs'))],
  derivations: [], results: {},
};
const save = () => fs.writeFileSync(reportFile, JSON.stringify(report, null, 2) + '\n');
save();

function derive(role, argument) {
  const input = fs.realpathSync(argument);
  const original = fs.readFileSync(input);
  const text = original.toString('utf8');
  assert.equal(Buffer.from(text).compare(original), 0, role + ' UTF-8 roundtrip');
  assert(!text.includes('phase70OccurrenceQueries'), role + ' already extended API');
  const helpers = Object.entries(requiredOccurrenceSetHelpers);
  const counted = {index_set: 4, index_tip: 2, index_insert: 4, index_leaf: 3};
  for (const [name] of [...helpers.map(([key, pair]) => pair), ...Object.entries(counted)]) {
    const escaped = '\\$' + name + '\\$';
    assert.equal([...text.matchAll(new RegExp('^function ' + escaped + '\\(', 'gm'))].length,
      1, role + ' exact original closure: ' + name);
  }
  const exports = helpers.map(([key, [name, arity]]) => {
    const args = Array.from({length: arity}, (_, i) => 'a' + i);
    const values = args.join(', ');
    const keep = args.map(a => '(' + a + ');').join(' ');
    return `  ${key}: run_lib((${values}) => { const r = run_loop($${name}$(${values})); ${keep} return r; }, ${arity}),`;
  });
  const zero = JSON.stringify(Object.fromEntries(Object.keys(counted).map(key => [key, 0])));
  const instrumentation = Object.entries(counted).map(([name, arity]) => {
    const args = Array.from({length: arity}, (_, i) => 'a' + i).join(', ');
    return `const p70Original_${name} = $${name}$;\n` +
      `$${name}$ = function(${args}) { p70Counters.${name}++; return p70Original_${name}(${args}); };`;
  }).join('\n');
  const suffix = '\n// Diagnostic counters call unchanged original closures; no timing credit.\n' +
    `let p70Counters = ${zero};\n` + instrumentation + '\n' +
    'export const phase70OccurrenceQueries = {\n' + exports.join('\n') + '\n' +
    `  resetCounters: () => { p70Counters = ${zero}; },\n` +
    '  readCounters: () => ({...p70Counters}),\n};\n';
  const derived = path.join(output, role + '-query-api.mjs');
  fs.writeFileSync(derived, Buffer.concat([original, Buffer.from(suffix)]), {flag: 'wx'});
  assert.equal(fs.readFileSync(derived).subarray(0, original.length).compare(original), 0);
  assert.equal(fs.readFileSync(derived).subarray(original.length).toString(), suffix);
  originals.push({input, original});
  report.inputs.push(pin(input));
  report.derivations.push({role, input: pin(input), output: pin(derived),
    appendOffset: original.length, exactAppend: suffix, appendSha256: sha(Buffer.from(suffix)),
    originalPrefixByteIdentical: true});
  save();
  return derived;
}

try {
  const derived = {
    baseline: derive('baseline', baselineArg),
    candidate: derive('candidate', candidateArg),
  };
  for (const role of ['baseline', 'candidate']) {
    const imported = await import(pathToFileURL(derived[role]));
    const api = {...imported.phase70OccurrenceQueries};
    report.results[role] = runOccurrenceSetControls(api);
    assert.equal(report.results[role].pass, true);
    assert.equal(report.results[role].rows.length, 38, role + ' planned term count');
    save();
  }
  const structural = result => ({...result, rows: result.rows.map(({counters, ...rest}) => rest)});
  assert.deepEqual(structural(report.results.candidate), structural(report.results.baseline),
    'all actual summary indexes, partitions and sharing strings agree');
  let reducedCases = 0;
  for (let i = 0; i < report.results.baseline.rows.length; ++i) {
    const before = report.results.baseline.rows[i], after = report.results.candidate.rows[i];
    assert.equal(after.counters.index_tip, before.counters.index_tip, before.name + ' unchanged search work');
    assert(after.counters.index_insert <= before.counters.index_insert, before.name + ' no extra inserts');
    assert(after.counters.index_leaf <= before.counters.index_leaf, before.name + ' no extra leaves');
    if (after.counters.index_insert < before.counters.index_insert) ++reducedCases;
    if (before.name === 'repeated-single') {
      assert(before.counters.index_insert > 0 && after.counters.index_insert === 0,
        'repeated identical IDs avoid all replacement inserts');
    }
    if (before.name === 'unique-ids') {
      assert.equal(after.counters.index_insert, before.counters.index_insert, 'unique IDs unchanged insert count');
      assert.equal(after.counters.index_leaf, before.counters.index_leaf, 'unique IDs unchanged leaf count');
    }
  }
  assert(reducedCases > 0);
  report.reducedCases = reducedCases;
  for (const {input, original} of originals) {
    assert.equal(fs.readFileSync(input).compare(original), 0, 'original API changed: ' + input);
  }
  for (const input of report.inputs) assert.deepEqual(pin(input.file), input, 'consumed input changed');
  report.originalsPreserved = true;
  report.fullSummaryEquality = true;
  report.complete = true;
  report.pass = true;
  save();
  console.log(JSON.stringify({report: reportFile, pairedTerms: 38, pass: true}));
} catch (error) {
  report.complete = true;
  report.error = {name: error.name, message: error.message, stack: error.stack};
  report.originalsPreserved = originals.every(({input, original}) =>
    fs.existsSync(input) && fs.readFileSync(input).compare(original) === 0);
  save();
  throw error;
}
