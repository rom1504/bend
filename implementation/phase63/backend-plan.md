# Phase63 single-lowering backend prototype

Status: source candidate prepared for root qualification; no compiler, target,
benchmark or test has been executed by the implementation agent. This report
does not claim correctness admission or a speed improvement.

## Removable work and chosen architecture

Phase62 found 361 ms mean backend work against 120 ms in the pinned TypeScript
compiler. That is the whole backend budget, not the savings available to this
change. The current driver first calls `jd_reach_selected`, which builds a call
graph and lowers each visited definition to JDText to discover exact runtime
references. It discards those documents. `jd_library_selected` then constructs
another call graph and lowers the retained definitions again.

The prototype in [reach.bend](../../selfhost/src/back/js/direct/reach.bend)
introduces a request-local `JDPlan`. It owns one immutable annotated lookup book,
one set of call/SCC facts, retained source definitions, and the lowered text for
each visited definition. Reachability consumes the existing JDText metadata,
then renders and stores that definition once. Final library emission concatenates
the stored definitions in original source order and creates host exports using
the same owned context.

The existing exact-name persistent index doubles as the visited set and text
store. Each entry has the private kind `JDPlanText`; its value carries the final
String. This avoids a second index, a linear search through saved documents, or
a new general-purpose intermediate representation. JDText remains responsible
for local demand and exact emitted dependency metadata. Text rendering moves
into the plan rather than introducing a second rendering pass.

The old `jd_reach_selected` and `jd_library_selected` APIs remain available for
older compiler images, program-mode fallback and controlled ablation. The first
driver integration is library mode. The new API is:

- `jd_plan_selected(contextBook, annotatedDefs, roots) -> JDPlan`
- `jd_plan_error(plan) -> String`
- `jd_plan_defs(plan) -> List<KDef>`
- `jd_plan_library(plan) -> String`

No new module, manifest entry, generated-code convention or runtime support is
required. All compiler algorithms remain in Bend; the JavaScript driver only
selects the API and coordinates foreign files and output.

## Context contract: the real architectural change

This is not a cache that replays a result under a different book. The plan keeps
the exact book under which its code was generated until final emission.

There is nevertheless an important change relative to the old pipeline. The old
reach pass overlays **all selected annotated definitions** on the checked book;
the old final pass overlays **only the retained annotated definitions**. A type
alias used during lowering can therefore resolve to different KTerm objects in
the two passes. Phase61 correctly rejected unguarded cross-context text reuse.

The proposed canonical context retains the complete annotation overlay for both
passes. Runtime pruning determines emitted code and foreign initializers; it
does not remove type information or revert aliases in the lowering world.
Annotations originate in the same checked source world, and `wnf` removes `Ann`
without decrementing its evaluation budget. Those observations are useful, but
they do **not** alone prove identical native classification, telescope facts,
quantity transformations, host marshalling, or all bounded refusal behavior.
`ka_def` can also beta-reduce or transform literal/quantity terms. Qualification
must explicitly challenge that boundary rather than treating finite matching
outputs as a universal proof.

## Preserved local contracts

The prototype retains the original initial call-analysis admission, 4,096
definition bound, 65,536 reach-worklist bound and 2,097,152-character per-document
metadata bound. Duplicate worklist entries still consume edge fuel. A new name
consumes definition fuel before lookup; missing definitions and malformed or
unknown references return the original reach error strings. JDText reference
validation occurs before a document enters the saved index.

Only visited definitions are lowered. Unreachable bodies are not eagerly
compiled by the new plan. Call-analysis admission still visits the same initial
selected definitions, including its existing tail-node and graph-edge budgets.
Runtime references still come from the actual demand-pruned emitter, with its
numeric row selection, erased parameters and constructor folding.

SCC leaders still emit explicit references to every member, while member
wrappers reference their leader. A reached component therefore retains the
whole emitted dispatcher. Member order, widths and program-counter IDs belong
to the one plan context. Final definition order remains the original filtered
source order, independent of reach traversal order. Host exports run against the
same call facts, so their forcing decisions cannot disagree with saved bodies.

Foreign path selection, foreign initializer generation and runtime layout checks
remain outside the plan in their current driver positions. A rejected plan has
empty definitions and cannot be rendered successfully. The private missing-text
failure detects a broken internal plan rather than silently emitting nothing.

## Required discriminating checks

1. Compare all 23 complete library outputs with the frozen current compiler.
   Keep any difference as a failure requiring investigation; do not replace the
   oracle because the new architecture seems reasonable.
2. Separate three observations: old pruned-context final lowering; fresh lowering
   under the plan's canonical context; and rendering the saved plan. The latter
   two must match exactly. The first comparison isolates context changes from
   actual reuse mistakes.
3. Exercise erased-only aliases, dependent parameters, annotated native type
   aliases, literal aliases, host Nat/non-Nat classification, foreign IO,
   dead-let demand, numeric dead branches, self and mutual tail calls, unknown
   closure tails, partial application and unreachable unsupported bodies.
4. Reuse the existing reach/JDText boundary controls, adding the plan's visit and
   document adapters. Check exact/over definition and edge fuel, missing and
   duplicate references, malformed metadata and the document cap. An early
   rendering exception or altered refusal remains a regression.
5. After the focused source and emission checks, compare clean whole requests
   with the existing short loop. Measure peak memory: stored text remains live
   until final emission, although lowered trees no longer need to remain live.
   A decline in counted lowerings without a request-time gain is insufficient.
6. Qualify native/program fallback, public values and genuine B2/self-emission
   only after the candidate survives those cheaper gates.

## Remaining limitations

This removes a second call-analysis and lowering pass for library compilation;
it does not eliminate the first pass, annotation, frontend reconstruction or
host-type analysis. The public standalone legacy API keeps its original behavior.
Programs still use the old direct path until their separate entry/readback
contract is integrated and qualified. No expected numerical gain is promoted
from the source change alone.
