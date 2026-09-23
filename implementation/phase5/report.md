# Phase 5 implementation report

Status: in progress, validation checkpoint at 2026-09-23 00:45 UTC.
The authorized six-hour campaign began at 21:39:36 UTC and ends
2026-09-23 03:39:36 UTC. Baseline: `7d69850`; design commit: `7c7db08`.

The [design](../../design/phase5/conformance_and_development.md) prioritizes
conformance, targeted simplification and reusable performance improvements.
The [experiment ledger](../../experiments/ledger.md) and
[current strategy](../../experiments/STEERING.md) track decisions and evidence.

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
Compiler source is now frozen pending the final combined checks.

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
input/output hashes. The final combined checked build is running.

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

## Remaining campaign work

After the controlled memo window, run the final genuine combined build and
frontend gate, selected actual CPU/backend executions, a new complete-source
TypeScript/checked-B1/derived comparison and the unchanged checked self-host
fixed-point procedure. Recount source/support/experimental code separately and
archive the final input identities and failures. The default distribution and
pinned upstream remain unchanged. The six-hour campaign is still active.

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
