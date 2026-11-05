# Phase165 — causal source bisection against bendc

Start `b78a8c4`, 2026-11-05. The user asks for a substantially more aggressive
explanation of the source/architecture gap, using controlled component replacement.
Do not continue adding isolated QBE optimizations before this experiment answers
a causal question. Preserve the qualified compiler and all production selections.

## First discriminating experiment

Identical source does not imply identical work across compilers: bendc replaces
six checker memo operations and selected Map/String operations with native
implementations. Its Bend memo fallback intentionally does not store results.
Our checker already memoizes through a different persistent heap. A reverse
source cross-compilation without accounting for this would be misleading.

Acquire private, source-derived bendc variants under the same pinned producer,
matching acquisition Base, Clang flags and bounded-search tracing runtime:

1. Original source/control.
2. Rename all six checker memo operations and their references, preserving their
   existing bodies, to disable native substitution.
3. Redirect actual checker lookup/comparison paths to namespaced copies of their
   complete Bend implementations. Keep unrelated compiler/backend code unchanged.
4. Test the combined policy only when the separate gates make it economical.

Use lexical identity/provenance checks, independent body checking, and emitted-C
inspection to establish that each knob affects actual calls. The operation
closures and acquisition cost are measured; host scripts must not become
alternative implementations of compiler semantics. Never patch generated C to
repair algorithm output or silently change policies after a failed comparison.

## What must match

Measured workloads use the exact Phase162 common Base, source bytes, one CPU,
one runtime thread, GPU off and fixed runtime policy. Acquisition Base and
workload Base are deliberately distinct and pinned. A successful source check,
an unsafe/foreign proof verdict, independent BendTT verification and generated
program correctness remain different properties.

Every accepted timing requires the complete expected exit/stdout/stderr, not
a verdict prefix: actual type errors can also start `SOME PROOFS FAIL`. Run tiny
valid and invalid controls first. Memo-disabled checking may hit finite fuel
or exponential normalization; bound sharing witnesses and stop before large
cases if they fail. Such a refusal is evidence, not a slow successful check.
Native cells and portable stubs have different intermediate observations; compare
the complete checker, not direct memo.same results as though they were equivalent.

Use the existing 182KB compiler input for transfer, then the3.085MB source only
when justified. Start with two reversed pairs for meaningful cases. Attribute
algorithms, native primitives, representation and runtime interactions separately.
Record output identities, complete time, CPU/RSS, actual changed call paths and
operation counts where they resolve an ambiguity. No new full self-host campaign
or broad program-runtime benchmark is needed for early semantic discrimination.

## Further source bisection

The backend must remain in scope: the prior census observed2.132 billion logical
allocation requests outside parse/check/report. Investigate a whole-function
capture/replay or common-target boundary, not another isolated fact-put loop.
Earliest portable frontend seam is parsed declarations; checked books contain
different memo/template/publication state and are not interchangeable records.
An adapter must preserve full semantic observations and be charged separately
and end to end. No universal IR rewrite is justified merely to create a test.

If a capability explains a substantial gap, attempt the reciprocal replacement
in our compiler on a small complete computation. If no such gap appears, reject
that hypothesis and move to backend work. Two promising differences warrant a
four-combination interaction test; do not add independent percentage forecasts.
The objective is an accounted-for gap, not a prescribed performance claim.

## Resources and deliverables

Root owns one guarded execution lane with explicit disk/RSS/deadline budgets
and the ordinary5GiB reserve. Bounded agents prepare/audit memo, lookup, semantic
controls and the next backend seam. No target jobs or recursive agent campaigns
in those lanes. Reuse existing evidence and exact archives; review any needed
reclamation explicitly before starting more work.

Commit the design, source transformations, exact evidence, negative results and
an honest report. Report source-to-IR separately from complete source-to-executable
cost; bendc's few-second emission is not a five-second full native build. Do not
change installation or post PR comments.
