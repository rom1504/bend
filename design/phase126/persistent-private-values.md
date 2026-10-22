# Phase126: persistent private values

Started 2026-10-22 22:59 UTC from `3c94d98`; authorized three-hour campaign,
ending around 2026-10-23 01:59 UTC. Compiler implementations remain checked Bend.

## Objective and baseline

Improve direct-QBE generated-program speed toward broad upstream parity, without
changing the frozen45 sources, outputs, repetition weights or reference products.
Phase125 is the qualified native checkpoint:44 timed points have geometric
slowdown1.89221,40 exceed1.1 and24 exceed2. Positive log-slowdown is0.89500.
Ray contributes26.6% of positive excess batch time. These are program runtimes,
not compiler-request times. Preserve the installed selection and independent
verifier. Unrelated dirty files and all frozen evidence remain untouched.

## Falsifiable primary hypothesis

Keeping F32 representation across private calls and loop backedges removes enough
integer/float transport and scratch work to improve complete numeric computations
materially. Compare original, typed boundary only and persistent typed region.
Use original intersection/nearest and an unrelated numeric recurrence, with exact
outputs and ordinary boundary controls. Inspect real machine conversions and
spills. Smaller text or static eligibility alone is insufficient evidence.

Initial decision budget45–90min. A roughly25% runtime reduction plus unrelated
transfer justifies expanding a bounded automatic implementation. Neutrality,
unresolved float semantics, or increased hot spills stops expansion. Preserve
rounding, signed zero, NaNs, exact bit observations and source evaluation order;
do not equate native F32 values with arbitrary U32 terms. Unknown boundaries use
the existing correct representation. No arithmetic reassociation or fast-math.

## Ambition ladder

1. **1x scope:** a checked typed-private-call/backedge experiment, then a small
   general admitted subset if profitable. Private producer destination propagation
   is the lower-cost alternative if typed regions fail the early test.
2. **10x scope:** extend existing plans with shared representation/ownership facts
   so typed scalars, virtual fields and local resumptions compose. Implement only
   the common interface demanded by successful transformations. Require two
   interacting capabilities and unrelated workload transfer before broadening.
3. **100x scope:** symbolically preserve complete closed computations and emit only
   observable results/effects; temporary products, lists and continuation state
   materialize on escape/sharing. First prove one small cross-layer advantage;
   no universal IR rewrite, extra backend or autonomous search framework.

These labels describe research scope, not speed promises. Even2x speed on all
three ray cases moves the44-point geometric ratio only to about1.80. Broad parity
requires improvements across many slow families. Local forecasts are not corpus
forecasts and cannot be multiplied across overlapping transformations.

## Execution and resource discipline

Root owns implementation/integration and one guarded CPU3 measurement lane.
Bounded agents inspect machine/lowering facts, semantic alternatives and reusable
fast-loop tooling without competing target campaigns. Reuse authenticated checked
source/API/runtime products and original independent output/graph verification.
Ordinary jobs use2048MiB tree RSS,16384MiB available floor and bounded files/deadline.
No broad image build until disk headroom and actual benefit justify it. Exact
duplicate hardlinking may reclaim space only after byte verification and receipts.

Approximate schedule: first60min decisive experiment; next75min selected general
implementation or a documented pivot; final45min transfer/cost/broad validation,
report and commits. Adapt to measured cost. While guarded jobs run, inspect code,
review proofs and write evidence; do not idle on long polling. Native qualification
is an integration decision, not a per-prototype requirement; Phase125 stays qualified
if a new candidate has only hosted qualification. No PR comments.

## Evidence and acceptance

Each hypothesis/attempt retains exact sources, input/runtime/API identity, command,
guard result, failed attempts and complete independent outputs. Separate runtime
timings from diagnostic counters. Report historical geometric mean, positive log
deficit, family-weighted ratio, threshold counts, total/excess batch time and worst
regressions. Measure whole prepared compiler cost for the selected candidate;
record source growth and total research wall/guarded-target time separately.
No recursive acceleration claim follows from a faster emitted program alone.

Commit design, bounded useful implementations and honest reports during work.

## Evidence-driven extension at 23:32 UTC

The first typed experiment improves the active numeric workload but ordinary
ray tracing remains dominated by a different work mix. In parallel, source and
machine inspection found that upstream preserves constant-returning scalar
selectors as tables, while QBE retains branches and closed arithmetic. The bounded
P126-002 experiment tests that lost whole-computation fact separately, then tests
composition only if it pays. It does not expand the campaign into a universal IR.
