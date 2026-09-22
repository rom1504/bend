// Real parsed-book canonicalization only. No repeat checker or code generator.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [configFile, output] = process.argv.slice(2);
if (!output || fs.existsSync(output)) throw Error('Usage: book-final-real.mjs CONFIG NEW_REPORT');
const config = JSON.parse(fs.readFileSync(configFile)), hash = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const baseline = JSON.parse(fs.readFileSync(path.join(config.baseline, 'manifest.json'))), checked = JSON.parse(fs.readFileSync(config.checkedReport));
assert.equal(checked.complete, true); assert.equal(checked.inputsUnchanged, true); assert.equal(hash(checked.api.file), checked.api.sha256);
for (const name of ['api/b1.mjs', 'compiler.bend', 'src/runtime.mjs', 'tools/typed-driver.mjs', 'tools/compiler-abi.mjs']) assert.equal(hash(path.join(config.baseline, name)), baseline.files[name].sha256);
const apiFile = path.join(config.baseline, 'api/b1.mjs'), input = path.join(config.baseline, 'compiler.bend'), driver = path.join(config.baseline, 'tools/typed-driver.mjs');
const files = [import.meta.filename, configFile, config.checkedReport, checked.api.file, path.join(config.baseline, 'manifest.json'), apiFile, input, driver, config.base, config.hUnguarded, config.hGuarded, ...['compiler-abi.mjs', 'assemble.mjs', 'native-build.mjs', 'node-resource-args.mjs'].map(name => path.join(config.baseline, 'tools', name))];
const identity = Object.fromEntries(files.map(file => [file, hash(file)]));
process.env.BEND_TYPED_API = apiFile; process.env.BEND_BASE = config.base; process.env.BEND_TYPED_RUNTIME = path.join(config.baseline, 'src/runtime.mjs');
const D = await import(pathToFileURL(driver)), api = await D.loadApi(), candidate = (await import(pathToFileURL(checked.api.file))).default;
const report = {kind: 'phase4-real-parsed-book-canonicalization', complete: false, config, identity, node: {version: process.version, args: process.execArgv}, scope: 'Component work on a source-identity-checked parsed compiler book; no repeated checker or code generator. Base preparation checked normally and reported separately.', phases: [], rows: [], datasets: []};
const save = () => fs.writeFileSync(output, JSON.stringify(report, null, 2) + '\n'); save();
async function phase(name, work) { const start = performance.now(), result = await work(); report.phases.push({name, milliseconds: performance.now() - start}); save(); return result; }
const seed = await phase('validated Base preparation', () => D.prepareBase(api));
report.base = {sourcePath: seed.sourcePath, bookSha256: seed.bookSha256, validatedBy: seed.validatedBy};
const graph = await phase('discover and parse compiler source', () => D.discoverSources(api, input, {seed}));
const loaded = await phase('load graph with validated Base seed', () => api.f_load_graph_seed(graph.main, graph.sources, seed.sourcePath, seed.sourceText, seed.book));
assert.equal(loaded.error, '');
const nil = {$: 'Nil'}, array = value => { const result = []; while (value.$ === 'Con') { result.push(value.head); value = value.tail; } assert.equal(value.$, 'Nil'); return result; };
const digest = book => crypto.createHash('sha256').update(JSON.stringify(array(book))).digest('hex');
for (const [label, book] of [['Base', seed.book], ['compiler', loaded.book]]) {
  console.log('DATASET ' + label);
  const before = digest(book), expected = digest(api.driver_final(book, nil));
  assert.equal(digest(candidate.book_final_legacy(book, nil)), expected); assert.equal(digest(candidate.book_final_fast(book, nil)), expected);
  report.datasets.push({label, definitions: array(book).length, inputSha256: before, resultSha256: expected}); save();
  for (let round = 0; round < 3; round++) for (const method of round % 2 ? ['book_final_fast', 'book_final_legacy'] : ['book_final_legacy', 'book_final_fast']) {
    const start = performance.now(), result = candidate[method](book, nil), milliseconds = performance.now() - start;
    assert.equal(digest(result), expected); report.rows.push({dataset: label, image: 'checked-B1', method, round, milliseconds, outputSha256: expected}); save();
  }
  assert.equal(digest(book), before);
}
// Base-only H component comparison; convert once outside all timers.
const oldH = await import(pathToFileURL(config.hUnguarded)), newH = await import(pathToFileURL(config.hGuarded));
const {createCompilerAbi} = await import(pathToFileURL(path.join(config.baseline, 'tools/compiler-abi.mjs')));
const abi = createCompilerAbi({ctor: newH.ctor, fields: {Nil: [], Con: ['head', 'tail'], KDef: ['name', 'kind', 'arity', 'templates', 'typ', 'value', 'ctors', 'native', 'unsafe'], KTerm: ['tag', 'name', 'id', 'quant', 'kids', 'removed']}});
const positional = abi.encode(seed.book), empty = abi.encode(nil), expected = report.datasets.find(item => item.label === 'Base').resultSha256;
const hMethods = {legacy: newH.default.book_final_legacy, unguarded: oldH.default.book_final_fast, guarded: newH.default.book_final_fast};
for (const method of Object.values(hMethods)) assert.equal(digest(abi.decode(method(positional, empty))), expected);
for (let round = 0; round < 3; round++) for (const method of round % 2 ? ['guarded', 'unguarded', 'legacy'] : ['legacy', 'unguarded', 'guarded']) {
  const start = performance.now(), result = hMethods[method](positional, empty), milliseconds = performance.now() - start;
  assert.equal(digest(abi.decode(result)), expected); report.rows.push({dataset: 'Base', image: 'H-component', method, round, milliseconds, outputSha256: expected}); save();
}
report.changedInputs = Object.entries(identity).filter(([file, before]) => hash(file) !== before).map(([file]) => file);
assert.deepEqual(report.changedInputs, []); report.complete = true; save(); console.log(JSON.stringify({complete: true, phases: report.phases, datasets: report.datasets}));
