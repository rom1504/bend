# Rapid performance experiments

Status: first causal experiments complete; production candidates in preparation.

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

Candidates are a path-compressed persistent index, avoiding declaration-list
filtering for new names, and fewer repeated character operations in the Bend
lexer. Full checked upstream bootstraps and focused backend tests precede
source integration; complete candidate validation remains a separate milestone.

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
