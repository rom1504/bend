#!/usr/bin/env bun
// IO/observation adapter only: all transformations, validation and emission
// are checked Bend exports. Expected rows and observer outputs are fixed here.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';
import {spawnSync} from 'node:child_process';
import {pin, verify, requireThat as need, workspace} from '../../tools/build/hosted.mjs';

const own = fileURLToPath(import.meta.url), args = {};
for (let i = 2; i < process.argv.length; i += 2) {
  const key = process.argv[i], value = process.argv[i + 1];
  need(['--api', '--assets', '--out', '--groups'].includes(key) && value && !Object.hasOwn(args, key), 'Unknown, incomplete, or duplicate option: ' + key);
  args[key] = value;
}
for (const key of ['--api', '--assets', '--out']) need(args[key], 'Required option: ' + key);
const rows = names => names.split(' ').map(name => name + '=1');
const groups = {
  transport: {fixture: 'register-transport-controls.bend', observer: 'register-transport-oracle.c', target: 'qbe',
    controls: 'p186rc_controls', emit: 'p186rc_oracle_module', expected: 'register-transport-oracle: checks=2000 failures=0\n',
    rows: rows('jump-zero jump-eight return-zero return-eight fusion-scratch inline-scratch foreign-buffer-refused state-buffer-refused local-continuation-buffer-refused jump-nine-refused return-nine-refused counter-refused unknown-fid-refused runtime-fid-refused numeric-fid-refused high-count-refused dynamic-count-refused state-identity-refused result-type-refused verifier-jump-valid verifier-jump-arity verifier-jump-incoming verifier-jump-capacity verifier-return-valid verifier-return-width verifier-return-capacity fallback-byte-identity capability-guard jump-fallback-retained return-fallback-retained'),
    names: ['p186rt_j0', 'p186rt_j1', 'p186rt_j2', 'p186rt_j8', 'p186rt_r0', 'p186rt_r1', 'p186rt_r2', 'p186rt_r8', 'p186rt_jforeign', 'p186rt_rforeign'],
    stubs: ['p111_rt_jump', 'p111_rt_return'], scope: 'Late-template oracle, valid ABI transfer contracts, independent full-state/memmove/capability-clear observations; no whole-expanded-IR verification claim.'},
  char: {fixture: 'char-controls.bend', observer: 'char-controls.c', target: 'qbe',
    controls: 'p186chc_controls', emit: 'p186chc_oracle_module', expected: 'phase186 char controls pass: 60\n',
    rows: rows('take ctor take-input-alias take-buffer-alias ctor-buffer-alias full64-constant store-before-status load-before-destination wrong-kind wrong-count zero-count kind-high count-high state-alias-refused wrong-state wrong-import wrong-result-type extra-argument verified-take verified-constructor short-buffer-rejected other-statement'),
    names: ['p186char_take', 'p186char_status', 'p186char_input_alias', 'p186char_buffer_alias', 'p186char_ctor', 'p186char_ctor_alias'],
    stubs: [], scope: 'Exact full-word identity, alias/read-before-write and finite admission observations; no Unicode-range conversion claim.'},
  inline: {fixture: 'inline-effects-controls.bend', observer: 'inline-effects-controls.c', target: 'x86',
    validate: 'p186ie_validate', controls: 'p186ie_controls', emit: 'p186ie_emit', expected: 'phase186 inline effect controls pass: 590\n',
    rows: rows('verified all-ten-live-across disabled-summary unsupported-barrier fallback-live-stacked fallback-result-stacked input-result-overwrite old-input-survives all-five-homes-live pressure-result-stacked pointer-read-before-result pointer-stack-home wrong-count conversion-call wrong-state wrong-symbol'),
    names: ['p186ia', 'p186ib', 'p186ic', 'p186id', 'p186ie', 'p186if', 'p186ig', 'p186ih', 'p186ii', 'p186ij', 'p186ik', 'p186il', 'p186io', 'p186im', 'p186in'],
    stubs: ['p111_rt_op'], scope: 'Original IR verification, custom placement, frozen F32 bit/class oracles and live caller-clobbered registers. Unsupported operation uses an isolated call-clobber stub.'},
  callee: {fixture: 'callee-save-controls.bend', observer: 'callee-save-controls.c', extra: ['callee-save-preserve.s'], target: 'x86',
    controls: 'p186_sv_controls', emit: 'p186_sv_emit', expected: 'phase186 callee-save controls pass: 32/32\n',
    rows: ['unknown-mask=1', ...Array.from({length: 32}, (_, i) => 'mask-' + i + '=1')],
    names: Array.from({length: 32}, (_, i) => 'p186_sv_' + i), stubs: [],
    scope: 'All five-register save masks; independent SysV shim observes return and all six callee-saved registers. Custom frame emitter, not a whole-IR verifier claim.'},
  private: {fixture: 'private-controls.bend', observer: 'private-controls.c', target: 'x86',
    validate: 'p186pm_validate', controls: 'p186pm_controls', emit: 'p186pm_emit', expected: 'phase186 private memory controls pass\n',
    rows: rows('verified dead-buffer-stores dead-buffer-allocation live-buffer-store overlapping-read unknown-call-escape branch-read-union inline-f32-reads allocation-preserves-other-facts allocation-kills-own-facts setup-escape branch-escape stored-address-escape'),
    names: ['p186ma', 'p186mb', 'p186mc', 'p186md', 'p186me', 'p186mf'], stubs: ['p111_rt_op'],
    scope: 'Original/transformed IR verification and finite alias, escape, branch, overlapping-width, inline-read observations. Isolated opcode36 stub tests buffer mutation, not runtime sqrt semantics.'},
  parallel: {fixture: 'parallel-controls.bend', dependencies: ['private-controls.bend'], observer: 'parallel-controls.c', target: 'x86',
    validate: 'p186mv_validate', controls: 'p186mv_controls', emit: 'p186mv_emit', expected: 'phase186 parallel move controls pass\n',
    rows: rows('verified self-empty acyclic-chain self-fanout two-cycle-fallback three-cycle-fallback discard-scheduled-prefix mismatched-vector duplicate-homes buffer-source-fallback bounded-vector'),
    names: ['p186va', 'p186vb', 'p186vc', 'p186vd', 'p186ve', 'p186vf', 'p186vg'], stubs: [],
    scope: 'Original IR verification and custom machine placement: parallel assignment chains, fanout, cycle fallback, constants, transients and setup snapshots.'},
  unique: {fixture: 'unique-take-controls.bend', observer: 'unique-take-oracle.c', target: 'qbe',
    controls: 'p186uc_controls', emit: 'p186uc_oracle_module', expected: 'unique-take-oracle: checks=4038 failures=0\n',
    rows: rows('one two three four zero-refused five-refused foreign-buffer-refused state-buffer-refused fusion-buffer inline-buffer local-continuation-refused counter-refused high-count-refused dynamic-count-refused word-symbol-refused reserved-word-refused literal-word state-identity-refused result-type-refused other-import-refused verified-call short-buffer-rejected unique-tag-guard constructor-bound-guard arity-byte-window static-boundary-guard handoff-threshold-guard original-sized-fallback'),
    names: ['p186ut_one', 'p186ut_two', 'p186ut_three', 'p186ut_four', 'p186ut_foreign'],
    stubs: ['p125_rt_take1', 'p125_rt_take2', 'p125_rt_take3', 'p125_rt_take4', 'p111_rt_take'],
    scope: 'Late-template ABI11102 cache/field observer with sparse guarded corpus. Full state/cache/touched heap/output comparison, static rounding, CID/arity guards, threshold and ordered overlap. Invalid words occur only in isolated fallback-routing stubs; no real runtime or whole-expanded-IR verifier claim.'},
  uniquev2: {fixture: 'unique-take-v2-controls.bend', observer: 'unique-take-v2-oracle.c', inputs: ['unique-take-oracle.c'], target: 'qbe',
    controls: 'p186vc_controls', emit: 'p186vc_oracle_module', expected: 'unique-take-oracle: checks=4038 failures=0\nunique-take-v2 aliases: checks=1296 failures=0\n',
    rows: rows('one two three four zero-refused five-refused foreign-buffer-refused state-buffer-refused fusion-buffer inline-buffer local-continuation-refused counter-refused high-count-refused dynamic-count-refused word-symbol-refused reserved-word-refused literal-word state-identity-refused result-type-refused other-import-refused verified-call short-buffer-rejected unique-tag-guard constructor-bound-guard arity-byte-window static-boundary-guard handoff-threshold-guard original-sized-fallback one-single-fallback two-single-fallback three-single-fallback four-single-fallback word-destination buffer-destination state-destination reserved-destination-refused'),
    names: ['p186ut_one', 'p186ut_two', 'p186ut_three', 'p186ut_four', 'p186ut_foreign', 'p186uv_word', 'p186uv_buffer', 'p186uv_state'],
    stubs: ['p125_rt_take1', 'p125_rt_take2', 'p125_rt_take3', 'p125_rt_take4', 'p111_rt_take'],
    scope: 'Single-fallback v2; original4038 observations plus1296 destination/input/state/buffer alias observations. Late-template ABI11102 cache/field observer with sparse guarded corpus. Full state/cache/touched heap/output comparison, static rounding, CID/arity guards, threshold and ordered overlap. Invalid words occur only in isolated fallback-routing stubs; no real runtime or whole-expanded-IR verifier claim.'},
  stacked: {fixture: 'stacked-frame-controls.bend', observer: 'stacked-frame-controls.c', target: 'qbe',
    inputs: ['../../src/runtime/qbe/runtime.h'], allFunctions: true,
    validate: 'p186sfc_verified', validationArgs: [[0], [1]], controls: 'p186sfc_controls', emit: 'p186sfc_oracle_module',
    rows: rows('original-ir-two-verified original-ir-branch-verified original-single-frame-rule-refuses two-pending-admitted alternating-branches-admitted two-cases unknown-call-refused missing-case-refused eight-cases-admitted nine-cases-refused no-global-dispatch no-native-self-call explicit-depth outside-region-refused'),
    names: ['stacked', 'p186stack'], stubs: ['p111_rt_fail'],
    variants: [{suffix: 'mode0', args: [0], observerFlags: ['-DSTACKED_MODE=0'], expected: 'phase186 stacked mode0 controls pass: 42\n'},
      {suffix: 'mode1', args: [1], observerFlags: ['-DSTACKED_MODE=1'], expected: 'phase186 stacked mode1 controls pass: 42\n'}],
    scope: 'Independently verified original segments and closed local-continuation plans. Two push orders/branch modes, 100001-level explicit descent, full-width arithmetic, restored state and stack canaries. Only the unreachable error route is an isolated aborting stub.'},
  expression: {fixture: 'expression-controls.bend', dependencies: ['private-controls.bend'], observer: 'expression-controls.c', target: 'x86',
    validate: 'p186ce_validate', controls: 'p186ce_controls', emit: 'p186ce_emit', expected: 'phase186 expression controls pass: 2160\n',
    rows: rows('verified duplicate-bin source-write result-write snapshot-write self-updates alias-mask-address comparison-width variable-shifts store-load-barrier unknown-call-barrier branch-barrier u32-operations load-preserves-pure-fact self-hit offset-capacity-preserved bound-refusal'),
    names: ['p186ea', 'p186eb', 'p186ec', 'p186ed', 'p186ee', 'p186ef', 'p186eg', 'p186eh', 'p186ei', 'p186ej', 'p186ek', 'p186el', 'p186en', 'p186eo', 'p186em'],
    stubs: ['p111_rt_op'],
    scope: 'Original/transformed IR verification and independent 12-word crossgrid: modulo arithmetic, sign-bit-flip signed ordering, masked shifts, source/result mutation, snapshots, barriers, Offset capacity, status and all state/output canaries. Isolated opcode36 stub returns a distinct full-width word and clobbers caller registers; no runtime sqrt or performance claim.'},
  arguments: {fixture: 'call-argument-controls.bend', observer: 'call-argument-controls.c', target: 'x86',
    controls: 'p186ca_controls', emit: 'p186ca_emit', expected: 'phase186 call argument controls pass: 5/5\n',
    rows: rows('direct-plan transient-plan direct-first-home direct-no-copy direct-stack-args snapshot-before-placement disabled-snapshot u32-six-registers short-capacity-refused unknown-slot-refused unknown-register-refused unknown-transient-refused outside-frame-refused saved-slot-refused buffer-overlap-refused maximum-public-arity bounded-512 bounded-513-refused empty-call explicit-invalid-frame'),
    names: ['p186ca_direct', 'p186ca_disabled', 'p186ca_snapshot', 'p186ca_six', 'p186ca_zero'],
    stubs: ['p186ca_check_direct', 'p186ca_check_snapshot', 'p186ca_check_six', 'p186ca_check_zero'], dataGlobals: ['p186ca_cookie'],
    scope: 'Isolated custom machine frames, not whole-IR admission. Independent callees observe all ten argument words, nominal U32 high-word clearing, first six SysV registers, stack arguments, mutable-register snapshots, symbol/buffer addresses and FID/CID constants. Observer cookie and call counts must remain exact; no production runtime is linked.'},
  floatvalues: {fixture: 'float-values-controls.bend', dependencies: ['inline-effects-controls.bend'], observer: 'float-values-controls.c', target: 'x86',
    validate: 'p186fv_validate', controls: 'p186fv_controls', emit: 'p186fv_emit',
    expected: 'phase186 inline effect controls pass: 590\nphase186 float operand controls pass: 45\n',
    rows: rows('original-ir-verified all-ten-forwarded-store-free mutation-refused mutation-stores-retained observed-still-forwarded observed-stores-retained overlap-refused call-barrier-refused branch-barrier-refused again-body-forwarded again-stores-removed escape-still-forwarded escape-stores-retained result-input-alias-forwarded unsupported-call-retained'),
    names: ['p186ia', 'p186ib', 'p186ic', 'p186id', 'p186ie', 'p186if', 'p186ig', 'p186ih', 'p186ii', 'p186ij', 'p186ik', 'p186il', 'p186io',
      'p186va', 'p186vb', 'p186vc', 'p186vd', 'p186ve', 'p186vf', 'p186vh', 'p186im', 'p186in', 'p186vg'],
    stubs: ['p111_rt_op'],
    scope: 'Original IR verification and custom private F32 plan emission. Retains all590 frozen arithmetic/live-register observations plus45 mutation, observed-scratch, overlapping-store, call/branch/alias barriers, repeated loop and escaping-buffer observations. Exact93 inherited F32 label rows are authenticated against Phase112; arithmetic NaNs retain class-only/zero-upper-word policy. Isolated opcode36 stub models an arbitrary allowed buffer write, not runtime sqrt.'},
  xmm: {fixture: 'xmm-controls.bend', dependencies: ['inline-effects-controls.bend', 'float-values-controls.bend'],
    observer: 'xmm-controls.c', inputs: ['float-values-controls.c'], floatCatalogObserver: 'float-values-controls.c', target: 'x86',
    validate: 'p186xm_validate', controls: 'p186xm_controls', emit: 'p186xm_emit',
    expected: 'phase186 inline effect controls pass: 590\nphase186 float operand controls pass: 45\nphase186 XMM controls pass: 730\n',
    rows: rows('original-ir-verified rhs-destination-home rhs-divide-destination-home assigned-comparison-homes canonical-source-home canonical-copy-home result-boundary-refused parameter-refused raw-write-refused raw-copy-refused fourteen-live-homes fifteenth-live-fallback sixteenth-live-fallback unknown-call-boundary branch-boundary again-boundary setup-definition-refused'),
    names: ['p186ia', 'p186ib', 'p186ic', 'p186id', 'p186ie', 'p186if', 'p186ig', 'p186ih', 'p186ii', 'p186ij', 'p186ik', 'p186il', 'p186io',
      'p186va', 'p186vb', 'p186vc', 'p186vd', 'p186ve', 'p186vf', 'p186vh',
      'p186xa', 'p186xb', 'p186xc', 'p186xd', 'p186xe', 'p186xf', 'p186xg', 'p186xh', 'p186xi', 'p186xj', 'p186xk', 'p186xl', 'p186xm',
      'p186im', 'p186in', 'p186vg'],
    stubs: ['p111_rt_op'],
    scope: 'Original IR verification and isolated XMM placement emission. Retains all635 inherited observations plus730 focused arithmetic, RHS destination alias, raw full-width copy, fourteen-register pressure, call/branch boundaries, and assigned-comparison bit-pattern checks. Included observer and its93 frozen FP catalog rows are authenticated. Isolated opcode36 stub also clobbers XMM2 through XMM15; no production-runtime or performance claim.'},
  u32float: {fixture: 'u32-float-controls.bend', observer: 'u32-float-controls.c', target: 'x86',
    controls: 'p186uf_controls', emit: 'p186uf_emit', expected: 'phase186 u32 float controls pass: 105/105\n',
    rows: rows('exact-unary unsigned64-conversion fullword-publication read-before-pointer-overwrite disabled wrong-id high-id wrong-count high-count wrong-state state-buffer-refused wrong-import wrong-result nonlocal-buffer dynamic-id verified-eight-byte-buffer short-buffer-rejected conservative-call-barrier'),
    names: ['p186uf_0', 'p186uf_1', 'p186uf_2', 'p186uf_3', 'p186uf_4'], stubs: [],
    scope: 'Exact opcode23 admission with independent original-segment verifier rows and isolated custom machine placements, not a whole-IR machine-placement claim. Seven frozen conversion labels across five placements and three upper-word variants observe unsigned conversion, full-word publication, input/pointer destination aliases, preserved source/state and output canaries. No runtime helper or floating host oracle is linked.'},
};
const selected = args['--groups'] ? args['--groups'].split(',') : ['inline', 'callee', 'private', 'parallel', 'expression', 'arguments', 'floatvalues', 'xmm', 'u32float'];
need(selected.length && selected.length === new Set(selected).size && selected.every(name => Object.hasOwn(groups, name)), 'Unknown, empty, or duplicate group');
const out = path.resolve(args['--out']);
need(out.startsWith(workspace + '/selfhost/build/') && !fs.existsSync(out), 'Fresh guarded selfhost/build output required');
fs.mkdirSync(out, {recursive: true});
const snapshot = path.join(out, 'driver.mjs'); fs.copyFileSync(own, snapshot, fs.constants.COPYFILE_EXCL);
const adapted = new Set(['callee-save-controls.bend','parallel-controls.bend','call-argument-controls.bend','xmm-controls.bend','u32-float-controls.bend']);
const fixture = name => path.join(workspace, adapted.has(name) ? 'selfhost/tests/phase188' : 'selfhost/tests/phase186', name);
const read = file => JSON.parse(fs.readFileSync(file, 'utf8'));
const same = (a, b) => a?.bytes === b?.bytes && a?.sha256 === b?.sha256;
const report = {kind: 'phase188-typed-native-semantic-controls', version: 1, complete: false,
  driver: {entry: own, snapshot: pin(snapshot)}, selected, started: new Date().toISOString(),
  inputs: [pin(path.join(workspace,'selfhost/tests/phase186/semantic-controls.mjs')), pin(path.join(workspace,'selfhost/tests/phase188/fixture-adaptations.json')), pin(path.join(workspace,'selfhost/tests/phase188/legacy-adapters.bend')), pin(snapshot), pin(process.execPath), pin(path.join(workspace, 'selfhost/tools/build/hosted.mjs'))],
  jobs: [], artifacts: [], rows: {}, machine: [], linkedRuntime: null,
  scope: 'Finite checked-B1 API and native machine observations only; isolated observer stubs are explicitly identified per group. No production runtime, bootstrap, installed-image, kernel-proof, performance or broad-conformance claim.'};
const save = () => fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
const record = file => { const value = pin(file); report.artifacts.push(value); return value; };
const write = (name, value) => {
  need(typeof value === 'string' && Buffer.byteLength(value) < 16 * 1024 * 1024, 'Bounded text artifact required');
  const file = path.join(out, name); fs.writeFileSync(file, value, {flag: 'wx'}); record(file); return file;
};
const list = xs => {
  const values = [];
  while (xs?.$ === 'Con') { need(values.length < 10000, 'Unbounded fixture list'); values.push(xs.head); xs = xs.tail; }
  need(xs?.$ === 'Nil', 'Malformed fixture list'); return values;
};
const exact = (actual, expected, label) => need(JSON.stringify(actual) === JSON.stringify(expected), label + ' differs');
function run(label, command, expected) {
  report.inputs.forEach(verify);
  const begin = performance.now(), env = {...process.env};
  for (const key of ['LD_PRELOAD', 'LD_AUDIT', 'BENDRTS', 'NODE_OPTIONS', 'NODE_PATH']) delete env[key];
  const started = new Date().toISOString();
  const result = spawnSync(command[0], command.slice(1), {cwd: workspace, env, encoding: 'utf8', timeout: 15000, maxBuffer: 4 * 1024 * 1024});
  const stdout = write(label + '.stdout', result.stdout ?? ''), stderr = write(label + '.stderr', result.stderr ?? '');
  report.jobs.push({label, command, cwd: workspace, started, status: result.status, signal: result.signal,
    error: result.error?.message ?? null, seconds: (performance.now() - begin) / 1000, stdout: pin(stdout), stderr: pin(stderr)});
  save(); need(result.status === 0 && !result.signal && !result.error, label + ' failed');
  if (expected !== undefined) need(result.stdout === expected && result.stderr === '', label + ' exact observation differs');
}
// Decode emitted symbol metadata for inventory comparison only, never bodies.
const readable = name => name.replace(/^p11(?:1|3d|4r)_FID_((?:\d+_)+)$/, (_, bytes) => bytes.split('_').filter(Boolean).map(n => String.fromCharCode(Number(n))).join(''));
const begin = performance.now(); save();
try {
  const authority = read(args['--api']), assets = read(args['--assets']);
  need(authority.kind === 'bend-checked-hosted-api' && authority.complete && authority.checked && !authority.error, 'Complete checked hosted API receipt required');
  need(assets.kind === 'bend-build-assets' && assets.complete && authority.upstream?.revision === assets.upstream, 'API/assets upstream mismatch');
  need(Array.isArray(authority.inputs) && Array.isArray(authority.exports), 'Authenticated input/export inventories required');
  const binding = authority.imageBinding;
  need(binding?.kind === 'bend-build-image-binding' && binding.complete && binding.checked && binding.host === 'js' && binding.stage === 'B1' &&
    same(binding.image, authority.api) && same(binding.sourceIdentity, authority.source), 'Exact checked-B1 image/source binding required');
  report.authority = {receipt: pin(args['--api']), source: authority.source, api: authority.api, upstream: authority.upstream, binding};
  report.inputs.push(report.authority.receipt, pin(args['--assets']), authority.api, authority.source, ...authority.inputs);
  const tool = key => {
    const expected = assets.assets?.[key]; need(expected, 'Missing asset: ' + key);
    const actual = pin(path.resolve(workspace, expected.file)); need(same(actual, expected), 'Changed asset: ' + key);
    report.inputs.push(actual); return actual.file;
  };
  const qbe = tool('qbe'), assembler = tool('assembler'), linker = tool('linker');
  need(same(pin(process.execPath), assets.assets?.bun), 'Pinned Bun engine required');
  for (const key of ['upstream-bend', 'upstream-comp', 'base']) {
    const expected = pin(tool(key)); need(authority.inputs.some(row => row.file === expected.file && same(row, expected)), 'API lacks exact upstream authority: ' + key);
  }
  report.toolchains = {};
  for (const target of new Set(selected.map(name => groups[name].target))) {
    const policy = assets.toolchains?.[target];
    need(policy?.target === 'amd64_sysv' && ['assemblerFlags', 'linkerFlags', 'libraries'].every(key => Array.isArray(policy[key])), 'Maintained AMD64 SysV policy required');
    report.toolchains[target] = policy;
  }
  report.inputs.forEach(verify);
  const sourceManifestFile = path.join(path.dirname(authority.source.file), 'manifest.json');
  const sourceManifest = read(sourceManifestFile);
  need(sourceManifest.complete && same(sourceManifest.source, authority.source) && Array.isArray(sourceManifest.inputs), 'Exact source-assembly receipt required');
  report.sourceAssembly = pin(sourceManifestFile); report.inputs.push(report.sourceAssembly);
  for (const name of selected) for (const file of [groups[name].fixture, ...(groups[name].dependencies ?? [])]) {
    const input = pin(fixture(file)); report.inputs.push(input);
    need(sourceManifest.inputs.some(row => row.file === input.file && same(row, input)), 'Checked source assembly lacks exact fixture input: ' + file);
  }
  for (const name of selected) for (const file of [groups[name].observer, ...(groups[name].extra ?? []), ...(groups[name].inputs ?? [])]) report.inputs.push(pin(fixture(file)));
  const floatGroups = selected.filter(name => ['inline', 'floatvalues', 'xmm'].includes(name));
  if (floatGroups.length || selected.includes('u32float')) {
    const catalogFile = path.join(workspace, 'selfhost/tools/performance/phase112/float/cases.json'), catalogPin = pin(catalogFile);
    need(catalogPin.sha256 === 'bde39b2e416263ae82219c601ea409afc0e14be42ddb877a4d8aa4c545ce9753', 'Frozen F32 catalog differs');
    report.inputs.push(catalogPin);
    const cases = read(catalogFile).cases.filter(row => row.op >= 26 && row.op <= 35);
    need(cases.length === 93, 'Frozen F32 inventory differs');
    const expected = cases.map(row => {
      const words = row.args.map(word => ((BigInt(word.hi) << 32n) | BigInt(word.lo)).toString(16).padStart(16, '0'));
      return `  {${row.op}, UINT64_C(0x${words[0]}), UINT64_C(0x${words[1]}), UINT64_C(0x${row.expectedHex}), ${row.comparison === 'nan-class' ? 1 : 0}, ${JSON.stringify(row.name)}},`;
    });
    for (const name of floatGroups) {
      const actual = fs.readFileSync(fixture(groups[name].floatCatalogObserver ?? groups[name].observer), 'utf8').split('\n').filter(line => /^  \{\d+, UINT64_C\(0x/.test(line));
      exact(actual, expected, name + ' independent frozen F32 observer labels');
    }
    if (selected.includes('u32float')) {
      const unary = read(catalogFile).cases.filter(row => row.op === 23);
      need(unary.length === 7 && unary.every(row => row.args.length === 1 && row.comparison === 'exact'), 'Frozen U32-to-F32 inventory differs');
      const unaryExpected = unary.map(row => {
        const word = row.args[0], input = ((BigInt(word.hi) << 32n) | BigInt(word.lo)).toString(16).padStart(16, '0');
        return `  {UINT64_C(0x${input}), UINT64_C(0x${row.expectedHex}), ${JSON.stringify(row.name)}},`;
      });
      const unaryActual = fs.readFileSync(fixture(groups.u32float.observer), 'utf8').split('\n').filter(line => /^  \{UINT64_C\(0x/.test(line));
      exact(unaryActual, unaryExpected, 'u32float independent frozen conversion observer labels');
    }
  }
  report.inputs.forEach(verify);
  const api = (await import(pathToFileURL(authority.api.file))).default;
  for (const name of selected) {
    const group = groups[name];
    for (const symbol of [group.controls, group.emit, ...(group.validate ? [group.validate] : [])])
      need(authority.exports.includes(symbol) && typeof api?.[symbol] === 'function', 'Missing checked export: ' + symbol);
    if (group.validate) for (const parameters of group.validationArgs ?? [[]]) {
      const result = api[group.validate](...parameters);
      (report.validation ??= []).push({group: name, parameters, result}); save();
      need(result === '', name + ' unchanged verifier rejected fixtures: ' + result);
    }
    report.rows[name] = list(api[group.controls]()); exact(report.rows[name], group.rows, name + ' admission rows');
    for (const variant of group.variants ?? [{suffix: '', args: [], observerFlags: [], expected: group.expected}]) {
    const label = name + (variant.suffix ? '-' + variant.suffix : '');
    let text = api[group.emit](...variant.args);
    if (group.target === 'x86') {
      need(['X181Output','P188TextOutput'].includes(text?.$) && text.error === '', name + ' emission refused: ' + text?.error);
      const chunks = list(text.chunks); need(chunks.length, 'Assembly chunks required');
      if (text.$ === 'X181Output') { need(authority.exports.includes('x188_render') && typeof api.x188_render === 'function', 'Checked typed renderer required'); text = chunks.map(chunk => api.x188_render(chunk)).join(''); }
      else { need(chunks.every(chunk => typeof chunk === 'string'), 'Legacy observation text required'); text = chunks.join(''); }
    }
    need(typeof text === 'string' && text.length, 'Nonempty emitted module required');
    const names = group.target === 'qbe' ? [...text.matchAll(group.allFunctions ? /^(?:export )?function l \$([^ (]+)\(/gm : /^export function l \$([^ (]+)\(/gm)].map(m => readable(m[1])) :
      [...text.matchAll(/^\.globl ([^\s]+)$/gm)].map(m => readable(m[1]));
    exact(names, group.names, label + ' module inventory');
    const row = {label, group: name, target: group.target, emitter: group.emit, arguments: variant.args, validator: group.validate ?? null,
      names, controls: group.rows.length, observer: pin(fixture(group.observer)), slowHelperStubs: group.stubs, observerDataGlobals: group.dataGlobals ?? [],
      scope: group.scope, complete: false}; report.machine.push(row); save();
    const generated = write(label + (group.target === 'qbe' ? '.ssa' : '.s'), text); row.emitted = pin(generated);
    let assembly = generated;
    if (group.target === 'qbe') { assembly = path.join(out, label + '.s'); run(label + '-qbe', [qbe, '-t', 'amd64_sysv', '-o', assembly, generated]); record(assembly); }
    const observerAssembly = path.join(out, label + '-observer.s');
    run(label + '-observer', [linker, '-std=c11', '-O2', '-fno-pie', ...variant.observerFlags, '-S', fixture(group.observer), '-o', observerAssembly]); record(observerAssembly);
    const combined = write(label + '-combined.s', [observerAssembly, ...(group.extra ?? []).map(fixture), assembly]
      .map(file => fs.readFileSync(file, 'utf8')).join('\n') + '\n.section .note.GNU-stack,"",@progbits\n');
    const object = path.join(out, label + '.o'), binary = path.join(out, label), policy = assets.toolchains[group.target];
    run(label + '-assemble', [assembler, ...policy.assemblerFlags, '-o', object, combined]); record(object);
    run(label + '-link', [linker, ...policy.linkerFlags, object, ...policy.libraries, '-o', binary]); record(binary);
    run(label + '-execute', [binary], variant.expected); row.binary = pin(binary); row.complete = true; save();
    }
  }
  report.inputs.forEach(verify); report.complete = true;
} catch (error) { report.error = String(error.stack ?? error); process.exitCode = 1; }
report.seconds = (performance.now() - begin) / 1000; report.finished = new Date().toISOString(); save();
console.log(JSON.stringify({complete: report.complete, selected, rows: Object.fromEntries(Object.entries(report.rows).map(([name, values]) => [name, values.length])),
  machine: report.machine.map(({label, complete}) => ({label, complete})), error: report.error}));
