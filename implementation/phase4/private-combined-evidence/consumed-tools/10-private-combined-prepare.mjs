import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {identity, verifyIdentity} from '../../private-compiler/common.mjs';
import {validateProof} from '../../private-compiler/proof.mjs';
import {assertSupportedRuntime} from '../../private-compiler/build.mjs';
import {specializeCompiler} from '../../private-compiler/transform.mjs';
import {privateBooleans} from './private-booleans.mjs';
import {privateStableMemo} from './private-stable-memo.mjs';
import {privateCombined} from './private-combined-transform.mjs';

const [configArgument, outputArgument] = process.argv.slice(2);
if (!outputArgument) throw Error('Usage: private-combined-prepare.mjs CONFIG_JSON NEW_DIRECTORY');
const configuration = fs.realpathSync(configArgument), config = JSON.parse(fs.readFileSync(configuration));
const resolve = file => fs.realpathSync(path.resolve(path.dirname(configuration), file));
const out = path.resolve(outputArgument); fs.mkdirSync(out, {recursive: false});
const proof = path.join(out, 'checked-proof.json'); fs.copyFileSync(resolve(config.proof), proof);
const runtime = resolve(config.runtime), api = resolve(config.api);
assertSupportedRuntime(fs.readFileSync(runtime));
const validated = validateProof({proofFile: proof, apiFile: api, runtimeFile: runtime, experimental: false});
const initial = await import(pathToFileURL(validated.proof.initialCompiler.file));
const exports = Object.keys(initial.default), source = fs.readFileSync(api, 'utf8');
const toolFiles = [import.meta.filename, ...['private-booleans.mjs','private-stable-memo.mjs','private-combined-transform.mjs'].map(n=>path.join(import.meta.dirname,n)),
  ...fs.readdirSync(path.resolve(import.meta.dirname, '../../private-compiler')).filter(name => name.endsWith('.mjs')).map(name => path.resolve(import.meta.dirname, '../../private-compiler', name))];
const inputs = [...validated.inputs, ...[configuration, process.execPath, ...toolFiles].map(identity)];
const snapshots = path.join(out, 'tools'); fs.mkdirSync(snapshots);
for (const file of toolFiles) fs.copyFileSync(file, path.join(snapshots, path.basename(file)));
const report = {kind: 'phase4-private-combined-experiment', complete: false, proofStatus: validated.status,
  source: identity(api), inputs, variants: [],
  scope: 'Private data-only compiler worker. Four variants from one completed proof: canonical private, Boolean-only, stable-only, and verified composition; unchanged public outputs and host boundary.',
};
for (const [id, transform] of [['private-control', specializeCompiler], ['private-booleans', privateBooleans], ['private-stable', privateStableMemo], ['private-combined', privateCombined]]) {
  const result = transform(source, exports), file = path.join(out, id + '.mjs');
  fs.writeFileSync(file, result.source, {flag: 'wx'});
  report.variants.push({id, file, sha256: identity(file).sha256, stats: result.stats});
}
assert.ok(Object.values(report.variants[1].stats.booleans.counts).some(n => n > 0));
inputs.forEach(verifyIdentity); report.complete = true;
fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify({complete: true, proofStatus: report.proofStatus, stats: report.variants[1].stats.booleans}));
