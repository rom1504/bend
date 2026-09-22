// Real boundary refusals; never modifies compiler inputs or launches a compiler.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [configFile, outArg] = process.argv.slice(2);
if (!outArg) throw Error('Usage: native-annotation-guards.mjs VALID_CONFIG NEW_DIRECTORY');
const out = path.resolve(outArg), cfg = JSON.parse(fs.readFileSync(configFile)); fs.mkdirSync(out, {recursive:false});
const {spawnFileCapture} = await import(pathToFileURL(cfg.captureTool));
const tool = path.join(import.meta.dirname, 'native-annotation-measure.mjs'), rows = [];
const cases = [
  ['zero-rounds', c => {c.rounds = 0;}, /Positive integer rounds/],
  ['empty-fixtures', c => {c.fixtures = [];}, /Nonempty fixtures/],
  ['empty-variants', c => {c.variants = [];}, /Nonempty variants/],
  ['unsafe-id', c => {c.fixtures[0].id = '../escaped';}, /safe output basenames/],
  ['fixture-alias', c => {c.fixtures[0].file = c.base;}, /Fixture physical identity differs/],
  ['oracle-input-drift', c => {const oracle = JSON.parse(fs.readFileSync(c.oracleReport)); oracle.identity[c.base] = '0'.repeat(64); c.oracleReport = path.join(out, 'bad-oracle.json'); fs.writeFileSync(c.oracleReport, JSON.stringify(oracle));}, /Oracle input drift/],
];
for (const [id, mutate, expected] of cases) {
  const c = structuredClone(cfg); mutate(c); const file = path.join(out, id + '.json'), output = path.join(out, id + '-output'); fs.writeFileSync(file, JSON.stringify(c));
  const result = await spawnFileCapture(process.execPath, [tool, file, output], {timeout: 10000, maxBuffer: 1024 * 1024});
  fs.writeFileSync(path.join(out, id + '.stderr'), result.stderr); fs.writeFileSync(path.join(out, id + '.stdout'), result.stdout);
  assert.ok(!result.error); assert.equal(result.signal, null); assert.equal(result.status, 1); assert.match(result.stderr, expected);
  assert.equal(fs.existsSync(path.join(output, 'report.json')), false, 'Refusal must precede native launch/report');
  rows.push({id, status: result.status, diagnostic: result.stderr, refusedBeforeNativeLaunch: true});
}
fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify({kind: 'native-annotation-boundary-controls', complete:true, rows}, null, 2) + '\n');
console.log(JSON.stringify({complete:true, cases:rows.length}));
