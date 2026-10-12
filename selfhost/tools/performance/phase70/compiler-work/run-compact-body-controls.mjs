// Root executes this process under its CPU3 resource guard. Source-only until then.
// Append diagnostic exports to exact original checked-B1 bytes; no function edits.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';
import {requiredCompactBodyHelpers, runCompactBodyControls} from './compact-body-controls-v2.mjs';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../../../../..');
const [baselineArg, candidateArg, outArg] = process.argv.slice(2);
assert(baselineArg && candidateArg && outArg,
  'usage: node run-compact-body-controls.mjs BASELINE_B1_API CANDIDATE_B1_API FRESH_PHASE70_OUTPUT');
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
  kind: 'phase70-compact-body-paired-controls', complete: false, pass: false,
  scope: 'Append-only diagnostic exports of caller-bound checked B1 images; actual helper terms, no C/native execution.',
  inputs: [pin(fileURLToPath(import.meta.url)), pin(path.join(here, 'compact-body-controls-v2.mjs'))],
  derivations: [], results: {},
};
const save = () => fs.writeFileSync(reportFile, JSON.stringify(report, null, 2) + '\n');
save();

function derive(role, argument) {
  const input = fs.realpathSync(argument);
  const original = fs.readFileSync(input);
  const text = original.toString('utf8');
  assert.equal(Buffer.from(text).compare(original), 0, role + ' UTF-8 roundtrip');
  assert(!text.includes('phase70CompactQueries'), role + ' already extended API');
  const helpers = Object.entries(requiredCompactBodyHelpers).filter(([name]) =>
    role !== 'baseline' || name !== 'nc_compact_definition');
  for (const [name] of helpers) {
    const escaped = '\\$' + name + '\\$';
    assert.equal([...text.matchAll(new RegExp('^function ' + escaped + '\\(', 'gm'))].length,
      1, role + ' exact original closure: ' + name);
  }
  const exports = helpers.map(([name, arity]) => {
    const args = Array.from({length: arity}, (_, i) => 'a' + i);
    const values = args.join(', ');
    const keep = args.map(a => '(' + a + ');').join(' ');
    return `  ${name}: run_lib((${values}) => { const r = run_loop($${name}$(${values})); ${keep} return r; }, ${arity}),`;
  });
  const suffix = '\n// Pure diagnostic exports; preceding checked image bytes are exact.\n' +
    'export const phase70CompactQueries = {\n' + exports.join('\n') + '\n};\n';
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
    const api = {...imported.phase70CompactQueries};
    if (role === 'baseline') {
      // The old compiler has no new accessor. Its oracle invokes its unchanged
      // Bend definition and compact helpers, exactly as the old consumers did.
      api.nc_compact_definition = (book, d, fresh) => api.nc_compact(api.nc_definition(book, d, fresh));
    }
    report.results[role] = runCompactBodyControls(api);
    assert.equal(report.results[role].pass, true);
    assert.equal(report.results[role].rows.length, 155, role + ' planned query count');
    save();
  }
  assert.deepEqual(report.results.candidate, report.results.baseline, 'all actual helper terms agree');
  for (const {input, original} of originals) {
    assert.equal(fs.readFileSync(input).compare(original), 0, 'original API changed: ' + input);
  }
  for (const input of report.inputs) assert.deepEqual(pin(input.file), input, 'consumed input changed');
  report.originalsPreserved = true;
  report.fullTermEquality = true;
  report.complete = true;
  report.pass = true;
  save();
  console.log(JSON.stringify({report: reportFile, pairedQueries: 155, pass: true}));
} catch (error) {
  report.complete = true;
  report.error = {name: error.name, message: error.message, stack: error.stack};
  report.originalsPreserved = originals.every(({input, original}) =>
    fs.existsSync(input) && fs.readFileSync(input).compare(original) === 0);
  save();
  throw error;
}
