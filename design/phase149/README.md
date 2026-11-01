# Phase149 — Bend optimization policies and measured development builds

Start at `5ace44e`; Phase147 remains the qualified ordinary native compiler.
The user authorizes this experiment and asks that new logic be written in Bend,
with easy host-tool retirement where supported. The goal is causal information
and a useful compilation/runtime tradeoff before another large representation
change. Defaults and the installed compiler remain unchanged until justified.

## Implementation

One additive Bend policy entry carries a validated code through the existing
pipeline. Code bits0/1 disable inlining/optional helper preparation; bits2..3
select regions0=current,1=complete-direct then H/generic,2=complete-direct then
generic/fused. Codes0..11 are valid. Code0 must reproduce existing emission.
Suggested diagnostics0,1,2,4,8,3,11 isolate work and interactions; do not call11
the fastest development policy before measuring it.

Preserve source checking, runtime admission, original/direct verification,
ownership/array certificates, namespace checks, recursion/stack safety and all
mandatory lowering. Skip complete optional work before preparing candidates.
The existing range boundary is identity and is not a new optimization switch.
Return an unchanged checked boundary when skipping inlining. Skip optional
helper preparation only after final verification, returning its already admitted
program. Region switches preserve complete direct workers and verified fallback.

Use the existing cursor/context unchanged; carry region policy outside it.
Default collection and streaming delegate the current implementation. A new
Bend CLI parses explicit policy codes, reads bounded inputs, drives compilation,
streams QBE, and optionally records coarse monotonic timing to a separate file.
Non-policy requests retain the existing CLI behavior. No host code implements
policy selection, compiler transformations or output rendering.

Use maintained source assembly, independent source acquisition, native builder,
benchmark runner, profiler and disk guards. These external process/measurement
tools are reused, not duplicated. Replace an existing host policy/test operation
only when a Bend implementation preserves its actual contract; deleting pinned
historical methods or rewriting process supervision is outside this experiment.

## Gates and efficient sequence

1. Small checked Bend controls: valid/invalid codes, exact code0 output, direct
   worker/fallback handling, unchanged refusal behavior and cursor boundaries.
2. Acquire one independently checked native experiment compiler with the
   qualified Phase147 parent. All policies execute this same binary.
3. Use small complete requests covering compiler code, Map/ownership and numeric
   or recursive work. Collect exact policy outputs before clean alternating
   timing. Changed output is expected for ablations, so compare independent
   program outputs rather than requiring false byte equality across policies.
4. Build selected emitted programs with unchanged QBE/runtime/toolchain and
   measure representative fixed-work native wrappers. Preserve refusals and
   runtime regressions. Avoid all45/full bootstrap until a useful policy exists.
5. If small evidence supports it, measure a bounded full-source request or cold
   build against code0. Track compiler execution, QBE construction and program
   execution separately. A faster build that makes the generated compiler slow
   may lose on total edit/build/test cost.

One root-controlled CPU3 target lane, fresh run roots, explicit disk/time/RSS
budgets,5GiB reserve,16GiB available floor; no nested guards or large parallel
builds. Bounded agents can own separate Bend modules/reviews. Preserve failed
attempts; close/archive/verify all cold outputs before any optional pruning.

## Interpretation and ambition

The1× outcome is a cost/benefit table of real optional groups, not a promised
speedup. Differences include downstream work and code-layout changes; they are
not additive pass clocks. A development profile keeps cheap high-value passes
and omits expensive low-value ones, based on complete-loop evidence.

The10× extension is targeted profitability and preparation shared across
composable groups, eliminating work shown unnecessary by ablations. First prove
one useful default or development profile; do not build a new policy framework.

The100× extension is cheap verified owner units and adaptive optimization effort
that can amortize across future experiments. It remains conditional, and warm
reuse/parallel throughput are not cold serial gains. Do not add caching/search
machinery just to satisfy ambition labels.

Commit design and meaningful implementation/evidence milestones. Report measured
request/build/runtime effects, correctness scope, complexity, cost and rejected
policies honestly. No new bootstrap theorem, whole-corpus score or installed
promotion follows from small policy controls.

## Executed clarification and outcome

Bit0 gates the existing inline **and scalar-cleanup group**, not call expansion
alone. Bit1 removes late optional helper preparation; initial direct/SCC/array
admission and shared region context still execute. The implementation adds no
new unchecked admission path. These boundaries limit causal attribution.

The [report](../../implementation/phase149/README.md) records a20.74% smaller
staged full-build clock but1.831× slower execution by the resulting compiler.
Keep the experimental switches; reject default promotion. RLE also rejects the
small-screen interpretation that reduced region search is universally free.
