#!/usr/bin/env bun
// Transport only: use the actual checked native entry and fully drain its cursor.
// This command emits QBE but never assembles, links, or runs a generated program.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';
import {pin, verify, requireThat as need, workspace} from '../../tools/build/hosted.mjs';
import {runtimeArgumentConvention, runtimeArguments} from '../../tools/runtime-arguments.mjs';

const own = fileURLToPath(import.meta.url);
const revision = '9a4223d577ba56a0cb53d1fd952d2b481c38930f';
const roots = ['p86_prepare', 'p86_plan', 'p169np_plan', 'p134e_next'];
const read = file => JSON.parse(fs.readFileSync(file, 'utf8'));
const args = {};
for (let i = 2; i < process.argv.length; i += 2) {
  const key = process.argv[i], value = process.argv[i + 1];
  need(['--api', '--source', '--assets', '--out'].includes(key) && value && !Object.hasOwn(args, key), 'Unknown, duplicate, or incomplete option: ' + key);
  args[key] = value;
}
for (const key of ['--api', '--source', '--assets', '--out']) need(args[key], 'Missing ' + key);
need(!process.env.BENDRTS, 'Ambient BENDRTS is not part of this control');
const out = path.resolve(args['--out']);
need(out.startsWith(workspace + '/selfhost/build/') && !fs.existsSync(out), 'Fresh selfhost/build output required');
fs.mkdirSync(out, {recursive: true});
const report = {kind: 'phase182-early-native-entry-controls', version: 1, complete: false, pass: false,
  upstream: revision, inputs: [], rows: [], generatedProgramsExecuted: false, kernelChecked: false,
  scope: 'One live checked Base preparation; actual p86_plan -> p169np_plan for three positive IO sources and one unknown foreign source. Successful P169Prepared values pass unchanged source/original/private/borrowed/direct verification in Bend, then every forwarder and cursor piece is rendered. Admission and complete QBE emission only; literal runtime oracles are retained for a separate native gate, not claimed as observed.'};
const started = performance.now();
const save = () => { report.seconds = (performance.now() - started) / 1000; fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n'); };
save();
try {
  const receiptFile = pin(args['--api']), receipt = read(receiptFile.file), binding = receipt.imageBinding;
  const source = pin(args['--source']);
  need(receipt.kind === 'bend-checked-hosted-api' && receipt.version === 1 && receipt.complete === true && receipt.checked === true && receipt.status === 0, 'Completed checked acquisition required');
  need(binding?.kind === 'bend-build-image-binding' && binding.version === 1 && binding.complete === true && binding.checked === true && binding.host === 'js' && binding.stage === 'B1', 'Checked B1 binding required');
  need(binding.image?.sha256 === receipt.api?.sha256 && binding.image?.bytes === receipt.api?.bytes && binding.sourceIdentity?.sha256 === source.sha256 && binding.sourceIdentity?.bytes === source.bytes && receipt.source?.sha256 === source.sha256 && receipt.source?.bytes === source.bytes, 'API/canonical source binding differs');
  need(receipt.upstream?.revision === revision && roots.every(name => receipt.exports?.includes(name) && binding.exports?.includes(name)), 'Wrong upstream or missing early-entry roots');
  [receipt.api, receipt.source, binding.image, binding.sourceIdentity, ...receipt.inputs].forEach(verify);
  const assetsFile = pin(args['--assets']), assets = read(assetsFile.file);
  need(assets.kind === 'bend-build-assets' && assets.version === 1 && assets.complete === true && assets.upstream === revision, 'Complete current assets required');
  const asset = key => {
    const row = assets.assets?.[key];
    need(row && typeof row.file === 'string', 'Missing asset: ' + key);
    const bound = {...row, file: path.resolve(workspace, row.file)};
    verify(bound);
    return pin(bound.file);
  };
  const base = asset('base'), engine = asset('bun'), runtime = asset('qbe-runtime');
  need(pin(process.execPath).sha256 === engine.sha256 && pin(process.execPath).bytes === engine.bytes, 'Run with the pinned Bun engine');
  need(receipt.inputs.some(row => row.file === engine.file && row.sha256 === engine.sha256 && row.bytes === engine.bytes), 'Engine differs from checked acquisition');
  const acquiredBase = pin(path.join(receipt.upstream.file, 'bend2/base.bend'));
  need(acquiredBase.sha256 === base.sha256 && acquiredBase.bytes === base.bytes && receipt.inputs.some(row => row.file === acquiredBase.file && row.sha256 === base.sha256 && row.bytes === base.bytes), 'Base differs from checked acquisition');
  const runtimeAsset = assets.assets['qbe-runtime'], runtimePolicy = assets.runtimePolicies?.['qbe-runtime'];
  if (runtimeAsset.runtimeArgumentConvention && runtimePolicy?.runtimeArgumentConvention)
    need(runtimeAsset.runtimeArgumentConvention === runtimePolicy.runtimeArgumentConvention, 'Conflicting runtime argument convention');
  const runtimeProvider = runtimeAsset.runtimeArgumentConvention ? runtimeAsset : runtimePolicy ?? runtimeAsset;
  need(runtimeArgumentConvention(runtimeProvider) === 'bend-rts-v1', 'Current runtime convention required');
  report.runtime = runtime;
  report.runtimeArgumentConvention = runtimeArgumentConvention(runtimeProvider);
  report.runtimeArguments = runtimeArguments(runtimeProvider);
  report.acquisition = receiptFile;
  report.source = source;
  report.base = base;
  const positive = [
    {name: 'argv', expected: {stdout: 'True 0\nTrue 0\n', stderr: '', exitCode: 0}},
    {name: 'files', expected: {stdout: '"ab\\n"\n"cd"\n"Zb\\ncd"\n', stderr: '', exitCode: 0}},
    {name: 'open-errors', expected: {stdout: '22\n84\n', stderr: '', exitCode: 0}},
  ].map(row => ({...row, source: pin(path.join(path.dirname(own), 'native', row.name + '.bend'))}));
  for (const row of positive) {
    const markers = fs.readFileSync(row.source.file, 'utf8').split('\n').filter(line => line.startsWith('#|')).map(line => line.slice(2));
    need(markers.join('\n') + '\n' === row.expected.stdout, 'Independent literal oracle differs from fixture markers: ' + row.name);
  }
  const negative = {name: 'unknown-foreign', source: pin(path.join(workspace, 'selfhost/tests/consolidation/native-focused/negative-foreign.bend')),
    expected: {diagnostic: 'compile: foreign provider unavailable in fixed runtime: p108_missing', forwarders: 0, cursor: 'P134End'}};
  need(negative.source.sha256 === '19a5b3686b07e311f3291e0c26a6308a76d4930f869d7f6a70249c94365ba11c' && negative.source.bytes === 260, 'Historical negative foreign fixture changed');
  const cases = [...positive, negative];
  const inputs = [pin(own), pin(path.join(workspace, 'selfhost/tools/build/hosted.mjs')),
    pin(path.join(workspace, 'selfhost/tools/bootstrap-config.mjs')), pin(path.join(workspace, 'selfhost/tools/runtime-arguments.mjs')),
    receiptFile, source, receipt.api, binding.image, binding.sourceIdentity, assetsFile, base, engine, runtime, ...receipt.inputs, ...cases.map(row => row.source)];
  const unique = new Map();
  for (const row of inputs) {
    const previous = unique.get(row.file);
    need(!previous || (previous.sha256 === row.sha256 && previous.bytes === row.bytes), 'Conflicting input pin: ' + row.file);
    unique.set(row.file, row);
  }
  report.inputs = [...unique.values()];
  report.inputs.forEach(verify);
  save();
  for (const key of Object.keys(process.env)) if (key.startsWith('BEND_')) delete process.env[key];
  const api = (await import(pathToFileURL(receipt.api.file))).default;
  need(roots.every(name => typeof api?.[name] === 'function'), 'Missing API functions');
  report.active = 'live-base'; save();
  const baseStarted = performance.now();
  const preparedBase = api.p86_prepare(base.file, fs.readFileSync(base.file, 'utf8'));
  report.basePreparation = {tag: preparedBase?.$, error: preparedBase?.error ?? '', seconds: (performance.now() - baseStarted) / 1000};
  need(preparedBase?.$ === 'P86PreparationReady', preparedBase?.error ?? 'Base preparation refused');
  for (const entry of cases) {
    report.active = entry.name; save();
    const begin = performance.now(), row = {...entry, complete: false, pass: false};
    report.rows.push(row); save();
    try {
      const plan = api.p86_plan(preparedBase.seed, entry.source.file, fs.readFileSync(entry.source.file, 'utf8'));
      row.plan = {tag: plan?.$, error: plan?.error ?? '', verdict: plan?.verdict ?? ''};
      need(plan?.$ === 'P86PlanReady', plan?.error ?? 'Source did not reach backend admission');
      const prepared = api.p169np_plan(plan);
      row.prepared = {tag: prepared?.$, error: prepared?.error, cursor: prepared?.cursor?.$};
      need(prepared?.$ === 'P169Prepared' && typeof prepared.error === 'string', 'Malformed native preparation');
      if (entry.name === 'unknown-foreign') {
        need(prepared.error === entry.expected.diagnostic && prepared.forwarders?.$ === 'Nil' && prepared.cursor?.$ === 'P134End', 'Expected exact native foreign refusal and empty output');
        row.outputAbsent = true;
      } else {
        need(prepared.error === '', prepared.error);
        const folder = path.join(out, entry.name);
        fs.mkdirSync(folder);
        const product = path.join(folder, 'program.ssa'), fd = fs.openSync(product, 'wx');
        let bytes = 0, forwarders = 0, pieces = 0;
        const write = text => {
          need(typeof text === 'string', 'Malformed compiler text');
          bytes += Buffer.byteLength(text);
          need(bytes <= 32 * 1024 ** 2, 'QBE product exceeds finite 32 MiB bound');
          need(fs.writeSync(fd, text) === Buffer.byteLength(text), 'Incomplete QBE file write');
        };
        try {
          let list = prepared.forwarders;
          while (list?.$ === 'Con') {
            need(++forwarders <= 100000, 'Forwarder list exceeds finite bound');
            write(list.head); write('\n'); list = list.tail;
          }
          need(list?.$ === 'Nil', 'Malformed forwarder list');
          let cursor = prepared.cursor;
          while (true) {
            const step = api.p134e_next(cursor);
            if (step?.$ === 'P134Done') break;
            need(step?.$ === 'P134Piece' && typeof step.legacy_end === 'boolean' && ++pieces <= 100000, 'Malformed or unbounded emission cursor');
            write(step.text); if (step.legacy_end) write('\n'); cursor = step.next;
          }
          need(bytes > 0 && pieces > 0, 'Empty successful emission');
        } finally { fs.closeSync(fd); }
        row.emission = {product: pin(product), forwarders, pieces, bytes, fullyDrained: true};
        fs.writeFileSync(path.join(folder, 'expected.stdout'), entry.expected.stdout);
        fs.writeFileSync(path.join(folder, 'expected.stderr'), entry.expected.stderr);
        row.runtimeOracle = {stdout: pin(path.join(folder, 'expected.stdout')), stderr: pin(path.join(folder, 'expected.stderr')), exitCode: entry.expected.exitCode, observed: false};
        row.machineBuildCommand = ['python3', '-B', 'selfhost/tools/build/native.py', '--assets', assetsFile.file, '--target', 'qbe', '--ir', product, '--out', path.join(folder, 'build'), '--seconds', '55', '--retain-ir'];
        row.executionCommand = [path.join(folder, 'build/program'), ...report.runtimeArguments];
        row.executionCwd = path.join(folder, 'run');
      }
      row.complete = true; row.pass = true;
    } catch (error) { row.error = String(error?.stack ?? error); }
    row.seconds = (performance.now() - begin) / 1000; save();
  }
  report.inputs.forEach(verify);
  report.complete = report.rows.length === 4 && report.rows.every(row => row.complete);
  report.pass = report.complete && report.rows.every(row => row.pass);
  delete report.active;
} catch (error) { report.error = String(error?.stack ?? error); }
finally {
  report.changedInputs = [];
  for (const row of report.inputs) try { verify(row); } catch { report.changedInputs.push(row); }
  if (report.changedInputs.length) { report.complete = false; report.pass = false; }
  save();
  console.log(JSON.stringify({complete: report.complete, pass: report.pass, cases: report.rows.map(row => [row.name, row.pass]), report: path.join(out, 'report.json')}));
  if (!report.pass) process.exitCode = 1;
}
