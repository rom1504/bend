#!/usr/bin/env node
// Executes only when root runs: node dispatch-controls.mjs PREPARATION_RECEIPT NEW_OUT
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { pathToFileURL } from 'node:url';

const [receiptArg, outArg] = process.argv.slice(2);
assert.ok(receiptArg && outArg && process.argv.length === 4);
const out = path.resolve(outArg); fs.mkdirSync(out);
const inputs = [], observations = [];
const report = { kind: 'phase51-dispatch-controls', complete: false, passed: false, inputs, observations };
function pin(file, expected) {
  file = fs.realpathSync(file); const data = fs.readFileSync(file);
  const row = { file, sha256: createHash('sha256').update(data).digest('hex'), bytes: data.length };
  if (expected) assert.equal(row.sha256, expected);
  inputs.push(row); return row;
}
try {
  pin(import.meta.filename); pin(process.execPath);
  const receipt = JSON.parse(fs.readFileSync(pin(receiptArg).file, 'utf8'));
  assert.equal(receipt.kind, 'phase51-dispatch-prototype'); assert.equal(receipt.complete, true);
  for (const item of receipt.inputs) pin(item.file, item.sha256);
  for (const item of Object.values(receipt.outputs)) pin(item.file, item.sha256);
  const modules = [];
  for (const role of ['baseline', 'candidate']) {
    const clean = fs.readFileSync(receipt.outputs[role + '.mjs'].file, 'utf8');
    const diagnostic = fs.readFileSync(receipt.outputs[role + '-controls.mjs'].file, 'utf8');
    assert.equal(diagnostic, clean + receipt.diagnosticSuffix);
    modules.push(await import(pathToFileURL(receipt.outputs[role + '-controls.mjs'].file).href));
  }
  const original = fs.readFileSync(receipt.outputs['baseline.mjs'].file, 'utf8');
  assert.equal(original.split(receipt.originalApply).length, 2);
  assert.equal(original.replace(receipt.originalApply, receipt.replacement),
    fs.readFileSync(receipt.outputs['candidate.mjs'].file, 'utf8'));
  async function test(name, run) {
    const results = [];
    for (const mod of modules) {
      const events = []; const value = await run(mod.$dispatchProbe, events, mod);
      results.push({ value, events });
    }
    assert.deepEqual(results[1], results[0], name);
    observations.push({ name, passed: true, baseline: results[0], candidate: results[1] });
  }
  const trace = (value, label, events) => new Proxy(value, {
    get(target, key, receiver) { events.push(label + '.' + String(key)); return Reflect.get(target, key, receiver); },
  });
  await test('null-does-not-read-arguments', (a) => {
    assert.equal(a.apply(null, new Proxy([], { get() { throw Error('unexpected args read'); } })), null); return true;
  });
  for (const owned of [false, true]) for (const count of [0, 1, 2, 3]) {
    await test(`ordinary-${owned}-${count}`, (a, e) => {
      const code = trace(function(xs) { e.push('body'); return a.fn(1, ys => xs[0] + ys[0]); }, 'code', e);
      const f = trace(a.fn(1, code), 'f', e), args = trace(Array.from({ length: count }, (_, i) => i + 1), 'args', e);
      const value = a.apply(f, args, owned);
      if (!count) { assert.equal(value.arity, 1); assert.deepEqual(value.bound, []); return 'partial'; }
      if (count === 1) { assert.equal(a.call(value, [7]), 8); return 'function'; }
      if (count === 2) { assert.equal(a.force(value), 3); return 3; }
      assert.throws(() => a.force(value), /non-function/); return 'overapplied-nonfunction';
    });
  }
  await test('public-copy-and-owned-vector', (a) => {
    const publicArgs = [1], owned = [2];
    const f = a.fn(1, xs => { xs.push(9); return xs; });
    const result = a.call(f, publicArgs); assert.deepEqual(publicArgs, [1]); assert.deepEqual(result, [1, 9]);
    assert.equal(a.callOwned(f, owned), owned); assert.deepEqual(owned, [2, 9]); return true;
  });
  await test('partial-bound-isolation', (a) => {
    const args = [2], f = a.fn(2, xs => xs[0] + xs[1]);
    const partial = a.call(f, args); args[0] = 99;
    assert.equal(a.call(partial, [3]), 5); assert.deepEqual(partial.bound, [2]); return true;
  });
  await test('changing-bound-receiver', (a, e) => {
    const f = a.fn(2, xs => xs[0] + xs[1]); let reads = 0;
    Object.defineProperty(f, 'bound', { get() { e.push('bound'); return ++reads === 1 ? [9] : [1]; } });
    assert.equal(a.call(f, [3]), 4); assert.equal(reads, 2); return true;
  });
  await test('changing-code-and-call-before-env', (a, e) => {
    const f = a.fn(1, () => 0); let reads = 0;
    const code = function(xs) { e.push('body'); assert.equal(this.offset, 7); return xs[0] + this.offset; };
    Object.defineProperty(code, 'call', { get() { e.push('call'); return Function.prototype.call; } });
    Object.defineProperty(f, 'code', { get() { e.push('code'); return ++reads === 1 ? (() => 0) : code; } });
    Object.defineProperty(f, 'env', { get() { e.push('env'); return { offset: 7 }; } });
    assert.equal(a.call(f, [3]), 10); assert.deepEqual(e, ['code', 'code', 'call', 'env', 'body']); return true;
  });
  await test('overflow-arity-mutation-and-force-before-tail-slice', (a, e) => {
    let arity = 1;
    const next = a.fn(0, () => { e.push('force'); arity = 3; return a.fn(0, () => 77); });
    const f = a.fn(1, xs => { assert.deepEqual(xs, [10]); e.push('body'); arity = 2; return a.jump(next, []); });
    Object.defineProperty(f, 'arity', { get() { e.push('arity:' + arity); return arity; } });
    assert.equal(a.call(f, [10, 20, 30]), 77);
    assert.deepEqual(e, ['arity:1', 'arity:1', 'arity:1', 'body', 'arity:2', 'force', 'arity:3']); return true;
  });
  await test('overflow-body-throw', (a, e) => {
    const sentinel = {}; const f = a.fn(1, () => { e.push('throw'); throw sentinel; });
    assert.throws(() => a.call(f, [1, 2]), error => error === sentinel); return true;
  });
  await test('io-empty-preserves-identity', (a, e) => {
    const io = { get io() { e.push('io'); return true; } };
    assert.equal(a.apply(io, trace([], 'args', e)), io); assert.deepEqual(e, ['io', 'args.length']); return true;
  });
  await test('io-changing-marker-and-pure-value', (a, e) => {
    let reads = 0; const io = { get io() { e.push('io'); return ++reads > 1; }, pureValue: 3 };
    const partial = a.apply(io, [null]); io.pureValue = 7;
    assert.equal(a.call(partial, [a.fn(1, xs => xs[0] + 1)]), 8); assert.deepEqual(e, ['io', 'io']); return true;
  });
  await test('io-request-action-and-continuation', (a) => {
    const io = { io: true }, k = a.fn(1, xs => xs[0]); const r = a.apply(io, [null, k]);
    assert.equal(r.request, true); assert.equal(r.action, io); assert.equal(r.k, k); return true;
  });
  await test('type-repeated-name-and-iterators', (a, e) => {
    let reads = 0;
    const f = { get typeName() { e.push('name'); return ++reads === 1 ? 'A' : 'B'; },
      get typeArgs() { e.push('typeArgs'); return { *[Symbol.iterator]() { e.push('left'); yield 1; } }; } };
    const args = { *[Symbol.iterator]() { e.push('right'); yield 2; } };
    assert.deepEqual(a.apply(f, args), { typeName: 'B', typeArgs: [1, 2] });
    assert.deepEqual(e, ['name', 'name', 'typeArgs', 'left', 'right']); return true;
  });
  await test('nonfunction-empty-and-coercion-error', (a, e) => {
    const f = { [Symbol.toPrimitive]() { e.push('coerce'); return 'missing'; } };
    assert.equal(a.apply(f, []), f); assert.throws(() => a.apply(f, [1]), /non-function missing/);
    assert.deepEqual(e, ['coerce']); return true;
  });
  await test('error-hook-reentry-and-identity', (a, e) => {
    const original = globalThis.Error, sentinel = {};
    try {
      globalThis.Error = function(message) { e.push(message); assert.equal(a.call(a.fn(1, xs => xs[0] + 1), [4]), 5); return sentinel; };
      assert.throws(() => a.apply(7, [1]), error => error === sentinel);
    } finally { globalThis.Error = original; }
    assert.deepEqual(e, ['attempt to call non-function 7']); return true;
  });
  await test('sparse-array-species-and-original-isolation', (a, e) => {
    class Vector extends Array { static get [Symbol.species]() { e.push('species'); return Array; } }
    const args = new Vector(2); args[1] = 9;
    const f = a.fn(2, xs => { assert.equal(0 in xs, false); assert.equal(xs[1], 9); xs[1] = 20; return 3; });
    assert.equal(a.call(f, args), 3); assert.equal(args[1], 9); assert.deepEqual(e, ['species']); return true;
  });
  await test('custom-bound-concat-receiver', (a, e) => {
    const bound = { length: 1, concat(args) { assert.equal(this, bound); e.push('concat'); return [4, args[0]]; } };
    assert.equal(a.call(a.fn(2, xs => xs[0] + xs[1], null, bound), [3]), 7); return true;
  });
  await test('delayed-fields-order-and-throw', (a, e) => {
    const sentinel = {}; const x = a.build('Tuple', [() => { e.push('left'); return 3; }, () => { e.push('right'); throw sentinel; }]);
    assert.throws(() => a.force(x), error => error === sentinel); assert.deepEqual(e, ['left', 'right']); return true;
  });
  await test('tail-bounces-remain-bounded', (a) => {
    let f; f = a.fn(1, xs => xs[0] ? a.jump(f, [xs[0] - 1]) : 42);
    assert.equal(a.call(f, [20000]), 42); return true;
  });
  await test('exact-entry-raw-call-overapply-and-reentry', (a, e) => {
    let depth = 0, f;
    const code = a.exactCode((xs, entered) => {
      e.push(entered); if (!depth) { depth++; assert.equal(a.call(f, [3]), 4); depth--; }
      return xs[0] + 1;
    });
    f = a.fn(1, code); assert.equal(a.call(f, [3]), 4); assert.deepEqual(e, [true, true]);
    e.length = 0; depth = 1; assert.equal(code.call(null, [3]), 4); assert.deepEqual(e, [false]);
    e.length = 0; assert.throws(() => a.call(f, [3, 9]), /non-function/); assert.deepEqual(e, [false]);
    e.length = 0; assert.equal(a.call(f, [3]), 4); assert.deepEqual(e, [true]); return true;
  });
  const expected = {
    f6e11b080d14cb9ba2dd32a5e758909be521eac13adf21c71028cb7b5bffc41e: 'a-bb-ccc 8 1877 42 lo hello 3',
    b21b0bbd4e40873907038838d89c559ef73d6c7e599f87e63e94b9f5be77f8b7: 81111,
    fe5c1aef40bfeb890960b3e14a1ae9b35ecf11a4881270141c94d61c80e1b345: 11111,
  }[receipt.outputs['baseline.mjs'].sha256];
  assert.notEqual(expected, undefined, 'this control version requires a pinned Morning/Evening/MapSet module');
  await test('complete-public-program-after-controls', (_a, _e, mod) => {
    for (let i = 0; i < 8; i++) assert.deepEqual(mod.default['main.out'](), expected);
    return expected;
  });
  report.complete = report.passed = true;
} catch (error) { report.error = error.stack ?? String(error); process.exitCode = 1; }
finally {
  try { for (const input of inputs) assert.equal(createHash('sha256').update(fs.readFileSync(input.file)).digest('hex'), input.sha256); report.inputsUnchanged = true; }
  catch (error) { report.complete = report.passed = false; report.identityError = error.stack ?? String(error); process.exitCode = 1; }
  fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n', { flag: 'wx' });
  process.stdout.write(JSON.stringify({ complete: report.complete, passed: report.passed, observations: observations.length, error: report.error }) + '\n');
}
