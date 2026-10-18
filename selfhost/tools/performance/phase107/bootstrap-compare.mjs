// Independent host comparison of two compiled implementations of the same Bend API.
// This runs compiler functions only; native execution and semantic oracles are separate.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {fileURLToPath, pathToFileURL} from 'node:url';

const [leftArg, rightArg, graphsArg, outArg, entry = 'bench'] = process.argv.slice(2);
if (!leftArg || !rightArg || !graphsArg || !outArg) {
  throw Error('Usage: bootstrap-compare.mjs B1_API B2_API GRAPH_DIR NEW_OUT_DIR [ENTRY=bench]');
}
const out = path.resolve(outArg), start = performance.now();
fs.mkdirSync(out, {recursive: false});
const sha = text => crypto.createHash('sha256').update(text).digest('hex');
const pin = file => {
  const data = fs.readFileSync(file);
  return {file: path.resolve(file), bytes: data.length, sha256: sha(data)};
};
const report = {
  kind: 'phase107-compiled-api-differential', complete: false,
  scope: 'Same-source compiled API equivalence on frozen inputs; not a native fixed point, semantic proof, or performance comparison.',
  inputs: [pin(leftArg), pin(rightArg), pin(fileURLToPath(import.meta.url))],
  entry, graphs: [], rows: [], emitted: [], optionalApis: {}, comparisons: 0,
};
const save = () => fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
const required = ['nxk_lower', 'nx_inline', 'nx_inline_deep', 'nx_tail_optimize',
  'nx_inline_nodes', 'nx_i_fixture', 'nx_workload', 'nx_optimize', 'nx_verify',
  'nx_json_program', 'nx_c_program', 'nxq_program', 'nxq_program_fused', 'nxq_units'];
let context = 'imports';
function same(label, a, b) {
  report.comparisons++;
  try { assert.deepStrictEqual(a, b); }
  catch {
    const encode = value => typeof value === 'string' ? value : JSON.stringify(value, null, 2);
    fs.writeFileSync(path.join(out, 'mismatch-left.txt'), encode(a));
    fs.writeFileSync(path.join(out, 'mismatch-right.txt'), encode(b));
    throw Error('Different outputs: ' + label);
  }
}
function units(result) {
  assert.equal(result.$, 'NxqUnits');
  assert.equal(typeof result.error, 'string');
  const items = [], seen = new Set();
  for (let list = result.units; ; list = list.tail) {
    assert.ok(list && typeof list === 'object');
    if (list.$ === 'Nil') break;
    assert.equal(list.$, 'Con');
    assert.ok(!seen.has(list) && items.length < 4096, 'cyclic/oversized units');
    seen.add(list);
    assert.equal(list.head.$, 'NxqUnit');
    assert.equal(typeof list.head.name, 'string');
    assert.equal(typeof list.head.text, 'string');
    items.push({name: list.head.name, text: list.head.text});
  }
  return {error: result.error, units: items};
}

try {
  const apis = [];
  for (const file of [leftArg, rightArg]) apis.push((await import(pathToFileURL(path.resolve(file)))).default);
  for (const api of apis) for (const key of required) assert.equal(typeof api[key], 'function', key);
  // B2 may expose extra private definitions. Public return representations are identical:
  // JS Bool/string/U32 plus named tagged records/lists, without coercion or normalization.
  for (const name of ['nx_inline_entry']) {
    const present = apis.map(api => typeof api[name] === 'function');
    same('optional API availability: ' + name, present[0], present[1]);
    report.optionalApis[name] = present[0];
  }
  report.exports = apis.map(api => Object.keys(api).sort());
  for (const file of new Set([leftArg, rightArg].flatMap(api => ['source.bend', 'inputs.json'].map(name => path.join(path.dirname(api), name))))) {
    if (fs.existsSync(file)) report.inputs.push(pin(file));
  }
  const programs = [];
  for (const name of fs.readdirSync(graphsArg).sort()) {
    const file = path.join(graphsArg, name, 'selected.json');
    if (!fs.existsSync(file)) continue;
    context = 'lower/' + name;
    report.inputs.push(pin(file));
    const source = fs.readFileSync(file, 'utf8');
    const results = apis.map(api => api.nxk_lower(JSON.parse(source), entry));
    for (const r of results) { assert.equal(r.$, 'NxkResult'); assert.equal(typeof r.error, 'string'); }
    same(context + '/error', results[0].error, results[1].error);
    same(context + '/graph', results[0].program, results[1].program);
    const refused = name.startsWith('refuse_');
    assert.equal(Boolean(results[0].error), refused, 'frozen acceptance expectation: ' + name);
    report.graphs.push({name, refused, error: results[0].error});
    if (!refused) programs.push({name: 'source-' + name, raw: results.map(r => r.program), valid: true});
    save();
  }
  assert.ok(report.graphs.length > 0, 'no checked graphs found');
  const fixtures = ['snapshot', 'collision', 'branch', 'merge', 'reset', 'nested', 'cycle',
    'tail_sum', 'tail_snapshot', 'tail_reset', 'tail_nontail', 'tail_dead',
    'tail_existingloop', 'tail_pointer', 'tail_mutual'];
  const workloads = ['text', 'list', 'tree', 'closure', 'tail', 'many', 'shared', 'shared_borrow', 'classify', 'shift', 'law_bridge'];
  for (const [fn, names] of [['nx_i_fixture', fixtures], ['nx_workload', workloads]]) {
    for (const name of names) {
      context = fn + '/' + name;
      const chosen = apis.map(api => api[fn](name));
      for (const value of chosen) assert.equal(value.$, 'Some', context);
      same(context + '/construction', chosen[0].value, chosen[1].value);
      programs.push({name: (fn === 'nx_i_fixture' ? 'fixture-' : 'ir-') + name,
        raw: chosen.map(value => value.value), valid: name !== 'tail_dead'});
    }
  }
  const passes = [['identity', (_api, p) => p], ['fold', (api, p) => api.nx_optimize(p)],
    ['tail', (api, p) => api.nx_tail_optimize(p)]];
  for (const method of ['nx_inline', 'nx_inline_deep', ...(report.optionalApis.nx_inline_entry ? ['nx_inline_entry'] : [])]) {
    for (const budget of [0, 32, 4096]) passes.push([method + '-' + budget, (api, p) => api[method](p, budget)]);
  }
  passes.push(['tail-deep-fold', (api, p) => api.nx_optimize(api.nx_inline_deep(api.nx_tail_optimize(p), 4096))]);
  const emitted = new Set();
  for (const {name, raw, valid} of programs) for (const [pass, apply] of passes) {
    context = name + '/' + pass;
    // Every invocation receives a fresh graph; no implementation can consume the other's input.
    const results = apis.map((api, i) => apply(api, structuredClone(raw[i])));
    same(context + '/IR', results[0], results[1]);
    const checks = apis.map((api, i) => api.nx_verify(structuredClone(results[i])));
    same(context + '/verifier', checks[0], checks[1]);
    assert.equal(checks[0], valid, context + ' expected validity');
    if (!valid) {
      for (let i = 0; i < 2; i++) same(context + '/invalid-input-refusal', results[i], raw[i]);
      report.rows.push({name, pass, valid: false, emitted: false});
      save();
      continue;
    }
    const json = apis.map((api, i) => api.nx_json_program(structuredClone(results[i])));
    for (const value of json) assert.equal(typeof value, 'string');
    same(context + '/JSON', json[0], json[1]);
    const digest = sha(json[0]);
    const nodes = apis.map((api, i) => api.nx_inline_nodes(structuredClone(results[i])));
    same(context + '/nodes', nodes[0], nodes[1]);
    report.rows.push({name, pass, valid: true, jsonSha256: digest, nodes: nodes[0]});
    // Emit once per identical verified IR, while checking every transformation independently.
    if (!emitted.has(digest)) {
      const products = {};
      for (const fn of ['nx_c_program', 'nxq_program', 'nxq_program_fused']) {
        const values = apis.map((api, i) => api[fn](structuredClone(results[i])));
        for (const value of values) assert.equal(typeof value, 'string');
        same(context + '/' + fn, values[0], values[1]);
        products[fn] = {bytes: Buffer.byteLength(values[0]), sha256: sha(values[0])};
      }
      for (const fuse of [false, true]) {
        const values = apis.map((api, i) => units(api.nxq_units(structuredClone(results[i]), fuse)));
        same(context + '/units/' + fuse, values[0], values[1]);
        assert.equal(values[0].error, '', 'verified unit emission refused');
        products['units-' + fuse] = values[0].units.map(unit => ({name: unit.name, bytes: Buffer.byteLength(unit.text), sha256: sha(unit.text)}));
      }
      report.emitted.push({firstCase: context, jsonSha256: digest, products});
      emitted.add(digest);
    }
    save();
  }
  report.complete = true;
} catch (error) {
  report.failure = {context, message: String(error), stack: error.stack};
  process.exitCode = 1;
} finally {
  report.seconds = (performance.now() - start) / 1000;
  save();
  console.log(JSON.stringify({complete: report.complete, graphs: report.graphs.length,
    pairs: report.rows.length, uniqueEmissions: report.emitted.length,
    comparisons: report.comparisons, failure: report.failure?.message}));
}
