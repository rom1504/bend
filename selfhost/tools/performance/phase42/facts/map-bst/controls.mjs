// Root runs this bounded saved-JS falsifier; no compiler admission is claimed.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
const [inputArg, outArg] = process.argv.slice(2);
assert(inputArg && outArg, 'usage: controls.mjs ABLATION_DIR NEW_OUT');
const input = path.resolve(inputArg), out = path.resolve(outArg);
fs.mkdirSync(out, {recursive: false});
const identity = file => ({file: fs.realpathSync(file), sha256: createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const preparation = JSON.parse(fs.readFileSync(path.join(input, 'preparation.json')));
for (const role of ['baseline', 'candidate']) assert.equal(identity(preparation.modules[role].file).sha256, preparation.modules[role].sha256);
const report = {kind: 'phase42-map-comparison-falsifier', complete: false, pass: false,
  compilerAdmission: false, preparation: identity(path.join(input, 'preparation.json')), tool: identity(import.meta.filename), observations: []};
try {
 const baseline = await import(pathToFileURL(preparation.modules.baseline.file));
 const candidate = await import(pathToFileURL(preparation.modules.candidate.file));
 const compare = (m, a, b) => {try {return {value: m.phase42MapDebug.cmp(a, b)}} catch (error) {return {error: String(error)}}};
 for (const [a, b] of [['', ''], ['', 'a'], ['a', ''], ['app', 'apple'], ['same', 'same'],
   ['😀', '\ue000'], ['e\u0301', 'é'], ['a\ud800', 'b'], ['a\ud800', 'a'], ['\ud800', 'a'], ['a', '\ud800'], ['\ud800', '\udfff']]) {
   const left = compare(baseline, a, b), right = compare(candidate, a, b);
   assert.deepEqual(right, left, 'complete comparison including restored operands / errors');
   if (left.value) assert.deepEqual(left.value[0], [a, b]);
   report.observations.push({name: 'complete-Unicode-comparison', a, b, result: right});
 }
 assert(candidate.phase42MapDebug.entries().entries > 0, 'clean worker must actually enter');

 function observeMap(m, size, seed) {
   let map = m.default['Map.new'](null, null);
   map = m.default['p37.map.fill'](BigInt(size), 0, seed, map);
   map = m.default['p37.map.update'](BigInt(Math.floor((size + 2) / 3)), 0, seed, map);
   map = m.default['p37.map.remove'](BigInt(Math.floor((size + 3) / 4)), 0, map);
   let xs = m.phase42MapDebug.complete(m.default['Map.to_list'](null, null, map));
   const entries = [];
   while (xs.$ === 'Con') {
     const pair = m.phase42MapDebug.complete(xs.a[0]);
     assert(Array.isArray(pair) && pair.length === 2);
     entries.push([pair[0], pair[1]]);
     xs = m.phase42MapDebug.complete(xs.a[1]);
   }
   assert.equal(xs.$, 'Nil');
   return entries;
 }
 function expectedMap(size, seed) {
   const m = new Map();
   for (let i = 0; i < size; i++) m.set('key' + i, (seed + Math.imul(i, 17)) >>> 0);
   for (let i = 0; i < size; i += 3) m.set('key' + i, (seed ^ Math.imul(i, 31)) >>> 0);
   for (let i = 0; i < size; i += 4) m.delete('key' + i);
   return [...m].sort((a, b) => a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : 0);
 }
 for (const [size, seed] of [[0, 0], [1, 17], [7, 31], [32, 17], [128, 123]]) {
   const expected = expectedMap(size, seed), before = observeMap(baseline, size, seed), after = observeMap(candidate, size, seed);
   assert.deepEqual(before, expected, 'independent full ordered Map entries');
   assert.deepEqual(after, expected, 'candidate full ordered Map entries');
   report.observations.push({name: 'complete-map-content', size, seed, entries: after});
 }

 for (const [object, key] of [[String.prototype, 'codePointAt'], [String.prototype, 'slice'], [String, 'fromCodePoint']]) {
   const old = Object.getOwnPropertyDescriptor(object, key);
   const before = candidate.phase42MapDebug.entries().entries;
   let callbacks = 0;
   try {
     Object.defineProperty(object, key, {...old, value: function(...a) {++callbacks; return Reflect.apply(old.value, this, a)}});
     assert.equal(candidate.phase42MapDebug.guard(), false, key);
     assert.deepEqual(compare(candidate, 'same', 'same'), compare(baseline, 'same', 'same'));
     assert.equal(candidate.phase42MapDebug.entries().entries, before, 'host mutation means zero fast entries');
     assert(callbacks > 0);
     report.observations.push({name: 'host-hook-fallback', key, callbacks, entries: 0});
   } finally {Object.defineProperty(object, key, old)}
 }
 for (const name of preparation.dependencies) {
   const descriptor = Object.getOwnPropertyDescriptor(candidate.G[name], 'code');
   const before = candidate.phase42MapDebug.entries().entries;
   try {
     Object.defineProperty(candidate.G[name], 'code', {...descriptor, value: function(...a) {return Reflect.apply(descriptor.value, this, a)}});
     assert.equal(candidate.phase42MapDebug.guard(), false, name);
     assert.deepEqual(compare(candidate, 'same', 'same'), compare(baseline, 'same', 'same'));
     assert.equal(candidate.phase42MapDebug.entries().entries, before);
     report.observations.push({name: 'dependency-code-fallback', dependency: name, entries: 0});
   } finally {Object.defineProperty(candidate.G[name], 'code', descriptor)}
 }
 report.entries = candidate.phase42MapDebug.entries();
 report.complete = report.pass = true;
} catch (error) {
 report.error = String(error?.stack ?? error);
 process.exitCode = 1;
} finally {fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n', {flag: 'wx'})}
console.log(JSON.stringify(report));
