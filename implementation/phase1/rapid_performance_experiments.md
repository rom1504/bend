# Rapid performance experiments

Status: two pure-Bend improvements integrated; checked bootstrap and all component
groups pass. A new whole-compiler fixed-point run is in progress.

The [design](../../design/phase1/rapid_performance_experiments.md) separates cheap
causal experiments from full compiler validation. The frozen phase 1 API is
`dist/phase1/selfhost-api.mjs`, SHA-256
`44227e5e9aa714682c3a5f042cbf38fce86cc6bc510265aeda75103ed242579a`.
The earlier fixed-point and corpus run remain evidence for that artifact only.

## Round 1: calls and index

The four-cell experiment compiled tree/IO with full checking, cache off, three
fresh processes per variant in rotating order on physical CPU 1. Each emitted
program ran and printed 42. All 12 emitted outputs were byte-identical. The
reference is the final phase 1 compiler, not the original TypeScript compiler.

| Disposable compiler variant | Median compilation | Relative to control |
|---|---:|---:|
| Unchanged phase 1 | 17.302 s | 1.00× |
| Guarded direct worker calls | 16.783 s | 1.03× |
| Persistent JS Map index ablation | 13.824 s | 1.25× |
| Both changes | 12.642 s | 1.37× |

The direct-call transform replaces 10,248 saturated global call sites and 1,872
tail sites. It retains live global lookup, function evaluation before arguments,
arity/bound-argument guards, forcing and stack-safe tail calls. The worker owns
a fresh argument array, avoiding the copy performed by public `apply`. Twelve
focused regressions cover mutation, effects, partial/overapplication, environments,
ownership and 50,000 tail calls. The **3% median improvement alone is small**:
removing this copy/dispatch path does not explain most of the observed runtime
overhead. The profile's 48% runtime share was never an achievable speedup promise.

The map prototype replaces whole-root index build/find/set/lookup. Updates clone
the map and retain a serializable definition list; old versions, first-duplicate
lookup and source declaration order remain intact. Tests include Unicode names,
actual hash collisions, missing names, retained versions and serialized clones.
It is a diagnostic host-language substitution, not a supported Bend compiler
implementation. Its result justifies a pure-Bend compressed-trie experiment.

The combined result is measured separately rather than obtained by multiplying
the individual speedups. Other physical cores ran the frozen full-source control
comparison and independent work. Existing corpus group 13 finished before CPU 1
was used. Its scheduler was paused between groups; active tests kept running
with their original deadlines. This remains a shared-host experiment.

[Raw timings, per-phase measurements, output checks and frozen artifact hashes](rapid-evidence/round1-factorial.json)
and [transform provenance](rapid-evidence/round1-transforms.json) preserve the
exact inputs. No compiler rebuild was needed for this experiment.

## Lexer probe

On the 64,336-byte Base source, three alternating in-process observations give
median tokenization times of 2.033 s unchanged, 1.631 s with direct head/tail
workers, and 0.067 s with a diagnostic host-language cursor lexer. Every token,
position and output hash matches. Cursor timings span 0.0066–0.0800 s, so JIT
warmup materially affects this small experiment; these are not fresh-process
whole-compilation speedups.

A separate untimed count records 858,992 calls to `f_head`, 395,987 to `f_tail`,
84,651 to `f_three`, and 53,718 to `String.reverse`. The current head accessor
projects both head and suffix before discarding the suffix; the tail accessor
repeats that work. The cursor prototype also replaces recursive tokenization,
word reversal and many generic operations. It therefore identifies a large
optimization opportunity but does not attribute it to suffix slicing alone.
Four differential test groups include 300 deterministic mixed-input cases,
Unicode, malformed UTF-16 fallback, token columns, quote errors and U32 wrapping.

[Lexer measurements and operation counts](rapid-evidence/lexer-base.json).
Complete parsing confirms that the lexer cost matters beyond its microbenchmark:
median Base parse time is 4.556 s unchanged, 4.031 s with direct head/tail access,
and 2.637 s with the cursor prototype. All parsed books, errors and imports are
identical. These remain alternating in-process observations, including warmup
variation; see [parser evidence](rapid-evidence/parser-base.json).

## Round 2: positional workers and combined upper bound

The next three-minute experiment generated 1,077 positional workers, keeping
generic function objects for higher-order/partial calls and guarding code,
environment, arity and identity before direct calls. Seven focused test groups
cover effects, mutable globals, environment/factory exclusion, escaped argument
arrays, partial/oversaturation and deep tail calls. Tail calls retain the original
trampoline. This is a disposable transform, not a new production emitter.

| Disposable compiler variant | Median compilation | Relative to round 2 control |
|---|---:|---:|
| Unchanged phase 1 | 17.143 s | 1.00× |
| Guarded positional workers | 16.398 s | 1.05× |
| Positional workers + Map | 13.446 s | 1.27× |
| Positional workers + Map + cursor | 10.878 s | 1.58× |

All 12 fresh-process compilations succeeded, produced byte-identical programs
and executed to 42. Cache policy, input and checking remain unchanged. Control
observations range 16.648–19.959 s, so small differences deserve caution on this
shared host. The production cost of duplicating 1,077 worker bodies is not
justified by this modest isolated improvement. This result redirects effort
toward data structures and reducing actual operations.

[Round 2 raw measurements](rapid-evidence/round2-positional.json) and
[transform provenance](rapid-evidence/round2-transforms.json) distinguish this
combined diagnostic result from a supported Bend implementation speedup.

An additional static experiment falsified the idea that arbitrary nested calls
were redundant currying: respecting actual runtime arities finds only one
flattenable site. In particular, the generated `Bool.and` is an arity-one matcher,
not the runtime's initially installed arity-two primitive. Replacing it changes
intermediate application behavior and must be treated as a separate hypothesis.

## Production experiments underway

The next loop compiles just the changed Bend module and its dependencies, then
transplants its generated workers into a disposable copy of the frozen compiler.
Constructor metadata must match; all selected module workers must be present.
This tests actual Bend-generated implementation changes without a 40-minute
self-build. A component capsule is explicitly not a whole-compiler fixed point.

## Integrated Bend changes

`src/core/index.bend` now uses a persistent Patricia trie. Each internal node
stores one discriminating hash bit; collision leaves still compare complete
names. The 1,024-key test has 1,024 leaves and 1,023 branches, with maximum depth
13. Root operations retain the existing complete 32-bit hash ABI used by the
native identifier validator. Source declaration lists and cached bounds remain
separate from the index representation.

`book_put` also avoids filtering the declaration list when the old cache proves
the nonempty name absent. Replacements and unusual empty names keep the original
filtering behavior. This proof matters: simply dropping the filter would retain
duplicate definitions and change declaration order. Both a prior version and a
new version remain usable after every update.

The first Patricia-only component experiment improved lookup about 2.2× and
construction about 2.9×, but did not improve insertion into the declaration list.
Adding the proven-miss path reduced 64 new-name insertions into a 1,024-definition
book from a local median 316.2 ms to 8.4 ms (**37.6×**). Existing-name replacements
did not improve. These are component results, not whole-compilation multipliers.
The final Bend-generated capsule passes **5,769 differential checks**, including
all 32 branch bits, collisions, duplicates, missing/empty names, bounds, ordering
and retained old versions. The standard index test now also covers the new path.

`src/front/lexer.bend` moves ordinary identifiers ahead of unnecessary triple-token
checks and avoids eager exponent-lookahead work when a character is already an
identifier character. Compiler-local ASCII predicates extract a numeric character
once and use U32 comparisons. Base Char definitions, public runtime primitives and
Unicode policy remain unchanged. The candidate matches **327 tokenization cases**,
including 24,056 Base tokens, 37 identical failures, malformed UTF-16, non-BMP
characters and U32 position wrapping. Complete Base parsing is structurally equal.
Generated Bend helpers passed **4,456,569 comparisons** over all 1,114,112 codepoint
values, including surrogate numbers; those classifier tests do not make surrogate
text valid input.

The capsule comparison for these actual Bend changes used three rotating fresh
processes per cell, checking enabled and caching off:

| Compiler workers | Median tree compilation |
|---|---:|
| Frozen phase 1 control | 17.698 s |
| Bend index and insertion changes | 14.854 s |
| Bend lexer changes | 16.822 s |
| Both Bend modules | 14.099 s |

Together these save **20.3%** of compilation time (**1.26×**), with identical
emitted bytes and successful execution in every sample. This is useful but much
smaller than the largest component result; it does not close the TypeScript gap.
An earlier lexer variant plus the index was no faster than the index alone, so
we do not assume every small source transformation improves the full compiler.

[Pure-Bend comparison](rapid-evidence/bend-ascii-index.json),
[earlier variant comparison](rapid-evidence/bend-index-lexer-v2.json),
[index checks](rapid-evidence/index-v2-differential.log),
[lexer checks](rapid-evidence/ascii-differential.json), and
[exhaustive predicate checks](rapid-evidence/ascii-predicates.json) retain the
evidence. Capsule manifests identify exact module/compiler hashes.

## Complete checked bootstrap

The integrated source rebuilt through pinned upstream in **20.637 seconds** and
passed all **19 component groups** in another **36.865 seconds**, including the
suite's own test API build. This **57.5-second** validation cycle checks the edited
Bend source. It does not establish a self-emitted fixed point or whole-corpus
conformance. The two source modules in the main checkout match the checked
snapshot; compiler API SHA-256 is
`37ebe8aea31b13aecd2ea84e5aaa0c5d2c48659e48661980badf71cb43e890e5`.

Three fresh-process uncached tree compilations give medians **0.386 s upstream**,
**7.147 s previous bootstrap**, and **6.350 s new bootstrap**. The two Bend
bootstrap artifacts emit identical program bytes and all nine executions print
42. This is an **11.1% reduction** versus the preceding bootstrap; it is still
about **16.5× slower** than the TypeScript compiler on this workload.

[Build provenance](rapid-evidence/integrated-bootstrap.json),
[component results](rapid-evidence/integrated-components.json), and
[bootstrap performance](rapid-evidence/integrated-bootstrap-performance.json)
keep these execution modes distinct. The new frozen source/API/runtime have
started a separate fixed-point chain on a reserved core. The previous phase 1
corpus continues on other cores; its evidence cannot certify this newer compiler.

The first checked self-emission of the integrated source completed in
**728.772 seconds (12.15 minutes)**. Its output SHA-256 is
`ea27e9e9a50ee5a5a569f785c4436e7100ab371c15f258f1a7d26ba1ee4354d5`.
The second emission is still running; a fixed point is not yet established.
This is a changed-source validation milestone, not a controlled speedup claim
against the previous source's self-emission time. Component experiments continued
on a separate physical core throughout the long proof.

## Matcher allocation and fallback chains

A disposable generated-code transform removes temporary function wrappers from
901 literal matcher arms and optionally fuses 463 fallback chains (934 nodes).
It preserves defensive argument copies, getter/effect order, partial and excess
arguments, computed-arm laziness, zero-field function identity and tail calls.
The focused suite passes 59 ABI/effect checks, including 50,000 tail calls.

| Compiler workers | Median tree compilation |
|---|---:|
| Frozen phase 1 control | 18.393 s |
| Fused literal arms | 17.754 s |
| Fused arms and fallback chains | 17.058 s |
| Bend index/lexer plus matcher fusion | 13.758 s |

Three rotating fresh processes per cell produced identical JS bytes and printed
42 in all 12 samples. Matcher fusion alone saves **7.3%**; its complexity is not
justified as an immediate production backend change. The combined result saves
**25.2%** against this run's control. This block does not include a Bend-modules-only
cell, so it does not establish the incremental matcher gain on those modules.
Native execution is the next larger hypothesis to test before further small JS
runtime rewrites. [Measurements](rapid-evidence/matcher-workers.json) and
[transform counts](rapid-evidence/matcher-transforms.json) retain exact artifacts.

Reproduce the transform and focused checks with:

```sh
node tools/performance/rapid/matcher-workers.mjs \
  dist/phase1/selfhost-api.mjs build/matcher-experiment.mjs --chains
node --stack-size=4096 tools/performance/rapid/matcher-workers.test.mjs --chains
```

Run the resulting API through the same `compare.py` fresh-process protocol; the
checked-in measurement records its full configuration.

## Rejected or deferred experiments

A further diagnostic specializes 2,446 non-tail calls to 28 retained scalar
primitives. It preserves live function identity/code/arity/environment guards,
callee-before-argument evaluation, fallback behavior and tail-call timing. Proven
scalar results bypass argument arrays and generic forcing. It passes 8,400
differential corner cases and 12 mutation/order/ABI checks.

Three fresh-process medians are 18.461 s control, 16.806 s with scalar
specialization, 14.786 s with the integrated Bend modules, and 13.470 s with
both. All outputs remain byte-identical and execute to 42. That is about **9%**
additional time reduction from scalar specialization, measured independently and
on top of the Bend changes. It is a candidate for later backend work, not an
integrated emitter optimization. [Measurements](rapid-evidence/native-scalars.json)
and [differential tests](rapid-evidence/native-scalar-tests.json) retain the details.

- Guarded calls and positional workers alone improved medians only 3–5%; no large
  emitter/runtime rewrite is integrated from that evidence.
- Retaining native `Bool.and`/`Bool.not` and flattening calls changes malformed
  host-value handling and intermediate failure order. Fourteen negative
  observations remain in [the differential report](rapid-evidence/boolean-differential.json).
  The compatible staged variant is separate. Boolean timing samples overlapped
  short lexer builds on the same core (including 07:45:02–07:45:14 UTC), so
  [that exploratory timing report](rapid-evidence/boolean-exploratory.json) is not
  used to claim a speedup. The unsafe whitelist change is not integrated.
- The diagnostic Map and JS cursor remain experiments. The integrated compiler
  algorithms remain Bend; its runtime and JS emitter are unchanged in this step.

See [fast compiler development](../../docs/FAST_COMPILER_DEVELOPMENT.md) for the
component/capsule workflow. Source improvements are committed independently of
promotion: distributed phase 1 artifacts remain their original frozen versions.

## Reproduction

From `selfhost`, using Node 24 and the pinned `.bootstrap/upstream` checkout:

```sh
node tools/performance/rapid/prepare.mjs build/rapid/new-run 1 3
python3 tools/performance/compare.py build/rapid/new-run/config.json build/rapid/new-run/results
node tools/performance/rapid/direct-calls.test.mjs
node --stack-size=4096 tools/performance/rapid/compact-index.test.mjs
node --stack-size=4096 tools/performance/rapid/lexer-probe.test.mjs
taskset -c 1 node --stack-size=4096 tools/performance/rapid/lexer-probe.mjs \
  dist/phase1/selfhost-api.mjs .bootstrap/upstream/bend2/base.bend \
  build/rapid/lexer.json 3 lex
```

Choose a free physical CPU. Outputs must use a new directory; the original
compiler and public `apply` argument-copy contract remain unchanged.
