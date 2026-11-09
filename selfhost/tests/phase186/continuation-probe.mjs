// IO transport only: the checked Bend API prepares and probes its real cursor.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';
import {pin, verify, requireThat as need, workspace} from '../../tools/build/hosted.mjs';

const options = {};
for (let i = 2; i < process.argv.length; i += 2) {
  const key = process.argv[i];
  need(['--api', '--binding', '--out', '--cases', '--names'].includes(key)
    && process.argv[i + 1] && !(key.slice(2) in options), 'Unique --key value required');
  options[key.slice(2)] = process.argv[i + 1];
}
for (const key of ['api', 'binding', 'out']) need(options[key], 'Missing --' + key);
const read = file => JSON.parse(fs.readFileSync(file, 'utf8'));
const authority = read(options.api), binding = read(options.binding);
const catalogFile = path.join(workspace, 'selfhost/tools/bench/catalogs/native45/catalog.json');
const catalog = read(catalogFile), assetRoot = path.resolve(path.dirname(catalogFile), catalog.assetRoot ?? '.');
const aliases = {unicode64: 'coverage-unicode-text-64', record256: 'coverage-record-aggregation-256'};
const defaults = {
  'coverage-unicode-text-64': ['$direct.sjoin.go', '$direct.sjoin', '$p111.k.9435', '$p111.k.9438'],
  'coverage-record-aggregation-256': ['$direct.p37.aggregate', '$direct.p37.aggregate.put',
    '$direct.Map.get', '$direct.Map.set', '$direct.Map.seek', '$direct.Map.seek.go', '$p111.k.7350', '$p111.k.7351'],
};
const selected = (options.cases ?? 'unicode64,record256').split(',').map(name => aliases[name] ?? name);
need(selected.length > 0 && selected.length <= 45 && new Set(selected).size === selected.length, 'Unique bounded catalog cases required');
const explicitNames = options.names?.split(',');
if (explicitNames) need(explicitNames.length <= 64 && explicitNames.every(n => n && n.length <= 1024)
  && new Set(explicitNames).size === explicitNames.length, 'Unique bounded query names required');
for (const id of selected) need(catalog.cases.some(c => c.id === id) && (explicitNames || defaults[id]),
  'Unknown case or missing explicit --names: ' + id);
const out = path.resolve(options.out);
need(out.startsWith(workspace + '/selfhost/build/') && !fs.existsSync(out), 'Fresh workspace build output required');
fs.mkdirSync(out, {recursive: true});
const inputs = [pin(fileURLToPath(import.meta.url)), pin(process.execPath), pin(options.api),
  authority.source, authority.api, ...(authority.inputs ?? []), pin(options.binding),
  ...['assets', 'base', 'carrier', 'engine'].filter(key => binding[key]).map(key => binding[key]), pin(catalogFile)];
const report = {kind: 'phase186-checked-continuation-probe', version: 1, complete: false,
  checkedApi: pin(options.api), inputs, selectedCaseIds: selected, rows: [], programsExecuted: false,
  scope: 'Checked B1 API performs source planning and p169np_plan, then probes the resulting cursor. Host transports exact List<String> queries/results only. Elapsed times are diagnostic; no emitted program execution, runtime ratio, admission rewrite or host compiler logic.'};
const start = performance.now();
const seconds = () => (performance.now() - start) / 1000;
const save = () => { report.seconds = seconds(); fs.writeFileSync(out + '/report.json', JSON.stringify(report, null, 2) + '\n'); };
const same = (a, b) => a && b && ['file', 'bytes', 'sha256'].every(key => a[key] === b[key]);
const list = values => values.reduceRight((tail, head) => ({$: 'Con', head, tail}), {$: 'Nil'});
function strings(value) {
  const result = []; let bytes = 0;
  while (value?.$ === 'Con') {
    need(result.length < 4096 && typeof value.head === 'string' && value.head.length <= 65536, 'Bounded String list required');
    bytes += Buffer.byteLength(value.head); need(bytes <= 4 * 1024 * 1024, 'Probe output exceeds bound');
    result.push(value.head); value = value.tail;
  }
  need(value?.$ === 'Nil', 'Proper List<String> result required'); return result;
}
save();
try {
  const exports = ['p88_cache_prepare', 'p86_plan', 'p169np_plan', 'p186hp_probe'];
  need(authority.kind === 'bend-checked-hosted-api' && authority.complete === true && authority.checked === true
    && !authority.error && !authority.changedInputs?.length && exports.every(name => authority.exports?.includes(name)), 'Complete checked API with probe exports required');
  need(authority.imageBinding?.host === 'js' && authority.imageBinding?.stage === 'B1'
    && same(authority.imageBinding.image, authority.api) && same(authority.imageBinding.sourceIdentity, authority.source), 'Actual checked B1 image/source binding required');
  need(binding.kind === 'phase175-prepared-base' && typeof binding.stamp === 'string' && binding.stamp
    && same(pin(process.execPath), binding.engine), 'Prepared Base binding and exact engine required');
  inputs.forEach(verify);
  const api = (await import(pathToFileURL(authority.api.file))).default;
  need(exports.every(name => typeof api[name] === 'function'), 'Probe API export shape differs');
  let tick = seconds();
  const prep = api.p88_cache_prepare(binding.base.file, fs.readFileSync(binding.base.file, 'utf8'),
    fs.readFileSync(binding.carrier.file, 'utf8'), binding.stamp);
  need(prep?.$ === 'P86PreparationReady', prep?.error ?? 'Base preparation refused');
  report.baseSeconds = seconds() - tick;
  for (const id of selected) {
    const c = catalog.cases.find(value => value.id === id);
    const source = pin(path.resolve(assetRoot, c.source.file));
    const expected = pin(path.resolve(assetRoot, c.expectedFile.file));
    need(source.bytes === c.source.bytes && source.sha256 === c.source.sha256
      && expected.bytes === c.expectedFile.bytes && expected.sha256 === c.expectedFile.sha256
      && fs.readFileSync(expected.file, 'utf8') === c.point.expectedStdout, 'Frozen catalog source/oracle differs: ' + id);
    inputs.push(source, expected);
    const row = {id, source, expectedFile: expected, oracleExecuted: false,
      queryNames: explicitNames ?? defaults[id], complete: false};
    report.rows.push(row); save(); tick = seconds();
    const planned = api.p86_plan(prep.seed, source.file, fs.readFileSync(source.file, 'utf8'));
    need(planned?.$ === 'P86PlanReady', planned?.error ?? 'Source planning refused');
    const prepared = api.p169np_plan(planned);
    need(prepared?.$ === 'P169Prepared' && prepared.error === '', prepared?.error ?? 'Verified native preparation refused');
    row.prepareSeconds = seconds() - tick; tick = seconds();
    row.strings = strings(api.p186hp_probe(prepared.cursor, list(row.queryNames)));
    row.probeSeconds = seconds() - tick;
    row.complete = true; save();
  }
  inputs.forEach(verify); report.complete = true;
} catch (error) {
  report.error = String(error.stack ?? error); process.exitCode = 1;
}
save();
console.log(JSON.stringify({complete: report.complete, rows: report.rows.length, report: out + '/report.json', error: report.error}));
