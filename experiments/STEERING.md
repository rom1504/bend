# Current compiler experiment strategy

Evidence cutoff: 2026-09-22 21:39 UTC, baseline `7d69850`.
Authorized Phase 5 window: 2026-09-22 21:39:36 to 2026-09-23 03:39:36 UTC.
Next review: first frontend witnesses and workflow/equality falsifiers, about 22:15 UTC.

## User objective

Prioritize conformance, simplify code where it helps future changes, and retain
or improve the fast development loop. Work for six hours, document the design
and results, and commit/push validated increments. See the
[Phase 5 design](../design/phase5/conformance_and_development.md).

## Established position

- Current source:59 Bend modules,16,055 physical lines; generated files excluded.
- All 919 positive frontend fixtures pass;377 strict negative-check failures remain.
- Live TypeScript comparison:560 differences across375 fixtures, including 50
  acceptance/phase observations; matching status is not proof of the same rule.
- Focused reused loop 9.328 seconds; checked rebuild plus cold cases 37.217 seconds.
- Four-core full frontend inventory about 5 minutes, with known failures retained.
- Exact-image B1 equality improves controlled full-source wall 630.026→339.992s.
  It is not yet a reusable checked-source optimization. Public H remains separate.
- Phase 4 correctness/performance records remain immutable and artifact-specific.

## Ranked work and cheapest falsifiers

| Rank | Work | First decisive gate | Owner |
| --- | --- | --- | --- |
|1|Shared binder validation and decorator grammar|Live TS/B1 counterexamples plus valid neighbors|compact_index|
|2|Current mismatch triage and shared diagnostic fidelity|Cluster raw differences, verify intended rule and exact rendering|root|
|3|One maintained development entry|Fresh checked build, selected probes, drift/failure/resume controls|direct_calls|
|4|Portable B1 equality derivative|Strict provenance/dependency recognition, two new checked builds and Unicode/error controls|lexer_analysis|

P5-001 through P5-004 identify these tracks. Initial implementation follows the
committed design. First prototypes get bounded review before scope expands.
No general parser/kernel/emitter rewrite and no reopening rejected Phase 4
memoization/uncurrying/representation ideas without new evidence.

## Correctness and promotion rules

Keep pinned upstream unchanged. Do not fabricate bootstrap or fixed-point
provenance for derived images. Record exact acceptance, phase, checked flag,
diagnostic and output; generic rejection is not conformance. Preserve failed
attempts, counterexamples, all timings and superseded decisions. Archive small
reproducers and raw reports durably. Known suite failures remain failures.

Fixes require focused positive/negative gates and independent review. Combined
source gets the full frontend inventory and a final checked fixed point after
source freeze. Backend-impacting edits require compile-and-execute witnesses;
GPU coverage needs actual hardware. Keep default distribution separate unless
all intended release obligations are explicitly satisfied.

## Resources and checkpoints

Root coordinates source integration, broad gates, performance windows and Git.
Short correctness jobs: root CPU0, frontend CPU1, equality CPU2, workflow CPU3;
4 GiB Node heaps by default. Frozen sources/tools prevent concurrent edit drift.
No timed compiler comparisons while another intentional compiler job runs.
No broad/full-source job without root scheduling and an external deadline.

Commit the initial design before implementation, then validated increments.
Aim to freeze source by 02:20 UTC for final proof and evidence review. Reserve
03:10–03:39UTC for documentation, audits, commit/push and final status. Stop
new experiments at the authorized boundary; report any unfinished gates honestly.
