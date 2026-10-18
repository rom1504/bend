// Root executes this host harness; all transformations use the checked Bend API.
// Capacity/invalid graphs are never emitted or executed as generated programs.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {decodeNxProgram} from './ir-json.mjs';

const [apiFile, outArg] = process.argv.slice(2);
if (!apiFile || !outArg || process.argv.length !== 4) throw Error('Usage: constant-capacity.mjs API FRESH_OUT');
const out = path.resolve(outArg); fs.mkdirSync(out, {recursive: false});
const pin = file => {const b = fs.readFileSync(file); return {file: path.resolve(file), bytes: b.length, sha256: crypto.createHash('sha256').update(b).digest('hex')};};
const write = (name, value) => {const file = path.join(out, name); fs.writeFileSync(file, typeof value === 'string' ? value : JSON.stringify(value, null, 2) + '\n', {flag: 'wx'}); return pin(file);};
const inputs = [apiFile, import.meta.filename, ...['ir-json.mjs', 'inline/constant.bend', 'inline/constant-controls.json'].map(x => path.join(import.meta.dirname, x))].map(pin);
const report = {kind: 'phase107-constant-capacity', complete: false, passed: false, started: Date.now() / 1000,
  inputs, command: process.argv, generatedProgramExecuted: false, rows: []};
const c = value => ({kind: 'const', type: 'u32', value}), v = name => ({kind: 'var', name});
const set = (name, value) => ({kind: 'set', name, value}), ret = value => ({kind: 'return', value});
const param = (name, type = 'u32') => ({name, type});
const fn = (name = 'main') => ({name, params: [], result: 'u32', locals: [param('x')], body: [set('x', c(1)), ret(v('x'))]});
const program = functions => ({version: 1, entry: 'main', functions});
function treeNodes(x) {
  if (Array.isArray(x)) return x.reduce((n, y) => n + treeNodes(y), 0);
  if (!x || typeof x !== 'object') return 0;
  return (typeof x.kind === 'string' ? 1 : 0) + Object.values(x).reduce((n, y) => n + treeNodes(y), 0);
}
const nodes = p => 1 + p.functions.reduce((n, f) => n + 1 + f.params.length + f.locals.length + treeNodes(f.body), 0);
function depth(body) {return body.reduce((d, s) => Math.max(d, s.kind === 'while' ? 1 + depth(s.body) : s.kind === 'if' ? 1 + Math.max(depth(s.then), depth(s.else)) : 0), 0);}
function shape(p) {
  const result = [], effects = new Set(['call', 'icall', 'alloc', 'load', 'store', 'free']);
  function walk(x, at) {
    if (Array.isArray(x)) x.forEach((y, i) => walk(y, [...at, i]));
    else if (x && typeof x === 'object') {
      if (effects.has(x.kind) || ['set', 'return', 'if', 'while'].includes(x.kind)) result.push({at, kind: x.kind, name: x.name ?? null});
      for (const [key, value] of Object.entries(x)) walk(value, [...at, key]);
    }
  }
  walk(p, []); return result;
}
function cases() {
  const all = [], add = (name, p, changed, metric, expected, valid = true) => all.push({name, program: p, changed, metric, expected, valid});
  add('literal-witness', program([fn()]), true);
  for (const n of [255, 256, 257]) add('functions' + n, program(Array.from({length: n}, (_, i) => fn(i ? 'f' + i : 'main'))), n <= 256, 'functions', n);
  for (const n of [127, 128, 129]) {
    const f = fn(); f.params = Array.from({length: n - 1}, (_, i) => param('a' + i));
    add('bindings' + n, program([f]), n <= 128, 'bindings', n);
  }
  for (const n of [4095, 4096, 4097]) {
    const f = fn(), extra = [];
    // An alloc/free pair costs five nodes, yielding odd totals without invalid memory accesses.
    if (n % 2) {f.locals.push(param('p', 'ptr')); extra.push(set('p', {kind: 'alloc', bytes: c(4)}), {kind: 'free', ptr: v('p')});}
    const padding = (n - 4 - treeNodes(extra)) / 2; assert(Number.isInteger(padding));
    f.body = [set('x', c(1)), ...Array.from({length: padding}, () => set('x', c(1))), ...extra, ret(v('x'))];
    add('body' + n, program([f]), n <= 4096, 'body', n);
  }
  for (const n of [15, 16, 17]) {
    const f = fn(); let body = [set('x', c(1))];
    for (let i = 0; i < n; i++) body = [{kind: 'while', cond: c(0), body}];
    // Put the independent literal witness after the loop: nested-loop havoc may
    // legitimately forget x even when these loops have a literal false condition.
    f.body.unshift(...body); add('depth' + n, program([f]), n <= 16, 'depth', n);
  }
  for (const n of [65535, 65536, 65537]) {
    const p = program(Array.from({length: 128}, (_, i) => fn(i ? 'f' + i : 'main'))), difference = n - nodes(p);
    for (let i = 0; i < Math.floor(difference / 2); i++) p.functions[i % 128].body.splice(-1, 0, set('x', c(1)));
    if (difference % 2) p.functions[0].locals.push(param('padding', 'u64'));
    assert(p.functions.every(f => treeNodes(f.body) <= 4096));
    add('nodes' + n, p, n <= 65536, 'nodes', n);
  }
  const invalid = program([fn()]); invalid.functions[0].body.at(-1).value = v('missing');
  add('invalid-identity', invalid, false, undefined, undefined, false);
  const store = value => ({kind: 'store', type: 'u32', ptr: v('p'), offset: 0, value});
  const touch = {name: 'touch', params: [param('p', 'ptr'), param('value')], result: 'u32', locals: [], body: [store(v('value')), ret(c(0))]};
  const main = {name: 'main', params: [], result: 'u32', locals: [param('p', 'ptr'), param('size'), param('x'), param('called'), param('loaded')], body: [
    set('size', c(4)), set('x', c(7)), set('p', {kind: 'alloc', bytes: v('size')}), store(v('x')),
    set('called', {kind: 'call', name: 'touch', args: [v('p'), {kind: 'bin', op: 'add', lhs: v('x'), rhs: c(2)}]}),
    set('loaded', {kind: 'load', type: 'u32', ptr: v('p'), offset: 0}), {kind: 'free', ptr: v('p')},
    ret({kind: 'bin', op: 'add', lhs: v('loaded'), rhs: v('called')})]};
  const effect = program([touch, main]), expectedEffect = structuredClone(effect), body = expectedEffect.functions[1].body;
  body[2].value.bytes = c(4); body[3].value = c(7); body[4].value.args[1] = c(9);
  add('effect-operands', effect, true); all.at(-1).expectedProgram = expectedEffect;
  all.at(-1).observation = {args: [], expected: 9, reason: 'touch overwrites the allocation with 9, returns 0; the following load returns 9.', executed: false};
  assert.equal(all.length, 18); return all;
}
try {
  const api = (await import(pathToFileURL(path.resolve(apiFile)))).default;
  for (const name of ['nx_constant_propagate', 'nx_verify', 'nx_inline_nodes', 'nx_json_program']) assert.equal(typeof api[name], 'function', 'missing export ' + name);
  for (const item of cases()) {
    const p = item.program, f = p.functions[0], metrics = {functions: p.functions.length, bindings: f.params.length + f.locals.length,
      body: treeNodes(f.body), depth: depth(f.body), nodes: nodes(p)}, raw = decodeNxProgram(p);
    if (item.metric) assert.equal(metrics[item.metric], item.expected, item.name + ' constructed boundary');
    assert.equal(api.nx_verify(raw), item.valid, item.name + ' input validity');
    assert.equal(api.nx_inline_nodes(raw), metrics.nodes, item.name + ' Bend/independent count');
    const rawText = api.nx_json_program(raw); assert.deepStrictEqual(JSON.parse(rawText), p, item.name + ' decoder round trip');
    const start = performance.now(), after = api.nx_constant_propagate(raw), seconds = (performance.now() - start) / 1000;
    const afterText = api.nx_json_program(after), afterJson = JSON.parse(afterText), changed = rawText !== afterText;
    assert.equal(api.nx_json_program(raw), rawText, item.name + ' original graph unchanged');
    assert.equal(api.nx_verify(after), item.valid, item.name + ' output validity');
    assert.equal(changed, item.changed, item.name + ' expected activation/refusal');
    assert.equal(api.nx_inline_nodes(after), nodes(afterJson), item.name + ' output count');
    assert(nodes(afterJson) <= metrics.nodes, item.name + ' nonincreasing nodes');
    assert.deepStrictEqual(shape(afterJson), shape(p), item.name + ' exact statement/effect ordering');
    if (!item.changed) assert.deepStrictEqual(afterJson, p, item.name + ' exact identity');
    if (!item.valid) assert.deepStrictEqual(after, raw, item.name + ' invalid graph identity');
    if (item.name === 'literal-witness') assert.deepStrictEqual(afterJson.functions[0].body, [set('x', c(1)), ret(c(1))]);
    if (item.expectedProgram) assert.deepStrictEqual(afterJson, item.expectedProgram, item.name + ' exact effect operand substitution');
    report.rows.push({name: item.name, valid: item.valid, changed, metrics, afterNodes: nodes(afterJson), seconds,
      before: write(item.name + '.before.json', rawText), after: write(item.name + '.after.json', afterText), observation: item.observation, passed: true});
  }
  for (const old of inputs) assert.deepStrictEqual(pin(old.file), old, 'input changed during audit');
  report.complete = true; report.passed = true; report.counts = {cases: report.rows.length, boundaries: 15, invalid: 1, literal: 1, effectOperands: 1};
} catch (error) {report.error = {message: error.message, stack: error.stack}; process.exitCode = 1;}
finally {
  report.finished = Date.now() / 1000; report.wallSeconds = report.finished - report.started;
  write('method.mjs', fs.readFileSync(import.meta.filename, 'utf8')); write('audit-report.json', report);
  console.log(JSON.stringify({complete: report.complete, passed: report.passed, counts: report.counts, error: report.error?.message}));
}
