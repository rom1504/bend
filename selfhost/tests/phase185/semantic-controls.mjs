#!/usr/bin/env bun
// Observation/transport only. The checked Bend API owns lowering, verification
// and both emitters. Literal C observations are independent of emitted IR.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';
import {spawnSync} from 'node:child_process';
import {pin, verify, requireThat as need, workspace} from '../../tools/build/hosted.mjs';

const own = fileURLToPath(import.meta.url), args = {};
for (let i = 2; i < process.argv.length; i += 2) {
  const key = process.argv[i], value = process.argv[i + 1];
  need(['--api', '--assets', '--out'].includes(key) && value && !Object.hasOwn(args, key), 'Unknown, incomplete, or duplicate option: ' + key);
  args[key] = value;
}
for (const key of ['--api', '--assets', '--out']) need(args[key], 'Required option: ' + key);
const out = path.resolve(args['--out']);
need(out.startsWith(workspace + '/selfhost/build/') && !fs.existsSync(out), 'Fresh guarded selfhost/build output required');
fs.mkdirSync(out, {recursive: true});
const driverSnapshot = path.join(out, 'driver.mjs');
fs.copyFileSync(own, driverSnapshot, fs.constants.COPYFILE_EXCL);
const fixture = (phase, name) => path.join(workspace, 'selfhost/tests', phase, name);
const read = file => JSON.parse(fs.readFileSync(file, 'utf8'));
const same = (a, b) => a?.bytes === b?.bytes && a?.sha256 === b?.sha256;
const report = {
  kind: 'phase185-native-semantic-controls', version: 1, complete: false,
  driver: {entry: own, snapshot: pin(driverSnapshot)},
  inputs: [pin(driverSnapshot), pin(process.execPath), pin(path.join(workspace, 'selfhost/tools/build/hosted.mjs'))],
  jobs: [], artifacts: [], rows: {}, machine: [], linkedRuntime: null,
  scope: 'Checked B1 compiler-data controls and finite QBE/x86 machine observations. No production runtime provider is linked; the optional constructor, packed-take, frame, floating-routing and scratch-barrier observers supply explicitly isolated slow-helper stubs. Source acceptance comes from the exact hosted acquisition receipt; no independent kernel, ownership, bootstrap, installed-image, or broad-conformance claim.',
};
const save = () => fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
const record = file => { const value = pin(file); report.artifacts.push(value); return value; };
const write = (name, text) => {
  need(typeof text === 'string' && Buffer.byteLength(text) < 16 * 1024 * 1024, 'Bounded text artifact required');
  const file = path.join(out, name); fs.writeFileSync(file, text, {flag: 'wx'}); record(file); return file;
};
const list = (xs, bound = 10000) => {
  const values = [];
  while (xs?.$ === 'Con') {
    need(values.length < bound, 'Unexpected or cyclic fixture list'); values.push(xs.head); xs = xs.tail;
  }
  need(xs?.$ === 'Nil', 'Malformed fixture list'); return values;
};
const exact = (actual, expected, label) => need(JSON.stringify(actual) === JSON.stringify(expected), label + ' differs');
function run(label, command, expected) {
  const begin = performance.now(), env = {...process.env};
  for (const key of ['LD_PRELOAD', 'LD_AUDIT', 'BENDRTS', 'NODE_OPTIONS', 'NODE_PATH']) delete env[key];
  const result = spawnSync(command[0], command.slice(1), {cwd: workspace, env, encoding: 'utf8', timeout: 15000, maxBuffer: 4 * 1024 * 1024});
  const stdout = write(label + '.stdout', result.stdout ?? ''), stderr = write(label + '.stderr', result.stderr ?? '');
  report.jobs.push({label, command, status: result.status, signal: result.signal, error: result.error?.message ?? null,
    seconds: (performance.now() - begin) / 1000, stdout: pin(stdout), stderr: pin(stderr)});
  save(); need(result.status === 0 && !result.signal && !result.error, label + ' failed');
  if (expected !== undefined) need(result.stdout === expected && result.stderr === '', label + ' literal observations differ');
}

const boolNames = ['p185bc_or', 'p185bc_xor', 'p185bc_or_output_alias', 'p185bc_xor_output_alias',
  'p185bc_or_helper_alias', 'p185bc_xor_helper_alias', 'p185bc_or_nearby_prefix'];
const boolRows = ['verified-functions', 'or-native', 'xor-native', 'literal-native', 'old-temporary-alias',
  'reserved-left-snapshot', 'reserved-right-snapshot', 'reserved-left-normalizer', 'reserved-right-normalizer',
  'reserved-left-condition', 'reserved-right-condition', 'reserved-combined-condition', 'reserved-future-prefix',
  'nearby-prefix', 'arity-zero', 'arity-one', 'arity-three', 'unrelated-fallback'].map(name => name + '=1');
const factRows = ['all-binary-bools', 'unary-is-zero', 'other-opcodes-unknown', 'binary-wrong-arity', 'zero-arity',
  'large-arity', 'wrong-symbol', 'u32-result', 'pointer-result', 'high-id', 'high-count', 'dynamic-id', 'dynamic-count',
  'exact-local-id-stays-conservative', 'constructor-id', 'state-identity', 'state-width', 'id-width', 'count-width',
  'buffer-width', 'buffer-null', 'buffer-state', 'buffer-unknown', 'missing-argument', 'extra-argument',
  'packed-test-folded', 'branch-assumptions', 'copy-propagates', 'call-overwrite-kills', 'load-overwrite-kills',
  'direct-call-overwrite-kills', 'unknown-branch-join', 'original-and-candidate-verify',
  'verifier-rejects-scratch-redefinition', 'verifier-rejects-short-buffer'].map(name => 'PASS fact-' + name);
const hygieneRows = ['valid-ir', 'hidden-result-parameter', 'reserved-prefix', 'nested-local', 'nested-alloca',
  'call-destination', 'segment-local', 'segment-alloca', 'ordinary-accepted', 'nearby-prefix-accepted'].map(name => name + '=1');
const constructorRows = ['one', 'two', 'three', 'four', 'class-one', 'class-two', 'class-three', 'class-four',
  'hot-refused', 'zero-refused', 'large-refused', 'wrong-count-refused', 'absent-ctor-refused', 'missing-marker-refused',
  'counter-limit-refused', 'numeric-cid-refused', 'high-count-refused', 'state-refused', 'buffer-refused',
  'result-type-refused', 'hot-byte-identical', 'other-import-byte-identical', 'exact-two-fallbacks', 'descriptor-guard',
  'bin-guard', 'field-snapshot', 'sized-fallback', 'tag-preserved', 'ids-preserved', 'maximum-cid',
  'oversize-cid-refused', 'memory-verifier-unchanged'].map(name => name + '=1');
const packedTakeRows = ['verified-functions', 'ordinary-one', 'ordinary-zero-refused', 'ordinary-two-refused',
  'special-refused', 'unqualified-refused', 'symbol-refused', 'function-id-refused', 'constructor-word-refused',
  'literal-admitted', 'reserved-word', 'reserved-guard', 'reserved-expected', 'reserved-payload', 'reserved-other-site',
  'nearby-prefix', 'special-byte-identical', 'wide-byte-identical', 'zero-byte-identical', 'identity-unresolved-rejected',
  'snapshot-first', 'tag-and-cid', 'payload-forty-bits', 'original-fallback', 'original-field-load', 'original-status'].map(name => name + '=1');
const transientRows = ['verified', 'chain-promoted', 'chain-reuses', 'same-statement-overlap', 'five-registers',
  'pressure-fallback', 'parameter-fallback', 'dead-write-extends', 'cross-branch-fallback', 'call-arguments-fallback',
  'cross-call-fallback', 'call-result-fallback', 'after-call-promoted', 'again-values-promoted', 'setup-fallback',
  'pointer-promoted', 'buffer-kept', 'runtime-argument-fallback', 'runtime-result-fallback', 'callee-home-kept',
  'size-cap', 'read-before-definition', 'reserved-name'].map(name => 'PASS transient-' + name);
const deadRows = ['dead-chain-removed', 'dead-load-retained', 'dead-load-consumer-removed', 'alloca-retained',
  'dead-call-retained', 'call-consumer-removed', 'branch-join-retained', 'entry-value-live-across-again'].map(name => name + '=1');
const frameRows = ['scoped-one', 'scoped-zero', 'scoped-eight', 'case-seven', 'unscoped-refused', 'foreign-buffer-refused',
  'ordinary-context-unchanged', 'case-eight-refused', 'forged-suffix-refused', 'count-nine-refused', 'counter-bound-refused',
  'unknown-fid-refused', 'runtime-fid-refused', 'numeric-fid-refused', 'high-count-refused', 'state-refused',
  'result-width-refused', 'other-import-refused', 'global-name-alone-refused', 'verifier-proves-valid',
  'verifier-rejects-wrong-arity', 'verifier-rejects-noncontinuation', 'verifier-rejects-short-buffer',
  'factory-excludes-user-namespace', 'scoped-call-eliminated', 'unscoped-call-retained', 'capture-load', 'result-zero'].map(name => name + '=1');
const floatingRows = ['verified', 'binary-ten-supported', 'conversion-fallback', 'sqrt-fallback', 'bits-fallback',
  'wrong-arity', 'high-op', 'high-count', 'dynamic-op', 'dynamic-count', 'integer-fallback', 'alternate-buffer',
  'fusion-buffer', 'wrong-state', 'state-width', 'nonlocal-buffer', 'buffer-width', 'result-width', 'wrong-symbol',
  'noncall', 'short-buffer-refused'].map(name => name + '=1');
const scratchRows = ['verified', 'exact-cells', 'source-mutation', 'overlapping-widths', 'disjoint-widths',
  'branch-barrier', 'call-barrier', 'again-local-only', 'identity-reassignment', 'reserved-identity',
  'setup-not-carried', 'exact-type-only', 'bounds-refused', 'alias-store-barrier', 'load-overwrites-source',
  'sixteen-cell-cap'].map(name => name + '=1');
const registerRows = ['verified', 'nine-physical-homes', 'stack-fallback', 'unsupported-fallback',
  'rhs-snapshot-first', 'self-load-omitted', 'wide-immediate'].map(name => name + '=1');
const descriptorRows = ['caps-nine', 'caps-eleven', 'caps-thirteen', 'caps-fifteen', 'caps-five-guarded',
  'caps-eight-guarded', 'caps-unknown-guarded', 'caps-high-guarded', 'abi-guarded', 'size-guarded',
  'count-mismatch-guarded', 'arity-mismatch-guarded', 'hot-mismatch-guarded', 'invalid-hot-guarded',
  'missing-tables-guarded', 'duplicate-header-guarded', 'manual-ids-guarded', 'old-proof-revalidated',
  'old-proof-cleared', 'old-proof-missing-cleared', 'foreign-metadata-unqualified', 'foreign-metadata-preserved',
  'paired-guard-eliminated', 'manual-guard-retained', 'cap-mismatch-guard-retained',
  'allocation-miss-fallback-retained', 'ids-preserved'].map(name => name + '=1');

// Explicit independent word/label table. Do not derive truth from a production
// normalization helper, the emitted instructions, or the returned Bend labels.
const boolWords = ['0000000000000000', '0000000000000001', '0000000000000002', '00000000ffffffff',
  '0000000100000001', '8000000000000000', '8000000000000001', '01002a0000000000',
  '01002affffffffff', '81002a0000000000', '81002affffffffff', '00002a0000000000',
  '02002a0000000000', '0100290000000000', '01002b0000000000', 'ffffffffffffffff', '810029ffffffffff'];
const boolTruths = [0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0];
// Fixed external ABI spellings; this encodes fixture identifiers, not IR.
const symbol = name => 'p113d_FID_' + [...name].map(c => c.codePointAt(0) + '_').join('');
function boolObserver() {
  return `#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
${boolNames.map((name, i) => `extern uint64_t f${i}(void *, uint64_t, uint64_t) __asm__("${symbol(name)}");`).join('\n')}
typedef uint64_t (*Binary)(void *, uint64_t, uint64_t);
static Binary functions[7] = {f0,f1,f2,f3,f4,f5,f6};
static const char *names[7] = {${boolNames.map(name => JSON.stringify(name)).join(',')}};
static const uint64_t words[17] = {${boolWords.map(word => 'UINT64_C(0x' + word + ')').join(',')}};
static const unsigned truth[17] = {${boolTruths.join(',')}};
static const unsigned is_xor[7] = {0,1,0,1,0,1,0};
int main(void) {
  uint64_t state[261];
  for (unsigned n=0; n<261; ++n) state[n] = UINT64_C(0x9b7d5f311357ace0);
  for (unsigned f=0; f<7; ++f) for (unsigned a=0; a<17; ++a) for (unsigned b=0; b<17; ++b) {
    const uint64_t expected = is_xor[f] ? truth[a] != truth[b] : truth[a] || truth[b];
    const uint64_t actual = functions[f](state, words[a], words[b]);
    if (actual != expected) {
      fprintf(stderr,"%s[%u,%u]: got %016" PRIx64 ", expected %" PRIu64 "\\n", names[f],a,b,actual,expected);
      return 1;
    }
    for (unsigned n=0; n<261; ++n) if (state[n] != UINT64_C(0x9b7d5f311357ace0)) return 2;
  }
  puts("phase185 bool controls pass: 2023");
  return 0;
}
`;
}

save();
try {
  const authority = read(args['--api']), assets = read(args['--assets']);
  need(authority.kind === 'bend-checked-hosted-api' && authority.complete && authority.checked && !authority.error,
    'Complete upstream-checked hosted API receipt required');
  need(assets.kind === 'bend-build-assets' && assets.complete && authority.upstream?.revision === assets.upstream,
    'Hosted API and current assets upstream revisions differ');
  need(Array.isArray(authority.inputs) && Array.isArray(authority.exports), 'Authenticated API input/export inventories required');
  report.authority = {receipt: pin(args['--api']), source: authority.source, api: authority.api, upstream: authority.upstream};
  report.inputs.push(report.authority.receipt, pin(args['--assets']), authority.api, authority.source, ...authority.inputs);
  const tool = key => {
    const expected = assets.assets?.[key]; need(expected, 'Missing asset: ' + key);
    const actual = pin(path.resolve(workspace, expected.file)); need(same(actual, expected), 'Asset differs: ' + key);
    report.inputs.push(actual); return actual.file;
  };
  const qbe = tool('qbe'), assembler = tool('assembler'), linker = tool('linker');
  need(same(pin(process.execPath), assets.assets?.bun), 'Pinned Bun engine required');
  for (const key of ['upstream-bend', 'upstream-comp', 'base']) {
    const file = tool(key), expected = pin(file);
    need(authority.inputs.some(input => input.file === expected.file && same(input, expected)), 'API lacks exact pinned upstream authority: ' + key);
  }
  for (const target of ['qbe', 'x86']) {
    const policy = assets.toolchains?.[target];
    need(policy?.target === 'amd64_sysv' && ['assemblerFlags', 'linkerFlags', 'libraries'].every(key => Array.isArray(policy[key])),
      'Explicit maintained AMD64 SysV policy required: ' + target);
  }
  report.toolchains = {qbe: assets.toolchains.qbe, x86: assets.toolchains.x86};
  for (const name of ['bool-controls.bend', 'fact-controls.bend', 'x86-controls.bend', 'x86-controls.c']) report.inputs.push(pin(fixture('phase185', name)));
  report.inputs.forEach(verify);
  const api = (await import(pathToFileURL(authority.api.file))).default;
  const required = ['p185bc_ids', 'p185bc_functions', 'p185bc_validate', 'p185bc_words', 'p185bc_truths', 'p185bc_controls',
    'p185fc_controls', 'p185x_functions', 'p185x_validate', 'x181_direct', 'p113e_private', 'missing'];
  for (const name of required) need(authority.exports.includes(name) && typeof api?.[name] === 'function', 'Missing checked export: ' + name);
  need(api.p185bc_validate() === '', 'Bool fixtures fail unchanged IR verifier');
  need(api.p185x_validate() === '', 'Immediate fixtures fail unchanged IR verifier');
  report.rows.bool = list(api.p185bc_controls()); exact(report.rows.bool, boolRows, 'Bool admission rows');
  report.rows.facts = list(api.p185fc_controls()); exact(report.rows.facts, factRows, 'Fact rows');
  exact(list(api.p185bc_words()).map(word => {
    need(word?.$ === 'N111Const' && [word.lo, word.hi].every(n => Number.isInteger(n) && n >= 0 && n <= 4294967295), 'Bounded raw word required');
    return ((BigInt(word.hi) << 32n) | BigInt(word.lo)).toString(16).padStart(16, '0');
  }), boolWords, 'Raw-word inventory');
  exact(list(api.p185bc_truths()), boolTruths, 'Independent truth labels');
  const bools = list(api.p185bc_functions()), immediates = list(api.p185x_functions());
  exact(bools.map(fn => fn.name), boolNames, 'Bool function inventory');
  exact(immediates.map(fn => fn.name), ['p185a', 'p185b', 'p185c', 'p185d'], 'Immediate function inventory');
  const emptyIds = {$: 'N111Ids', functions: api.missing(), constructors: api.missing()};
  const boolC = write('bool-observer.c', boolObserver()), observerAssembly = {};
  function observer(label, source) {
    const assembly = path.join(out, label + '-observer.s');
    run(label + '-compile-observer', [linker, '-std=c11', '-O2', '-fno-pie', '-S', source, '-o', assembly]);
    record(assembly); observerAssembly[label] = assembly; return assembly;
  }
  observer('bool', boolC); observer('immediate', fixture('phase185', 'x86-controls.c'));
  function machine(label, target, functions, ids, cAssembly, expected, extraAssembly = [], extraObjects = [], x86Emitter = 'x181_direct') {
    const row = {label, target, names: functions.map(fn => fn.name), emitter: target === 'qbe' ? 'p113e_private' : x86Emitter,
      extraAssembly: extraAssembly.map(pin), irVerified: true, complete: false};
    report.machine.push(row); save();
    let text = '';
    for (const fn of functions) {
      need(fn?.$ === 'P113DFunction', 'Direct fixture required');
      if (target === 'qbe') {
        const emitted = api.p113e_private(fn, ids); need(typeof emitted === 'string' && emitted.length > 0, 'Missing QBE function'); text += emitted;
      } else {
        const emitted = api[x86Emitter](fn, ids);
        need(emitted?.$ === 'X181Output' && emitted.error === '', 'x86 refused ' + fn.name + ': ' + emitted?.error);
        const chunks = list(emitted.chunks); need(chunks.every(chunk => typeof chunk === 'string'), 'Assembly chunks must be strings'); text += chunks.join('');
      }
    }
    const generated = write(label + (target === 'qbe' ? '.ssa' : '.s'), text);
    row.emitted = pin(generated);
    let assembly = generated;
    if (target === 'qbe') {
      assembly = path.join(out, label + '.s'); run(label + '-qbe', [qbe, '-t', 'amd64_sysv', '-o', assembly, generated]); record(assembly);
    }
    // Keep all emitted bytes unchanged. A single assembler unit lets the C
    // observer reference QBE's private symbols without host-generated wrappers.
    const combined = write(label + '-combined.s', [cAssembly, ...extraAssembly, assembly].map(file => fs.readFileSync(file, 'utf8')).join('\n') + '\n.section .note.GNU-stack,"",@progbits\n');
    const object = path.join(out, label + '.o'), binary = path.join(out, label);
    const policy = assets.toolchains[target];
    run(label + '-assemble', [assembler, ...policy.assemblerFlags, '-o', object, combined]); record(object);
    run(label + '-link', [linker, ...policy.linkerFlags, object, ...extraObjects, ...policy.libraries, '-o', binary]); record(binary);
    run(label + '-execute', [binary], expected); row.binary = pin(binary); row.complete = true; save();
  }
  function moduleMachine(label, target, text, names, cAssembly, expected, metadata) {
    need(typeof text === 'string' && text.length > 0, 'Nonempty emitted oracle module required');
    const row = {label, target, names, ...metadata, complete: false}; report.machine.push(row); save();
    const generated = write(label + (target === 'qbe' ? '.ssa' : '.s'), text); row.emitted = pin(generated);
    let assembly = generated;
    if (target === 'qbe') {
      assembly = path.join(out, label + '.s');
      run(label + '-qbe', [qbe, '-t', 'amd64_sysv', '-o', assembly, generated]); record(assembly);
    }
    const combined = write(label + '-combined.s', [cAssembly, assembly].map(file => fs.readFileSync(file, 'utf8')).join('\n') + '\n.section .note.GNU-stack,"",@progbits\n');
    const object = path.join(out, label + '.o'), binary = path.join(out, label), policy = assets.toolchains[target];
    run(label + '-assemble', [assembler, ...policy.assemblerFlags, '-o', object, combined]); record(object);
    run(label + '-link', [linker, ...policy.linkerFlags, object, ...policy.libraries, '-o', binary]); record(binary);
    run(label + '-execute', [binary], expected); row.binary = pin(binary); row.complete = true; save();
  }
  machine('bool-qbe', 'qbe', bools, api.p185bc_ids(), observerAssembly.bool, 'phase185 bool controls pass: 2023\n');
  machine('bool-x86', 'x86', bools, api.p185bc_ids(), observerAssembly.bool, 'phase185 bool controls pass: 2023\n');
  report.boolObservations = {functions: 7, words: 17, pairsPerFunction: 289, perTarget: 2023, targets: ['qbe', 'x86'], total: 4046, fullU64Results: true, stateCanaryWords: 261};
  machine('immediate-x86', 'x86', immediates, emptyIds, observerAssembly.immediate, 'phase185 immediate controls pass\n');

  function optional(names, label) {
    const selected = names.filter(name => authority.exports.includes(name));
    need(selected.length === 0 || selected.length === names.length, 'Partial ' + label + ' export set');
    for (const name of selected) need(typeof api[name] === 'function', 'Missing checked export: ' + name);
    return selected.length === names.length;
  }
  if (optional(['p185cp_validate', 'p185cp_functions', 'p185cp_emit_setup'], 'copy')) {
    for (const name of ['x86-copy-controls.bend', 'x86-copy-controls.c']) report.inputs.push(pin(fixture('phase185', name)));
    need(api.p185cp_validate() === '', 'Original/transformed copy fixtures fail unchanged IR verifier');
    const functions = list(api.p185cp_functions());
    exact(functions.map(fn => fn.name), ['p185e', 'p185f', 'p185g', 'p185h', 'p185i', 'p185k'], 'Copy function inventory');
    const setup = api.p185cp_emit_setup();
    need(setup?.$ === 'X181Output' && setup.error === '', 'Setup-snapshot emission refused: ' + setup?.error);
    const chunks = list(setup.chunks); need(chunks.length > 0 && chunks.every(chunk => typeof chunk === 'string'), 'Setup assembly chunks required');
    const setupFile = write('copy-setup.s', chunks.join(''));
    const cAssembly = observer('copy', fixture('phase185', 'x86-copy-controls.c'));
    machine('copy-x86', 'x86', functions, emptyIds, cAssembly, 'phase185 copy controls pass\n', [setupFile]);
    report.copies = {included: true, functions: 7, directFunctions: 6, setupFunction: 'p185j', setupAssembly: pin(setupFile),
      scope: 'Original and transformed control IR passes the unchanged verifier; the separately emitted entry setup executes once before repeated body iterations.'};
  } else report.copies = {included: false, reason: 'Copy exports not present in checked API; no copy pass claimed'};

  if (optional(['p185rs_validate', 'p185rs_emit'], 'setup scoring')) {
    for (const name of ['x86-score-controls.bend', 'x86-score-controls.c']) report.inputs.push(pin(fixture('phase185', name)));
    need(api.p185rs_validate() === '', 'Setup-scoring fixture fails unchanged IR verifier');
    const emitted = api.p185rs_emit();
    need(emitted?.$ === 'X181Output' && emitted.error === '', 'Setup-scoring emission refused: ' + emitted?.error);
    const chunks = list(emitted.chunks); need(chunks.length > 0 && chunks.every(chunk => typeof chunk === 'string'), 'Setup-scoring assembly required');
    const generated = write('score-x86.s', chunks.join(''));
    const row = {label: 'score-x86', target: 'x86', names: ['p185l'], irVerified: true, emitted: pin(generated), complete: false};
    report.machine.push(row); save();
    const cAssembly = observer('score', fixture('phase185', 'x86-score-controls.c'));
    const combined = write('score-x86-combined.s', [cAssembly, generated].map(file => fs.readFileSync(file, 'utf8')).join('\n') + '\n.section .note.GNU-stack,"",@progbits\n');
    const object = path.join(out, 'score-x86.o'), binary = path.join(out, 'score-x86'), policy = assets.toolchains.x86;
    run('score-x86-assemble', [assembler, ...policy.assemblerFlags, '-o', object, combined]); record(object);
    run('score-x86-link', [linker, ...policy.linkerFlags, object, ...policy.libraries, '-o', binary]); record(binary);
    run('score-x86-execute', [binary], 'phase185 setup scoring controls pass\n');
    row.binary = pin(binary); row.complete = true;
    report.scoring = {included: true, functions: 1, machineChecks: 2,
      scope: 'Finite execution checks a setup snapshot across repeated body iterations and full-width wraparound; no register-selection performance claim.'};
    save();
  } else report.scoring = {included: false, reason: 'Setup-scoring exports not present in checked API; no scoring pass claimed'};

  if (optional(['p185rf_validate', 'p185rf_emit'], 'public return')) {
    for (const name of ['x86-fact-controls.bend', 'x86-fact-controls.c']) report.inputs.push(pin(fixture('phase185', name)));
    need(api.p185rf_validate() === '', 'Public-return fixtures fail unchanged IR verifier');
    const emitted = api.p185rf_emit();
    need(emitted?.$ === 'X181Output' && emitted.error === '', 'Public-return emission refused: ' + emitted?.error);
    const chunks = list(emitted.chunks); need(chunks.length > 0 && chunks.every(chunk => typeof chunk === 'string'), 'Public-return assembly required');
    const generated = write('returns-x86.s', chunks.join(''));
    const row = {label: 'returns-x86', target: 'x86', names: ['p185m', 'p185n', 'p185o'], irVerified: true, emitted: pin(generated), complete: false};
    report.machine.push(row); save();
    const cAssembly = observer('returns', fixture('phase185', 'x86-fact-controls.c'));
    const combined = write('returns-x86-combined.s', [cAssembly, generated].map(file => fs.readFileSync(file, 'utf8')).join('\n') + '\n.section .note.GNU-stack,"",@progbits\n');
    const object = path.join(out, 'returns-x86.o'), binary = path.join(out, 'returns-x86'), policy = assets.toolchains.x86;
    run('returns-x86-assemble', [assembler, ...policy.assemblerFlags, '-o', object, combined]); record(object);
    run('returns-x86-link', [linker, ...policy.linkerFlags, object, ...policy.libraries, '-o', binary]); record(binary);
    run('returns-x86-execute', [binary], 'phase185 public return controls pass\n');
    row.binary = pin(binary); row.complete = true;
    report.publicReturns = {included: true, segments: 3, machineChecks: 3,
      scope: 'Finite public-segment true/false/nested Return observations preserve the scalar-return boundary around private-function facts.'};
    save();
  } else report.publicReturns = {included: false, reason: 'Public-return exports not present in checked API; no return-boundary pass claimed'};

  if (optional(['p185pc_ids', 'p185pc_functions', 'p185pc_validate', 'p185pc_controls'], 'packed take')) {
    for (const name of ['packed-take-controls.bend', 'packed-take-oracle.c']) report.inputs.push(pin(fixture('phase185', name)));
    need(api.p185pc_validate() === '', 'Packed-take fixtures fail unchanged IR verifier');
    report.rows.packedTake = list(api.p185pc_controls()); exact(report.rows.packedTake, packedTakeRows, 'Packed-take admission rows');
    const functions = list(api.p185pc_functions());
    exact(functions.map(fn => fn.name), ['p185ta', 'p185tb', 'p185tc', 'p185td', 'p185te', 'p185tf', 'p185tg'], 'Packed-take function inventory');
    const cAssembly = observer('packed-take', fixture('phase185', 'packed-take-oracle.c'));
    for (const target of ['qbe', 'x86']) {
      machine('packed-take-' + target, target, functions, api.p185pc_ids(), cAssembly, 'packed-take-oracle: checks=420 failures=0\n');
    }
    report.packedTake = {included: true, controls: 26, functions: 7, words: 20, checksPerTarget: 420,
      targets: ['qbe', 'x86'], machineChecks: 840, realRuntimeLinked: false,
      slowHelperStubs: ['p125_rt_take1', 'p111_rt_take'], oracle: pin(fixture('phase185', 'packed-take-oracle.c')),
      scope: 'Isolated full-word payload/status, fallback-argument, call-count and state-canary observations. No real heap or ownership qualification.'};
    save();
  } else report.packedTake = {included: false, reason: 'Packed-take exports not present in checked API; no packed-take pass claimed'};

  if (optional(['p185ct_controls', 'p185ct_oracle_module'], 'constructor')) {
    for (const name of ['cold-ctor-controls.bend', 'cold-ctor-oracle.c']) report.inputs.push(pin(fixture('phase185', name)));
    report.rows.constructors = list(api.p185ct_controls()); exact(report.rows.constructors, constructorRows, 'Constructor admission rows');
    const names = ['p185ct_width1', 'p185ct_width2', 'p185ct_width3', 'p185ct_width4', 'p185ct_hot', 'p185ct_twice'];
    const row = {label: 'constructor-qbe', target: 'qbe', names, complete: false,
      scope: 'Late-expansion machine oracle with an independent cache/descriptor model and isolated slow-helper stubs. No real runtime or whole-expanded-IR verifier claim.'};
    report.machine.push(row); save();
    const text = api.p185ct_oracle_module(); need(typeof text === 'string' && text.length > 0, 'Constructor oracle QBE required');
    exact([...text.matchAll(/^export function l \$(p185ct_[a-z0-9]+)\(/gm)].map(match => match[1]), names, 'Constructor module inventory');
    const generated = write('constructor-qbe.ssa', text), assembly = path.join(out, 'constructor-qbe.s');
    row.emitted = pin(generated);
    run('constructor-qbe-compile', [qbe, '-t', 'amd64_sysv', '-o', assembly, generated]); record(assembly);
    const object = path.join(out, 'constructor-qbe.o'), observerObject = path.join(out, 'constructor-observer.o');
    const binary = path.join(out, 'constructor-qbe'), policy = assets.toolchains.qbe;
    run('constructor-qbe-assemble', [assembler, ...policy.assemblerFlags, '-o', object, assembly]); record(object);
    run('constructor-compile-observer', [linker, '-std=c11', '-O2', '-fno-pie', '-c', fixture('phase185', 'cold-ctor-oracle.c'), '-o', observerObject]); record(observerObject);
    run('constructor-qbe-link', [linker, ...policy.linkerFlags, object, observerObject, ...policy.libraries, '-o', binary]); record(binary);
    run('constructor-qbe-execute', [binary], 'cold-ctor-oracle: checks=221 failures=0\n');
    row.binary = pin(binary); row.complete = true;
    report.constructors = {included: true, controls: 32, functions: 6, machineChecks: 221, realRuntimeLinked: false,
      slowHelperStubs: ['p125_rt_ctor1', 'p125_rt_ctor2', 'p125_rt_ctor3', 'p125_rt_ctor4'],
      oracle: pin(fixture('phase185', 'cold-ctor-oracle.c'))};
    save();
  } else report.constructors = {included: false, reason: 'Constructor exports not present in checked API; no constructor pass claimed'};

  if (optional(['p185tr_validate', 'p185tr_controls', 'p185tr_functions', 'p185tr_emit', 'p185tr_emit_setup'], 'transient')) {
    for (const name of ['transient-controls.bend', 'transient-controls.c']) report.inputs.push(pin(fixture('phase185', name)));
    need(api.p185tr_validate() === '', 'Transient fixtures fail unchanged IR verifier');
    report.rows.transient = list(api.p185tr_controls()); exact(report.rows.transient, transientRows, 'Transient placement rows');
    const functions = list(api.p185tr_functions());
    exact(functions.map(fn => fn.name), ['p185tr5', 'p185tr0', 'p185tr1', 'p185tr2', 'p185tr3', 'p185tr4', 'p185tr6', 'p185tr8'], 'Transient function inventory');
    const setup = api.p185tr_emit_setup();
    need(setup?.$ === 'X181Output' && setup.error === '', 'Transient setup emission refused: ' + setup?.error);
    const chunks = list(setup.chunks); need(chunks.length > 0 && chunks.every(chunk => typeof chunk === 'string'), 'Transient setup assembly required');
    const setupFile = write('transient-setup.s', chunks.join(''));
    const cAssembly = observer('transient', fixture('phase185', 'transient-controls.c'));
    machine('transient-x86', 'x86', functions, emptyIds, cAssembly, 'phase185 transient controls pass: 168\n', [setupFile], [], 'p185tr_emit');
    report.transient = {included: true, controls: 23, functions: 9, directFunctions: 8, setupFunction: 'p185tr7',
      setupAssembly: pin(setupFile), machineChecks: 168, emitter: 'p185tr_emit',
      scope: 'The checked custom emitter forces transient placement while bypassing copy/facts so lifetime hazards remain present. Separate setup, branch/call boundaries, pressure, dead writes, Again snapshots and widths have finite machine observations; no performance claim.'};
    save();
  } else report.transient = {included: false, reason: 'Transient exports not present in checked API; no transient pass claimed'};

  if (optional(['p185dc_validate', 'p185dc_controls', 'p185dc_emit'], 'dead assignment')) {
    for (const name of ['dead-controls.bend', 'dead-controls.c']) report.inputs.push(pin(fixture('phase185', name)));
    need(api.p185dc_validate() === '', 'Dead-assignment fixtures fail unchanged IR verifier');
    report.rows.dead = list(api.p185dc_controls()); exact(report.rows.dead, deadRows, 'Dead-assignment rows');
    const emitted = api.p185dc_emit();
    need(emitted?.$ === 'X181Output' && emitted.error === '', 'Dead-assignment emission refused: ' + emitted?.error);
    const chunks = list(emitted.chunks); need(chunks.length > 0 && chunks.every(chunk => typeof chunk === 'string'), 'Dead-assignment assembly required');
    const cAssembly = observer('dead', fixture('phase185', 'dead-controls.c'));
    moduleMachine('dead-x86', 'x86', chunks.join(''), ['p185da', 'p185db', 'p185dc', 'p185dd', 'p185de', 'p185df', 'p185dg'],
      cAssembly, 'phase185 dead assignment controls pass\n', {irVerified: true, emitter: 'p185dc_emit'});
    report.dead = {included: true, controls: 8, functions: 7, observerGroups: 8,
      scope: 'The checked custom emitter preserves DCE hazards by bypassing earlier copy/facts passes. Finite observations retain loads/calls, branch joins and entry values across Again; no performance claim.'};
    save();
  } else report.dead = {included: false, reason: 'Dead-assignment exports not present in checked API; no DCE pass claimed'};

  if (optional(['p185ff_controls', 'p185ff_oracle_module', 'p185ff_oracle_x86'], 'scoped frame')) {
    for (const name of ['frame-controls.bend', 'frame-oracle.c']) report.inputs.push(pin(fixture('phase185', name)));
    report.rows.frame = list(api.p185ff_controls()); exact(report.rows.frame, frameRows, 'Scoped-frame admission rows');
    const names = ['p185fr_zero', 'p185fr_one', 'p185fr_eight', 'p185fr_last', 'p185fr_unscoped', 'p185fr_foreign', 'p185fr_outside'];
    const qbeText = api.p185ff_oracle_module(); need(typeof qbeText === 'string', 'Scoped-frame QBE oracle required');
    exact([...qbeText.matchAll(/^export function l \$(p185fr_[a-z]+)\(/gm)].map(match => match[1]), names, 'Scoped-frame module inventory');
    const emitted = api.p185ff_oracle_x86();
    need(emitted?.$ === 'X181Output' && emitted.error === '', 'Scoped-frame x86 emission refused: ' + emitted?.error);
    const chunks = list(emitted.chunks); need(chunks.length > 0 && chunks.every(chunk => typeof chunk === 'string'), 'Scoped-frame assembly required');
    const cAssembly = observer('frame', fixture('phase185', 'frame-oracle.c'));
    const scope = 'Late-template oracle with independent whole-state/stack/capture and overlap-order observations plus an isolated p111_rt_frame fallback stub. No real runtime or whole-expanded-IR verifier claim.';
    moduleMachine('frame-qbe', 'qbe', qbeText, names, cAssembly, 'frame-oracle: checks=140 failures=0\n',
      {emitter: 'p185ff_oracle_module', scope});
    moduleMachine('frame-x86', 'x86', chunks.join(''), names, cAssembly, 'frame-oracle: checks=140 failures=0\n',
      {emitter: 'p185ff_oracle_x86', scope});
    report.frame = {included: true, controls: 28, functions: 7, checksPerTarget: 140, targets: ['qbe', 'x86'], machineChecks: 280,
      realRuntimeLinked: false, slowHelperStubs: ['p111_rt_frame'], oracle: pin(fixture('phase185', 'frame-oracle.c')), scope};
    save();
  } else report.frame = {included: false, reason: 'Scoped-frame exports not present in checked API; no frame pass claimed'};

  if (optional(['p185fp_validate', 'p185fp_controls', 'p185fp_functions'], 'floating')) {
    for (const name of ['floating-controls.bend', 'floating-controls.c']) report.inputs.push(pin(fixture('phase185', name)));
    const catalog = path.join(workspace, 'selfhost/tools/performance/phase112/float/cases.json'); report.inputs.push(pin(catalog));
    const data = read(catalog); need(data.kind === 'phase112-float-boundaries' && Array.isArray(data.cases), 'Frozen floating oracle catalog required');
    const cases = data.cases.filter(row => row.op >= 26 && row.op <= 35);
    need(cases.length === 93 && cases.filter(row => row.comparison === 'exact').length === 88 &&
      cases.filter(row => row.comparison === 'nan-class').length === 5, 'Exact frozen floating case inventory required');
    const frozenRows = cases.map(row => {
      need(Number.isInteger(row.op) && Array.isArray(row.args) && row.args.length === 2 &&
        ['exact', 'nan-class'].includes(row.comparison) && /^[0-9a-f]{16}$/.test(row.expectedHex) && typeof row.name === 'string', 'Malformed frozen floating case');
      const words = row.args.map(word => {
        need([word.lo, word.hi].every(n => Number.isInteger(n) && n >= 0 && n <= 4294967295), 'Bounded floating input word required');
        return ((BigInt(word.hi) << 32n) | BigInt(word.lo)).toString(16).padStart(16, '0');
      });
      return `  {${row.op}, UINT64_C(0x${words[0]}), UINT64_C(0x${words[1]}), UINT64_C(0x${row.expectedHex}), ${row.comparison === 'nan-class' ? 1 : 0}, ${JSON.stringify(row.name)}},`;
    }).join('\n');
    const observerText = fs.readFileSync(fixture('phase185', 'floating-controls.c'), 'utf8');
    need(observerText.split('/* BEGIN FROZEN CASES */\n').length === 2 && observerText.split('\n/* END FROZEN CASES */').length === 2,
      'Unique frozen C oracle table required');
    exact(observerText.split('/* BEGIN FROZEN CASES */\n')[1].split('\n/* END FROZEN CASES */')[0], frozenRows, 'Floating C oracle table');
    need(api.p185fp_validate() === '', 'Floating fixtures fail unchanged IR verifier');
    report.rows.floating = list(api.p185fp_controls()); exact(report.rows.floating, floatingRows, 'Floating admission rows');
    const functions = list(api.p185fp_functions());
    exact(functions.map(fn => fn.name), Array.from({length: 12}, (_, i) => 'p185f' + String.fromCharCode(97 + i)), 'Floating function inventory');
    const cAssembly = observer('floating', fixture('phase185', 'floating-controls.c'));
    machine('floating-x86', 'x86', functions, emptyIds, cAssembly, 'phase185 floating controls pass: 95\n');
    report.floating = {included: true, controls: 21, functions: 12, arithmeticAndComparisonCases: 93, exactWords: 88,
      arithmeticNaNClassWithZeroUpperWord: 5, fallbackRoutingCases: 2, machineChecks: 95, realRuntimeLinked: false,
      slowHelperStubs: ['p111_rt_op'], allowedFallbackOpcodes: [23, 36], caseCatalog: pin(catalog),
      oracle: pin(fixture('phase185', 'floating-controls.c')),
      scope: 'Frozen Phase112 binary F32 bit oracles plus full-word fallback routing. The isolated stub rejects calls from supported operations 26..35; arithmetic NaN payloads retain the established class-only contract. No floating runtime replacement or broad numeric claim.'};
    save();
  } else report.floating = {included: false, reason: 'Floating exports not present in checked API; no floating pass claimed'};

  if (optional(['p185sf_validate', 'p185sf_controls', 'p185sf_emit'], 'scratch forwarding')) {
    for (const name of ['scratch-controls.bend', 'scratch-controls.c']) report.inputs.push(pin(fixture('phase185', name)));
    need(api.p185sf_validate() === '', 'Original/transformed scratch fixtures fail unchanged IR verifier');
    report.rows.scratch = list(api.p185sf_controls()); exact(report.rows.scratch, scratchRows, 'Scratch-forwarding rows');
    const emitted = api.p185sf_emit();
    need(emitted?.$ === 'X181Output' && emitted.error === '', 'Scratch-forwarding emission refused: ' + emitted?.error);
    const chunks = list(emitted.chunks); need(chunks.length > 0 && chunks.every(chunk => typeof chunk === 'string'), 'Scratch-forwarding assembly required');
    const cAssembly = observer('scratch', fixture('phase185', 'scratch-controls.c'));
    moduleMachine('scratch-x86', 'x86', chunks.join(''), ['p185sa', 'p185sb', 'p185sc', 'p185sd', 'p185se', 'p185sf', 'p185sg', 'p185sh'],
      cAssembly, 'phase185 scratch forwarding controls pass\n', {irVerified: true, emitter: 'p185sf_emit'});
    report.scratch = {included: true, controls: scratchRows.length, functions: 8, resultGroups: 133, words: 6,
      stateCanaryWords: 261, realRuntimeLinked: false, slowHelperStubs: ['p111_rt_op'],
      oracle: pin(fixture('phase185', 'scratch-controls.c')),
      scope: 'The custom emitter tests scratch forwarding independently. The isolated stub writes its argument buffer to exercise a conservative call barrier; it does not model opcode 36 semantics. Finite results cover source mutation, byte overlap, branch/call boundaries, Again iterations and pointer aliases.'};
    save();
  } else report.scratch = {included: false, reason: 'Scratch-forwarding exports not present in checked API; no scratch pass claimed'};

  if (optional(['p185rb_validate', 'p185rb_controls', 'p185rb_emit'], 'register binary')) {
    for (const name of ['register-controls.bend', 'register-controls.c']) report.inputs.push(pin(fixture('phase185', name)));
    need(api.p185rb_validate() === '', 'Register-binary fixtures fail unchanged IR verifier');
    report.rows.registerBinary = list(api.p185rb_controls()); exact(report.rows.registerBinary, registerRows, 'Register-binary rows');
    const emitted = api.p185rb_emit();
    need(emitted?.$ === 'X181Output' && emitted.error === '', 'Register-binary emission refused: ' + emitted?.error);
    const chunks = list(emitted.chunks); need(chunks.length > 0 && chunks.every(chunk => typeof chunk === 'string'), 'Register-binary assembly required');
    const text = chunks.join(''), names = ['a', 'c', 'w'].flatMap(group => Array.from({length: 9}, (_, i) => 'p185rb' + group + i));
    exact([...text.matchAll(/^\.globl ([A-Za-z0-9_]+)$/gm)].map(match => match[1]), names.map(symbol), 'Register-binary assembly inventory');
    const cAssembly = observer('register', fixture('phase185', 'register-controls.c'));
    moduleMachine('register-x86', 'x86', text, names, cAssembly, 'phase185 register binary controls pass\n',
      {irVerified: true, emitter: 'p185rb_emit'});
    report.registerBinary = {included: true, controls: 7, functions: 27, inputWords: 11, inputPairs: 121,
      invocations: 3267, exactU64ResultWords: 26136, stateCanaryWords: 261, runtimeLinked: false,
      forcedHomes: ['rbx', 'r13', 'r14', 'r15', 'rdi', 'rsi', 'rdx', 'r8', 'r9'],
      oracle: pin(fixture('phase185', 'register-controls.c')),
      scope: 'Custom emission forces physical destinations without allocator or earlier simplifier decisions. Independent unsigned/sign-bit-flip oracles cover aliases, masked variable shifts, wide immediates, comparisons and zero-extended U32 results; no placement or performance claim.'};
    save();
  } else report.registerBinary = {included: false, reason: 'Register-binary exports not present in checked API; no register pass claimed'};

  if (optional(['p185bd_controls', 'p185bd_oracle_module'], 'descriptor proof')) {
    for (const name of ['descriptor-proof-controls.bend', 'descriptor-proof-oracle.c']) report.inputs.push(pin(fixture('phase185', name)));
    report.rows.descriptor = list(api.p185bd_controls()); exact(report.rows.descriptor, descriptorRows, 'Descriptor-binding rows');
    const text = api.p185bd_oracle_module(); need(typeof text === 'string' && text.length > 0, 'Descriptor-binding QBE oracle required');
    const names = ['p185bd_paired', 'p185bd_raw'];
    exact([...text.matchAll(/^export function l \$(p185bd_[a-z]+)\(/gm)].map(match => match[1]), names, 'Descriptor-binding module inventory');
    const cAssembly = observer('descriptor', fixture('phase185', 'descriptor-proof-oracle.c'));
    const scope = 'Finite descriptor-binding and late-template observations. The paired path executes only with its bound descriptor preconditions; unpaired IDs retain guard/fallback observations. The isolated allocation stub is not a production runtime, and no universal proof or whole-expanded-IR verification is claimed.';
    moduleMachine('descriptor-qbe', 'qbe', text, names, cAssembly, 'descriptor-proof-oracle: checks=19 failures=0\n',
      {emitter: 'p185bd_oracle_module', scope});
    report.descriptor = {included: true, controls: 27, functions: 2, machineChecks: 19, realRuntimeLinked: false,
      slowHelperStubs: ['p125_rt_ctor2'], oracle: pin(fixture('phase185', 'descriptor-proof-oracle.c')), scope};
    save();
  } else report.descriptor = {included: false, reason: 'Descriptor-proof exports not present in checked API; no descriptor pass claimed'};

  const legacy = ['p181c_functions', 'p181c_validate', 'p181h_controls', 'p181h_validate'];
  need(legacy.every(name => authority.exports.includes(name)) || legacy.every(name => !authority.exports.includes(name)), 'Partial legacy export set');
  if (legacy.every(name => authority.exports.includes(name))) {
    for (const name of legacy) need(typeof api[name] === 'function', 'Missing legacy export: ' + name);
    need(api.p181c_validate() === '' && api.p181h_validate() === '', 'Legacy fixtures fail unchanged IR verifier');
    report.rows.hygiene = list(api.p181h_controls()); exact(report.rows.hygiene, hygieneRows, 'Hygiene rows');
    const functions = list(api.p181c_functions()); exact(functions.map(fn => fn.name), Array.from({length: 17}, (_, i) => 'p181' + String.fromCharCode(97 + i)), 'Legacy machine inventory');
    const runtimeDir = path.join(workspace, 'selfhost/src/runtime/qbe');
    for (const name of ['abi-controls.bend', 'hygiene-controls.bend', 'abi-runner.c', 'abi-preserve.s']) report.inputs.push(pin(fixture('phase181', name)));
    const contract = fixture('phase183', 'abi-contract.c'); report.inputs.push(pin(contract));
    for (const name of ['runtime.h', 'primitives.h']) report.inputs.push(pin(path.join(runtimeDir, name)));
    const contractObject = path.join(out, 'legacy-contract.o');
    run('legacy-contract', [linker, '-std=c11', '-O2', '-fno-pie', '-I', runtimeDir, '-c', contract, '-o', contractObject]); record(contractObject);
    const cAssembly = observer('legacy', fixture('phase181', 'abi-runner.c'));
    machine('legacy-x86', 'x86', functions, emptyIds, cAssembly, 'controls pass\n', [fixture('phase181', 'abi-preserve.s')], [contractObject]);
    report.legacy = {included: true, functions: 17, hygiene: 10, runtimeABI: 11102};
  } else report.legacy = {included: false, reason: 'Legacy exports not present in checked API; no legacy pass claimed'};
  report.inputs.forEach(verify); report.complete = true;
} catch (error) {
  report.error = String(error.stack ?? error); process.exitCode = 1;
}
save();
console.log(JSON.stringify({complete: report.complete, boolRows: report.rows.bool?.length, factRows: report.rows.facts?.length,
  constructorRows: report.rows.constructors?.length, packedTakeRows: report.rows.packedTake?.length,
  transientRows: report.rows.transient?.length, deadRows: report.rows.dead?.length, frameRows: report.rows.frame?.length,
  floatingRows: report.rows.floating?.length, scratchRows: report.rows.scratch?.length, registerRows: report.rows.registerBinary?.length,
  descriptorRows: report.rows.descriptor?.length,
  machine: report.machine.map(row => ({label: row.label, complete: row.complete})),
  copies: report.copies, scoring: report.scoring, publicReturns: report.publicReturns, packedTake: report.packedTake,
  constructors: report.constructors, transient: report.transient, dead: report.dead, frame: report.frame, floating: report.floating,
  scratch: report.scratch, registerBinary: report.registerBinary, descriptor: report.descriptor,
  legacy: report.legacy, error: report.error}));
