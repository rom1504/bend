// Diagnostic exports from an actual checked API; root owns bounded execution.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [configArg, outArg] = process.argv.slice(2);
assert(configArg && outArg, 'usage: controls.mjs CONFIG NEW_OUT');
const config = JSON.parse(fs.readFileSync(configArg));
const candidate = config.candidate ?? config;
const out = path.resolve(outArg);
fs.mkdirSync(out, {recursive: false});
const identity = file => ({file: fs.realpathSync(file), sha256: createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const report = {kind: 'phase42-request-facts-controls', complete: false, pass: false,
  inputs: [import.meta.filename, configArg, candidate.api].map(identity), observations: []};
const list = xs => xs.reduceRight((tail, head) => ({$: 'Con', head, tail}), {$: 'Nil'});
const unlist = xs => {const out = []; for (; xs.$ === 'Con'; xs = xs.tail) out.push(xs.head); assert.equal(xs.$, 'Nil'); return out;};
const term = (tag, name = '', kids = [], id = 0, quant = 0) => ({$: 'KTerm', tag, name, id, quant,
  kids: list(kids), removed: list([]), originBegin: 0, originEnd: 0});
const absent = () => term('Absent');
const ty = name => term('ADT', name);
const all = (a, b, id) => term('All', '', [a, b], id, 2);
const lam = (id, body) => term('Lam', '', [body], id, 2);
const app = (name, args) => args.reduce((f, a) => term('App', '', [f, a]), term('Ref', name));
const def = (name, typ, value, arity = 1, kind = 'Def', native = false, ctors = []) =>
  ({$: 'KDef', name, kind, arity, templates: 0, typ, value, ctors: list(ctors), native, unsafe: false});
const kind = () => term('Typ', '', [term('Qua', '', [], 0, 2)]);
const lit = n => ({$: 'KLiteral', kind: 'U32', number: n, text: '', originBegin: 0, originEnd: 0});

try {
  const original = fs.readFileSync(candidate.api, 'utf8');
  const names = ['book_context', 'book_put', 'lookup', 'j_component_plan', 'j_direct_plan',
    'j_component_cached', 'j_direct_cached', 'j_plan_context', 'j_plan_fact', 'j_plan_lookup',
    'j_plan_scan'];
  for (const name of names) assert.equal(original.split('function $' + name + '$(').length, 2, name);
  const diagnostic = path.join(out, 'diagnostic-api.mjs');
  const addition = '\nexport const phase42Facts={' + names.map(n => n + ':(...a)=>run_loop($' + n + '$(...a))').join(',') + '};\n';
  fs.writeFileSync(diagnostic, original + addition, {flag: 'wx'});
  report.diagnostic = {...identity(diagnostic), parentSha256: report.inputs[2].sha256, unchangedPrefixBytes: Buffer.byteLength(original)};
  const api = (await import(pathToFileURL(diagnostic))).phase42Facts;
  const rows = [];
  for (const [name, constructors] of [['U32', ['U32']], ['Word.Nil', ['WNil']], ['Word.Con', ['WCon']], ['Bool', ['False', 'True']]])
    rows.push(def(name, kind(), absent(), 0, 'ADT', true, constructors.map(n => def(n, ty(name), absent(), 0, 'Ctr', true))));
  rows.push(def('Word', kind(), absent(), 0, 'Def', true));
  const id = def('facts_id', all(ty('U32'), ty('U32'), 101), lam(101, term('Var', '', [], 101)));
  const caller = def('facts_caller', all(ty('U32'), ty('U32'), 102), lam(102, app(id.name, [term('Var', '', [], 102)])));
  rows.push(id, caller);
  const source = api.book_context(list(rows));
  const prepared = api.j_plan_context(source, list([id, caller]));
  assert.strictEqual(prepared.head.ctors.head, source.head.ctors.head, 'original source index identity');
  assert.strictEqual(prepared.tail, source.tail, 'original source definitions identity');
  assert.equal(prepared.head.arity, source.head.arity, 'maximum binder bound');
  assert.equal(prepared.head.ctors.tail.head.kind, 'JSPlanContext');
  assert.equal(unlist(prepared.head.ctors).length, 2);
  assert.equal(api.lookup(prepared, '$js.plans').kind, 'Absent', 'private facts unreachable by source lookup');
  report.observations.push({name: 'private-request-metadata-and-source-identity', pass: true});

  const direct = api.j_direct_plan(source, id);
  assert.equal(direct.valid, true, 'positive direct planner fixture');
  assert.deepEqual(api.j_direct_cached(prepared, id.name), direct);
  const fact = api.j_plan_lookup(prepared, id.name, true);
  assert.equal(fact.kind, 'JSPlanFact');
  assert.deepEqual(fact.ctors, direct.defs, 'exact ordered graph');
  assert.equal(fact.arity, direct.fuel, 'exact remaining fuel');
  assert.equal(fact.native, direct.valid);
  assert.deepEqual(api.j_component_cached(prepared, id.name), api.j_component_plan(source, id), 'component refusal');
  assert.equal(api.j_plan_lookup(prepared, id.name, false).kind, 'JSPlanFact', 'negative component facts retained');
  report.observations.push({name: 'positive-direct-and-negative-component-roundtrip', pass: true, directFuel: direct.fuel, directDefs: unlist(direct.defs).map(d => d.name)});

  const changed = {...id, value: lam(101, lit(17))};
  assert.notDeepEqual(api.j_direct_plan(prepared, changed), direct, 'arbitrary same-name definition uses logical planner');
  const updated = api.book_put(prepared, changed);
  assert.equal(unlist(updated.head.ctors).length, 1, 'source update discards facts');
  assert.equal(api.j_plan_lookup(updated, id.name, true).kind, 'Absent');
  assert.deepEqual(api.j_direct_cached(updated, id.name), api.j_direct_plan(updated, changed));
  assert.deepEqual(api.j_direct_cached(source, id.name), direct, 'context miss uses logical planner');
  report.observations.push({name: 'same-name-original-identity-and-source-update-invalidation', pass: true});

  const pending = api.book_context(list([]));
  assert.strictEqual(api.j_plan_scan(source, list([caller.value]), 0, pending), pending, 'discovery exhaustion reduces only reuse');
  const second = api.j_plan_context(prepared, list([id]));
  assert.equal(unlist(second.head.ctors).length, 2, 'fresh entry replaces prior payload');
  assert.equal(api.j_plan_lookup(second, id.name, true).kind, 'Absent', 'prior direct facts do not leak to new selection');
  assert.deepEqual(api.j_direct_cached(second, id.name), direct, 'fresh miss retains exact plan');
  report.observations.push({name: 'discovery-exhaustion-and-fresh-request-scope', pass: true});

  const failed = {$: 'JPure', defs: list([caller, id]), fuel: 23, valid: false};
  const failedFact = api.j_plan_fact('negative-with-graph', failed);
  assert.deepEqual(failedFact.ctors, failed.defs);
  assert.equal(failedFact.arity, 23);
  assert.equal(failedFact.native, false);
  report.observations.push({name: 'nonempty-refused-graph-and-fuel-retained', pass: true});
  assert.deepEqual(identity(candidate.api), report.inputs[2], 'checked API unchanged');
  report.complete = report.pass = true;
} catch (error) {
  report.error = String(error?.stack ?? error);
  process.exitCode = 1;
} finally {
  fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n', {flag: 'wx'});
}
console.log(JSON.stringify(report));
