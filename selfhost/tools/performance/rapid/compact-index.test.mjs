import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';
import {performance} from 'node:perf_hooks';
import {transformCompactIndex} from './compact-index.mjs';

const selfhost = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../..');
const input = path.resolve(process.argv[2] ?? path.join(selfhost, 'dist/phase1/selfhost-api.mjs'));
const output = path.join(selfhost, 'build/rapid/index/compact-index-test-api.mjs');
fs.mkdirSync(path.dirname(output), {recursive: true});
fs.writeFileSync(output, transformCompactIndex(fs.readFileSync(input, 'utf8')).source);
const control = await import(pathToFileURL(input));
const candidate = await import(pathToFileURL(output));

function suite(api) {
  const f = api.default;
  const absent = f.atom('Absent');
  const make = (name, value) => api.ctor('KDef', [name, 'RapidTest', value, 0,
    absent, absent, api.list([]), true, false]);
  const names = ['', '__proto__', 'constructor', 'toString', 'α', '🦀', 'a\0b',
    ...Array.from({length: 64}, (_, i) => `module/definition_${i}`)];
  const defs = names.map((name, i) => make(name, i));
  const book = api.list([...defs, make(names[1], 999)]);
  const invalid = f.book_cached(api.list([make('\ud800', 0)]), 0);
  assert.throws(() => f.lookup(invalid, '\ud800'), /Unicode scalar value/);
  const cache = f.book_cached(book, 1234);
  const head = cache.a[0];
  assert.equal(f.dk(head), 'BookCache');
  assert.equal(f.da(head), 1234);
  assert.equal(cache.a[1], book, 'declaration list identity is preserved');
  for (const d of defs) assert.equal(f.lookup(cache, f.dn(d)), d, 'first duplicate wins');
  assert.equal(f.dk(f.lookup(cache, 'does/not/exist')), 'Absent');
  assert.equal(f.dk(f.index_build(api.list([]))), 'Absent');
  assert.equal(f.dk(f.lookup(f.book_cached(api.list([]), 0), 'x')), 'Absent');
  assert.deepEqual(f.book_context(cache), cache, 'context wrapping remains idempotent');

  const old = cache;
  let current = cache;
  const snapshots = [];
  for (let i = 0; i < 20; i++) {
    const replacement = make(names[i], i + 1000);
    snapshots.push({book: current, name: names[i], value: f.lookup(current, names[i])});
    current = f.book_put(current, replacement);
    assert.equal(f.lookup(current, names[i]), replacement);
    assert.equal(f.da(current.a[0]), 1234, 'bound survives updates');
  }
  for (const {book, name, value} of snapshots) assert.equal(f.lookup(book, name), value);
  for (const d of defs) assert.equal(f.lookup(old, f.dn(d)), d, 'old cache stays immutable');

  function declarations(xs) {
    const result = [];
    while (xs.$ === 'Con') {
      if (f.dk(xs.a[0]) !== 'BookCache') result.push([f.dn(xs.a[0]), f.da(xs.a[0])]);
      xs = xs.a[1];
    }
    assert.equal(xs.$, 'Nil');return result;
  }
  const uncached = f.book_put(book, make(names[1], 42));
  assert.equal(f.da(f.lookup(uncached, names[1])), 42);
  assert.equal(declarations(uncached).filter(([name]) => name === names[1]).length, 1);

  // Exercise native validator's direct root-index ABI, including a real FNV-1a
  // collision. Internal cache node representation is intentionally not compared.
  const a = make('costarring', 1), b = make('liquid', 2), hash = f.index_hash('costarring', 2166136261);
  assert.equal(f.index_hash('liquid', 2166136261), hash);
  const root0 = f.missing();
  const root1 = f.index_set(root0, a, hash, 32);
  const root2 = f.index_set(root1, b, hash, 32);
  assert.equal(f.index_find(root2, 'costarring', hash, 32), a);
  assert.equal(f.index_find(root2, 'liquid', hash, 32), b);
  assert.equal(f.dk(f.index_find(root1, 'liquid', hash, 32)), 'Absent');
  assert.equal(f.dk(f.index_find(root2, 'costarring', hash + 1, 32)), 'Absent');
  assert.deepEqual(f.index_find(structuredClone(root2), 'costarring', hash, 32), a);
  assert.deepEqual(f.lookup(structuredClone(current), names[0]), f.lookup(current, names[0]));
  assert.equal(f.nv_unique(api.list(['id/a', 'id/b']), api.list([])), '');
  assert.equal(f.nv_unique(api.list(['id/a', 'id/b', 'id/a']), api.list([])),
    'native identifier collision: id/a');
  return {declarations: declarations(current), uncached: declarations(uncached),
    lookups: names.map(name => [name, f.da(f.lookup(current, name))])};
}

assert.deepEqual(suite(candidate), suite(control));
assert.throws(() => candidate.default.index_set(candidate.default.missing(),
  candidate.default.missing(), 0, 0), /whole 32-bit roots/);
assert.throws(() => transformCompactIndex(fs.readFileSync(output, 'utf8')), /already installed/);
console.log(JSON.stringify({passed: true, control: input, candidate: output,
  coverage: ['duplicates', 'special/unicode names', 'missing', 'empty', 'declaration order',
    'bound retention', 'persistent versions', 'root hash collision', 'native identifier validation']}));

// Opt-in, short component probe. The caller chooses CPU affinity and repetition;
// successful semantic tests above are mandatory before any timings are printed.
if (process.env.RAPID_INDEX_BENCH === '1') {
  const size = Number(process.env.RAPID_INDEX_SIZE ?? 1024);
  const probes = Number(process.env.RAPID_INDEX_PROBES ?? 2048);
  for (const [label, api] of [['control', control], ['map', candidate]]) {
    const f = api.default, absent = f.atom('Absent');
    const make = (name, i) => api.ctor('KDef', [name, 'RapidBench', i, 0,
      absent, absent, api.list([]), true, false]);
    const defs = Array.from({length: size}, (_, i) => make(`bench/name_${i}`, i));
    const inputBook = api.list(defs);
    const start = performance.now();
    let book = f.book_cached(inputBook, size);
    const built = performance.now();
    let sum = 0;
    for (let i = 0; i < probes; i++) sum += f.da(f.lookup(book, `bench/name_${i % size}`));
    const looked = performance.now();
    for (let i = 0; i < 64; i++) book = f.book_put(book, make(`bench/name_${i % size}`, i + size));
    const updated = performance.now();
    console.log(JSON.stringify({benchmark: 'exact-name-index', label, size, probes,
      buildMs: built - start, lookupMs: looked - built, update64Ms: updated - looked, checksum: sum}));
  }
}
