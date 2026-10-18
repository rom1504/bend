// Data-only builders for root's strength audit. They do not invoke any compiler.
// JSON schema is Phase106 Nx IR; every executable expected value is independent.
const c = value => ({kind: 'const', type: 'u32', value});
const v = name => ({kind: 'var', name});
const bin = (op, lhs, rhs) => ({kind: 'bin', op, lhs, rhs});
const set = (name, value) => ({kind: 'set', name, value});
const ret = value => ({kind: 'return', value});
const mul = (value = v('x')) => bin('mul', value, c(33));
const param = (name, type = 'u32') => ({name, type});
const fn = (name, params, locals, body) => ({name, params, result: 'u32', locals, body});
const program = functions => ({version: 1, entry: 'main', functions});
const load = () => ({kind: 'load', type: 'u32', ptr: v('p'), offset: 0});
const store = value => ({kind: 'store', type: 'u32', ptr: v('p'), offset: 0, value});
const alloc = () => set('p', {kind: 'alloc', bytes: c(4)});
const free = () => ({kind: 'free', ptr: v('p')});
const values = [0, 1, 2, 33, 2147483647, 2147483648, 4294967294, 4294967295];
const u32 = value => Number(BigInt.asUintN(32, value));

function padding(name, count, multiply = true, extra = []) {
  return fn(name, [param('x')], [param('tmp'), ...extra.map(() => param('p', 'ptr'))],
    [...Array.from({length: count}, () => set('tmp', multiply ? mul() : c(0))), ...extra, ret(v('x'))]);
}

export function strengthExtraControls() {
  const touch = fn('touch', [param('p', 'ptr')], [param('old')],
    [set('old', load()), store(bin('add', v('old'), c(1))), ret(v('old'))]);
  const callMain = fn('main', [param('x')], [param('p', 'ptr'), param('once'), param('after'), param('product')],
    [alloc(), store(v('x')), set('once', {kind: 'call', name: 'touch', args: [v('p')]}),
      set('product', mul(v('once'))), set('after', load()), free(),
      ret(bin('add', v('product'), bin('mul', v('after'), c(65536))))]);
  const loadMain = fn('main', [param('x')], [param('p', 'ptr'), param('once'), param('after'), param('product')],
    [alloc(), store(v('x')), set('once', load()), store(bin('add', v('x'), c(1))),
      set('product', mul(v('once'))), set('after', load()), free(), ret(bin('xor', v('product'), v('after')))]);
  const cases = [
    {name: 'effect-call-snapshot', suite: 'effects', program: program([touch, callMain]), valid: true,
      execute: true, inputs: values.map(x => [x]), expected: values.map(x => u32(BigInt(x) * 33n + BigInt(u32(BigInt(x) + 1n)) * 65536n)),
      contract: 'Exactly one direct touch call. Its read/write remains before multiplication; no operand duplication or call elimination.'},
    {name: 'effect-load-snapshot', suite: 'effects', program: program([loadMain]), valid: true,
      execute: true, inputs: values.map(x => [x]), expected: values.map(x => u32((BigInt(x) * 33n) ^ BigInt(u32(BigInt(x) + 1n)))),
      contract: 'Two loads and two stores remain ordered around the snapshot. Multiplication uses the earlier loaded value, not a repeated load.'}
  ];
  for (const [name, operand, functions] of [
    ['nested-call', {kind: 'call', name: 'touch', args: [v('p')]}, [touch]],
    ['nested-load', load(), []],
    ['nested-alloc', {kind: 'alloc', bytes: c(4)}, []]
  ]) cases.push({name: 'invalid-effect-' + name, suite: 'effects', valid: false, unchanged: true, execute: false,
    program: program([...functions, fn('main', [], [param('p', 'ptr')], [ret(mul(operand))])]),
    contract: 'Existing verifier refuses effectful multiply operands; the pass must return the complete original graph.'});

  cases.push({name: 'functions257', suite: 'capacity', valid: true, unchanged: true, execute: false,
    program: program(Array.from({length: 257}, (_, i) => padding(i === 0 ? 'main' : 'f' + i, 1))),
    contract: 'Outer function-count limit must refuse before transformation.'});
  // 1023 multiplies cost4092 body nodes; return costs2, a constant assignment2.
  const body4096 = padding('main', 1023); body4096.body.splice(-1, 0, set('tmp', c(0)));
  cases.push({name: 'body4096', suite: 'capacity', valid: true, unchanged: false, execute: false,
    program: program([body4096]), expectedGrowth: 2046, expectedOriginalBodyNodes: 4096});
  cases.push({name: 'body4097', suite: 'capacity', valid: true, unchanged: true, execute: false,
    program: program([padding('main', 1023, true, [alloc()])]), expectedOriginalBodyNodes: 4097,
    contract: 'Allocation is structural only; do not execute this synthetic padding fixture.'});
  for (const [name, counts, unchanged, growth] of [
    ['growth4096', [683, 683, 682], false, 4096], ['growth4098', [683, 683, 683], true, 0]
  ]) cases.push({name, suite: 'capacity', valid: true, unchanged, execute: false, expectedGrowth: growth,
    program: program(counts.map((n, i) => padding(i === 0 ? 'main' : 'f' + i, n))),
    contract: 'Every original body is below4096; total transformed growth controls whole-program acceptance.'});
  //128functions*5fixed nodes +32447 two-node sets +one replacement adding2 +program1.
  const large = Array.from({length: 128}, (_, i) => padding(i === 0 ? 'main' : 'f' + i, i < 63 ? 254 : 253, false));
  large[0].body[0] = set('tmp', mul());
  cases.push({name: 'nodes65537', suite: 'capacity', valid: true, unchanged: true, execute: false,
    expectedOriginalNodes: 65537, program: program(large), contract: 'Above total-node admission with a real otherwise eligible multiply.'});
  return cases;
}

// Preserve the complete effect operand trees and statement/control positions in
// audit output. Count matching event kinds as a secondary check, not as the oracle.
export const strengthExtraScope = {
  sourceOnly: true,
  expectedCases: 11,
  effectsCases: 5,
  capacityCases: 6,
  nativeExecutionCases: 2,
  noExecution: 'Malformed and capacity fixtures must never execute.',
  priorFailure: 'bridge-check17 fixture width was consumed twice; cb1c3c0 fixes only its annotation. Core unchanged.',
  acceptance: 'Source construction is not an actual pass; root must verify fixtures, exact refusals/growth and full effectful outputs.'
};
