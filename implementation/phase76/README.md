# Phase76: native compilation work reduction

Installed compiler12 reduces measured C-request time by **6.28% for B1** and
**1.84% for B2**, with exact previous generated programs. This phase has **not
reached compilation parity**. The much faster scalar-pattern prototype is
preserved separately because it regresses two generated programs.

[Design](../../design/phase76/native-work-reuse.md) ·
[Methods and commands](../../selfhost/tools/performance/phase76/README.md) ·
[Experiments](../../experiments/phase76/)

## Measured selected candidate

The final paired comparison contains 45 fresh requests: three programs, three
rotated/reversed rounds, old/new B1/B2 and pinned TypeScript. All outputs match
their complete C oracles.

| Compiler image | Previous / upstream | Selected / upstream | Less request time |
|---|---:|---:|---:|
| B1 | 2.93623x | **2.75191x** | **6.28%** |
| B2 | 1.94374x | **1.90803x** | **1.84%** |

The B2 improvement is small relative to the precision of a three-round screen;
it should not be described as a major or universal gain. Parity remains unachieved.
The larger prototype's 32%/22% savings below are rejected-release results.

| Program | TS (ms) | Old B1 | Selected B1 | Old B2 | Selected B2 |
|---|---:|---:|---:|---:|---:|
| Numeric | 693.6 | 2063.5 | 1941.2 | 1367.7 | 1351.9 |
| Array | 705.6 | 2057.5 | 1948.9 | 1356.0 | 1340.5 |
| Lexer | 885.4 | 2583.1 | 2386.7 | 1715.5 | 1660.7 |

These are medians; ratios above are geometric means across programs.
[Selected samples and identities](measurements.json) and
[rejected prototype samples](prototype-measurements.json) retain every interval.
The production manifest remains 131 modules: 32,018 physical / 26,162 nonblank,
noncomment Bend lines, a change of **+34 / +22**. The experimental pattern module
is excluded from these counts and from the active compiler manifest.

## What changed

The selected compiler changes four Bend modules. Native-definition and native-call
classification now reject ordinary definitions, non-calls and ineligible heads
before constructing intrinsic metadata. Scalar and allocating calls share one
provenance/arity gate. Representation certificates use explicit lazy branches:
a native definition does not require scanning its fallback implementation, and
a false whole-program certificate does not require visiting the remaining book.
Admission rules, foreign policy and emitted runtime macros are unchanged.

This matters because the previous Boolean expressions evaluated their arguments
eagerly. A logically redundant classifier or recursive scan still consumed time.
These changes remove that work without changing the lowering algorithm or adding
a backend cache. All compiler algorithms remain written in Bend. No production
runtime, JavaScript backend or pinned upstream source was modified.

## Larger experiment: compact scalar patterns

Per-definition profiling revealed unexpected work amplification. One ordinary
character pattern in `Nat.read.trim` expands to 1,421 erased nodes: 624 constructors,
496 native words, 98 lambdas, 98 variables, 68 matches and 35 empty eliminations.
The expansion repeatedly reconstructs defaults. Upstream's `mat_lits` already
collects scalar decision rows, which suggested a general structural Bend rule.
No rule identifies this source function or any benchmark name. The benchmark
wrappers share argument-reading library code, however, so the large measured
saving must not be generalized to arbitrary applications without broader
source-level compilation measurements.

The prototype collects known low-bit prefixes, proves inherited defaults equivalent
under binder identity, and falls back on unsupported shapes. A later version
retains the small pattern tree for analyses and both lowering routes. Another
version removes exact U32/F32 reconstruction round trips when no residual Word
escapes. These are compile-time algorithm changes within the request clock.

Candidate08's completed paired45 comparison measures **B1 2.93853x → 1.99078x**
and **B2 1.95077x → 1.51774x** upstream: **32.25% / 22.20% less request time**.
The three C files shrink by 52–66%. These promising numbers do not describe the
selected release.

The complete twelve-family, six-round execution comparison has these medians:

| Family | Previous program (ms) | Prototype (ms) |
|---|---:|---:|
| Numeric | 251 | 251 |
| Array | 185 | 187 |
| Closures | 173.5 | 174.5 |
| Tree | 287 | 297.5 |
| Map | 255.5 | 254.5 |
| Lexer | 297.5 | 291.5 |
| List pipeline | 327.5 | 324.5 |
| BST | 432 | 438.5 |
| Expression | 474.5 | 471.5 |
| Array.map | 456 | 478.5 |
| Tape observer | 266.5 | 267 |
| String order | 238.5 | 240.5 |

All 216 executions produce correct digests. Tree is 3.66% slower and Array.map
4.93% slower; both recur in focused probes. The prototype therefore fails the
user's no-generated-program-regression constraint. It is not promoted.

## Failed hypotheses and limitations

An initial alpha-equivalence implementation conflated a free variable and a bound
variable with the same numeric ID. An independent capture counterexample exposed
it; candidate05 is rejected. Corrected controls cover all 0–32 prefix depths,
inherited and distinct defaults, reconstruction and private-node rejection.
Candidate08 passes 12,073 comparisons; candidate10 passes 20,521. These are
finite differential controls, not a formal proof of the optimization.

Removing scalar reconstruction eliminates word-building loops but does not recover
the runtime regressions. Saved-C 32/64/128-byte function alignment, patchable entry
and hot-section probes also fail to recover both affected families. No such hint
or runtime flag is adopted. Some last-probe samples drift considerably; they are
retained, not used as precise speed estimates. Initial numeric slowdown disappeared
in the larger balanced run, so it is not treated as a persistent regression.

Selected hot machine-code sequences agree after address normalization, apart from
error-message references. Native layout is a plausible contributor, not a proven
cause. Hardware counters were unavailable: the installed perf wrapper lacks its
kernel-specific binary, and the account has restrictive perf permissions. The
host compiler already removes `DEVICE && ...` error guards; deleting these guards
would not be a CPU speed optimization.

The first paired preparation reused a populated historical cache and failed its
empty-cache assertion before any target request. The corrected v2 method gives
each role a fresh project. An independent audit finds all 114 archived Phase75
project/cache files unchanged. Candidate11 is a failed rollback preparation caused
by an incorrect manifest path; candidate12 fixes that path. A later B2 C-identity
preparer was missing its derivation sidecar and failed before target execution.
The sidecar is now recorded and the retry uses a fresh output directory; native
gates are not repeated. All failures remain.

## Validation and scope

The [completed qualification](qualification.json) verifies:

- Frontend36; native100 (candidate100, reference93 with the same seven failures);
  additional native14; raw31; 28 executions at one/four threads.
- Twelve independently executed acquisitions with **exact previous C and executable
  bytes**, and twelve genuine B2 requests reproducing that same C.
- Genuine B2/driver8, fresh B2 own-source type acceptance with expected unsafe
  proof-trust refusal, and exact B2/B3 byte equality. This is not a mathematical
  correctness proof.
- Unchanged non-native generated dependency closure (2,992 functions), 166 report
  controls, 1,066 constructor comparisons and 199,400 occurrence-set controls.
- Installed release verification before/after, legacy42, default24 and helper5.
  All seven previous release files are preserved byte-for-byte.

Installed checked B1: `98134f59f1d1683b2ae66e8e00df8f5ea308742a68d19353bded7063c82c865f`. Genuine B2/B3: `29da003b469e431ec418525de790c60d929d08e3ea71daa95415d7848de6eebc`.
The default remains the checked B1 image; B2 results are separately qualified.
No release change silently substitutes stages in the performance metric.

B1 is the upstream-bootstrapped checked compiler image. B2 is its genuine
self-emitted JavaScript compiler image. Both compile Bend programs to C; neither
ratio measures a compiler executable built by Clang. The three-source fresh
request metric excludes imports, explicit Bend Base preparation, Clang and
program execution. The pinned TypeScript compiler checks Base within its request.
Backend products are disabled. Cache-assisted service latency is a different metric.

Twelve-family execution covers varied data structures and allocation patterns,
but is not universal performance or full device conformance. Seven known reference
native test failures and thirteen broader native API gaps remain explicit. No
unmeasured conformance improvement is claimed. Historical benchmarks stay pinned
to upstream 059266225b77c8ca256ac6b25ee5c21449bab151.

## What to try next

The most useful next architectural experiment is a retained native lowering
product with per-node facts and relocatable temporary IDs, consumed by both
scheduler and worker emission. First require exact existing C output on a small
set; then measure whether avoiding repeated walks buys enough to justify the
extra representation. A root-identity cache remains weak because earlier data
found 97% distinct roots. Reusable Base products could remove more work, but need
explicit dependency, static-image and ID relocation contracts and separate cold
and warm numbers. Neither proposal has a demonstrated parity result.

Scalar-pattern compaction is now a concrete, reconstructible alternative with
large measured compilation savings. Revisit it with hardware-counter access and
a cross-family runtime acceptance test, not more speculative alignment changes.
The [prototype patch](../../experiments/phase76/prototypes/candidate10.patch)
reconstructs all eight changed source files exactly from the Phase75 baseline;
its verification is retained beside it.

## Efficiency and evidence

No agents or PR comments were used. Each heavy target runs serially on CPU3 with
2 GiB process-tree RSS, 4 GiB available-memory floor and Node 1 GiB heap/4 MiB
stack. Fast checked builds take about 33 seconds. Focused controls and saved-C
probes precede broad gates. The selected exact executable identities avoid an
unnecessary second twelve-family timing campaign. Failed builds and abandoned
plans are retained and are not counted as passing tests.

Several layout probes had weak discriminatory value after the first repeated
regression. A future cycle should cap those probes earlier and require actual
hardware evidence before expanding that line of work. This phase does not
justify promising a 3x gain from local classifier changes.

[Retained guard accounting](time-accounting.json) records 35.9 minutes
of guarded wall intervals over a 86.1-minute first-to-last guard span. Overlapping
parent/child intervals are counted once. Peak recorded tree RSS is
1.60 GiB. This excludes unguarded work and is neither CPU time nor
a measurement of active agent time or quota.

The content-addressed [evidence capsule](../../selfhost/tools/performance/phase76/evidence01/verification.json)
is sealed after all target writers close; it includes candidate source snapshots,
generated artifacts, recipes, raw samples and failed attempts. The capsule contains 15,007 files / 4,086 unique objects in 65,489,422 compressed bytes.
A [full restoration](restoration.json) independently rechecked every byte hash
and file mode; only that temporary restore was removed. Historical phases,
upstream and toolchains are external pinned dependencies. Account quota telemetry is not task billing.
