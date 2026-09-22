// Small component-only guard overhead measurement; not compiler throughput.
import fs from 'node:fs';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [oldFile, newFile, output] = process.argv.slice(2);
if (!output || fs.existsSync(output)) throw Error('Usage: book-final-audit-time.mjs UNGUARDED GUARDED NEW_REPORT');
const hash = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const identity = Object.fromEntries([import.meta.filename, oldFile, newFile].map(file => [file, hash(file)]));
const old = (await import(pathToFileURL(oldFile))).default, guarded = (await import(pathToFileURL(newFile))).default;
const list = values => values.reduceRight((tail, head) => ({$: 'Con', a: [head, tail]}), {$: 'Nil', a: []});
const absent = {$: 'KTerm', a: ['Absent', '', 0, 0, list([]), list([])]};
const rows = [];
for (const size of [256, 1024]) {
  const book = list(Array.from({length: size}, (_, i) => ({$: 'KDef', a: ['definition-' + i, 'Def', i, 0, absent, absent, list([]), true, false]}))), done = list([]);
  const methods = {unguarded: old.book_final_fast, guarded: guarded.book_final_fast, legacy: guarded.book_final_legacy};
  const expected = JSON.stringify(methods.legacy(book, done));
  for (const method of Object.values(methods)) assert.equal(JSON.stringify(method(book, done)), expected);
  for (let round = 0; round < 3; round++) for (const name of round % 2 ? ['guarded', 'unguarded', 'legacy'] : ['legacy', 'unguarded', 'guarded']) {
    const start = performance.now(), result = methods[name](book, done), milliseconds = performance.now() - start;
    assert.equal(JSON.stringify(result), expected); rows.push({size, round, name, milliseconds});
  }
}
assert.ok(Object.entries(identity).every(([file, before]) => hash(file) === before));
fs.writeFileSync(output, JSON.stringify({kind: 'phase4-book-final-H-component-time', complete: true, identity, node: process.version, rows}, null, 2) + '\n');
console.log(JSON.stringify(rows));
