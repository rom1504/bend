// Qualification and paired, in-process timing. No generated program is executed.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';

const [apiArg, outArg, nativeArg] = process.argv.slice(2);
if (!apiArg || !outArg || !nativeArg || process.argv.length !== 5)
  throw Error('Usage: pipeline-audit.mjs API FRESH_OUT NATIVE_CONTROLS_DIR');
const out = path.resolve(outArg), native = path.resolve(nativeArg);
fs.mkdirSync(out, {recursive: false});
const sha = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const pin = file => { const bytes = fs.readFileSync(file); return {file: path.resolve(file), bytes: bytes.length, sha256: sha(bytes)}; };
const write = (name, text) => { const file = path.join(out, name); fs.writeFileSync(file, text, {flag: 'wx'}); return pin(file); };
const inputs = new Map();
const input = file => { const p = pin(file); inputs.set(p.file, p); return p; };
const report = {kind: 'phase107-pipeline-audit', complete: false, passed: false,
  started: Date.now() / 1000, command: process.argv, node: process.version,
  api: input(apiArg), method: input(import.meta.filename), inputs: [], rows: [], timings: [],
  scope: 'Exact optimization/IR/emission comparison, not independent generated-program execution or a proof. Fixed4096 budgets. Single-entry closed programs.',
  clockScope: 'Warmed same-process optimization only, after corpus qualification. Input cloning, diagnostic verification, serialization and emission excluded. Both policies include their boundary checks; checked policy also includes standalone pass checks.',
  timingProtocol: {rounds: 3, pairsPerRound: 2, orders: ['checked,fast', 'fast,checked'], samplesPerPolicyPerCase: 6}};
const required = ['nx_pipeline_fast', 'nx_verify', 'nx_tail_optimize', 'nx_inline_demand',
  'nx_reachable', 'nx_inline_leaf', 'nx_memory_forward', 'nx_optimize', 'nx_json_program',
  'nx_c_program', 'nxq_program_fused', 'nx_workload', 'nx_i_fixture', 'nx_r_fixture', 'nx_l_fixture', 'nx_m_fixture'];

// Decode only the documented Nx JSON schema, then require an exact round trip.
const list = xs => xs.reduceRight((tail, head) => ({$: 'Con', head, tail}), {$: 'Nil'});
const typ = t => { const tag = {u32: 'NxU32', u64: 'NxU64', ptr: 'NxPtr', invalid: 'NxBad'}[t]; assert(tag, 'unknown type'); return {$: tag}; };
const param = p => ({$: 'NxParam', name: p.name, typ: typ(p.type)});
function expr(e) {
  switch (e.kind) {
    case 'const': return {$: 'NxConst', typ: typ(e.type), value: e.value};
    case 'var': return {$: 'NxVar', name: e.name};
    case 'bin': return {$: 'NxBin', op: e.op, left: expr(e.lhs), right: expr(e.rhs)};
    case 'call': return {$: 'NxCall', name: e.name, args: list(e.args.map(expr))};
    case 'alloc': return {$: 'NxAlloc', bytes: expr(e.bytes)};
    case 'load': return {$: 'NxLoad', typ: typ(e.type), ptr: expr(e.ptr), offset: e.offset};
    case 'ptradd': return {$: 'NxOffset', ptr: expr(e.ptr), bytes: expr(e.bytes)};
    case 'func': return {$: 'NxFunc', name: e.name};
    case 'icall': return {$: 'NxICall', callee: expr(e.callee), args: list(e.args.map(expr)), params: list(e.params.map(typ)), result: typ(e.result)};
    default: throw Error('unknown expression ' + e.kind);
  }
}
function stmt(s) {
  switch (s.kind) {
    case 'set': return {$: 'NxSet', name: s.name, value: expr(s.value)};
    case 'return': return {$: 'NxReturn', value: expr(s.value)};
    case 'if': return {$: 'NxIf', condition: expr(s.cond), yes: list(s.then.map(stmt)), no: list(s.else.map(stmt))};
    case 'while': return {$: 'NxWhile', condition: expr(s.cond), body: list(s.body.map(stmt))};
    case 'store': return {$: 'NxStore', typ: typ(s.type), ptr: expr(s.ptr), offset: s.offset, value: expr(s.value)};
    case 'free': return {$: 'NxFree', ptr: expr(s.ptr)};
    default: throw Error('unknown statement ' + s.kind);
  }
}
function decode(p) {
  assert.equal(p.version, 1);
  return {$: 'NxProgram', entry: p.entry, functions: list(p.functions.map(f => ({$: 'NxFunction', name: f.name,
    params: list(f.params.map(param)), result: typ(f.result), locals: list(f.locals.map(param)), body: list(f.body.map(stmt))})))};
}

try {
  const api = (await import(pathToFileURL(path.resolve(apiArg)))).default;
  for (const name of required) assert.equal(typeof api[name], 'function', 'missing export ' + name);
  input(path.join(import.meta.dirname, 'inline/pipeline.bend'));
  input(path.join(import.meta.dirname, 'inline/pipeline-controls.json'));
  const corpus = [], names = new Set();
  function add(name, raw, expectedValid, origin) {
    assert(!names.has(name), 'duplicate corpus name'); names.add(name);
    corpus.push({name, raw, expectedValid, origin});
  }
  function fixture(name, factory) {
    if (names.has(name)) return;
    const selected = api[factory](name);
    assert.equal(selected.$, 'Some', 'missing fixture ' + name);
    add(name, selected.value, name !== 'tail_dead', {factory});
  }
  const catalogs = [
    ['controls.json', 'nx_i_fixture'], ['tail-controls.json', 'nx_i_fixture'],
    ['reachable-controls.json', 'nx_r_fixture'], ['leaf-controls.json', 'nx_l_fixture'],
    ['memory-controls.json', 'nx_m_fixture']];
  for (const [file, factory] of catalogs) {
    const source = path.join(import.meta.dirname, 'inline', file); input(source);
    for (const name of [...new Set(JSON.parse(fs.readFileSync(source)).cases.map(c => c.fixture))]) fixture(name, factory);
  }
  fixture('cycle', 'nx_i_fixture');
  for (const name of ['text', 'list', 'tree', 'closure', 'tail', 'many', 'shared', 'shared_borrow', 'classify', 'shift', 'law_bridge'])
    fixture(name, 'nx_workload');

  const nativeReport = path.join(native, 'report.json'); input(nativeReport);
  const prior = JSON.parse(fs.readFileSync(nativeReport));
  assert.equal(prior.complete, true); assert.equal(prior.passed, true);
  const nativeFiles = [], refused = new Set(prior.refusals.map(r => r.name)); report.nativeRefusalsNotReexecuted = [];
  assert(Array.isArray(prior.selection.included) && prior.selection.included.length > 0);
  for (const name of [...prior.selection.included].sort()) {
    const file = path.join(native, name + '-raw-json-cache', 'program.json'), source = input(file);
    if (refused.has(name)) {assert.equal(source.bytes, 0, 'refused source has IR'); report.nativeRefusalsNotReexecuted.push({name, source});}
    else {assert(source.bytes > 0, 'accepted source missing IR'); nativeFiles.push(file);}
  }
  assert(nativeFiles.length > 0, 'no native source IR products');
  for (const file of nativeFiles) {
    const origin = input(file), json = JSON.parse(fs.readFileSync(file)), raw = decode(json);
    assert.deepStrictEqual(JSON.parse(api.nx_json_program(raw)), json, 'native JSON decoder round trip');
    add('native-' + path.basename(path.dirname(file)).replace(/-raw-json-cache$/, ''), raw, true, origin);
  }

  // Every malformed case retains a foldable subtree, exposing a missing outer guard.
  const base = {version: 1, entry: 'main', functions: [{name: 'main', params: [], result: 'u32', locals: [], body:
    [{kind: 'return', value: {kind: 'bin', op: 'add', lhs: {kind: 'const', type: 'u32', value: 1}, rhs: {kind: 'const', type: 'u32', value: 2}}}]}]};
  const bad = [
    ['missing_entry', p => {p.entry = 'missing';}],
    ['duplicate_function', p => {p.functions.push(structuredClone(p.functions[0]));}],
    ['unresolved_call', p => {p.functions.unshift({name: 'bad', params: [], result: 'u32', locals: [], body: [{kind: 'return', value: {kind: 'call', name: 'missing', args: []}}]});}],
    ['unresolved_address', p => {p.functions[0].locals.push({name: 'p', type: 'ptr'}); p.functions[0].body.unshift({kind: 'set', name: 'p', value: {kind: 'func', name: 'missing'}});}],
    ['undefined_local', p => {p.functions[0].body.unshift({kind: 'set', name: 'missing', value: {kind: 'const', type: 'u32', value: 0}});}],
    ['mismatched_type', p => {p.functions[0].locals.push({name: 'p', type: 'ptr'}); p.functions[0].body.unshift({kind: 'set', name: 'p', value: {kind: 'const', type: 'u32', value: 0}});}],
    ['dead_statements', p => {p.functions[0].body.push(structuredClone(p.functions[0].body[0]));}]];
  for (const [name, mutate] of bad) {const p = structuredClone(base); mutate(p); add('invalid-' + name, decode(p), false, {constructed: name});}

  const stages = [
    ['tail', p => api.nx_tail_optimize(p)], ['demand', p => api.nx_inline_demand(p, 4096)],
    ['reach1', p => api.nx_reachable(p)], ['leaf', p => api.nx_inline_leaf(p, 4096)],
    ['reach2', p => api.nx_reachable(p)], ['memory', p => api.nx_memory_forward(p)], ['fold', p => api.nx_optimize(p)]];
  function checked(raw, observations) {
    if (!api.nx_verify(raw)) return raw;
    let p = raw;
    for (const [name, run] of stages) {
      p = run(p);
      if (observations) {const valid = api.nx_verify(p); observations.push({stage: name, valid}); assert.equal(valid, true, 'invalid intermediate ' + name);}
    }
    return api.nx_verify(p) ? p : raw;
  }
  const expected = new Map();
  for (const item of corpus) {
    const {name, raw, expectedValid, origin} = item, row = {name, origin, expectedValid, stages: []}; report.rows.push(row);
    const rawObject = JSON.stringify(raw), original = api.nx_json_program(raw);
    row.before = write(name + '.before.json', original);
    assert.equal(api.nx_verify(raw), expectedValid, 'fixture validity ' + name);
    const checkedInput = structuredClone(raw), fastInput = structuredClone(raw);
    const reference = checked(checkedInput, row.stages), candidate = api.nx_pipeline_fast(fastInput);
    const referenceText = api.nx_json_program(reference), candidateText = api.nx_json_program(candidate);
    row.checked = write(name + '.checked.json', referenceText); row.fast = write(name + '.fast.json', candidateText);
    assert.deepStrictEqual(candidate, reference, 'complete IR mismatch ' + name);
    assert.equal(candidateText, referenceText, 'complete JSON mismatch ' + name);
    assert.equal(api.nx_verify(candidate), expectedValid, 'final validity ' + name);
    assert.equal(JSON.stringify(raw), rawObject, 'input mutated ' + name);
    assert.equal(JSON.stringify(checkedInput), rawObject, 'checked input mutated ' + name);
    assert.equal(JSON.stringify(fastInput), rawObject, 'fast input mutated ' + name);
    if (!expectedValid) {assert.equal(candidateText, original); assert.deepStrictEqual(candidate, raw);}
    else {
      row.emissions = [];
      for (const [ext, emit] of [['c', 'nx_c_program'], ['ssa', 'nxq_program_fused']]) {
        const a = api[emit](reference), b = api[emit](candidate);
        row.emissions.push({checked: write(name + '.checked.' + ext, a), fast: write(name + '.fast.' + ext, b)});
        assert.equal(a, b, 'complete emitted ' + ext + ' mismatch ' + name);
      }
    }
    row.passed = true; expected.set(name, referenceText);
  }

  const timedNames = ['many', 'text', 'shared', 'native-branches'];
  for (const name of timedNames) assert(names.has(name), 'missing timing case ' + name);
  for (let round = 0; round < 3; round++) for (const name of timedNames) {
    const item = corpus.find(x => x.name === name);
    for (const [pair, order] of [['AB', ['checked', 'fast']], ['BA', ['fast', 'checked']]]) for (const role of order) {
      const raw = structuredClone(item.raw), original = JSON.stringify(raw), startEpoch = Date.now() / 1000, start = performance.now();
      const result = role === 'checked' ? checked(raw) : api.nx_pipeline_fast(raw);
      const seconds = (performance.now() - start) / 1000, finishedEpoch = Date.now() / 1000;
      const text = api.nx_json_program(result), output = write(`timing-${name}-${round}-${pair}-${role}.json`, text);
      report.timings.push({name, round, pair, order, role, seconds, startEpoch, finishedEpoch, output});
      assert.equal(text, expected.get(name), 'timed complete product mismatch');
      assert.equal(api.nx_verify(result), true); assert.equal(JSON.stringify(raw), original, 'timed input mutation');
    }
  }
  report.summary = timedNames.map(name => {
    const roles = Object.fromEntries(['checked', 'fast'].map(role => {
      const samples = report.timings.filter(x => x.name === name && x.role === role).map(x => x.seconds);
      const sorted = [...samples].sort((a, b) => a - b); assert.equal(samples.length, 6);
      return [role, {samples, medianSeconds: (sorted[2] + sorted[3]) / 2}];
    }));
    return {name, roles, fastOverChecked: roles.fast.medianSeconds / roles.checked.medianSeconds};
  });
  report.counts = {programs: corpus.length, valid: corpus.filter(x => x.expectedValid).length,
    invalid: corpus.filter(x => !x.expectedValid).length, nativeSourceGraphs: nativeFiles.length, timingSamples: report.timings.length};
  for (const old of inputs.values()) assert.deepStrictEqual(pin(old.file), old, 'input changed during audit');
  report.complete = true; report.passed = true;
} catch (error) {
  report.error = {message: error.message, stack: error.stack}; process.exitCode = 1;
} finally {
  report.inputs = [...inputs.values()]; report.finished = Date.now() / 1000;
  report.wallSeconds = report.finished - report.started;
  write('method.mjs', fs.readFileSync(import.meta.filename));
  write('report.json', JSON.stringify(report, null, 2) + '\n');
  console.log(JSON.stringify({complete: report.complete, passed: report.passed, counts: report.counts, error: report.error?.message, summary: report.summary}));
}
