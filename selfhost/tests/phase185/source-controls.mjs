#!/usr/bin/env bun
// Ordinary source controls only. The checked Bend API owns all source/compiler
// work; maintained native.py owns machine construction and runtime observation.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';
import {spawnSync} from 'node:child_process';
import {pin, verify, requireThat as need, workspace} from '../../tools/build/hosted.mjs';

const args = {}, allowed = ['--api', '--binding', '--assets', '--python', '--out', '--seconds'];
for (let i = 2; i < process.argv.length; ++i) {
  const key = process.argv[i];
  need(!Object.hasOwn(args, key), 'Duplicate option: ' + key);
  if (key === '--guarded') args[key] = true;
  else {
    need(allowed.includes(key) && process.argv[i + 1], 'Unknown or incomplete option: ' + key);
    args[key] = process.argv[++i];
  }
}
for (const key of ['--api', '--binding', '--out', '--seconds']) need(args[key], 'Required option: ' + key);
const seconds = Number(args['--seconds']), started = performance.now();
need(Number.isFinite(seconds) && seconds > 2 && seconds <= 900, 'Bounded 2..900 second deadline required');
need(args['--guarded'] && /^Cpus_allowed_list:\s*3\s*$/m.test(fs.readFileSync('/proc/self/status', 'utf8')),
  'One outer guarded CPU3 lane required');
for (const key of ['LD_PRELOAD', 'LD_AUDIT', 'BENDRTS', 'BEND_SAMPLE_OUT', 'BEND_SAMPLE_CONTEXT_OUT',
  'BEND_PROFILE_EVENTS_OUT', 'BEND_PROFILE_COUNTERS']) need(process.env[key] === undefined, 'Unset ambient ' + key);
const out = path.resolve(args['--out']);
need(out.startsWith(workspace + '/selfhost/build/') && !fs.existsSync(out), 'Fresh selfhost/build output required');
let ancestor = path.dirname(out);
while (!fs.existsSync(ancestor)) ancestor = path.dirname(ancestor);
need(fs.realpathSync(ancestor) === ancestor, 'Output must not traverse symlinks');
fs.mkdirSync(out, {recursive: true});
const read = file => JSON.parse(fs.readFileSync(file, 'utf8'));
const same = (a, b) => a?.file === b?.file && a?.bytes === b?.bytes && a?.sha256 === b?.sha256;
const report = {kind: 'phase185-ordinary-source-controls', version: 1, complete: false,
  inputs: [], artifacts: [], rows: [], jobs: [], targets: ['qbe', 'x86'], cpu: 3, guarded: true,
  secondsLimit: seconds, expectedObservations: 8,
  scope: 'Four ordinary checked source fixtures, both native backends, current runtime ABI and exact independent full outputs. Separate from native45 benchmarks, compiler-image qualification, self-hosting and installed selection.'};
const save = () => {
  report.seconds = (performance.now() - started) / 1000;
  fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
};
const add = entry => {
  const prior = report.inputs.find(item => item.file === entry.file);
  need(!prior || same(prior, entry), 'Conflicting input identity: ' + entry.file);
  if (!prior) report.inputs.push(entry);
  return entry;
};
const left = () => {
  const remaining = seconds - (performance.now() - started) / 1000;
  need(remaining > 0, 'Whole source-control deadline exceeded'); return remaining;
};
const write = (file, text) => {
  need(typeof text === 'string' && Buffer.byteLength(text) <= 128 * 1024 * 1024, 'Bounded output required');
  fs.writeFileSync(file, text, {flag: 'wx'});
  const item = pin(file); report.artifacts.push(item); return item;
};
function strings(xs, bound = 1000000) {
  const result = []; let bytes = 0;
  while (xs?.$ === 'Con') {
    need(result.length < bound && typeof xs.head === 'string', 'Bounded string list required');
    bytes += Buffer.byteLength(xs.head); need(bytes <= 128 * 1024 * 1024, 'Emission exceeds byte bound');
    result.push(xs.head); xs = xs.tail;
  }
  need(xs?.$ === 'Nil', 'Proper emitted list required'); return result;
}
function qbeText(api, prepared) {
  const chunks = strings(prepared.forwarders).map(text => text + '\n');
  let cursor = prepared.cursor, bytes = Buffer.byteLength(chunks.join(''));
  for (let count = 0; ; ++count) {
    need(count < 1000000, 'QBE cursor exceeds piece bound'); left();
    const piece = api.p134e_next(cursor);
    if (piece?.$ === 'P134Done') break;
    need(piece?.$ === 'P134Piece' && typeof piece.text === 'string' && typeof piece.legacy_end === 'boolean', 'Malformed QBE cursor');
    const text = piece.text + (piece.legacy_end ? '\n' : '');
    bytes += Buffer.byteLength(text); need(bytes <= 128 * 1024 * 1024, 'QBE exceeds byte bound');
    chunks.push(text); cursor = piece.next;
  }
  return chunks.join('');
}
const fixtures = [
  {id: 'bool-inputs', expected: '10\n'},
  {id: 'fact-f32-inputs', expected: '[14, 50, 41, 41, 2, 2, 2, 50, 14, 41]\n'},
  {id: 'cold-ctor-inputs', expected: '[2080, 4160, 6240, 8320, 16640]\n'},
  {id: 'packed-take-inputs', expected: '[0n, 1n, 4294967296n, 1099511627775n, 1099511627776n, 281474976710655n, 2199023255552n, 2199023255550n]\n'},
];
save();
try {
  const apiReceipt = add(pin(args['--api'])), authority = read(apiReceipt.file);
  const bindingPin = add(pin(args['--binding'])), binding = read(bindingPin.file);
  const assetPin = add(pin(args['--assets'] ?? path.join(workspace, 'selfhost/manifests/assets-native.json')));
  const assets = read(assetPin.file), python = add(pin(args['--python'] ?? '/usr/bin/python3'));
  add(pin(fileURLToPath(import.meta.url))); add(pin(process.execPath));
  for (const name of ['hosted.mjs', 'native.py', 'request.py', 'common.py', 'assets.py']) add(pin(path.join(workspace, 'selfhost/tools/build', name)));
  need(authority.kind === 'bend-checked-hosted-api' && authority.complete === true && authority.checked === true && !authority.error,
    'Complete checked B1 API receipt required');
  need(assets.kind === 'bend-build-assets' && assets.complete === true && authority.upstream?.revision === assets.upstream,
    'Current assets and checked API upstream differ');
  need(Array.isArray(authority.inputs) && Array.isArray(authority.exports), 'API authority inventories required');
  add(authority.source); add(authority.api); authority.inputs.forEach(add);
  add(binding.base); add(binding.carrier);
  need(typeof binding.stamp === 'string' && binding.stamp.length > 0, 'Prepared Base stamp required');
  const asset = key => {
    const expected = assets.assets?.[key]; need(expected, 'Missing current asset: ' + key);
    const actual = pin(path.resolve(workspace, expected.file));
    need(actual.bytes === expected.bytes && actual.sha256 === expected.sha256, 'Current asset differs: ' + key);
    return add(actual);
  };
  const runtime = asset('qbe-runtime'), engine = asset('bun'), base = asset('base');
  need(same(engine, pin(process.execPath)), 'Pinned Bun engine required');
  need(same(base, binding.base) && same(assetPin, binding.assets), 'Prepared Base binding differs from current assets');
  const policy = assets.runtimePolicies?.['qbe-runtime'];
  need(policy?.runtimeABI === 11102 && policy.runtimeArgumentConvention === 'bend-rts-v1', 'Current runtime ABI11102 required');
  report.authority = {receipt: apiReceipt, source: authority.source, api: authority.api, upstream: authority.upstream};
  report.runtime = runtime; report.runtimeABI = 11102; report.baseBinding = bindingPin;
  for (const fixture of fixtures) {
    fixture.source = add(pin(path.join(workspace, 'selfhost/tests/phase185', fixture.id + '.bend')));
    fixture.text = fs.readFileSync(fixture.source.file, 'utf8');
    const golden = [...fixture.text.matchAll(/^#\|(.*)$/gm)].map(match => match[1] + '\n').join('');
    need(golden === fixture.expected, 'Fixture golden differs from independent literal: ' + fixture.id);
  }
  report.inputs.forEach(verify); left();
  const api = (await import(pathToFileURL(authority.api.file))).default;
  for (const name of ['p88_cache_prepare', 'p86_plan', 'p169np_plan', 'p134e_next', 'x181_prepared'])
    need(authority.exports.includes(name) && typeof api[name] === 'function', 'Missing checked export: ' + name);
  const prep = api.p88_cache_prepare(binding.base.file, fs.readFileSync(binding.base.file, 'utf8'),
    fs.readFileSync(binding.carrier.file, 'utf8'), binding.stamp);
  need(prep?.$ === 'P86PreparationReady', prep?.error ?? 'Prepared Base refused');
  for (const fixture of fixtures) for (const target of report.targets) {
    left();
    const directory = path.join(out, fixture.id + '-' + target); fs.mkdirSync(directory);
    const row = {id: fixture.id, target, source: fixture.source, complete: false}; report.rows.push(row); save();
    const plan = api.p86_plan(prep.seed, fixture.source.file, fixture.text);
    need(plan?.$ === 'P86PlanReady', plan?.error ?? 'Source refused: ' + fixture.id);
    const prepared = api.p169np_plan(plan);
    need(prepared?.$ === 'P169Prepared' && prepared.error === '', prepared?.error ?? 'Verified native preparation refused');
    let text;
    if (target === 'qbe') text = qbeText(api, prepared);
    else {
      const result = api.x181_prepared(prepared);
      need(result?.$ === 'X181Output' && result.error === '', result?.error ?? 'x86 emission refused');
      text = strings(result.chunks).join('');
    }
    need(text.length > 0, 'Empty emitted program');
    row.product = write(path.join(directory, target === 'qbe' ? 'program.ssa' : 'program.s'), text);
    row.expected = write(path.join(directory, 'expected.stdout'), fixture.expected); row.verified = true; save();
    const childSeconds = Math.min(30, left() - 2); need(childSeconds > 0, 'Insufficient machine-check deadline');
    const machine = path.join(directory, 'machine');
    const command = [python.file, '-B', path.join(workspace, 'selfhost/tools/build/native.py'),
      '--assets', assetPin.file, '--target', target, '--ir', row.product.file,
      '--runtime-key', 'qbe-runtime', '--retain-ir', '--expected-stdout', row.expected.file,
      '--out', machine, '--seconds', String(childSeconds)];
    const stdout = path.join(directory, 'native.stdout'), stderr = path.join(directory, 'native.stderr');
    const so = fs.openSync(stdout, 'wx'), se = fs.openSync(stderr, 'wx');
    let child;
    try { child = spawnSync(command[0], command.slice(1), {cwd: workspace, stdio: ['ignore', so, se], timeout: Math.ceil((childSeconds + 2) * 1000)}); }
    finally { fs.closeSync(so); fs.closeSync(se); }
    const job = {id: fixture.id, target, command, status: child.status, signal: child.signal,
      error: child.error?.message ?? null, stdout: pin(stdout), stderr: pin(stderr)};
    report.jobs.push(job);
    const receipt = path.join(machine, 'report.json');
    if (fs.existsSync(receipt)) row.buildReceipt = pin(receipt);
    save();
    need(child.status === 0 && !child.signal && !child.error && row.buildReceipt, 'Maintained native check failed: ' + fixture.id + '/' + target);
    const built = read(receipt);
    need(built.kind === 'bend-native-build' && built.complete === true && built.outputExact === true &&
      !built.changedInputs?.length && built.target === target && built.runtimeABI === 11102 &&
      built.runtimeArgumentConvention === 'bend-rts-v1' && same(built.runtime, runtime) &&
      same(built.expectedStdout, row.expected) && same(target === 'qbe' ? built.sourceIR : built.sourceAssembly, row.product),
      'Native receipt source/runtime/output binding differs');
    built.inputs.forEach(add); add(row.buildReceipt); verify(built.binary);
    row.binary = built.binary; row.exactOutput = true; row.complete = true; save();
  }
  need(report.rows.length === report.expectedObservations && report.rows.every(row => row.complete), 'Missing ordinary source observations');
  report.complete = true;
} catch (error) { report.error = String(error.stack ?? error); }
report.changedInputs = [];
for (const input of report.inputs) {
  try { verify(input); } catch { report.changedInputs.push(input.file); }
}
if (report.changedInputs.length) report.complete = false;
save();
console.log(JSON.stringify({complete: report.complete, observations: report.rows.filter(row => row.complete).length, error: report.error}));
if (!report.complete) process.exitCode = 1;
