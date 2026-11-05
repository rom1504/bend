// Transport/timing only. Preparation, optimization and all decisions run in Bend.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {pin, verify, items} from '../../phase147/tools/support.mjs';

const [candidateReceipt, baselineReceipt, base, out, ...names] = process.argv.slice(2);
assert(names.length > 0, 'Explicit frozen cases required');
const catalogPath = 'selfhost/tools/bench/catalogs/native45/catalog.json';
const catalog = JSON.parse(fs.readFileSync(catalogPath));
assert.equal(catalog.schema, 'bend-benchmark-native-catalog-v1');
const catalogRoot = path.resolve(path.dirname(catalogPath), catalog.assetRoot);
function asset(value) {
  const result = {...value, file: path.resolve(catalogRoot, value.file)};
  verify(result);
  return result;
}
const cases = names.map(name => {
  const rows = catalog.cases.filter(row => row.id === name);
  assert.equal(rows.length, 1);
  const row = rows[0];
  const source = asset(row.source), expected = asset(row.expectedFile);
  assert.equal(fs.readFileSync(expected.file, 'utf8'), row.point.expectedStdout);
  return {name, family: row.family, source, expected, point: row.point};
});
async function load(file) {
  const r = JSON.parse(fs.readFileSync(file));
  assert(r.complete && r.checked);
  verify(r.api);
  return {receipt: pin(file), ...r, value: (await import(pathToFileURL(r.api.file))).default};
}
const candidate = await load(candidateReceipt), baseline = await load(baselineReceipt);
assert.equal(baseline.source.sha256, '027e15041035522ed7e40ef971eff75f24a09ef6a00e3f8fe335839f94bcb8a8');
fs.mkdirSync(out, {recursive: false});
const report = {
  complete: false, inputs: [pin(import.meta.filename), pin(catalogPath), pin(base),
    candidate.receipt, candidate.api, baseline.receipt, baseline.api],
  scope: 'Original frozen IO sources and inputs. Shared checked request; hosted complete backend emission, not native whole-request time. Independent native outputs checked separately.',
  controls: [], rows: []
};
const save = () => fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
function render(api, emission) {
  if (emission.$ === 'P111Emission') {
    assert.equal(emission.error, '');
    return items(emission.chunks).join('\n') + '\n';
  }
  assert.equal(emission.$, 'P134Planned', JSON.stringify(emission));
  let cursor = api.p134e_begin(emission.plan);
  let text = '';
  for (;;) {
    const next = api.p134e_next(cursor);
    if (next.$ === 'P134Done') return text;
    assert.equal(next.$, 'P134Piece');
    text += next.text + (next.legacy_end ? '\n' : '');
    cursor = next.next;
  }
}
try {
  if (candidate.value.p164h_controls) {
    report.controls = items(candidate.value.p164h_controls());
    save();
    assert(report.controls.length > 0 && report.controls.every(x => x.endsWith(':pass')));
  }
  let start = performance.now();
  const prepared = candidate.value.p86_prepare(fs.realpathSync(base), fs.readFileSync(base, 'utf8'));
  assert.equal(prepared.$, 'P86PreparationReady', JSON.stringify(prepared));
  report.basePreparationSeconds = (performance.now() - start) / 1000;
  for (const [index, spec] of cases.entries()) {
    const row = {...spec, complete: false, products: {}};
    report.rows.push(row); report.inputs.push(spec.source, spec.expected); save();
    start = performance.now();
    const plan = candidate.value.p86_plan(prepared.seed, spec.source.file, fs.readFileSync(spec.source.file, 'utf8'));
    assert.equal(plan.$, 'P86PlanReady', JSON.stringify(plan));
    row.frontendSeconds = (performance.now() - start) / 1000;
    for (const role of index % 2 ? ['candidate', 'baseline'] : ['baseline', 'candidate']) {
      const api = role === 'candidate' ? candidate.value : baseline.value;
      start = performance.now();
      const emission = role === 'candidate' ? api.p164h_emit_plan(plan) : api.p134e_plan(plan);
      const text = render(api, emission);
      const seconds = (performance.now() - start) / 1000;
      const file = path.join(out, spec.name + '-' + role + '.ssa');
      fs.writeFileSync(file, text, {flag: 'wx'});
      row.products[role] = {ir: pin(file), seconds,
        functions: (text.match(/^(?:export )?function /gm) || []).length};
      if (role === 'candidate' && api.p164h_summary) row.summary = api.p164h_summary(emission);
      save();
    }
    row.ratio = row.products.candidate.seconds / row.products.baseline.seconds;
    row.complete = true; save();
  }
  report.inputs.forEach(verify);
  report.complete = true;
} catch (error) {
  report.error = String(error.stack ?? error);
  process.exitCode = 1;
} finally {
  save();
  console.log(JSON.stringify({complete: report.complete, rows: report.rows.length, error: report.error}));
}
