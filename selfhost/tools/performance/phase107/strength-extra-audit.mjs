// Root-owned execution: exact effect positions/operands and bounded refusal audit.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {decodeNxProgram} from './ir-json.mjs';
import {strengthExtraControls, strengthExtraScope} from './strength-extra-controls.mjs';

const [apiFile, outArg] = process.argv.slice(2);
if (!apiFile || !outArg || process.argv.length !== 4) throw Error('Usage: strength-extra-audit.mjs API FRESH_OUT');
const out = path.resolve(outArg); fs.mkdirSync(out, {recursive: false});
const pin = file => {const bytes = fs.readFileSync(file); return {file: path.resolve(file), bytes: bytes.length, sha256: crypto.createHash('sha256').update(bytes).digest('hex')};};
const write = (name, data) => {const file = path.join(out, name); fs.writeFileSync(file, data, {flag: 'wx'}); return pin(file);};
const controlFile = path.join(import.meta.dirname, 'inline/strength-controls-v3.json');
const sourceFiles = [apiFile, import.meta.filename, controlFile, ...['ir-json.mjs', 'strength-extra-controls.mjs',
  'inline/strength.bend', 'inline/strength-fixtures.bend'].map(n => path.join(import.meta.dirname, n))];
const inputs = sourceFiles.map(pin), rows = [];
const report = {kind: 'phase107-strength-extra-audit', complete: false, passed: false, started: Date.now() / 1000,
  command: process.argv, inputs, scope: strengthExtraScope, rows, generatedProgramExecuted: false};
function treeNodes(value) {
  if (Array.isArray(value)) return value.reduce((n, x) => n + treeNodes(x), 0);
  if (!value || typeof value !== 'object') return 0;
  return (typeof value.kind === 'string' ? 1 : 0) + Object.values(value).reduce((n, x) => n + treeNodes(x), 0);
}
const nodes = p => 1 + p.functions.reduce((n, f) => n + 1 + f.params.length + f.locals.length + treeNodes(f.body), 0);
function effects(p) {
  const found = [];
  function body(stmts, at) {
    stmts.forEach((s, i) => {
      const site = [...at, i];
      if (['store', 'free'].includes(s.kind) || ['call', 'icall', 'load', 'alloc'].includes(s.value?.kind))
        found.push({site, statement: s});
      if (s.kind === 'if') {body(s.then, [...site, 'then']); body(s.else, [...site, 'else']);}
      if (s.kind === 'while') body(s.body, [...site, 'body']);
    });
  }
  p.functions.forEach(f => body(f.body, [f.name])); return found;
}
try {
  for (const expected of JSON.parse(fs.readFileSync(controlFile)).sourceInputs) {
    const actual = pin(expected.file); assert.equal(actual.sha256, expected.sha256, 'frozen source ' + expected.file);
    assert.equal(actual.bytes, expected.bytes); if (!inputs.some(p => p.file === actual.file)) inputs.push(actual);
  }
  const api = (await import(pathToFileURL(path.resolve(apiFile)))).default;
  for (const name of ['nx_strength_reduce', 'nx_verify', 'nx_inline_nodes', 'nx_json_program', 'nx_c_program', 'nxq_program_fused'])
    assert.equal(typeof api[name], 'function', 'missing ' + name);
  const cases = strengthExtraControls(); assert.equal(cases.length, strengthExtraScope.expectedCases);
  write('extra-controls.json', JSON.stringify({scope: strengthExtraScope, cases}, null, 2) + '\n');
  for (const item of cases) {
    const {name, program: json} = item, raw = decodeNxProgram(json), rawObject = JSON.stringify(raw);
    assert.deepStrictEqual(JSON.parse(api.nx_json_program(raw)), json, name + ' decoder round trip');
    assert.equal(api.nx_verify(raw), item.valid, name + ' original validity');
    const beforeNodes = api.nx_inline_nodes(raw); assert.equal(beforeNodes, nodes(json), name + ' independent node count');
    if (item.expectedOriginalNodes !== undefined) assert.equal(beforeNodes, item.expectedOriginalNodes);
    if (item.expectedOriginalBodyNodes !== undefined) assert.equal(treeNodes(json.functions[0].body), item.expectedOriginalBodyNodes);
    const after = api.nx_strength_reduce(raw), valid = api.nx_verify(after);
    assert.equal(valid, item.valid, name + ' output validity'); assert.equal(JSON.stringify(raw), rawObject, name + ' mutation');
    const beforeText = api.nx_json_program(raw), afterText = api.nx_json_program(after), afterJson = JSON.parse(afterText);
    const afterNodes = api.nx_inline_nodes(after); assert.equal(afterNodes, nodes(afterJson));
    const changed = beforeText !== afterText, growth = afterNodes - beforeNodes, stem = path.join(out, name);
    const row = {name, stem, valid, changed, native: item.execute === true,
      extra: {name, args: (item.inputs ?? []).map(a => String(a[0])), expected: (item.expected ?? []).map(String)},
      suite: item.suite, beforeNodes, afterNodes, growth, unchanged: item.unchanged,
      before: write(name + '.before.json', beforeText), after: write(name + '.json', afterText)};
    rows.push(row);
    if (item.unchanged !== undefined) assert.equal(!changed, item.unchanged, name + ' refusal/change');
    if (!valid) assert.deepStrictEqual(after, raw, name + ' invalid exact refusal');
    else assert(growth <= 4096, name + ' growth cap');
    if (item.expectedGrowth !== undefined) assert.equal(growth, item.expectedGrowth, name + ' exact growth');
    assert.deepStrictEqual(json.functions.map(f => [f.name, f.params, f.locals]), afterJson.functions.map(f => [f.name, f.params, f.locals]));
    const events = effects(json); assert.deepStrictEqual(effects(afterJson), events, name + ' exact effect positions/operands');
    row.effects = write(name + '.effects.json', JSON.stringify(events, null, 2) + '\n');
    if (valid && row.native) {
      assert(changed, name + ' transformation must activate');
      assert(row.extra.args.length > 0 && row.extra.args.length === row.extra.expected.length);
      row.emissions = [['c', 'nx_c_program'], ['ssa', 'nxq_program_fused']].map(([ext, emit]) => write(name + '.' + ext, api[emit](after)));
    }
    row.passed = true;
  }
  for (const expected of inputs) assert.deepStrictEqual(pin(expected.file), expected, 'input changed');
  report.complete = true; report.passed = true;
  report.counts = {cases: rows.length, valid: rows.filter(r => r.valid).length, invalid: rows.filter(r => !r.valid).length,
    nativePrepared: rows.filter(r => r.native).length, capacity: rows.filter(r => r.suite === 'capacity').length};
} catch (error) {report.error = {message: error.message, stack: error.stack}; process.exitCode = 1;}
finally {
  report.finished = Date.now() / 1000; report.wallSeconds = report.finished - report.started;
  write('rows.json', JSON.stringify(rows, null, 2) + '\n');
  write('controls.json', fs.readFileSync(controlFile));
  write('inputs.json', JSON.stringify(inputs, null, 2) + '\n');
  write('method.mjs', fs.readFileSync(import.meta.filename));
  write('audit-report.json', JSON.stringify(report, null, 2) + '\n');
  console.log(JSON.stringify({complete: report.complete, passed: report.passed, counts: report.counts, error: report.error?.message}));
}
