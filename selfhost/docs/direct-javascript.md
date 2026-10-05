# Direct JavaScript output

**Selected checked Phase52 candidate 06 is installed and verified.** The default
JavaScript interface retains the legacy compatibility contract; direct output
remains an explicit opt-in. Installed and relocated checks passed all 42 legacy
and 18 direct steps, including IO print and runtime tamper rejection/restoration.
The independent 95/96 semantic limitation below remains unresolved. The final
45-point runtime comparison completed all 669 samples; those are scoped corpus
results, not universal correctness or speed claims. See the
[Phase52 report](../../implementation/phase52/README.md) and release manifest for
selected identities and final measurements.

## Choose the JavaScript contract

From `selfhost/`, using Node.js 24 or newer:

```sh
# Default compatibility output: existing mutable G/descriptor interface.
node cli.mjs example.bend --library -o compatibility.mjs

# Direct output: upstream-style callable library exports.
node cli.mjs example.bend --direct-js --library -o direct.mjs

# Direct program: emit an ES module, then execute it.
node cli.mjs example.bend --direct-js -o example.mjs
node example.mjs -- argument

# Or check, compile and run main in one command.
node cli.mjs example.bend --direct-js --run -- argument
```

Use `.mjs` for unambiguous ES-module loading. `.js` also needs an ESM host
configuration. Direct mode cannot be combined with native/GPU output or a
non-JavaScript output suffix. Runtime arguments belong to a run, not to a library
or output-writing command. Without `--run`, `--library`, or `-o`, the normal
check-then-interpret default remains; `--direct-js` does not imply a compiled run.

Default JavaScript retains `G` and function descriptors with `code`, `env`,
`arity`, and `bound`. Its guards preserve supported mutations and fallback
behavior. Direct output uses lexical functions, native closures, and named
constructor fields. It exports no G table or legacy `call`, `list`, or `ctor`
machinery. Replacing an exported callable does not replace lexical internal
callees. Clients that inspect or mutate legacy internals should keep the default
contract. See the [parity contract](../../implementation/phase52/parity-contract.md).

The reference is Bend's TypeScript-written compiler at fixed commit
[`018751270e800bc222a93dad7f257083ee53a5f7`](https://github.com/rom1504/bend/tree/018751270e800bc222a93dad7f257083ee53a5f7).
“Upstream-compatible” names that JavaScript interface, not Microsoft's TypeScript
compiler or an unverified latest release. It remains a scoped qualification goal;
the known mismatch below prevents a blanket equivalence claim.

## Callable library example

Save this as `add.bend`:

```bend
import Base

def demo.add(+a: U32, +b: U32) -> U32:
  U32.add(a, b)
```

Emit it with `node cli.mjs add.bend --direct-js --library -o add.mjs`. A JavaScript
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

`node cli.mjs example.bend --direct-js --run` prints `42`. An IO example is:

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

- At most 512 selected emitted definitions in call/reachability analysis.
- At most 8192 scanned tail nodes per definition and 65536 queued edges per
  reachability walk.
- At most 1024 type-worklist visits for Nat conversion discovery and 64 levels
  for marshaller construction/field telescopes.
- At most 4096 type nodes for pure-main readback schemas.

These are compiler-analysis bounds, not limits on ordinary loop iteration counts.
Exhausted analyses and unsupported emission fail explicitly. The driver rejects
`JD_UNSUPPORTED` source rather than accepting a delayed throw as qualification.
There is no silent switch to the default backend. Raising these limits requires
separate scaling and refusal evidence.

## Selected 06 evidence and known limit

The independent selected-06 controller completed **95/96** scenarios across 29
fixtures; its aggregate report remains **failed**. The retained exception is
`tests/compile/f32_table_nan_bits.bend`: the source oracle expects 40, pinned
upstream returns 1, and direct returns 39 under the selected Node host. Neither
implementation passes that oracle. NaN payload transport and first-use conversion
remain unresolved; this release candidate does not claim a correction.

Direct also lacks upstream numeric match-table lowering. Upstream table reads
use `Math.min`, while direct branches can have different comparisons/coercions.
Arbitrary post-import Math/conversion hook equivalence is not established. The
selected pure, IO, FFI, Array, closure, and evaluation-order controls cover their
recorded scenarios, not every possible host hook. The maintained 26-row JS census
agreed on all observations (22 passes/four unchanged not-applicable rows), and
maintained validation passed. See [remaining work](../../implementation/phase52/remaining-work.md)
and [conformance](../../implementation/phase52/conformance.md) for the scopes.

Candidate 07's ordered-argument successor was rejected after its eight-point
screen was 25.75% slower than 06; selected 06 source was restored. Its receipts
remain retained. That small screen is separate from the final 45-point comparison
against Phase51 and pinned TypeScript.

## Release integrity and measurement scope

Ordinary compilation runs the checked compiler written in Bend. The standalone
[direct runtime](../src/runtime/js/direct.mjs) is an attributed pinned helper port
embedded in output; generated modules import neither the upstream compiler nor
the legacy runtime. Use its matching Base, driver, provider bundle, and runtime.
Release verification binds those files, and the completed
[installed/relocated qualification](../tools/performance/phase52/release-qualification.md)
checks both interfaces and deliberate copied-runtime tampering.

This installation is a checked B1 release, not a new self-emitted fixed point. Generated-program runtime measurements do not measure compiler throughput
or request latency. The unchanged 45-point/23-source catalog is a regression
corpus, not an untouched holdout or universal speed/parity evidence. Follow the
[tools guide](../tools/performance/phase52/README.md) and
[current report](../../implementation/phase52/README.md) for final corpus and
installed-release results. The [release interface receipt](../build/phase52/release-qualification06-final01/report.json)
joins successful verification and 42/18 checks with preserved sandbox and harness
failures; its pass does not change the failed 95/96 semantic aggregate.
