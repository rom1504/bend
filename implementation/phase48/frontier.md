# Phase48 frontier: exact output boundaries

This read-only census inspects the selected **Phase47 array06** output and its
paired pinned TypeScript output. It parses JavaScript as data; it does not run a
compiler or emitted program. The actionable new findings are repeated F32
literal decoding inside an already-private numeric loop, residual native String
dispatch inside an already-private Unicode graph, and the distinction between
expression producer/fold specialization and actual producer/consumer fusion.

The [experiment design](../../design/phase48/opportunity-census.md) gives the
next tests. [Machine-readable evidence](evidence/frontier-census.json) records
27 exact modules: nine sources/observations × array06, worker23 and TypeScript.
Its AST counts include unexecuted fallback and unused declarations. They are
not dynamic calls, allocation counts, hot percentages or activation evidence.

## Identity and what changed previously

The candidate archive is the published Phase47 `current/programs.tar.gz`, SHA256
`a8588a97d99c601e87ac0116d2be6923f9a17c557403118cb9c22267f3bda573`.
The baseline/TypeScript archive SHA256 is
`e8998913c37701425ddcc5cf56c9ec732f32e09bf3e0849ad74319a88d177364`.
Every extracted member's size and SHA256 matches its manifest. The API is
`28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f`,
runtime `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`,
and upstream pin `018751270e800bc222a93dad7f257083ee53a5f7`.

Across all nine inspected modules, every complete top-level `G` assignment is
byte-identical to worker23 except `pair` and `batch` in the local-row module.
The public `row.probe` and its generic helpers did not change. The runtime
addition and unrelated optimized roots remain part of the actual array06 module;
unchanged assignments do not prove unchanged JIT behavior or timing.

The census's first data-only attempt used a child `tar` command; Node reported
`spawnSync tar EPERM` despite producing stdout. No target ran and no result was
accepted. The maintained tool instead reads the bounded gzip/tar archive in
process, checks each selected member hash and parses its bytes directly.

## Where aggregate improvement can come from

These numbers are recomputed from the final Phase47 medians, with no historical
sample pooling. Shares below divide a group's sum of log(candidate/TS) by the
45-point total log slowdown. They are **not time or CPU shares**.

| Group | Points | Group geometric slowdown | Share of log slowdown | Overall if this group reaches parity |
| --- | ---: | ---: | ---: | ---: |
| Six severe cases | 6 | 56.900× | 50.29% | 1.703× |
| Expression, numeric, Unicode | 6 | 4.551× | 18.86% | 2.385× |
| Combined groups above | 12 | 16.091× | 69.15% | 1.392× |
| Map churn and records | 4 | 1.674× | 4.27% | 2.789× |

Current overall slowdown is **2.919×**, equal-source **3.996×**. Bringing only
the six severe cases to 3× TypeScript would produce a hypothetical 1.972×
overall ratio. Bringing them to parity still leaves the other 39 points at a
1.849× group mean. These are ceilings toward parity under stated substitutions,
not measured or promised optimization gains.

## Selected paths and the next discriminating experiment

Line numbers below refer to exact archive member bytes, not mutable generated
files in a checkout. Member paths/hashes and full assignment AST ranges are in
the census. The source links identify the checked Bend witnesses.

| Observation | Current ratio / TS | Exact selected output | Remaining boundary; first experiment |
| --- | ---: | --- | --- |
| [Morning](../../selfhost/tools/performance/phase37/fixtures-historical/test-morning-program.bend) | 61.273× | `main.out` line896; no contextual/scalar root in module | Recursive matched factories feed callable values to finishing helpers; test finite captured-function transport across that boundary |
| [Evening](../../selfhost/tools/performance/phase37/fixtures-historical/test-evening-program.bend) | 49.824× | `main.out` line935; no contextual/scalar root | Canonical literal F32 arrays, two swaps and tuple/matcher transport; isolate `fpart` before claiming complete-program admission |
| [RLE](../../selfhost/tools/performance/phase37/fixtures-historical/test-rle-roundtrip.bend) | 56.802× | `main.out` line841; 7 native components, 4 continuation components, 3 tail-only wrappers; 17 guards | Two transient state tuples per helper return; flatten that private tail-state transport while retaining the persistent encoded list |
| [Map/Set](../../selfhost/tools/performance/phase37/fixtures-historical/test-map-set-ops.bend) | 57.523× | `main.out` line932 generic; contextual `chk_get` and `chk_union` have 64/59 guards | Separate five public checks; identify remaining admission refusals and entry counts before attributing the whole ratio to guards |
| [Scalar zero](../../selfhost/tools/performance/phase37/fixtures-historical/scalar-region.bend) | 60.795× | `bench` line825; old private scalar root with 6 guards | Zero work still crosses public invocation/input/dependency boundary; pair zero/small/8192 inputs and isolate fresh-entry cost |
| [Complete row](../../selfhost/tools/performance/phase37/fixtures-historical/local-row.bend) | 55.959× | `row.probe` line859 generic; optimized `pair`/`batch` are separate roots | Four arrays escape as `Dp`; prove private transport plus public handle/alias/demand reconstruction |
| [Expression](../../selfhost/tools/performance/phase37/fixtures-new/expression.bend), 32/128 | 9.091× / 4.613× | `bench` line833; private unary producer and reusable-frame fold, 4 guards | Entire expression tree is still built before folding; test true producer/consumer fusion or separately simplify producer continuation transport |
| [Numeric](../../selfhost/tools/performance/phase37/fixtures-new/numeric-recurrence.bend), 256/1024 | 6.802× / 2.714× | `bench` line817; direct counted loop, 3 guards | Three repeated `bitsFloat` calls per iteration and native conversion helper; isolate literal decoding first |
| [Unicode](../../selfhost/tools/performance/phase37/fixtures-new/unicode-text.bend), 16/64 | 4.352× / 2.636× | `bench` line852; contextual graph, 4 native/3 continuation components, 18 guards | Already-private String concatenations still invoke generic native dispatch; lower the proved native operation directly |

### Numeric: a hot-loop representation difference with a cheap ablation

The private `p37.numeric` helper inside `G["bench"]` already has a Number
countdown and scalar locals. Each loop body contains these exact calls:

| Bit payload | Private emitted expression | Paired TS expression |
| ---: | --- | --- |
| 1081081856 | `bitsFloat(1081081856)` | `3.75` |
| 1065353216 | `bitsFloat(1065353216)` | `1` |
| 1232348160 | `bitsFloat(1232348160)` | `1000000` |

The initial value additionally decodes `100.0` outside the loop; the first
experiment deliberately leaves that and every public fallback unchanged.
`bitsFloat` writes a shared DataView then reads Float32. The full region guard
checks the view's prototype/own methods and the canonical prototype methods.
A prior generic hook may retain the view, so removing its writes is not an
observationally neutral literal substitution.

The prepared derivative therefore compares original code, write-preserving
literal decoding, and a separately labeled pure-literal upper bound. All
`Math.fround` operations remain. The producer/controller are ready for root-run
controls and timing; this census supplies **no execution result** for them.

Current literal printing goes through `j_word_text` in
[literals.bend](../../selfhost/src/back/js/literals.bend), also used by ordinary
`JIRWord` emission. A production change must carry a proved private context;
changing this shared printer globally would alter the generic fallback. The
older private planner already annotates literal type in `j_region_expr_on`,
while the private loop ultimately calls ordinary `j_expr` from
[worker.bend](../../selfhost/src/back/js/worker.bend). This is a context-propagation
problem rather than a lack of constant values in the IR.

The loop also calls `regionF32ToU32`, whose selected runtime body checks
`Number.isFinite` and uses `Math.trunc`; upstream spells a bounded conditional
and `Math.floor`. This is a separate candidate, not credited to constant decoding.

### Unicode: a complete worker still calls a generic native

The root's ordered dependencies are 11 source functions plus seven primitive/
native names, including `String.append`. Private repeat and join functions
contain `callOwned(get(G,"String.append"),[...])`. Root construction has two
more calls. The paired TS repeat/join/root expressions use direct `+`.

This follows the unconditional `JWNative` dispatch in
[worker-emit.bend](../../selfhost/src/back/js/ir/worker-emit.bend): the exact
runtime [native definition](../../selfhost/src/runtime/js/base.mjs) is
`(a,b)=>a+b`. Existing lowering checks scalar native argument/result layouts;
the complete graph's dependency guards remain necessary. Removing native
dispatch/temporary argument vectors at this typed boundary is a smaller
experiment than rebuilding String algorithms.

Other costs remain: split traverses one code point at a time, recursively builds
a list of strings and join consumes that list; native recursion can reach the
bounded continuation fallback. Static presence does not establish dynamic
fallback frequency. Char code-point conversion and persistent list construction
must not be counted as eliminated by a String.append change.

### Expression: two optimizations are not yet a composed optimization

The root invokes a private unary producer followed by a private sum fold.
The producer stores `{args:[...],before:[...]}` on its unwind stack, constructs
the complete `Lit/Add/Mul/Sub` tree using `ctor`, and returns it. The fold then
walks that tree with reusable `{node,tag,phase,value}` frames. There is no generic
recursive call on this selected private path, but the intermediate tree and
producer frames survive. Upstream uses direct recursive functions and named
constructor fields; it also materializes the tree.

Consequently, a general producer/algebra composition could outperform both
representations, but this is unmeasured. A diagnostic derivative must preserve
which recursive child is evaluated first, overflow wrapping, all demanded
fields and effect/error boundaries. The older four-name guard should not be
replaced by a larger worker fence merely to gain a common IR.

### RLE: remove state transport, not the shared output

The native `rle` component projects `[head,[count,list]]`, calls private
`rle.step`, then carries only the returned state to the next tail iteration.
Both `rle.step` branches allocate two nested state tuples. The unequal branch
also allocates the persistent encoded pair and `Con` node; those are distinct
from transient state. The caller `go` passes the resulting encoded list to
both `llenp` and `expand`, so single-consumer list fusion is not justified.
Upstream also returns nested Tuple objects here: the opportunity is a better
private product calling convention, not simply reproducing TS output.

The earlier worker cleanup did not enter this branchy helper or remove its
cross-return transport. A bounded product result/parameter convention should
prove elimination at this exact consumer, with renamed recursive witnesses,
before another broad pass is retained.

### Coverage boundaries that must not be silently overstated

Morning's `Str.split` supplies `Str.split.fin` with the partially applied
recursive call; join similarly transports a two-capture partial result. The TS
backend uses `run_clo` around a normal callable and invokes that callable in the
finisher. An initial pass limited to leading lambdas or singleton Let factories
does not yet establish this recursive matched-factory coverage.

Evening's scalar `fpart` constructs `ANode(ALeaf(0.5),ALeaf(1.5))`, performs
two `Array.swap` operations and matches their tuple results. It does not begin
with `Array.new`. Broadening the native operation whitelist alone leaves lazy
constructor materialization and iterator demand unresolved. The larger main
program additionally exercises Set, numeric showing and String parsing.

Generic row has 18 static `callOwned` sites in the `row.probe` assignment and
deferred `Dp` construction in `cell.f4`. Its terminal row swaps two array roles.
Paired TS uses raw arrays/direct calls but still constructs result records and
get-result tuples. The existing observation adapter serializes all four returned
backings. A scalar checksum path is not an equivalent benchmark observation.

Map/Set remains partly private. The earlier native String equality prototypes
already improved one narrow point while expanding its module substantially;
they were not selected. Reuse that evidence when considering native admission,
and independently diagnose `chk_del` instead of attributing every refusal to
String equality.

Scalar-zero's 6-name boundary is much smaller than some complete worker guards,
yet its 4.081 microsecond call is 60.795× a 0.067 microsecond TS observation.
Its 8192-step sibling is 1.160× TS. This supports separating fixed boundary and
useful work; it does not identify every microsecond or authorize stale proofs.

## Status and next evidence

Only saved data was consumed for this census. No target, profiler, compiler,
conformance suite or release check ran. The numeric derivative has a separate
root-owned execution handoff; no result is anticipated here. Other owners have
the exact closure, Array/composite, product and native-dispatch findings above.

Use the next independent controls to establish the general mechanism, then
counter derivatives to establish activation, and clean timing to establish
benefit. Profile the unresolved outliers themselves before importing percentages
from old Map/record profiles. Preserve all closed Phase45–47 evidence and the
103 unrelated starting files.
