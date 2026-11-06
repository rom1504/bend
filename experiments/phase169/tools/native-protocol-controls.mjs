// Finite protocol observations from the independently checked Bend API.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {pin, verify, items} from '../../phase147/tools/support.mjs';

const [receipt, out] = process.argv.slice(2);
assert(receipt && out);
const acquired = JSON.parse(fs.readFileSync(receipt));
assert(acquired.complete && acquired.checked);
verify(acquired.api);
fs.mkdirSync(out, {recursive:false});
const report = {complete:false, inputs:[pin(import.meta.filename), pin(receipt), acquired.api], rows:[]};
try {
  const api = (await import(pathToFileURL(acquired.api.file))).default;
  report.rows = items(api.p169np_controls());
  assert.equal(report.rows.length, 8);
  assert(report.rows.every(row => row.endsWith(':pass')));
  for (const input of report.inputs) verify(input);
  report.complete = true;
} catch (error) {
  report.error = String(error.stack ?? error);
  process.exitCode = 1;
} finally {
  fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
  console.log(JSON.stringify({complete:report.complete, count:report.rows.length, error:report.error}));
}
