// Full finite-result gate against frozen independent Phase156 reference results.
// Run only in the parent's guarded target lane; this file is source preparation.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {pin, verify, items} from '../../phase147/tools/support.mjs';
import {decodeGraph} from '../../phase154/tools/graph.mjs';

const args = {};
for (let i = 2; i < process.argv.length; i += 2) args[process.argv[i].slice(2)] = process.argv[i + 1];
const read = file => JSON.parse(fs.readFileSync(file));
const receipt = read(args['api-receipt']), source = read(args['source-manifest']), oracle = read(args.oracle);
assert(receipt.complete && receipt.checked && source.complete && oracle.complete);
assert.deepEqual(receipt.source, source.source);
assert.deepEqual(source.exports, ['p169c_result', 'p169c_run', 'p169c_fixtures']);
const modulePin = oracle.inputs.find(p => p.file.endsWith('/phase169/checker-workload.bend'));
assert(source.inputs.some(p => p.file === modulePin.file && p.sha256 === modulePin.sha256 && p.bytes === modulePin.bytes));
const inputs = [pin(import.meta.filename), pin(args['api-receipt']), pin(args['source-manifest']),
  pin(args.oracle), pin(new URL('../../phase154/tools/graph.mjs', import.meta.url)),
  receipt.api, receipt.source, ...source.inputs, ...oracle.inputs, ...oracle.cases.map(c => c.graph)];
inputs.forEach(verify);
const out = path.resolve(args.out); fs.mkdirSync(out, {recursive:false});
const report = {kind:'phase169-checker-complete-controls', complete:false, passed:false, inputs, rows:[],
  scope:'Ten full parsed books and full checker outputs against frozen independent references, then complete finite digest checks.'};
const save = () => fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
try {
  const api = (await import(pathToFileURL(receipt.api.file))).default;
  for (const c of oracle.cases) {
    const captured = decodeGraph(read(c.graph.file)), actual = api.p169c_result(c.index);
    const row = {name:c.name, passed:false}; report.rows.push(row); save();
    assert.equal(actual.$, 'P169CParsed');
    assert.deepEqual(actual.book, captured.book, 'Complete parsed book: ' + c.name);
    assert.deepEqual(actual.checked, captured.original, 'Complete DChecking: ' + c.name);
    assert.equal(actual.checked.result.error, c.error);
    row.passed = true; save();
  }
  for (const rounds of [0, 1]) {
    const actual = items(api.p169c_run(rounds));
    assert.deepEqual(actual, oracle.expected[String(rounds)]);
    report.rows.push({name:'complete-digest-' + rounds, passed:true, actual}); save();
  }
  inputs.forEach(verify);
  report.complete = true; report.passed = true;
} catch (error) {
  report.error = String(error.stack ?? error); process.exitCode = 1;
} finally {
  save(); console.log(JSON.stringify({complete:report.complete, passed:report.passed, rows:report.rows.length, error:report.error}));
}
