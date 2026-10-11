// Root must execute this one process under its CPU3 resource guard.
// The appended exports expose existing checked closures; no generated function
// or runtime byte is edited, and the original checked API stays untouched.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';
const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../../../../../..');
const [apiArg, outArg] = process.argv.slice(2);
assert(apiArg && outArg, 'usage: node run-image-boundaries.mjs CHECKED_API FRESH_PHASE69_OUTPUT');
const apiPath = fs.realpathSync(apiArg), out = path.resolve(outArg);
const raw = path.join(root, 'selfhost/build/phase69');
assert(out.startsWith(raw + path.sep) && !fs.existsSync(out), 'fresh Phase69 output required');
fs.mkdirSync(out, {recursive: true});
const sha = bytes => createHash('sha256').update(bytes).digest('hex');
const pin = file => {
  const bytes = fs.readFileSync(file);
  return {file: path.resolve(file), sha256: sha(bytes), bytes: bytes.length};
};
const original = fs.readFileSync(apiPath);
const text = original.toString('utf8');
assert.equal(Buffer.from(text).compare(original), 0, 'UTF-8 roundtrip');
for (const fn of ['ns_node', 'missing']) {
  const escaped = '\\$' + fn + '\\$';
  assert.equal([...text.matchAll(new RegExp('^function ' + escaped + '\\(', 'gm'))].length, 1, 'exact original closure ' + fn);
}
assert(!text.includes('phase69StaticQueries'), 'already extended API refused');
const suffix = '\n// Diagnostic query exports only; all preceding checked API bytes stay exact.\n' +
  'export const phase69StaticQueries = {\n' +
  '  ns_node: run_lib((a0, a1) => { const r = (run_loop($ns_node$((a0), (a1)))); (a0); (a1); return r; }, 2),\n' +
  '  missing: run_lib(() => { const r = (run_loop($missing$()));  return r; }, 0),\n' +
  '};\n';
const derived = path.join(out, 'query-api.mjs');
fs.writeFileSync(derived, Buffer.concat([original, Buffer.from(suffix)]), {flag: 'wx'});
assert.equal(fs.readFileSync(derived).subarray(0, original.length).compare(original), 0);
assert.equal(fs.readFileSync(derived).subarray(original.length).toString(), suffix);
const helper = path.join(here, 'image-boundaries.mjs');
const report = {kind: 'phase69-static-image-boundary-controller', complete: false, pass: false,
  scope: 'Diagnostic append-only exports of checked closures; pure boundary queries, no C/native or production changes.',
  inputs: [pin(apiPath), pin(helper), pin(fileURLToPath(import.meta.url))],
  derivation: {input: pin(apiPath), output: pin(derived), appendOffset: original.length,
    exactAppend: suffix, appendSha256: sha(Buffer.from(suffix)), originalPrefixByteIdentical: true}};
const reportFile = path.join(out, 'report.json');
const save = () => fs.writeFileSync(reportFile, JSON.stringify(report, null, 2) + '\n');
save();
try {
  const {phase69StaticQueries} = await import(pathToFileURL(derived));
  const {runStaticImageBoundaries} = await import(pathToFileURL(helper));
  report.result = runStaticImageBoundaries(phase69StaticQueries);
  assert.equal(report.result.rows.length, 7);
  assert.equal(report.result.pass, true);
  assert.equal(fs.readFileSync(apiPath).compare(original), 0, 'checked API changed during query');
  report.originalPreserved = true;
  report.complete = true;
  report.pass = true;
  save();
  console.log(JSON.stringify({report: reportFile, passed: report.result.rows.length}));
} catch (error) {
  report.error = {name: error.name, message: error.message, stack: error.stack};
  report.complete = true;
  report.originalPreserved = fs.readFileSync(apiPath).compare(original) === 0;
  save();
  throw error;
}
