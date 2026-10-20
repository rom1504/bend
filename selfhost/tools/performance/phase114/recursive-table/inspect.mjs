// Root-only ordinary source transport. The Bend API owns every compiler and
// eligibility decision. No emitted-text parsing or host semantic lowering.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [apiArg, outArg, ...sourceArgs] = process.argv.slice(2);
if (!apiArg || !outArg || !sourceArgs.length)
  throw Error('Usage: inspect.mjs CHECKED_API FRESH_PHASE114_OUT SOURCE [SOURCE ...]');
const root = path.resolve(import.meta.dirname, '../../../../..');
const apiFile = path.resolve(apiArg), out = path.resolve(outArg);
if (!out.startsWith(root + '/selfhost/build/phase114/') || fs.existsSync(out))
  throw Error('Fresh Phase114 output required');
let parent = path.dirname(out);
while (!fs.existsSync(parent)) parent = path.dirname(parent);
if (fs.realpathSync(parent) !== parent) throw Error('Symlink output parent refused');
const pin = file => {
  file = path.resolve(file);
  const bytes = fs.readFileSync(file);
  return {file, bytes: bytes.length, sha256: crypto.createHash('sha256').update(bytes).digest('hex')};
};
const verify = row => {
  const found = pin(path.resolve(root, row.file));
  if (found.bytes !== row.bytes || found.sha256 !== row.sha256) throw Error('Changed input ' + row.file);
};
const requiredExports = ['p88_cache_prepare', 'p86_plan', 'p111_runtime_admission', 'p114h_inspect_request'];
const receiptFile = path.join(path.dirname(apiFile), 'report.json');
const receipt = JSON.parse(fs.readFileSync(receiptFile));
if (!receipt.complete || !receipt.checked || !requiredExports.every(x => receipt.exports?.includes(x)))
  throw Error('Complete checked API with recursive inspection exports required');
verify(receipt.api);
if (path.resolve(receipt.api.file) !== apiFile) throw Error('API receipt identity mismatch');
if (!Array.isArray(receipt.inputs) || !receipt.inputs.length) throw Error('Missing API acquisition inputs');
for (const row of receipt.inputs) verify(row);
const selectionFile = path.join(root, 'selfhost/tools/native/selection.json');
const selection = JSON.parse(fs.readFileSync(selectionFile));
verify(selection.admission);
const admission = JSON.parse(fs.readFileSync(selection.admission.file));
if (!admission.complete || !admission.qualified) throw Error('Qualified native source assets required');
const {base, cache} = admission.assets;
verify(base); verify(cache.carrier);
const sources = sourceArgs.map(x => pin(path.resolve(x)));
fs.mkdirSync(out, {recursive: true});
const method = path.join(out, 'method.mjs');
fs.copyFileSync(import.meta.filename, method);
const report = {kind: 'phase114-ordinary-table-recursive-inspection', complete: false,
  startedUtc: new Date().toISOString(), requiredExports, inputs: [pin(import.meta.filename),
    pin(method), pin(apiFile), pin(receiptFile), pin(selectionFile), selection.admission,
    base, cache.carrier, pin(process.execPath), ...receipt.inputs, ...sources], cases: [],
  scope: 'Checked ordinary frontend, runtime admission, Bend lowering and internal table-recursive-plan inspection. No QBE emission, program execution, native qualification or performance claim. Empty admitted-entry lists are reported, not hidden.'};
const save = () => fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
const totalStart = performance.now();
save();
try {
  const api = (await import(pathToFileURL(apiFile))).default;
  if (!requiredExports.every(x => typeof api[x] === 'function')) throw Error('Missing API function');
  let start = performance.now();
  const prepared = api.p88_cache_prepare(base.file, fs.readFileSync(base.file, 'utf8'),
    fs.readFileSync(cache.carrier.file, 'utf8'), cache.stamp);
  report.preparationSeconds = (performance.now() - start) / 1000;
  if (prepared?.$ !== 'P86PreparationReady') throw Error('Preparation: ' + String(prepared?.error));
  for (const source of sources) {
    const row = {source, complete: false, sourceChecked: false, runtimeAdmitted: false, entries: []};
    report.cases.push(row); save();
    try {
      start = performance.now();
      const planned = api.p86_plan(prepared.seed, source.file, fs.readFileSync(source.file, 'utf8'));
      row.frontendSeconds = (performance.now() - start) / 1000;
      if (planned?.$ !== 'P86PlanReady' || planned.request?.$ !== 'NR_Request')
        throw Error('Frontend: ' + String(planned?.error ?? planned?.$));
      row.sourceChecked = true; row.verdict = planned.verdict;
      const capability = api.p111_runtime_admission(planned.request);
      if (typeof capability !== 'string' || capability) throw Error('Runtime admission: ' + String(capability));
      row.runtimeAdmitted = true;
      start = performance.now();
      const inspected = api.p114h_inspect_request(planned.request);
      row.inspectionSeconds = (performance.now() - start) / 1000;
      if (inspected?.$ !== 'P114HInspection' || typeof inspected.error !== 'string')
        throw Error('Invalid Bend inspection result');
      if (inspected.error) throw Error('Inspection: ' + inspected.error);
      let entries = inspected.entries;
      row.regions = [];
      while (entries?.$ === 'Con') {
        const entry = entries.head;
        if (entry?.$ !== 'P114HEntry' || typeof entry.name !== 'string') throw Error('Invalid table entry');
        const continuations = [];
        let cells = entry.continuations;
        while (cells?.$ === 'Con') {
          if (typeof cells.head !== 'string') throw Error('Non-string continuation name');
          continuations.push(cells.head); cells = cells.tail;
        }
        if (cells?.$ !== 'Nil') throw Error('Invalid continuation list tail');
        row.entries.push(entry.name);
        row.regions.push({name: entry.name, continuations});
        entries = entries.tail;
      }
      if (entries?.$ !== 'Nil') throw Error('Invalid entry list tail');
      row.complete = true;
    } catch (error) { row.error = String(error); }
    save(); console.log(JSON.stringify(row));
  }
  for (const input of report.inputs) verify(input);
  report.complete = report.cases.every(x => x.complete);
} catch (error) { report.error = String(error); }
finally {
  report.totalSeconds = (performance.now() - totalStart) / 1000;
  report.finishedUtc = new Date().toISOString(); save();
}
if (!report.complete) process.exitCode = 1;
