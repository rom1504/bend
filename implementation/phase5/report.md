# Phase 5 implementation report

Status: in progress, first integrated checkpoint at 2026-09-22 22:24 UTC.
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
  controls pass. No new Phase 5 speed estimate is claimed yet.

## Remaining campaign work

P5-005 tests a narrow source-location reconstruction for unchanged applications;
P5-006 repairs lexical constructor-brace adjacency; P5-007 improves selected
constructor/datatype error reasons without changing checker acceptance. They
remain separate experiments until focused review and integration. Additional do
binder and argument-separator witnesses are being prepared.

The final source still needs a fresh broad gate, CPU backend coverage, checked
self-reproduction, updated code-size/complexity counts and controlled performance
samples. The default distribution and pinned upstream have not changed.

## Evidence

Each workstream report links a content-addressed archive with raw successes,
failures, checked source/API identities, consumed tools and fixtures. Historical
absolute paths identify inputs; they are not a claim of portable replay. The
[integration archive](integration-01-evidence/manifest.json) preserves the first
combined source, complete reports, reference attempts and exact comparison.
Large executable/toolchain prerequisites are identified separately.
