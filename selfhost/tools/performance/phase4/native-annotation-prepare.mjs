// Checked component preparation; no changes to the frozen compiler modules.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {assemble} from '../../assemble.mjs';
const [launchFile, outputArgument] = process.argv.slice(2);
if (!outputArgument) throw Error('Usage: native-annotation-prepare.mjs COMBINED_LAUNCH NEW_DIRECTORY');
const out = path.resolve(outputArgument), digest = bytes => crypto.createHash('sha256').update(bytes).digest('hex'), hash = f => digest(fs.readFileSync(f));
fs.mkdirSync(out, {recursive: false});
const identity = {}, copied = [], report = {kind: 'phase4-native-annotation-preparation', complete: false, started: new Date().toISOString(), identity, copied};
const save = () => fs.writeFileSync(path.join(out, 'preparation.json'), JSON.stringify(report, null, 2) + '\n'); save();
function consume(file) { const key = path.resolve(file), bytes = fs.readFileSync(key), sha256 = digest(bytes); if (identity[key]) assert.equal(sha256, identity[key], 'Input changed: ' + key); else identity[key] = sha256; return bytes; }
function copy(file, rel, text) { const bytes = consume(file), dst = path.join(out, rel), output = text === undefined ? bytes : text; fs.mkdirSync(path.dirname(dst), {recursive: true}); fs.writeFileSync(dst, output); assert.equal(hash(dst), digest(output)); copied.push({source: path.resolve(file), target: dst, sourceSha256: digest(bytes), sha256: hash(dst)}); return dst; }
try {
consume(import.meta.filename); consume(path.resolve(import.meta.dirname, '../../assemble.mjs'));
const launch = JSON.parse(consume(launchFile)), checked = JSON.parse(consume(launch.checked)); report.launch = launch;
assert.equal(checked.complete, true); assert.equal(checked.inputsUnchanged, true);
assert.equal(digest(consume(launch.source.file)), launch.source.sha256); assert.equal(digest(consume(launch.api.file)), launch.api.sha256);
const modules = checked.modules.map(m => { assert.equal(digest(consume(m.destination)), m.sha256); const target = copy(m.destination, m.relative); assert.equal(hash(target), m.sha256); return target; });
const bundle = path.resolve(import.meta.dirname, '../rapid/native-bundle.bend'), graph = path.resolve(import.meta.dirname, '../rapid/native-graph.bend');
const oldBundle = consume(bundle).toString().replace(/^law main:/m, 'law ap_original_main:').replace(/^def main\(\):/m, 'def ap_original_main():');
assert.notEqual(oldBundle, consume(bundle).toString());
modules.push(copy(bundle, 'wrapper/native-bundle.bend', oldBundle), copy(graph, 'wrapper/native-graph.bend'));
const wrapper = path.join(import.meta.dirname, 'native-annotation.bend');
let laws = '';
const prepared = consume(wrapper).toString().replace(/^def ([A-Za-z_][A-Za-z_0-9]*)\((.*)\) -> (.*):$/gm, (_, name, args, result) => {
  let depth = 0, start = 0; const fields = [];
  for (let i = 0; i < args.length; ++i) { if ('<(['.includes(args[i])) ++depth; if ('>)]'.includes(args[i])) --depth; if (args[i] === ',' && !depth) { fields.push(args.slice(start, i).trim()); start = i + 1; } }
  if (args.trim()) fields.push(args.slice(start).trim());
  assert.ok(fields.every(x => /^\+?[A-Za-z_][A-Za-z_0-9]*: .+$/.test(x)), name);
  laws += `law ${name}:\n` + fields.map(x => '  for ' + x + '\n').join('') + '  ' + result + '\n\n';
  return 'def ' + name + '(' + fields.map(x => x.split(':')[0].replace(/^\+/, '')).join(', ') + '):';
});
modules.push(copy(wrapper, 'wrapper/native-annotation.bend', laws + prepared));
const source = path.join(out, 'compiler.bend'), assembly = assemble(modules, source);
Object.assign(report, {assembly, source, sourceSha256: hash(source), scope: '59 unchanged frozen compiler modules plus disposable native annotation wrapper; original native driver main renamed, wrapper signatures expanded to forward laws.'});
report.changedInputs = Object.entries(identity).filter(([f,h]) => hash(f) !== h).map(([f]) => f);
report.changedCopies = copied.filter(c => hash(c.target) !== c.sha256).map(c => c.target);
assert.deepEqual(report.changedInputs, []); assert.deepEqual(report.changedCopies, []); report.complete = true;
} catch (error) { report.error = error.stack; process.exitCode = 1; }
finally { report.finished = new Date().toISOString(); save(); console.log(JSON.stringify({complete: report.complete, source: report.source, sha256: report.sourceSha256, error: report.error})); }
