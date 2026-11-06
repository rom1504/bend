// Literal independent error-order expectations; transport only, no compiler rules.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {pin,verify,items} from '../../phase147/tools/support.mjs';

const [receiptPath, manifestPath, out] = process.argv.slice(2);
const read = file => JSON.parse(fs.readFileSync(file));
const receipt = read(receiptPath), manifest = read(manifestPath);
assert(receipt.complete && receipt.checked && manifest.complete && manifest.parentSourceUnchanged);
assert.deepEqual(receipt.source,manifest.source);
assert.deepEqual(manifest.exports,['p169svo_controls','p169svo_rows']);
const inputs = [pin(import.meta.filename),pin(receiptPath),pin(manifestPath),
  pin(new URL('../../phase147/tools/support.mjs',import.meta.url)),receipt.api,receipt.source,...manifest.inputs];
inputs.forEach(verify); fs.mkdirSync(out,{recursive:false});
const report = {complete:false,passed:false,inputs,rows:[],
  scope:'Six pure finite error-precedence controls against literal messages; intentionally invalid IR is never executed.'};
const save = () => fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const body = 'direct terminal vector has wrong arity/type or undefined value';
const abi = 'public direct wrapper does not preserve original scalar ABI';
const projection = 'borrowed import: constructor/count contract';
const privateError = 'observer first final worker must be private';
const forward = 'unknown/cyclic direct call or argument/result mismatch: helper';
const prefix = 'adapter renderer original final IR: ';
const expected = [
  ['',body,abi,prefix+body,'empty'],
  ['',projection,projection,prefix+projection,'empty'],
  ['',projection,projection,prefix+projection,'empty'],
  ['','',abi,'adapter imports view verification: '+abi,'empty'],
  ['',privateError,'',prefix+privateError,'empty'],
  ['',forward,forward,prefix+forward,'empty'],
];
const names = ['order-early-view-ABI-later-original-body','order-later-projection-before-earlier-body',
  'order-later-projection-before-earlier-view-ABI','order-view-ABI-only',
  'order-private-input-before-view-reset','order-public-forward-callee-still-refused'];
try {
  const api = (await import(pathToFileURL(receipt.api.file))).default;
  const actual = items(api.p169svo_rows()).map(items);
  assert.equal(actual.length,expected.length);
  for (let i=0;i<expected.length;i++) {
    const row = {name:names[i],passed:false,actual:actual[i],expected:expected[i]};
    report.rows.push(row);save();assert.deepEqual(actual[i],expected[i]);row.passed=true;
  }
  report.bendControls = items(api.p169svo_controls());
  assert.deepEqual(report.bendControls,names.map(name=>name+':pass'));
  inputs.forEach(verify);report.complete=true;report.passed=true;
} catch(error) {report.error=String(error.stack??error);process.exitCode=1;}
finally {save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,rows:report.rows.length,error:report.error}));}
