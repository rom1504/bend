#!/usr/bin/env bun
// Diagnostic only. Import an existing, pinned B2 and exercise its actual public
// exports. No compiler generation, source parsing, private-function exposure,
// image rewriting, stack-limit change, or replacement implementation.
//
// Example (run under the campaign's CPU/memory/disk guard):
// bun selfhost/tests/phase182/js-export-stack.mjs \
//   --authority selfhost/build/phase182/js-b203/report.json \
//   --out selfhost/build/phase182/js-export-stack01
// Repeat in a separate process with phase174/js-b2-retry/report.json to compare
// engines/images under the same guard and warmup. Stack overflows are recorded
// observations; they do not make this diagnostic a successful compiler gate.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {fileURLToPath, pathToFileURL} from 'node:url';

const own = fileURLToPath(import.meta.url);
const workspace = path.resolve(path.dirname(own), '../../..');
const need = (value, message) => { if (!value) throw new Error(message); };
const pin = file => {
  file = fs.realpathSync(file);
  const bytes = fs.readFileSync(file);
  return {file, bytes: bytes.length, sha256: crypto.createHash('sha256').update(bytes).digest('hex')};
};
const verify = expected => {
  const actual = pin(expected.file);
  need(actual.bytes === expected.bytes && actual.sha256 === expected.sha256, 'Input identity differs: ' + expected.file);
};
const errorRecord = error => ({name: error?.name ?? null, message: error?.message ?? String(error), stack: error?.stack ?? null});
const stackOverflow = error => error?.name === 'RangeError' && /call stack|stack overflow/i.test(error?.message ?? '');
const nil = () => ({$: 'Nil'});
const con = (head, tail) => ({$: 'Con', head, tail});
const list = values => {
  let result = nil();
  for (let i = values.length - 1; i >= 0; --i) result = con(values[i], result);
  return result;
};
const array = value => {
  const result = [];
  while (value?.$ === 'Con') {
    need(result.length < 16384, 'Unexpected or cyclic output list');
    result.push(value.head);
    value = value.tail;
  }
  need(value?.$ === 'Nil', 'Malformed output list');
  return result;
};

// Field names are the actual js-b203 aggregate ABI (also used by Phase174 B2).
const term = (tag, name = '', kids = [], id = 0) => ({
  $: 'KTerm', tag, name, id, quant: 0, kids: list(kids), removed: nil(), originBegin: 0, originEnd: 0,
});
const definition = (name, serial = 0, fields = {}) => ({
  $: 'KDef', name, kind: 'Absent', arity: serial, templates: 0,
  typ: term('Qnt'), value: term('Qnt', 'value-' + serial, [], serial),
  ctors: nil(), native: false, unsafe: false, ...fields,
});

// The IO definition is only a synthetic lookup fixture, not a checked program.
// Its absent body makes wnf preserve App(Ref(IO), Qnt). j_io_type returns true,
// and jd_host_export omits the probe. Thus the expected export text is exactly
// empty; no foreign effect, generated function, or marshaller is executed.
const io = definition('IO', 1, {kind: 'Def', native: true, value: term('Absent')});
const ioGoal = term('App', '', [term('Ref', 'IO'), term('Qnt')]);
const probe = definition('stack.probe', 0, {kind: 'Def', typ: ioGoal});
const skipped = definition('stack.skipped');
const makeBook = length => {
  need(length >= 1 && length <= 12288, 'Bounded book length required');
  const rows = [io];
  for (let i = 1; i < length; ++i) rows.push(definition('filler.' + i, i));
  return {rows, value: list(rows)};
};
const makeDefs = (prefix, includeProbe) => {
  let result = includeProbe ? con(probe, nil()) : nil();
  for (let i = 0; i < prefix; ++i) result = con(skipped, result);
  return result;
};

const options = {};
for (let i = 2; i < process.argv.length; i += 2) {
  const key = process.argv[i], value = process.argv[i + 1];
  need(['--authority', '--out', '--warmup'].includes(key) && value && !Object.hasOwn(options, key),
    'Unknown, incomplete, or duplicate option: ' + key);
  options[key] = value;
}
need(options['--authority'] && options['--out'], 'Usage: --authority B2_REPORT --out FRESH_DIRECTORY [--warmup 64]');
const warmup = Number(options['--warmup'] ?? 64);
need(Number.isInteger(warmup) && warmup >= 0 && warmup <= 4096, 'Warmup must be 0..4096');
const out = path.resolve(options['--out']);
need(out.startsWith(workspace + '/selfhost/build/') && !fs.existsSync(out), 'Fresh selfhost/build output required');
fs.mkdirSync(out, {recursive: true});
const reportFile = path.join(out, 'report.json');
const bookLengths = [1, 4096, 8192, 12288];
const exportPrefixes = [0, 2048, 4271, 4290];
const report = {
  kind: 'phase182-js-export-stack-diagnostic', version: 1, complete: false,
  inputs: [pin(own), pin(process.execPath)], rows: [],
  engine: {
    execPath: process.execPath, execArgv: process.execArgv, versions: process.versions,
    // Explicit allowlist only. The external guard/caller owns these settings;
    // this diagnostic records them and never adjusts the process stack policy.
    resourceEnvironment: {
      BUN_JSC_maxPerThreadStackUsage: process.env.BUN_JSC_maxPerThreadStackUsage ?? null,
      BUN_JSC_dumpOptions: process.env.BUN_JSC_dumpOptions ?? null,
    },
  },
  plan: {bookLengths, exportPrefixes, warmup, order: 'oracle, warmup, skip-only, each book: filter then ascending export prefixes'},
  scope: 'Finite helper diagnosis in an unchanged B2 image. Synthetic aggregate inputs are not checked Bend programs. No source acceptance, public-library completion, B3 reproduction, exact stack limit, or compiler correctness claim.',
  policy: 'Only declared list/term/definition objects and existing exported functions. A caught stack overflow is an observation; unexpected exceptions or oracle differences fail the diagnostic. No automatic retry or stack adjustment. External host resource settings are recorded, not set.',
};
const save = () => fs.writeFileSync(reportFile, JSON.stringify(report, null, 2) + '\n');
save();

function observe(description, call, check, allowStack = true) {
  report.active = description;
  save();
  const started = performance.now();
  let row;
  try {
    const value = call();
    row = {...description, classification: 'returned', ...check(value)};
  } catch (error) {
    row = {...description, classification: stackOverflow(error) ? 'stack-overflow' : 'unexpected-error', exception: errorRecord(error)};
    if (!allowStack || row.classification !== 'stack-overflow') row.unexpected = true;
  }
  row.elapsedMs = performance.now() - started;
  report.rows.push(row);
  delete report.active;
  save();
  return row;
}

try {
  const authorityPin = pin(options['--authority']);
  const authority = JSON.parse(fs.readFileSync(authorityPin.file, 'utf8'));
  need(authority.kind === 'bend-js-self-emission' && authority.complete && authority.stage === 'B2', 'A completed actual B2 authority is required');
  need(authority.image && authority.source && authority.base, 'B2 authority lacks image/source/Base identities');
  report.authority = authorityPin;
  report.image = authority.image;
  report.source = authority.source;
  report.base = authority.base;
  report.inputs.push(authorityPin, authority.image, authority.source, authority.base);
  report.inputs.forEach(verify);
  const api = (await import(pathToFileURL(authority.image.file))).default;
  const required = ['index_remove', 'jd_host_exports', 'j_io_type'];
  report.exports = {required, available: required.filter(name => typeof api?.[name] === 'function'), total: Object.keys(api ?? {}).length};
  need(report.exports.available.length === required.length, 'Required actual image export is absent');
  save();

  const oracleCases = [
    ['empty', [], 'x'],
    ['miss', ['a', 'b', 'c'], 'x'],
    ['all-hit', ['x', 'x', 'x'], 'x'],
    ['head', ['x', 'a', 'b'], 'x'],
    ['middle', ['a', 'x', 'b'], 'x'],
    ['tail', ['a', 'b', 'x'], 'x'],
    ['duplicates-order', ['b', 'x', 'a', 'x', 'c', 'x'], 'x'],
    ['empty-name', ['', 'a', '', 'b'], ''],
  ];
  for (const [name, names, needle] of oracleCases) {
    const rows = names.map((label, i) => definition(label, i + 1, {unsafe: i % 2 === 1}));
    const input = list(rows), original = JSON.stringify(input);
    // Independent host filter; complete row values and order are the oracle.
    const expected = rows.filter(row => row.name !== needle);
    observe({group: 'order-oracle', name, needle, inputNames: names}, () => api.index_remove(input, needle), result => {
      const actual = array(result);
      need(JSON.stringify(actual) === JSON.stringify(expected), 'index_remove complete-value/order mismatch: ' + name);
      need(JSON.stringify(input) === original, 'index_remove changed retained input: ' + name);
      return {exact: true, outputNames: actual.map(row => row.name)};
    }, false);
  }
  const one = makeBook(1);
  observe({group: 'path-oracle', name: 'native-IO-shadow'}, () => api.j_io_type(one.value, ioGoal), result => {
    need(result === true, 'Synthetic goal did not take the IO omission path');
    return {exact: true, value: result};
  }, false);
  observe({group: 'path-oracle', name: 'single-probe'}, () => api.jd_host_exports(one.value, makeDefs(0, true)), result => {
    need(result === '', 'Expected IO-valued probe to be omitted');
    return {exact: true, textBytes: 0};
  }, false);
  need(report.rows.every(row => row.classification === 'returned' && row.exact), 'Small independent oracles failed');

  report.active = {group: 'warmup', iterations: warmup};
  save();
  const small = makeBook(16), smallDefs = makeDefs(8, true);
  const warmStarted = performance.now();
  for (let i = 0; i < warmup; ++i) {
    need(array(api.index_remove(small.value, 'IO')).length === 15, 'Warmup filter differs');
    need(api.jd_host_exports(small.value, smallDefs) === '', 'Warmup exports differ');
  }
  report.warmup = {iterations: warmup, bookLength: 16, exportPrefix: 8, elapsedMs: performance.now() - warmStarted};
  delete report.active;
  save();

  for (const prefix of exportPrefixes) {
    observe({group: 'export-prefix-only', bookLength: 0, exportPrefix: prefix, definitionRows: prefix},
      () => api.jd_host_exports(nil(), makeDefs(prefix, false)), result => {
        need(result === '', 'Skipped export prefix produced text');
        return {exact: true, textBytes: 0};
      });
  }
  for (const length of bookLengths) {
    const book = makeBook(length);
    observe({group: 'filter-depth', bookLength: length, needle: 'IO'}, () => api.index_remove(book.value, 'IO'), result => {
      const actual = array(result);
      need(actual.length === length - 1 && actual.every((row, i) => row.name === 'filler.' + (i + 1) && row.arity === i + 1),
        'Large filter length/order differs');
      return {exact: true, outputRows: actual.length};
    });
    for (const prefix of exportPrefixes) {
      const defs = makeDefs(prefix, true);
      observe({group: 'combined-depth', bookLength: length, exportPrefix: prefix, definitionRows: prefix + 1, ioProbes: 1},
        () => api.jd_host_exports(book.value, defs), result => {
          need(result === '', 'IO-valued probe produced export text');
          return {exact: true, textBytes: 0};
        });
    }
  }
  report.inputs.forEach(verify);
  report.complete = true;
  report.oraclesPassed = true;
  report.observedStackOverflow = report.rows.some(row => row.classification === 'stack-overflow');
  report.unexpectedFailures = report.rows.filter(row => row.unexpected).length;
  if (report.unexpectedFailures) process.exitCode = 1;
} catch (error) {
  report.error = errorRecord(error);
  process.exitCode = 1;
}
save();
console.log(JSON.stringify({complete: report.complete, oraclesPassed: report.oraclesPassed,
  observedStackOverflow: report.observedStackOverflow, unexpectedFailures: report.unexpectedFailures,
  rows: report.rows.length, report: reportFile, error: report.error}));
