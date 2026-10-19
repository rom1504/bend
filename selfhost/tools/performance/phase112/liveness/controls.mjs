#!/usr/bin/env node
// Raw-term semantic controls. Root runs this under the serial target guard.
// These are finite host checks, not checked-source or native-runtime evidence.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [baselinePath, candidatePath, outArg] = process.argv.slice(2);
if (!baselinePath || !candidatePath || !outArg) throw Error('BASE_API CANDIDATE_API FRESH_OUTPUT');
const root = path.resolve(import.meta.dirname, '../../../../..');
const out = path.resolve(outArg);
if (fs.existsSync(out) || !out.startsWith(root + '/selfhost/build/phase112/')) throw Error('Fresh Phase112 output required');
const pin = file => ({file: path.resolve(file), bytes: fs.statSync(file).size,
  sha256: crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const verify = row => assert.deepEqual(pin(row.file), row, 'Input changed');
async function load(file) {
  const receipt = JSON.parse(fs.readFileSync(path.join(path.dirname(file), 'report.json')));
  assert.ok(receipt.complete && receipt.checked, 'Checked API receipt required');
  verify(receipt.api);
  return (await import(pathToFileURL(path.resolve(file)))).default;
}
const baseline = await load(baselinePath), candidate = await load(candidatePath);
for (const name of ['p111_lower', 'nc_uses', 'nu_has']) assert.equal(typeof baseline[name], 'function', 'Baseline export: ' + name);
for (const name of ['p111_lower', 'p112_liveness_term', 'p112_liveness_uses', 'p112_liveness_args', 'nu_has']) assert.equal(typeof candidate[name], 'function', 'Candidate export: ' + name);
fs.mkdirSync(out, {recursive: true});
const inputs = [pin(import.meta.filename), pin(baselinePath), pin(candidatePath)];
const report = {kind: 'phase112-liveness-local-controls', complete: false, inputs, sets: [], lowering: [], scope: 'Finite raw-term hosted controls; no native, checked-request or universal-proof claim.'};
const save = () => fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
save();
const nil = {$: 'Nil'};
const list = xs => xs.reduceRight((tail, head) => ({$: 'Con', head, tail}), nil);
const term = (tag, kids = [], id = 0, name = '', quant = 0) =>
  ({$: 'KTerm', tag, name, id, quant, kids: list(kids), removed: nil, originBegin: 0, originEnd: 0});
const variable = (id, kids = []) => term('Var', kids, id);
const word = n => term('NWord', [], 0, String(n));
const bind = (id, value, extra = []) => term('Bind', [value, ...extra], id, '', 1);
const lets = (...children) => term('Let', children);
const mklet = (id, value, rest) => lets(bind(id, value), rest);
const env = ids => list(ids.map(id => ({$: 'NC_Binding', id, word: 'v_' + id, kind: {$: 'N_W64'}})));

// Independent occurrence oracle: Var is a leaf, all other children count;
// binder IDs and metadata carry no occurrence meaning.
function occurrenceIds(t, found = new Set()) {
  if (t.tag === 'Var') found.add(t.id);
  else for (let xs = t.kids; xs.$ === 'Con'; xs = xs.tail) occurrenceIds(xs.head, found);
  return found;
}
function trieIds(set, found = new Set()) {
  if (set.$ === 'NU_Leaf') found.add(set.key);
  else if (set.$ === 'NU_Node') { trieIds(set.left, found); trieIds(set.right, found); }
  else assert.equal(set.$, 'NU_Empty');
  return found;
}
const ordered = xs => [...xs].sort((a, b) => a - b);
function checkSet(name, t, plan = candidate.p112_liveness_term(t)) {
  const expected = ordered(occurrenceIds(t));
  const actual = ordered(trieIds(candidate.p112_liveness_uses(plan)));
  assert.deepEqual(actual, expected, name + ': candidate occurrences');
  assert.deepEqual(ordered(trieIds(baseline.nc_uses(t))), expected, name + ': mature occurrences');
  report.sets.push({name, expected});
}
const rawCases = [
  ['empty', lets()],
  ['singleton', lets(variable(1))],
  ['nested-singletons', lets(lets(lets(variable(1))))],
  ['binder-does-not-kill', lets(bind(7, variable(7)), variable(7))],
  ['nested-tail', lets(bind(1, word(4)), mklet(2, variable(1), variable(2)))],
  ['bind-extra-child', lets(bind(2, variable(1), [variable(9)]), variable(2))],
  ['var-is-leaf', variable(1, [variable(9)])],
  ['raw-var-head', lets(variable(1, [variable(9)]), variable(2))],
  ['wide-ids', lets(bind(4294967295, variable(2147483648)), variable(4294967295))],
  ['nested-value', lets(bind(2, mklet(1, variable(9), variable(1))), variable(2))],
];

try {
  for (const [name, t] of rawCases) checkSet(name, t);
  const suffix = mklet(11, variable(7), variable(11));
  const args = [variable(1), mklet(8, variable(2), variable(8)), variable(1)];
  // The frozen source defines nc_id(n) = 4294967295 - n. Assert this ordering
  // independently instead of using candidate-generated IDs as their own oracle.
  const prepared = candidate.p112_liveness_args('NCtr', 'Pair', list(args), nil, 100, 10, candidate.p112_liveness_term(suffix));
  const generatedIds = args.map((_, i) => 4294967295 - 100 - i);
  let cursor = prepared;
  for (let i = 0; i < args.length; i++) {
    assert.equal(cursor.$, 'P112LivenessLet');
    assert.equal(cursor.id, generatedIds[i]); cursor = cursor.rest;
  }
  let expectedArgs = mklet(10, term('NCtr', generatedIds.map(id => variable(id)), 0, 'Pair'), suffix);
  for (let i = args.length - 1; i >= 0; i--) expectedArgs = mklet(generatedIds[i], args[i], expectedArgs);
  checkSet('normalized-arguments-retain-suffix', expectedArgs, prepared);

  const loweringCases = [
    ...rawCases,
    ['value-duplication', lets(bind(2, variable(1)), term('NCtr', [variable(1), variable(2)], 0, 'Pair'))],
    ['value-discard', lets(bind(2, variable(1)), word(0))],
    ['constructor-normalization', lets(bind(3, term('Ctr', [variable(1), variable(2)], 0, 'Pair')), variable(3))],
    ['constructor-argument-cut', lets(bind(3, term('Ctr', [term('NCall', [variable(1)], 0, 'callee'), variable(2)], 0, 'Pair')), variable(3))],
    ['generic-call-cut', lets(bind(3, term('NCall', [variable(1)], 0, 'callee')), variable(3))],
    ['closure-value', lets(bind(3, term('Lam', [variable(4)], 4, '', 1)), variable(3))],
    ['unknown-primitive-error', lets(bind(3, term('NOp', [variable(1)], 0, 'unknown')), variable(3))],
    ['bad-word-error', lets(bind(3, term('NWord', [], 0, 'bad')), variable(3))],
  ];
  for (const [name, t] of loweringCases) {
    for (const ids of [[], [1, 2, 7, 9, 2147483648, 4294967295]]) {
      const before = baseline.p111_lower(nil, t, env(ids), 100);
      const after = candidate.p111_lower(nil, t, env(ids), 100);
      assert.deepEqual(after, before, name + ': exact complete P111Code');
      report.lowering.push({name, env: ids, error: after.error, fresh: after.fresh});
    }
  }
  inputs.forEach(verify); report.complete = true; save();
  console.log(JSON.stringify({complete: true, sets: report.sets.length, lowering: report.lowering.length, out}));
} catch (e) { report.error = String(e); save(); throw e; }
