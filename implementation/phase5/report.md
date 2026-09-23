# Phase 5 implementation report

Status: implementation and release validation complete; final documentation checkpoint 2026-09-23T03:31:27+00:00.
The authorized six-hour campaign window began at 21:39:36 UTC and ends
2026-09-23 03:39:36 UTC. Baseline: `7d69850`; design commit: `7c7db08`.

The [design](../../design/phase5/conformance_and_development.md) prioritizes
conformance, targeted simplification and reusable performance improvements.
The [experiment ledger](../../experiments/ledger.md) and
[current strategy](../../experiments/STEERING.md) track decisions and evidence.
The [experiment outcome index](outcomes.md) separates all 23 source/tool changes,
measurements and rejected approaches without rewriting their original plans.

The user's latest steering asks for one usable compiler before further semantic
and performance work. The [consolidated release](consolidated-release.md) now
installs the validated equality-derived B1 as the ordinary CLI default, with a
relocatable manifest and one `npm run build` command. The advertised command was
actually rebuilt and passed its focused gate; its API bytes remain identical to
the measured/validated artifact. Default interpretation, JavaScript and actual
native CPU execution pass, along with relocation and changed-input refusal checks.
Broad paired JS/native validation is [complete](broad-backends.md): 3,962 actual
observations, with retained negative diagnostic/phase failures, environment
limitations and one positive native timeout. Coverage completion is not a
full-conformance pass.

The full H and derivative frontend [gates](final-artifact-frontend.md) are
complete: each reproduces all 2,756 B1 observations exactly, preserving all 318
known strict failures. The [next semantic design](../../design/phase6/semantic-gaps.md)
and [performance design](../../design/phase6/residual-performance.md) keep new
candidates isolated from this usable release.

## Current outcomes

| Final-source metric | Campaign baseline | Current checked source |
| --- | ---: | ---: |
| Positive fixtures passing parse and check | 919 / 919 | 919 / 919 |
| Strict check failures | 377 | 318 |
| Exact live frontend differences | 560 | 444 |
| Status/phase differences | 50 | 16 |
| Production Bend modules | 59 | 59 |
| Production Bend physical lines | 16,055 | 16,509 |
| Production Bend nonblank lines | 13,400 | 13,803 |
| Production Bend definitions | 1,482 | 1,526 |

No previously exact observation or strict check regressed. Remaining text-field
mismatches can still reflect different selected errors; they are not assumed to
be cosmetic. All check statuses match pinned TypeScript on this inventory, while
three parse acceptance discrepancies and eight differing rejection phases
remain. See [the complete breakdown](final-conformance.md).

Two distinct controlled workflow experiments pass: the maintained equality
profile reduces full frontend wall by 23.9% on its frozen source, and private
Base decoding reuse reduces it by 17.1% on another frozen source. Those gains
are not multiplied into an unmeasured combined percentage. The final-source
[controlled compilation comparison](full-source-comparison.md) is complete:
mean process wall is **60.25s for pinned TypeScript, 642.58s for checked B1,
and 363.39s for its maintained equality derivative**. The derivative uses
**43.45% less time** than checked B1 and remains **6.03× slower than TypeScript**
on this workload and documented cache policy. All six checked compilation,
emitter-family byte and output-execution gates pass. Public self-emitted H is a
separate artifact; these measurements do not establish its compilation speed or
the runtime speed of emitted user programs. Genuine checked self-reproduction
completed at 02:10:22 UTC: actual B1→H→H stages are byte-identical, with all
recorded inputs verified. B1's stage took 661.410 seconds and public H's stage
1,595.546 seconds. Those single proof-stage observations have a separate setup
and are not a repeated controlled H/TypeScript comparison.

The [source recount](code-size.md) reports +454 production lines (+2.83%),
principally structured diagnostics and imported declaration checks. Removing a
duplicate core/checker filter and two obsolete Nat helpers simplifies specific
boundaries; this is not a claim that the whole compiler shrank or that line
counts measure semantic complexity. The [independent static review](final-static-review.md)
records its scope and a [confirmed diagnostic-location counterexample](static-counterexample.md).
The final explicit support boundary totals 12,919 physical lines; experimental
performance tools/prototypes/tests are a separate 14,771 lines in 260 files.
These are published file-selection counts, not a cyclomatic complexity measure.
After a physical newline inside a string, an existing lexer cursor error can
make the new renderer highlight the wrong line. Rejection behavior is unchanged;
the valid neighbor agrees exactly. The defect remains explicitly unfixed in
this frozen source.

## Final development workflow observations

The final integration's maintained commands recorded these process durations:

| Operation | Observed wall |
| --- | ---: |
| Checked B1 bootstrap subprocess | 14.63s |
| Prepare its validated Base cache | 4.41s |
| Paired 387-observation focused selection, per compiler | 42.13s total for the pair |
| Full B1 frontend inventory, 2,756 observations | 292.25s |

The build report's broader start-to-finish interval is 15.37 seconds; the table
uses recorded child-process walls. These are completed workflow observations
amid other correctness work, not a
controlled speed comparison with the campaign baseline. The checked API build
exports the ordinary API; it is distinct from the 1,566-root complete-library
benchmark and from checked B1→H→H self-reproduction. Small edits can use the
focused paired gate, fixture-only changes can reuse a verified build, and the
long proof remains an integration gate. The [maintained guide](../../docs/PHASE5_DEVELOPMENT.md)
documents those commands and their artifact boundaries.

## First integrated source

The ordinary checked bootstrap produced API `a17d909d9c48…`, from assembled
source `40c05814…`. Four production frontend modules changed. The combined
115-case selected check gate agrees with fresh pinned TypeScript on all declared
acceptance/phase oracles; 52 exact diagnostic differences remain in that selection.
Separate execution gates verify the affected binder scope and do-notation paths.

| Full pinned frontend measure | Phase 4 baseline | First Phase 5 integration |
| --- | ---: | ---: |
| Fixtures / parse+check observations | 1,378 / 2,756 | 1,378 / 2,756 |
| Positive fixtures passing both lanes | 919 / 919 | 919 / 919 |
| Strict check failures | 377 | 376 |
| Exact live TypeScript differences | 560 | 558 |
| Acceptance/phase differences | 50 | 48 |
| New differences versus baseline | — | 0 |
| Worker failures/timeouts or input drift | 0 | 0 |

Fresh TypeScript reference observations are unchanged from Phase 4. Its three
strict check failures remain visible. Candidate differences still include 510
exact diagnostic/report discrepancies. `check/do_missing_bind.bend` now matches
in both lanes. Two other negative fixtures change error text while retaining
existing differences; generic rejection is not counted as a repaired diagnostic.
These are frontend metrics, not full language/runtime conformance.

The full candidate workflow reports `complete: true, pass: false`: all requested
observations completed, while known strict failures remain failures. Its broad
phase took about 310 seconds amid documentation/archive work. The checked build
and selected phase took about 14 and 18 seconds respectively. These are workflow
observations, not controlled speed comparisons. One reference launch omitted a
required environment variable; another exceeded its 180-second single-core
budget after 2,082 observations. Both attempts are retained. The fresh four-worker
retry completed all 2,756 observations, with no reference behavior changes.

## Validated workstreams

- [P5-001 frontend bindings](frontend-bindings.md): common pattern validation,
  decorator grammar, and last-binder-wins scope in parallel/local/match forms.
  The final audit covers 109 paired observations, including 30 exact execution
  outputs. New local fixtures expose gaps absent from the pinned suite.
- [P5-004 do notation](do-notation.md): 20 demonstrated acceptance/phase gaps
  repaired in 36 programs; 34 interpreter/JavaScript observations agree exactly.
  The retained report distinguishes 17 remaining diagnostic differences.
- [P5-002 development workflow](development-workflow.md): one maintained
  checked-build/validate entry, immutable attempt snapshots, finite process
  supervision, artifact drift checks and explicit derived-artifact provenance.
  Eleven regression groups pass; the integrated broad run exercises its
  known-failure completion path. See [usage documentation](../../docs/PHASE5_DEVELOPMENT.md).
- [P5-003 equality derivation](equality-derivation.md): the proven string equality
  derivative now recognizes two genuinely new checked builds, verifies the
  complete generated runtime/dependency contract, and keeps bootstrap proof
  separate from derived code. Unicode, malformed data, drift and rejection
  controls pass. Its new-build performance confirmation is recorded below.

## Second integrated source

Checked API `c3c2ac7b1456…` includes the reviewed P5-006/007/008/009/010
changes. All 213 focused check observations pass their declared oracles. The
full 1,378-fixture / 2,756-observation gate preserves all 919 positive fixtures, has
zero worker failures/timeouts/input drift, and introduces zero new exact live
TypeScript differences relative to the first integration.

| Measure | Campaign baseline | First integration | Second integration |
| --- | ---: | ---: | ---: |
| Strict check failures | 377 | 376 | 374 |
| Exact TypeScript differences | 560 | 558 | 556 |
| Acceptance/phase differences | 50 | 48 | 38 |
| Remaining exact diagnostic/report differences | 510 | 510 | 518 |

Ten observations move from an incorrect phase to a correct phase but still
have different diagnostic text, explaining the increased presentation category.
The exact matches newly repaired in this batch are `check/ctr_of_datatype` and
`io/channel_send_recv`. The remaining 556 differences span 372 fixtures. The same
pinned TypeScript report, freshly measured earlier in this campaign, is reused
with identical fixture/compiler hashes; it has not been relabeled as another run.

Validated additions are [constructor adjacency](frontend-adjacency.md),
[argument delimiters](frontend-arguments.md),
[constructor diagnostic reasons](constructor-diagnostics.md),
[plain do binders](do-plain-binders.md) and
[local constructor freshness](declaration-freshness.md). The unchanged
newline-only helper moved from sugar to lexer as `f_space`, shared by do headers
and argument lists; statement-aware `f_skip` retains its separate role.

[P5-005 application-origin reconstruction](application-origins.md) is rejected.
It repaired four exact upstream diagnostics without semantic regressions, but
reparsed the same application repeatedly. An ordinary 128-argument rejection
observation rose 2.855→4.845 seconds. These unpaired stress observations support
rejecting the known quadratic work; they are not general speed estimates.
No part of that source overlay was promoted.

## Controlled equality measurement on the new source

[P5-012](equality-performance.md) verifies the maintained derivative on checked
API `c3c2ac7b1456…`. Opposite-order fresh-process requests improve from
19.278 to 12.262 seconds for the fixed core library (36.4% less time), and
2.464 to 1.849 seconds for list_sort (25.0% less). Pinned TypeScript takes
0.397 seconds for that list request: checked B1 is 6.20× slower, the derivative
4.65× slower. These are small workload request measurements with the documented
Base-cache policy, not current complete-source ratios or CLI timings.
All ten rows pass exact emitted-byte checks; list outputs execute exactly.
Core coverage is checked compilation and JavaScript syntax, not full core runtime
execution. Other intentional compiler jobs paused throughout the timed window.

## Later source and validation work

Reviewed changes now include [structured parser errors](structured-parser-diagnostics.md),
[unresolved operators](frontend-operators.md), [matcher heads](frontend-matchers.md),
[namespace error preservation](frontend-namespace-errors.md),
[core-layer definition filtering](core-filter-layering.md),
[Nat prefix parsing](frontend-nat-prefix.md),
[imported declaration freshness](imported-freshness.md), and
[embedded parser diagnostics](embedded-parser-diagnostics.md).

Nat precedence was an actual wrong-result bug: `(2n * 1n+3n : Nat)` previously
returned 5 while TypeScript returned 8. The final candidate returns 8 in both
interpreter and JavaScript execution. A first-error regression discovered during
development was corrected before promotion and remains in the evidence.
Two obsolete Nat helpers were removed; the cleanup produces the same checked
API bytes. Separately, removing the duplicate core/checker definition filter
restores the standalone 22-module frontend build and passes 23 existing
definition-selection controls on a Bend-emitted library.

Integration-03 is genuine checked API `8cfa124d7567…`. Its initial selected gate
is retained as **273/274 passing declared oracles**: the combination of new
matcher validation and parser metadata exposed a nested-error formatting loss.
The source-aware error-only renderer repairs that composition without scanning
accepted books. A full integration-03 control run has now completed all 2,756
observations, preserving 919/919 positives and retaining 365 strict check
failures. That is an intermediate source, before the later Nat, freshness and
additional expectation-site changes; it is not the final campaign metric.

Integration-04 is genuine checked API `9bb69d433703…`, including the Nat,
freshness and nested-error fixes. Its 362-observation selection has 361 semantic
agreements. A missing-import control incorrectly required Bend's existing load
phase even though TypeScript reports parse phase. That discrepancy is unchanged
from the frozen baseline; the original fixture and failed paired run remain.
A separately named confirmed selection excludes that known residual. Exact
diagnostic agreement remains distinct from acceptance/phase agreement.

The additional explicit expectation-site candidate has 45 newly exact messages
in a 167-case comparison, retains all eight previously exact messages and changes
no classifications. Its original stricter unchanged-or-exact gate still fails on
nine reformatted but divergent messages. The approved presentation criterion
requires faithful rendering of the same chosen error and no newly broken exact
oracles; these remaining parser differences are not counted as repairs.
Compiler source was frozen here for the final combined checks reported below.

## Faster complete frontend loops

[P5-015](equality-frontend.md) compares the maintained equality derivative with
its genuine checked parent in a controlled four-worker ABBA schedule. All
11,024 observations and closed worker histories agree exactly. Mean full-loop
wall falls from **301.905 to 229.753 seconds**, 23.90% less time (1.314×).
All four runs retain the same 374 strict check failures for that source.

[P5-021](persistent-base-decoding.md) then isolates repeated host cache work.
The cost probe attributes 44.14% of focused request time to decoding and
re-verifying an unchanged Base book. A bounded private session memo passes
84 mixed-request comparisons and 15 adversarial contract groups. Its focused
ABBA pilot reduces request time **16.629→10.144 seconds**, 39.00%, with all
168 observations exact. This is a separate host optimization and a different
measurement boundary; its percentage must not be multiplied into the equality
result to invent a combined speedup. The [complete-inventory memo comparison](base-memo-frontend.md) now passes:
292.602→242.597 seconds, **17.09% less**, with all 11,024 observations and closed
worker histories exact. The two measured host files are promoted with guarded
input/output hashes and are included in the completed final combined build.

## Final combined source checkpoint — 00:43 UTC

Genuine checked integration-05 API `5969c53d34a0…` compiles the frozen final
source `e3b927d13dc2…`. The focused paired gate completes all **387 observations**
on 371 fixtures: both compilers pass every declared oracle and agree in
acceptance/phase. There are 277 exact agreements and 110 retained diagnostic
differences; acceptance-only oracles do not turn those differences into exact
conformance.

The unfiltered full frontend gate completes **2,756 observations** on all 1,378
pinned fixtures. All **919 positive fixtures pass parse and check**. Strict
checking now has **1,060 passes and 318 failures**, compared with 377 failures
at campaign baseline. Negative parse observations retain their diagnostic
status; they are not counted as strict checker passes. The workflow correctly
exits nonzero while marking the observations complete. The live pinned comparison has **444 exact differences**, down from 560:
428 differ only in text fields and 16 differ in status/phase, down from 50.
These text differences are not automatically cosmetic: they can describe
different selected errors. There are **116 newly exact observations and no
new exact regressions**, and all 2,756 fresh TypeScript observations match the
baseline reference. See [the final conformance breakdown](final-conformance.md).

The final paired backend selection also passes all 42 declared observations
per compiler (84 actual observations), including nine positive programs through
interpreter, JS and actual native C compilation/execution. Ten custom diagnostic
differences remain; the pinned exact matcher diagnostic agrees through all three
execution entry points. Two fixture-author errors caught in preflight are
preserved alongside the corrected intended positive fixtures. See the
[backend report](final-backends.md) and the verified
[final integration archive](integration-final-evidence/manifest.json), including
both earlier failed combined selections and their immutable inputs.

## Consolidation and completed broad validation

The final genuine combined build, full B1 frontend inventory, selected actual
CPU/backend executions, complete-source comparison and fresh checked fixed point
have finished. The [independent proof audit](final-selfhost.md) verifies 225 file
identities and all 59modules, actual stage2/stage3 byte equality and every P523 Bend
output. The [H/derivative frontend gate](final-artifact-frontend.md) also completes
with all 2,756observations/artifact exact and all worker histories closed.

The default distribution is now the consolidated optimized release; pinned
upstream and compiler source remain unchanged. The advertised build reproduces
its exact API, and default CLI/relocation/integrity controls pass. A discovered
native subprocess error could incorrectly return exit0; a one-line host fix and
regression controls address it, followed by another checked release build with
identical compiler bytes. Historical pre-fix observations remain in their archives.

The paired [broad JS/native gate](broad-backends.md) completed at 03:08:40 UTC on
that same compiler image with its frozen pre-fix host: 1,981 observations per
compiler, 3,962 total, no missing rows or input drift. Bend recorded 1,423 strict
passes, 315 negative diagnostic/phase failures, 242 not-applicable observations
and one positive native timeout. All 527 eligible negative observations were
rejected. The 354 exact paired differences comprise 299 diagnostic-only and 55
other differences; the latter include unavailable Bun, reference toolchain/runtime
failures and 16 known rejection-phase differences. They are not 55 new language
bugs. Full strict conformance and infrastructure health remain failed gates.

The native timeout emitted 3,716,568 bytes of C for a 255-field record, versus
80,723 bytes for TypeScript. [Static analysis](../phase6/native-arity-wall.md)
identifies quadratic repetition of scalar-field continuation saves, distinct
from the JS library workload's 6.03× compiler deficit. All actual C files, native
binaries and failures are retained in the 24,148-member broad archive.

The installed package also passed a fresh [relocated CLI check](relocated-cli-evidence/README.md)
without an upstream checkout or build/cache tree at startup. Phase 6 candidates
remain isolated; their [outcome report](../phase6/report.md) separates focused
improvements, rejected patches and uncompleted promotion gates.

## Priorities after this campaign

The maintained checked/derived workflow makes focused conformance changes
practical without repeating a full self-host build on every edit. Next, target
the three remaining parser acceptance discrepancies and the five missing-import
phase discrepancies, with first-error and valid-neighbor controls. Repair the
confirmed multiline-string cursor/excerpt defect as its own checked change.
These eight pinned fixtures plus the new reproducer are more precise targets
than treating all 428 text-field differences as one rendering problem.

Then distinguish wrong selected errors from provenance/presentation differences.
Keep independent semantic witnesses such as the repaired Nat 8-versus-5 result:
the pinned positive inventory alone did not expose that bug. Reuse structured
transport and the thin maintained workflow rather than reintroducing repeated
application reparsing or a second general validation framework.

For performance, the final coarse observations still put substantial time in
checking, annotation and lowering even after the equality optimization. A fresh [optimized-core profile](../phase6/optimized-residual-profile.md) now
identifies remaining trampoline, closure and allocation work. An isolated explicit
Boolean-worker candidate [passed its controlled core pilot](../phase6/boolean-branches.md):
6.18–6.72% less request time and 5.79–6.30% less process wall in both orders, with
exact emitted bytes. This is one small workload, not a new whole-source ratio or
a promoted compiler. The released derivative leaves generated bytes unchanged and
does not establish a runtime improvement for user programs. Local removal of
duplicate logic is useful, but the compiler grew 2.83%; further simplification
should be justified by a concrete shared contract and its regression gates.

## Evidence

Each workstream report links a content-addressed archive with raw successes,
failures, checked source/API identities, consumed tools and fixtures. Historical
absolute paths identify inputs; they are not a claim of portable replay. The
[integration archive](integration-01-evidence/manifest.json) preserves the first
combined source, complete reports, reference attempts and exact comparison.
The [second integration archive](integration-02-evidence/manifest.json) preserves
the next complete source, all 213 selected observations, the full frontend report
and the exact comparison. Large executable/toolchain prerequisites are identified
separately.

## Final handoff

The consolidated compiler is the ordinary default on `selfhost/bootstrap`.
`npm run build` and `npm run verify:release` are the maintained entry points;
[the user guide](../../docs/BEND-IN-BEND.md) covers first checkout, normal use,
rebuilding, source experiments and separate proof gates. The default API remains
`e2b5463678a26558e8fea1d585782e0863f1046067949a374f0469080281b15a`.
No Phase 6 candidate was merged into it.

All requested Phase 5 compiler/integration jobs are closed. Optional public-H
selected user-program backend coverage was prepared but not launched; all recorded
strict failures, the native timeout and untested GPU execution remain limitations.
The [Phase 6 report](../phase6/report.md) preserves the final bounded experiments
and ranks semantic repairs, Boolean validation, native scalar-field lowering and
repeated checking/annotation work. The [final documentation audit](release-doc-evidence/)
and [independent review](../phase6/final-release-doc-review.md) document their exact
scope. The final recount keeps source, maintained support and experimental tools
separate. This handoff does not claim full conformance or TypeScript performance
parity; it supplies a stable compiler and concrete, reproducible next experiments.
