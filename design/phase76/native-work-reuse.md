# Phase76: native compilation parity by removing repeated work

Baseline: Phase75 selected source/release at `6becf8675ce6b485ea8072df374bf61aeb564d09`.
B1/B2 fresh checked Bend-to-C request ratios are 2.91581/1.92053 upstream.
The target is parity while preserving generated-program speed and conformance.
Compiler algorithms stay in Bend. No agents, upstream edits or PR comments.

## Experiments in order

1. Quantify retained native analysis with bounded diagnostic prototypes. Distinguish
   subtree use summaries, reconstructed bodies, native signature/layout queries,
   and formatting. A root-only cache was already falsified. Do not spend hours on
   a representation rewrite if its measured removable fraction is too small.
2. Implement surviving changes as immutable Bend facts or structured lowering
   products. Preserve source KTerm ABI and source spans; do not repurpose binder
   IDs as cache identities. Raw/error/device demand stays unchanged. Prefer exact
   complete C output so runtime performance remains protected.
3. Evaluate reusable library products only with precise context/dependency and
   relocation boundaries. Keep preparation and cache contracts explicit. Cached
   requests must not be relabeled cold algorithmic improvements.
4. Evaluate genuine B2 release packaging separately from algorithm gains. It is
   already faster but must retain genuine lineage and compiler qualification.
5. Run final balanced B1/B2/upstream requests and selected integration gates only
   after the fast screen demonstrates useful gains. Exact C and executables on
   all twelve runtime families protect prior performance; changed C instead
   requires paired runtime timing. Check self-source acceptance, exact B3 and
   installed CLI before any release promotion.

## Fast/slow loops and resources

Use checked B1 builds (about 35 seconds) plus the three-source fresh request
screen. Add small non-harness and growing user-function fixtures to reject
benchmark-specific wins. Diagnostic image edits only estimate headroom; no
production speed claim comes from them. Freeze source/method/tool identities
before each run, retain failures, and use fresh attempt/output paths.
One heavy CPU3 process tree, 2 GiB RSS, 4 GiB available-memory floor, Node
1 GiB heap/4 MiB stack. Read-only analysis is independent. Track wall time,
selected changes, rejected attempts and resource outcomes in the report.
Phase75 is sealed; inherited dirty files and older releases remain untouched.

## Acceptance

Maintain checked reports and complete output semantics. Distinguish fresh request,
imports, preparation, Clang and program execution. A two-hour prototype should
show a credible large saving before architectural expansion; revise the approach
when evidence contradicts the estimate. Parity is a target, never an assumed
outcome. Publish design, measured decisions and comprehensive report, commit
and push meaningful checkpoints.

## Evidence-driven refinement: scalar decisions

Per-definition attribution found a larger opportunity than generic occurrence
memoization: a single ordinary character pattern expands to 1,421 erased nodes.
The pinned upstream `mat_lits` algorithm retains known-bit rows and compares
reconstructed defaults. Implement this in a separate Bend native pattern module,
then retain successful rows during the existing private-tree preparation pass.
Do not recognize source function or benchmark names. Require all 0–32 prefix
depths, inherited/distinct defaults, alpha-equivalence capture controls, private
input refusal, native U32/F32 and sharing tests, and twelve-family runtime timing.

The smaller tree is shared by generic and worker lowering and occurrence queries.
Unsupported shapes keep the old path. Reference source and original erased
observer inputs stay intact. Classifiers must reject ordinary heads before
constructing intrinsic metadata; a shared lazy admission removes duplication.
These are cold algorithm changes, not precomputation outside the request clock.
Do not add runtime alignment hints on an inconsistent short-run observation.

## Selection after runtime evidence

The scalar-pattern hypothesis succeeds at reducing compile-time work, but does
not meet the no-runtime-regression constraint. Keep its source/controls/results
as an unpromoted experiment, and stop speculative native alignment tuning.
Qualify explicit short-circuit native admission and representation certificates
independently, with exact generated C on all twelve families. No backend cache,
new default stage or runtime flag may obscure the remaining parity deficit.
The next large experiment should retain an immutable lowering product with
relocatable IDs while preserving emitted code, or investigate pattern compaction
with actual hardware counters on a suitable machine. Both remain hypotheses.
