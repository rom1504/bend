# Compiler experiment ledger

This ledger records decisions and links evidence; it does not replace the reports.
Read [workflow](README.md) and [current strategy](STEERING.md) before a new investigation.
User objective: make the Bend compiler written in Bend and its validation loop much faster while preserving correctness. Historical authorization windows are recorded below; current release status and priorities are in [STEERING.md](STEERING.md).

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

## Controlled full-source equality result — 2026-09-22, 20:09 UTC

[P4-026](../implementation/phase4/b1-native-equality-full-comparison.md) completes
all four planned observations at 20:08:44, before the unchanged 20:09 deadline.
Control/candidate/candidate/control process times are 628.273 / 339.318 /
340.665 / 631.779 seconds. Both opposite-order pairs pass the preregistered
request and process thresholds: process reductions are 45.99% and 46.08%.
Means are 630.026→339.992 seconds, **46.04% less time / 1.85× faster**. Every
actual H output and captured input agrees exactly. Mean peak RSS is 1.56% lower;
per-run values remain visible, including the slightly higher second candidate.

This establishes a material complete-source gain for the exact derived B1.
It does not promote arbitrary future builds, change the default distribution,
establish faster emitted programs, or turn a derived JavaScript artifact into
a newly checked bootstrap. The original single correctness observation remains
outside the four-row comparison. The consumed preregistration file is preserved
unchanged, with results in the dedicated report rather than appended to it.

### Updated frontier

The six-hour pass has finished compiler experiments and independent archive
review. The final comparison preserves 259 file identities in 120 verified
compressed objects. No compiler job remains running. The established loop is
a checked B1 rebuild, targeted persistent
witnesses, then four-core broad regression and justified source self-reproduction.

For later work, first make equality portable across genuinely new checked builds
without false provenance or an H regression. The new lowering design compares
the artifact and source routes. Shared identifier/index counts remain a useful
algorithm investigation; the narrow worker's rejected result still constrains
larger lowering proposals. Conformance work can already use the seconds-scale
focused loop while retaining the 560 known upstream differences explicitly.

## Phase 5 authorized: conformance and simpler development — 2026-09-22, 21:39 UTC

The user authorized another six hours after reviewing current performance,
conformance and code-size metrics. The new design prioritizes conformance,
targeted simplification and bounded reusable optimization. Baseline is `7d69850`;
Phase 4's observations and rejected experiments remain unchanged.

Initial independent tracks are P5-001 frontend binder/decorator witnesses,
P5-002 maintained development workflow, P5-003 portable checked-B1 equality
interpretation, and P5-004 current mismatch triage/diagnostic fidelity. See
[the design](../design/phase5/conformance_and_development.md). No new measured
result is claimed by this entry.

### Updated frontier

Commit/push the design, reproduce cheap semantic witnesses, then implement and
validate bounded candidates. Root coordinates shared source, full-suite gates
and uncontended timings. Work ends 2026-09-23 03:39:36 UTC, with source freeze
and final evidence/documentation time reserved before that deadline.

## Phase 5 first integrated checkpoint — 2026-09-22, 22:24 UTC

P5-001, P5-002, P5-003 and P5-004 have focused evidence and archived attempts;
see the [campaign report](../implementation/phase5/report.md). P5-004's concrete
first target became do-notation grammar/desugaring after current mismatch triage.
The genuine checked combined API `a17d909d9c48…` completes all2,756 frontend
observations, preserves919/919positive fixtures and introduces zero new live
TypeScript differences. Strictcheck failures377→376; liveexact differences
560→558, acceptance/phase50→48. The fresh reference is unchanged. Known failures
remain failures; selected local improvements do not inflate full-suite metrics.

A failed reference setup and an incomplete180-second single-core attempt are
retained alongside the completefour-worker retry. Workflow times are not
controlled performance samples. The maintained workflow and reusable equality
derivative have correctness/provenance gates, but no new Phase5 speed claim.

### Updated frontier

Continue bounded adjacency, diagnosticreason and exactsource-origin experiments,
then integrate reviewed candidates. Keep sourcefreeze/finalproof time reserved;
the six-hour campaign remains active until03:39:36UTC.

## Phase 5 second integrated checkpoint — 2026-09-22, 23:03 UTC

P5-006/007/008/009/010 are integrated in genuine checked API `c3c2ac7b1456…`.
All 213 selected observations meet their declared oracles; the full frontend
preserves all 919 positive fixtures and introduces zero new live differences.
Strict check failures are now 374 (377 at campaign start); live differences are
556, including 38 acceptance/phase observations. The remaining 518 diagnostic
and report discrepancies still count as failures. See the
[campaign report](../implementation/phase5/report.md) and its second integration
archive for exact source, tool and input identities.

[P5-005](../implementation/phase5/application-origins.md) is rejected: four exact
diagnostic repairs do not justify repeated quadratic application reconstruction.
The failed attempts and original timings remain archived, with no promoted code.
[P5-012](../implementation/phase5/equality-performance.md) confirms the reusable
derivative on the new source: core request median 19.278→12.262 seconds and list
2.464→1.849 seconds. All ten rows pass. Pinned TS list request is 0.397 seconds;
the derivative is 4.65× slower on this small workload and stated cache policy.
This does not replace the historical complete-source comparison.

### Updated frontier

Review structured parser transport, matcher heads and unqualified operators;
separate the discovered namespace-delimiter error-loss bug from formatting.
Run the prepared controlled four-core complete frontend ABBA comparison only
when competing compiler jobs are paused. Keep final source freeze, CPU coverage
and checked self-reproduction time reserved. Campaign ends at 03:39:36 UTC.

## Phase 5 validation checkpoint — 2026-09-23, 00:20 UTC

[P5-015](../implementation/phase5/equality-frontend.md) completed the controlled
full-inventory ABBA comparison. All11,024raw observations and worker histories
agree; mean wall301.905→229.753s,23.90%less. Each run retains the same374strict
check failures for its source. This does not alter the historical full-source
ratio to TypeScript.

P5-011/013/014/016/017 are reviewed and integrated in checked API8cfa124d….
A complete full control now preserves919/919positives with365strictcheck
failures. The selected diagnostic composition failure is retained and addressed
by P5-022. Later checked API9bb69d… also includes P5-018/020/022:361of362selected
semantic observations agree, with one unchanged missing-import phase gap exposed
by an incorrect joint oracle. The original case and failed run remain; the
confirmed subset is explicitly separate.

[P5-018](../implementation/phase5/frontend-nat-prefix.md) repairs both adjacency
and an actual8-versus5 result discrepancy. Its intermediate error-order regression
was corrected and retained. [P5-017](../implementation/phase5/core-filter-layering.md)
restores standalone frontend layering and passes23existing definition-selection
controls. [P5-020](../implementation/phase5/imported-freshness.md) repairs18selected
acceptance/phase observations; a focused overhead gate finds no material regression.

P5-019 adds45exact diagnostics in167cases with no previously exact losses or
classification changes. P5-019/022 retain their original failed unchanged-or-exact
gates. Independent review approves faithful rendering of the same chosen error,
while existing parser/first-error mismatches continue to count as differences.
No grammar tags or fixture filters conceal those residuals.

[P5-021](../implementation/phase5/persistent-base-decoding.md) identified repeated
Base JSON decoding/verification as44.14%of a focused request sample. The private
session memo passes84mixed comparisons and15adversarial groups. A168-observation
ABBA pilot measures39.00%less request time. The full same-compiler, different-host
ABBA is running under a20-minute budget; no full gain or promotion is claimed yet.

### Updated frontier

Compiler source is frozen. Complete the memo gate, final combined build/frontend
inventory, actual CPU/backend coverage, fresh complete-source TS/B1/derived
comparison and genuine checked self-reproduction. Recount production, maintained
support and experimental code separately. Preserve all failed or incomplete
attempts. The campaign remains active until03:39:36UTC.

## 2026-09-23 00:38 UTC — P5-021 full gate and final combined build

The full Base memo comparison completes with all 11,024 result/history records
exact and mean 292.602→242.597 seconds (17.09% less). Both orders improve about
17%; all 919 positives and 365 known strict failures are retained. The exact
measured two-file host candidate is promoted under SHA guards; full evidence
and historical cost/gate tools are archived. Integration05 starts from frozen
combined source with 371 focused fixtures/387 observations and the unfiltered
1,378-fixture frontend inventory. The known missing-import phase residual stays
in the original failed selection/evidence and is explicitly excluded only from
the confirmed focused repairs. No final combined metric or fixed point is claimed.

## 2026-09-23 00:44 UTC — final combined source gates

Integration05 is genuine checked API5969c53d34a0… for sourcee3b927d13dc2… .
All387 focused declared oracles pass (277exact/110diagnostic differences).
The full unfiltered frontend completes2,756observations and preserves919positive
fixtures in both lanes. Strict check failures377→318,59repairs/0regressions.
Against fresh pinnedTS, exactdifferences560→444 (116resolved/0new); status/phase
differences50→16, with428remaining differences in text fields. This does not
classify every text difference as cosmetic. All2,756reference observations are
unchanged. The separate42-percompiler backend gate passes84actualobservations,
including9positive interpreter/JS/native executions and exact pinnednegative
diagnostics, while retaining10custom diagnostic differences. Final integration
evidence archives4,890historicalfileidentities/3,260objects/9,383,519compressed
bytes. Full-source timings and genuine checked self-reproduction remain pending.

## 2026-09-23 01:33 UTC — P5-023 complete; final proof running

The [final-source comparison](../implementation/phase5/full-source-comparison.md)
completed at01:25:56UTC. All six fresh-process checking, emitter-family byte and
execution gates pass. Mean process wall is60.248s for pinned TypeScript,
642.581s for genuine checked B1 and363.392s for its maintained derivative:
43.45%less than B1,6.03×the TypeScript workflow. Both opposite-order pairs
improve. The documented Base-cache asymmetry, two samples per variant and distinct
emitter/export policies remain explicit. An independent raw-file audit passes;
the archive preserves253fileidentities/205objects/1,926,588compressedbytes.
The consumed precommitted plan is unchanged; its later association record is
dated honestly and does not rewrite benchmark inputs.

A [targeted static-review counterexample](../implementation/phase5/static-counterexample.md)
confirms an existing multiline-string lexer cursor defect and a new wrong source
excerpt in final05. The actual offending line is5; both earlier/final Bend report4,
and the new renderer highlights string content on that line. Rejection phase and
checked flags are unchanged; the valid neighbor agrees exactly. Both four-case
paired gates retain two exact diagnostic mismatches. No fix was attempted on
the frozen source.

The fresh unchanged maintained self-host procedure started at01:32:44UTC from
genuine final B1, in its own directory with no imported measurement stages.
Competing compiler jobs are paused. After actual B1→H→H completion, the plan is
full public-H/derivative frontend equivalence followed by bounded paired broad
JS/native execution. No proof or unexecuted backend coverage is claimed yet.

## 2026-09-23 02:12 UTC — fresh checked fixed point complete

The unchanged maintained self-host procedure completed its fresh B1→H→H proof
at02:10:22UTC. Both stages exited0 without signals and verified their recorded
inputs. Stage2 and stage3 report identical SHA5043267732f5178b12d14708e7dc07e3aa1a71b9d1d5949ef279af23c4297edd;
actual stage2 already matches the four P523 Bend outputs. Independent final-byte
and module auditing follows before archiving. B1stage took661.410seconds and
publicHstage1595.546seconds; these are descriptive proof-stage observations,
not a repeated controlled H/TS comparison. No competing intentional compiler or
archive job ran during the proof. Small documentation/read-only metadata work
and a Git checkpoint pinned toCPU3 overlapped the CPU0 proof.

The audited P523/report checkpoint is pushed as307962c. Automatic review first
rejected the push for unverified destination; read-only account/repository checks
established authenticated rom1504 ownership, ADMIN access and the configured fork
of bendlang/bend. The same authorized destination then accepted the push.

All three broad-wrapper guard tests pass, and fresh snapshot03 retains the exact
corrected tool. Previous snapshots remain unexecuted history. The full publicH
then derivative frontend gates launch with unchanged2756-observation inventories;
the H cap is prospectively25minutes rather than30 to reserve derivative time
before the02:45cutoff. Broad paired JS/native execution remains held until those
compiler jobs finish. No unexecuted coverage is counted as passed.

## 2026-09-23 02:36 UTC — consolidate the validated compiler

The final H and maintained derivative frontend gate completed at02:30:30UTC.
Both reproduce all2,756 B1 observations exactly, preserve all318 strict failures,
and close/revalidate all91 worker histories. The verified archive preserves
5,034 members in5,175,824 bytes; see the [artifact gate](../implementation/phase5/final-artifact-frontend.md).

The user now explicitly requests one usable compiler version, then remaining
semantic gaps and the6× deficit. The [consolidation design](../design/phase5/consolidated-release.md)
promotes the validated equality-derived B1 as the ordinary CLI default, with
a relocatable release manifest and genuine historical lineage kept distinct.
This supersedes older default-distribution holds; it does not rewrite original
proof or timing evidence. Broad backend preparation04 will test this selected
derivative, rather than the unexecuted checked-parent preparations01–03.
No broad result or release completion is claimed by this decision entry.

## 2026-09-23 03:00 UTC — usable default checkpoint

Commitd5a7bd8 is pushed to the authorized selfhost/bootstrap fork branch.
The [consolidated release](../implementation/phase5/consolidated-release.md)
uses APIe2b546… without overrides; actual npm build reproduces its exact bytes.
Default check/interpreter/JS/native and relocation/integrity controls pass.
An observed native subprocess error with status0 now returns exit1; five host
regression groups and an actual default-CLI EPERM reproduction verify the fix,
followed by another genuine checked build and21paired controls. No compiler
source/API bytes changed. A clean relocated package without upstream/build data
also verifies and runs pure/IO JavaScript programs.

The broad backend sweep remains running on its frozen pre-fix host and same API.
It retains unsupported reference cases and actual failures. The fresh
[optimized profile](../implementation/phase6/optimized-residual-profile.md)
identifies residual trampoline/closure/allocation work. An isolated explicit
Boolean-worker candidate passes438direct controls and exact core emission; its
controlled ABBA timing is held until competing compiler jobs close. An isolated
erased-name parser candidate repairs14exact focused observations with no lost
exact result; it remains unpromoted, and a marked-name noncapture experiment
is still running. None of these candidate results changes release metrics.

## Consolidation and opening Phase 6 outcomes — 2026-09-23T03:22:29+00:00

The Phase 5 default is installed and already pushed (`d5a7bd8`), with actual
checked rebuild, source/runtime/host-bound manifest, native error-exit fix and
relocated ordinary CLI evidence. The [campaign report](../implementation/phase5/report.md)
links all final integration gates.

The [broad JS/native run](../implementation/phase5/broad-backends.md) closed at
03:08:40 UTC: 3,962 observations, no missing rows or drift, 315 negative strict
Bend failures and one positive native timeout. Its 24,148 verified archive members
include actual generated C and native executables. Complete coverage remains
distinct from conformance/infrastructure pass.

The [Boolean pilot](../implementation/phase6/boolean-branches.md) passed both
predeclared opposite-order ≥5% request/process thresholds, with exact core-library
bytes: 6.72%/6.18% less request time and 6.30%/5.79% less process wall. This does
not change the default or its measured 6.03× TS full-source ratio. Public-H
behavior and timing require separate gates. The [marked-name candidate](../implementation/phase6/marked-name-analysis.md)
is rejected for a concrete `+f(1)` precedence regression despite selected phase
repairs. The separate [erased-name guard](../implementation/phase6/semantic-gap-analysis.md)
improves its focused comparisons but remains unpromoted. New `+U32` false
acceptance outside the pinned inventory is retained explicitly.

The [native footprint analysis](../implementation/phase6/native-arity-wall.md)
identifies quadratic scalar-field continuation saves in the timed-out large
record, a separate problem from JS library compilation. The [Phase 6 report](../implementation/phase6/report.md)
links the follow-up designs, bounded experiments and remaining promotion gates.

## Last bounded follow-ups — 2026-09-23T03:28:07+00:00

The [native scaling falsifier](../implementation/phase6/native-arity-wall.md)
completed checked emission for 32/64/128 fields. Literal continuation bytes
62,299 / 230,651 / 888,091 nearly quadruple with each doubling, corroborating
quadratic prefix repetition against the retained 255-field anchor. No Clang,
user-program execution or optimized emitter was run.

The [actual-H Boolean follow-up](../implementation/phase6/boolean-branches.md)
retains two distinct verdicts: original positional malformed-data graph gate
failed after 430 completed controls; separately named checked core-emission gate
passed exact output. Baseline H itself fails the inherited raw-function identity
comparison, so this is an unresolved oracle/partial-function contract, not a
silently repaired success. No H speed claim, new fixed point or source promotion.
All compiler experiments are now closed. Remaining campaign work is final
source recount, documentation/evidence checks, commit and push.

## New authorized Phase 6 campaign — 2026-09-23 05:06:12 UTC

The user authorizes all proposed speed, complexity/line-count and conformance
improvements, with up to ten hours. The new deadline is 15:06:12 UTC. Baseline
`a6459af` is clean and already pushed. The [campaign design](../design/phase6/ten_hour_campaign.md)
separates nine concrete experiments covering the eight proposals, isolated
implementation, measured promotion gates and a final usable release. Earlier
Phase 6 opening results and failed candidates retain their original scope.

Initial parallel read-only assignments cover prefix semantics, source provenance
and native immediate words. Root handles baseline identity, obsolete-path audit,
missing imports and checked-result reuse. Source implementation starts after the
design checkpoint. No new speedup, simplification or conformance repair is claimed
at this starting entry.

## First ten-hour campaign checkpoint — 2026-09-23T05:40:05.229181+00:00

The [campaign report](../implementation/phase6/campaign-report.md) records five
frozen candidates: prefix/erased semantics, native immediate fields, multiline
lexer positions, obsolete freshening and missing-import phase classification.
Checked isolated gates and independent reviews are retained; production remains
unchanged. The native255-field witness now actually compiles and runs, with95.31%
less generated C. The cleanup removes184lines with byte-identical selected APIs.
These results do not change the release's6.03×TypeScript speed claim.

Source provenance v2 fixes112missing-excerpt cases while preserving141prior exact
negatives, but has material metadata allocation/cache cost. Measure that cost
serially before promoting; retain the earlier one-case diagnostic regression.
Root's structured-error candidate removes140Bend lines and passes its first
checked/default gate; exact broader gates remain. The next frontier is accepted
provenance overhead, one authoritative checker result, typed-fact opportunity
measurement, parser families and the Boolean H oracle.

## 2026-09-26 — sequential simplification, S0 complete

The user authorizes the [phased simplification design](../design/phase7/compiler_simplification.md)
with design, work and report for each phase in sequence. The [S0 audit](../implementation/phase7/s0-report.md)
changes no implementation. It verifies unchanged source/release identities and
finds an exact 548-line obsolete-code candidate for S1, projecting 15,961 lines.
The larger 50%/75% budgets remain unproven; S0 identifies substantial shortfalls
in the proposed later allocations rather than crediting hypothetical savings.
The previous steering is preserved as an audit input. S1 is the next authorized
implementation; prior Phase 6 candidates remain separate.

## 2026-09-26 — S1 obsolete paths retired

[S1](../implementation/phase7/s1-report.md) removes548 physical compiler lines,
460 nonblank lines and14,980bytes, reaching15,961lines. The54-root checked and
optimized APIs are byte-identical to their baseline; active compiler behavior,
host and runtime remain unchanged. Fresh checked build,21 focused controls,
compiler/runtime components and51/51 harness tests pass. A stale artifact-test
mock export was repaired; sandbox EPERM and an omitted gated-test environment
remain preserved attempts. The smaller-source release verifies and ordinary
check/interpreter/JS smoke passes. No new full-source timing or fixed point is
claimed. S2 design is next; 50%/75% goals are still unachieved.

## 2026-09-26 — S2 shared provenance trace

[S2](../implementation/phase7/s2-report.md) retires duplicate source reparsing and
origin/event alignment:135 fewer lines,134 fewer nonblank lines,3,764 fewer bytes;
15,826 total compiler lines. Its bounded design was pushed before implementation.
Fresh checked build,21focused controls,all components,51harness tests,530new
cross-version provenance comparisons and204existing diagnostic comparisons pass.
52of54selected root closures retain identical generated code; changed origin
routes preserve exact outputs. CPU0 serial provenance medians improve25.4%/40.5%
for all/filtered loading; existing-trace lookup has no regression. No new whole
compiler/TS ratio or fixed point is claimed. The usable release is installed and
all raw evidence preserved. S3 design is next; 50%/75% targets remain unmet.

## 2026-09-26 — S3 authoritative checker result

[S3](../implementation/phase7/s3-report.md) removes139Bend lines and adds2host
lines by preserving the original structured failure and deleting duplicate event,
prefix and diagnostic replay workers. The compiler is15,687lines (822removed,
4.98%). Fresh full parse/check vectors match on all2,756observations, including
919positive/459negative check fixtures;318strict failures remain. Checked/focused,
allcomponents,52harness tests,204diagnostic and39first-error comparisons pass;
actualhost counters establish4→1selected failing-body checks. Serial ABBA shows
33.5%faster late rejection byrequest,30.6%byprocess, accepted overhead<0.7% and
maxpairedRSSgrowth2.91%; exact outputbytes remain. The usable release is installed.
No new full-sourceTSratio orB1→H→Hproof isclaimed. S4mustfund another7,433lines
before the50%milestone; the targetremains unmet.

## 2026-09-26 — S4 bounded checkpoint installed; milestone remains open

[S4](../implementation/phase7/s4-report.md) removes another 1,020 physical /
588 nonblank lines / 16,706 bytes, reaching 14,667 / 12,505 / 470,062. The original
baseline reduction is 11.16% physical, 9.40% nonblank and 7.82% bytes. Corrected
declaration candidate A02 passes genuine checked B1→H→H byte equality; the first
425-law attempt is preserved as rejected after losing two bootstrap exports.
B01 shares loader and embedded-error walks and common list operations. All 2,756
frontend observations match S3 exactly; 318 strict failures remain. Component,
harness, provenance, diagnostic and native smoke gates pass. Serial host cost
increases at most 1.53%; raw/parsed graph medians increase 1.94%/2.63%; memory
and size guards pass. This is simplification with small cost, not a speedup.

The proposed continuation fusion is rejected with a reproducible pinned-language
falsifier. B02 relocates unchanged generic joins to their datatype owner and
produces byte-identical B01 compiler images. Its own genuine checked bootstrap
is installed; default and relocated integrity/check/interpreter/JS/native smoke
pass. Source-only context improves, but new test obligations prevent uniform
context/byte reduction. A02's H proof remains A02's, not B02's. All rejected
attempts, raw measurements and artifact identities are preserved. Another 6,413
lines are needed for the 50% milestone; no later phase is reported complete.
The final controlled S3/S4/S4/S3 development-loop gate takes about 35 seconds
per fresh checked/focused attempt: paired wall differences −0.71%/+0.72%,
maximum RSS increase 3.30%. The failed first measurement setup is retained;
all four actual attempts and runtime/memory guards pass.

## 2026-09-27 — architectural experiment design

The user authorizes recording eight architectural ideas and trying the recommended
first three to find the best direction. The [prospective design](../design/phase7/architectural_experiments.md)
starts isolated P7-A01 checked output, P7-A02 semantic values, and P7-A03 binding
operations inside the still-open S4 milestone. Each hypothesis has its own record
under phase7. Candidate implementation, correctness, measurement and promotion
remain separate; no prototype has run and no source saving is claimed. The
installed 14,667-line compiler is the unchanged comparison control.

## 2026-09-27 — three architectural trials compared

The [comparison report](../implementation/phase7/architecture-report.md) records
three actual isolated Bend prototypes. A01 checked output passes genuine B1,
21 focused controls and 148 direct-output assertions; its preparation workload
takes about 17% less time but check-only costs about 25% more and 45% more peak RSS.
A02 semantic values reduce substitution-heavy normalization time about 47%, but
closed constructor data costs 3.415× and median process RSS about 1.95×. Stronger
controls expose and retain quotation, shape and conversion-demand failures before
correction. The final selected suite passes 100 controls, but a later All-domain
witness remains a known demand regression; a codomain probe is inconclusive.
A03's 965 observations pass, but the runtime generic walker adds 22 lines and
slows freshening 19–23% and shifting 81–82%.

These are bounded operation measurements, not whole-compiler or TypeScript
comparisons. None is promoted and no production simplification is credited.
Checked-output ownership is the best next investigation, beginning with output/
discard policy before allocations. The installed 14,667-line S4 compiler remains
byte-identical and passes release verification; 318 strict failures remain the
previous recorded full-frontend result. Sources, original failed attempts, exact
artifacts, measurement workers and final decisions are preserved in the
[shared evidence capsule](../implementation/phase7/architecture-evidence/README.md).

## 2026-09-28 — upstream and conformance migration authorized

The user authorizes updating upstream, improving conformance and using validated
simplifications. The [prospective Phase8 design](../design/phase8/upstream_and_conformance.md)
freezes target `b2111cf43244e65f76ddc278ee695e669f720cbf`, 118 commits beyond the
old pin. S4 B02 source/API/release identities are preserved; initial release
verification passes. New and old upstream checkouts are separate. Bootstrap API,
Nat host boundaries, upfront declarations and current verdict rules need explicit
migration. No compiler candidate has run yet and no speed gain is claimed.
Percentage line goals are no longer prerequisites; the rejected general evaluator
and runtime generic walker remain out. P8-001 and P8-002 own the first bounded
bootstrap and conformance hypotheses. Prior dirty Phase6 work remains untouched.


## 2026-09-28 — upstream migration consolidated

The [Phase8 report](../implementation/phase8/upstream_and_conformance.md) records
one installed genuine checked release targeting b2111cf, after2.0.32. The API is
e928f777…6374bbe4; source0f5425ac…6a47822; final runtime1766d6d6…5e772f0.
Whole-book bootstrap, ABI controls, focused language and backend gates, and
30 ordinary/relocated release steps pass. All19 component groups ran;18 pass,
while six source diagnostics retain missing-caret differences.

The final2,996-row paired frontend run accepts997/1,001 positives, rejects481/482
validation negatives and leaves one negative timeout. Seven incorrect acceptances
are fixed; none is observed in the final vector. Exact differences fall743→734
within the new target. Four new positive literal cases and four imported-law
trust cases remain. All913 common-path current positives pass;121 paths were
added, one removed, and510 common source hashes changed. Reports preserve these
categories instead of borrowing old-pin conformance claims.

All192 focused parse/check observations,18 semantic outputs,35 import/JS outputs,
44 final foreign-runtime outputs and13 native/scanner controls pass their explicit
oracles; selections overlap. The first tag guard's primitive regression and the
subsequent generic-parameter falsifier remain beside corrected actual executions.
Native Process is blocked by the same unavailable libc symbol in upstream.
GPU and interactive devices remain outside measured coverage.

The compiler retains S4 simplifications and grows310 lines for new behavior:
14,977 physical /12,779 nonblank lines across 59 modules, still9.28% below the
original16,509-line baseline. Generated API shrinks27.80%. No new50%/75% claim or
unchecked generic rewrite is promoted.

P8-001's unchanged-source operation comparison improves1.45–1.52×. P8-003's
separate controlled full-source **checking** comparison records205.26s Bend versus
2.80s TypeScript,73.20× process wall; it does not measure full compilation.
A coarse profile locates most time in checking. The measured checked-build plus
focused loop is about27s. All samples, failed attempts, exact identities and
archived byte objects remain linked from the [preservation index](PRESERVATION.md).
The checked release is not relabeled a fresh self-hosted fixed point.

## 2026-09-28 — targeted checker speed phase authorized

The user requests design, implementation and report. The prospective
[Phase9 design](../design/phase9/checker_speed.md), committed as `e7b2846` before
experiments, preserves the Phase8 release and targets measured checker work.
P9-001 adapts the native equality derivative; P9-002 tests three independent
checker work reductions; P9-003 separates duplicated descent from compact
literal representation; P9-004 owns baseline/residual profiling and the final
same-source controlled comparison. No candidate is promoted at this point.

## 2026-09-28 — Phase9 checked compiler released

The [final report](../implementation/phase9/checker_speed.md) records the installed
`integrated-03` checked B1 and version-3 equality derivative. Chronological law
checking shares an immutable binder-bound seed; exact conversion, lambda checking
and successful lookup avoid redundant work. Descent avoids repeated failed-child
comparison, and compact Nat literals repair the two Nat checking failures.
The initial cache-metadata and later Nat-inference diagnostic regressions are
repaired; both failed attempts remain preserved. Native equality retains guarded
provenance and exact historical version replay.

The controlled same-final-source checking comparison is **66.84 s versus 208.22 s**
for Phase8, **3.12× faster**. Pinned TypeScript takes **2.94 s**, leaving a **22.74×**
process-wall gap. Two serial fresh processes per compiler use one CPU and retain
every result; peak memory remains about 1.5 GiB. These are checking costs, not
full compilation or generated-program runtime. The approximately 27-second
checked-build/focused loop remains appropriate for routine edits.

All 2,996 frontend observations complete without timeouts. Positive type acceptance
improves from 997/1,001 to **1,000/1,001**, and all **482/482** validation negatives
determinately refuse, with zero observed invalid acceptances. Exactly four baseline
observations improve; all others are unchanged. There remain 731 exact reference
differences, one long-string positive failure and four imported-law trust cases
that fail before the intended phase. All **42** ordinary/relocated release checks
pass across interpreter, JS and native execution. No new self-hosted fixed point
or full backend-equivalence claim is made.

**Updated frontier:** investigate remaining declaration-membership scans,
generated-call/allocation overhead and deep-pattern layout costs with small
controlled series. Compact strings and imported-law fills are semantic priorities.
Source is 15,050 physical lines across 59 modules, 73 more than Phase8; the earlier
50%/75% simplification goals remain unmet. The
[preservation index](../implementation/phase9/checker-evidence/README.md) retains
failures, complete measurements, exact inputs and the final release. Unrelated
Phase6 work remains outside this promotion.

## 2026-09-28 — Phase10 repeated-work cycle started

The user asks to repeat the successful method. The
[prospective design](../design/phase10/repeated_work.md) is committed and pushed
as `1449aaf`; Phase9 `f21e9f0` remains the installed baseline. A fresh profile of
its immutable `integrated-03` passes checking and input-identity guards. Loader
membership, deep-pattern layout and profile-ranked generated/index overhead
have separate bounded owners and prospective records. The
[outcome report](../implementation/phase10/repeated_work.md) will distinguish
operation counts, measured times, semantic gates and actual promotion. No new
speed gain or conformance change is claimed at this checkpoint.

## 2026-09-28 — Phase10 repeated-work compiler released

The [final report](../implementation/phase10/repeated_work.md) installs checked
`integrated-01` and its guarded equality derivative on unchanged upstream b2111cf.
Conditional alias/membership guards avoid unnecessary scans; Boolean-parameter
index workers become an upstream-generated loop; typed constructor lookup and
layer-by-layer Nat validation remove repeated layout searches. Raw malformed-book
boundaries, failed syntax probes and the native Nat300 timeout remain explicit.

Serial same-final-source checking improves **1.30×**, **67.04→51.75 seconds**,
with pinned TypeScript at **2.89 seconds**: **17.93×** remaining process-wall gap.
Memory stays about 1.5 GiB. Separate serial Nat300 JS runs improve **1.38×**
(34.17→24.74 seconds), and the layout pass improves **19.09×** (9.48→0.50 seconds).
The emitted JS is byte-identical and all four runs produce 306n; no generated-
program runtime speedup is claimed. Two samples per variant remain descriptive.

All **2,996** frontend observations match Phase9 exactly; 1,000/1,001 positive types,
482/482 negative refusals and 731 exact TypeScript differences are unchanged.
All **42** installed/relocated release checks pass with interpreter, JS and native
execution; the final Nat32 native witness also passes. The initial sandboxed
smoke's six Clang EPERM failures remain beside the successful fresh permitted run.
No new self-hosted fixed point, Lean kernel check or GPU evidence is asserted.

Source adds 57 physical lines to **15,107** across 59 modules, five helper definitions
and no new type. The observed checked-build/focused interval is 26.19 seconds.
Long strings/imported-law fills remain semantic priorities; a fresh final-artifact
profile and reconstructed-pattern/native code expansion are next speed targets.
The [verified evidence capsule](../implementation/phase10/evidence/README.md)
retains exact inputs, rejected attempts, complete measurements and release lineage.
Unrelated Phase6 files remain outside the commit. The 50%/75% reduction targets
remain unmet.

## 2026-09-28 — Phase11 upstream-guided optimization started

The user authorizes further work and larger conceptual changes, and suggests
rereading TypeScript. [Design](../design/phase11/known_work.md) `cf29bae` preserves
released Phase10 `5f561c4` and unchanged upstream b2111cf. Fresh actual-release
profiling, pattern/native expansion, checker normalization and branch/call costs
have independent bounded investigations and prospective records. The
[report](../implementation/phase11/known_work.md) will separate component evidence,
whole-workflow measurements, semantic gates and promotion. No new performance,
conformance or fixed-point result is claimed at this checkpoint.


## 2026-09-28 — Phase11 final integration

[Design](../design/phase11/known_work.md), [report](../implementation/phase11/known_work.md),
[evidence](../implementation/phase11/evidence/README.md). Promote lazy offload
lookup, shared constructor telescope, bounded open-Succ lowering and reviewed
version4 choice derivative. Exact-comparison shortcut deferred; delayed fallback
unimplemented. Current pin stays b2111cf. Final API63c861e9 is an explicit
checked-B1 derivative with historical replay, not a new bootstrap/fixedpoint.

Serial same-source checking51.443→29.729s (1.7304×); TS2.785s, remaining10.674×.
Nat300 JS24.450→15.611s with identical code; native emission27.032→3.609s,
C20,589,858→269,358B. Actual Clang/run succeeds306n. Full frontend:1,001positive
acceptances,482negative refusals, zero invalid acceptances/timeouts,730exactTS
differences. Long-string fixture improves; all other2,995observations unchanged.
Four imported-law trust cases still fail early. Final37row paired backend gate
passes with3exact differences. Source adds31lines to15,138; reduction goals open.

Independent operation/derivation/boundary controls and final release validation
are linked in the report. Preserve every failed attempt, including zero-count
underflow, setup/oracle mistakes, and status-zero EPERM launch records. Invalid
call microtimings are excluded. No performance ratio is inferred from archive
capture, profiling, operation counts, or historical different-source measurements.


## 2026-09-28 — Phase12 avoidable-work investigation started

User authorizes another optimization round. The
[prospective design](../design/phase12/avoidable_work.md) preserves Phase11
`f8244c9`, selected API63c861e9 and unchanged upstream b2111cf. Root profiles the
actual final release before choosing integrations. Independent bounded owners
inspect delayed normalizer fallback, remaining branch/call work and rediscovered
checked/literal structure; plans precede probes and no live source changes happen
before evidence. The [report](../implementation/phase12/avoidable_work.md) will
separate actual correctness, measurements and promotion from the1.2–1.5× estimate.
No new speed, conformance or fixed-point result is claimed.

## Phase12 final avoidable-work round — 2026-09-28

The [report](../implementation/phase12/avoidable_work.md) selects integrated-03,
API0975a4a8, with typed constructor lookup/literal reuse and guarded version5
leaf branch lowering. Same-source checking improves29.56→26.90s (9.0%), versus
pinned TypeScript2.86s (9.42×gap); Nat300JS15.73→7.90s (1.99×), and native
emission3.71→2.78s (1.33×), with unchanged generated bytes and actual execution.
Source loses8lines/onehelper; maintained host transformation/test complexity grows.

All2996frontend observations match Phase11, retaining730exact TS differences,
all1001positive accepts,482negative refusals and four early imported-law failures.
The37paired backend rows pass. Normalizer seed cleanup and broad inlining remain
rejected after fresh and exact-history counterexamples; integrated01/02 remain
failed. The corrected leaf candidate passes both53/60request histories at4MiB.
The focused selection adds the string first, since baseline itself can overflow
after the older21-case prefix. No general stack-safety claim follows.

[Preservation](../implementation/phase12/evidence/README.md) retains original
plans, checked attempts, failures, exact tools, measurements and release checks;
publication binds full byte/mode recovery and explicit prerequisites. Next work
starts from a profile of this final API. No new fixedpoint, kernel/GPU gate or
generated-program runtime gain is claimed. Unrelated Phase6 work stays untouched.

## Phase13 structured-rewriter experiment started — 2026-09-28

The user authorizes the staged [design](../design/phase13/structured_rewriter.md):
profile the actualPhase12release, reproduce its guarded transformations through
a shared structured view, then try explicit branch workers that preserve execution
boundaries. Independent capture/demand/stack review and exact53/60histories precede
whole-source timing. Expansion requires meaningful benefit; no speedup is promised.
The [report](../implementation/phase13/structured_rewriter.md) will retain failures
and distinguish checked provenance, correctness, timing and promotion.

## Phase13 structured-rewriter experiment completed — 2026-09-28

The [report](../implementation/phase13/structured_rewriter.md) closes the staged
[design](../design/phase13/structured_rewriter.md). The installed Phase12 compiler,
upstream b2111cf, Bend source and conformance frontier remain unchanged.
A shared structural view replays authentic transformation versions 1–5 exactly.
Named-worker lifting removes closures but adds capture arrays; complete-source
checking is 1.01% slower, so it is rejected. Actual unsafe-capture cases and their
corrected recognizer remain preserved.

Selector fusion removes intermediate selection work while retaining selected
body arrows. Its one-owner pilot reduces process time by 6.63%; bounded const-scope
recognition in six owners reaches **27.36→24.47 s, 10.56% less time**. Each image
passes independent semantic controls, a fresh long string and both exact saved
53/60-request histories before timing. These are finite controls, not a general
stack-safety or compiler-soundness proof. All timing rows use separate exclusive
ABBA comparisons with two samples per image; no new TypeScript ratio is inferred.

**Decision: defer integration.** A self-contained helper reproduces the prototype
and historical versions exactly, but grows from 296 to 535 lines and adds 7,010
bytes. The smaller gain does not compensate with simpler maintained machinery
and misses the roughly 20% checking target. No new checked release or broad
conformance gate is claimed for the experimental image. The last installed
TypeScript comparison remains 9.42×, and semantic gaps remain unchanged.

**Updated frontier:** remove measured intermediate work, not just closure syntax.
Keep this selector prototype for a cheaper implementation or a demonstrably
larger opportunity; do not broaden branch inlining past saved counterexamples.
Imported-law semantics and exact diagnostics remain useful next priorities.
The [evidence capsule](../implementation/phase13/evidence/README.md) preserves
profiles, failed attempts, consumed tools, exact histories and all measurements;
publication checks full byte/mode recovery. All 75 unrelated Phase6 files remain
unchanged and unstaged.

## Phase14 conformance-first phase started — 2026-09-28

The user authorizes the recommended next phase. The
[design](../design/phase14/conformance_and_dispatch.md) preserves Phase12 API
0975a4a8 and upstream b2111cf. Independent bounded owners investigate the four
imported-law cases, group exact differences and select one shared correction,
and test source-level normalizer dispatch following the successful index pattern.
The [report](../implementation/phase14/conformance_and_dispatch.md) will separate
semantic changes, exact output, scoped controls, controlled timings and promotion.
No new result is claimed at this checkpoint; all unrelated Phase6 work stays untouched.

## Phase14 conformance and source dispatch completed — 2026-09-28

The [report](../implementation/phase14/conformance_and_dispatch.md) promotes
combined-01 API9136be92, retaining upstream b2111cf. Deferred imported-law fills
now inherit canonical signatures after dependency loading; all11trust refusals
match exactly. Source-order trust reporting uses final declarations. Checker
carets remove a shared diagnostic gap, and six source normalizer workers avoid
intermediate choices without extending the maintained JavaScript helper.

The full2,996-observation gate preserves all1,001positive accepts and482negative
refusals. Exact differences fall730→603(194parse/409check),127new matches and no
regressions. The two alias-declaration observations now refuse at the proper parse
phase;26other checker changes add only carets while retaining an exact gap. No
unexpected semantic delta, invalid acceptance or timeout is observed. The71/78
strict diagnostic family still fails for seven prior span errors.

Controlled identical-final-source checking is27.40→24.98s,8.82%less process time;
pinned TypeScript is2.81s, leaving8.88×gap. Exactly two reviewed host argument edits
are explicit; remaining hosts/Base/runtime match. The separate identical-host
pilot saves9.03%. Ratios are not multiplied. Source grows134lines/4,670bytes/11defs
and two temporary markers; maintained JS helper/runtime stay unchanged. This is
not a source reduction or generated-program runtime speed claim.

Both checked builds pass26focused controls. All226paired saved-history observations,
41paired backend rows,16helper groups,five authentic replays and42installed/relocated
CLI checks pass within their stated scopes. The full launcher's null/undefined
postprocessing failure remains failed; a strict identity-bound audit reuses the
healthy vector without rerunning fixtures. Earlier failed fixtures/attempts and
strict differences remain in [preserved evidence](../implementation/phase14/evidence/README.md).

**Updated frontier:** address another measured shared diagnostic cause; profile this
exact release before expanding source dispatch. The Phase13 rewriter stays deferred.
Keep rejected seed/branch transformations excluded until their history failures
are addressed. All75unrelated Phase6 files remain unchanged and unstaged.


## Phase14 attribution correction

A read-only follow-up audit separates the127new exact matches into71checker-caret
improvements,48trust-reporting improvements and8imported-law observations. The
initial main report/CONFORMANCE incorrectly attributed119to checker rendering.
The [corrected report](../implementation/phase14/conformance_and_dispatch.md) and
[per-observation audit](../implementation/phase14/exact-match-attribution.json)
retain the exact breakdown. Total improvement, compiler, timings and validation
results are unchanged. The original capsule preserves the pre-correction wording
and all raw evidence; it has not been rewritten.


## Phase15 parser conformance and checking speed started — 2026-09-29

The user authorizes all recommended next steps. The prospective
[design](../design/phase15/parser_conformance_and_speed.md) binds Phase14 API9136be92
and unchanged upstream b2111cf. Independent owners inspect10parser/load behavior
gaps,66parser-caret fixtures and a fresh profile before one bounded source-speed
experiment. Root retains strict full-corpus delta/acceptance, exact histories,
backend and installed/relocated release gates. The
[report](../implementation/phase15/parser_conformance_and_speed.md) will separate
exact attribution, measured costs, remaining failures and promotion. No new
performance or conformance result is claimed at this checkpoint. All75unrelated
Phase6 files remain unchanged and unstaged.


## Phase15 completed — 2026-09-29

**Installed:** combined-02 API `b8d658c5`, genuine checked parent `32ec77a3`, unchanged
upstream `b2111cf`. The [report](../implementation/phase15/parser_conformance_and_speed.md)
and [per-observation attribution](../implementation/phase15/exact-differences.md)
record parser/import/cycle fixes, shared caret rendering and two source lookup
workers. Exact differences fall 603→459 with 144 new matches and none lost:
132 parser carets, ten missing-file contexts, two binder-plus-caret observations.
All measured behavior/output axes agree across 2,996 observations; remaining
exact differences are diagnostic. All 1,001 positives, 482 validation refusals
and 11 exact trust refusals retain their required results.

Controlled identical-source checking takes 25.0780→24.1023 s (3.89% less process,
3.92% less request time); TypeScript takes 2.8858 s, leaving an 8.3520× gap. The
host patch is explicit and all other hosts/Base/runtime agree. The isolated lookup
pilot separately gains 3.49%; ratios are not multiplied. Source is 15,288 lines,
+24 overall: formatter −35, behavior +37, lookup +22. No new maintained JS rewrite.

Both corrected builds pass 36 focused cases. The standalone component, 226 paired
history observations, 41 backend rows, 16 helper groups, five authentic replays and
42 installed/relocated CLI checks pass. Three known backend exact differences
remain. The initial cycle precedence regression and both first 32/36 integration
failures stay rejected; corrected scoped witnesses do not weaken upstream oracles.
All superseded tools/failed audits remain in [preserved evidence](../implementation/phase15/evidence/README.md).
All 75 unrelated Phase6 files are unchanged and unstaged.

**Updated frontier:** another shared diagnostic cause, then a fresh installed-image
profile for any larger representation/allocation experiment. The source-worker
pattern still pays but does not close the 8.35× gap. Keep routine edits on the
36-case checked workflow; no old multi-hour campaign is renewed.


## Phase16 exact conformance started — 2026-09-29

The user authorizes continued work toward full conformance with low checking cost
and simple implementation, and explicitly approves project evidence archives to
`rom1504/bend` / `selfhost/bootstrap`. Phase15 evidence commit `2ab7b14` is pushed.
The [design](../design/phase16/full_conformance.md) freezes unchanged upstream,
459 exact differences, successful behavior axes and 75 unrelated-file identities.
The fresh same-image baseline averages 24.5512 s Bend and 2.6651 s TS (9.2122×);
1.82% variation between identical Bend groups is not an optimization result.
Independent owners inspect parser errors, checker errors and missing source
origins. Numeric full-range provenance requires an isolated cost/ABI gate before
instrumentation. Outcomes go in the [report](../implementation/phase16/full_conformance.md).


## Phase16 first complete conformance wave — 2026-09-29

The isolated wave1-build-02 full gate reduces 459→364 exact differences, with
95 new matches (82 parser / 13 checker), zero lost exacts and unchanged primitive
behavior on all 2,996 observations. The installed compiler remains Phase15.
The metadata-only numeric-span experiment costs 1.01% process time and 8.93%
peak RSS in the same-source exclusive matrix; populated spans remain unmeasured.
The common rebuild helper removes 90 repeated projections and 275 source bytes
with its 22-group gate passing; its speed is unmeasured. The [report](../implementation/phase16/full_conformance.md)
preserves scoped results, the omitted-file first composition and the corrected
complete-owner preparation guard. Continue semantic controls and explicit source
provenance before final integration/promotion.

## Phase16 populated origins and second complete wave — 2026-09-29

Integration04 passes the full gate with **459→145** differences: **314 new exact,
zero lost**, all 2,996 primitive observations still agree with pinned TypeScript.
The range group is 160/169 exact. Two bounded semantic controls also expose and
fix canonical negation-name capture and implicit bare-family instantiation; their
tiny changes are integrated and documented separately. The failed integration02
partial-parser ranges and every first attempt remain preserved.

The first populated-span same-source comparison costs **10.17% process time**:
25.5882→28.1905 s, TS 2.8902 s. This exceeds the prospective threshold. No Phase16
compiler is installed. Diagnostic profiles motivate a guarded unsafe recursion
scan and one-copy range construction; operation counts and 32 range controls
pass, and their composition passes focused36 plus twelve exact recursion checks.
Exclusive recovery timing is pending. Read the [conformance report](../implementation/phase16/full_conformance.md)
and [cost investigation](../implementation/phase16/range-cost-recovery.md).

The next parser candidate makes another 62 targeted observations exact with
16/16 positive controls and no loss in its 244-observation family census; final
composition is pending. A proposed scoped memo-key correction is explicitly
rejected after growth-limit and literal-versus-constructor counterexamples.
Correctness includes first-error order and syntax-sensitive memo identity.

## Phase16 corrected fourth wave — 2026-09-29

`wave4-build-02` / `wave4-frontend-02` reaches **51 exact differences**:
408 new matches against Phase15 and94 against integration04, with no losses
under either comparison. Primitive outcomes remain exact on all2,996 observations.
The first wave4 accidentally reverted the bare-family predicate; the new adjacent
gate detects and preserves that failure, and the corrected candidate reruns the
whole corpus plus all eight family boundaries. Current source is15,616 lines
in59 maintained modules (+328 versus Phase15), not a net LOC reduction.

The first wave4 cost matrix is **25.9805→29.0659 s**, TS2.9332 s: +11.88% process
cost and a9.91× TS ratio for that unselected image. The small scan/copy changes
did not demonstrate recovery. An existing-index template-membership experiment
passes27 operation controls and24 complete-program comparisons; timing is pending.
All remaining semantic, platform, history and release limitations stay explicit
in the [Phase16 report](../implementation/phase16/full_conformance.md).


## Phase16 fifth full wave and cost attribution — 2026-09-29

The accepted wave5 gate reaches **48 exact differences**, three fewer than wave4,
with zero lost matches and all 2,996 primitive outcomes unchanged. See the
[report](../implementation/phase16/full_conformance.md),
[invalid-binder controls](../implementation/phase16/unbound-binder-marker.md) and
[kind-origin controls](../implementation/phase16/kind-origin-fallback.md).

The [template membership index](../implementation/phase16/template-membership-index.md)
is correct on its controls but flat at 28.8561→28.8768 s; leave it unselected.
[Stage attribution](../implementation/phase16/stage-cost-attribution.md) directs
investigation toward loader allocation and host source validation. It is an
instrumented diagnostic with variable baseline stages, not a replacement for the
ordinary +11.88% cost result. Base-prefix reuse needs an exact law/operation probe
and original request-history gates before any change can be selected.

The next integration keeps parser/import ownership explicit. New module-name
controls expose the semantic alias/local-binder precedence gap; retain it and
its positive witness. No Phase16 compiler is installed and no full-conformance,
new fixed-point or generated-runtime speed claim is made.


## Phase16 sixth full wave — 2026-09-29

Wave6 passes the adjacent full gate at **24 exact differences**, 24 newly exact
and none lost since wave5; 435 newly exact versus Phase15. All 2,996 primitive
outcomes agree with pinned TypeScript. The unchanged maintained backend selection
is now **41/41 exact**, clearing its three historical diagnostic differences.
[The report](../implementation/phase16/full_conformance.md) distinguishes these
scoped results from full conformance and an installed release. Source is 15,759
lines, +471 versus Phase15; no net source reduction is claimed.

The Base-prefix law passes, but operation counts bound its opportunity to 1.32%
of actual-source freshening visits, so its cache change is deferred. The stronger
lead is elaboration from roughly 105k parsed/alias nodes to 2.17M terms. Attribute
literal expansion before changing representation. Keep exact memo/literal and
same-history counterexamples as mandatory boundaries. Production stays Phase15.


## Phase16 seventh full wave — 2026-09-29

Wave7 passes the adjacent full gate at **18 exact differences**, six newly exact
and none lost since wave6;441 newly exact versus Phase15. All2,996 primitive
outcomes still agree. Lexical alias handling fixes a separately measured invalid
rejection. Integrated controls are157/159 exact, with only the two known imported
law wording gaps;16 direct alias controls pass. See the [report](../implementation/phase16/full_conformance.md).
The separately checked qualified-pattern fix closes six erroneous acceptances
and awaits integration. Production remains Phase15.

The [literal census](../implementation/phase16/checker-compact-literal-census.md)
finds about2M literal-construction terms within the2.17M raw source graph.
Compact literal representation is now the principal performance experiment;
operation counts do not establish an end-to-end speedup. Contextual module
parsing and final program-completeness ordering proceed in isolated snapshots.


## Phase16 eighth full wave — 2026-09-29

Wave8 reaches **16 exact frontend differences**, two new and none lost against
wave7; all2,996 primitive outcomes remain exact. The unchanged maintained backend
selection remains41/41 exact. Final completeness ordering and constructor-note
eligibility close the two remaining checker-only corpus rows. Qualified pattern
controls also close six erroneous acceptances outside that corpus. See the
[report](../implementation/phase16/full_conformance.md).

A controlled isolated completion comparison is flat at29.2656→29.3768s (+0.38%),
TS2.9708s, with unchanged memory. Keep the semantic correction; claim no speedup.
The accepted [wave7 capsule](../implementation/phase16/wave7-evidence/README.md)
now preserves917 files, with independent byte recovery and214-source-file
reconstruction from committed Phase15 plus the patch. Earlier/later experiment
preservation remains separate. Contextual completion and compact literal gates
continue; no Phase16 image is installed.


## Phase16 ninth full wave — 2026-09-29

Contextual module parsing brings the accepted full gate to **two exact
differences**, fourteen new matches and none lost since wave8; 457 new versus
Phase15. All 2,996 primitive outcomes agree and the maintained backend selection
remains 41/41 exact. Integrated independent controls are 197/198 exact; their
remaining same-body instance chronology gap is outside the main corpus. The two
main rows concern one do-block's earlier pattern error. See the
[report](../implementation/phase16/full_conformance.md).

The complete source is 16,038 lines, 750 more than Phase15. Compact literal
representation separately removes 92.97% of loaded terms on identical compiler
source, with literal/backend/host controls passing. It still needs exact
syntax-sensitive memo keys and final combined gates; no end-to-end speed claim
or production promotion follows from the structural reduction.


## Phase16 compact-literal timing — 2026-09-29

The compact-literal/context union preserves wave9's two exact frontend gaps and
all primitive outcomes, with no lost matches; all176 literal observations remain
exact. The [controlled comparison](../implementation/phase16/compact-literal-cost.md)
now measures30.8339→10.7300 s,2.87× faster, with peak RSS down65.20%. TS takes
2.9962 s, so the gap falls10.29×→3.58× within that single measurement window.
Six serial fresh-process rows are healthy and other compiler/archive jobs stayed
closed. Known memo-key and size-boundary gaps still block promotion; final
Lambda/JSON-key integration and release gates remain open. Source grows104 lines
over wave9. No generated-program runtime speedup is claimed.


## Phase16 consolidated release — 2026-09-29

The [final report](../implementation/phase16/consolidation.md) installs
`compact-final-build-01`, API `35044ae6`, with genuine parent `83113283` and
unchanged maintained version5 transformation. All42 installed/relocated CLI checks
pass. The previous Phase15 API and lineage are retained in release history.

On identical final source, the exclusive TS/B/C/C/B/TS matrix measures Phase15
30.5837s, final12.3570s and TS3.6108s: **2.475× faster**, same-window TS gap
**8.47×→3.42×**, peakRSS**−62.70%**. The complete two-file host delta is reviewed;
this is checking/trust reporting with validated Bend Base caches and TS checking
Base. The prototype2.87× result remains historical, not a final release ratio.

Main frontend459→2 exact differences,457new/0lost; all2,996 primitive outcomes
agree. Full inventory1498 fixtures retains1001positive accepts/482validation
refusals/11trust refusals. Broader gaps stay visible: integration197/198exact;
marked-pattern71/114exact/rawpassfalse with a separate114-outcome preservation
audit; contextual/host controls retain a decorator/import wording gap. Backend41,
literal176/execution20, instance29/growth2, canonical-key61, loader/helper/history
and CLI gates bind the final image. No full-conformance, new fixed-point, kernel
or GPU claim is made.

Source grows to16,345lines(+1,057 vs Phase15),59modules,1,656definitions,775laws,
66types. Compact terms remove allocation, not source complexity. Promotion01/02
fail before copying anything; promotion03 corrects identity-schema handling and
explicitly records the known marked-pattern oracle failure. Original reports
and tools remain preserved. No test oracle is changed to manufacture a pass.

### Updated frontier

Finish durable topic-capsule recovery and commit the usable release. Then isolate
parser chronology and profile the installed compact compiler. A small raw-body
group wrapper preserves information needed by a future general checkpoint
solution; it does not itself fix the remaining monad/instance cases. Pushes
remain blocked by the earlier automatic approval review despite standing user
authorization; no publication success is claimed.


## Phase17 direct frontend lookup — 2026-09-29

The [eight-line worker](../implementation/phase17/find-worker.md) is installed as
API `9b20de50`, genuine checked parent `59317ea5`. The original emitter lowers
its mutual tail calls to a direct loop, removing a dispatch record/argument array
on each missed declaration. No host/runtime/cache/transformation change is needed.

The exclusive final-source matrix measures12.4407→11.6255s, **6.55% less process
time**, versus TS3.3998s: same-window gap3.66×→3.42×. Both order pairs improve;
request time falls7.17%, RSS0.43%. The older Phase16 TS ratio also rounded3.42×
in a different window; cross-window values are not mixed or multiplied.

All2,996 full frontend results, including existing diagnostics, are unchanged.
Demand23/expected46, selected backend41, context39/host43, original histories226,
helper16/replay5, standalone25-module loader and installed/relocatedCLI42 pass
their explicit contracts. The first promotion preparation misread paired
provenance and copied no source; its successor verifies both identities and
installs one file. Source is16,353 physical lines in59 modules (+8), not smaller.

### Updated frontier

The separate [group trial](../implementation/phase17/group-boundary.md) preserves
196 outcomes and passes92 structural controls without a conformance gain. It
remains uninstalled. Its further checkpoint proposal needs comparison with a
single parser/context authority to justify250–400 extra lines. The
[instance investigation](../implementation/phase17/instance-chronology.md) proves
both ordinary-vs-instance and nested-instance ordering gaps;22 observations have
20 exact results and all8 memo/name controls are exact. Phase18 begins only the
shared-world/result representation-cost ablation before semantic migration.
Neither research direction is a current production conformance improvement.
Publication remains blocked by the earlier automatic approval review.


## Phase18 representation screens — 2026-09-29

The [checkpoint report](../implementation/phase18/representation-checkpoint.md)
keeps the installed Phase17 release unchanged. Two independent prototypes clear
the prospective5% process-overhead screen: checker-world source03 is essentially
flat (11.7103→11.6839 s), while inert parser cursor source02 costs0.93%
(11.6339→11.7416 s). These use separate identical-source TS/B/C/C/B/TS windows;
their percentages are not combined. Cursor construction counts are generated
expressions executed, not measured physical V8 heap objects.

World source06 restores historical raw KSpecialized/KChecked output after a
review found the internal-state leak. Its maintained36, chronology22, direct42,
memo8 and public18 scoped gates pass; both known TS chronology gaps remain.
The final adapter is not timed. Cursor direct194 and all196 saved outcomes pass
their preservation contracts; the raw suite retains68 strict differences.
Source costs are+107lines/+16definitions/+3types for world06 and+77lines/
+13definitions/+2types for cursor02, each against the same installed parent.
No source reduction, conformance improvement or new release is claimed.

### Updated frontier

Investigate two private Phase19 semantic slices: authoritative live-instance
checking and contextual parser checkpoints. Keep source and checked output,
private scopes, first-failure worlds and public parser stages explicit. A narrow
stopped-body alternative still needs substantial propagation machinery without
removing a semantic owner. The measured cursor cost makes testing the coherent
contextual route reasonable. Phase17 recovery is committed as`b34f8cd`; Phase18
failures and corrected artifacts are being preserved separately from Phase19.
Remote publication remains blocked by the earlier automatic approval review.

## P19-001: exact cached-prefix identity — 2026-09-29

Promoted [the two-line correction](../implementation/phase19/prefix-identity.md)
from Phase17 as API66d6ce45. Independent review found literal payload and lambda
quantity presence absent from exact_term. Twelve direct controls expose five
parent failures; the corrected image passes all twelve. A pinned proof witness
shows a real invalid cached acceptance: old check_from_exact_prefix accepts
`{0n == 1n : Nat}` against an old `{0n == 0n : Nat}` prefix, while its own full
checker rejects. The candidate rejects in both paths. This concerns the public
prefix API, without demonstrating a failure of the separately hashed host cache.

Genuine checked B1/maintained36, exact unchanged frontend2996 and installed/relocated
CLI42 pass. Controlled TS/B/C/C/B/TS is neutral: process11.6119→11.6171s,
request10.4848→10.5106s; TS3.4176s, current gap3.3992×. Same35host files, Base,
runtime, v5 profile and resource policy; expected trust refusal, no emission.
Compiler delta+2lines/+186bytes, zero new defs/laws/types. Source/host214 and all75
unrelated Phase6 states verified around installation.

Updated frontier: the usable default contains only this correction. The separate
live-checker rewrite now matches all22 saved chronology observations, but needs
remaining first-error, recursion, output, broad regression and cost gates. The
private parser names/calls slice has real order witnesses and explicit unsupported
boundaries, without a complete Core/loader route. Phase18 experiments are preserved
and independently recovered. Prefix evidence capture is the next publication
checkpoint; an earlier automatic approval review still blocks remote pushes.

## P19-002: one checker for live instances — 2026-09-29

Installed the [shared live checker](../implementation/phase19/live-checker-release.md),
APIa15d150a from genuine checkedd4e57543. Source events and live template uses now
share one semantic traversal. Source books remain authoritative; checked output
is separate data, with completed nested instances before callers. Stable public
payloads remain four-field. Prefix APIs replay source events because cache6 does
not contain memo/output state. The earlier changed-proof prefix repair remains.

All22 original chronology observations and6let controls are exact, closing two
instance-order and three let-close differences. Original integration198 is now
198exact (its raw runner retains pass:false for14negative observed labels). Main
frontend2996 complete results and broader group196/68differences remain unchanged.
Memo8/parsed29/key61/direct40/recursion4, independentboundary104, actualbackend41,
literalexecution20, histories226, helper16/replay5 and installed/relocatedCLI42 pass
their named scopes. Historicalpublic18 remains12pass/6intentionaltransition
differences; all9stablepayload/demand rows pass. No fullconformance is claimed.

Exclusive same-sourceTS/B/C/C/B/TS: predecessor11.5706→candidate11.0570s process
(-4.44%), request10.4700→9.9567s(-4.90%);TS3.4829s, gap3.3221→3.1746×; peakRSS+0.38%.
This is a small favorable cost screen, two samples/image, identical35host files,
Base/runtime/v5/resources. No emission or generated-program speed measurement.
Source15,880physical/13,527nonblank,59modules:475fewerlines/56fewerlaws, but2more
definitions/1moretype versus installedprefix. Six reviewed files installed; all
214source/host members and75unrelatedPhase6 states verified. CLI42 passes.

Updated frontier: contextual parser stages1–3 have scoped names/calls/local-body
controls but no productionCore/loader route. Stage4 targets the original saved16
with shared pattern and flatten checkpoints, preserving real header IDs and
first-error demand. Main do diagnostics and broader grouped-pattern gaps remain.
Profile the newly installed checker before more speed changes; removing another
semantic owner matters more than renaming helpers. Preserve this release separately
from active parser work. Earlier automatic approval review still blocks remote
pushes; commits are local, without a publication claim.


## Phase20 declaration checkpoints — 2026-09-29

The [usable release](../implementation/phase20/declaration-checkpoints-release.md)
installs API `40c8f7f3`, genuine checked parent `2270973c`, on unchanged pin `b2111cf`.
One declaration module adds17 lines/one function and corrects constructor admission,
name/alias/duplicate/brace order, datatype whitespace, decorator diagnostics and
first-element match grammar. No host, runtime, cache, semantic state or profile
change. Independent review caught intermediate semicolon false acceptance; all
original source02/03 evidence remains and source04 is the sole promoted candidate.

Maintained36 is now36/36 exact; decorator24, constructor50, first-element54,
whitespace44 and original supplied39/ordered-host43 are exact. New program12 and
CLI42 pass. The entire main2996 vector is unchanged, still two do-block diagnostic
differences. Broader196 improves128→136 exact with eight gains/zero lost, retaining
60 strict differences and three failed verdicts. Its raw failure remains explicit.
Source totals15,897 physical /13,543 nonblank lines,577,003 bytes,59 modules,
1,660 definitions,719 laws and67 types. Overlapping suite counts are not summed.

Exclusive six-row identical-source timing is neutral: preceding10.9727s,
candidate10.9412s,TS3.4463s; same-window gap3.1839→3.1748×,process−0.29%,RSS+0.44%.
The observed checked build+36-control loop took34.68s, a single concurrent run,
not a controlled loop-speed measurement. No emission, kernel/GPU or fixedpoint claim.
Two audit-schema mistakes and two promotion-schema mistakes are retained; neither
promotion failure copied source. No compiler fixture or oracle was rewritten.

### Updated frontier

The [private Stage4 report](../implementation/phase19/saved-row-group-frontier.md)
retains the actual-state, row/group and alpha-binding evidence; it is uninstalled.
The unexecuted [Phase21 plan](../design/phase21/group-boundaries.md) isolates a small
first-binder range hypothesis for three observations. Grouped-comma correctness
needs preserved completed-group/error order; do not substitute a raw tag guard.
Complete durable preservation and keep remaining60/main2 visible. Publication is
still blocked by the earlier automatic approval review; local commits are not pushes.


## Phase21 local and typed-annotation origins — 2026-09-29

The [usable release](../implementation/phase21/group-range-release.md) installs
API44094e58 from genuine checkedB1 on unchanged pinb2111cf. Three existing parser
workers carry the original body cursor to the sole typed-Ann producer; Local
retains its first binder origin. Source02 adds3lines/156bytes across3files,
no definitions/laws/types, traversal, host or semantic-state change. Source01
passed narrow controls but was withheld because locating Local stopped synthetic
Ann origin attachment; complete graph review caught this and the pin30 cursor
controls validate the repair.

Broader196 improves136→139exact with3gains/0lost;57differences remain and its raw
runner stays false. Main2996 entire result payloads remain unchanged, including
two do-block diagnostics. Independent68 gains16exact, no primitive changes;
additional typederror4 preserves two exact/two inherited diagnostic differences.
Structural172 and positiveAnn30 pass;80legacy origins remain absent. Checked36
strict and installed/relocatedCLI42 pass. Program12 has exact healthy compiler
observations, but nine original per-side expected-output verdicts remain false:
#| comments omitted Nat's n suffix. No fixture/oracle rewrite or redundant rerun.
Original fixture-assumption errors and the isolated-worker audit01 failure remain.

Controlled same-sourceTS/B/C/C/B/TS: parent11.0060s→final10.9547s, TS3.4364s,
gap3.2028→3.1879×. Process−0.47%, request−0.44%, RSS−0.11% is a neutralcost screen,
not a new speedup. The observed checkedbuild+36 loop took35.17s. Source totals
15,900physical/13,546nonblank,577,159bytes,59modules/1660defs/719laws/67types.

### Updated frontier

[Comma controls](../implementation/phase21/group-comma.md) establish that a rawtag
guard loses valid nested tuples and earlier pattern errors. Adding missing
Parallel lowering alone risks false checked acceptance of raw-comma syntax.
The next semantic change needs preserved completion/failure order with actual
lexical scope. Private contextual research remains uninstalled; no second pattern
checker or location-based syntax inference. Remaining57/main2 and independent
constructor gaps stay visible. Preservation closes separately; publication remains
blocked by the earlier automatic approval review, so commits are local.


## Phase22 contextual frontend consolidation — 2026-09-29

[P22-001](phase22/P22-001-contextual-conformance.md) installs one contextual
frontend with actual scope, aliases, group completion and staged materialization.
The [release report](../implementation/phase22/contextual-conformance.md) binds
source17/build16, checkedB1 9cf01096 and guardedv5 APIade8ef02 on pinb2111cf.
Raw parsing/later-scope replay, per-term completion wrappers and98 unreachable
workers are retired. The host requires loadABI2 and corrects checkup chronology.

Final main2996 and broader196 are entirely exact, closing2 and57 differences
with zero lost matches. Audited marked114 closes43 historical differences.
Independent public176/execution36/integration198, header12/normalization12,
completion17/checkup4, strictmaintained36 and CLI42 pass. Histories226+fresh2
preserve all results except one exact prospectively pinned diagnostic correction;
unchanged standalonefrontend26 is genuinely checked independently. Counts overlap;
original raw negative statuses and failed assumptions remain visible.

The initial contextual bundle was32.77% slower. Fresh attribution led to guarded
declaration scans, direct constructor workers, a proved template-arity projection
and a constructor-only scope index preserving first-DFS winners. Two subsequent
failed cost screens (+6.48%,+5.38%) remain. The final exclusive six-row screen is
Phase21 11.0168s/final10.6991s/TS3.3833s:3.1623× TS time, process−2.88%,
request−3.22%,RSS+2.52%, exact complete observations. Only one reviewed host file
changes; this is usable-bundle checking cost, not emission or an isolated Bend
attribution. Two samples do not establish a universal speedup.

Source totals15,600physical/13,305nonblank,580,464bytes,60modules,
1691defs/638laws/68types. Physical lines fall300; bytes and helpers rise slightly.
This consolidates semantic authority without claiming the50%/75% targets.

### Updated frontier

Maintain the exact tested frontend and fast focused edit loop. Challenge new
semantic neighborhoods before another architecture change; profile the installed
image before further optimization. Kernel/GPU/platform validation and generated
program speed need separate work. The [evidence index](../implementation/phase22/context-evidence/README.md)
records preservation independently. All75 unrelated Phase6 paths remain untouched;
remote publication stays blocked by the recorded automatic approval review.

## P23 — pinned upstream migration and graph conversion (2026-09-29)

[Design](../design/phase23/upstream-graph-conversion.md),
[P23-001](phase23/P23-001-upstream-graph-conversion.md),
[P23-002](phase23/P23-002-uniform-array-atomics.md),
[P23-003](phase23/P23-003-bootstrap-profile.md), and
[report](../implementation/phase23/upstream-graph-conversion.md).

Merged29 upstream commits through0187512 after2.0.34 and added15 fixtures to the
active target. Preserved b2111cf and the old released compiler; oldTS/newTS/oldBend
were measured before edits. New upstream alone was near-neutral on ordinary
checking. Profile6 guards the changed Base dependency chain; oldprofiles1–5
retain exact replay. The current image is a derivative of a genuine checked B1,
not a new self-emitted fixed point.

Conversion reuses graph evaluation with rigid-first/full-book policies and
EQ-only post-obligation sharing. Depth32copy/shared programs formerly exhausting
1GiB now pass in1.36/1.41s under that same cap; the failed baseline cannot supply
a normal timing ratio. Added current widening/foreign/TCP/scheduler fixes and
all9arrayatomics with existing uniform arrays/RFC ownership. A surviving alias
exposed reversed native clone ordering (199versus119); final03 fixes it. Earlier
syntax, harness, missingatomic and clone failures remain preserved.

Final API5596f914 /checkedparent5f539f81: main3026 and broader196 exact, histories
226paired+2fresh exact without exceptions, focused36 and installed/relocatedCLI42
pass. Backendnew/scoped24 candidatepasses include22exact and2 Node/Bun reference
limits; retainedarrays18exact and100 multicore repetitions pass. Scanner4116,
JS TCP16 and maintainedharness114 pass. Component fixture maintenance and evidence
closure are described in the final report. Scope exclusions remain explicit:
independentkernel, GPU, arbitrarystructural/atomic races and universal equivalence.

Final exclusive ordinary check: TS3.5518s, old10.9708s, refreshed10.9199s,
final11.0135s;3.1008×TS. Final process+0.39%, request+0.52%vsold, within the
prospective3%screen. PeakRSS+7.52%vsold/−0.80%vsrefreshed. Two samples perbundle,
exact observations and unchanged identities; no generated-code performance claim.
Canonical source+148physical(+0.95%)to15,748lines, unchanged60modules/68types,
+9definitions/+2laws. This expands compatibility while reusing representations;
it is not a line-reduction phase.

**Updated frontier:** promote the pinned, validated compiler and preserve its
failed checkpoints. Profile the remaining ordinary-checking3.10× gap before new
optimization. Continue independent conformance challenges within the supported
scope, preserving exact first errors and one frontend authority. Oldmulti-hour
budgets are not renewed by this checkpoint; future work follows current user
scope and the maintained bounded-experiment workflow.


## P24 — ordinary profiles and execution boundaries (2026-09-29)

[Design](../design/phase24/profile-and-coverage.md),
[report](../implementation/phase24/profile-and-coverage.md),
[measurement review](../implementation/phase24/measurement-review.md),
[backend inventory](../implementation/phase24/backend-census.md).
Hypotheses: [profile](phase24/P24-001-ordinary-profile.md),
[local absence](phase24/P24-002-local-absence.md),
[foreign collisions](phase24/P24-003-effect-collision.md),
[membership](phase24/P24-004-membership-branch.md), and [native identity](phase24/P24-005-native-identifiers.md).

Fresh diagnostics identify source completion and repeated declaration scans,
with membership branch allocation a separate small opportunity. A negative lookup
in the existing scope index proves local absence; hits retain the original scan.
A Boolean worker removes membership closures via existing loop lowering. Direct
local-match syntax fails checked bootstrap and remains preserved. There is no new
index, cache, datatype or parser field.

The bounded execution pilot exposes two gaps despite matching frontend verdicts.
Shared emission now rejects foreign/constructor collisions before reachability;
native function IDs reuse existing scalar encoding to keep case/punctuation
identities apart. Backend81/81exact after repair; raw4check boundary failures remain
matching expected-later-error observations. Focused controls, invalid fixture
attempts and maintained native test maintenance are recorded separately.

Final API7b523bdf/checkedparente8d99da3: focused36exact, frontend3026+196exact,
histories226paired+2fresh exact. Broad reference reuse is explicitly attested,
with fresh candidate acquisitions and unchanged identities. TCP2supported-host
comparisons and8saved-program TSan executions close earlier environment gaps;
finite probes are not universal platform/race-safety claims.

Serial15samples(3/image): TS3.7370s, old11.7300s, local11.2990s,
membership11.0856s, final11.1565s. Final−4.89%process/−5.58%request with flatRSS,
2.985×TS process in this window. Final integration costs0.64%overmembership.
Native emitted identifiers grow; nat_ops C source+22.27%, no emitted runtime-speed
claim. Canonical source+28physical lines to15,776, +3helpers; modules/types/laws
unchanged. Historical large line-reduction goals remain unmet.

**Updated frontier:** keep the usable checked compiler and approximately28-second
focused loop. Expand bounded backend coverage; the inventory counts2,654execution
opportunities but only a small subset is observed here. Investigate materialization,
book walks/updates and dispatch with producer/consumer invariants before a broad
rewrite. Preserve all failed attempts and the 103 unrelated starting paths; the
new evidence capsule reuses Phase23 prerequisites and records exact recovery.

## P25 — analyze emitted programs before optimizing H (2026-09-30)

[Design](../design/phase25/generated-code-analysis.md),
[report](../implementation/phase25/generated-code-analysis.md),
[reproduction](../implementation/phase25/README.md).
Hypotheses: [call lowering](phase25/P25-001-call-lowering.md),
[allocation](phase25/P25-002-runtime-allocation.md),
[JIT/scaling](phase25/P25-003-jit-and-scaling.md).

No compiler, runtime, Base or installed release changed. Twenty-three small
sources produce46 checked libraries;127 independently expected scalar points
agree on both sides. Most are mechanism analogues, not exact full compiler
components. Forty-five runtime points supply450 clean samples on CPU3/Node24;
the full cached sweep costs171.69s of child wall. A new focused paired command,
including calibration/output checks/ten samples, reproduces a numeric case in5.37s.

Full AST analysis separates copied runtimes,48 common emitted registrations and
workload owners. Direct U32 patterns expand each scalar to33 temporary constructor
values in our runtime; exact counts corroborate the hot representation overhead.
Dense pop grows to65,562bytes of matcher code versus a60-byte upstream function
and68-byte table. Selected numeric-pattern gaps are1,418–1,761×; these are tiny
generated-program ratios, not compiler-throughput or predicted optimization gains.
Other mechanisms vary widely, with string equality near parity(1.05–1.15×).

Matches interrupt saturated calls; ordinary arithmetic uses generic primitive
dispatch where upstream emits direct loops/operations. Nine paired diagnostics
(18healthy processes) establish runtime-prefix CPU73–87%, plus allocation and
exact operation evidence. Boolean-worker source is22.24× faster under upstream
lowering but1.80× slower under our emitter on one matched input: upstream-built B1
source improvements do not automatically transfer to self-emitted H.

Selected V8 steady traces show no candidate deoptimizations; observed upstream
ones belong to the diagnostic harness. Input sizes also change seeds/paths, so
no pure scaling law is inferred. Full H, native/GPU execution and a broader current
backend sweep remain outside this phase. Independent timing and dynamic reviews
retain fixture errors, the initial missing-matcher counter vocabulary, the invalid
diagnostic launcher and trace-summary parser failures. Raw artifacts and exact
recovery receipts are preserved in the evidence index.

**Updated frontier:** first isolate direct native U32 decision lowering with strict
identity/default/demand controls; next test known saturated workers and tail loops
on the frozen traversal kernels. Keep primitive inlining, Nat representation and
constructor forcing as separate ablations. Use the seconds-scale emitted-code loop
before component/full-H integration; preserve the working Phase24 release and its
conformance scope while these backend hypotheses are tested.

## P26 — native U32 decisions without linked words (2026-09-30)

[Design](../design/phase26/direct-u32-decisions.md),
[hypothesis](phase26/P26-001-direct-u32-decisions.md),
[report](../implementation/phase26/direct-u32-decisions.md),
[reproduction](../implementation/phase26/README.md).

Promoted a110-line Bend emitter rule for native U32-to-U32 ordered matcher trees
with closed numeric leaves. Native owner/constructor guards, an8192-node limit
and explicit failure preserve generic lowering outside that envelope. Recognition
precedes deep lifting. Runtime, Base, frontend, native backend and fn/call ABI are
unchanged; the source grows0.70% to15,886 lines/61modules, with no new datatype.

Installed API4c67ac04 derives from genuine checked parent818f68ca through profile6.
Focused36exact, selected upstream JS15exact, corpus23libraries/127points exact.
Paired controls2816scalar outputs per emitter plus4refusals, supplemental468points
per emitter, and independent56guard/780worker checks pass. Actual escaping
full-text/scalar controls pass. These overlap and do not renew all broader suites.

Serial CPU3/Node24 timing:90valid samples,6cases,3outputs,5fresh processes/output,
44.61seconds total including calibration/checks. Table11.80×, wide3.66×,
direct-numeric50.25× faster than old selfhost output. Remaining TS ratios122.26×,
484.26×,12.97×. Arithmetic/actual escaping controls are unchanged within the
observed window; no whole-compiler throughput or H gain is claimed.

Exact constructor counts fall8481→0,33792→0,66→0 per respective benchmark call.
Generated pop/key definitions shrink86.7%/87.0%. Generic apply/closure work remains
large in loop workloads, explaining why eliminating one representation is not
parity. The real compiler's four numeric-case helpers return String/List and do
not qualify for this rule. The emitted comparison loop gives useful evidence in
seconds without another full self-hosting build.

Retained source/expectation pilots, initial missing diagnostic-export harness and
the overly broad documentation-inclusive closure audit. Independent review finds
no blocker for checked native scalar inputs; arbitrary raw JS object coercions
and forged native flags remain outside that contract. Capsule recovery and the 103
protected-path audit close preservation; release verification/CLI smoke pass.

**Updated frontier:** test constructor-arm prebinding as a separate call-lowering
ablation while preserving partial-function descriptors and argument demand.
Do not merely raise public arity. Wider numeric-result support, dense tables,
primitive inlining and tail loops remain separate candidates; prioritize changes
that transfer to real compiler components. Keep backend conformance acquisition
bounded, and retain compiler-throughput/generated-program/H distinctions.

## P27 — selected constructor-arm prebinding (2026-09-30)

[Design](../design/phase27/constructor-arm-prebinding.md),
[warmup amendment](../design/phase27/longer-warmup.md),
[shared-helper amendment](../design/phase27/shared-arm-runtime.md),
[report](../implementation/phase27/constructor-arm-prebinding.md),
[reproduction](../implementation/phase27/README.md).

Promoted the shared-runtime variant; rejected the first inline form. Both pass
scoped semantic gates and remove one fn/apply/bounce per affected match, but
inline substitution regresses20.08% in the original short window. V8 traces
motivated a prospectively defined longer-warm comparison, not discarded samples.
The final shared form preserves the same recognizer/partial descriptors and
removes that material measured penalty. Substitution remains effectively flat.

Final warmed actual compiler membership improves1.059× and Boolean traversal1.042×,
with nonoverlapping five-sample ranges. Short membership median1.026× has overlapping
ranges; other short gains are about2–6% on selected kernels. Four separate windows
retain360 samples with pinned TypeScript and Phase26 baselines. Independent audit
verifies504 total timing/calibration/check processes. The final short135-sample
screen takes66.93s; long45-sample screen63.14s. No whole-compiler/H claim.

Fresh shared gates:36 strict focused,15 upstream JS execution,23library/127point,
72 arm observations, numeric2816+468 scalar checks per emitter plus refusals,
22 actual component oracles and runtime ABI controls. Counts overlap; broader
frontend/native/device coverage is not renewed. Source adds58 Bend lines/eight
helpers/one module and11 runtime lines/one helper; no new datatype or representation.
Installed API5a89c775, checked parent25c38e3f, runtime40823818, sourcef3097523.

All failed/superseded acquisitions, original inline source, untimed ablations,
traces, checked snapshots and exact output bytes are retained with recovery
receipts. The103 unrelated paths remain unchanged; no new PR comment is posted.

**Updated frontier:** reducing one dispatch boundary yields incremental gains.
Test a private saturated worker or loop on the actual compiler helper before a
full H. Preserve evaluation/descriptor boundaries and measure both warmup regimes;
identical helper-count reductions do not guarantee identical V8 performance.

## P28 — broader existing generated programs (2026-09-30)

[Design](../design/phase28/broader-program-comparison.md),
[prospective warmup follow-up](../design/phase28/warmup-followup.md),
[report](../implementation/phase28/broader-program-comparison.md),
[reproduction](../implementation/phase28/README.md).

Measured six existing runtime algorithms at documented small inputs, four unchanged
mixed tests and the original small HVM interpreter demo. Both checked emitters
produce matching observable outputs on all11. Compiler source and installed Phase27
release remain unchanged; these runs do not renew the broad conformance inventory.

Original five-sample warmed algorithm ratios are111.39–1391.14× slower than pinned
TypeScript output: tree sorting111.39×, lexer139.32×, symbolic regression141.05×,
edit distance509.53×, ray tracing523.80× and Mandelbrot1391.14×. Tiny mixed tests
are55.35–107.32×. HVM's whole process is200.93ms versus69.21ms,2.903×. The scopes
remain separate; no production-average, native-output or compiler-throughput claim.

All four cases with repeated within-block drift receive a prospectively defined
longer-warm follow-up using identical bytes/inputs: Mandelbrot1271.44×, tree
sorting100.38×, morning60.60× and Map/Set82.37×. Residual drift remains in sorting,
Map/Set and one morning sample; neither protocol proves steady-state convergence.
All 150 timed samples and56 check/calibration processes are retained and independently
audited. Original library screen816.11s; follow-up189.32s. Both rejected Nat wrappers
and the incorrect CommonJS filename remain in the capsule with their failures.

**Updated frontier:** large emitted-program gaps persist beyond diagnostic kernels.
Test saturated private workers across matches, primitive inlining and direct native
constructor/match lowering as separate ablations. Static inspection observes generic
dispatch/allocation boundaries but does not assign their shares of the slowdown.
Both outputs already have tail-jump machinery and native strings. Preserve partial
application, argument demand, forcing and stack behavior; validate on small focused
cases before repeating this more expensive algorithm suite.

## Phase29 — generated-program fast loop and guarded lowering

[Design](../design/phase29/generated-program-fast-loop.md),
[private worker amendment](../design/phase29/private-nat-worker.md),
[evening follow-up](../design/phase29/evening-warmup-followup.md),
[report](../implementation/phase29/generated-program-fast-loop.md),
[reproduction](../implementation/phase29/README.md).

Promote checked attempt04: API10510efd, checked parent37218b8a, source191df20c,
unchanged runtime40823818 and pin0187512. Two guarded JS emitter rules expose
54 native scalar operations and supported Nat countdown loops. Public partial
application, evaluation order and representations remain.

The real helper fixture improves3.65× in longer-warm confirmation. The paired
screen takes4.706s end to end; build+36focused checks33.341s and fixture emission
4.825s make a roughly43s checked edit loop before additional feature controls.
Full final three-output integration takes22.0 minutes and is reserved for this
boundary. Original algorithms improve1.24–2.94× in the original window, still
89–465× TypeScript. Longer-warm Mandelbrot improves2.695×; sorting1.063× remains
drifting. Evening regresses27.4% in the short window but improves1.167× with longer
warmup; both persist. HVM process medians196.86→198.39ms have overlapping ranges,
so no whole-process gain is claimed. Ordinary compiler throughput is not renewed.

Independent semantic controls and fresh36focused/15JS/23library127point/original
11program/component22 scopes pass; counts overlap. Independent measurement audit
passes601 processes/429 timed observations across all windows and checks summary
aggregates. Primitive/worker guards include native identity, arithmetic bounds,
partial ABI, argument demand, closures and50,000 iterations.

Failed02 source syntax,03 recognizer stack overflows, the first audit combiner's
warmup-field comparison and the first CLI smoke expectation remain in evidence.
Explicit kc branches repair eager && recursion; the small witness discriminates
old/new. All eight previously valid original emissions remain byte-identical
after repair. Canonical source16,207physical/13,839nonblank lines,64modules,
1,762defs,640laws,68types: +263lines/+36defs, two concepts, no new IR/runtime helper.

The next measured direction is a general private saturated worker across the
edit-distance record/tuple cell chain, retaining project/build/array behavior
initially. Static inspection identifies remaining generic boundaries without
assigning runtime shares. Full backend conformance and TypeScript-speed parity
remain unestablished.

## Phase30 — direct generated code (started2026-09-30 07:28 UTC)

The user authorizes at least seven hours of sustained optimization.
[Prospective design](../design/phase30/direct-generated-code.md) freezes baseline,
semantic boundaries, performance protocols and promotion gates before compiler
edits or new timings. Start at77aecb2; preserve103 unrelated files. Three agents
independently prepare a private-call prototype, semantic counterexamples and
paired generated-code inspection. Root owns the general implementation and
measurement coordination. No performance result or promotion yet.

### Phase30 first mechanism checkpoint

Private edit-row prototype confirms1.379×; live-replacement guard version1.287×,
with an explicitly narrower immutable-descriptor contract. Retain firstcold-path
ordering failure and short-window drift. Owned non-tail argument vectors confirm
1.1367× on the prior scalarfixture. Implement the latter in checkedattempt01;
36focused/120oracle/22independent ABI observations pass. Installedrelease stays
Phase29 pendingintegration. Separate exact-arm and once-per-scalar-loop dependency
guard experiments are prospective. No wholecompiler or native speed claim.

### Phase30 guarded region checkpoint

Actual checked owned-vector output confirms1.13325× on the helper fixture.
Exact constructor-arm saturation confirms1.02321× on the complete-state edit
row. The closed scalar region confirms2.679× on original Mandelbrot bench(0,0),
while per-call guards regress53.8%. Both guard frequency and eliminated-call
scope differ, so this is not a pure guard-frequency attribution. A separate
private-row V8 diagnostic profile samples43.5% in apply/force/call and2.6% in
GC; named frames are not a universal cost decomposition. Retain every window.

[General scalar-region plan](../design/phase30/scalar-region-compiler.md)
freezes compiler admission, snapshot guards, private expression nodes, unchanged
fallback and validation before implementation. Prefer existing KTerm/JS emission
over retargeting C-specific NIR. Independent reviewers cover purity, metadata,
forward references and type-preserving private lowering. Phase29 stays installed.

### Phase30 semantic correction and rejected micro-optimizations

Attempt03 passes its selected checks against Phase29, but comparison with the
pre-worker emitter finds five inherited scheduling/self-binding failures.
The corrected design admits only pure graphs, guards the recursive owner,
requires exact runtime entry and retains the original generic fallback. It
does not inherit the old loop as fallback. The exact-arm extension is withdrawn:
three enclosing-application counterexamples outweigh its small measured gain.

Long-window array-call ablation rejects per-call guards (33.7% slower on the old
row and43.2% slower after private helper lowering). Immutable native bypass saves
only about6–7%; it is not a public-ABI-preserving production candidate. A private
Number countdown gives only1.052× over BigInt with slightly overlapping ranges
and residual BigInt warmup drift; defer that representation rule.

The bootstrap error formatter previously made one source error look like a
120-second compiler timeout. A bounded structural diagnostic returns in1.836s;
eight initial and four follow-up controls pass. Successful output is byte-identical
on the checked control. Attempt04 successfully bootstraps current source, then
the provenance gate correctly refuses the changed recipe hash. Review that exact
recipe separately and preserve historical replay. No new release is installed.

### Phase30 direct lexical helpers and nested loops

Attempt07 passes the selected broad integration gates, including the retained
erased-let admission adaptation with unchanged runtime oracles. Actual helper
output confirms10.45× over Phase29, from0.394653 to0.037776ms, still22.13× pinned
TypeScript at the same128-iteration point. This is generated-program execution,
not compiler throughput.

The isolated dictionary-to-lexical helper change confirms3.757× with disjoint
ranges. Callback implementation hoisting and fusion show no meaningful warm gain;
retain their overlapping ranges and first-call observations. The profile's large
enterExact sample attribution therefore does not establish token-check cost.
Attempt08 implements lexical spelling with injective codepoint identifiers and
passes actual emission/name/ABI controls. An initial malformed synthetic name
fixture remains preserved before its corrected native-owner setup.

The nested terminal-record prototype confirms8.161× on a complete histogram
chunk and1.639× on original small Mandelbrot. Attempt09 implements that grammar
using existing state and loop emission; its actual200 histograms/129 boundaries
and independent41 admission books/88 executions pass. Instrumented chunk generic
calls fall2242→3 while the delayed record build remains. Actual output timing is
pending confirmation; isolated prototype results are not release claims.

The exact-entry method-read ablation removes redundant reflective checks and
passes scoped getter/error controls. Its initial original edit-distance screen
suggests7% but costs199s because a call lasts2.4s. Move confirmation to a row
microcase; never apply the100-call long-warm floor to that original workload.
Ordinary scalar root regions and F32 coverage remain separately frozen trials.
Installed compiler stays Phase29 until the combined promotion gates finish.


### Phase30 ordinary roots and private scalar trees

The actual lexical helper confirmation measures39.6× over Phase29,5.86× TS;
actual terminal09 measures38× on a complete chunk and1.79× on original small
Mandelbrot. Ordinary11 confirms1.375× over terminal10 on that original point.
Its admission, numeric and ordered public-boundary controls pass. A terminal
counter adapter initially selected an already-optimized baseline but expected
an old internal bounce; the unchanged failed receipt and corrected baseline run
are both retained. No source fix was needed for that harness expectation.

The strict scalar binary-tree prototype confirms15.6× over actual10 on original
small Mandelbrot, with repeated whole-point warmup drift retained explicitly.
The depth5 microcase is21.7× faster with mostly stable timed halves. A prospective
production design reuses region analysis and adds one private DFS continuation
shape, preserving public fallback and bounding its depth. Attempt12 passes all36
focused gates; actual tree controls and independent refusal tests are pending.

The F32 acyclic-root guard regresses both hit and miss microcases by2.9–7×.
The corrected exact-arm retry passes semantics but regresses28%. Both remain
out of production. Number counters confirm only5.4% lower time and remain
deferred to avoid another representation mode. Exact method-read cleanup has
an encouraging row signal but unresolved baseline drift. Installed release stays
Phase29 until the combined image, broad gates, measurement and installation.

## Phase30: actual tree confirmation and residual probes

Actual12 passes the combined focused, selected upstream, primitive/worker,
23-library, real-component and HVM gates. A fresh checked-source fixture adds
270 Bool/Nat tree points across TypeScript/actual11/actual12, 11 admission/refusal
assertions and six ordered mutation observations. Original ten libraries compile
and return exact results. Full frontend renewal and original timing remain pending.

The separate15-second-warmup original Mandelbrot comparison confirms
3.614043ms→0.267604ms for actual11→12, a13.505× gain; TypeScript is0.045645ms.
Three-process ranges are disjoint and timed halves stable in that window. Earlier
three-second drift remains retained. A tree-frame storage ablation then confirms
0.266169ms→0.244705ms (8.06% less time), cutting255 allocation pairs to8. Its
small production emitter patch is applied and awaits a fresh checked build.

Private helper const/arrow bindings show no useful screen improvement and stay
out of production. Replacing exact-entry objects with scalar runtime slots gives
a3.2% scalar gain but a4% row median regression with drift; it remains deferred.
The closed owned-row ladder passes full-state, alias and ordered host controls;
its1.52× screen gain has substantial drift and awaits confirmation. A general
local-container proof is documented, not implemented by recognizing this fixture.

### Phase 30 — settled frame, owned-row and private-Let follow-ups

The [closed owned-row ladder](phase30/P30-020-closed-owned-row.md) confirms
1.60× on its complete row32/seed17 fixture: generic 0.588137 ms versus private
row 0.367874 ms, with unchanged storage effects and full-state/alias/public
controls. TypeScript 0.008413 ms leaves a 43.7× gap there. This is a disposable
closed scalar-input experiment, not a general compiler ownership extension.

[Native calls inside the same region](phase30/P30-021-owned-native-dispatch.md)
then confirm 1.082× incrementally, 0.368370→0.340405 ms, with disjoint ranges.
Generic setup, projections, copies and force counts remain fixed; generic apply
falls 794→630. The full ladder is 1.759× generic but still 40.6× TypeScript on this
fixture. Independent review retains a real Array.prototype getter that mutates
umin inside the old standard-Array domain. The new variant rejects those hooks
at the outer boundary and matches generic behavior. No production promotion.

[Private frame reuse](phase30/P30-022-private-frame-reuse.md) is implemented in
checked13. Fresh actual-output oracles, ordered host/depth controls and repeated
traversals pass; complete module differences are restricted to intended push/pop.
Fresh frame/argument pairs fall 255→8 for original Mandelbrot. Its separate
15-second-warmup actual12→13 comparison confirms 0.263759→0.246737 ms, 6.45%
less time, with disjoint ranges and small drift. The earlier 8.06% prototype
window stays separate. A sandbox ENOSPC event prevented one oracle launch before
process creation; its receipt is retained, followed by parent-verified duplicate
temporary-file recovery and successful fresh acquisition.

[Private helper Let statements](phase30/P30-023-private-let-statements.md)
confirm 0.267175→0.237970 ms on original Mandelbrot after 15-second warmup,
10.93% less time, with disjoint ranges and less than 1% half drift. The proposed
maintained rule adds one small statement-return emitter reusing existing Let
helpers. Checked14 passes its independent actual-output structural, numeric and
public-boundary gates. The separate actual13→14 long comparison confirms
0.246549→0.215416 ms, 12.63% less time, with stable, disjoint samples; pinned
TypeScript is 0.045613 ms in that same window, leaving 4.723×. This is original
Mandelbrot execution, not a generated-program average or compiler checking cost.
The separate generic tail-Let experiment must pass its own scheduling/closure
controls and warmed measurements.

[Private helper hoisting](phase30/P30-024-hoisted-private-helpers.md) does not
survive confirmation: baseline 0.265628 versus hoisted 0.270437 ms, overlapping
ranges and 1.81% slower median. Its encouraging short screen remains in the
record. Defer the 90–160-line implementation despite smaller generated modules.

**Updated frontier:** prioritize the small confirmed private-Let implementation
and its checked-image validation, then the separately scoped general tail-Let
experiment. Keep owned local-container regions as evidence-backed research,
not benchmark-specific compiler admission. Phase29 remains installed pending
combined conformance, original-program timings, ordinary compiler-cost checks
and release. Ratios from distinct inputs/windows must not be multiplied. No
new whole-compiler throughput, full-backend conformance or fixed-point claim.

### Phase 30 — freeze the release candidate after the guard decision

The final bounded [complete-guard allocation trial](phase30/P30-025-guard-fixed-lists.md)
preserves every metadata read, predicate and live snapshot, with 67 independent
full reflection-order controls plus the retained core/helper/tree suites. Its
confirmed helper reduction is 4.33%, and original Mandelbrot reduction is 1.80%,
both with disjoint sample ranges. Before measuring, promotion required at least
5% helper or 3% whole reduction with no material opposite regression. Both
benefits fall short, so defer rather than relax the thresholds. The first
tooling-only parser failure and all short/warmed results remain retained.

**Updated frontier:** checked14's small private-Let emitter remains the release
candidate. It confirms a same-window 4.723× TypeScript gap on original small
Mandelbrot after substantial earlier improvements. Generic tail-Let expansion,
helper hoisting, guard allocation changes and closed local-array prototypes are
not part of this compiler. Freeze optimization variants and finish the original
program matrix, ordinary compiler-cost and conformance gates, evidence
preservation and installation. The installed compiler is still Phase29 until
those parent-owned steps complete.


## Phase 30 — complete matrix holds checked14 release

[P30-026](phase30/P30-026-complete-candidate-matrix.md) completes all 13 frozen
jobs in 1,631.07 seconds: ten original programs, the ordinary compiler check,
two-source checked-library costs and four scalar helper sizes. All output
checks pass. Original Mandelbrot improves 97.35× versus Phase29, but generic
edit-distance, lexer and ray-tracing paths regress approximately 20–24%. Several
small transfer cases have large warmup drift and remain explicitly unsettled.
Scalar8192 is 190.74× faster than Phase29 and 1.34× TypeScript time, while scalar0
pays 2.68× Phase29 time. These separate results expose coverage and fixed-entry
cost rather than supporting a universal average.

**Release is on hold.** The installed compiler is not replaced by this held
candidate. The next experiment uses newly checked Phase29/14 emissions of the
same complete-state row fixture and independent runtime-dispatch ablations.
Full medians, ranges, costs and limitations are in
[the batch report](../implementation/phase30/final-timing.md); the prior release
frontier is superseded by this observed regression and hold.

**Separately frozen checked16 renewal:** P30-026 now also records all 13 renewed
jobs passing in 1557.58 seconds, preserving the entire held14 comparison above.
The generic 20–24% regressions are recovered on edit distance, lexer and raytrace
within overlapping 29/16 ranges; original Mandelbrot retains about 100× Phase29
throughput. The registered helper at 8192 iterations is about 193× faster than 29
and 1.34× TypeScript, a scoped scaling result. RLE remains 10.30% slower, the
ordinary compiler request 3.86% slower, and several short points retain warmup
ambiguity. The [checked16 report](../implementation/phase30/final-timing-16.md)
is the canonical full table. Release remains on hold pending P30-030 and native
backend gates; this renewal is neither pooled with 14 nor an installation claim.
The separately frozen 15-second tree-bitonic follow-up retains a 4.15% regression
with disjoint ranges; the apparent transfer difference is not dismissed as
warmup alone. The separate long Mandelbrot check preserves scalar speed with
overlapping repaired15/cleaned16 ranges and no additional cleanup speed claim.


## Phase 30 — exact row identifies generic constructor dispatch

[P30-027](phase30/P30-027-generic-runtime-row.md) checks newly emitted Phase29
and held14 against five runtime/reference variants on the same complete-state
row. All 196 state observations and both 28/16/257 oracle/alias/boundary suites
pass. The short screen has severe opposing warmup drift; maintained confirmation
shows that restoring generic delayed constructor-field application reduces
checked14 row time from 0.606265 to 0.446850 ms (26.29% less), recovering Phase29's
0.450682 ms within overlapping ranges. Inline dispatch is null; fused prebinding
saves 2.32%; the independent method-read expression saves 9.68%.

The parent accepts the isolated generic runtime repair for checked integration.
No compound transformation is selected. The release hold remains until actual
emission, boundary and original-program transfer checks support the repaired
image. The complete comparison and its regressions remain immutable.


## Phase 30 — retire the redundant constructor-arm mechanism

[P30-028](phase30/P30-028-retired-arm-prebinding.md) separately checks the source
simplification after the isolated generic runtime repair. Checkpoint73912c3 and
checked16 remove64 maintained implementation lines, eight admission functions
and the prebinding-specific bridge. Shared arm typing and registered scalar
worker entry remain. Complete runtime/generated AST correspondence passes on
row, helper and original Mandel emissions; fresh callable-shape, partial/entry,
ordered public and actual-emitter arm controls pass. The selected15 upstream JS
gate and primitive/worker/corpus/component/HVM integration are renewed on16.

**Updated frontier:** the64-line reduction is established by source and checked
structural/public evidence. Fresh five-way confirmation now passes: row16
0.444585 ms overlaps repair15's0.448121 and29's0.448173 ranges, while held14 is
0.601983 ms. The full repair removes26.15% of held14 time; the overlapping
15/16 ranges provide no additional deletion-speed claim. Scalar14/15/16 ranges
also overlap, preserving the earlier private-worker benefit. Do not infer
complete backend conformance, full transfer recovery or installation. The held14
comparison and all intermediate failures remain in the record.


## Phase 30 — one bounded generated compiler passes its small oracle

[P30-029](phase30/P30-029-bounded-generated-compiler.md) performs one exact16
B1→H acquisition under the separately reviewed1200-second budget. It completes
checked emission in30.841 seconds and the full preflight/ABI/Base/small-oracle
supervisor in78.530 seconds. H creates a genuinely checked cache under its own
hash, reproduces the positive8 and negative-check observations, and emits the
same small-program JavaScript bytes as B1. This overlapped correctness work:
there is no controlled historical speedup, fixed point or full H-conformance claim.

A separately frozen small comparison of warmed H with its genuine TS-produced
parent is being prepared. It retains one warm/two timed requests per trial,
actual API-specific caches and real adapter costs; no timing or H installation
is inferred from the functional acquisition. The first preparation's pipe-capture
failure and consumed worker remain preserved. Exact phase/resource/artifact
receipts and remaining scope are in the linked record.

The separately granted warmed comparison is now complete: genuine parent median
two-call mean1460.836ms, H7609.354ms, or5.2089× for the fixed small request. All18
warm/timed output hashes pass. Parent's second timed request still improves
11.11–11.51%; H's slows4.39–5.92%, so this is not converged throughput. The
reference is the TS-produced implementation of the same Bend compiler, not the
upstream TypeScript compiler itself. Full trial/range/cache/ABI evidence is in
[the distinct cost report](../implementation/phase30/warmed-generated-compiler-cost.md).


## Phase 30 — empty registration state avoids unnecessary dispatch work

[P30-030](phase30/P30-030-registration-free-dispatch.md) preserves the selected
code read and all method/environment/entry ordering while bypassing WeakSet.has
until the first successful private callback registration. Complete AST/inverse
proofs and public/transition/scalar controls pass. A manually derived H also
passes its actual-hash Base and small positive/negative oracle; that is functional
evidence, not another generated-compiler speed measurement.

The drifting short screen is inconclusive. Frozen confirmation reduces original
RLE16 time by5.566% (.0485082→.0458081ms) and complete-state row time by5.378%,
both with disjoint ranges. Registered helper/Mandelbrot negative controls overlap
unchanged16 ranges, satisfying the prospective criteria. RLE remains3.45% slower
thanPhase29 in its same window. Root selects only the three general-flag runtime
edits for checked17; fresh actual-output and integration checks remain required
before release. The direct-only diagnostic, all earlier baselines and the two
metadata-plan failures remain retained.


## Phase 30 — current generated compiler comparison

[P30-029's actualH17 renewal](../implementation/phase30/warmed-generated-compiler17.md)
follows the checked17 output correspondence and fresh positive/cache preparation.
Its separately granted warmed-once window reports1480.712ms for the genuine
TS-produced parent of the same Bend compiler and7405.986ms for H17, a5.0016×
ratio. All18 output hashes pass. Both sides still warm between the two timed
requests: parent10.12–13.37%, H17 7.66–9.88%. This is not the upstream handwritten
compiler ratio, steady-state throughput, a fixed point, or an isolated flag
speedup inferred from the earlier5.2089× window. Original observations and
negative-gate reuse scope remain explicit.


## Phase31 — local data and recent compiler methodology

The user authorizes studying Zig and related compiler history, experimenting and
implementing further speed improvements. Installed8b16a16 is the baseline.
[P31-001](phase31/P31-001-local-data.md) starts a fresh checked17 local-data ladder
with an independent demand/alias review. A separate H17 attribution will separate
ABI work from generated compiler invocation before proposing throughput edits.
No new measurement or production promotion is claimed. The [design](../design/phase31/local-data-and-compiler-throughput.md)
keeps compiler/output speed and historical windows distinct.

P31-001 confirms private setup and separate Dp-shell gains on its small row,
with independent state/demand/alias controls. P31-002's checked04 promotes the
closed local call graph: one actual256×256pair takes61.980ms versus489.298ms
checked17 and1.235826ms pinnedTS (7.89× faster, still50.15×TS). All328,966 native
events and final arrays match. Six inherited gates pass, including23 libraries
and127points.04's smallest-entry screen shows~5% overhead with ongoing warming;
longer canary confirmation is deferred to the final candidate. Attempts01–03
retain guard/embedded-runtime packaging failures; no installed release changed.
[P31-003](phase31/P31-003-private-demand.md) next tests a bounded demand proof.


## Phase31 — close local data, then remove private administration

[P31-002](phase31/P31-002-checked-local-regions.md) extends the existing bounded
region proof to internally allocated arrays, nonrecursive records and canonical
Sigma. [P31-003](phase31/P31-003-private-demand.md) proves fully demanded private
returns and removes redundant forcing. [P31-004](phase31/P31-004-direct-private-fields.md)
retains proved input layouts for direct field snapshots. All public representations
and unsupported fallback remain intact.

The [same-window ablation](../implementation/phase31/local-data-ablation.md)
measures29.09× improvement on a complete pair and17.67× on a distinct fold.
The force-removal increment overlaps; direct fields remove62.50%/49.46% of06
time. The fold still warms. [Original transfer](../implementation/phase31/final-measurements.md)
reduces four-pair edit distance1900.375→70.817ms (26.83×), still14.28×TS.
Mandelbrot and RLE retain prior warmed performance; no universal speed claim.

The original no-material-regression criterion remains **failed**: scalar-zero
+4.01% and generic row +5.04%. [P31-005](phase31/P31-005-registration-cost.md)
reproduces96.97% of same-window row excess with one unused exact-worker
registration. [Explicit admission](../design/phase31/admission-tradeoff.md) accepts
that cost, the separate stronger-guard cost and107.77ms (+6.90%) more normal
edit-distance compilation. This is a generated-program improvement with known
tradeoffs, not a compiler-throughput speedup.

**Updated frontier:** selected07 is installed and verified; all42 ordinary/
relocated CLI checks pass. Fresh3026+196 frontend observations agree exactly.
The81-row backend pilot preserves69 pass /8 N/A /4 shared failures through an
explicit60+21 native-context retry;17 initial paired EPERM failures remain.
All required inherited and added worker/component/HVM gates pass. Independent
review verifies measurements, provenance and scoped admission. Source adds236
lines (+1.41%),34 definitions and one module, with no new type declarations.

The [release](../implementation/phase31/release-07.md) and
[capsule](../implementation/phase31/evidence/README.md) retain exact artifacts,
failed attempts and consumed tools. All 103 unrelated files remain protected.
No PR comment was posted. Next: isolate statement unpacking, then private
producer/consumer tuple fusion; their gains are unmeasured. H17 profiling rules
out another ABI cache as the leading target for its measured request, while
Zig research motivates measured representation and reuse boundaries.


## Phase32 — representation and reuse

User authorizes all four next investigations. [Design](../design/phase32/representation-and-reuse.md) freezes scope and correctness boundaries before code changes. Baseline is installed Phase31 checked07 at5f3015d. P32-001 through004 separately investigate local temporaries, structured checker calls, semantic reuse and compact analysis. No timing or promotion yet.


## Phase32 — close representation gains and reject unsafe reuse

[P32-001](phase32/P32-001-local-representation.md) promotes checked03 after three
separate checked ablations: statement unpacking, immediate typed read/consumer
bridges and private field vectors. Original four-pair edit distance improves
72.266 → 20.398 ms (3.54×), reducing its same-window TypeScript gap from 14.49×
to 4.09×. Complete pair/fold fixtures improve 3.76× / 1.98×. Mandelbrot and RLE
keep identical prior emitted bytes; all three canary ranges overlap. Fold warming
remains visible. [Measurements](../implementation/phase32/final-measurements/measurements.md)
keep compiler requests, imports and generated execution separate.

[Explicit admission](../design/phase32/admission.md) accepts 36.75 ms / 1.91%
more Mandelbrot compilation, 57 added Bend lines (+0.335%), six functions, two
private plan tags and generated-size costs. There is no general compiler-throughput
speedup or source-line reduction. The maintained compiler has 17,071 physical /
14,580 nonblank Bend lines, 1,884 definitions, 640 laws, 70 types and 66 modules.
The runtime and driver are unchanged.

P32-002's private checker projections show narrower gains but public mutation/
getter counterexamples block promotion. P32-003 preserves 22 observations with
complete event dependencies but checkpoint comparison/retention is too costly.
P32-004's scoped 4k/16k memos fail their speed gates; default-API stop-list reuse
fails an executed ownership witness. No cache or speculative new IR was installed.

**Updated frontier:** checked03 is installed and verified, with all 42 ordinary/
relocated CLI checks passing. All 14 pre-install gate groups close; 223 canonical
source identities match. Fresh 3,026 + 196 frontend observations agree exactly.
The backend preserves 69 pass / 8 N/A / 4 shared failures through an explicit
60 + 21 approved native-context consolidation; 17 original paired Clang EPERM
failures remain. The original interrupted broader run remains separately saved;
completed main/measurement work was not repeated. All inherited/library/component/
HVM controls pass within their declared finite scopes.

Heavy jobs ran serially with explicit heap, process-tree RSS, deadline and available
memory checks. Current OOM counters do not establish the server interruption's
cause. [Release](../implementation/phase32/release-03.md) and
[capsule](../implementation/phase32/evidence/README.md) retain 20,807 raw files,
including rejected and failed observations. All 103 unrelated starting files and
the previous installed release remain intact. No PR comment was posted.

Next hypotheses remain private scalar replacement and an actually owned source-only
compiler boundary; public defaults are mutable. Keep the approximately 40-second
checked-build loop and short saved-output controls before broad integration.


## Phase33 — consolidate generated-program execution loops

[P33-001](phase33/P33-001-program-loop.md) installs one documented benchmark
entry point with portable checked TypeScript/Phase32 modules, separate checked
candidate preparation, explicitly unchecked JS prototypes, named sets and
20 / 60 / 300 / 600-second ceilings. Compiler source and installed release remain
unchanged. [Design](../design/phase33/program-execution-loop.md) and
[report](../implementation/phase33/README.md) state the new protocol boundary.

All four presets complete: fast 5 in 16.39s, core 8 in 56.71s, broad 14 in 259.40s
(three roles), full 15 including raytrace in 351.07s (two roles). Fast preparation
from an existing checked attempt takes 13.53s for 3 sources; acquisition is outside
the execution budget. Full execution peaks 132.4 MiB tree RSS on this host. These
are loop-validation observations, not a compiler optimization or universal speed
claim. Same-compiler broad median ratios 0.987–1.020 demonstrate remaining noise.

Nine worker scenarios plus receipt preservation and 20 runner controls pass.
Relocation passes 30 role/points with original-repository filesystem reads denied;
manual prototype positive/negative controls pass. An intentionally short raytrace
request stops at its 20s deadline, retaining 0/1 coverage and no ratio; cleanup and
postflight checks add 0.49s. The initial restricted worker-test EPERM failure is
recorded separately from its approved-context success. All 42 checked emissions
pass a catalog/source/module identity audit. Raw data, failed controls and consumed
producers are preserved in the [capsule](../implementation/phase33/evidence/README.md).

**Updated frontier:** use the [maintained suite](../selfhost/tools/performance/programs/README.md)
before another optimization. Select the cheapest discriminating case, then widen
coverage; keep actual checked compiler acquisition and semantic gates separate.
A short screen does not establish steady state or general application performance.
All 103 unrelated files remain unchanged; no PR comment was posted.


## Phase34 — generated-program profiles and source comparison

[P34-001](phase34/P34-001-program-diagnostics.md) completes the requested diagnosis
of current generated-program execution without changing the compiler. The
[report](../implementation/phase34/README.md) links clean Phase33 results, new
CPU/allocation profiles, true AST comparison and the ranked next experiments.
Timing remains unprofiled; diagnostics have a separate explicit budget and status.

Fast exact-module diagnostics complete 30/30 in 17.98s, full corpus 60/60 in
244.88s; a real combined command passes timing and all four pair profiles in
8.69s. All 28 Python controls, 15 analyzer controls and 13 profiler scenarios plus
aggregation/preservation controls pass. The initial analyzer mapping failure and
V8 orphan-allocation failure remain preserved beside their fixes and retries.

The full raytrace CPU profile assigns 49.81% self weight to `apply`, 2.26% to GC;
lexer/symreg also retain hot generic machinery. Four raytrace selectors receive
29.92% of sampled allocation self weight. The private pair's repeated four-slot
state vector is a cheaper isolated target, supported by 65.40% allocation weight
at `cell.f4`. These are observations, not causal or promised speedups.

Fine raytrace allocation sampling peaked at 1,221 MiB. An explicit coarser 256 KiB
interval for both roles passes in 44.40s at 541.6 MiB, retaining consistent hot
owners. Other cases stay at 32 KiB. Both acquisitions remain immutable in the
[capsule](../implementation/phase34/evidence/README.md), including raw profiles,
exact consumed sources, normalized tokens and resource receipts.

**Updated frontier:** use a saved-output scalar-replacement ablation for pair/fold
first, then test finite Nat-to-F32 selectors and larger saturated call/match regions
for broader transfer. Retain historical guard regressions and public mutation
controls. All 103 unrelated files remain unchanged; no PR comment was posted.


## Phase35 — remove private representation and dispatch costs

[P35-001](phase35/P35-001-private-state.md),
[P35-002](phase35/P35-002-direct-regions.md) and
[P35-003](phase35/P35-003-private-folds.md) implement selective scalar replacement,
private counters/array access, larger finite/F32 regions, an independent bounded
purity proof and iterative closed structural folds. The
[primary literature study](../design/phase35/literature.md) maps LLVM/MLton/GHC,
stream fusion and Flambda2 ideas to local proof obligations. Broad scalar-helper
inlining regressed and was rejected. An inactive NaN guard witness caught a false
optimization success; parser/fixture/environment failures remain preserved.

**Checked09 is installed and verified**, with all 42 ordinary/relocated CLI checks,
15 postinstall audit groups and 225 canonical source identities passing. Fresh
3,026 main + 196 broader frontend observations agree exactly with retained pinned
references; backend81 preserves 69 pass / 8 N/A / 4 shared failures. All 15 owner
groups and inherited execution/library/component/HVM controls pass on the final
API. Shared failures remain failures; no full backend/GPU or new fixed point claim.

The [full15 comparison](../implementation/phase35/README.md) records pair **1.324×**,
fold **2.360×**, edit distance **1.278×**, symreg **6.865×** and ray **5.475×** gains
versus same-run Phase32, with all exact outputs. Remaining TS gaps are 3.058×,
3.497×, 3.259×, 14.021× and 54.781×. The full generic-row slowdown of 9.52% overlaps
bimodal ranges; a separate five-round check is only 0.323% slower with overlap.
Both observations remain. Fixed inputs do not define average application speed.

[Normal compiler costs](../implementation/phase35/compiler-cost.md) rise 0.72%
(pair, overlap), 8.17% (Mandelbrot), 30.09% (symreg) and 34.40% (ray), with disjoint
ranges on the latter three and retained ray drift. Source grows 979 Bend lines
(5.73%) to 18,050 lines / 68 modules; generated modules grow. The
[admission](../implementation/phase35/performance-admission.md) explicitly accepts
those costs; this phase improves output execution, not compilation or simplicity.

Final profiles complete 24/24 separately from clean timing. Allocation falls
roughly 73×/17×/8.4×/9.5× on pair/fold/symreg/ray. The
[next frontier](../implementation/phase35/profile-findings.md) is private producer
lowering (symreg generator 64.33% CPU ancestry) and safe guard amortization
(ray guards 47.24%). Pair/fold still run slower than TS despite lower sampled
allocation, so surviving loop/array operations also deserve isolated tests.

The [capsule](../implementation/phase35/evidence/README.md) streams and independently
verifies 24,717 files / 395,912,134 logical bytes into two volumes / 52,475,156 compressed
bytes. Capture peaks at 65.6 MiB RSS. All 103 unrelated starting files remain unchanged
and unstaged. No PR comment was posted. The original sandbox EPERM and audit
historical-path error remain beside explicit successful successors.

**Updated frontier:** keep the 42.5-second checked build and 23-second focused
execution screen; use original programs as transfer gates. Preserve public
mutation/reentry/demand controls when expanding private regions. Reduce
unproductive analysis and unused workers only with independent compile/size
measurements and complete semantic evidence.


## Phase36 — amortize pure guards and lower private producers

**Checked03 is installed and verified**, with 42 ordinary/relocated CLI checks,
15 inherited postinstall audit groups, seven new owner groups and 226 canonical
source identities passing. Exact frontend and backend outcomes remain unchanged;
shared failures retain their verdicts. [Release](../implementation/phase36/release-03.md).

[P36-001](phase36/P36-001-scoped-guards.md) and
[P36-002](phase36/P36-002-private-producers.md) retain whole-root scoped guard reuse
and ordered private tree producers/selectors. Error callbacks and native arrays
exposed unsafe earlier proof boundaries; corrected controls and failed attempts
remain. [P36-003](phase36/P36-003-analysis-preflight.md) rejects the low-yield compiler
preflight. [P36-004](phase36/P36-004-exact-entry.md) rejects the additional
reflection shortcut after an overlapping 0.234% slowdown. No rejected patch is
in the selected source.

The unchanged full15 comparison measures **3.653× symreg and 2.319× ray gains**
versus same-run Phase35, with remaining TS gaps **3.834× and 23.473×**. Other
points overlap; map/set's +3.190% full-run median becomes −0.523% in a separate
same-protocol follow-up, also overlapping. Both remain. The
[execution report](../implementation/phase36/execution-findings.md) keeps all
samples; thirteen emitted program suffixes are byte-identical.

Normal checked request medians change −1.56%, +0.42%, +4.50% and +4.02% on
pair/Mandelbrot/symreg/ray, all with overlapping ranges. Source adds 124 Bend lines
(0.687%) to 18,174 lines / 69 modules, with no new types or laws. These accepted
costs are separate from runtime gains. Final profiles confirm ray guard ancestry
50.12→0.44% and symreg producer ancestry 63.92→12.30%; sampled allocation also
falls, with explicit diagnostic limits.

**Updated frontier:** private finite sums/tree-to-tree operations for the large
lexer/tree gaps, remaining symreg guard boundaries, and ray's generic geometry/
result calls. Use narrow falsifiable ablations first; profile ancestry is not an
additive speedup estimate. Keep the 42.3-second checked loop and 8-second actual
symreg screen. Full report, raw evidence capsule and next steps are in
[Phase36](../implementation/phase36/README.md). All 103 unrelated starting files
remain protected. No PR comment is posted.


## Phase37 — expand program coverage before another backend pass

[P37-001](phase37/P37-001-coverage.md) freezes 45 points/23 sources before compiler
changes: historical 15, 14 input variants and 16 points across eight new families.
Three families/six points remain out of tuning until the final candidate is frozen.
Both reference compilers check 23 sources; final candidate/TS correctness passes
154 observations (45 points + 32 small controls, two roles).

[P37-002](phase37/P37-002-finite-sum-workers.md) retains bounded finite selectors
inside complete private proofs. A broader first candidate opened 1,968 tiny scopes
and regressed active ray 35.6%; scalar-only selectors no longer justify new roots.
[P37-003](phase37/P37-003-guarded-conversion.md) removes generic F32 conversion
calls inside an existing region. A checksum-only success missed host callbacks;
18/22 adversarial DataView observations failed before the guard correction.
Final emitted-code owner groups all pass, including deep tail cycles and aliases.

**Checked03 is installed and verified:** 42 ordinary/relocated CLI checks,
15 postinstall audit groups, 227 canonical files, 15 Phase35 owner groups, seven
Phase36 groups and three new groups. Frontend 3,026 + 196 exact observations and
backend 69 pass / 8 N/A / 4 shared
failures retain their scopes. The first inherited-owner closer failed historical
catalog path resolution after all controls passed; its independently reviewed
successor preserves 43 original assertions and verifies 678 files/15 Git blobs.

The [45-point comparison](../implementation/phase37/execution/report.md) retains
669 samples over 1,056.320 seconds. Numeric gains are 2.674×/5.165×; tree gains across
three sizes 1.165–1.270×. Four disjoint slower points remain: symreg +1.63%, smaller
lexer +1.78%, active ray 256 +3.58%, list 512 +4.65%. Heldout paired penalties and large
record 256 tails are preserved. BST remains 152–209× TS, map 91–106× TS; no average
application or parity claim. All 24 separate profiles pass; sampled numeric/tree
allocation falls about 71%/31%, while list/ray is roughly unchanged.

[Admission](../implementation/phase37/performance-admission.md) accepts normal
checked-request costs +2.47% local / +6.40% tree / +1.06% numeric and 184 added Bend
lines (+1.01%) to 18,358 lines / 70 modules, with unchanged 71 types / 640 laws. This is a measured
execution tradeoff, not compiler throughput improvement or source simplification.
[Release](../implementation/phase37/release-03.md) and
[capsule](../implementation/phase37/evidence/README.md) bind artifacts and failures.

**Updated frontier:** isolated saturated dispatch/matching in map/lexer and a
reusable recursive tree component after a second shape validates the mechanism.
First investigate inactive-branch/module-layout costs; do not weaken mandatory
host guards. Keep 20/60 second focused execution screens, reserve the 17.61 minute
suite for acceptance, and separate build, compilation, profiling and timing.
Former holdouts are now exposed; freeze new families before another tuning pass.
All 103 unrelated starting files remain protected; no PR comment is posted.

## Phase38 — compiler research collection and mined proposals (2026-10-01)

User request: research other compilers, including Bend's TS backend, write a
large document collection, and rank promising ideas with gain/risk estimates.
The [collection](../design/phase38/README.md) contains 19 design documents and
12 studies, with versioned sources, current evidence, architecture, estimates
and a prospective experiment queue. Three agents researched disjoint compiler
families; root added pinned TS/Koka/Chez inspection and integrated the ranking.
[Report](../implementation/phase38/README.md) and
[independent review](../implementation/phase38/review.md).

**No compiler change or new benchmark result.** Installed Phase37 checked03 and
upstream 0187512 remain selected; closed evidence is unchanged. Main conclusion:
preserve callee/arity/demand/shape/control facts across a useful private component,
initially keeping tagged data. Cheap counter and ray-scope probes precede broader
workers; known callbacks precede fusion; allocation elimination precedes reuse.

Conditional forecasts versus current eligible workloads: 1.1–1.5× numeric from
a private Number countdown, 1.15–1.5× active ray from scope amortization,
1.5–2.5× tree from direct recursive workers, 1.5–3× selected list/closure work
from known callbacks. Fusion's 1.2–2× screening range instead uses a future
direct-unfused comparator. None is measured or additive; no parity forecast.
Numeric already has one outer guard and is not an established scope-amortization
target. Public host mutation, reentry, demand/error order and stack contracts
remain mandatory. Shared-fact simplification and compile-cost recovery are
unmeasured hypotheses, not achieved reductions.

The collection is linked from README. Local documentation/source-identity checks
and protection of all 103 unrelated files pass. No build, target execution,
optimization, external compiler benchmark or PR comment was performed.

## Phase39 — research recommendations implemented and installed (2026-10-01)

The [prospective design](../design/phase39/README.md) and portable checked Phase37
baseline were committed before source promotion. Four changes survive actual
checked-emission controls: private scalar Number countdowns, reused whole-root
proof scope, two-child structural frames and unary producer frames. A genuine
callback fixture rejects the slower specialization prototype; no fusion or new
runtime is retained. [Report](../implementation/phase39/README.md),
[findings](../implementation/phase39/findings.md),
[release](../implementation/phase39/release-05.md).

**Checked05 installed:** API04d9ebf4…,42 ordinary/relocated CLI checks,15 post-install
audit groups and227 canonical files pass. All 15+7+3 inherited and4 new semantic
owner groups close, plus154 application executions. Frontend3,026+196 exact
observations and backend69pass/8N/A/4shared failures keep their original scope.
No new self-emitted fixed point, full backend/GPU or proof-validity claim.

[Execution](../implementation/phase39/execution/report.md):45points/23sources,
669 primary samples /1,076.213seconds plus60 separate confirmation samples.
Changed-module gains versus fresh Phase37 are expression4.46–8.05×,
active-ray2.62–2.87×, tree1.76–2.25×, symreg1.75–1.83×, numeric1.07–1.22×.
All selected gains retain ranges and drift. Generic-row costs0.97% primary /
1.66% confirmation (five paired losses each).23points have identical old/new
JavaScript; even their large apparent changes cannot be compiler effects.
Map/BST still have very large TypeScript gaps. No pooled ratio or typical-program
claim. All42 separate profiles pass; sampled allocation reductions on changed
paths are about50/60/79/83% for tree/ray/numeric/expression.

[Compiler cost](../implementation/phase39/compiler-cost.md) reproduces27 checked
emissions exactly. Tree request time rises3.50% with disjoint ranges; local−1.60%
and numeric−1.68% overlap. These requests remain5.05–5.98×TS. Source grows364lines
(+1.98%) to18,722lines/70modules/2,087definitions; runtime/types/laws unchanged.
This is a selected execution improvement with explicit costs, not simplification.
The [portable loop](../selfhost/tools/performance/phase39/README.md) provides
20/60/300/600-second case selection; five-point smoke passes in17.444seconds.

Preserved failures include missing worker declarations in checked02/03, fixture
admission mistakes, inherited scalar-counter expectation, distinct TS receipt
schema/bootstrap relative paths, and sandbox-denied Clang smoke. Reviewed
successors keep semantic assertions and byte provenance; unchanged smoke retry
passes42/42. [Closed evidence](../implementation/phase39/evidence/README.md)
retains failures and successful final-image data. All 103 unrelated starting
files remain unchanged and unstaged. No PR comment is posted.


## Phase40 — direct components installed (2026-10-03)

The [prospective design](../design/phase40/README.md) uses compact Sol6.1 medium
mechanism owners, a low-effort evidence owner and serial root execution. Lists,
trees and lexer receive mechanism experiments before compiler promotion.
[Report](../implementation/phase40/README.md),
[release](../implementation/phase40/release-06.md),
[admission](../implementation/phase40/performance-admission.md).

Checked06 is installed: 42 CLI checks, 15 postinstallation audit groups and 227
canonical source pairs pass. Frontend 3,026 + 196 observations match; the
backend retains 69 pass / 8 not applicable / 4 shared failures within its
original scope. The 154 application observations and all inherited/new owners
close. No new fixed point, full backend/GPU or independent proof claim.

Actual direct-unfused lists improve 9.973× / 13.113×; trees improve 1.829–2.176×
over Phase39. Final 45-point evidence explicitly selects 42 byte-identical
checked05 rotations plus three fresh checked06 ray rotations, totaling 669
selected samples. All original ratios, ranges and drift remain intact. Thirty
final points equal Phase39 bytes; shifts are controls. The smallest Mandelbrot
point's 9.68% slower median overlaps ranges and remains disclosed. The 2.426×
ray regression of checked05 was rejected: checked06's Nat admission for data
results preserves existing scalar islands and restores complete Phase39 ray
bytes.

All 36 checked requests match expected bytes, but tree/list request medians cost
24.45% / 19.09% more (disjoint ranges); local +18.44% is noisy, numeric flat.
Four-source requests remain 4.66–8.37× TS. Source grows 141 lines / 17
definitions to 18,863 lines / 2,104 definitions, with 70 modules, 71 types, 640
laws and runtime unchanged. All 18 separate profiles pass; per-call sampled
allocation falls 81.8% for list512 / 46.9% for tree8. These are execution gains
with explicit compiler/source costs, not a simplification claim.

Preserved failures include incorrect List admission metadata, checked04
saved-child emission, checked05 ray selection and inherited
counter/decoder/entry diagnostic assumptions. Their reviewed successors retain
semantic assertions, exact selected emission and successful resource/provenance
checks. Lexer remains a roughly 2× manual prototype, deferred pending wider
String/Char/Sigma proof support.

**Updated frontier:** recover compiler analysis cost; prove one lexer component;
follow tree residual dispatch and Map/String/BST hotspots. Use the new direct
unfused list denominator for future fusion. The portable fast-five check passes
in 20.36 s using the 20-second preset; a checked build plus 36 probes takes
45.845 s. No PR comment. The 103 unrelated files remain unchanged/unstaged.
[Evidence](../implementation/phase40/evidence/README.md) and
[workflow](../implementation/phase40/workflow-findings.md) separate
interruption, recorded jobs and model-attribution limits.

## 2026-10-03 — Phase41: guarded wrappers and bounded validation

Promote checked01 with a documented compiler-cost tradeoff. Three tree points
improve1.506–1.592× over Phase40 and remain9.33–12.18× slower than TS;42/45
modules are unchanged. Source adds35 lines/four definitions. The normal tree
compilation request costs9.46% more; no compiler-throughput gain is claimed.
All 15 final audit groups and42 CLI checks pass. Frontend retains all3222 exact
observations and historical shared failures; backend status is unchanged.

Reject transfer-tuple scalarization after a null timing result. Defer lexer
admission after a native String-hook counterexample. Preserve five failed jobs,
one checked build, all final timings/profiles and independent reviews in the
[closed report](../implementation/phase41/README.md). The fast portable preset
passes in17s. Raw campaign closure occurs at78m16s, including34m03s recorded tool
intervals; [accounting](../implementation/phase41/accounting.md) keeps residual,
preservation and publication separate.

**Updated frontier:** profile and reduce repeated compiler planner work, then
isolate remaining tree dispatch/allocation. Require a cheap falsifier and actual
checked emission before another broad integration. Current
[steering](STEERING.md) and [portable loop](../selfhost/tools/performance/phase41/README.md)
replace Phase40 as the starting point; all historical evidence remains retained.


## 2026-10-03 — Phase42 checkpoints, final admission pending

The [roadmap](../design/phase42/README.md) and plan commit ef83a07 precede source
changes. Checkpoints c7165a6,d20232c,929445e,7d9424a,3b64bc5 preserve the evolving
source and evidence. Phase41 remains installed while the Phase42 survivor is
qualified. Seven mechanism/review/documentation agents share static work; root
serializes heavy compilation, semantic jobs and timing under resource caps.

Actual outputs retain inherited direct calls, owned constructors, request-local
planner facts, private flat graphs, total list fusion, exact native List/Sigma
proofs and sequential traversal. Checked13 BST screens improve14.9–28.7× over
checked07. Actual bounded recursion adds1.37–1.61× to checked14 tree output while
retaining the iterative fallback; the larger tree is1.22×TS in a short screen.
Checkpoints04/05 contain points, samples, ranges and comparator identities.
No final 45-point or global parity claim is made yet.

Native-constructor literals win1.3–1.67× in the last BST discriminator; checked15
source qualification follows. Transfer arrays add no benefit; Map.bit's isolated
dispatch prototype is30–44% slower despite passing controls. Preserve failures.
Pre-import hooks expose actual universal-equivalence failures; subsequent review
found the standard-at-initialization contract published before this phase. Keep
that scope correction and unchanged mandatory post-import/Error boundaries.

**Updated frontier:** freeze the actual survivor, run all semantic owners, three
serial full 45 timing batches (669 samples), compiler cost, profiles, installation
and evidence closure. Checked13 tree compilation improved10.03% but list costs
12.03% more; assess the final image and record tradeoffs. Source growth and all
remaining TS deficits remain explicit. No PR comment is posted.

## Phase42 final release — 2026-10-03

Checked16 installed and qualified; see the [report](../implementation/phase42/README.md).
All 45points/669samples pass. Equal-point geometric slowdown12.57→8.86×TS;
source-weighted15.40→11.42×. Tree6.27–8.02×, BST23.66–26.96× and list2.72–6.65×
gains over Phase41; onlylist512beatsTS among45points. Overall parity remains
unreached. Mixed compiler cost and+1158source lines are explicit tradeoffs.
All 15postinstall groups,227bindings and42CLI checks pass. Seven owner/review
roles worked in parallel while root serialized heavy jobs. Failed probes, scope
repairs and final raw receipts are preserved; no PR comment posted.

## Phase43 final release outcome — 2026-10-04

Checked14 is installed after selected-image admission. All 34 mechanism owners,
42 CLI checks, 15 postinstall audit groups, 227 source bindings and the 41-group
composite installed closure pass. Phase42 checked16 is retained as baseline;
the [portable current bundle](../selfhost/tools/performance/phase43/current/manifest.json)
is complete, with all 45 points frozen and reopened byte-exact. Compact20,
full-fast60 and targeted60 smoke replays pass; raw writers are closed and all
35,665 raw files are archived and reopened with exact hashes.
The [report](../implementation/phase43/README.md) links actual-source controls,
[final results](../implementation/phase43/results.md) and profiles. Raw selected
runtime closure is [integration01/runtime-full45-close.json](../selfhost/build/phase43/integration01/runtime-full45-close.json);
[final-results01/report.json](../selfhost/build/phase43/final-results01/report.json)
retains all 45 points, 23 sources and 669 fresh role samples.

Equal-point geometric slowdown improves 8.875959→6.161075× pinned TypeScript time,
a 1.44065× gain over the fresh Phase42 baseline. Medians improve on 25 points and
regress on 20; two beat TypeScript. Lexer, Map-churn, closures and BST family gains
are 12.2953×, 3.61984×, 9.43965× and 2.48645×. This is a regression corpus used
during optimization, not universal parity or untouched holdout validation.

Delivered mechanisms are complete typed String graphs, lexical contextual Map
calls with conservative primitive identity fences, callback construction/application
fusion that removes the unescaped environment graph, bounded Number countdown
with original BigInt fallback, and private pair state with original scalar-worker
precedence. Failed source ABI/parse/purity probes, eager-recursion compile blowup,
Map continuation defects and narrowly reviewed controller repairs remain retained.
[P43-001](phase43/P43-001-strings.md), [P43-002](phase43/P43-002-map.md),
[P43-003](phase43/P43-003-products.md), [P43-004](phase43/P43-004-callbacks.md)
and [P43-005](phase43/P43-005-guards.md) link outcomes; P43-006 remains proposal only.

The maintained graph grows 1,384 lines/164 definitions to 21,440 lines,
2,413 definitions and 70 modules. The [normal checked-library cost report](../selfhost/build/phase43/integration01/compiler-cost/report.json)
passes all 36 requests but candidate request medians increase 8.72% local-pair,
21.14% tree, 14.01% list and 0.76% numeric; candidate requests remain 4.92–8.68×
TS across these four sources. No compiler-throughput or source-simplification gain
is claimed. Full-source acquisition additionally records Map compilation
2.302s→9.450s (4.105×) and module growth 2.216×, plus lexer compilation 1.715×.
Runtime and compiler costs are separate evidence.

**Updated frontier:** release closure is complete. Next investigate
[P43-006](phase43/P43-006-nullary-entry.md) with ordinary-entry and private-worker
activation counters before any new proof grant. It remains a proposal without an
executed prototype or causal speedup. Planner cost and residual Map/String/allocation
remain subsequent investigations. Preserve the 103 unrelated files and Phase42
evidence; no PR comment is posted. Current [steering](STEERING.md) records installation,
the verified portable bundle and remaining smoke/evidence closure. The [raw installed composite](../selfhost/build/phase43/integration01/composite-postinstall/report.json)
binds the successful selected-image closure.


## Phase44 final release outcome — 2026-10-04

Checked04 is installed and verified; all 42 ordinary/relocated CLI checks pass.
The [report](../implementation/phase44/README.md) records the typed ordinary runtime
IR and its separate lowering, lexical facts, transformations and emission modules.
Fifteen old helpers are removed. The migration remains partial at private layouts
and source-dependent guarded call plans. Source grows 373 lines to 21,813 lines,
2,452 definitions and 78 modules.

Fresh frontend agreement is exact on 3,026 main and 196 broader observations.
All 81 backend observations agree (69 execution passes, eight not applicable,
four shared failures); eight maintained suites and independent composition
controls pass. Shared failures remain failures; historical Phase43 owner and
composite postinstall campaigns are not rebranded as Phase44 gates.

All 45 execution points / 669 samples pass. The [full result](../implementation/phase44/results.md)
is effectively flat: 6.1214× → 6.0832× TypeScript time against freshly sampled
Phase43. Twenty medians improve and 25 regress. Map compiler requests improve
15.61%; three other probes regress 2.81–3.57%. The saved-JavaScript known-call
helper prototype is rejected after its six-point screen shows no broad gain.
[P44-001](phase44/P44-001-composable-ir.md) and
[P44-002](phase44/P44-002-known-call-dispatch.md) preserve both outcomes.

Next work should migrate call/value representations into the IR and establish
shared legality facts for allocation and dispatch removal. [Profiles](../implementation/phase44/diagnostics.md)
support investigating those costs, without proving a specific optimization gain.
The [evidence index](../selfhost/tools/performance/phase44/evidence/selected-release.json)
and [accounting](../implementation/phase44/accounting.md) retain selected identities,
failed attempts, validation scope and time use. No PR comment is posted.


## Phase45 selected release — 2026-10-04

Worker23 is installed, verified and pushed in `ab74ece`. The
[report](../implementation/phase45/README.md),
[full execution comparison](../implementation/phase45/results.md),
[profiles](../implementation/phase45/diagnostics.md) and
[portable benchmark guide](../selfhost/tools/performance/phase45/README.md)
record the selected implementation and its separate qualification boundaries.

General typed private calls, SCC partitioning, bounded native recursion with a
continuation fallback, tail loops, named fields, native constructors and exact
Number Nats reduce argument-vector and descriptor allocation. Typed root ranking
preserves better existing plans. Whole-graph primitive fences, nullary ABI
preservation, canonical Unit and inert exact-entry preflight complete the selected
changes. The backend remains partially unified; this is a checked B1 derivative.

All 45 runtime points / 23 sources / 669 fresh samples pass. Equal-point slowdown
falls **6.0867× → 3.0787× TypeScript time**, a **1.9771× speedup**. Equal-source
slowdown falls 8.2713× → 4.1467×; equal-family 8.4316× → 4.7340×. Thirty-two
medians improve and 13 regress; the largest observed regression is 4.93%.
Two points beat TypeScript. Records improve 41–43× and Map128 improves 15×.
Profiles show sampled allocation reductions of 33.07× and 10.11× respectively.
Neither this maintained corpus nor its geometric mean establishes universal
program speed or parity.

Fresh frontend agreement is exact on 3,026 main and 196 broader observations.
All 81 backend observations agree: 69 execution passes, eight not applicable and
four shared failures. Eight maintained suites, composition, seven freshly acquired
mechanism families/twelve controls and focused nullary/Unit/host-hook checks pass.
Release verification and all 42 ordinary/relocated CLI checks pass, followed by
27 fresh portable smoke samples. Four existing main failures remain shared;
a separate Number-Nat parse-diagnostic probe still fails strict comparison and
receives no qualification credit. Historical owner campaigns are not relabeled.

Tradeoffs remain explicit: source grows 1,194 physical Bend lines (5.47%) to
23,007 lines, 2,594 definitions and 85 modules. All 36 compiler-cost requests pass,
but request medians increase 8.62% local-pair, 28.55% lexer, 1.32% Map and 1.20%
closures. Runtime allocation gains do not establish compiler-throughput gains.

Rejected17b's 10.77× generic-row regression and stopped full campaign are retained.
An exact SCC profitability rule fixes that selection error; a later acyclic
readmission still regresses 5.15× and is rejected. Six post-import preflight hook
differences were reproduced on22 and corrected in23. The separate inherited
WeakSet.add observation is a static, unexecuted audit proposal. Failed fixtures,
controllers and publication preflights remain preserved with their successors.

The final [native equality study](../implementation/phase45/native-string-equality.md)
retains24/25 as **unselected prototypes**. The one-line Number-Nat admission
composition passes its expanded controls but adds no useful short-screen gain
by itself. Combined23→25 confirmation improves Map/Set 1.378×, still 41.336×
TypeScript with within-sample drift and 56.4% more generated JavaScript. Unrelated
sampled modules remain byte-identical. This narrow result is not included in the
selected45-point score, and neither prototype has full release qualification.

Next work should address private function values/closures, typed Array and result
boundaries, shared proof facts and shared private component emission. Preserve
known public mutation boundaries, the five-canary rejection loop and all failed
evidence. No PR comment is posted. Final raw writer closure and archive capture
are recorded separately in the preservation index.

## Phase46 backend investigation — 2026-10-04

[P46-001](phase46/P46-001-backend-comparison.md) completed the frozen four-way
experiment without changing the installed Phase45 worker23 compiler. The
[report](../implementation/phase46/README.md), [source findings](../implementation/phase46/source-findings.md)
and [summary](../implementation/phase46/evidence/summary.json) retain six workloads,
24 exact pure and24 final wrapper observations,96 independent input-cycle
oracles,72 checked timing samples and72 checked cold observations. These scopes
overlap; they are not a count of unique conformance tests.

Our C is1.28–5.03× slower than our JS on five workloads and roughly tied on
closures. Upstream C is2.19–19.73× faster than upstream JS; our native gap ranges
2.75–131.03× upstream C. Separate native counters show repeated small allocation,
curried-call and continuation transport where upstream retains scalar loops.
Whole-array copying is not supported as the primary cause of the array gap.
Instrumented counts are not untouched-binary allocation counts or timing shares.

Native cold turnaround/RSS improve, but checked emission plus Clang makes the
batch development loop substantially slower. The runtime also reproduces an
IO.args program-name mismatch. The common final benchmark wrapper avoids that
boundary; no native repair or broader conformance claim is made. Failed setup,
parse and argument-boundary attempts, an unavailable perf probe, all calibrations,
profiles and native counter derivatives are retained in the capsule.

**Updated frontier:** keep JS primary; defer LLVM/assembly. Test caching a proven
fresh private array's backing view/length using the existing IR and new shared
ownership/use/effect facts. Preserve host conversion, alias and demand/error
boundaries; use a saved-output causal screen before another compiler campaign.
Known-call normalization and aggregate elimination are stronger native needs.
The maintained45-point JS score is unchanged; this common Bend batch has a
separate context and input schedule. No PR comment is posted.

## Phase47 research-guided private arrays — 2026-10-05

[P47-001](phase47/P47-001-array-view.md) and
[P47-004](phase47/P47-004-private-array-layout.md) led to a closed Array<U32>
representation contract, ordered writes and consistent known-call normalization.
The [report](../implementation/phase47/README.md) connects the Go, Rust/LLVM,
Lean, Zig, V8 and upstream lessons to measured decisions. The array length cache
and invariant pointer alias added no useful gain. The 405-line worker cleanup
[P47-002](phase47/P47-002-worker-value-cleanup.md) is deferred: its small observed
gains did not remove the intended aggregates. The separate proof-query memo
[P47-003](phase47/P47-003-compiler-proof-census.md) measured 6.64% on one saved-JS
request; no production cache is shipped and its result is not combined here.

The first full array04 run exposed a private-tree composition gap. P47-005 reused
the existing checked tree emitter with the same array contract, adding 32 lines;
P47-006 retained a complete integer hook proof, including Math.floor, while
omitting irrelevant floating hooks. Independent finite controls verify aliases,
actual private entries, both tree children, zero paths, unused F32 aliases,
mutation, reentry and demand. All eight maintained suites also pass. Full
frontend and 81-backend inventories remain historical worker23 evidence.

Final array06 passes all 45 points / 23 sources / 669 fresh samples. Point-weighted
slowdown changes 3.08515×→2.91942× TypeScript (1.05677× gain); equal-source
4.16985×→3.99581×. Tree edit distance improves 1.85–1.86× and local pair 1.75×.
The large fold reaches 0.956× TypeScript, but the 128-step fold regresses 1.93×
(7.603→14.671µs). Tree-bitonic's default case regresses 4.17% despite unchanged
program-body bytes; the JIT cause is unresolved. Sixteen medians improve and 29
regress; signs do not establish statistical significance or universal speed.

Source grows 247 physical Bend lines (+1.07%) to 23,254, with 19,175 code lines,
2,622 definitions, 87 types and 86 modules. Generated libraries grow 100,476 bytes
(+2.58%). All 27 compiler-cost requests match expected output; median request
cost rises 1.21% fold /3.75% editdist /0.87% lexer. This is a speed/size/entry-cost
tradeoff, not a conformance-count, simplification or compiler-throughput gain.

The fast-loop correction is concrete: use the existing core8 screen and separate
private-entry witnesses before a full campaign. Preserve the 103 unrelated files,
all failed attempts and historical capsules. Keep JS primary; next work should
address public-entry profitability and ownership/materialization boundaries,
with shared call/representation facts rather than a larger unmeasured inliner.
Release/publication receipts and terminal closure are linked from the phase report.
No PR comment was posted.

## Phase48 selected representations and remaining frontier — 2026-10-05

RNFA04 is installed and release-verified. All 42 ordinary/relocated CLI checks
and portable replay pass. The [report](../implementation/phase48/README.md),
[complete runtime comparison](../implementation/phase48/results.md),
[static accounting](../implementation/phase48/accounting.md) and
[portable guide](../selfhost/tools/performance/phase48/README.md) bind the selected
compiler and its separate measurement scopes. The API is
`6f9d111aa68c19f3ce45b80785621d57c4d10efb12d50164f5cb0597bc952100`; the runtime
is byte-identical to array06. The upstream pin is unchanged.

The selected R/N/F/A slices preserve array handles across public composite
results, remove proved native String dispatch, specialize finite private F32
literals while retaining observable shared-view writes, and share typed Array
effects/literal-handle facts. Direct zero/one countdowns can decline the literal
path before its full guard. These are source/type-based mechanisms, with existing
selector ranking, host/dependency checks and ordinary fallbacks retained.

All **45 runtime points / 23 sources / 669 fresh samples** pass. Fresh equal-point
slowdown improves **2.9024375× → 2.6789370× TypeScript**, or **1.08343×**: 8.34%
faster / 7.70% less time. Equal-source improves 3.9789231× → 3.6792514×, and
equal-family 4.4796607× → 3.9120521×. The full three-batch protocol takes
1,132.24 seconds. Previous phase ratios are context, not pooled denominators.

Generic row improves **13.467×**, from 55.728× to 4.138× TypeScript, while checking
all four returned arrays. Unicode16/64 improve **1.257× / 1.462×**; numeric1024
improves **1.062×**. Generic row contributes **72.1% of net equal-point logarithmic
gain**; the other 44 points collectively improve **1.0231×**. This is a concentrated
benefit in a finite, optimization-informed corpus, not broad parity. Morning,
scalar-zero, RLE, Map/Set and Evening remain approximately 49–62× TypeScript time.

Twenty-three medians improve and 22 regress. Closures64 (+3.25%), lists512
(+2.49%) and tree-bitonic (+2.31%) have unchanged output bytes. Short fold has
changed output and regresses 2.12%; no executed guard cost or JIT cause is proved.
The final report retains drift and all observed regressions without classifying
them collectively as noise. Three points beat TypeScript. The separate literal
diagnostic retains **30.63% / 18.64%** zero/one-trip overhead, despite 16.372× /
71.831× gains at 128/8192; those points are not added to the primary weighting.

All focused controls and eight maintained suites pass. Fresh backend agreement
covers **81 outcomes: 69 execution passes, eight N/A and four shared failures**.
The 3,026-main / 196-broader frontend inventories remain historical unchanged-
frontend evidence. Control categories overlap; no fabricated total or newly
self-emitted fixed point is claimed. Native IO.args and broader native/GPU
qualification remain separate gaps.

The compiler grows **406 physical Bend lines (+1.75%)** to 23,660, with 19,489
code lines, 2,673 definitions, 87 types and 92 modules. Generated libraries grow
0.72% across the 24 distinct source/output pairs. All **18 compiler requests**
match expected output, but fresh request medians regress **3.274% on Evening**
and **4.411% on lexer**. That two-source compilation screen does not measure
self-compilation or establish a general compiler-throughput gain.

The RNFA02 local-row acquisition's bounded compiler heap OOM is preserved. The
successor rejects wrong call shapes before expensive normalization and completes
the same acquisition within the unchanged heap limit. Bend's eager conjunction
did not supply the presumed short circuit; the explicit branch repair retains
the intended admission contract. This failure and its correction are distinct
from successful runtime qualification, not evidence of a system/session OOM.

**Updated frontier:** prioritize a general bounded matched-family H experiment
with staged/partial captures and actual Morning entry witnesses. H02's fixture
success did not change its real corpus targets, so it remains unselected. Carry
shared effect, use, ownership and representation facts through calls and result
boundaries; test a demonstrated aggregate consumer before widening conventions.
V's scalar/vector alternatives remove constructors but fail to demonstrate useful
broad gains and remain preserved, unselected prototypes. Measure actual public
entry work before changing guards; do not cache mutable permission or omit
generic-path host observations. [Remaining opportunities](../implementation/phase48/remaining-opportunities.md)
and [steering](STEERING.md) record the next falsifiers.

Keep JS primary, exact full-output oracles, renamed controls, actual activation
counters and the nominal core8 screen before another full campaign. Preserve all
103 unrelated files and historical evidence. Final writer closure and archive
publication are separate receipts. No PR comment was posted.

## Phase49 V8-aware diagnosis — 2026-10-05

The [design](../design/phase49/v8-aware-diagnostics.md) was pushed before targets;
[report](../implementation/phase49/README.md) and
[optimizer findings](../implementation/phase49/v8-ir.md) explain the failed tuple
pass without changing the installed compiler. Retained array06 RLE is byte-identical
to RNFA04's current output. All 63 public-call jobs pass their exact result/digest;
one initial TS graph is invalid JSON and is separately retained with a complete
fresh longer-run successor. No compiler build or conformance expansion is claimed.

Fresh five-process medians are 39.343µs baseline, 39.365µs rejected values03 and
0.589µs TS. Named guards contribute 79.44%/76.55% CPU self weight. Sampled allocation
is roughly 33 KB/call, dominated by descriptor reflection. Unsafe one-condition
bypasses produce 0.804µs baseline/0.836µs candidate; String-only omission 22.370µs.
The 49× diagnostic intervention changes JIT context as well as omitted work; it
is neither a safe compiler optimization nor a new corpus/typical-program result.

Both RLE loops reach TurboFan before measurement and inline the step, with no
measured bailouts. Baseline allocation sites survive escape analysis; the pass
reduces 16→8 but adds 6 context loads / 6 stores, lexical initialization checks and
barrier paths. Code grows 2,448→2,516 B and 16→17 stack slots. With guards bypassed,
the candidate allocates 2,549→1,770 estimated B/call but is 3.88% slower. These static
mechanisms and samples constrain explanations, not exact instruction causality.

**Updated frontier:** prove smaller guard requirements from full original-source
and runtime observations; test cheaper equivalent fresh checks. Do not infer safe
String omission from dependency names or cache mutable permission across calls.
Test caller-local transport before another broad product pass. Preserve clean
counterfactuals separately from semantic qualification. Root ran 63 serial jobs,
136.81 s observed process occupancy, 205.9 MiB maximum tree RSS; measurement ended
about 14 minutes after the raw start. Source/review/docs time is separate.
The [diagnostic guide](../selfhost/tools/performance/phase49/README.md) and complete
closed evidence make these probes reusable. The 103 unrelated files remain intact;
no PR comment was posted.

## Phase50 information-only guard survey — 2026-10-05

[Report](../implementation/phase50/README.md): all 45 RNFA04 points profiled with
full result checks. Guard ancestry exceeds 50% in 11 points and is below 5% in
16. Morning/Evening have zero named-guard samples; generic application/matching
plus roughly 28–30× TS sampled allocation dominate these and much of MapSet.
Pinned V8 identifies `apply` bytecode-size inlining refusals; all six trace
measurement windows have zero bailouts. Expression transport is another distinct
cost. 63 serial jobs pass, 137.40 s target occupancy, 200.04 MiB maximum tree RSS.
No fixes, bypasses, compiler rebuilds, new clean ratios or release changes.
**Updated frontier:** distinguish guard-heavy optimized paths from generic
dispatch and materialized producer/consumer paths; investigate each independently.


## Phase51 V8-guided optimization — 2026-10-05

[Design](../design/phase51/v8-guided-runtime.md) pushed before targets as a79c114;
[report](../implementation/phase51/README.md). Installed IO-only helper plus
same-entry String-proof reuse. Batched descriptors lost; larger apply/invoke
splits displaced useful inlining and were not selected. Actual checked output
passes 33 String-boundary and 27 application observations, retained controls and
all eight maintained suites. Backend agreement is 69 passes / eight N/A / four
shared failures; only the native batch was retried after a sandbox Clang refusal.
Release verification, 42 CLI checks and 27 portable replay samples pass.

All 669 full samples pass: fresh RNFA04/TS 3.007942× → Phase51/TS 2.927825×, a 1.027364×
speedup. Historical 2.678937× is not the denominator. 34 medians improve / 11 regress;
worst regression 2.65%. Unicode gains 1.242× / 1.083×. Evening's 1.460× standard-protocol
result shrinks to 1.0477× with longer fixed-work warmup; allocation remains about
177 KB/call. Other 44 points gain 1.0192×. Source code lines/definitions unchanged,
+2 Bend comment lines and +6 runtime lines. No compiler-throughput/fixed-point claim.

**Updated frontier:** V8 traces identify opportunities, but inlining and fewer
allocations do not themselves establish a gain. Prove narrower guard requirements
or improve generic closure/constructor transport next; first use saved-output
counterexamples and clean screens. One checked build 53.48s, full45 comparison
19m03s. At the accounting cutoff 73m26s elapsed, observed process occupancy 36m02s;
other time includes code/review/docs/orchestration, not simply waiting. All 103
unrelated files and failed receipts remain preserved. No PR comment was posted.


## Phase52 direct JavaScript backend — 2026-10-05

[Design](../design/phase52/direct-javascript.md),
[report](../implementation/phase52/README.md),
[results and all-point chart](../implementation/phase52/results.md).
The prototype gate passed within one hour: eight points measured1.03522× TS
versus same-run Phase51's5.23997×. Expansion produced a Bend-written direct
backend with native callable/data layout, tail cycles, erasure/partial calls,
program output, IO and FFI. It is explicit `--direct-js`; the legacy mutable-G
contract and default mode remain available.

Selected direct06 passes all45 benchmark points and669 fresh samples. Equal-point
execution time improves **2.630605× → 1.123799× TS**, a **2.340815× speedup**.
Equal-source weighting improves3.582113× →1.129112×. Twenty-nine points lie within
10% of TS. Seven Phase51 regressions and three drift/spread flags remain in the
aggregate; two older specialized paths already beat TS. Historical campaign
ratios are not reused as denominators. Generated module bytes decrease about75%;
Bend source grows9.0% because both backends remain, adding1,746 code lines in
nine modules while preserving all92 original modules.

The atomic-intrinsic screen gains7.4%, below its prewritten10% target; retention
is explicitly a separate scoped decision. Exact byte reconstruction accounts
for375 expansions and52 wrapper removals. Computed-operand IIFEs then lose25.75%
and are rejected; the precise V8 cause is unestablished. The original incomplete
direct05 timing, parse/harness/permission failures and all rejected images remain
preserved. Direct06 is installed; release verification,42 legacy CLI checks,18 direct CLI
checks and the final3-case/27-sample portable replay pass. Sandbox Clang/Node
refusals and a test-controller output-directory collision are separately preserved
with successful retries; no compiler change was required to resolve them.

Independent semantic qualification is **95/96**, not full conformance: the NaN
source oracle40 differs from both TS1 and direct39. The direct26-row JS census
and eight maintained suites pass. Legacy core8 emits exactly Phase51 bytes and
passes its fresh120-sample gate after a separate20s budget-exhausted attempt.
Compiler throughput, arbitrary host-hook parity and a new self-emitted fixed
point are not established. Analysis limits, including512 selected definitions,
are explicit refusals. Native/frontend broader inventories remain historical.

**Updated frontier:** use ordered statement-prefix/value lowering for a small
causal arithmetic experiment; keep NaN/raw-bit and numeric-table work separate.
Investigate general reuse of legacy optimizations that already beat TS, then
scale graph analysis before compiler-sized self-emission. A narrow checked
build/emission/timing iteration is roughly three minutes of target work; full45
costs about22 minutes including acquisition. Preserve scoped correctness and
exact output checks. No PR comment was posted.


## Phase53 corrected default and ordered expressions — 2026-10-06

[Design](../design/phase53/default-direct-and-ordered-expressions.md),
[report](../implementation/phase53/README.md),
[results/chart](../implementation/phase53/results.md),
[publication](../selfhost/tools/performance/phase53/publication.json).
The compiler remains implemented in Bend. Direct JavaScript is now the ordinary
program/library/run output; `--legacy-js` and explicit API `backend:'js'` retain
compatibility. Fresh typed-array storage fixes the cold NaN payload mismatch
without changing the source golden40; pinned TS still returns1. Independent
callback controls also exposed an ordering gap. Composable statement prefixes
and pending values now follow the pinned emitter's observable ordering through
calls, constructors, lets, partial applications and true overapplication.

The separate corrected-baseline screen admits ordered02 with1.068387× speedup.
The complete same-run45-point/23-source/669-sample comparison improves
**1.129266× →1.069599× TS**, a**1.055785× speedup**. Equal-source weighting is
1.078076× TS. Fifteen points beat TS,34/45 lie within±10%,39/45 within±20%.
All12 regressions below3.4% and six timing flags remain; worst point is1.912×TS.
These are corpus summaries, not statistical bounds or universal parity.

Original source scenarios pass96/96; numeric34/34; composition18/18 and genuine
overapplication2/2; maintained census26/26 agreement and compatibility8/8.
Overlapping scopes are not summed. TS's NaN failures remain explicit. Selected
release passes42 legacy+24 default/legacy checks, relocation, integrity and
runtime-tamper controls. Installed direct-row acquisition and final portable
replay3cases/27samples pass. All135 portable mappings verify. Failed semantic
assumptions, controller/routing failures and sandbox launch refusals are retained.

Source is26,151 physical/21,523 code Bend lines (+361/+288), with two new modules
and one changed old module;100 prior modules remain exact. Four-module static
inspection finds202 primitive call sites and30 wrapper declarations removed,
replaced by256 holds. This is syntax evidence, not a proven V8 mechanism.
Selected build61.09s, peak1.513GB; causal screen57.50s; full timing18.69min.
At the explicit accounting cutoff80.13min elapsed, recorded process occupancy
was35.12min; the remaining45.01min combines development, review, docs, orchestration
and unrecorded/idle time. Packaging follows that cutoff. Targets remained serial
and memory bounded. One closed archive retains complete evidence. All103
unrelated files are preserved. No PR comment was posted.

**Updated frontier:** test general scalar numeric match tables with NaN/demand
controls; use saved-output ablation to test whether acyclic loop scaffolding
matters; replace repeated graph reachability before scaling compiler-sized direct
self-emission. Finite F32 literals are already folded; do not repeat that proposal.
Compiler-throughput parity and a new direct self-emitted fixed point are unproved.

## Phase54 backend cleanup and scalable analysis — 2026-10-06

[Design](../design/phase54/backend-cleanup-and-direct-bootstrap.md),
[report](../implementation/phase54/README.md),
[publication](../selfhost/tools/performance/phase54/publication.json).
Graph02 is installed. Thirty-four unchanged helpers now have shared semantic/JS
utility ownership, and two compiler-image callers explicitly request legacy.
All 17 native modules, both runtimes and the driver remain exact. Source grows
108 physical / 75 code lines to 26,259 / 21,598, across 107 modules; this is dependency
cleanup rather than net line reduction.

Iterative SCC traversal replaces repeated all-node closure. Independent 15 + 10
graph controls, five checked/ran source chains through 3,004 functions, and the
4,097-vertex default graph refusal pass. The production cap is 4,096. New edge
budget and previously rejected dense inputs are explicit acceptance changes.
A single cold 128-node graph observation improves 226.9 → 38.2 ms; this is not a
whole-compiler throughput result.

Source 96 / numeric 34 / composition 18 / overapplication 2 / direct 26 / maintained 8 pass.
All 45 point modules from 23 checked sources and all 33 semantic modules retain
Phase53 bytes. Three native sources retain exact C and pass six CPU runs.
Installed integrity and 42 legacy + 24 default/relocated/tamper checks pass; seven
prior-release files remain exact. The dated Phase53 result 1.069599× TS is reused
for identical executable bytes; no fresh 669-sample timing is claimed.

Restricted direct compiler transport works, including 20,000-element shared data.
Full 77 generation exceeds 240s below 864 MB RSS. Diagnostic profiling identifies
repeated constructor search beneath arity recovery, suggesting typed-owner lookup
or a checked constructor index as the next narrow experiment. Full direct image,
fresh self-check and fixed point remain unqualified. Retain legacy bootstrap.
Fixture/controller/environment failures, profile heap failure and both deadlines
remain preserved alongside successful successors. No PR comment was posted.

## Phase55 — resolve direct compiler-image timeout

[Design](../design/phase55/direct-compiler-image-throughput.md),
[report](../implementation/phase55/README.md),
[publication](../selfhost/tools/performance/phase55/publication.json).
Host02 is installed. Typed matcher ownership avoids redundant whole-book
constructor search; one completed no-Nat signature proof avoids repeated export
conversion analysis. Two source files add 27 physical / 19 code lines; all other 105
Bend modules, runtimes, native modules and driver retain exact bytes.

The old full image exceeded 240 s. Fixed-source arity01 completes in 198.49 s;
host02 completes in 96.23 s with a byte-identical 3,895,592-byte image. Its export
stage falls 121.39 → 20.92 s. Host02's own-source image completes in 103.95 s.
Both images pass 8 exact ordinary-driver requests; no fresh self-check/B2→B3
fixed point or legacy-client retirement is claimed. Times are bounded diagnostic
observations, not user-program speed results.

Final 96 source / 34 numeric / 18 composition / 2 overapplication, 26 census, 8 maintained,
33 semantic module equality, 45 benchmark point equality, 3 native / 6 CPU and 42 + 24
installed interface gates pass. Dated Phase53 runtime timing is retained for those
exact bytes. Focused arity and 8 host-wrapper controls include fallbacks and budget
exhaustion. Two harness book-event assumptions, launcher syntax failure and sandbox
child-process EPERM remain preserved with their corrected successors. All 103
unrelated files, 7 prior-release artifacts and 4,543 closed Phase54 files remain
unchanged. Source commit c192b60; no PR comment posted.

## Phase56 — dead helper cleanup, native equality and direct self-hosting

[Design](../design/phase56/qualification-and-simplification.md),
[String equality](../design/phase56/native-string-equality.md),
[report](../implementation/phase56/README.md),
[publication](../selfhost/tools/performance/phase56/publication.json).
String01 is installed. Seven unused helpers are removed; the native equality
change adds two lines, for net −40 physical / −32 code / −7 definitions. Native modules,
runtimes and typed driver retain exact bytes. The original direct image's
profile put 17.6% of ticks in String.cmp and its recursive helper. Definition-only
native equality retains the callback order that call-site expansion would change.

B1 emits B2 in 84.43 s; B2 freshly type-checks its own source in 29.68 s and reproduces
its complete 3,896,951-byte image in 250.72 s. The prior B2 exceeded 300 s. Baseline
self-check 55.84 s was profiled, selected 29.68 s unprofiled: no controlled ratio.
All 3,012 source unsafe definitions remain, causing the expected proof-trust refusal.
B2 type acceptance/fixed point are distinct from kernel validity and installed
checked B1 provenance. The source commit is 8d2f4f0.

B2 semantic 96/34/18/2, equality 484/8, benchmark 23 sources/45 points exact to B1,
B1 focused 36/maintained 8 and release42 + 24 allpass. Scopes overlap; TS oracle
failures remain visible.44/45 runtime points retain host02 bytes; changed map/set
median 20.8518 → 17.5360 µs,TS 20.5952 µs, 15.9% less time over 15 correct samples.
No new whole-corpus timing aggregate. Compiler requests remain slower than TS:
B1 2.84–3.11× and B2 5.08–5.55× on a two-input, three-round cache-primed screen.

Next profile emitted reachability 89.03 s and unsplit emission 111.68 s inside direct
B2 reproduction. Keep checked B1 as the development loop while qualifying legacy
client migration separately. The baseline timeout, contained profile-processor
heap failure and corrected fixture-loader failure are preserved. No PR comment.


## Phase57 — compiler performance attribution — 2026-10-06

[Design](../design/phase57/compiler-performance-attribution.md),
[report](../implementation/phase57/README.md),
[publication](../selfhost/tools/performance/phase57/publication.json).
Information gathering only: Phase56 string01 remains installed, with no compiler
source/runtime/driver change and no new generated-program aggregate or PR comment.

Two clean matrices passed 48 fresh processes / 192 checked requests on two inputs.
B1 import+first request is 2.83–3.13× handwritten TS; B2 is 4.96–5.45×. B2 takes
23–30% less later-request time than raw upstream-emitted Bend but about 1.8× B1
time. The ordered B1 stages show native equality removing 44–46% of later time,
choices another 17–24%, tail choices another 3.6–5%. B2 already has native equality;
these conditional B1 effects cannot simply be promised for B2. Repeats still warm.

Lexer sampled allocations/request: TS 59 MB, raw 4,385 MB, B1 927 MB, B2 2,178 MB.
These are cumulative estimated allocations including collected objects, not RSS.
CPU profiles, allocation stacks, V8 events and exact generated bodies are retained.
Full-source checks for all three Bend images preserve type acceptance and the
expected 3,012 unsafe declarations/trust refusal, not kernel proof validity.

A filtered V8 dump confirms B2's constant computed record keys retain map updates
and three main-path runtime property calls in hot kt. Ordinary B1 literals have
simpler boilerplates; both allocate, and no optimization gain has yet been measured.
Full B2 emission reproduces exact 3,896,951-byte B3 under 25 ms stage sampling.
kt + missing account for 63.683% of reachability and 51.062% of final-emission
self weights. j_arm_type still globally scans nested constructors, creating many
intermediate missing records even on successful queries. This is distinct from
Phase55's already completed typed-arity fast path.

The first 1 ms emission capture hit the RSS guard after reachability returned;
eight earlier captures and the failed result remain. The lower-rate successor
uses the same limits and peaks at 1.39 GiB tree RSS. No timing is presented as an
optimization speedup. All 103 inherited files, seven installed artifacts and
16,034 closed Phase54–56 files remain exact. All 1,605 Phase57 raw files are
archived with reopened per-member verification. Pre-publication accounting:
54.81 minutes elapsed, 25.66 minutes covered by recorded process intervals; the
remaining time is not classified as waiting.

**Updated frontier:** test ordinary literal record fields with __proto__ controls;
count and remove redundant constructor-owner probes/miss construction; preserve
scalar origin through residual numeric bindings; then generalize literal-choice
lowering. Keep experiments small and independently measured before another large
representation or emitter rewrite. Phase57 raw writers are closed.

## Phase58 — allocation, scalar provenance and shared code generation

[Design](../design/phase58/compiler-allocation-and-code-generation.md),
[report](../implementation/phase58/README.md),
[final compiler measurements](../implementation/phase58/final-measurements.md),
[reproduction guide](../selfhost/tools/performance/phase58/README.md),
[hypothesis records](phase58/).

Selected checked-last01 is installed and verified after final compiler/source/
generated-program gates and all five release steps. Integrity before/after,
legacy 42 and default 24 pass; the archive is closed and verified.
Source `85454aab…`, checked B1 `641381f6…`, genuine B2/B3 `a73daccf…` retain exact
runtime/driver/native support. Six mechanisms are general typed/emitter rules:
last-live-key placement, constructor-query miss elimination/checked-owner search,
exact residual U32 provenance, proved literal continuations, per-definition
validated edge deduplication, and private shared mutual-tail dispatchers.
Source grows 314 physical/238 code lines;98 original modules retain exact bytes.

Literal all-ordinary keys help compiler requests but regress three generated
programs. Whole computed rollback restores those programs with a large compiler
cost; last-live-field computed is the selected general compromise. Preceding
ordinary keys and ordinary host-clone keys remain literal; __proto__ is always
computed. Focused17-group controls and independent empty/single/all-erased,
trailing-erased/final-proto/effect cases pass. Width cutoff is not selected and its
synthetic grid remains unexecuted. Historical syntax diagnoses are not relabelled
as checked final performance.

The checked 14-job integration and fresh B2 qualification retain96 source,
34 numeric,18 composition,2 overapplication,8 maintained suites, native pairs,
full own-source type acceptance, exact fixed point and23-source/45-point module
agreement. Unsafe proof-trust refusal is expected independently of type acceptance;
these gates are not kernel soundness proofs. Existing pinned-reference NaN defects
remain separate from candidate oracles.

The fresh full45 campaign passes all 669 samples: equal-point new/TS 1.046110,
old/TS 1.061731 and new/old 0.985287; equal-source new/TS 1.040502. No  >10% regression,
worst 2.949%, zero timing flags. This is a new completed corpus result, not reuse of
Phase53/56 dates or a universal parity claim. Exact tables/flags/plots remain in
[aggregate](../selfhost/build/phase58/final-performance-last01/aggregate/report.json).

Final B2 ordinary compiler requests improve 49–56% for import+first and 59–67% in
later windows on two inputs, still 2.4–2.7× same-campaign TS. B1 results are small
and mixed, including 3.89% later lexer regression. Separate B2 lexer sampling shows
89.41% less cumulative allocation, not peak RSS. Fresh selected own-source emission
36.058 s versus retained old 223.475 s gives descriptive 6.198×; baseline was not a
fresh consecutive repeat, and each emits its own changed source. No isolated
factor speedup or final B1 allocation claim is inferred from those comparisons.

Preserved evidence includes strictExact-flag/controller successors, invalid
computed scrutinee, cross-realm AST and sandbox-launch failures, choice01 edge
exhaustion, failed old full-allocation capture, all-literal program regressions,
whole rollback/compiler cost, and every partial/negative measurement. Dependency
dedup preserves resource constants and validates malformed repeated metadata;
shared dispatch retains component member closure, entry ABI and per-call state.
No old checked receipt or source oracle was rewritten.

**Updated frontier:** release42/default 24/integrity execution is complete/pass.
Post-install preservation, accounting, writer closure and archive member verification
are complete; the final publication index binds the exact evidence.
Keep measured TS compiler gap and mixed B1 results visible. Deferred local key
reuse, serialization/substitution and declaration-event indexing require concrete
counters and context-complete proofs; a large representation rewrite or unsafe
cache is not licensed by the completed allocation gains. Phase58 raw writers are closed.

## Phase59 — first-request attribution (registered; information only)

[Design](../design/phase59/first-request-attribution.md) and
[initial hypotheses](phase59/) register four falsifiable questions: whether fresh
import/first-compile attribution differs from warmed profiles; which disjoint
stages explain the absolute B2/TS gap; where residual cumulative allocation
originates; and whether narrow counters find genuinely repeated work beyond
existing stable/memo paths. Lexer/Evening compilation is the workload, not
generated-program execution. No new measurement outcome is credited yet.

Installed Phase58 last01, source/API/runtime/driver and upstream pin remain
unchanged. Clean fresh-process timing, separate before-import first-window
profiles, diagnostic stage clocks and bounded counters have distinct evidence
contracts. Root alone runs serial resource-guarded targets; data-only analysis
uses CPU0. Closed Phase58 evidence and consumed methods remain immutable.

**Updated frontier:** measure and attribute the remaining first-request gap
before selecting an optimization. Require exact prepared-output equality, correct
stage nesting, cumulative-allocation warnings and context-complete counter scope.
Stop on null/incomplete evidence rather than inventing a speedup or a new release.

### Phase59 completed attribution; unchanged release

[Final report](../implementation/phase59/README.md),
[clean/profile measurements](../implementation/phase59/measurements.md),
[counter findings](../implementation/phase59/counter-findings.md) and
[profile-stage attribution](../implementation/phase59/profile-stage-attribution.md)
close the information-only questions. Clean import/API/first ratios repeat
2.604×TS on Lexer and 2.400× on Evening; compile-only ratios 4.169×/3.204×. Startup
already favors B2. Later requests remain warming, not steady state. First-window
sampled allocations are 246.094/898.285MB versus TS 64.958/123.968MB, cumulative
including collected objects rather than peak or exact allocation counts.

Lexer emphasizes checking/completion, substitutions and persistent indexes;
Evening exposes generated-String search and emitted-dependency processing.
Exact-ancestor partitions preserve unassigned samples and avoid summing nested
weights. Diagnostic stage means are not clean medians or equivalent TS stages.
One refused weighted TS CPU view stays intact with valid count-only evidence
and a separate retry, not clipped deltas or replacement of the original capture.

The primary next hypothesis is generic unchanged String head+tail reconstruction
elision, backed by actual source/generated shape and profiles, not proved copying
complexity or a speedup. Next are the actual 90-row primitive table reconstructed
711/2,595 times and 329,274/374,623 retained index_remove links. Existing stable
substitution proofs already succeed; context/normalization and declaration-event
precedence forbid a careless cache/storage shortcut. Quantity merging is lower
priority on these inputs at ~2.83 visits per merged left entry. Counts are executed
source operations and cannot be divided into sampled bytes as exact object costs.

All workload/output diagnostic checks pass. 38 serial targets total 180.155 s recorded
wall, peak 622.55 MiB tree RSS; this excludes development/analysis/review/publication.
Preservation passes Phase58 closed 30,169 files, installed 7 and protected 103.
No compiler/runtime/driver/release changed, optimization was promoted, PR comment
posted or fresh generated-program speed claim made. Installed release is last01.

**Updated frontier:** start a small general String-provenance falsifier before
another representation rewrite; retain exact demand/Unicode/host effects. Then
consider measured primitive-table and event-list work with complete proofs.
Phase59 raw writers closed approximately 15:20 UTC. [Publication](../selfhost/tools/performance/phase59/artifacts/raw/publication.json)
and [streamed archive/member verification](../selfhost/tools/performance/phase59/artifacts/raw/archive.json)
pass: 518 members, 86,059,319 raw bytes, 5,330,436 gzip bytes; archive SHA256
`711cde7dc2d8576b1a39d37efe5195c8ec7836f9c639a9f4c474cc79b0989673`.

## Phase60 — broad compiler-source survey (registered; measurement only)

[Three hypotheses](phase60/) register broader population variation, recurring
bottleneck groups and a small measured discriminating subset. Root is preparing
`design/phase60/broad-compiler-survey.md`. The 45 benchmark runtime points are not
45 distinct compile requests; 23 source inputs is provisional pending the exact
source/entry/export/adapter audit and compilation-contract deduplication.

Unchanged installed Phase58 last01/genuine B2 and pinned TS are the comparators.
No compiler/runtime/driver changes, optimization, new release or PR comment.
Root alone runs one guarded serial target on CPU3; agents analyze on CPU0. Closed
Phase59 results/raw and all consumed methods stay unchanged; no outcomes credited
here before completed preparation, output oracles and population/method review.

**Updated frontier:** broaden attribution beyond Lexer/Evening, retain absolute
cost and clean/profile/window distinctions, then select a small explicit group-
covering subset and held-out falsifiers. Source/point weighting and compiler versus
generated-program execution remain separate. Existing String reconstruction,
metadata and index-event hypotheses may be supported or demoted, never assumed
universal or promoted from a chosen small subset.

### Phase60 interim results: audited population and common frontend

[Clean measurements](../implementation/phase60/measurements.md) confirm 23 audited
compiler inputs mapped to 45 inherited runtime points. All 138 fresh clean workers/
552 requests pass their qualified raw output oracle; no failed/missing/excluded
source. Combined-first equal-source B2/TS GM is 2.461296885 (summed-median ratio
2.485×); every source slower, 2.103–3.049×. Absolute-gap and ratio rankings differ;
three later requests remain still warming. This is unchanged last01 B2 versus
pinned TS, not a compiler update or fresh generated-program performance claim.

Stage/CPU complete; allocation running. [Source audit](../implementation/phase60/common-frontend.md)
shows ABI2's validated prefix is ignored and loaded Base declaration events are
rechecked. Check-and-complete 611–726 ms is largest individual stage on 22/23 inputs.
The cache saves parsed/source IR, not checked world/memo/output; observed common
stage time does not isolate Base from user checking, specialization, GC or V8.
No unchecked Base-skip or context-incomplete reuse is authorized by this finding.

**Interim frontier:** await allocation and final diagnostics/grouping before
choosing a fast subset or final hypothesis ranking. Preserve shared-work and
source-dependent distinctions, unlike TS stages and clean/profile boundaries.
No optimization promoted, installed release unchanged, archive pending.

### Phase60 target closure and tested short loops

All target campaigns pass: 300 processes, 712 observed compilations (298 first/
414 later), child wall sum 1,246.100 s and peak 630.91 MiB. Whole CLI first-only
Numeric recurrence+MapSet screen passes in 17.528899 s/four workers; adding active
raytrace and two rotated rounds passes 49.509634 s/12 workers. Reusable preparation
is excluded; these costs are observations, not guaranteed budgets or a substitute
for all 23 inputs. Final preservation passes 30,687 closed Phase58/59 files,
installed 7 and protected 103 unchanged. No compiler/runtime/driver/release change.

The original diagnostic population reader fails data-only because one TS
allocation sample's 138,000 bytes reference a missing node. Target profiles and
original unknown mass remain intact. The reviewed successor must retain that
unknown mass before final grouping is credited; this is not a failed target.
Final diagnostic interpretation and archive publication remain pending.

### Phase60 final classification and measured iteration subset

[Diagnostics](../implementation/phase60/diagnostics.md) classify 138 rows with
zero failures, retaining the original data-only reader failure and TS 138,000-byte
missing-node allocation sample in the denominator/explicit unknown bins. All
target workers passed; no profile rerun or source modification repaired the reader.
At a descriptive 5% screen, index names recur in CPU/allocation on 23/23 inputs,
substitution allocation 22/23, String allocation 18/23 and refs/uses 8/23. CPU
String appears 10/23, metadata 4/23. Families, ancestry and wall stages overlap
and cannot be added or interpreted as removable shares.

[Ranked next discriminators](../implementation/phase60/bottlenecks.md) address
common frontend/world/check completion, contrasting String/reference transport,
and persistent index/substitution invariants; primitive metadata is a smaller
independent candidate. Both pipelines check Base, so omission is neither a
relative-gap explanation nor permitted by a source-only cache. No optimization
was implemented or promoted.

[Tested short-loop protocol](../implementation/phase60/fast-loop.md) retains
Numeric recurrence+MapSet rejection screen 17.528899 s/four workers and adds active
raytrace for 49.509634 s/12-worker confirmation. Preparation excluded; measured host
costs are not guarantees. Selection followed clean/stage/CPU and preceded
allocation, which corroborates distinct coverage. Lexer/Evening remain held-out;
all 23 sources remain the broad gate and no subset represents universal parity.

**Updated frontier:** information pass complete, installed last01 unchanged.
Use the measured subset to falsify a separately authorized general proposal with
complete semantic/cache-state proofs before broad integration. Archive publication
remains pending until explicit writer closure and reopened member verification.

Phase60 raw writers closed at 05:42:28 UTC. All 46 CPU count views remain valid;
38 weighted views admitted/8 refused, with uniform count units used in the broad
family comparisons. Streamed archive/member verification is in progress; final
archive identity is the remaining publication item. No further raw writes.

Phase60 [publication](../selfhost/tools/performance/phase60/artifacts/raw/publication.json)
and [archive manifest](../selfhost/tools/performance/phase60/artifacts/raw/archive.json)
pass reopened/member verification with stable input bytes: 2,286 members,
463,038,119 raw bytes and 18,788,706 gzip bytes; one unsplit archive, SHA256
`a02e1bed02335b8bb35451cd129f2c85fe23484ca0f4f68da2daaa30a0b9ef6b`.
No further raw writes; installed last01 remains unchanged.


## Phase61 — architectural compiler speed — 2026-10-07

Explicit user authorization now permits ambitious compiler-source improvements
implemented in Bend with maintained correctness; Phase60's information-only scope
remains an unchanged historical result. Installed Phase58 last01, closed 58–60 and
103 unrelated files remain protected until qualified promotion. Root owns source,
target scheduling and architectural design; no goals or PR comments.

Registered before Phase61 outcomes: [P61-001 shared checked frontend state](phase61/P61-001-shared-frontend-state.md),
[P61-002 compact owned contexts](phase61/P61-002-compact-owned-contexts.md),
[P61-003 structured emission](phase61/P61-003-structured-emission.md), and
[P61-004 fast iteration](phase61/P61-004-fast-iteration.md).
The [research map](../implementation/phase61/research-map.md) links each to prior
proof boundaries and rejected/qualified attempts. Registration changes documents
only; correctness unchecked, new measurements not run, decision investigate.

Phase60's 2.461× combined-first equal-source B2/TS gap, common check/completion,
index/substitution and contrasting String/ref families motivate tests, not savings.
A parsed Base cache lacks checked world/output/memo/fresh/provenance resume state;
both measured pipelines recheck Base. Substitution can reduce Apps without a
variable replacement. Structured refs must preserve emission demand/FFI/order and
bounded refusals. These are explicit falsifiers, not restrictions inferred from
old information-only authorization.

**Updated frontier:** test complete shared-state reuse and structured/compact
work in isolated reviewed source candidates. Use the prior measured rejection/
confirmation subset plus held-out Lexer/Evening, then all 23 and applicable source,
B2/fixed-point/native/legacy gates for the selected candidate. No new result,
installation or speedup is claimed by this pre-outcome entry.


### Phase61 measured state04 and state06 qualification frontier — 2026-10-07

The [state04 broad analysis](../selfhost/tools/performance/phase61/validation/state04-broad-analysis.json)
records all 23 sources: equal-source geometric mean B2/TS **2.436× → 1.702×**
for import + API load + first compilation and **3.773× → 2.549×** for compilation
alone. Candidate/baseline combined-first ratio is 0.698615. All 23 candidate raw
modules equal their qualified references; no generated workloads were rerun.
These are combined-candidate results, not isolated contributions or runtime gains.

The exploratory screen has one round in fixed role order. Its original broad
240-second queue remains failed after 62 successful workers, a TS deadline and
six skipped rows. The aggregate uses 20 complete original triples plus three
complete fresh tail triples, preserving the incomplete attempt and avoiding
partial-role pooling. A separate [three-case confirmation](../selfhost/build/phase61/state04-b2-latency01/confirm90/report.json)
passed all 18 workers over Numeric recurrence, MapSet and active raytrace with
two rounds and no later requests. Preparation and post-return byte validation
are excluded from the clean clocks. The [canonical report](../implementation/phase61/README.md)
retains build, focused controls, genuine B2 and ordinary-driver scope separately.

Current state06 has a successful checked B1 build and 36 strict paired probes.
New native host facts, private prefix provenance and segmented JSON transport
have no credited speedup at this checkpoint; focused controls, genuine B2 and
fresh measurements remain gates. Installed Phase58 last01 is unchanged. Records
[P61-005](phase61/P61-005-native-host-type-facts.md),
[P61-006](phase61/P61-006-private-prefix-provenance.md) and
[P61-007](phase61/P61-007-segmented-json-transport.md) now join the experiment
index; P61-007 explicitly records its retrospective registration.

The [current fast protocol](README.md#current-compiler-fast-method-protocol)
binds genuine images and consumed methods (state04 uses `latency-method03`),
keeps private preparation outside latency, and proceeds from two-source screen
to three-source confirmation, held-out Lexer/Evening and all 23. The 20/60 labels
are coverage names, not time guarantees. Root alone schedules guarded CPU3 jobs;
failures and skipped observations retain their status. Final semantic, B2,
native/legacy, performance and release checks still govern promotion.

The [October 7 cleanup](../selfhost/build/cleanup-20261007/README.md) compacted
49 old raw profiles only. Retained gzip payloads were round-trip hash verified;
restoration mappings preserve historical replay. Source/reports, Phase6, active
Phase58–61 and seven installed-file hashes were unchanged. This storage cleanup
ran no compiler or benchmark and changes no historical result.

**Updated frontier:** finish state06 focused and genuine-B2 qualification, then
measure that exact candidate before attributing any additional benefit. Preserve
the measured state04 checkpoint and all failed predecessors. Full installation
and source promotion remain uncredited until the selected final gates pass.


### Phase61 state06 genuine B2 and subset confirmation — 2026-10-07

The [state06 bootstrap](../selfhost/build/phase61/bootstrap-state06-execution/report.json)
passes six commands and all eight ordinary-driver observations. Its actual
86-root B2 is 3,977,511 bytes, SHA256
`f73ef8a5596e99d45108b0d31b4e6c3f49e008db000a428e27acd27d79bd6d1a`.
Full construction took 71.728722 internal seconds /71.952000 supervised seconds,
within the 132.061495-second enclosing stage. Source checking is inherited;
these results do not establish fresh B2 self-checking or a B2/B3 fixed point.
State06's checked36, native controls18 and carrier29 + five producer cases pass.

[Preparation](../selfhost/build/phase61/state06-b2-latency01/preparation/report.json)
passes separately in 13.768266 campaign seconds. The
[two-source screen](../selfhost/build/phase61/state06-b2-latency01/screen45/report.json)
passes 6/6 workers in 10.317683 seconds. The independent
[three-source confirmation](../selfhost/build/phase61/state06-b2-latency01/confirm90/report.json)
passes 18/18 workers in 30.996514 seconds: Numeric recurrence, MapSet and active
raytrace, two rotated rounds, no later requests. Its median-based equal-source
combined-first ratios are **0.569145 versus fresh Phase58 B2** and **1.468267
versus TypeScript**. Compilation-only ratios are separately **0.532443** and
**2.030508**. Every source improves against its baseline but remains slower than
TS. Complete fresh raw-module comparisons pass; generated workloads were not
executed. Neither pilot nor confirmation is an all23 state06 result.

The consumed method05 uses reviewed stable-input verification and the actual
frame decoder. Campaign wall includes changed orchestration outside clean clocks;
it cannot be compared with method03 as pure compiler speed. Preparation and
post-return raw-byte checking remain outside import/API-load/first-request
measurements. Earlier candidate/state04 samples are not pooled with these rows.
See the [reconciled report](../implementation/phase61/README.md) and
[timing account](../implementation/phase61/timing-account.md).

The [tracked cleanup report](../implementation/phase61/cleanup.md) now preserves
receipt identities and restoration links for the 49 losslessly compacted old
profiles. The local gzip payloads remain required; a Markdown link/hash is not
an independent backup. Seven installed-file hashes and active Phase58–61 were
unchanged by that storage-only work.

**Updated frontier:** qualify the final maintained workflow and exact selected
source/B2 lineage, then broad compiler measurements, self-check/reproduction,
semantic/native/legacy and release gates. Installed Phase58 last01 remains
unchanged. State04 retains the latest broad exploratory population result;
state06's encouraging subset evidence does not replace it or authorize release.


### Phase61 state06 broad23 screen complete — 2026-10-07

The [broad180 receipt](../selfhost/build/phase61/state06-b2-latency01/broad180/report.json)
passes all **69 workers**, covering 23 sources × three roles × one fixed-order
round, with no later requests. Campaign wall is **108.100775 seconds** and the
measurement-stage interval is 107.670503 seconds. All 23 newly emitted raw
modules match qualified references. No generated runtime workload was rerun.

Equal-source geometric means improve **2.468310 → 1.432999 B2/TS** for compiler
import + API load + first compilation, and **3.802103 → 2.098952** for compilation
alone. Candidate/baseline ratios are 0.580559 and 0.552050 respectively.
Preparation and post-return output validation are outside clean clocks. This
one-round screen has no within-cell variation or balanced-position estimate;
no wall-time extrapolation is made. Earlier three-source confirmation and
state04 observations remain distinct, with all failed predecessors preserved.

**Updated frontier:** state06 controls/bootstrap and broad compiler screen are
complete; investigate JDText duplication without assuming a performance cause,
and finish selected final semantic/self-check/reproduction, preservation,
native/legacy/generated-program-performance and release qualification. A changed
source or canonical helper needs its own bound image lineage. Installed Phase58
last01 remains unchanged; no final promotion follows from this screen alone.


### Phase61 state07 correctness and deferred alternatives — 2026-10-07

The [state06 fresh own-source check](../selfhost/build/phase61/self-check-state06-early01/report.json)
passes type acceptance in 18.896774 supervised seconds (12.448330 seconds for
the check request). All 3,191 explicitly unsafe declarations cause the expected
separate proof-trust refusal; kernel checking is false. This is not a fixed
point or qualification of a later source.

The [reuse diagnostic](../selfhost/build/phase61/reuse-probe-all01/report.json)
passes all 23 inputs, retaining definition text/call facts and complete raw
outputs. Finite matches do not prove context invariance or a general safe cache;
cross-context emission reuse is deferred, with no speedup credited.

State07 applies private substitution-leaf reuse plus a 34-line backend telescope
cursor. [Checked36](../selfhost/build/phase61/checked-state07/validation-001/report.json)
passes in 56.558074 seconds; [leaf14](../selfhost/build/phase61/leaf-controls-state07/report.json)
in 9.048651 seconds and [backend24 + one bridge](../selfhost/build/phase61/backend-telescope-state07/report.json)
in 10.250364 seconds. B1 preparation completes separately; no state07 request
speed result is credited at this checkpoint.

The maintained [frame2 workflow application](../selfhost/build/phase61/workflow-sync02-application01/report.json)
records helper `cdd71b72cb2efeec31fdaac322fc3267644f4c6c51fd6575ea0b37e8920be27c`;
its development tests pass in 6.344696 seconds. Historical pilot tools remain
unchanged. The [binary codec discriminator](../selfhost/build/phase61/binary-codec01/report.json)
passes value checks but rejects the alternative: required decode/validation is
2.260389× JSON (225.676447 versus 99.839660 ms medians), in a 4.221657-second
supervised diagnostic. Warm resident-byte codec cost is not compiler latency.

**Updated frontier:** measure state07 before retention, then qualify the final
source, maintained workflow and genuine B2 lineage through semantic, fresh
self-check/reproduction, preservation and release gates. General context caching
remains deferred and binary transport rejected. State06 retains the latest
broad measured result; installed Phase58 last01 remains unchanged.


### Phase61 state08 retains leaf reuse and hoists maximum bounds — 2026-10-07

The [state07 B1 confirmation](../selfhost/build/phase61/state07-analysis01/report.json)
is mixed: combined-first candidate/baseline geometric mean1.010232, compile-only
1.010398. It combines leaf and backend-cursor changes; no isolated effect or B2
claim follows. The backend cursor was reverted. State08's Bend source is state06
plus only the two-line private leaf reuse and maximum-bound hoisting.

[State08 checked36](../selfhost/build/phase61/checked-state08/validation-001/report.json)
passes in 58.678729 supervised seconds. Carrier controls pass 29 world rows,
five producer and eight maximum-bound cases in 44.113050 seconds; leaf controls
pass14 in 9.044181 seconds. These are correctness durations, not speed gains.
The [source footprint](../implementation/phase61/source-footprint.md) compares
frozen installed Phase58 and state08 manifests with the inherited counting rules,
separating runtime/host support and excluding tests/research from Bend totals.

**Updated frontier:** measure the actual state08 image, then qualify selected
source/B2/helper lineage and final release. State06 retains the latest broad B2
measurement; state07's failed retention case is preserved. Installed last01
remains unchanged, and no state08 performance or B2 result is inferred.


### Phase61 state08 B2 and short confirmation, final matrix open — 2026-10-07

The [state08 results matrix](../implementation/phase61/state08-results.md) records
successful six-command bootstrap and eight-driver join for the genuine 86-root
B2, SHA256`23bd6a48b9ed48b58bdc81245c3e40978735f8386c3eb6029b92701511986477`,
3,978,248 bytes. Bootstrap stage132.873596s includes full emission73.272635s
internal/73.458295s supervised; this uses inherited exact-source checking.

Method06 preparation and short screens pass. Three-source/two-round confirmation
passes18 workers; combined-first B2/TS2.599648→1.452451 and compilation-only
3.828061→2.007350. Complete raw output checks pass; no generated workload is
rerun. The one-round pilot and earlier state06 campaigns remain separate. A
small cross-campaign difference is not attributed to individual state08 passes.

The original composition controller remains FAIL due to recorded process-health
`spawnSync EPERM`, despite matching saved observations. The unchanged controller's
fresh permission-corrected retry passes18; overapplication passes2. No compiler
fix or complete final-matrix PASS is inferred from that retry. Balanced all23,
remaining semantics, exact B2 own-source/reproduction and release remain pending.

The [new architecture guide](../docs/self_hosted/compiler-request-pipeline.md)
describes prepared state, private provenance, dependent-term/index operations,
export-local facts and JDText's bounded composition. Its status remains candidate;
installed Phase58 last01 and the historical Phase45 survey are kept distinct.

**Updated frontier:** complete final state08 measurement/qualification and retain
all failures, then consider release admission. No installed change or generated-
program speed result follows from the completed compiler subset.


### Phase61 state08 checked matrix complete, release still open — 2026-10-07

The [13-command resume](../selfhost/build/phase61/final-state08/checked-resume02-execution/report.json)
passes every step. Together with the preserved initial acquisition, it completes
the logical 14-step checked-B1 matrix. The 96 source, 34 numeric, 18 composition and two overapplication observations,
eight maintained suites, direct census, three exact C/stdout oracles and the
45-point generated-program smoke pass. The original permission failure remains
failed; no compiler change was required to retry it.

[Pre-release preservation](../selfhost/build/phase61/preservation-pre-release-state08.json)
passes for seven installed files, 32,973 closed files and 103 protected files.
State08 compiler timings describe genuine B2 fresh processes using prepared
persistent Base caches, excluding preparation and post-return oracle work.
They are not cold OS-cache, installed checked-B1 CLI or generated-program speed
measurements.

**Updated frontier:** finish the balanced three-round broad campaign and exact
B2 semantic/self-check/reproduction gates, then decide release admission.
Installed Phase58 last01 remains unchanged.


### Phase61 state08 balanced broad and B2 child gates — 2026-10-07

The [audited broad summary](../implementation/phase61/evidence/state08-broad3.json)
passes 207 fresh workers, 23 sources × three roles × three rounds with balanced
role positions and fixed source order. Equal-source median B2/TS geometric means
are **2.476542 → 1.433877** combined-first and **3.816429 → 2.071828** compilation-
only; every source improves versus same-campaign Phase58 B2. All raw module
comparisons pass. Compiler clocks use prepared persistent Base caches, exclude
preparation/post-return checks, and do not claim cold OS caches, installed-B1 CLI
latency or fresh user-program runtime gains. Earlier campaigns remain separate.

The actual B2 freshly accepts its source's types in 11.397480 request seconds
(17.385388 supervised), with expected trust refusal for 3,192 unsafe declarations.
Exact B2/B3 equality at `23bd6a48…` passes in 34.567764 supervised seconds; B2 raw
modules and the 45-point observer mapping equal selected B1. These successful
child gates do not relabel the original enclosing B2 stage, which failed later
at a receipt metadata comparison; the corrected identity-normalization retry is
separate. No Bend source change is implied by that tooling correction.

**Updated frontier:** finish the exact B2 semantic retry and remaining release
admission/preservation gates. Installed Phase58 last01 is still unchanged.


### Phase61 state08 installed and verified — 2026-10-07

The [resolved checked matrix](../selfhost/build/phase61/final-state08/checked-resolution.json)
passes 14 logical steps: the original healthy acquisition plus 13 healthy retry
commands. The [genuine-B2 semantic retry](../selfhost/build/phase61/final-state08/b2-semantics-resume02-execution/report.json)
passes seven commands, covering 96 source, 34 numeric, 18 composition and two
overapplication observations in 105.044043 stage seconds. Original permission
and receipt-validator failures remain failed; known TS oracle defects remain
explicit. Receipt identity normalization required no Bend source change.

The [release admission](../selfhost/build/phase61/final-state08/release-admission.json)
selects checked B1 API `97f412af…`, source `268b3cf2…`. Genuine B2/B3
`23bd6a48…` retains its separate own-source, reproduction and timing evidence.
Installation and verification-before pass, as does the complete legacy42 child.
A daemon restart interrupts the original outer release receipt before it records
that child completion; the wrapper remains incomplete. The independent
[two-command resume](../selfhost/build/phase61/final-state08/release-resume02-execution/report.json)
passes default24 and verification-after in 19.881522 stage seconds. **Phase61
state08 is installed and verified.**

[Final preservation](../selfhost/build/phase61/preservation-final.json) verifies
seven selected installed files, preserved prior-release copies, 32,973 closed
historical files and all 103 protected files. Selected runtime and 23 raw
programs/45 observation modules retain qualified bytes. Prior runtime performance
evidence transfers only to identical artifacts; no fresh 669-sample timing or
new program-speed gain is claimed.

The [final state08 report](../implementation/phase61/state08-results.md) retains
the balanced207 compiler result (combined B2/TS 2.476542→1.433877;
compilation-only 3.816429→2.071828), completed gates, failures and remaining
practical proposals. Body-only Base patch bytes are a model; larger substitution
and emission reuse still need proofs, and measured binary transport stays rejected.

**Updated frontier:** semantic, measurement and installed-release qualification
are complete. Finish publication accounting and evidence archive/writer closure;
no further compiler target or source experiment is selected. Preserve all failed
and interrupted receipts with their original statuses.


The [final timing account](../implementation/phase61/timing-account.md) closes
its target-work window at `2026-10-07T16:38:11.916235+00:00`: 28,007.366566 s
elapsed and 3,514.638909 s observed supervised wall union (12.548980%). Fourteen
finished failures are included; incomplete intervals receive no invented end.
The uncovered 24,492.727657 s is not classified as waiting. Documentation,
analysis and publication after the cutoff remain outside that measurement.


### Phase61 evidence closed and published — 2026-10-07

The [archive and restoration guide](../selfhost/tools/performance/phase61/artifacts/README.md)
records 17,386 raw files, 882,650,258 uncompressed bytes and one 90,979,618-byte
capsule, SHA256 `0f3ceb5a8f90686a05469af2bf0ab2b18e9b479e11a14ad18a7f23461ee62d43`.
Reopening/member verification and input-stability verification pass. The closed
snapshot retains failed, interrupted and rejected attempts without status edits.
Publication metadata and later documentation remain outside the raw archive;
all raw writers are closed.

**Updated frontier:** Phase61 is complete and its evidence is published. State08
is installed and verified as checked B1, with separate genuine-B2 correctness
and compiler-request measurements. No further compiler source change, target or
follow-up optimization is selected.


### Phase62 remaining compiler-cost investigation — 2026-10-07

[Design](../design/phase62/compiler-parity-investigation.md) and
[P62-001](phase62/P62-001-remaining-compiler-cost.md) precede target collection.
The [report](../implementation/phase62/README.md) records an unchanged-compiler
study: 92 CPU/allocation profiles, 50 exclusive-stage workers, 36 clean
same-source B1/B2/TS workers, 16 repeated-request workers/64 requests, 27 paired
counter inputs and 16 synthetic-scaling workers with 1,488 exact runtime checks.
All target results pass their scoped output/value oracles. Raw evidence is
closed, archived and reopened-verified; one data-only plot failure is preserved.

The current arithmetic diagnostic gap is 510.20 ms per input: 265.99 ms in
prepared-state/loading/checking, 241.55 ms in backend work, 2.65 ms elsewhere.
The checker boundary itself averages171.94 ms B2 versus172.91 ms TS, with
unequal Base work. Cache admission costs173.42 ms, mainly JSON parse88.77 ms
and tree validation52.02 ms, versus file read1.75 ms. These diagnostic clocks
are separate from the historical clean23 headline1.433877×/2.071828×.

Same-source B2 uses12.82% less compilation time than optimized checked B1 on
four inputs; runtime/ABI/profile confounders remain explicit. Later ordinary
requests change B2/TS2.114→1.577→1.293→1.380×; no plateau or isolated JIT
attribution. All23 inputs repeat signature facts, but that family's CPUcount
union averages only2.25%. Sampled allocation ratio1.185× and varying per-stage
substitution counts refute a universal allocation-only explanation. Simple
size/width screens reveal higher marginal cost without quadratic growth over
the tested range; one round is not an asymptotic proof.

Focused primary-source research compares current Bend with TS caches, Lean
metadata/sharing, Lean4Lean, smalltt, Rust query dependencies and LLVM analysis
preservation. Root alone ran serial guarded CPU3 targets; seven agents handled
independent tooling/source research and review. Ten collection workflows total
401.903 seconds including their preflight/preparation/verification; this is not
whole-session elapsed. Preservation passes110 inherited files and7 installed
files. No production source change, upstream update, installation or PR comment.

**Updated frontier:** investigation complete. The strongest next work combines
safe admitted Base state for library sessions with reusable backend analysis and
documents. Use a small signature-fact bundle as a cheap architecture prototype,
not a parity promise. Fresh-process state transport and completion/freshening
remain distinct opportunities. No optimization or target is currently selected.


### Phase63 implementation authorized — 2026-10-07

[Design](../design/phase63/ready-world-and-lowering-plan.md) records the
ready semantic Base world, parser indexes, validated sharing transport and
one owned lowering plan. Six agents prepared source/control/measurement
prototypes in parallel. Root retains exclusive serial guarded target execution.
Phase63 target evidence is separate from closed Phase62. No result or promotion
is claimed at registration.

**Updated frontier:** execute fast correctness and clean latency screens, then
qualify the best genuineB2 on all23 sources. Parity remains the objective.


### Phase63 State09 selected and installed — 2026-10-07

The [final report](../implementation/phase63/state09-results.md) records a
207-worker balanced comparison on23 compilation sources. Genuine B2/TS improves
2.05505×→1.63275× for compilation (20.55% less time) and1.40665×→1.15092× for
host/API import plus first compilation (18.18% less). Every source improves over
the previous compiler; all complete emitted modules equal the qualified oracle.
Compilation-only parity remains unfinished. No new generated-program timing
campaign or speedup is claimed.

Selected changes retain a ready Base world/parser indexes, validated shared
transport with fixed constructor decoding, one owned library lowering plan,
shared host field conversion and already-computed arity facts. State09 carries
actual completed suffixes and removes four obsolete host traversals. Actual
named-layout images make the proposed positional-ABI shortcut inapplicable.
Typed call-spine reuse was correct on focused controls but reverted for no
useful request gain; warm-only generic decoder results were misleading. All
failed source/control/permission/metadata attempts retain their original status.

The [qualification join](../implementation/phase63/evidence/state09-qualification.json)
reverifies3061 inputs: strict36/export94, full checked matrix, real B2 build,
fresh own-source acceptance with expected unsafe-trust refusal, exact B2/B3,
B2 semantic96/34/18/2, raw23/point45 equality, balanced207, release42/24 and five
helper-integrity checks. A reviewed packaging-only delta includes the new graph
helper with checked provenance. State09 is installed as equality-derived checked
B1; the measured image is genuine B2. All110 inherited unrelated files and all
seven previous release artifacts are preserved.

**Updated frontier:** Phase63 implementation complete. Profile the new residual
cost before selecting further owned signature/layout reuse or frontend scan
removal. Another38.75% reduction in compilation time is needed for parity on
this catalog; startup-inclusive proximity is a different metric. Use the final
report and evidence capsule, not intermediate checkpoints, as current authority.


### Phase63 evidence closed — 2026-10-07

The [capsule](../selfhost/tools/performance/phase63/artifacts/README.md) preserves
16,691 files,521,756,245 uncompressed bytes and a78,204,174-byte archive, SHA256
`8dc20dcc3961cc479a343a275ae7d0d9b3eaca4401f10336da72aae9d7c63c22`.
Every member was reopened and byte-verified; original input inventory/hashes
remain unchanged. All raw writers are closed. No failed receipt was relabelled.


### Phase64 implementation authorized — 2026-10-07

[Design](../design/phase64/typed-facts-and-compact-state.md) and
[P64-001](phase64/P64-001-residual-costs-and-typed-facts.md) register a new
State09 residual-cost survey and separate Base-completion and typed-backend
fact experiments. Indexed Base loading or compact representation follow only
when measurements justify them. Root retains serial guarded target execution;
agents own disjoint source/data/review work. Baseline110 inherited files and
seven installed artifacts were rehashed. No Phase64 result or promotion yet.
