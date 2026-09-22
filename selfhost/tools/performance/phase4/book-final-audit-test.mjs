// Independent differential audit of the actual Bend-emitted component.
import fs from 'node:fs';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [apiFile, output, requireEquivalence] = process.argv.slice(2);
if (!output || fs.existsSync(output)) throw Error('Usage: book-final-audit-test.mjs COMPONENT.mjs NEW_REPORT.json');
const hash = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const identity = Object.fromEntries([import.meta.filename, apiFile].map(file => [file, hash(file)]));
const {default: api} = await import(pathToFileURL(apiFile));
const list = values => values.reduceRight((tail, head) => ({$: 'Con', a: [head, tail]}), {$: 'Nil', a: []});
const term = {$: 'KTerm', a: ['Absent', '', 0, 0, list([]), list([])]};
const def = (name, index, kind = 'Def') => ({$: 'KDef', a: [name, kind, index, 0, term, term, list([]), true, false]});
const filler = Array.from({length: 256}, (_, i) => def('filler-' + i, i));
const cases = [
  ['single-malformed-suffix', [...filler, def('z\ud800', 300)], []],
  ['distinct-malformed-common-prefix', [...filler, def('a\ud800x', 300), def('a\ud800y', 301)], []],
  ['identical-malformed-names', [...filler, def('a\ud800x', 300), def('a\ud800x', 301)], []],
  ['valid-non-bmp-common-prefix', [...filler, def('a🦋x', 300), def('a🦋y', 301)], []],
  ['malformed-prior-common-prefix', [...filler, def('a\ud800x', 300)], [def('a\ud800y', 301)]],
  ['empty-and-markers', [...filler, def('', 300), def('$final.seen', 301, '$final.seen'), def('$kernel.cache', 302, 'BookCache'), def('', 303)], [def('', 400), def('untouched', 401), def('untouched', 402)]],
];
for (const size of [0, 1, 63, 64, 255, 256, 257, 512]) {
  cases.push(['boundary-unique-' + size, filler.slice(0, size).concat(Array.from({length: Math.max(0, size - filler.length)}, (_, i) => def('extra-' + i, 1000 + i))), [def('untouched', 2000), def('untouched', 2001)]]);
  cases.push(['boundary-duplicates-' + size, Array.from({length: size}, (_, i) => def(i % 2 ? '' : 'same', i)), [def('', 2000), def('same', 2001), def('untouched', 2002), def('untouched', 2003)]]);
}
cases.push(['full-hash-collision', [...filler, def('costarring', 300), def('liquid', 301), def('costarring', 302)], [def('liquid', 400)]]);
const nameValidity = typeof api.book_final_name_valid === 'function' ? ['', 'a', '🦋', '\ud800', '\udfff', 'a\ud800x', '\ud7ff', '\ue000'].map(name => {
  const actual = api.book_final_name_valid(name), expected = name.isWellFormed();
  assert.equal(actual, expected); return {name, actual, expected};
}) : null;
function outcome(method, values, prior) {
  try { const result = api[method](list(values), list(prior)); return {status: 'ok', serialized: JSON.stringify(result)}; }
  catch (error) { return {status: 'error', diagnostic: String(error.message ?? error)}; }
}
const rows = cases.map(([label, values, prior]) => {
  const legacy = outcome('book_final_legacy', values, prior), fast = outcome('book_final_fast', values, prior);
  return {label, events: values.length, initial: prior.length, legacy, fast, equal: JSON.stringify(legacy) === JSON.stringify(fast)};
});
assert.ok(Object.entries(identity).every(([file, before]) => hash(file) === before));
fs.writeFileSync(output, JSON.stringify({kind: 'phase4-book-final-independent-H-audit', identity, node: process.version, rows, nameValidity, complete: true}, null, 2) + '\n');
console.log(JSON.stringify(rows.map(({label, legacy, fast, equal}) => ({label, legacy: legacy.status, fast: fast.status, equal}))));

if (requireEquivalence === '--require-equivalence') assert.ok(rows.every(row => row.equal), 'All legacy/fast observations must agree');
