// Prepare an isolated, explicitly opt-in candidate builder. Canonical tools are
// copied, never edited; genuine checked-proof validation remains intact.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {identity, verifyIdentity} from '../../private-compiler/common.mjs';

const [outputArgument] = process.argv.slice(2);
if (!outputArgument || process.argv.length !== 3)
  throw Error('Usage: private-combined-package.mjs NEW_PACKAGE_DIRECTORY');
const output = path.resolve(outputArgument), canonical = path.resolve(import.meta.dirname, '../../private-compiler');
fs.mkdirSync(output, {recursive: false});
const sources = fs.readdirSync(canonical).filter(name => name.endsWith('.mjs') && !name.endsWith('.test.mjs'));
const inputs = [identity(import.meta.filename), ...sources.map(name => identity(path.join(canonical, name)))];
const transformations = [];
for (const name of sources) fs.copyFileSync(path.join(canonical, name), path.join(output, name));
for (const [original, name] of [
  ['private-booleans.mjs', 'profile-booleans.mjs'],
  ['private-stable-memo.mjs', 'profile-stability.mjs'],
  ['private-combined-transform.mjs', 'profile-combined.mjs'],
]) {
  const input = identity(path.join(import.meta.dirname, original)); inputs.push(input);
  const source = fs.readFileSync(input.file, 'utf8')
    .replaceAll('../../private-compiler/', './')
    .replaceAll('./private-booleans.mjs', './profile-booleans.mjs')
    .replaceAll('./private-stable-memo.mjs', './profile-stability.mjs');
  fs.writeFileSync(path.join(output, name), source, {flag: 'wx'});
  transformations.push({input, output: name, onlyChange: 'relative imports into isolated copied package'});
}
const reviewedH = 'b33b38e32a263bf78e1d43cf459b7abf9a41d78d112d71a25f87ddba7bd09bf8';
fs.writeFileSync(path.join(output, 'profiles.mjs'), `
import {digest} from './common.mjs';
import {specializeCompiler} from './transform.mjs';
import {privateCombined} from './profile-combined.mjs';
export const reviewedProfileH=${JSON.stringify(reviewedH)};
export function specializeProfile(source,exports,profile='default') {
  if(profile==='default')return specializeCompiler(source,exports);
  if(profile!=='phase4-boolean-stable')throw Error('Unknown private optimization profile: '+profile);
  if(digest(source)!==reviewedProfileH)throw Error('Unreviewed compiler image for phase4-boolean-stable; use default or re-audit the exact source');
  const result=privateCombined(source,exports);
  return {...result,stats:{...result.stats,optimizationProfile:{name:profile,reviewedH:reviewedProfileH,scope:'Experimental private immutable image only; whole-source and broad gates must be recorded separately.'}}};
}
`, {flag: 'wx'});
let builder = fs.readFileSync(path.join(output, 'build.mjs'), 'utf8');
const replace = (before, after) => {
  assert.equal(builder.split(before).length, 2, 'Unexpected canonical builder shape: ' + before);
  builder = builder.replace(before, after);
};
replace("import {specializeCompiler} from './transform.mjs';", "import {specializeProfile} from './profiles.mjs';");
replace('output,experimental=false})', "output,experimental=false,optimizationProfile='default'})");
replace('specializeCompiler(original,exports)', 'specializeProfile(original,exports,optimizationProfile)');
replace('exports,stats:transformed.stats,inputs:', 'exports,optimizationProfile,stats:transformed.stats,inputs:');
replace("const args=process.argv.slice(2),experimental=args.includes('--experimental');", "const args=process.argv.slice(2),experimental=args.includes('--experimental');\n const profileFlags=args.filter(x=>x.startsWith('--profile='));if(profileFlags.length>1)throw Error('Repeated profile option');\n const optimizationProfile=profileFlags[0]?.slice(10)??'default';");
replace("x.startsWith('--')&&x!=='--experimental'", "x.startsWith('--')&&x!=='--experimental'&&!x.startsWith('--profile=')");
replace('NEW_IMAGE_DIRECTORY [--experimental]', 'NEW_IMAGE_DIRECTORY [--experimental] [--profile=default|phase4-boolean-stable]');
replace('output:positional[3],experimental}', 'output:positional[3],experimental,optimizationProfile}');
fs.writeFileSync(path.join(output, 'build.mjs'), builder);
inputs.forEach(verifyIdentity);
const artifacts = fs.readdirSync(output).map(name => ({name, ...identity(path.join(output, name))}));
fs.writeFileSync(path.join(output, 'package.json'), JSON.stringify({
  kind: 'phase4-isolated-private-profile-package', complete: true,
  default: 'unchanged canonical specialization', candidate: 'phase4-boolean-stable',
  reviewedH, inputs, transformations, artifacts,
  scope: 'Disposable candidate builder, not canonical promotion. Both profiles retain genuine checked-proof validation. Candidate additionally requires exact reviewed H plus Boolean/stability/runtime guards.',
}, null, 2) + '\n', {flag: 'wx'});
console.log(JSON.stringify({complete: true, output, candidate: 'phase4-boolean-stable', reviewedH}));
