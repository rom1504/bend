# Current compiler experiment strategy

Current campaign: 2026-09-23 05:06:12–15:06:12 UTC, at most ten hours.
Baseline `a6459af`; [design](../design/phase6/ten_hour_campaign.md),
[live report](../implementation/phase6/campaign-report.md).

The previous Phase 5 release remains the default. Its controlled full-source
ratio is 6.03× TS, with 318 strict check failures, 444 exact frontend differences,
16 phase differences and 16,509 production Bend lines. Prior Phase 6 candidates
remain unpromoted. The new user request authorizes all eight proposed improvement
directions, bounded by the new window; this supersedes the prior closed campaign.

| Priority | Work | First decisive check | Owner/resource |
| --- | --- | --- | --- |
| 1 | Prefix/erased-name semantics | Prefix-call precedence, noncapture, `+U32`, valid neighbors and exact first error | Semantics / CPU1 |
| 1 | Source provenance and parser diagnostics | 150 same-message/missing-excerpt cases, small exact cluster, no per-application reparsing | Diagnostics / CPU2 |
| 1 | Native scalar continuation removal | Checked size ladder, mixed fields/ownership/order and actual native outputs | Native / CPU3 |
| 2 | Obsolete code and missing-import boundary | Root/export audit; narrowly classified import failures | Root / CPU0 |
| 2 | Typed results and single authoritative error path | Dependency/duplication measurement, one bounded handoff, exact graphs/errors | Root + reviewers |
| 3 | Boolean candidate | Resolve H positional/partial-function gate, then matched timing and broader controls | Next available slot |

Agents use isolated source projects and immutable checked attempts. Root owns
production integration, default distribution, Git and timing resources. No human
upstream edits. No broad/full-source job without root scheduling; finite limits
for every process. Correctness runs may overlap on separate cores; controlled
comparisons require all intentional competing compiler/archive/hash jobs paused.

First review 06:15–06:30 UTC. Target final source freeze 12:15 UTC, reserving the
last roughly three hours for controlled measurements, checked self-reproduction,
full artifact frontend/affected backend gates, release installation and evidence.
Stop at 15:06:12 UTC. Unfinished gates remain unfinished; time does not convert a
failed experiment into a promotion. Preserve raw failures and source identities.

Keep exact diagnostics, phase agreement, strict fixture oracles, compile speed,
Clang time, runtime speed and generated/source size separate. Estimates are not
measured gains and are not additive. A semantic repair outside the pinned corpus
matters even if it changes no existing count. No new representation or generic
memoization rewrite without a concrete measured opportunity and validity contract.
