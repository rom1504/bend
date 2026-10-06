// Data-only source census. Never imports or executes an emitted module.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { fileURLToPath } from 'node:url';

const [baselineFile, candidateFile, out, ...ids] = process.argv.slice(2);
assert(baselineFile && candidateFile && out && ids.length);
assert(!fs.existsSync(out), 'fresh output required');
const sha = bytes => createHash('sha256').update(bytes).digest('hex');
const identity = file => {
  file = fs.realpathSync(file);
  const bytes = fs.readFileSync(file);
  return { file, sha256: sha(bytes), bytes: bytes.length };
};
const inputs = [identity(baselineFile), identity(candidateFile), identity(fileURLToPath(import.meta.url)), identity(process.execPath)];
const acornModule = { exports: {} };
new Function('module', 'exports', process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'])(acornModule, acornModule.exports);
const parse = text => acornModule.exports.parse(text, { ecmaVersion: 'latest', sourceType: 'module', locations: true });
const baseline = JSON.parse(fs.readFileSync(baselineFile)), candidate = JSON.parse(fs.readFileSync(candidateFile));
const rows = [];
for (const id of ids) {
  const read = (manifest, file) => {
    const matches = manifest.cases.filter(row => row.id === id);
    assert.equal(matches.length, 1);
    const module = matches[0].modules.candidate;
    const pin = identity(path.resolve(path.dirname(file), module.path));
    assert.equal(pin.sha256, module.sha256);
    inputs.push(pin);
    return { pin, text: fs.readFileSync(pin.file, 'utf8') };
  };
  const before = read(baseline, baselineFile), after = read(candidate, candidateFile);
  const ast = parse(before.text), edits = [], sites = [];
  const walk = (node, owner = '<module>') => {
    if (!node || typeof node !== 'object') return;
    if (node.type === 'FunctionDeclaration') owner = node.id.name;
    if (node.type === 'ObjectExpression') {
      const selected = node.properties.filter(p => p.type === 'Property' && p.kind === 'init' && !p.method && !p.shorthand && p.computed && p.key.type === 'Literal' && typeof p.key.value === 'string' && p.key.value !== '__proto__');
      if (selected.length) {
        const tag = node.properties.find(p => p.type === 'Property' && !p.computed && (p.key.name === '$' || p.key.value === '$'));
        sites.push({ owner, line: node.loc.start.line, column: node.loc.start.column + 1, tag: tag?.value.type === 'Literal' ? tag.value.value : null, fields: selected.map(p => p.key.value) });
      }
      for (const p of selected) {
        const close = /^\s*\]\s*:/.exec(before.text.slice(p.key.end, p.value.start));
        assert(close);
        edits.push({ start: p.start, end: p.key.end + close[0].length, text: JSON.stringify(p.key.value) + ':' });
      }
    }
    for (const [key, child] of Object.entries(node)) {
      if (['start', 'end', 'loc'].includes(key)) continue;
      if (Array.isArray(child)) child.forEach(x => walk(x, owner));
      else if (child && typeof child === 'object') walk(child, owner);
    }
  };
  walk(ast);
  let normalized = before.text;
  for (const e of edits.sort((a, b) => b.start - a.start)) normalized = normalized.slice(0, e.start) + e.text + normalized.slice(e.end);
  const functions = text => Object.fromEntries(parse(text).body.filter(n => n.type === 'FunctionDeclaration').map(n => [n.id.name, text.slice(n.start, n.end)]));
  const bf = functions(normalized), af = functions(after.text);
  const changedFunctions = [...new Set([...Object.keys(bf), ...Object.keys(af)])].filter(name => bf[name] !== af[name]);
  rows.push({ id, baseline: before.pin, candidate: after.pin, fieldEdits: edits.length, objectSites: sites.length, fieldOnlyByteIdentity: normalized === after.text, normalizedSha256: sha(normalized), changedFunctionsAfterNormalization: changedFunctions, sites });
}
for (const pin of inputs) assert.deepEqual(identity(pin.file), pin);
const report = { kind: 'phase58-data-only-program-field-census', complete: true, pass: true, scope: 'Static exact-text isolation only; no target execution, allocation count, timing or causal V8 claim.', nodeVersion: process.version, inputs, rows, inputsUnchanged: true };
fs.mkdirSync(path.dirname(path.resolve(out)), { recursive: true });
fs.writeFileSync(out, JSON.stringify(report, null, 2) + '\n', { flag: 'wx' });
console.log(JSON.stringify(rows.map(({ id, fieldEdits, objectSites, fieldOnlyByteIdentity }) => ({ id, fieldEdits, objectSites, fieldOnlyByteIdentity }))));
