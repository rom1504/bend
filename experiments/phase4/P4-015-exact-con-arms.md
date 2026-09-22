# P4-015 — Inline exact private list-matcher arms

- Owner: lexer-analysis; independent reviewer: pending.
- Started: 2026-09-22, after final combined proof; bounded initial prototype about25 minutes.
- Objective: reduce compiler dispatch/allocation without changing public emitted code.
- Correctness at completion: 69 selected checks and 8 pilot observations pass; private data-only image only.
- Measurement at completion: two-round opposite-order pilot, reported below.
- Decision at completion: reject for insufficient repeatable benefit.
- Design: [next structural experiment](../../design/phase4/next_structural_experiment.md).
- Predecessor: [Phase1 matcher fusion](../../implementation/phase1/rapid_performance_experiments.md#matcher-allocation-and-fallback-chains), deferred7.3% tree result; ordinary uncurrying P4-011 has zero sites.

## Claim and cheapest disproof

Inline only literal Con/arity2 arm bodies inside their existing private matcher worker. Remove the selected arm closure, function record/empty bound array and bounce/apply transition. Existing field arrays already borrowed: no array-copy saving is claimed.

First count actual eligible arm executions separately from timings. Preserve project behavior, exact argument scope, lexical captures, lazy returned builds/tail bounces and fallback on unexpected field counts. Reject any supported-domain differential mismatch. Reject the bounded timing pilot if real-core improvement is absent/below roughly3% with opposite-order disagreement; do not rescue it with list-only results. About5% repeatable real-core gain justifies a broader comparison.

## Setup and gates

Use final proven H b33b38e3… and current unchanged canonical private control75eb…; runtime26f… and same frozen host/Base. CPU3, fresh processes, validated separate Base caches, 4MiB stack/3GiB heap, serial opposite-order list/core pilot, exact diagnostics/bytes and peak RSS. No canonical/source changes. Root's full private compile uses CPU2; other cores remain active.

Boundary gates precede timings: captured values/nested argument scopes, partial/overapplication, malformed field counts, projection/body errors, selected/unselected effects, returned build/force order, higher-order results and100,000 tail steps. Complete source and broad frontend gates are required before any promotion.

## Observations and decision

The initial proposal above preceded the runs; completed results follow. No promotion.

## Completed result — 2026-09-22 approximately 17:26 UTC

- Correctness: 69 focused differential assertions pass; 8/8 selected compilation results/bytes agree; both emitted list programs print6. Independent review is linked in the detailed report.
- Measurement: complete two-round opposite-order CPU3 pilot; original recorded inputs unchanged. List reductions0.73%/3.00%; real compiler-core reductions3.49%/0.061%; all process/RSS samples retained.
- Decision: **reject this narrow transform for insufficient repeatable benefit**, following the predeclared stop criterion. No three-round/full-source escalation or promotion.
- Limitation: unchanged canonical75eb private control separately failed full-source compilation (`F is not defined`). This selected-workload pilot does not validate that path; original consumed tools were frozen before the independent repair.
- Preservation: [detailed report](../../implementation/phase4/private-con-arms.md), [49-entry archive](../../implementation/phase4/private-con-arms-evidence/manifest.json), exact original failure/test and source/config snapshots. Large generated APIs omitted with regeneration prerequisites documented.
- Reopen only for a materially different proven mechanism/opportunity, not another run of these same sites. Root updates ledger/STEERING separately.
