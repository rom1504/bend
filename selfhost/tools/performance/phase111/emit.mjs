// Source bytes and checked Bend API transport only; no host semantic lowering.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [apiArg, inputArg, outArg, mode = 'cache'] = process.argv.slice(2);
if (!apiArg || !inputArg || !outArg || !['cache', 'live'].includes(mode))
  throw Error('Usage: emit.mjs CHECKED_API INPUT FRESH_OUT [cache|live]');
const root = path.resolve(import.meta.dirname, '../../../..');
const apiFile = path.resolve(apiArg), source = path.resolve(inputArg), out = path.resolve(outArg);
if (!out.startsWith(root + '/selfhost/build/phase111/') || fs.existsSync(out))
  throw Error('Fresh Phase111 output required');
const pin = file => ({file: path.resolve(file), bytes: fs.statSync(file).size,
  sha256: crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const verify = row => {
  const got = pin(row.file);
  if (got.bytes !== row.bytes || got.sha256 !== row.sha256) throw Error('Changed input ' + row.file);
};
const apiRecordFile = path.join(path.dirname(apiFile), 'report.json');
const apiRecord = JSON.parse(fs.readFileSync(apiRecordFile));
if (!apiRecord.complete || !apiRecord.checked || !apiRecord.exports.includes('p111_compile_source'))
  throw Error('A checked complete Phase111 source API is required');
verify(apiRecord.api);
if (apiRecord.api.file !== apiFile) throw Error('API path differs from checked receipt');
const selectionFile = path.join(root, 'selfhost/tools/native/selection.json');
const selection = JSON.parse(fs.readFileSync(selectionFile));
verify(selection.admission);
const admission = JSON.parse(fs.readFileSync(selection.admission.file));
if (!admission.complete || !admission.qualified) throw Error('Native seed admission incomplete');
const {base, cache} = admission.assets;
verify(base);
if (mode === 'cache') verify(cache.carrier);
const inputs = [pin(import.meta.filename), pin(apiFile), pin(apiRecordFile), pin(source),
  pin(selectionFile), selection.admission, base, ...(mode === 'cache' ? [cache.carrier] : [])];
fs.mkdirSync(out, {recursive: true});
fs.copyFileSync(import.meta.filename, path.join(out, 'emit-method.mjs'));
const report = {kind: 'phase111-checked-source-qbe-emission', complete: false, mode,
  inputs, sourceChecked: false, compilerHost: 'checked Bend source API acquired by pinned TypeScript',
  scope: 'Fast semantic integration. This is not a native compiler or self-host qualification.'};
const save = () => fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
save();
try {
  const api = (await import(pathToFileURL(apiFile))).default;
  const start = performance.now();
  const result = api.p111_compile_source(source, fs.readFileSync(source, 'utf8'), base.file,
    fs.readFileSync(base.file, 'utf8'), mode === 'cache' ? fs.readFileSync(cache.carrier.file, 'utf8') : '',
    mode === 'cache' ? cache.stamp : '', mode === 'cache');
  report.compilerSeconds = (performance.now() - start) / 1000;
  if (result?.$ !== 'P111Emission') throw Error('Unexpected Bend emission result');
  report.diagnostic = result.error;
  if (result.error) throw Error(result.error);
  const fd = fs.openSync(path.join(out, 'program.ssa'), 'wx');
  let cursor = result.chunks, chunks = 0;
  try {
    while (cursor?.$ === 'Con') {
      if (typeof cursor.head !== 'string') throw Error('Invalid emitted chunk');
      fs.writeSync(fd, cursor.head + '\n');
      chunks++;
      cursor = cursor.tail;
    }
    if (cursor?.$ !== 'Nil' || chunks === 0) throw Error('Invalid emitted chunk list');
  } finally {fs.closeSync(fd);}
  report.chunks = chunks;
  report.sourceChecked = true;
  report.product = pin(path.join(out, 'program.ssa'));
  for (const row of inputs) verify(row);
  report.complete = true;
  save();
  console.log(JSON.stringify({complete: true, seconds: report.compilerSeconds, chunks, bytes: report.product.bytes}));
} catch (error) {
  report.error = String(error);
  save();
  throw error;
}
