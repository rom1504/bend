// Saved-JavaScript experiment, never a checked compiler artifact. No execution.
// Capture code at its original allocation site; do not inspect public metadata.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';

const argv = process.argv.slice(2), options = {};
for (let i = 0; i < argv.length; i += 2) {
  assert(['--manifest', '--out'].includes(argv[i]) && argv[i + 1]);
  assert(!options[argv[i]]); options[argv[i]] = argv[i + 1];
}
assert(options['--manifest'] && options['--out']);
const manifestFile = fs.realpathSync(options['--manifest']);
const out = path.resolve(options['--out']);
assert(!fs.existsSync(out), 'Use a fresh output directory');
const sha = x => createHash('sha256').update(x).digest('hex');
const identity = file => ({path: fs.realpathSync(file), bytes: fs.statSync(file).size,
  sha256: sha(fs.readFileSync(file))});
const acornModule = {exports: {}};
new Function('module', 'exports', process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'])(acornModule, acornModule.exports);
const parse = s => acornModule.exports.parse(s, {ecmaVersion: 'latest', sourceType: 'module'});
function nodes(root) {
  const result = [], pending = [root];
  while (pending.length) {
    const n = pending.pop();
    if (!n || typeof n !== 'object' || typeof n.type !== 'string') continue;
    assert(result.length < 2_000_000, 'AST node bound'); result.push(n);
    for (const [k, v] of Object.entries(n)) {
      if (['start', 'end', 'loc'].includes(k)) continue;
      if (Array.isArray(v)) { for (const child of v) pending.push(child); }
      else if (v && typeof v === 'object') pending.push(v);
    }
  }
  return result;
}
const id = (n, name) => n?.type === 'Identifier' && n.name === name;
const call = (n, name) => n?.type === 'CallExpression' && !n.optional && id(n.callee, name);
const member = (n, object, property) => n?.type === 'MemberExpression' && !n.computed && !n.optional && id(n.object, object) && id(n.property, property);
const globalName = n => n?.type === 'MemberExpression' && n.computed && !n.optional && id(n.object, 'G') &&
  n.property.type === 'Literal' && typeof n.property.value === 'string' ? n.property.value : null;
function bindingNames(pattern) {
  if (!pattern) return [];
  if (pattern.type === 'Identifier') return [pattern.name];
  if (pattern.type === 'AssignmentPattern') return bindingNames(pattern.left);
  if (pattern.type === 'RestElement') return bindingNames(pattern.argument);
  if (pattern.type === 'ArrayPattern') return pattern.elements.flatMap(bindingNames);
  if (pattern.type === 'ObjectPattern') return pattern.properties.flatMap(p => bindingNames(p.type === 'RestElement' ? p.argument : p.value));
  throw Error('Unsupported binding ' + pattern.type);
}
function derive(source) {
  assert(!source.includes('$p44Known'), 'Reserved identifier collision');
  const ast = parse(source), all = nodes(ast), edits = [], bindings = new Map();
  const functions = all.filter(n => ['FunctionDeclaration', 'FunctionExpression', 'ArrowFunctionExpression'].includes(n.type));
  const record = p => { for (const name of bindingNames(p)) bindings.set(name, (bindings.get(name) ?? 0) + 1); };
  for (const n of all) {
    if (n.type === 'VariableDeclarator' || n.type === 'ClassDeclaration') record(n.id);
    if (['FunctionDeclaration', 'FunctionExpression', 'ArrowFunctionExpression'].includes(n.type)) {
      if (n.id) record(n.id); n.params.forEach(record);
    }
    if (n.type === 'CatchClause') record(n.param);
    if (n.type.startsWith('Import') && n.local) record(n.local);
  }
  for (const name of ['G', 'get', 'fn', 'callOwned', 'apply', 'invokeExact'])
    assert.equal(bindings.get(name), 1, 'No shadowing of ' + name);
  const topFunctions = ast.body.filter(n => n.type === 'FunctionDeclaration');
  const invoke = topFunctions.find(n => n.id.name === 'invokeExact');
  const apply = topFunctions.find(n => n.id.name === 'apply');
  assert(invoke && apply);
  assert(![...nodes(invoke), ...nodes(apply)].some(n => id(n, 'known')), 'New runtime parameter must not capture existing identifiers');
  assert.deepEqual(invoke.params.map(n => n.name), ['f', 'all']);
  assert.equal(source.slice(apply.params[0].start, apply.params.at(-1).end), 'f,args,owned=false');
  const fallbackCalls = nodes(invoke.body).filter(n => n.type === 'ReturnStatement' &&
    n.argument?.type === 'CallExpression' && member(n.argument.callee, 'code', 'call') &&
    n.argument.arguments.length === 2 && member(n.argument.arguments[0], 'f', 'env') && id(n.argument.arguments[1], 'all'));
  assert.equal(fallbackCalls.length, 2, 'Exact original invokeExact fallback sites');
  const exactCalls = nodes(apply.body).filter(n => call(n, 'invokeExact'));
  assert.equal(exactCalls.length, 1);
  assert.deepEqual(exactCalls[0].arguments.map(n => n.name), ['f', 'all']);
  const callOwned = ast.body.flatMap(n => n.type === 'VariableDeclaration' ? n.declarations : []).find(n => id(n.id, 'callOwned'));
  assert(callOwned && source.slice(callOwned.init.start, callOwned.init.end) === '(f,args)=>force(apply(f,args,true))');

  const assignments = new Map(), captures = new Map(), refusals = [];
  for (const n of all) {
    if (n.type !== 'AssignmentExpression') continue;
    const name = globalName(n.left); if (name === null) continue;
    const list = assignments.get(name) ?? []; list.push(n); assignments.set(name, list);
  }
  for (const [name, writes] of assignments) {
    if (writes.length !== 1 || writes[0].operator !== '=') { refusals.push({name, reason: 'multiple-or-nonassignment-writes'}); continue; }
    const n = writes[0]; let value = n.right;
    // scalarCapture returns its second argument unchanged. It can observe that
    // fresh descriptor as before; code capture adds no property access or call.
    if (call(value, 'scalarCapture') && value.arguments.length >= 2 && value.arguments[0]?.value === name) value = value.arguments[1];
    if (!call(value, 'fn') || value.arguments.length < 2 || value.arguments[0].type !== 'Literal' ||
        !Number.isInteger(value.arguments[0].value) || value.arguments[0].value < 0 ||
        !['FunctionExpression', 'ArrowFunctionExpression'].includes(value.arguments[1].type)) {
      refusals.push({name, reason: 'not-literal-function-fn-code'}); continue;
    }
    // A public assignment must be a module-level generated statement, possibly
    // under its native-presence `if`; assignments inside function bodies refuse.
    if (functions.some(f => f.start < n.start && f.end > n.end)) {
      refusals.push({name, reason: 'nested-public-assignment'}); continue;
    }
    captures.set(name, {name, code: value.arguments[1], index: captures.size, callsites: 0});
  }
  for (const n of all) {
    if (!call(n, 'callOwned') || n.arguments.length !== 2 || !call(n.arguments[0], 'get')) continue;
    const [get, args] = n.arguments;
    if (get.arguments.length !== 2 || !id(get.arguments[0], 'G') || get.arguments[1].type !== 'Literal' ||
        typeof get.arguments[1].value !== 'string' || args.type !== 'ArrayExpression' || args.elements.some(e => !e || e.type === 'SpreadElement')) continue;
    const capture = captures.get(get.arguments[1].value); if (!capture) continue;
    capture.callsites++;
    edits.push({start: n.callee.start, end: n.callee.end, text: '$p44KnownCallOwned'});
    edits.push({start: n.end - 1, end: n.end - 1, text: ',$p44KnownInvoke' + capture.index});
  }
  const selected = [...captures.values()].filter(c => c.callsites > 0);
  if (!selected.length) return {text: source, selected: [], refusals, rewrittenCalls: 0, runtimeChanged: false};
  let declarations = '// Unchecked Phase44 saved-JavaScript known-call experiment.\n';
  for (const c of selected) {
    const code = '$p44KnownCode' + c.index, inv = '$p44KnownInvoke' + c.index;
    declarations += `let ${code};\nfunction ${inv}(code,f,all){return code===${code}?${code}.call(f.env,all):code.call(f.env,all);}\n`;
    edits.push({start: c.code.start, end: c.code.start, text: '(' + code + '=(0,'});
    edits.push({start: c.code.end, end: c.code.end, text: '))'});
  }
  edits.push({start: 0, end: 0, text: declarations});
  edits.push({start: invoke.params.at(-1).end, end: invoke.params.at(-1).end, text: ',known'});
  edits.push({start: apply.params.at(-1).end, end: apply.params.at(-1).end, text: ',known'});
  for (const r of fallbackCalls) {
    const a = r.argument; edits.push({start: a.start, end: a.start, text: 'known?known(code,f,all):'});
  }
  edits.push({start: exactCalls[0].end - 1, end: exactCalls[0].end - 1, text: ',known'});
  const owner = ast.body.find(n => n.type === 'VariableDeclaration' && n.declarations.includes(callOwned));
  edits.push({start: owner.end, end: owner.end, text: '\nconst $p44KnownCallOwned=(f,args,known)=>force(apply(f,args,true,known));'});
  edits.sort((a, b) => b.start - a.start || b.end - a.end);
  let text = source, previous = source.length;
  for (const e of edits) { assert(e.end <= previous, 'Overlapping AST edits'); text = text.slice(0, e.start) + e.text + text.slice(e.end); previous = e.start; }
  parse(text);
  return {text, selected: selected.map(({name, index, callsites}) => ({name, index, callsites})), refusals,
    rewrittenCalls: selected.reduce((n, c) => n + c.callsites, 0), runtimeChanged: true,
    originalRuntime: {invokeExact: sha(source.slice(invoke.start, invoke.end)), apply: sha(source.slice(apply.start, apply.end))}};
}

const manifest = JSON.parse(fs.readFileSync(manifestFile));
assert(manifest.complete && manifest.kind === 'bend-program-bundle' && manifest.roles.candidate);
assert.equal(manifest.roles.candidate.compiler?.kind, 'checked-development-attempt');
assert(manifest.cases.length > 0 && manifest.cases.length <= 256);
fs.mkdirSync(out); fs.mkdirSync(path.join(out, 'modules'));
fs.copyFileSync(import.meta.filename, path.join(out, 'consumed-known-call-derive-v1.mjs'));
const report = {kind: 'phase44-saved-js-known-call', complete: false, checked: false, sourceChecked: true,
  manifest: identity(manifestFile), producer: identity(import.meta.filename), modules: [], replacements: [],
  scope: 'Known-callee invoker specialization only; no runtime checks, property reads, partial/oversaturation behavior, forcing or exact-entry grants bypassed. Code captured at original closure creation, not by public descriptor snapshots. This is an unchecked diagnostic, not a production compiler.',
  limitations: ['Additional private JavaScript call frames may be visible through host stack inspection.', 'Only direct fn code functions, optionally wrapped in scalarCapture, are selected; matchers and exactCode wrappers are refused.', 'Module timing and validation must be measured independently; no performance claim follows from derivation.']};
const seen = new Map(); let bytes = 0;
for (const row of manifest.cases) {
  const m = row.modules.candidate, input = fs.realpathSync(path.resolve(path.dirname(manifestFile), m.path));
  let output = seen.get(input);
  if (!output) {
    const source = fs.readFileSync(input); bytes += source.length;
    assert(source.length > 0 && source.length <= 64 * 1024**2 && bytes <= 512 * 1024**2);
    assert.equal(sha(source), m.sha256); if (m.bytes !== undefined) assert.equal(source.length, m.bytes);
    const result = derive(source.toString('utf8'));
    output = path.join(out, 'modules', String(seen.size).padStart(2, '0') + '-' + path.basename(input));
    fs.writeFileSync(output, result.text, {flag: 'wx'}); delete result.text;
    report.modules.push({input: identity(input), output: identity(output), ...result}); seen.set(input, output);
  } else assert.equal(identity(input).sha256, m.sha256);
  report.replacements.push({id: row.id, file: output});
}
report.complete = true;
fs.writeFileSync(path.join(out, 'derive.json'), JSON.stringify(report, null, 2) + '\n', {flag: 'wx'});
fs.writeFileSync(path.join(out, 'prototype-args.json'), JSON.stringify(['--from', manifestFile,
  ...report.replacements.flatMap(r => ['--replace', r.id + '=' + r.file])], null, 2) + '\n', {flag: 'wx'});
console.log(JSON.stringify({complete: true, checked: false, modules: report.modules.length,
  rewrittenCalls: report.modules.reduce((n, m) => n + m.rewrittenCalls, 0), out}));
