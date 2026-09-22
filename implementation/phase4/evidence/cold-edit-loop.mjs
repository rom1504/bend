// One observed cold checked-build + focused-validation loop, not a benchmark median.
// Supply an external deadline and explicit Node stack/heap/CPU settings.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {spawn} from 'node:child_process';
import {pathToFileURL} from 'node:url';

const [configArgument, outputArgument] = process.argv.slice(2);
if (!outputArgument) throw Error('Usage: cold-edit-loop.mjs CONFIG.json NEW_DIRECTORY');
const configFile = fs.realpathSync(configArgument);
const config = JSON.parse(fs.readFileSync(configFile));
const resolve = name => fs.realpathSync(path.resolve(path.dirname(configFile), config[name]));
const out = path.resolve(outputArgument);
fs.mkdirSync(out, {recursive: false});
const started = performance.now();
const sha = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const identity = file => ({file, canonicalPath: fs.realpathSync(file), sha256: sha(file)});
const inputs = [];
const capture = file => { inputs.push(identity(file)); return file; };
const verify = () => {
  for (const before of inputs) assert.deepEqual(identity(before.file), before, 'Input drift: ' + before.file);
};
const report = {
  kind: 'phase4-cold-edit-loop', started: new Date().toISOString(), complete: false,
  scope: 'One fresh checked B1 build followed by 21 live paired acceptance/rejection-phase witnesses in the same process. No existing compiler-side Base cache. This is a workflow observation, not a repeated timing comparison or an exact-diagnostic/full-conformance gate.',
  node: {version: process.version, args: process.execArgv},
  affinity: fs.readFileSync('/proc/self/status', 'utf8').split('\n').find(line => line.startsWith('Cpus_allowed_list:')),
  inputs, phases: [], rows: [],
};
const save = () => fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
async function git(upstream, args, label) {
  const a = fs.openSync(path.join(out, label + '.stdout'), 'wx');
  const b = fs.openSync(path.join(out, label + '.stderr'), 'wx');
  try {
    await new Promise((accept, reject) => {
      const child = spawn('git', ['-C', upstream, ...args], {stdio: ['ignore', a, b]});
      const timer = setTimeout(() => { child.kill('SIGKILL'); reject(Error('Git deadline')); }, 30000);
      child.once('error', error => { clearTimeout(timer); reject(error); });
      child.once('close', code => { clearTimeout(timer); code === 0 ? accept() : reject(Error('Git failed: ' + label)); });
    });
  } finally { fs.closeSync(a); fs.closeSync(b); }
  return fs.readFileSync(path.join(out, label + '.stdout'), 'utf8').trim();
}
async function timed(name, action) {
  const start = performance.now();
  try { return await action(); }
  finally { report.phases.push({name, ms: performance.now() - start}); save(); }
}
try {
  capture(import.meta.filename); capture(configFile); capture(process.execPath);
  fs.copyFileSync(import.meta.filename, path.join(out, 'cold-edit-loop.mjs'));
  capture(path.join(out, 'cold-edit-loop.mjs'));
  const upstream = resolve('upstream'), buildFile = capture(resolve('integrationReport'));
  const checked = JSON.parse(fs.readFileSync(buildFile));
  assert.equal(checked.complete, true);
  let build;
  if (checked.kind === 'phase3-checked-integration-api') {
    build = {api: checked.api, apiSha256: checked.apiSha256, source: checked.source, sourceSha256: checked.sourceSha256, roots: checked.roots, inputs: checked.provenance.inputs};
  } else if (checked.kind === 'phase4-checked-overlay') {
    assert.equal(checked.inputsUnchanged, true);
    build = {api: checked.api.file, apiSha256: checked.api.sha256, source: checked.source.file, sourceSha256: checked.source.sha256, roots: checked.roots, inputs: checked.inputs};
  } else throw Error('Unsupported checked build provenance');
  report.checkedBuild = identity(buildFile);
  report.checkedBuildKind = checked.kind;
  assert.equal(sha(build.api), build.apiSha256); assert.equal(sha(build.source), build.sourceSha256);
  capture(build.api); capture(build.source);
  for (const item of build.inputs) {
    assert.deepEqual(identity(item.file), {file: item.file, canonicalPath: item.canonicalPath, sha256: item.sha256});
    capture(item.file);
  }
  const pin = '6018e28ecc67cf1fffc0c20c64b11023474c2df8';
  assert.equal(await git(upstream, ['rev-parse', 'HEAD'], 'revision'), pin);
  assert.equal(await git(upstream, ['status', '--porcelain', '--untracked-files=no'], 'status'), '');
  report.upstream = {path: upstream, pin};
  for (const name of ['bend.ts', 'comp.ts', 'base.bend']) capture(path.join(upstream, 'bend2', name));
  const source = path.join(out, 'compiler.bend'), apiFile = path.join(out, 'api.mjs');
  fs.copyFileSync(build.source, source); capture(source);
  const runtime = path.join(out, 'runtime.mjs');
  fs.copyFileSync(capture(resolve('runtime')), runtime); capture(runtime);
  const hostDirectory = path.join(out, 'host', 'tools'); fs.mkdirSync(hostDirectory, {recursive: true});
  const driverSource = resolve('driver');
  for (const name of ['typed-driver.mjs', 'compiler-abi.mjs', 'node-resource-args.mjs', 'native-build.mjs', 'assemble.mjs']) {
    const original = name === 'typed-driver.mjs' ? driverSource : path.join(path.dirname(driverSource), name);
    let text = fs.readFileSync(capture(original), 'utf8');
    if (name === 'typed-driver.mjs') {
      const pattern = /export const project=[^;\n]+;/g;
      assert.equal([...text.matchAll(pattern)].length, 1);
      text = text.replace(pattern, 'export const project=' + JSON.stringify(path.dirname(hostDirectory)) + ';');
    }
    const destination = path.join(hostDirectory, name); fs.writeFileSync(destination, text); capture(destination);
  }
  report.source = identity(source); report.roots = build.roots;
  const B = await import(pathToFileURL(path.join(upstream, 'bend2/bend.ts')));
  const C = await import(pathToFileURL(path.join(upstream, 'bend2/comp.ts')));
  await timed('checked-bootstrap', async () => {
    const book = B.book_nil(); await B.book_load(book, source, '', new Map());
    B.book_valid(book); C.book_owned(book, C.SYNTH);
    assert.equal(book.hols + book.open, 0);
    fs.writeFileSync(apiFile, C.js_lib(book, build.roots, build.roots));
  });
  assert.equal(sha(apiFile), build.apiSha256, 'Fresh checked API differs from frozen candidate');
  report.api = identity(capture(apiFile));
  process.env.BEND_TYPED_API = apiFile; process.env.BEND_TYPED_RUNTIME = runtime;
  process.env.BEND_BASE = path.join(upstream, 'bend2/base.bend');
  const host = await import(pathToFileURL(path.join(hostDirectory, 'typed-driver.mjs')));
  const cache = path.join(host.project, 'build/typed/cache');
  assert.equal(fs.existsSync(cache), false, 'Base cache must begin absent');
  report.initialBaseCacheAbsent = true;
  const api = await host.loadApi();
  const casesFile = capture(resolve('cases')), cases = JSON.parse(fs.readFileSync(casesFile));
  assert.equal(cases.length, 21);
  for (const test of cases) capture(path.join(path.dirname(casesFile), test.file));
  await timed('live-paired-targeted-validation', async () => {
    for (const test of cases) {
      const file = path.join(path.dirname(casesFile), test.file);
      let phase = 'parse', reference;
      try {
        const book = B.book_nil(); await B.book_load(book, file, '', new Map()); phase = 'check';
        B.book_valid(book); C.book_owned(book, C.SYNTH); assert.equal(book.hols + book.open, 0);
        reference = {status: 'ok', phase, checked: true};
      } catch (error) {
        reference = {status: 'error', phase, checked: phase === 'check', diagnostic: error?.$ === 'Err' ? B.err_show(error) : String(error)};
      }
      const candidate = await host.inspect(file, {mode: 'check', api});
      const expected = value => test.accept ? value.status === 'ok' : value.status === 'error' && value.phase === test.rejectPhase;
      report.rows.push({id: test.id, file, reference, candidate, passed: expected(reference) && expected(candidate)});
      save();
    }
  });
  report.cacheFiles = fs.readdirSync(cache).map(name => identity(path.join(cache, name)));
  verify(); report.inputsUnchanged = true;
  report.complete = report.rows.length === cases.length && report.rows.every(row => row.passed);
} catch (error) { report.error = error?.stack || String(error); process.exitCode = 1; }
report.totalWallMs = performance.now() - started; report.finished = new Date().toISOString(); save();
console.log(JSON.stringify({complete: report.complete, phases: report.phases, totalWallMs: report.totalWallMs, error: report.error}));
if (!report.complete) process.exitCode = 1;
