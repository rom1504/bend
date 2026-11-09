# Phase185 — faster QBE and assembly generated programs

Start: 2026-11-09 06:07:54 UTC, parent `1d8b56e`, branch
`selfhost/bootstrap`. Three-hour campaign, approximately until09:08 UTC.
User authorizes implementation, profiling and optimization of both native
backends, targeting our C backend's generated-program speed or better.

## Decisions to resolve

Phase184's identical Bend programs execute faster through our C backend on
35/44 timed points. QBE/C is about3.5× on map churn and3.4× on tree sorting,
but only1.14× on raytrace. The handwritten C comparison is a second reference,
with different representation/ownership choices; it is not an isolated codegen
ceiling. Assembly's earlier three-kernel screen is25–50× slower than QBE and
misses established late tag, borrowing and constructor expansions. That is not
an assembly full45 score.

Measure whether the gaps are excess semantic work (allocations, ownership,
continuations, intermediate structures) or cost per operation (calls, tagging,
spills, instruction selection). Preserve dynamic evidence and actual machine
code; static counts alone do not attribute time. Instrumented runs diagnose;
clean uninstrumented runs measure gains.

## Work and time allocation

- First20min: source/machine audit and existing profiler reuse. Acquire only
  missing small products. Freeze parent products and independent output oracles.
- Next60min: parallel bounded implementation of assembly lowering reuse and a
  measured QBE hypothesis. One root-owned CPU3 execution lane. Read-only agent
  audits proceed while target jobs execute. Avoid full compiler rebuilds before
  small checked-emitter experiments show a useful effect.
- Next55min: reject weak candidates quickly; integrate the best mechanisms and
  require transfer to unrelated workloads. Compare against the unchanged parent
  and actual C products, preserving original inputs and full output checks.
- Final45min: broader runtime/semantic gates, justified native acquisition and
  reproduction where feasible, evidence/report, commits and push. Qualification
  is a separate decision from a successful experiment. Installed qualified
  images remain available; promotion requires the maintained independent gates.

Small decisive experiments take priority over consuming every planned minute on
an unsuccessful hypothesis. Continue useful work for the requested session;
measure failed attempts and avoid repeated broad campaigns after unchanged code.

## Ambition and admission

The first path restores a missing class of efficient lowering in assembly and
removes a measured repeated QBE cost. Prefer shared typed native operations over
reimplementing optimizations as unrelated assembly text recognizers.

The larger path composes existing capabilities across helper/continuation and
ownership boundaries: direct private calls, virtual product values or borrowed
loads survive complete hot computations. Pursue this if machine profiles expose
one clear boundary with a plausible large benefit and an inexpensive legality
control. This is a bounded architectural improvement, not a universal-IR rewrite.

The most ambitious path removes a whole category of runtime work in both targets
through one shared semantic plan. Prototype only if a source/machine ceiling and
transfer evidence justify it. Parity,2×,10× and larger gains are goals, not
promised outcomes. Reject a change that merely moves cost to compilation or
materializes equivalent discarded representations.

Preserve independent final verification, effects/evaluation order, ownership,
sharing, fallback behavior, numeric semantics, runtimeABI11102 and bounded native
stack use. Do not edit upstream `bend2/bend.ts`. Source checking, finite controls,
BendTT proofs and bootstrap agreement remain separate guarantees.

## Metrics and fast loop

Use installed Phase183 and Phase184 products as explicit baselines. Primary
outcomes are runtime ratios to our C target, per-case regressions and transfer
across families. Retain equal-case/source/family geometric means, positive log
slowdown and counts above1.1×/2× when full cohorts are admitted. No averaging away
missing/short/failed cases. Small experiments remain explicitly scoped subsets.

Adaptive per-role batches target250ms, minimum100ms, three rotated rounds. Match
catalog inputs, initial values and every success count. Assembly diagnostic runs
may need much smaller repetition counts than the historical fixed-batch screen.
Existing benchmark timing and profiling tools are reused. Record compiler-request
cost and source complexity separately; ordinary program speed is not compiler
self-build speed or research acceleration.

Profile initially map churn, tree sorting and a contrasting numeric/rendering
case. Reuse source-aware Bend attribution and native leaf/caller inspection;
require sufficient samples before quantitative hotspot claims. Runtime event
counts need exact ABI/output controls and stay out of timing products.

## Resources, evidence and delivery

Use fresh paths, default2GiB RSS and16GiB available-memory floor, one CPU3 lane,
explicit artifact budgets and5GiB disk reserve. Storage recovery must use exact
immutable duplication or independently verified retention evidence, never age
or unexplained deletion. Do not overwrite historical hardlinked files.

One coordinating agent owns execution and integration. Bounded agents own x86
implementation, QBE machine audit, profiler/tool transport and read-only storage
audit. No competing whole-compiler campaigns.

Keep one file per hypothesis with prediction, candidate, measurement and decision.
Commit design first, then validated changes and an honest report under
`implementation/phase185`. Preserve failures, raw profile identities, machine
products, oracles and reproducible commands. No PR comments.
