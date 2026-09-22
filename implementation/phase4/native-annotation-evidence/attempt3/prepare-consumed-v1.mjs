// Checked component preparation; no changes to the frozen compiler modules.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {assemble} from '../../assemble.mjs';
const [launchFile, outputArgument] = process.argv.slice(2);
if (!outputArgument) throw Error('Usage: native-annotation-prepare.mjs COMBINED_LAUNCH NEW_DIRECTORY');
const out = path.resolve(outputArgument), read = f => JSON.parse(fs.readFileSync(f)), hash = f => crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const launch = read(launchFile), checked = read(launch.checked);
assert.equal(checked.complete, true); assert.equal(checked.inputsUnchanged, true);
assert.equal(hash(launch.source.file), launch.source.sha256); assert.equal(hash(launch.api.file), launch.api.sha256);
fs.mkdirSync(out, {recursive: false});
const inputs = [launchFile, launch.checked, launch.source.file, launch.api.file, import.meta.filename, path.resolve(import.meta.dirname, '../../assemble.mjs')];
const copied = [];
function copy(file, rel, text = fs.readFileSync(file)) { const dst = path.join(out, rel); fs.mkdirSync(path.dirname(dst), {recursive: true}); fs.writeFileSync(dst, text); inputs.push(file); copied.push({source: file, target: dst, sourceSha256: hash(file), sha256: hash(dst)}); return dst; }
const modules = checked.modules.map(m => { assert.equal(hash(m.destination), m.sha256); return copy(m.destination, m.relative); });
const bundle = path.resolve(import.meta.dirname, '../rapid/native-bundle.bend'), graph = path.resolve(import.meta.dirname, '../rapid/native-graph.bend');
const oldBundle = fs.readFileSync(bundle, 'utf8').replace(/^law main:/m, 'law ap_original_main:').replace(/^def main\(\):/m, 'def ap_original_main():');
assert.notEqual(oldBundle, fs.readFileSync(bundle, 'utf8'));
modules.push(copy(bundle, 'wrapper/native-bundle.bend', oldBundle), copy(graph, 'wrapper/native-graph.bend'));
const wrapper = path.join(import.meta.dirname, 'native-annotation.bend');
let laws = '';
const prepared = fs.readFileSync(wrapper, 'utf8').replace(/^def ([A-Za-z_][A-Za-z_0-9]*)\((.*)\) -> (.*):$/gm, (_, name, args, result) => {
  let depth = 0, start = 0; const fields = [];
  for (let i = 0; i < args.length; ++i) { if ('<(['.includes(args[i])) ++depth; if ('>)]'.includes(args[i])) --depth; if (args[i] === ',' && !depth) { fields.push(args.slice(start, i).trim()); start = i + 1; } }
  if (args.trim()) fields.push(args.slice(start).trim());
  assert.ok(fields.every(x => /^\+?[A-Za-z_][A-Za-z_0-9]*: .+$/.test(x)), name);
  laws += `law ${name}:\n` + fields.map(x => '  for ' + x + '\n').join('') + '  ' + result + '\n\n';
  return 'def ' + name + '(' + fields.map(x => x.split(':')[0].replace(/^\+/, '')).join(', ') + '):';
});
modules.push(copy(wrapper, 'wrapper/native-annotation.bend', laws + prepared));
const source = path.join(out, 'compiler.bend'), assembly = assemble(modules, source);
const identity = Object.fromEntries([...new Set(inputs)].map(f => [f, hash(f)]));
const report = {kind: 'phase4-native-annotation-preparation', complete: true, at: new Date().toISOString(), launch, identity, copied, assembly, source, sourceSha256: hash(source), scope: '59 unchanged frozen compiler modules plus disposable native annotation wrapper; original native driver main renamed, wrapper signatures expanded to forward laws.'};
fs.writeFileSync(path.join(out, 'preparation.json'), JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify({source, sha256: report.sourceSha256}));
