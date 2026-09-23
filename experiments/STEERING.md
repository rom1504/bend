# Current compiler experiment strategy

Evidence cutoff: 2026-09-23 02:40 UTC; baseline `7d69850`, final checked integration API `5969c53d34a0…`.
Authorized Phase 5 window: 2026-09-22 21:39:36 to 2026-09-23 03:39:36 UTC.
Next review: consolidated CLI/default verification, then broad backend closure by03:25 UTC.

## User objective

Prioritize conformance, simplify code where it helps future changes, and retain
or improve the fast development loop. Work for six hours, document the design
and results, and commit/push validated increments. Latest steering explicitly asks
for one usable consolidated compiler, then the remaining semantic gaps and6×
performance deficit. See the
[Phase 5 design](../design/phase5/conformance_and_development.md).

## Established position

- Production source: 59 Bend modules, 16,055→16,509 physical lines (+2.83%).
- Final integration05 preserves all 919 positive fixtures and completes all
  2,756 frontend observations: 1,060 strict check passes / 318 failures, down
  from 377 failures at campaign baseline. Focused 387 declared oracles pass;
  110 exact diagnostic differences remain in that explicit acceptance selection.
- Final live comparison has444exact differences (560at baseline), including16
  status/phase differences (50at baseline). There are116new exact agreements and
  zero new exact regressions. The remaining428text-field differences can include
  different selected errors; they are not all assumed cosmetic.
- Focused reused loop 9.328 seconds; checked rebuild plus cold cases 37.217 seconds.
- Controlled full frontend ABBA:301.905→229.753s with maintained equality,
  all11,024observations/history records exact and known failures retained.
- Final-source controlled P5-023 completes all six fresh processes and output
  gates: TS60.248s /checkedB1 642.581s /maintained derivative363.392s mean process
  wall. The derivative uses43.45%less time than B1 and remains6.03×slower than TS
  for the documented workflow/cache policy. Public H remains separate.
- Private Base-decoding memo passes84mixed requests/15adversarial groups; focused
  ABBA16.629→10.144s (39.00%). Full-inventory ABBA passes all 11,024 observations/history records and reduces
  mean wall292.602→242.597s(17.09%). The exact measured host is promoted; no
  combined equality+memo gain is inferred.
- Phase 4 correctness/performance records remain immutable and artifact-specific.

## Remaining validation, in order

| Rank | Work | Decisive gate | Owner |
| --- | --- | --- | --- |
|1|Consolidated default release|Actual default CLI and relocatable source/runtime/lineage verification|compact_index/root|
|2|Paired broad JS/native execution, running|All1,981eligible probes/compiler on chosen derivative, preserved failures and outputs|direct_calls|
|3|Remaining semantic gaps|Isolated parser witnesses/patch with unchanged released source|lexer_analysis|
|4|Residual6× deficit|Bounded diagnostic profile of actual optimized compiler, then cheapest falsifier|root|

The final H and derivative frontend inventories are complete: each has2,756exact
B1 observations,318known strict failures and closed/revalidated worker histories.
The completed archive preserves5,034members in5,175,824compressedbytes.

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
P5-023 is complete and independently audited. Cheap smoke failures revealed
differing library export policy and natural root order; both were explicitly
handled before timing. The unchanged genuine checked-B1 fixed-point procedure
completed at02:10:22UTC with all competing intentional compiler jobs paused.
Both actual stages have SHA5043267732f5…; B1stage661.410s/Hstage1595.546s are
descriptive proof observations. Public H/derivative full frontend gates completed
at02:30UTC. Broad JS/native correctness now runs on the chosen derivative with
four workers, ending by03:25UTC; it makes no timing claim. A tiny static-review probe confirmed an
existing multiline-string cursor error that makes the new renderer highlight
the wrong line; it remains unfixed and acceptance behavior is unchanged.
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
GPU coverage needs actual hardware. The user now authorizes default consolidation;
follow the [release design](../design/phase5/consolidated-release.md), preserve
authentic parent/proof provenance and verify the actual packaged default.

## Resources and checkpoints

Root coordinates source integration, broad gates, performance windows and Git.
Short correctness jobs: root CPU0, frontend CPU1, equality CPU2, workflow CPU3;
4 GiB Node heaps by default. Frozen sources/tools prevent concurrent edit drift.
No timed compiler comparisons while another intentional compiler job runs.
No broad/full-source job without root scheduling and an external deadline.

Commit the initial design before implementation, then validated increments.
Compiler source is frozen; freeze the final host/build by00:30–00:45UTC. Reserve
roughly40minutes for controlled full-source comparison, then40minutes for checked
self-reproduction. The final schedule gives the proof exclusive compiler access,
then four cores to H/derivative frontend validation (cutoff02:45UTC) and the broad
backend gate (45-minute bound). Prepare documentation during the proof and reserve
the remaining final window for archives, audits, commit/push and final status. Stop
new experiments at the authorized boundary; report any unfinished gates honestly.
