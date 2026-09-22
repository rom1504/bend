import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {identity, verifyIdentity} from '../../private-compiler/common.mjs';

const [preparation, outputArgument] = process.argv.slice(2);
if (!outputArgument) throw Error('Usage: private-booleans-test.mjs PREPARED_REPORT NEW_DIRECTORY');
const prepared = JSON.parse(fs.readFileSync(preparation)), out = path.resolve(outputArgument);
assert.equal(prepared.complete, true); fs.mkdirSync(out, {recursive: false});
const inputs = [identity(preparation), identity(import.meta.filename), ...prepared.variants.map(v => identity(v.file))];
const apis = [];
for (const variant of prepared.variants) {
  assert.equal(identity(variant.file).sha256, variant.sha256);
  const optimized = variant.id !== 'private-control';
  const first = optimized ? 'privateBooleanAndFirst(a)' : 'call(get(G,"Bool.and"),[a])';
  const negate = optimized ? 'privateBooleanNot(a)' : 'call(get(G,"Bool.not"),[a])';
  const adapter = `
export function observe(mode,a,b){const trace=[];let value,error;
try{switch(mode){
case 'and':value=call(${first},[b]);break;
case 'not':value=${negate};break;
case 'partial':value=call(call(${first},[]),[b]);break;
case 'over':value=call(${first},[b,true]);break;
case 'late-error':value=call(${first},[(()=>{trace.push('second argument');throw Error('late argument');})()]);break;
case 'function':value=call(call(${first},[fn(1,args=>args[0])]),[b]);break;
default:throw Error('test mode');
}}catch(e){error={name:e.name,message:e.message};}
return {value,error,trace};}
`;
  const file = path.join(out, variant.id + '.mjs');
  fs.writeFileSync(file, fs.readFileSync(variant.file, 'utf8') + adapter);
  inputs.push(identity(file)); apis.push(await import(pathToFileURL(file)));
}
let assertions = 0;
const compare = (mode, a, b) => {
  const left = apis[0].observe(mode, a, b), right = apis[1].observe(mode, a, b);
  assert.deepEqual(right, left, mode + ': ' + String(a) + ', ' + String(b)); assertions++;
  return right;
};
for (const a of [true, false]) for (const b of [true, false, null, undefined, 0, 42, 'text'])
  for (const mode of ['and', 'partial', 'over', 'function']) compare(mode, a, b);
for (const a of [true, false, null, undefined, 0, 1, '', 'text', {}, [], {request: true}]) {
  compare('not', a);
  const result = compare('late-error', a);
  if (a?.request) assert.deepEqual(result.trace, []);
  else assert.deepEqual(result.trace, ['second argument']);
  for (const b of [true, false]) compare('and', a, b);
}
for (let i = 0; i < 200; i++) compare('and', (i & 1) === 0, (i & 2) === 0);
inputs.forEach(verifyIdentity);
const report = {kind: 'phase4-private-boolean-controls', complete: true, assertions, inputs,
  scope: 'Disposable test-only internal exports; public APIs unchanged. Exact Boolean behavior, partial/overapplication, eager argument errors, original raw fallbacks and repeat reuse.'};
fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify({complete: true, assertions}));
