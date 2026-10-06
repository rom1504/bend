# Direct JavaScript output

**Checked Phase53 ordered02 is installed and verified; direct JavaScript is the
default.** Ordinary compilation, library output and `--run` use callable direct
output. `--legacy-js` retains the descriptor compatibility interface. Ordered02
passes the original 96 source scenarios, 18 composition controls, 34 numeric
controls and two overapplication controls, plus the maintained direct census and
eight explicit legacy suites. These overlapping gates are separate evidence, not
a unique test total. Ordinary and relocated release checks passed all 42 legacy
and 24 default-direct/legacy steps, including IO printing and runtime tamper
rejection/restoration. Fresh installed preparation also passed the complete
four-array row oracle. The final 45-point comparison completed all 669 samples
with a 1.055785× geometric speedup over original direct06; this is scoped corpus
evidence, not a universal performance claim. See the
[Phase53 report](../../implementation/phase53/README.md),
[qualification report](../../implementation/phase53/qualification.md) and
[routing contract](../tools/performance/phase53/routing.md).

## Choose the JavaScript contract

From `selfhost/`, using Node.js 24 or newer:

```sh
# Default output: upstream-style callable library exports.
node cli.mjs example.bend --library -o direct.mjs

# Explicit compatibility output: mutable G/descriptor interface.
node cli.mjs example.bend --legacy-js --library -o compatibility.mjs

# Direct program: emit an ES module, then execute it.
node cli.mjs example.bend -o example.mjs
node example.mjs -- argument

# Or check, compile and run main in one command.
node cli.mjs example.bend --run -- argument
```

Use `.mjs` for unambiguous ES-module loading. `.js` also needs an ESM host
configuration. Explicit `--direct-js` and `--legacy-js` cannot be combined with
each other or native/GPU output. Without either JS selector, native targets retain their
existing routing; a mixed `.mjs`/`.c` request selects each emitter independently.
Runtime arguments belong to a run, not to a library
or output-writing command. Without `--run`, `--library`, or `-o`, the normal
check-then-interpret default remains; `--direct-js` does not imply a compiled run.

Explicit legacy JavaScript retains `G` and function descriptors with `code`,
`env`, `arity`, and `bound`. Its guards preserve supported mutations and fallback
behavior. Direct output uses lexical functions, native closures, and named
constructor fields. It exports no G table or legacy `call`, `list`, or `ctor`
machinery. Replacing an exported callable does not replace lexical internal
callees. Clients that inspect or mutate legacy internals must select
`--legacy-js`, or
`backend:'js'` in the driver API. Omitted API backend in checked compile/library
requests selects direct, while explicit `backend:'direct'` remains supported.
Compiler-image bootstrap and maintained private compiler-image workers keep
their explicit legacy contract. See the
[parity contract](../../implementation/phase52/parity-contract.md).

The reference is Bend's TypeScript-written compiler at fixed commit
[`018751270e800bc222a93dad7f257083ee53a5f7`](https://github.com/rom1504/bend/tree/018751270e800bc222a93dad7f257083ee53a5f7).
“Upstream-compatible” names that JavaScript interface, not Microsoft's TypeScript
compiler or an unverified latest release. It remains a scoped qualification goal;
the recorded controls do not establish blanket language or host equivalence.

## Callable library example

Save this as `add.bend`:

```bend
import Base

def demo.add(+a: U32, +b: U32) -> U32:
  U32.add(a, b)
```

Emit it with `node cli.mjs add.bend --library -o add.mjs`. A JavaScript
client can call or partially apply its default exports:

```js
import bend from './add.mjs';
console.log(bend['demo.add'](20, 22)); // 42
console.log(bend['demo.add'](20)(22)); // 42
```

Export names are resolved source names in the loading book. Wrappers accept live
arguments and omit erased type arguments. Partial application follows pinned
`run_lib`; source function results are native callable closures. Ordinary filled,
nonnative, nontemplate definitions are exported, excluding Foreign definitions
and definitions whose original whole type is `IO<A>`. A function with type
`U32 -> IO<Unit>` remains callable. See [ABI.md](../tools/performance/phase52/ABI.md)
for typed conversions and the precise export predicate.

## Pure and IO programs

A pure `main` is printed in the pinned Bend format. For example:

```bend
import Base

def main() -> U32:
  U32.add(20, 22)
```

`node cli.mjs example.bend --run` prints `42`. An IO example is:

```bend
import Base

def main() -> IO(Unit):
  IO.print("hello")
```

The same command prints `hello` through the direct CPS scheduler. Emitting an
`.mjs` program preserves that behavior when executed with Node. Main must be a
filled definition, and a build needs Base. Pure printing uses a Bend-built type
schema and the pinned display helper; an unprintable main type fails explicitly.

Foreign JavaScript sources register typed `$FFI` operations with arguments and a
continuation. Registry reads, argument evaluation, conversions, mutations,
failures, and callback order remain observable parts of this contract. Missing
sources, invalid source identifiers, and missing registrations fail explicitly;
there is no delegation to legacy execution or the TypeScript implementation.

The 37 pinned Base JS effect sources are
[vendored byte-for-byte](../src/runtime/js/effs/README.md). Mapping requires exact
pinned Base content and listed filenames beside that Base. Custom Base providers
and user effect paths retain their original resolution. Generated modules provide
an ESM `createRequire` binding when needed. Some syscall/polling paths still need
the pinned Bun FFI facilities or a suitable `globalThis.BEND_SYS` provider;
successful Node printing does not establish every system/asynchronous effect.
Foreign source code must be trusted by the caller.

## Native values and compiler bounds

U32/F32 use JavaScript numbers; Bool uses booleans; String/Char use strings. Nat
uses Number internally and typed BigInt conversion at public boundaries. The
pinned immediate arithmetic limit is `2^48 - 1`; `nat_host` separately accepts
nonnegative integer Number/BigInt inputs through `2^53`. Invalid host inputs use
a deferred throwing value, so conversion acceptance does not promise arithmetic
will succeed. These are distinct bounds, not arbitrary-precision Nat arithmetic.

Constructors use resolved tags and named fields. Unit is `{$: 'Unit'}`; tuples
use `{$: 'Tuple', fst, snd}`. Arrays use native JS storage. Nat-containing arrays
are converted in place at typed boundaries; recursive records and function
arguments/results receive typed conversion when needed. Aliasing, mutation, and
error timing matter alongside complete final values. Some non-tail recursion and
branching host conversions still consume native JS stack space.

Supported primitives require the checked native declaration; same-spelled user
functions do not acquire primitive behavior. Operations without a direct template
can retain their checked source implementation. Tail-call analysis and lexical
SCC dispatch support the admitted recursive call graph without a mutable global
callee registry. Analysis is bounded:

- At most 512 conservatively eligible runtime definitions before exact emitted
  dependency pruning. This can reject a source whose final output would contain
  fewer than 512 definitions; see the [scaling audit](../../implementation/phase53/scaling.md).
- At most 8192 scanned tail nodes per definition and 65536 queued edges per
  reachability walk.
- At most 1024 type-worklist visits for Nat conversion discovery and 64 levels
  for marshaller construction/field telescopes.
- At most 4096 type nodes for pure-main readback schemas.

These are compiler-analysis bounds, not limits on ordinary loop iteration counts.
Exhausted analyses and unsupported emission fail explicitly. The driver rejects
`JD_UNSUPPORTED` source rather than accepting a delayed throw as qualification.
There is no silent switch to the legacy backend or TypeScript compiler. Raising
these limits requires separate scaling and refusal evidence.

## Ordered expression architecture

The direct backend has 11 Bend modules. `model`, `reach` and `calls` establish
typed arity, dependencies and recursive call planning; `core`, `pattern`,
`constructors` and `primitive` emit lexical code; `host` and `program` implement
callable boundaries, foreign operations and program readback. The new
[`ordered.bend`](../src/back/js/direct/ordered.bend) and
[`ordered-values.bend`](../src/back/js/direct/ordered-values.bend) compose
statement prefixes with pending values through named calls, unknown callable
applications, constructor fields and expression lets. This representation is
compiler metadata; it adds no new public value representation.

The emitter follows the pinned compiler's two-stage order: collect child
statement prefixes first, then hold pending non-atomic operands at intrinsic
boundaries. Ordinary calls keep their operands pending after those prefixes.
For example, nested `U32.mul(f(n), U32.add(g(n + 1), 3))` can call `g` before
`f`; universal textual left-to-right execution is not the target contract.
Closure bodies retain their own statement scope. Partial application defers
supplied work until full application, and captured let aliases use names distinct
from arithmetic temporaries. No wrapper per primitive operation or program-name
condition is introduced. See the
[ordering design](../../design/phase53/ordered-prefix-evaluation-order.md) and
[source accounting](../../implementation/phase53/complexity.md).

## Qualified correction and retained reference failure

The Phase52 selected06 semantic aggregate passed 95/96 and remained failed.
Its direct output returned 39 for `tests/compile/f32_table_nan_bits.bend`, whose
source oracle expects 40. **Ordered02 returns 40 and passes all 96 source
scenarios.** Pinned TypeScript still returns 1, so it passes 95/96; exact
differential agreement is also 95/96. The remaining difference is the recorded
reference bug, not an unresolved candidate source failure. No oracle was weakened.

The correction removes the intermediate ordinary array from `f32_bits` and uses
fresh typed-array storage, preserving the tested NaN payloads without shared
mutable conversion state. Original and independently renamed cases pass cold
and repeated calls. Numeric controls pass 34/34 for the candidate and 28/34 for
the reference: three fresh processes per original/renamed NaN case expose the
reference's `[1,0,0]` sequence versus the candidate's `[40,40,40]`. All finite
numeric and callback-order controls pass in both roles. See
[NaN diagnosis](../../implementation/phase53/nan-payload.md).

Completed checked-image receipts are separate. The tracked
[hash-bound qualification summary](../tools/performance/phase53/semantic-qualified-ordered02-v1.json)
binds the source/API/runtime identities and the archived raw report members:

- [Original source scenarios](../../implementation/phase53/qualification.md):
  candidate 96/96, reference 95/96.
- [Composition](../../implementation/phase53/qualification.md):
  18/18 in both roles, including getters, throws, constructors, captures and
  partial application.
- [Numeric/runtime controls](../../implementation/phase53/qualification.md):
  candidate 34/34, reference 28/34.
- [Overapplication](../../implementation/phase53/qualification.md):
  2/2 in both roles, through a let barrier that prevents arity raising.
- [Maintained direct census](../../implementation/phase53/qualification.md):
  all 26 rows agree, including 18 runtime passes, four expected compilation
  rejections and four N/A.
- [Explicit legacy compatibility](../../implementation/phase53/qualification.md):
  all eight suites pass after four maintained test calls explicitly select the
  old ABI; the original default-routing failure and old bytes remain preserved.

Direct still lacks upstream numeric match-table lowering. Arbitrary post-import
Math/conversion hook equivalence is not established. Source values, thrown
errors and event order are checked for the recorded scenarios; this is no
universal host-hook claim. The Phase52 ordered-argument prototype07 rejection
and earlier Phase53 failures remain historical evidence, separate from ordered02
qualification and its completed selected corpus/release checks.

## Release integrity and measurement scope

Ordinary compilation runs the checked compiler written in Bend. The standalone
[direct runtime](../src/runtime/js/direct.mjs) is an attributed pinned helper port
embedded in output; generated modules import neither the upstream compiler nor
the legacy runtime. Use its matching Base, driver, provider bundle, and runtime.
Release verification binds those files. Phase53's installed and relocated
qualification passed the explicit legacy42 and default24 gates, checked partial
callable exports without G, rejected deliberate copied-runtime tampering and
verified exact restoration. The direct preparation wrapper also passed a fresh
installed complete-row oracle. See the
[Phase53 routing/release method](../tools/performance/phase53/routing.md) and
[current report](../../implementation/phase53/README.md).

This is a checked B1 release, not a new self-emitted fixed point. Generated-program
runtime measurements do not measure compiler throughput or request latency. The
unchanged 45-point/23-source catalog is a regression corpus, not an untouched
holdout or universal speed/parity evidence. Phase52's
[installed/relocated qualification](../tools/performance/phase52/release-qualification.md)
and [report](../../implementation/phase52/README.md) remain historical evidence;
their successful release checks did not change that older failed 95/96 semantic
aggregate. Phase53 fixes the candidate NaN failure while retaining the reference
failure as recorded evidence.
