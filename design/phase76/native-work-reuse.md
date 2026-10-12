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
