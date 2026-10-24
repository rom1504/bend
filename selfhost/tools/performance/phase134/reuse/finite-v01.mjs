// Host transport only: all semantic/refusal predicates execute in checked Bend.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';

const [apiArg, outArg, groupsArg] = process.argv.slice(2);
const root = path.resolve(import.meta.dirname, '../../../../..');
const out = path.resolve(outArg);
assert(!fs.existsSync(out) && out.startsWith(root + '/selfhost/build/phase134/'));
const pin = file => {
  file = path.resolve(file); const data = fs.readFileSync(file);
  return {file, bytes: data.length, sha256: crypto.createHash('sha256').update(data).digest('hex')};
};
const verify = item => assert.deepEqual(pin(item.file), item);
const receipt = JSON.parse(fs.readFileSync(apiArg));
assert(receipt.complete && receipt.checked);
const sources = receipt.command.filter(value => value.endsWith('.bend'));
assert.equal(sources.length, 1);
const manifestFile = path.join(path.dirname(sources[0]), 'manifest.json');
const manifest = JSON.parse(fs.readFileSync(manifestFile));
assert(manifest.complete && !manifest.checked && !manifest.targetsRun);
assert.deepEqual(manifest.source, pin(sources[0]));
assert(receipt.inputs.some(item => JSON.stringify(item) === JSON.stringify(manifest.source)));
const inputs = [pin(import.meta.filename), pin(apiArg), receipt.api, ...receipt.inputs,
  pin(manifestFile), ...manifest.inputs, pin(process.execPath)];
inputs.forEach(verify);
const groups = JSON.parse(groupsArg);
for (const name of Object.keys(groups)) assert(receipt.exports.includes(name));
fs.mkdirSync(out); fs.copyFileSync(import.meta.filename, path.join(out, 'method.mjs'));
const report = {complete: false, inputs, source: manifest.source, sourceManifest: pin(manifestFile),
  groups: [], scope: 'Checked Bend finite predicates; fabricated IR is data only, with no native execution or qualification.'};
const save = () => fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
try {
  const api = (await import(pathToFileURL(receipt.api.file))).default;
  for (const [name, expectedCount] of Object.entries(groups)) {
    assert.equal(typeof api[name], 'function');
    const row = {name, expectedCount, rows: []}; report.groups.push(row); save();
    let xs = api[name]();
    while (xs?.$ === 'Con') {
      row.rows.push(xs.head); assert(row.rows.length <= expectedCount); xs = xs.tail;
    }
    assert.equal(xs?.$, 'Nil'); assert.equal(row.rows.length, expectedCount);
    assert(row.rows.every(value => typeof value === 'string' &&
      ((name === 'p118z_controls' || name === 'p134ec_controls' || name === 'p134v_controls') ? value.startsWith('PASS ') : value.endsWith(':pass'))));
    row.complete = true; save();
  }
  inputs.forEach(verify); report.complete = true;
} catch (error) {
  report.error = String(error); process.exitCode = 1;
} finally {
  save(); console.log(JSON.stringify({complete: report.complete, groups: report.groups.map(row => ({name: row.name, count: row.rows.length, complete: row.complete})), error: report.error}));
}
