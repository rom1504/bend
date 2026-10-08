# Phase67: faster native code, short iteration loop, and proof pilot

The selected compiler is installed and verified. Six native diagnostic families
run **1.50× faster** (33.3% less execution time), produce **20.0% less C**, and
need **18.4% less Clang build time**. Every family improves. The production
change adds **46 Bend lines in two existing modules**, with no host/runtime
algorithm changes. [Design](../../design/phase67/native-speed-and-proof.md).

## Results and remaining gaps

| Native family | Execution-time reduction | Remaining ratio to upstream C |
| --- | ---: | ---: |
| Numeric recurrence | 55.8% | 7.20× |
| Mutable arrays | 34.8% | 84.99× |
| Closures | 21.1% | 2.46× |
| Recursive trees, held out | 21.2% | 9.78× |
| Map operations, held out | 28.3% | 5.90× |
| Lexer, held out | 31.5% | 14.71× |

These are six equally weighted diagnostic families, not a universal workload
mix. The geometric mean gap decreases from 15.61× to 10.41× against the same
upstream timing anchors. Baseline/candidate campaigns are sequential; refreshed
upstream samples expose 0–6% drift. The large gains are supported across all six
families; small incremental percentages should not be treated as precise causal
estimates. C build numbers are single acquisitions. Runtime uses two qualified
rounds with identical inputs and independent digest oracles, excluding emission
and C compilation. [Full ablations and evidence](native-ablations.md).

The main finding is avoidable value transport: even an already evaluated word
used to allocate a continuation. Binding atoms directly retains ownership and
liveness operations. Exactly saturated genuine Base scalar primitives now use
their existing C expressions, evaluating arguments in order. Partial calls,
overrides, foreign definitions, bang calls and allocating operations retain
fallback. The scalar step's clearest additional benefit is numeric work.
General boxed constructors, closure traffic and aggregate transport remain the
large native opportunities. This phase does not reach native parity.

## Faster iteration

The six-family Bend-only loop checks twelve observations in **7.00 seconds of
recorded campaign wall time**, plus initial setup/hashing; actual native children
take 2.83 seconds. Every measured interval is at least 182 ms. It reuses checked
executables. New source candidates still require a checked compiler build
(about 30 seconds here) and C acquisition; those costs are not hidden in the
7-second claim. Slow TypeScript-resolved timing is reserved for periodic
qualification, rather than every edit. [Commands](../../selfhost/tools/performance/phase67/benchmark/README.md)
and [loop receipt](evidence/native-fast06-validation01.json).

## Five existing metrics

| Axis | Selected result | Scope |
| --- | --- | --- |
| JavaScript program speed | All 45 point modules remain byte-identical | Retains Phase66's finite 669-sample runtime evidence; no fresh speedup claimed |
| B1 compilation | 0.95930× previous B1 in the short screen | Numeric/Map, two rounds; regression protection, not a causal optimization claim |
| B2 compilation | 0.99882× previous B2 | Same short screen; no material change |
| Conformance | Strict36, native controls, B2 self-check and reproduction pass | Full frontend/JS evidence reused through exact unchanged executable closure; native gaps remain |
| Simplicity | 28,536 physical / 23,388 code Bend lines; 115 modules | +46 physical / +35 code lines and six definitions; no new module or runtime representation |

The last full compilation campaign remains Phase66's **1.402× B1 / 1.321× B2**
versus TypeScript, or **0.983× / 0.990×** including imports/API loading. The short
screen does not update those headline ratios. JavaScript runtime retains the
prior **1.049× equal-point / 1.047× equal-source** observation for identical
outputs. The bounded compilation-side investigation found no small change with
credible sufficient benefit and was [deferred](compilation-side-review.md).
[Compilation and self-hosting report](compilation-and-selfhosting.md).

## Correctness, proof and release

Source review caught and fixed diagnostic precedence and device-path error
polling before execution. Fresh checks cover ten raw-core rows, eight paired
native fixtures, and four fixtures run with one and four threads. A simulated
shared-error observation is explicitly diagnostic-only, not GPU validation.
All six benchmark families pass independent output checks. All 1,403 frontend
and 3,066 non-native executable functions remain identical. This permits scoped
reuse of Phase66's 3,174 frontend observations and 1,045 golden JS passes, with
123 exemptions, one shared process failure and one graphics deferral unchanged.
Thirteen unsupported native APIs remain unsupported.

The actual B2 checks its source and reproduces B3 byte-for-byte; fresh B1/B2
compilation agrees on all 23 sources and 45 points. Selected checked B1 is
`c76f1113…`, genuine B2 `cbffd1f8…`, assembled source `e4a4105e…`, with unchanged
upstream `059266225b77c8ca256ac6b25ee5c21449bab151`.
[Qualification](evidence/final-qualification01.json) and
[installed release](evidence/installed-release01.json) pass, including legacy42,
default24, helper5 and integrity before/after. All seven prior release files
and 110 inherited unrelated files are preserved.

The [71-line Bend proof pilot](proof.md) states immediate-word transport and its
finite composition without unsafe assumptions or imports. Both Bend checkers
accept it and safe elaboration retains all 13 definitions. Independent kernel
checking is **blocked**: available Lean 4.32 cannot compile the unmodified kernel
requiring 4.34. No independent proof is claimed. The model also excludes actual
emitter correspondence, ownership, C and scheduling.

## Time, failures and reproducibility

Release-target work ran from 09:01:10 to 09:52:02 UTC on October 8, 2026:
**50 min 52 s elapsed**, with **18 min 6 s of guarded target occupancy**.
Peak sampled target-tree RSS was **1.41 GiB**, below the 2 GiB guard; no OOM or
resource-limit termination occurred. Other elapsed time is unclassified
source/data/review/orchestration; subsequent documentation, archive and push
are separate. [Time account](evidence/time-account01.json).

Retained failures include two incompatible proof launchers, the Lean mismatch,
a raw-control fixture missing List constructors, and the old installed-release
verifier correctly refusing changed live source. The latter comparison resumed
using a byte-identical frozen baseline image with explicit provenance. Rejected
source proposals and unexecuted duplicate plans remain distinguishable from
results. No PR comment was posted.

Raw writers are closed. The [verified archive](../../selfhost/tools/performance/phase67/artifacts/README.md)
preserves this phase's raw results; earlier phases and external pinned tools
remain explicit prerequisites. For ordinary use and future experiments, read
the [native lowering guide](../../docs/self_hosted/native-value-lowering.md)
and [compiler guide](../../docs/BEND-IN-BEND.md).
