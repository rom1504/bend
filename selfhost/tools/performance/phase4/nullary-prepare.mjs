// Build two disposable private images differing only in nullary constructors.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {transformPrivateCalls} from './private-calls.mjs';
import {transformPrivateRuntime, transformPrivateProjections} from './private-runtime.mjs';
import {preparePrivateConstants} from './private-constants.mjs';
import {transformPrivateNullary} from './nullary-transform.mjs';

const [baselineArgument, integrationArgument, outputArgument] = process.argv.slice(2);
if (!outputArgument) throw Error('Usage: nullary-prepare.mjs FROZEN_BASELINE INTEGRATION_REPORT NEW_DIRECTORY');
const baseline = fs.realpathSync(baselineArgument), integrationFile = fs.realpathSync(integrationArgument), out = path.resolve(outputArgument);
fs.mkdirSync(out, {recursive: false});
const sha = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const inputs = new Map();
const record = file => { file = fs.realpathSync(file); const identity = {file, sha256: sha(file)}; inputs.set(file, identity); return file; };
const manifest = JSON.parse(fs.readFileSync(record(path.join(baseline, 'manifest.json'))));
for (const [relative, item] of Object.entries(manifest.files)) assert.equal(sha(record(path.join(baseline, relative))), item.sha256);
const sourceFile = path.join(baseline, 'api/h.mjs'), source = fs.readFileSync(sourceFile, 'utf8');
const proof = JSON.parse(fs.readFileSync(path.join(baseline, 'evidence/fixedpoint.json')));
assert.equal(proof.complete, true); assert.equal(proof.stages.at(-1).outputSha256, sha(sourceFile));
const integration = JSON.parse(fs.readFileSync(record(integrationFile)));
assert.equal(integration.complete, true); assert.equal(integration.apiSha256, sha(path.join(baseline, 'api/b1.mjs')));
const tools = ['nullary-prepare.mjs', 'nullary-transform.mjs', 'private-calls.mjs', 'private-runtime.mjs', 'private-constants.mjs', '../rapid/direct-calls.mjs', '../rapid/native-primitives.mjs'];
for (const relative of tools) {
  const file = record(path.resolve(import.meta.dirname, relative));
  const copy = path.join(out, 'consumed-tools', path.basename(file)); fs.mkdirSync(path.dirname(copy), {recursive: true}); fs.copyFileSync(file, copy);
}
const report = {kind: 'phase4-private-nullary-experiment', complete: false, source: {file: sourceFile, sha256: sha(sourceFile)}, contract: 'Only trusted data-only private inspect workers may load these images. Nil and Unit are immutable compiler-owned nullary values; their identity is private to the worker.', inputs: [...inputs.values()], variants: []};
for (const optimizeNullary of [false, true]) {
  const id = optimizeNullary ? 'private-nullary' : 'private-control';
  const constants = preparePrivateConstants(source);
  const tags = optimizeNullary ? transformPrivateNullary(constants.source) : null;
  const projection = transformPrivateProjections(tags?.source ?? constants.source);
  const calls = transformPrivateCalls(projection.source, {exports: integration.roots, mode: 'combined'});
  const runtime = transformPrivateRuntime(calls.source);
  assert.ok(runtime.source.includes('// privateImageMarker:'));
  const file = path.join(out, id + '.mjs'); fs.writeFileSync(file, runtime.source);
  report.variants.push({id, file, sha256: sha(file), stats: {tags: tags?.stats, constants: constants.stats, projection: projection.stats, calls: calls.stats, runtime: runtime.stats}});
}
for (const item of inputs.values()) assert.equal(sha(item.file), item.sha256, 'Input drift: ' + item.file);
report.complete = true; fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify({complete: true, variants: report.variants.map(v => ({id: v.id, file: v.file, tags: v.stats.tags}))}));
