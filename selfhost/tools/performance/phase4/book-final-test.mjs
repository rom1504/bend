// Exact semantic and complexity checks for the checked book-final overlay.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';

const [apiArgument, outputArgument] = process.argv.slice(2);
if (!outputArgument) throw Error('Usage: book-final-test.mjs CHECKED_API.mjs NEW_REPORT.json');
const apiFile = fs.realpathSync(apiArgument), output = path.resolve(outputArgument);
assert.equal(fs.existsSync(output), false);
const sha = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const before = sha(apiFile);
const {default: api} = await import(pathToFileURL(apiFile));
for (const name of ['book_final_fast', 'book_final_legacy', 'driver_final', 'sp_canonical']) assert.equal(typeof api[name], 'function');
const list = values => values.reduceRight((tail, head) => ({$: 'Con', head, tail}), {$: 'Nil'});
const array = value => { const values = []; while (value.$ === 'Con') { values.push(value.head); value = value.tail; } assert.equal(value.$, 'Nil'); return values; };
const term = (tag = 'Absent', id = 0) => ({$: 'KTerm', tag, name: '', id, quant: 0, kids: list([]), removed: list([])});
const def = (name, id, kind = 'Def') => ({$: 'KDef', name, kind, arity: id, templates: 0, typ: term('Typ', id), value: term(id % 3 ? 'Lit' : 'Absent', id), ctors: list([]), native: false, unsafe: false});
const oracle = (book, done) => book.reduce((result, d) => [d, ...result.filter(previous => previous.name !== d.name)], done);
const report = {kind: 'phase4-book-final-exact', complete: false, api: {file: apiFile, sha256: before}, node: {version: process.version, args: process.execArgv}, cases: [], timings: []};
function check(label, values, prior = []) {
  const book = list(values), done = list(prior);
  const expected = oracle(values, prior);
  const original = api.book_final_legacy(book, done);
  assert.deepEqual(array(original), expected, label + ': original/oracle');
  for (const method of ['book_final_fast', 'driver_final', 'sp_canonical']) assert.deepEqual(api[method](book, done), original, label + ': ' + method);
  report.cases.push({label, events: values.length, initial: prior.length, final: expected.length, passed: true});
}
let state = 0x77ac4011;
const next = () => { state = (Math.imul(state, 1664525) + 1013904223) >>> 0; return state; };
const kinds = ['Def', 'ADT', 'Absent', 'BookCache', 'IndexLeaf', '$final.seen'];
for (const size of [0, 1, 2, 16, 63, 64, 65, 128, 255, 256, 257, 512]) {
  check('unique-' + size, Array.from({length: size}, (_, i) => def('name-' + i, i)));
  check('duplicate-' + size, Array.from({length: size}, (_, i) => def('same', i)), [def('same', 900), def('untouched', 901), def('untouched', 902)]);
}
const names = ['', '$kernel.cache', '$kernel.max-id', '$final.seen', 'é', '𐀀', '🦋', 'a', 'aa', 'a\0b', 'z'];
for (let sample = 0; sample < 80; sample++) {
  const values = Array.from({length: (sample % 2 ? 240 : 60) + next() % 110}, (_, i) => def(names[next() % names.length], i, kinds[next() % kinds.length]));
  const prior = Array.from({length: next() % 35}, (_, i) => def(names[next() % names.length], 1000 + i, kinds[next() % kinds.length]));
  check('random-' + sample, values, prior);
}
// A verified full 32-bit FNV collision exercises exact-name buckets.
const hash = name => { let h = 2166136261; for (const char of name) h = Math.imul(h ^ char.codePointAt(0), 16777619) >>> 0; return h; };
const collision = ['costarring', 'liquid', hash('costarring')];
assert.equal(hash(collision[1]), collision[2]); report.collision = collision;
check('full-hash-collision', Array.from({length: 340}, (_, i) => def(i % 3 ? collision[i % 2] : 'extra-' + i, i)), [def(collision[0], 900), def(collision[1], 901)]);
for (const size of [64, 256, 1024, 2048]) {
  const values = Array.from({length: size}, (_, i) => def('d' + i, i));
  const book = list(values), done = list([]);
  let expected;
  for (let repetition = 0; repetition < 5; repetition++) {
    for (const name of repetition % 2 ? ['book_final_fast', 'book_final_legacy'] : ['book_final_legacy', 'book_final_fast']) {
      const begin = performance.now(), result = api[name](book, done), milliseconds = performance.now() - begin;
      const serialized = JSON.stringify(array(result));
      expected ??= serialized; assert.equal(serialized, expected);
      report.timings.push({size, repetition, variant: name, milliseconds, checksum: crypto.createHash('sha256').update(serialized).digest('hex')});
    }
  }
}
assert.equal(sha(apiFile), before);
report.complete = true; fs.writeFileSync(output, JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify({complete: true, cases: report.cases.length, collision, output}));
