// Checked, isolated Phase 4 source experiments. No production source mutation.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {spawn} from 'node:child_process';
import {pathToFileURL} from 'node:url';

const [configArgument, outputArgument] = process.argv.slice(2);
if (!outputArgument) throw Error('Usage: checked-overlay.mjs CONFIG.json NEW_DIRECTORY');
const configFile = fs.realpathSync(configArgument);
const config = JSON.parse(fs.readFileSync(configFile));
const resolve = file => fs.realpathSync(path.resolve(path.dirname(configFile), file));
const out = path.resolve(outputArgument);
fs.mkdirSync(out, {recursive: false});
const sha = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const identity = file => ({file: path.resolve(file), canonicalPath: fs.realpathSync(file), sha256: sha(file)});
const inputs = new Map();
const capture = file => { const item = identity(file); inputs.set(item.file, item); return item.file; };
const verify = () => { for (const item of inputs.values()) assert.deepEqual(identity(item.file), item, 'Build input changed: ' + item.file); };
const report = {kind: 'phase4-checked-overlay', complete: false, started: new Date().toISOString(), node: {path: process.execPath, version: process.version, args: process.execArgv}, phases: [], modules: []};
const flush = () => fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify({...report, inputs: [...inputs.values()]}, null, 2) + '\n');
async function timed(name, action) {
  const start = performance.now();
  try { return await action(); }
  finally { report.phases.push({name, ms: performance.now() - start}); flush(); }
}
async function git(upstream, args, label) {
  const stdout = path.join(out, label + '.stdout'), stderr = path.join(out, label + '.stderr');
  const a = fs.openSync(stdout, 'wx'), b = fs.openSync(stderr, 'wx');
  try {
    await new Promise((accept, reject) => {
      const child = spawn('git', ['-C', upstream, ...args], {stdio: ['ignore', a, b]});
      const timer = setTimeout(() => { child.kill('SIGKILL'); reject(Error('Git deadline: ' + label)); }, 30000);
      child.once('error', error => { clearTimeout(timer); reject(error); });
      child.once('close', (code, signal) => { clearTimeout(timer); code === 0 && !signal ? accept() : reject(Error('Git failed: ' + label)); });
    });
  } finally { fs.closeSync(a); fs.closeSync(b); }
  return fs.readFileSync(stdout, 'utf8').trim();
}
flush();
try {
  capture(import.meta.filename); capture(configFile); capture(process.execPath);
  const baseline = resolve(config.baseline), overlay = config.overlay ? resolve(config.overlay) : null;
  const frozenFile = capture(path.join(baseline, 'manifest.json'));
  const frozen = JSON.parse(fs.readFileSync(frozenFile));
  assert.equal(frozen.kind, 'phase4-frozen-baseline');
  for (const [relative, item] of Object.entries(frozen.files)) {
    const file = capture(path.join(baseline, relative));
    assert.equal(sha(file), item.sha256, 'Frozen baseline drift: ' + relative);
  }
  const manifestFile = capture(path.join(baseline, 'src/compiler.json'));
  const manifest = JSON.parse(fs.readFileSync(manifestFile));
  const upstream = resolve(config.upstream);
  assert.equal(await git(upstream, ['rev-parse', 'HEAD'], 'revision-before'), manifest.upstream);
  assert.equal(await git(upstream, ['status', '--porcelain', '--untracked-files=no'], 'status-before'), '');
  report.upstream = {path: upstream, pin: manifest.upstream};
  for (const name of ['bend.ts', 'comp.ts', 'base.bend']) capture(path.join(upstream, 'bend2', name));
  for (const relative of manifest.modules) {
    const candidate = overlay && path.join(overlay, relative);
    const original = candidate && fs.existsSync(candidate) ? candidate : path.join(baseline, relative);
    capture(original);
    const destination = path.join(out, 'sources', relative);
    fs.mkdirSync(path.dirname(destination), {recursive: true}); fs.copyFileSync(original, destination); capture(destination);
    report.modules.push({relative, original, destination, sha256: sha(destination), overridden: original === candidate});
  }
  const {assemble} = await import(pathToFileURL(path.join(baseline, 'tools/assemble.mjs')));
  const source = path.join(out, 'compiler.bend'), api = path.join(out, 'api.mjs');
  await timed('assemble', () => assemble(manifest.modules, source, {root: path.join(out, 'sources')}));
  capture(source); capture(source + '.map.json');
  report.source = identity(source);
  const {default: previous} = await import(pathToFileURL(path.join(baseline, 'api/b1.mjs')));
  const roots = [...new Set([...Object.keys(previous), ...(config.extraRoots ?? [])])];
  assert.ok(roots.every(name => typeof name === 'string' && name.length)); report.roots = roots;
  const B = await import(pathToFileURL(path.join(upstream, 'bend2/bend.ts')));
  const C = await import(pathToFileURL(path.join(upstream, 'bend2/comp.ts')));
  const book = B.book_nil();
  await timed('load', () => B.book_load(book, source, '', new Map()));
  await timed('check-owned-and-closed', () => { B.book_valid(book); C.book_owned(book, C.SYNTH); assert.equal(book.hols + book.open, 0, 'Unresolved laws or holes'); });
  await timed('emit', () => fs.writeFileSync(api, C.js_lib(book, roots, roots)));
  report.api = identity(api);
  verify();
  assert.equal(await git(upstream, ['rev-parse', 'HEAD'], 'revision-after'), manifest.upstream);
  assert.equal(await git(upstream, ['status', '--porcelain', '--untracked-files=no'], 'status-after'), '');
  report.inputsUnchanged = true; report.complete = true;
} catch (error) { report.error = error?.stack || String(error); process.exitCode = 1; }
report.finished = new Date().toISOString(); flush();
console.log(JSON.stringify({complete: report.complete, api: report.api, phases: report.phases, error: report.error}));
