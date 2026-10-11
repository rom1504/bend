# Checked scalar arrays: Phase68 integration

Design: [checked scalar arrays](../../design/phase68/checked-scalar-arrays.md).
Experiments: [P68-017](../../experiments/phase68/P68-017-checked-scalar-layout.md),
[P68-018](../../experiments/phase68/P68-018-unshared-user-constructors.md).

## Result

The actual checked compiler20 improves the six-family native runtime geometric
mean **5.6816× versus installed Phase67**, leaving **1.7449× upstream C runtime**.
Numeric and array workloads reach upstream parity. This is a six-family screen,
not a claim about every Bend program. The cumulative gain includes earlier
Phase68 worker, product and constructor-packing work; it is not all due to arrays.

Same-source, same-Clang, CPU3, one native thread, GPU off; three balanced rotations
of installed/candidate/upstream roles. All 54 observations pass independent
checksums and the 100ms measured-interval floor. Values are medians in ms:

| Family | Installed | Candidate20 | Upstream | Candidate / upstream |
|---|---:|---:|---:|---:|
| Numeric | 1795 | 252 | 252 | 1.000× |
| Array | 14591 | 184 | 185 | 0.995× |
| Closures | 506 | 403 | 227 | 1.775× |
| Tree | 1877 | 647 | 193 | 3.352× |
| Map | 2386 | 729 | 393 | 1.855× |
| Lexer | 2927 | 586 | 228 | 2.570× |

The array-only development loop measured packed-only compiler18 at
278/278/289ms and combined compiler20 at 172/176/174ms. The final balanced
campaign above is separate. The main mechanism is recovering type/ownership
facts already known after checking: 32-bit storage and direct unshared access
replace generic 64-bit terms and reference-count location lookup.

## Implementation and boundary

`scalar-array.bend` adds a conservative checked-entry certificate. All reachable
array representation demands must agree on scalar elements; unknown sites,
proof transport and unaudited foreign calls refuse it. A separate use analysis
allows multiple uses only for recursively proven array-free trusted Base values.
User ADTs, functions/IO and opaque types decline. Packed seeds cannot introduce
hidden sharing of user objects. Match alternatives use maximum use counts;
parallel operands count together.

Raw `nc_compile` cannot opt in from arbitrary annotations. The new exported
`nc_compile_checked` requires a checked/specialized/annotated book, layout
validation and authenticated runtime/effects. The ordinary host enforces the
pinned Base hash and exact args/print/now handler hashes, and passes the effect
permission. Changed Base or unknown effects retain the generic path. This is a
trusted compiler API contract, not validation of arbitrary calls to that API.

The C runtime centralizes array get/set/swap for both ordinary and product-result
lowering. Creation, leaf extraction and atomics respect 32/64-bit width. Existing
copy/half/show/drop paths dispatch on tags. Uniform whole-program layout avoids
mixed-width node construction. The analysis is general but intentionally
conservative; per-array specialization is deferred.

Compiler20 also includes previously uncommitted Phase68 bounded product-alias
resolution and runtime-template rendering. Those changes were present in the
pre-array compiler17/15 baseline; they are not credited as new array findings.

## Qualification

Completed: checked B1 and exact focused frontend gate; 14 paired native cases;
8 admission/raw/effect-refusal controls; exact JS/frontend driver paths and
2,988 reachable generated functions. Genuine B2 generation and eight ordinary
driver observations pass; this is not a fresh full-source B2 self-check or B3
fixed-point claim. The broader native integration completes with 36/37 passes: the one failure is
`io/foreign_runtime_apply_tail.bend`, rejected with `FID(Clo~apply) names no
constructor or def`. It also fails with pre-array compiler17 in a fresh guarded
reproduction. This inherited foreign-ABI gap is not hidden or counted as a pass.
Char/F32 round trips pass, as do all12 raw API/error controls and six fixtures
at one/four CPU threads (including packed/shared atomics and redirection).
The raw comparison deliberately gives compiler17 and20 the same current generic
runtime, isolating raw emitter behavior. Installed Phase67 remains intact.

## Rejected experiment and failures

P68-018 reused the ownership certificate to diagnose omitting eager wrappers on
user constructors. Saved-C intervention passed all 18 observations but yielded
mixed results: tree647→597ms, lexer569→585ms, Map704→710ms (no applicable user
constructors). No production constructor-sealing change was selected.

The first diagnostic preparation stopped because Map had no user constructors;
no target ran. Compiler19 failed bootstrap on a captured linear binder, corrected
with the explicit duplicable binder in compiler20. An annotation inspection
initially used the raw positional API instead of the maintained ABI adapter;
that failed inspection was preserved and rerun through the actual driver.

Raw receipts are under `selfhost/build/phase68/`: scalar-build20,
scalar-build20-b2, scalar-controls20, scalar-admission20,
scalar-js-closure20, scalar-native-comparison20, user-seal-diagnostic01/02.
Durable [evidence](evidence/checked-scalars20.json) retains medians, every runtime
observation, compiler timings, image/report hashes and qualification outcomes.

## Complexity

Compiler17→20: 119→120 Bend modules, 29,703→29,794 physical lines,
24,330→24,403 nonblank/noncomment lines. Native modules total 3,310→3,401
physical lines. Thus the array feature adds91 physical/73 code lines net.
Host authentication and C-runtime helpers are separate from those Bend counts;
this is a performance improvement, not a source-size reduction. Shared runtime
array helpers remove repeated emission logic from ordinary/product paths.

## Compilation costs and next work

Twenty-seven fresh requests (three programs × three image roles × three balanced
rotations) all reproduce their complete qualified C oracles. B1 and B2 are JS
compiler images; they emit C, then Clang is a separate build step. Request clocks
include cache loading/checking/annotation/lowering/emission/reporting, exclude
host/API imports and Clang, and use explicitly prepared Base state. They are
neither runtime measurements nor the historical full JS compilation corpus.

| Program | B1 ms | B2 ms | Upstream TS ms | B2 / TS |
|---|---:|---:|---:|---:|
| Numeric |2629|1679|697|2.409×|
| Array |2655|1688|722|2.337×|
| Lexer |3270|2139|886|2.415×|

Geometric request ratios: **B1 3.7134×**, **B2 2.3868×**. No paired compiler17
latency campaign was run, so these numbers do not establish absence of a
compilation-speed regression. The runtime optimization has a measurable proof
cost; do not conflate that tradeoff with program speed.

Four separate profiles identify native bridge/product lowering, core-term/index
operations and allocation/GC as major costs. The B2 ownership scan has162–170ms
inclusive sampled time (overlapping child functions, not additive owner time).
It rescans an erased body for individual variable uses: an exact per-definition
use summary is a concrete follow-up. Broader lowering/product summaries and
avoiding repeated book queries are larger shared opportunities. The next runtime
work should target tree/lexer constructor layout and closure transport; the
rejected seal-only experiment shows that removing one allocation category is
insufficient. A more precise local array analysis could expand coverage but must
retain mixed-layout and sharing proofs.

The original profiler expected the old public `nc_compile` stage and failed after
saving a valid exact-C request/profile. Its failure remains in place. A narrowly
recorded derivative observes `nc_compile_checked`, retains all output/cache/input
checks and completes only the four diagnostic jobs. Clean timings were not rerun.
The initial Char/F32 fixtures also failed in both compilers on invalid source
syntax; their source copies and receipts are retained. Corrected fixtures use
parameter destructuring and `F32.neg`, and both pass their independent goldens.

## Delivery and resource accounting

Implementation checkpoint: `9745ab6`, pushed to `selfhost/bootstrap`. The final
report commit follows. Checked B1 is `add9aa3f…`, genuine B2 `48131284…`, assembled
Bend source `3c648301…`; full hashes are in the evidence file. B2 emission and
sampled driver equivalence are proven; fresh full-source self-check/B3 reproduction
and release-interface promotion were deliberately not claimed. Use the checked
candidate through its explicit API path or rebuild from these sources. The
installed Phase67 release and pinned upstream remain unchanged. No PR comment.

One root-owned heavy target tree ran at a time, with2GiB RSS and4GiB available
memory guards. B2 generation/driver checks took107.7s of guarded wall time, peaking
at1.09GiB; candidate20 bootstrap peaked at1.50GiB. No OOM or disk exhaustion.
One fresh-context Astra Ultra advisor reviewed the checked boundary and ownership
invariant; implementation and tests remained with the leader.

The local usage snapshot covers30.5minutes after initial investigation/design and
before final report/commit:57,812 output tokens, of which6,649 were the advisor;
12,752,640 of12,998,864 input tokens were reported cached. Observed account usage
rose8percentage points in the reported window. These are advisory local telemetry,
not billing or exact per-task quota; the interval does not cover the whole turn.
The main efficiency choice was validating on narrow saved-binary screens and
running broad/B2 checks only after selection. Reusing completed clean measurements
also avoided another27-request run after the profiling instrumentation failure.
