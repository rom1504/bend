# Current compiler experiment strategy

Evidence cutoff: 2026-09-23 00:43 UTC; baseline `7d69850`, final checked integration API `5969c53d34a0…`.
Authorized Phase 5 window: 2026-09-22 21:39:36 to 2026-09-23 03:39:36 UTC.
Next review: controlled final full-source comparison, about 01:25 UTC.

## User objective

Prioritize conformance, simplify code where it helps future changes, and retain
or improve the fast development loop. Work for six hours, document the design
and results, and commit/push validated increments. See the
[Phase 5 design](../design/phase5/conformance_and_development.md).

## Established position

- Campaign baseline: 59 Bend modules, 16,055 physical lines; recount after source freeze.
- Final integration05 preserves all 919 positive fixtures and completes all
  2,756 frontend observations: 1,060 strict check passes / 318 failures, down
  from 377 failures at campaign baseline. Focused 387 declared oracles pass;
  110 exact diagnostic differences remain in that explicit acceptance selection.
- Last completed live comparison before that: integration02 has556differences,
  including38acceptance/phase observations. Do not relabel those as final counts.
- Focused reused loop 9.328 seconds; checked rebuild plus cold cases 37.217 seconds.
- Controlled full frontend ABBA:301.905→229.753s with maintained equality,
  all11,024observations/history records exact and known failures retained.
- Exact-image B1 equality improves controlled full-source wall 630.026→339.992s.
  A reusable checked-source derivative now passes new-build correctness and
  controlled Phase5 small/full-frontend measurements. Public H remains separate.
- Private Base-decoding memo passes84mixed requests/15adversarial groups; focused
  ABBA16.629→10.144s (39.00%). Full-inventory ABBA passes all 11,024 observations/history records and reduces
  mean wall292.602→242.597s(17.09%). The exact measured host is promoted; no
  combined equality+memo gain is inferred.
- Phase 4 correctness/performance records remain immutable and artifact-specific.

## Ranked work and cheapest falsifiers

| Rank | Work | First decisive gate | Owner |
| --- | --- | --- | --- |
|1|Shared binder validation and decorator grammar|Live TS/B1 counterexamples plus valid neighbors|compact_index|
|2|Current mismatch triage and shared diagnostic fidelity|Cluster raw differences, verify intended rule and exact rendering|root|
|3|One maintained development entry|Fresh checked build, selected probes, drift/failure/resume controls|direct_calls|
|4|Portable B1 equality derivative|Strict provenance/dependency recognition, two new checked builds and Unicode/error controls|lexer_analysis|

Two reviewed source batches have complete frontend gates and no new differences.
P5-005 is rejected: four exact repairs do not justify repeated quadratic source
reconstruction. Subsequent reviewed work now repairs bare-operator/matcher/
namespace rules, an actual Nat wrong result, and imported declaration freshness.
The duplicate core/checker filter and two obsolete Nat helpers are removed.
P5-011/019/022 provide explicit parser-error metadata and source-aware rendering.
Their original stronger presentation gates remain failed where existing parser
differences persist; the approved narrower claim is faithful rendering, no lost
exact oracles and no acceptance changes. Source changes are frozen for final
integration. A missing-import phase gap remains explicitly outside the confirmed
selection, with the original failing combined run retained.

P5-021 is complete. Final selected CPU/backend coverage passes 84 declared
observations (42 per compiler), including actual native compilation/execution.
P5-023 prepares the final complete-source TS/B1/derived comparison; cheap smoke
failures revealed differing library export policy and natural root order, now
explicitly corrected before timing. Reserve all cores during controlled timing
and then the unchanged genuine checked-B1 fixed-point procedure. Broader JS and
native correctness can run after those gates, with no timing claim.
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
Compiler source is frozen; freeze the final host/build by00:30–00:45UTC. Reserve
roughly40minutes for controlled full-source comparison, then40minutes for checked
self-reproduction with backend correctness jobs on other cores. Retain ample
time for a failed gate rather than starting another source experiment. Reserve
03:10–03:39UTC for documentation, audits, commit/push and final status. Stop
new experiments at the authorized boundary; report any unfinished gates honestly.
