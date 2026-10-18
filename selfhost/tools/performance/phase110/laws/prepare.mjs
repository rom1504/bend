#!/usr/bin/env bun
// Data-only preparation. The coordinator alone runs compiler/proof targets.
import {readFileSync, writeFileSync, mkdirSync, existsSync} from 'node:fs';
import {resolve, dirname, relative, sep} from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';

const method = fileURLToPath(import.meta.url), here = dirname(method);
const root = resolve(here, '../../../../..'), options = {};
const args = process.argv.slice(2);
if (args.length !== 4) throw Error('usage: prepare.mjs --out NEW_REPO_DIR --scope selector|reconstruction');
for (let i = 0; i < args.length; i += 2) options[args[i]] = args[i+1];
const scope = options['--scope'], out = resolve(root, options['--out'] ?? '');
if (!['selector','reconstruction'].includes(scope) || !out.startsWith(root + sep) || existsSync(out))
  throw Error('valid scope and fresh repository output directory required');
const hash = bytes => createHash('sha256').update(bytes).digest('hex');
const pin = path => {const bytes = readFileSync(path); return {file: relative(root,path), bytes: bytes.length, sha256: hash(bytes)};};
const helperPath = resolve(here, 'helper.bend'), helper = readFileSync(helperPath, 'utf8');
if (/@unsafe|^law |^import /m.test(helper)) throw Error('helper must be a complete safe import-free source module');
const candidate = 'import Base\n\n' + helper;
const lawPath = resolve(here, scope === 'selector' ? 'selector.bend' : 'laws.bend');
const laws = readFileSync(lawPath, 'utf8');
const policyPath = resolve(here, '../lower/policy.bend');
const policy = readFileSync(policyPath, 'utf8');
const connection = 'nxo_law_select(String,String.eq(keep,a),a,b)';
if (policy.split(connection).length !== 2) throw Error('expected exactly one production candidate selector call');
const cases = [
  {id:'wrong-kept-field', before:'case False{}: NxoLawSelection{1, b, a}', after:'case False{}: NxoLawSelection{1, a, b}', law:'select_second_complete', witness:'keep_second with distinct a and b returns the wrong retained and remaining fields'},
  {id:'wrong-kept-index', before:'case True{}: NxoLawSelection{0, a, b}', after:'case True{}: NxoLawSelection{1, a, b}', law:'select_first_complete', witness:'keep_first emits runtime keep_index 1'},
  {id:'reuse-static-spare', before:'case NxoLawStatic{}: False{}', after:'case NxoLawStatic{}: True{}', law:'allocate_static', witness:'an immortal nonzero static spare is wrongly eligible for overwrite'},
  {id:'reuse-shared-parent', before:'case NxoLawSharedDynamic{}: False{}', after:'case NxoLawSharedDynamic{}: True{}', law:'allocate_shared_dynamic', witness:'an externally retained parent is wrongly eligible for overwrite'},
];
const extras = scope === 'reconstruction' ? ['model.bend', 'reference.bend'] : [];
if (scope === 'reconstruction') cases.push({id:'missing-shared-claim', file:'model.bend', before:'NxoLawHeapChild{value, 1n+aliases}', after:'NxoLawHeapChild{value, aliases}', law:'shared_transfer_claims', witness:'escaping a shared heap child without claiming an owner leaves its count unchanged'});
const texts = Object.fromEntries(extras.map(name => [name, readFileSync(resolve(here,name),'utf8')]));
for (const item of cases) if ((item.file ? texts[item.file] : candidate).split(item.before).length !== 2)
  throw Error('mutation boundary changed: ' + item.id);
mkdirSync(out,{recursive:true});
const files=[];
function write(path,text) {writeFileSync(path,text);files.push(pin(path));}
function packageAt(name,item) {
  const folder=resolve(out,name);mkdirSync(folder);
  write(resolve(folder,'candidate.bend'),item && !item.file ? candidate.replace(item.before,item.after) : candidate);
  write(resolve(folder,'laws.bend'),laws);
  if(scope==='reconstruction') write(resolve(folder,'selector.bend'),readFileSync(resolve(here,'selector.bend'),'utf8'));
  for (const [file,text] of Object.entries(texts)) write(resolve(folder,file),item?.file===file ? text.replace(item.before,item.after) : text);
  return relative(root,folder);
}
const baseline=packageAt('baseline');
for (const item of cases) item.folder=packageAt(item.id,item);
const manifest={schema:'phase110-source-connected-ownership-laws-v1',scope,targetsRun:false,
  method:pin(method),source:[pin(helperPath),pin(policyPath),...extras.map(name=>pin(resolve(here,name)))],
  frozenLaws:pin(lawPath),supportLaws:scope==='reconstruction' ? [pin(resolve(here,'selector.bend'))] : [],baseline,cases,files,
  extraction:{helper:'complete verbatim file',prefix:'import Base',unsafeRemoved:false},
  connection:{file:relative(root,policyPath),text:connection,meaning:'Actual candidate lowering calls this exact helper. This is source correspondence, not a proof of all lowering.'},
  lawCount:[...laws.matchAll(/^law /gm)].length + (scope==='reconstruction' ? [...readFileSync(resolve(here,'selector.bend'),'utf8').matchAll(/^law /gm)].length : 0),
  scopeBoundary:'Safe field selection and abstract ownership transition only. C runtime address/refcount classification, allocation, machine code, concurrency, and whole-compiler correctness are outside the theorem.',
  negativeProtocol:'Admit each changed law-free source before requiring unchanged laws to reject with expected/observed mismatch at the named law. These are source-check negatives; the positive has independent kernel checking.',
  checker:'selfhost/tools/laws/phase98/check.py',outputRestriction:'Fresh output under selfhost/build/phase98/ required.'};
writeFileSync(resolve(out,'manifest.json'),JSON.stringify(manifest,null,2)+'\n');
console.log(JSON.stringify({out:relative(root,out),scope,lawCount:manifest.lawCount,mutations:cases.length,targetsRun:false}));
