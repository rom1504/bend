// Transport for explicit checked Bend control groups; no compiler semantics.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {pin, verify, items} from '../../phase147/tools/support.mjs';

const [receipt, out, ...groups] = process.argv.slice(2);
assert(receipt && out && groups.length);
const selected = groups.map(group => {
  const match = /^([A-Za-z0-9_]+):([1-9][0-9]*)$/.exec(group);
  assert(match, 'Expected EXPORT:COUNT');
  return [match[1], Number(match[2])];
});
assert.equal(new Set(selected.map(([name]) => name)).size, selected.length);
const acquired = JSON.parse(fs.readFileSync(receipt));
assert(acquired.complete && acquired.checked);
const inputs = [pin(import.meta.filename), pin(receipt), acquired.api,
  pin(new URL('../../phase147/tools/support.mjs', import.meta.url))];
inputs.forEach(verify);
fs.mkdirSync(out, {recursive:false});
const report = {complete:false, inputs, selected, groups:[],
  scope:'Finite checked Bend observations; not a proof or runtime qualification.'};
try {
  const api = (await import(pathToFileURL(acquired.api.file))).default;
  for (const [name, count] of selected) {
    const rows = items(api[name]());
    report.groups.push({name, count, rows});
    assert.equal(rows.length, count);
    assert(rows.every(row => typeof row === 'string' && row.endsWith(':pass')),
      JSON.stringify({name, rows}));
  }
  inputs.forEach(verify);
  report.complete = true;
} catch(error) {
  report.error = String(error.stack ?? error);
  process.exitCode = 1;
} finally {
  fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2)+'\n');
  console.log(JSON.stringify({complete:report.complete,
    count:report.groups.reduce((sum, group) => sum + group.rows.length, 0),
    error:report.error}));
}
