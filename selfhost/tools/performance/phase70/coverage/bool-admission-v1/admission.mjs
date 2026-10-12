// Source-only authoring. Root runs this under the standard guarded target lane.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import * as D from '../../../../typed-driver.mjs';

const [mode, output] = process.argv.slice(2);
assert(['baseline', 'candidate'].includes(mode), 'baseline|candidate OUT');
assert(output && process.env.BEND_TYPED_API, 'explicit output and BEND_TYPED_API required');
const root = path.resolve(import.meta.dirname, '../../../../../..');
const out = path.resolve(output), raw = fs.realpathSync(path.join(root, 'selfhost/build/phase70'));
assert(out.startsWith(raw + path.sep) && !fs.existsSync(out), 'fresh Phase70 output required');
assert(fs.realpathSync(path.dirname(out)) === path.dirname(out), 'canonical existing parent required');
fs.mkdirSync(out);
const pin = file => {
  file = fs.realpathSync(file);
  const source = fs.readFileSync(file);
  return {file, bytes: source.length, sha256: createHash('sha256').update(source).digest('hex')};
};
const catalogPath = path.join(import.meta.dirname, 'catalog.json');
const catalog = JSON.parse(fs.readFileSync(catalogPath, 'utf8'));
for (const item of catalog.inputs) assert.deepEqual(pin(item.file), item, 'fixture provenance');
const api = await D.loadApi();
assert.equal(typeof api.nc_compile_checked, 'function');
const report = {complete: false, mode, method: pin(import.meta.filename), catalog: pin(catalogPath),
  api: pin(process.env.BEND_TYPED_API), driver: pin(D.driverPath), base: pin(D.basePath),
  runtime: pin(path.join(root, 'selfhost/src/runtime/native/runtime.c')), rows: []};
const save = () => fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
const flags = code => Object.fromEntries(['TYPED_SCALARS', 'SCALAR_ARRAYS', 'UNSHARED_ARRAYS'].map(name => {
  const found = [...code.matchAll(new RegExp('^#define NATIVE_' + name + ' ([01])$', 'gm'))];
  // Checked emission prepends the permission. Later runtime #ifndef defaults
  // are zero and inactive; raw emission may rely entirely on those defaults.
  assert(found.slice(1).every(match => match[1] === '0'), name + ' unexpected later definition');
  return [name, found.length ? Number(found[0][1]) : 0];
}));
async function emit(id, file, selectedApi, scalar, unshared) {
  const result = await D.inspect(file, {mode: 'native', api: selectedApi});
  assert.equal(result.status, 'ok', JSON.stringify(result));
  const observed = flags(result.code);
  assert.equal(observed.SCALAR_ARRAYS, scalar, id);
  assert.equal(observed.TYPED_SCALARS, scalar, id + ' typed ABI');
  if (unshared !== null) assert.equal(observed.UNSHARED_ARRAYS, unshared, id + ' sharing');
  const output = path.join(out, id + '.c');
  fs.writeFileSync(output, result.code);
  report.rows.push({id, source: pin(file), flags: observed, output: pin(output), pass: true});
  save();
}
try {
  for (const row of catalog.cases) {
    const scalar = mode === 'candidate' ? row.candidateScalar : 0;
    await emit(row.id, row.file, api, scalar, scalar ? row.candidateUnshared : 0);
  }
  // The same well-typed source cannot authorize narrowing through a raw entry,
  // or when the checked entry's effect-source permission is explicitly false.
  const file = catalog.cases.find(row => row.id === 'mixed').file;
  for (const kind of ['raw', 'untrusted-effects']) {
    const wrapped = {...api, nc_compile_checked: (book, runtime, requests) => kind === 'raw'
      ? api.nc_compile(book, runtime, requests)
      : api.nc_compile_checked(book, runtime, requests, false)};
    await emit(kind, file, wrapped, 0, 0);
  }
  report.complete = true;
} finally { save(); }
console.log(JSON.stringify({complete: report.complete, rows: report.rows.length}));
