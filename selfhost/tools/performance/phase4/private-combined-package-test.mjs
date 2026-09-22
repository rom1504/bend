import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {identity, verifyIdentity, verifyImage} from '../../private-compiler/common.mjs';

const [packageArg, defaultArg, combinedArg, preparedArg, outputArg] = process.argv.slice(2);
if (!outputArg) throw Error('Usage: private-combined-package-test.mjs PACKAGE DEFAULT_IMAGE COMBINED_IMAGE PREPARED_REPORT NEW_DIRECTORY');
const packageDirectory = fs.realpathSync(packageArg), output = path.resolve(outputArg);
fs.mkdirSync(output);
const control = verifyImage(defaultArg), candidate = verifyImage(combinedArg);
const prepared = JSON.parse(fs.readFileSync(preparedArg));
assert.equal(prepared.complete, true); verifyIdentity(prepared.source);
const selected = ['private-control', 'private-combined'].map(id => {
  const matches = prepared.variants.filter(v => v.id === id); assert.equal(matches.length, 1);
  const variant = matches[0], actual = identity(variant.file);
  assert.equal(actual.sha256, variant.sha256, 'Prepared variant changed: ' + id);
  return {id, ...actual};
});
const source = fs.readFileSync(prepared.source.file, 'utf8');
const metadata = JSON.parse(fs.readFileSync(path.join(packageDirectory, 'package.json')));
const inputs = [import.meta.filename, preparedArg, prepared.source.file, path.join(packageDirectory, 'package.json'),
  ...metadata.artifacts.map(a => path.join(packageDirectory, a.name)), ...selected.map(v => v.file), control.manifestIdentity.file, candidate.manifestIdentity.file].map(identity);
for (const artifact of metadata.artifacts) verifyIdentity(artifact);
const profiles = await import(pathToFileURL(path.join(packageDirectory, 'profiles.mjs')));
const checks = [];
function check(name, run) { run(); checks.push({name, passed: true}); }
check('completed checked proof retained', () => {
  assert.equal(control.manifest.proofStatus, 'fixedpoint'); assert.equal(candidate.manifest.proofStatus, 'fixedpoint');
});
check('default image byte-identical to corrected matrix control', () => {
  assert.deepEqual(fs.readFileSync(path.join(control.root, 'image.mjs')), fs.readFileSync(selected.find(v => v.id === 'private-control').file));
  assert.equal(control.manifest.optimizationProfile, 'default');
});
check('named image byte-identical to measured corrected combination', () => {
  assert.deepEqual(fs.readFileSync(path.join(candidate.root, 'image.mjs')), fs.readFileSync(selected.find(v => v.id === 'private-combined').file));
  assert.equal(candidate.manifest.optimizationProfile, 'phase4-boolean-stable');
});
check('exact reviewed H and body guards are recorded', () => {
  assert.equal(candidate.manifest.stats.optimizationProfile.reviewedH, prepared.source.sha256);
  assert.equal(Object.keys(candidate.manifest.stats.booleans.reviewed).length, 2);
  assert.equal(Object.keys(candidate.manifest.stats.stabilityMemo.reviewedWorkers).length, 6);
});
check('unknown profile refused', () => assert.throws(() => profiles.specializeProfile(source, candidate.manifest.exports, 'unknown'), /Unknown private optimization profile/));
check('changed H refused even when its body text is equivalent', () => assert.throws(() => profiles.specializeProfile(source + '\n', candidate.manifest.exports, 'phase4-boolean-stable'), /Unreviewed compiler image/));
check('all profile modules are captured as consumed tools and runtime artifacts', () => {
  for (const name of ['profiles.mjs', 'profile-booleans.mjs', 'profile-stability.mjs', 'profile-combined.mjs']) {
    assert.ok(candidate.manifest.tools.some(t => path.basename(t.file) === name));
    assert.ok(candidate.manifest.artifacts.some(a => a.relative === 'runner/' + name));
  }
});
inputs.forEach(verifyIdentity); verifyImage(control.root); verifyImage(candidate.root);
fs.writeFileSync(path.join(output, 'report.json'), JSON.stringify({kind: 'phase4-private-profile-package-gate', complete: true,
  scope: 'Builder/profile provenance and fail-closed identity checks; graph/Boolean observations come from the byte-identical prepared image, broad/full gates are separate.',
  inputs, checks, images: {control: identity(path.join(control.root, 'image.mjs')), candidate: identity(path.join(candidate.root, 'image.mjs'))}}, null, 2) + '\n');
console.log(JSON.stringify({complete: true, checks: checks.length}));
