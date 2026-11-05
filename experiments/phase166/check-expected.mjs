// Existing checked expected-record builder against the independent literal oracle.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {pin,verify,root} from '../phase147/tools/support.mjs';
const [receiptFile,outArg] = process.argv.slice(2);
const receipt = JSON.parse(fs.readFileSync(receiptFile));
assert(receipt.complete && receipt.checked && receipt.exports.includes('p166l_expected_values'));
const oracleFile = path.join(root,'experiments/phase166/lookup-expected-values.json');
const oracle = JSON.parse(fs.readFileSync(oracleFile));
const out = path.resolve(outArg);
assert(out.startsWith(root+'/selfhost/build/phase166/') && !fs.existsSync(out));
fs.mkdirSync(out);
const inputs = [pin(import.meta.filename),pin(receiptFile),receipt.api,receipt.source,pin(oracleFile)];
inputs.forEach(verify);
const api = (await import(pathToFileURL(receipt.api.file))).default;
const rows = [];
for (const row of oracle.cases) {
  const actual = api.p166l_expected_values(row.i);
  const file = path.join(out,`values-${row.i}.json`);
  fs.writeFileSync(file,JSON.stringify(actual)+'\n',{flag:'wx'});
  assert.deepEqual(actual,row.value);
  rows.push({i:row.i,count:row.count,actual:pin(file),complete:true});
}
inputs.forEach(verify);
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({complete:true,inputs,rows,
  scope:'Complete expected-record values at three inputs; finite control, not theorem.'},null,2)+'\n');
