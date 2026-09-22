# Phase 5 implementation report

Status: in progress, second integrated checkpoint at 2026-09-22 23:03 UTC.
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

## Remaining campaign work

P5-011 now prototypes structured raw-parser error transport with a once-only
renderer and unchanged public loader result shape; see its
[detailed design](../../design/phase5/structured_parser_diagnostics.md).
P5-013 investigates unqualified operator refusal; P5-014 investigates invalid
matcher-arm heads. P5-015 prepares a controlled complete frontend loop comparison. These isolated candidates are
not production changes until their gates and review pass.

The final source still needs a fresh broad gate, CPU backend coverage, checked
self-reproduction, updated code-size/complexity counts and controlled performance
samples. The default distribution and pinned upstream have not changed.

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
