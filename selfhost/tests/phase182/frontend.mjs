#!/usr/bin/env bun
// Paired frontend observations only: no host parser, checker, or diagnostic rewrite.
import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath, pathToFileURL} from 'node:url';
import {pin, verify, requireThat as need, workspace, driverInputs} from '../../tools/build/hosted.mjs';

const own = fileURLToPath(import.meta.url);
const revision = '9a4223d577ba56a0cb53d1fd952d2b481c38930f';
const fixtureRoot = path.dirname(own);
const namespaceCases = [
  ['ctr_named_def', true], ['law_def_named_ctr', false], ['ctr_of_datatype', false],
  ['sugar_alias', true], ['sugar_ctr_tld', true], ['sugar_list_own', true],
  ['ops_own', true], ['neq_own_empty', false], ['where_own_exists', false],
  ['or_own_bool', false], ['let_dependent_type', true], ['let_dependent_domain', true],
  ['let_dependent_domain_bad', false], ['let_plus_dependent_type', false],
  ['let_unsafe_dependent_type', true], ['let_forward_refused', false],
];
const sharingCases = [
  'share_cell_cycle', 'conversion_shared_cells_le', 'conversion_shared_cells_no_cycle',
  'conversion_shared_cells_no_cycle_check', 'conversion_shared_cells_self_value',
  'conversion_shared_cells_three_way', 'conversion_shared_cells_once',
];
const cases = [
  ...namespaceCases.map(([name, accepted]) => ({name, accepted, group: 'namespaces', file: path.join(fixtureRoot, 'namespaces', name + '.bend')})),
  ...sharingCases.map(name => ({name, accepted: true, group: 'sharing', file: path.join(fixtureRoot, 'sharing/upstream', name + '.bend')})),
];
const read = file => JSON.parse(fs.readFileSync(file, 'utf8'));
const save = (file, value) => fs.writeFileSync(file, JSON.stringify(value, null, 2) + '\n');
const errorRecord = error => ({name: error?.name ?? null, message: error?.message ?? String(error), stack: error?.stack ?? null});

function selectCases(value) {
  if (value === undefined) return cases;
  const names = value.split(',');
  need(names.length >= 1 && names.length <= cases.length && new Set(names).size === names.length, 'Select 1..23 distinct known case names');
  return names.map(name => {
    const entry = cases.find(entry => entry.name === name);
    need(entry, 'Unknown case name: ' + name);
    return entry;
  });
}

function options() {
  const result = {};
  for (let i = 2; i < process.argv.length; i += 2) {
    const key = process.argv[i], value = process.argv[i + 1];
    need(['--api', '--out', '--timeout-ms', '--cases', '--worker', '--plan'].includes(key) && value && !Object.hasOwn(result, key), 'Unknown, incomplete, or duplicate option: ' + key);
    result[key] = value;
  }
  return result;
}

async function worker(side, planFile) {
  need(['upstream', 'candidate'].includes(side), 'Unknown worker');
  const plan = read(planFile);
  need(plan.kind === 'phase182-frontend-plan' && plan.revision === revision && Array.isArray(plan.selection?.names), 'Invalid finite plan');
  const selected = selectCases(plan.selection.names.join(','));
  need(plan.selection.count === selected.length && plan.cases.length === selected.length && plan.cases.every((entry, i) => entry.name === selected[i].name && entry.accepted === selected[i].accepted && entry.group === selected[i].group && entry.input.file === fs.realpathSync(selected[i].file)), 'Plan selection differs from fixed corpus');
  const output = path.join(path.dirname(planFile), side + '.json');
  need(!fs.existsSync(output), 'Fresh worker output required');
  const report = {kind: 'phase182-frontend-observations', side, complete: false, selection: plan.selection, plan: pin(planFile), rows: []};
  save(output, report);
  try {
    plan.inputs.forEach(verify);
    for (const key of Object.keys(process.env)) if (key.startsWith('BEND_')) delete process.env[key];
    let upstream, inspector;
    if (side === 'upstream') {
      upstream = await import(pathToFileURL(plan.upstream.file));
      need(fs.realpathSync(upstream.BASE_BEND) === plan.base.file, 'Upstream Base identity differs');
    } else {
      process.env.BEND_TYPED_API = plan.api.file;
      process.env.BEND_BASE = plan.base.file;
      const driver = await import(pathToFileURL(path.join(workspace, 'selfhost/tools/typed-driver.mjs')));
      need(driver.apiPath === plan.api.file && driver.basePath === plan.base.file, 'Driver image/Base differs');
      inspector = await driver.createPersistentInspector();
    }
    for (const entry of plan.cases) {
      report.active = entry.name;
      save(output, report);
      const start = performance.now();
      let row = {name: entry.name, group: entry.group, expectedAccepted: entry.accepted, input: entry.input};
      try {
        if (side === 'upstream') {
          const book = upstream.book_nil(), seen = new Map();
          let phase = 'load';
          try {
            await upstream.book_load(book, entry.input.file, '', seen);
            phase = 'check';
            upstream.book_valid(book);
            need(Number.isSafeInteger(book.hols) && book.hols >= 0, 'Invalid upstream hole count');
            row = {...row, classification: book.hols === 0 ? 'accepted' : 'refused', phase, holes: book.hols,
              diagnostic: book.hols === 0 ? '' : 'Error: ' + book.hols + ' TODO' + (book.hols === 1 ? '' : 's') + ' found.\nThe code is incomplete, and not a valid proof yet.'};
          } catch (error) {
            if (error?.$ !== 'Err') throw error;
            row = {...row, classification: 'refused', phase, holes: book.hols, diagnostic: upstream.err_show(error)};
          }
          row.loadedFiles = [...seen.keys()].map(pin);
          for (const file of row.loadedFiles) need(plan.inputs.some(p => p.file === file.file && p.sha256 === file.sha256), 'Unpinned upstream import: ' + file.file);
        } else {
          const raw = await inspector.inspect(entry.input.file, {mode: 'check', useBaseCache: false});
          // typed-driver's catch return always owns sourceFile, even when undefined.
          // Its loader's explicit semantic exceptions identify the source and parse
          // phase. Unlocated exceptions must not masquerade as checker refusals.
          const caughtException = Object.hasOwn(raw, 'sourceFile');
          const locatedParseRefusal = caughtException && raw.phase === 'parse' && typeof raw.sourceFile === 'string'
            && plan.inputs.some(p => p.file === path.resolve(raw.sourceFile));
          const accepted = raw.typeAccepted === true && raw.checked === true
            && (raw.status === 'ok' || raw.phase === 'verdict');
          const refused = raw.typeAccepted === false && raw.status === 'error'
            && ['parse', 'check'].includes(raw.phase) && typeof raw.diagnostic === 'string' && raw.diagnostic.length > 0;
          const classification = caughtException && !locatedParseRefusal ? 'crash' : accepted ? 'accepted' : refused ? 'refused' : 'unexpected-result';
          row = {...row, classification, caughtException, locatedParseRefusal, raw};
          for (const file of raw.files ?? []) need(plan.inputs.some(p => p.file === fs.realpathSync(file)), 'Unpinned candidate import: ' + file);
        }
      } catch (error) {
        row = {...row, classification: 'crash', exception: errorRecord(error)};
      }
      row.elapsedMs = performance.now() - start;
      row.matchesExpected = row.classification === (entry.accepted ? 'accepted' : 'refused');
      report.rows.push(row);
      delete report.active;
      save(output, report);
    }
    plan.inputs.forEach(verify);
    report.complete = true;
    report.pass = report.rows.every(row => row.matchesExpected);
  } catch (error) {
    report.error = errorRecord(error);
  }
  save(output, report);
  if (!report.complete || !report.pass) process.exitCode = 1;
}

async function main(args) {
  need(args['--api'] && args['--out'] && !args['--plan'], 'Usage: bun frontend.mjs --api CHECKED_API_REPORT --out FRESH [--timeout-ms 120000] [--cases NAME,NAME]');
  need(process.versions.bun, 'Run with the pinned Bun engine to import unchanged upstream TypeScript');
  const selected = selectCases(args['--cases']);
  const selection = {requested: args['--cases'] ?? null, names: selected.map(entry => entry.name), count: selected.length, totalAvailable: cases.length, all: selected.length === cases.length};
  const timeoutMs = Number(args['--timeout-ms'] ?? 120000);
  need(Number.isSafeInteger(timeoutMs) && timeoutMs >= 1000 && timeoutMs <= 300000, 'Worker timeout must be 1000..300000 ms');
  const out = path.resolve(args['--out']);
  need(out.startsWith(path.join(workspace, 'selfhost/build') + path.sep) && !fs.existsSync(out), 'Fresh selfhost/build output required');
  fs.mkdirSync(out, {recursive: true});
  const reportFile = path.join(out, 'report.json');
  const report = {kind: 'phase182-paired-frontend', version: 1, complete: false, revision, selection, rows: [], workers: [],
    scope: 'Completion/pass covers only the explicit selection from 23 fixed frontend cases; no aggregation of prior partial runs, runtime-output, diagnostic-equivalence, kernel-proof, self-reproduction, or performance claim.',
    policy: {candidate: 'Unmodified typed-driver persistent inspector, mode check, live Base (cache disabled).', upstream: 'Unmodified book_load and book_valid, followed by the actual book.hols count.', diagnostics: 'Raw observations retained; no comparison or normalization.', timeoutMsPerWorker: timeoutMs}};
  save(reportFile, report);
  try {
    const receipt = read(args['--api']), binding = receipt.imageBinding;
    need(receipt.kind === 'bend-checked-hosted-api' && receipt.version === 1 && receipt.complete && receipt.checked && receipt.status === 0, 'Completed checked API receipt required');
    need(binding?.complete && binding.checked && binding.host === 'js' && binding.stage === 'B1' && binding.image.sha256 === receipt.api.sha256 && binding.sourceIdentity.sha256 === receipt.source.sha256, 'Checked B1 API/source binding required');
    need(receipt.upstream?.revision === revision, 'Wrong upstream revision');
    [receipt.api, receipt.source, binding.image, binding.sourceIdentity, ...receipt.inputs].forEach(verify);
    const upstreamRoot = fs.realpathSync(receipt.upstream.file);
    const upstream = pin(path.join(upstreamRoot, 'bend2/bend.ts'));
    const base = pin(path.join(upstreamRoot, 'bend2/base.bend'));
    const head = spawnSync('git', ['-C', upstreamRoot, 'rev-parse', 'HEAD'], {encoding: 'utf8', timeout: 5000, maxBuffer: 1024 * 1024});
    need(head.status === 0 && head.stdout.trim() === revision, 'Upstream checkout revision differs');
    for (const file of [upstream, base]) need(receipt.inputs.some(p => p.file === file.file && p.sha256 === file.sha256), 'Upstream source/Base differs from acquisition');
    const inputs = [pin(own), pin(process.execPath), pin(args['--api']), receipt.api, receipt.source, ...receipt.inputs,
      ...driverInputs(), pin(path.join(workspace, 'selfhost/tools/runtime-arguments.mjs')), upstream, base];
    const engine = receipt.inputs.find(p => p.file === fs.realpathSync(process.execPath));
    need(engine?.sha256 === pin(process.execPath).sha256, 'Use the acquisition Bun engine');
    for (const directory of ['namespaces', 'sharing/upstream']) {
      const names = fs.readdirSync(path.join(fixtureRoot, directory)).filter(name => name.endsWith('.bend')).sort();
      need(names.length === (directory === 'namespaces' ? 26 : 7), 'Fixture inventory differs');
      for (const name of names) {
        const local = pin(path.join(fixtureRoot, directory, name));
        const section = directory === 'namespaces' ? name.startsWith('let_') ? 'check' : 'import' : name === 'share_cell_cycle.bend' ? 'proof' : 'check';
        const original = pin(path.join(upstreamRoot, 'tests', section, name));
        need(local.sha256 === original.sha256 && local.bytes === original.bytes, 'Fixture differs from immutable upstream: ' + name);
        inputs.push(local, original);
      }
    }
    report.inputs = [...new Map(inputs.map(p => [p.file, p])).values()];
    report.inputs.forEach(verify);
    const planCases = selected.map(entry => {
      const expectedTrailer = fs.readFileSync(entry.file, 'utf8').split('\n').filter(line => line.startsWith('#|'));
      need(expectedTrailer.length && expectedTrailer.includes('#|exit 1') === !entry.accepted, 'Literal acceptance expectation differs from fixture trailer: ' + entry.name);
      return {...entry, input: pin(entry.file), expectedTrailer};
    });
    const planFile = path.join(out, 'plan.json');
    save(planFile, {kind: 'phase182-frontend-plan', version: 1, revision, selection, api: receipt.api, source: receipt.source, upstream, base, inputs: report.inputs, cases: planCases});
    report.plan = pin(planFile);
    save(reportFile, report);
    for (const side of ['upstream', 'candidate']) {
      const command = [own, '--worker', side, '--plan', planFile];
      const result = spawnSync(process.execPath, command, {cwd: workspace, encoding: 'utf8', timeout: timeoutMs, killSignal: 'SIGKILL', maxBuffer: 16 * 1024 * 1024});
      fs.writeFileSync(path.join(out, side + '.stdout'), result.stdout ?? '');
      fs.writeFileSync(path.join(out, side + '.stderr'), result.stderr ?? '');
      const file = path.join(out, side + '.json');
      report.workers.push({side, command: [process.execPath, ...command], status: result.status, signal: result.signal, error: result.error ? errorRecord(result.error) : null,
        stdout: pin(path.join(out, side + '.stdout')), stderr: pin(path.join(out, side + '.stderr')), observation: fs.existsSync(file) ? pin(file) : null});
      save(reportFile, report);
    }
    for (const entry of planCases) {
      const observed = Object.fromEntries(report.workers.map(worker => [worker.side, worker.observation ? read(worker.observation.file).rows.find(row => row.name === entry.name) ?? null : null]));
      const expected = entry.accepted ? 'accepted' : 'refused';
      report.rows.push({name: entry.name, group: entry.group, expected, upstream: observed.upstream?.classification ?? 'missing', candidate: observed.candidate?.classification ?? 'missing',
        pass: observed.upstream?.classification === expected && observed.candidate?.classification === expected});
    }
    report.inputs.forEach(verify);
    verify(report.plan);
    report.complete = report.workers.every(worker => worker.observation && read(worker.observation.file).complete && !worker.error && !worker.signal);
    report.pass = report.complete && report.workers.every(worker => worker.status === 0) && report.rows.length === selection.count && report.rows.every(row => row.pass);
    report.fullCorpusPass = report.pass && selection.all;
  } catch (error) {
    report.error = errorRecord(error);
  }
  save(reportFile, report);
  console.log(JSON.stringify({report: reportFile, complete: report.complete, pass: report.pass ?? false, fullCorpusPass: report.fullCorpusPass ?? false, selection: selection.names, cases: report.rows.length}));
  if (!report.pass) process.exitCode = 1;
}

try {
  const args = options();
  if (args['--worker']) {
    need(args['--plan'] && Object.keys(args).length === 2, 'Worker requires only side and plan');
    await worker(args['--worker'], args['--plan']);
  } else await main(args);
} catch (error) {
  console.error(error.stack ?? String(error));
  process.exitCode = 1;
}
