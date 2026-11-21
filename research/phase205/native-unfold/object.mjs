import fs from 'node:fs';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [receipt, input, out] = process.argv.slice(2);
function verify(pin) {
  const bytes = fs.readFileSync(pin.file);
  if (bytes.length !== pin.bytes || crypto.createHash('sha256').update(bytes).digest('hex') !== pin.sha256)
    throw Error('Changed input ' + pin.file);
  return bytes;
}
const manifest = JSON.parse(fs.readFileSync(receipt));
verify(manifest.source);
verify(manifest.api);
if (!(manifest.checked && manifest.complete)) throw Error('Unchecked compiler');
const api = (await import(pathToFileURL(manifest.api.file))).default;
const binding = JSON.parse(fs.readFileSync('selfhost/build/phase197/shared-emission-plan01.json')).producer.bindingValue;
const prep = api.p88_cache_prepare(binding.base.file, verify(binding.base).toString(), verify(binding.carrier).toString(), binding.stamp);
const plan = api.p86_plan(prep.seed, input, fs.readFileSync(input, 'utf8'));
if (plan.$ !== 'P86PlanReady') throw Error(plan.error);
const object = api.x187_prepared(api.x198pw_plan(plan));
if (object.error !== '') throw Error(object.error);
const bytes = [];
let list = object.bytes;
while (list?.$ === 'Con') {
  if (!Number.isInteger(list.head) || list.head < 0 || list.head > 255 || bytes.length >= 2000000) throw Error('Object byte bound');
  bytes.push(list.head);
  list = list.tail;
}
if (list?.$ !== 'Nil' || bytes.length < 64) throw Error('Invalid object list');
fs.writeFileSync(out, Buffer.from(bytes), {flag:'wx'});
