# Compiler experiment ledger

This ledger records decisions and links evidence; it does not replace the reports.
Read [workflow](README.md) and [current strategy](STEERING.md) before a new investigation.
User objective: make the Bend compiler written in Bend and its validation loop much faster while preserving correctness. The current authorized optimization window ends about 20:16 UTC on 2026-09-22.

## Migration checkpoint — 2026-09-22, 17:13 UTC

The file workflow is adopted during Phase 4 in response to the user's `rom1504/math` suggestion. These records summarize already completed or active experiments; they were not preregistered. Existing designs, detailed reports and raw evidence stay in place. Earlier phases remain indexed by their reports rather than being retroactively relabeled as this wave.

| ID | Experiment | Decision at checkpoint |
| --- | --- | --- |
| [P4-001](phase4/P4-001-private-calls.md) | Private compiler calling convention | Accepted |
| [P4-002](phase4/P4-002-indexed-book.md) | Indexed final-definition selection | Accepted |
| [P4-003](phase4/P4-003-telescope-facts.md) | Reuse substitution-invariant telescope suffixes | Accepted |
| [P4-004](phase4/P4-004-projection-layout.md) | Projection copies and direct child access | Deferred |
| [P4-005](phase4/P4-005-normalization-shortcut.md) | All/ADT weak-head shortcut | Rejected |
| [P4-006](phase4/P4-006-tag-comparisons.md) | Direct private tag comparisons | Rejected |
| [P4-007](phase4/P4-007-nullary-sharing.md) | Share private nullary values | Deferred |
| [P4-008](phase4/P4-008-native-flags.md) | Native PGO and compiler flags | Deferred |
| [P4-009](phase4/P4-009-stability-memo.md) | Memoize completed private stability facts | Pending |
| [P4-010](phase4/P4-010-wnf-pair-memo.md) | Memoize private weak-head normalization | Rejected |
| [P4-011](phase4/P4-011-ordinary-uncurry.md) | Flatten ordinary partial-call chains | Rejected |
| [P4-012](phase4/P4-012-boolean-matchers.md) | Specialize exact private Boolean matchers | Pending |
| [P4-013](phase4/P4-013-edit-loop.md) | Checked B1 rebuild and persistent focused validation | Accepted |
| [P4-014](phase4/P4-014-full-profile.md) | Full-source inspector sampling | Rejected |

“Accepted” means the stated implementation/boundary is supported by the linked gates, not complete language conformance or a universal speedup. “Rejected” includes valid transformations that did not help; it does not necessarily mean semantically incorrect. “Pending” is not promoted.

### Updated frontier

The combined source has completed checked self-reproduction: both H stages have SHA `b33b38e32a263bf78e1d43cf459b7abf9a41d78d112d71a25f87ddba7bd09bf8`. Full frontend observations remain unchanged, with 560 existing differences from pinned TypeScript. The actual focused developer loop is already seconds rather than a full-build iteration.

Prioritize a controlled full-source private-image comparison and the reviewed Boolean/stability combination. Keep the unchanged control image. Do not revisit weak-head memoization, direct tag comparisons or ordinary-function uncurrying without explicitly overcoming their recorded obstruction. Native O2 is a proven useful full-source lane; PGO setup is a separate amortization decision. Large term-layout migration remains an open research direction, not an inferred requirement.

Next wave must use the current [strategy](STEERING.md), specify the quickest falsifying check, and preserve exact output and resource evidence before promotion. Update this frontier after each material decision; preserve the older entry as history.

## Full-source private-image counterexample — 2026-09-22

[P4-016](phase4/P4-016-private-lexical-scope.md) records a lexical-scope bug found
by the whole-source gate. The canonical private image completed checking but
failed emission with `F is not defined`. Specialized workers had been
hoisted out of their generated helper-table blocks. The 602-second failed run
is retained and provides no successful-compilation speedup. The public compiler's
fixed point and earlier scoped observations remain valid.

The new small comparison passes all 54 observations, with successful B1 requests
7.6%/12.8% faster. A negative-case regression is retained; a separate five-round
confirmation finds a smaller 4.9% request regression, with all 15 exact outcomes.
See [the complete comparison](../implementation/phase4/small-comparison.md).

### Updated frontier

Correct the private lexical-scope transformation first, using a tiny reproducer
and independent review, then issue new image identities and repeat the affected
full-source gate. Other prototypes remain experimental. Do not multiply their
standalone gains: the four-way Boolean/stability comparison already shows
interactions and run variation. The exact Con-arm pilot
[P4-015](phase4/P4-015-exact-con-arms.md) is rejected for inconsistent material
benefit; retain its proof and measurements without escalating to a full build.

## Private scope correction — 2026-09-22

The fix for [P4-016](phase4/P4-016-private-lexical-scope.md) is independently
reviewed. Only proven module-level generated functions can be hoisted; captured
workers use the original closure. Twenty-five package tests and fourteen actual
split-worker controls pass. The escaped-string fixture's actual output equals
public H byte for byte. The new private image is `61e7d94c…`; its full-source
request is running under the original resource limits.

### Updated frontier

Complete that full-source gate and regenerate the Boolean/stability comparison
on the corrected base. The original four-way results remain scoped historical
evidence. Prioritize exact final-image frontend observations once the candidate
is chosen. Archive principal checked artifacts so later investigations can start
from verified bytes without repeating an eleven-minute emission solely to
recover their starting image.

## Corrected combined private candidate — 2026-09-22

[P4-019](phase4/P4-019-private-combined-profile.md) records the freshly rebased
four-way experiment. All 48 selected observations agree exactly. Combined
Boolean/stability specialization reduces core request median 26.902→23.855
seconds (11.3%), with all three pairs improving and no observed peak-RSS increase.
Focused Boolean, graph, changed-source/import, escaped-string and package
provenance controls pass. The earlier matrix stays separately archived because
its original base had the lexical-scope bug.

The corrected default private image has completed whole-source compilation with
exact H bytes. Its 780.022-second process and 778.536-second request observations
are single-run results; they are not paired medians. The combined candidate's
whole-source and exact frontend gates are running. Canonical profile integration
is staged only, leaving the default and all active tool identities unchanged.

### Updated frontier

Finish and independently review those final candidate gates before exposing the
named profile. Require exact output and retained resource evidence; preserve
the unchanged default and the ordinary checked B1 development loop. Do not
launch more percentage-scale private variants while the selected candidate is
under integration validation. Native frontend/annotation feasibility remains
a separate investigation with its own source and semantic boundaries.

## Final private gates — 2026-09-22, 18:41 UTC

[P4-020](phase4/P4-020-private-full-source.md) passes all four planned source
emissions, each exactly equal to the proven H. Opposite-order profile gains are
3.91% and 0.75%; mean process wall improves 805.634→787.260 seconds (2.28%), with
3.16% higher mean maximum-child RSS. Preserve the roughly 10% candidate drift.
The final private frontend independently preserves all 2,756 raw results and
verdicts, with the same 560 differences from TypeScript. Canonical named-profile
packaging is being finalized; the default bytes remain a separate identity.

[P4-018](phase4/P4-018-native-annotation-parallelism.md) rejects the disposable
two-worker native annotation wrapper: exact trees agree, but component wall is
11.5% worse in both orders. Propagation of may-fork metadata is a concrete
suspected cause, not a proven causal ablation. No four-worker/full-source
escalation follows this negative result.

### Updated frontier

[P4-021](phase4/P4-021-frontend-scheduling.md) measures four-core validation and
an idle serial bracket with no competing compiler experiment. Finish this route
before interpreting its wall-time improvement. Keep the seconds-scale B1 focused
loop as the default edit workflow.

[P4-022](phase4/P4-022-residual-private-profile.md) finishes bounded final-core
profiles: private generic apply remains 28.16% exclusive samples, while checking
and annotation dominate API spans. The
[next lowering design](../design/phase4/next_compiler_lowering.md) identifies typed
workers spanning matches, but the cheapest next gate is actual family/staging
counts plus strict demand-order controls. A sample share is not a speed ceiling.
Do not reopen rejected memoization or claim a tenfold gain from overlapping
micro-optimizations.

## Faster validation and a surviving B1 ablation — 2026-09-22, 19:21 UTC

[P4-021](phase4/P4-021-frontend-scheduling.md) is accepted as a resource-scheduling
workflow. The idle serial gate takes 1,036.017 seconds; four-core runs immediately
before/after take 299.376/297.699 seconds. Their median gives 3.47× throughput,
71.18% less wall, with all 2,756 raw results, verdicts and replay histories exact.
The earlier loaded serial is 9.04% slower and remains outside the primary ratio.
[P4-019](phase4/P4-019-private-combined-profile.md) now also passes canonical
packaging: actual default/profile images reproduce `61e7`/`4318`, with 25 unit cases
and seven guards. The named profile is opt-in; source/public APIs stay distinct.

[P4-023](phase4/P4-023-matcher-family-counts.md) completes its bounded exact-output
counter gate. The two substitution helpers account for 18.22% of actual partial
records and 8.68% of generic applications in this core workload. These are
operation counts, not time or bytes. They justify a narrowly guarded semantic
falsifier, now planned as P4-025, rather than a general lowering rewrite.

[P4-024](phase4/P4-024-b1-string-equality.md) passes 909 helper controls and 12 exact
selected observations. Core request reductions are 35.58% and 35.13% in opposite
orders; list and the retained rejection also improve. The derived image also
preserves every full frontend observation. Its single full-source exact-H gate
is running. This is a guarded JavaScript artifact derived from checked B1,
explicitly not a new checked bootstrap or a changed default API.

### Updated frontier

Finish the derived B1 full-source gate and preserve its measured scope. Complete
the bounded substitution-worker falsifier only if demand/error/deep-stack
controls pass; timed escalation still requires consistent material core gains.
Stop new experiment work by 19:55–20:00, leaving the final 15 minutes for report,
artifact/link review, commits and push. No production source mutation is needed
for either remaining experiment.

## Whole-source equality gate and worker rejection — 2026-09-22, 19:33 UTC

P4-024's experimental B1 emits the exact full H in 348.373 seconds, with unchanged
source, host, runtime and proof inputs. This completes its correctness escalation;
the earlier full B1 build is not used as a paired performance control. The image
remains an exact-artifact derivative, not a new checked bootstrap or default API.

P4-025 passes 157 semantic controls and all four exact core emissions. Request
gains are 7.25% and 1.99% in opposite orders, so the predeclared consistent-5%
threshold rejects this narrow worker implementation. No broad/full-source gate
or canonical integration follows. The general lowering question remains open;
the observed partial-record count did not predict a stable material gain.

### Updated frontier

[P4-026](phase4/P4-026-b1-full-source-comparison.md) is the final timed experiment:
four fresh complete-source observations in opposite orders, exact H and memory
checks, with all competing compiler work stopped. Its absolute 20:09 deadline
leaves time to retain any incomplete comparison before the 20:16 campaign end.
Archive and review the completed gates in parallel; do not launch another
optimization or source edit during this final measurement.
