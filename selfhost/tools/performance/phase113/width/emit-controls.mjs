// API transport only. All control functions, verification and QBE rendering
// are implemented in the checked Bend module. No machine lowering lives here.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL, fileURLToPath} from 'node:url';
import crypto from 'node:crypto';

const [apiPath, preparedPath, outputPath] = process.argv.slice(2);
if (!apiPath || !preparedPath || !outputPath) throw new Error('usage: API PREPARED OUT');
if (fs.existsSync(outputPath)) throw new Error('output already exists');
fs.mkdirSync(outputPath, {recursive: true});
const pin = file => {
  const raw = fs.readFileSync(file);
  return {file: path.resolve(file), bytes: raw.length,
    sha256: crypto.createHash('sha256').update(raw).digest('hex')};
};
const manifestPath = path.join(preparedPath, 'manifest.json');
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
if (manifest.kind !== 'phase113-width-independent-controls' || !manifest.complete)
  throw new Error('wrong prepared controls');
for (const item of [...manifest.inputs, ...manifest.outputs]) {
  const actual = pin(item.file);
  if (actual.sha256 !== item.sha256 || actual.bytes !== item.bytes)
    throw new Error(`changed prepared input: ${item.file}`);
}
const receiptPath = path.join(path.dirname(path.resolve(apiPath)), 'report.json');
const receipt = JSON.parse(fs.readFileSync(receiptPath, 'utf8'));
const required = ['p113_width_control_report', 'p113_width_case_error', 'p113_width_case_qbe'];
if (!receipt.complete || !receipt.checked || receipt.api.sha256 !== pin(apiPath).sha256 ||
    !required.every(name => receipt.exports?.includes(name)))
  throw new Error('checked API receipt/export mismatch');
const api = (await import(pathToFileURL(path.resolve(apiPath)))).default;
const rows = [];
let list = api.p113_width_control_report();
for (; list?.$ === 'Con'; list = list.tail) rows.push(list.head);
if (list?.$ !== 'Nil') throw new Error('malformed control report list');
if (!Array.isArray(rows) || rows.length !== 22 || rows.some(x => !x.startsWith('PASS ')))
  throw new Error(`width controls failed: ${JSON.stringify(rows)}`);
let qbe = '';
for (let which = 0; which < 16; which++) {
  const error = api.p113_width_case_error(which);
  if (error !== '') throw new Error(`original case ${which} rejected: ${error}`);
  qbe += api.p113_width_case_qbe(which);
}
fs.writeFileSync(path.join(outputPath, 'program.ssa'), qbe);
const report = {kind: 'phase113-width-control-emission', complete: true,
  targetExecutions: false, structuralControls: rows, functions: 16, observations: 128,
  inputs: [pin(apiPath), pin(receiptPath), pin(manifestPath), pin(fileURLToPath(import.meta.url))],
  outputs: [pin(path.join(outputPath, 'program.ssa'))]};
fs.writeFileSync(path.join(outputPath, 'report.json'), JSON.stringify(report, null, 2) + '\n');
