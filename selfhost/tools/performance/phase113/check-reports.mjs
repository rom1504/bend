// Execute finite Bend classification reports through a checked, pinned API.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [apiArg, outArg, ...specs] = process.argv.slice(2);
if (!apiArg || !outArg || !specs.length) throw Error('Usage: check-reports.mjs API FRESH_OUT EXPORT=COUNT ...');
const root = path.resolve(import.meta.dirname, '../../../..');
const apiFile = path.resolve(apiArg), out = path.resolve(outArg);
if (!out.startsWith(root + '/selfhost/build/phase113/') || fs.existsSync(out)) throw Error('Fresh Phase113 output required');
const pin = file => {
  file = path.resolve(file);
  const bytes = fs.readFileSync(file);
  return {file, bytes: bytes.length, sha256: crypto.createHash('sha256').update(bytes).digest('hex')};
};
const verify = row => {
  const actual = pin(row.file);
  if (actual.bytes !== row.bytes || actual.sha256 !== row.sha256) throw Error('Changed input: ' + row.file);
};
const receiptFile = path.join(path.dirname(apiFile), 'report.json');
const receipt = JSON.parse(fs.readFileSync(receiptFile));
const requests = specs.map(spec => {
  const [name, count] = spec.split('=');
  if (!/^[a-z0-9_]+$/.test(name) || !/^[1-9][0-9]*$/.test(count)) throw Error('Bad report specification');
  return {name, count: Number(count)};
});
if (!receipt.complete || !receipt.checked || receipt.api.file !== apiFile ||
    !requests.every(x => receipt.exports.includes(x.name))) throw Error('Complete checked API required');
const inputs = [pin(import.meta.filename), pin(receiptFile), pin(process.execPath), receipt.api, ...receipt.inputs];
inputs.forEach(verify);
fs.mkdirSync(out);
fs.copyFileSync(import.meta.filename, path.join(out, 'method.mjs'));
const report = {kind: 'phase113-finite-bend-control-reports', complete: false, inputs, reports: [],
  scope: 'Finite reflected classification controls; not a formal proof or native execution qualification.'};
try {
  const api = (await import(pathToFileURL(apiFile))).default;
  for (const {name, count} of requests) {
    const value = api[name]();
    let rows;
    if (typeof value === 'string') rows = value.trimEnd().split('\n');
    else {
      rows = [];
      let cursor = value;
      while (cursor?.$ === 'Con') { rows.push(cursor.head); cursor = cursor.tail; }
      if (cursor?.$ !== 'Nil') throw Error('Malformed report list');
    }
    const pass = rows.length === count && rows.every(x => typeof x === 'string' &&
      (/^PASS .+/.test(x) || /^.+ PASS$/.test(x)) && !x.includes('FAIL'));
    report.reports.push({name, expectedCount: count, rows, pass});
    if (!pass) throw Error('Finite report failed: ' + name);
  }
  inputs.forEach(verify);
  report.complete = true;
} catch (error) {
  report.error = String(error);
  process.exitCode = 1;
} finally {
  fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
  console.log(JSON.stringify({complete: report.complete, reports: report.reports.map(x => ({name: x.name, count: x.rows.length, pass: x.pass})), error: report.error}));
}
