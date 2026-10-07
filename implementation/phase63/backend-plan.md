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

## State09: retain arity in existing call facts

Ordinary body scanning already computes `jd_arity`. State09 keeps that exact
value in a `JDArity` marker on the call-analysis row, carries it through SCC
group construction and stores it inside the existing per-definition call fact.
It adds no new index, body scan or generic cache framework.

Private emitter consumers use `jd_emitted_arity` only for a definition of their
completed immutable call context. Native/foreign rows without a recorded value
and absent call facts fall back to `jd_arity`. The original raw query remains
unchanged for arbitrary caller-supplied books/definitions. There is no claim
that a name-only arity fact survives mutation of a context or definition.

The source adds 19 Bend lines for these retained facts. State09 also removes the
four unreachable old host tail/field traversal helpers and carries frontend
suffix fragments directly, yielding 11 fewer Bend lines than State06 overall.
The live `jd_host_marshal_tail_done` helper remains shared by the field plan.

Root reports strict checked36, 558 exact arity queries, full-module equality
and fallback controls passing. A direct balanced B1 comparison is approximately flat for
Numeric and Lexer and about 3.4% faster for MapSet. These are State06/State09 B1
observations, not a broad B2 or installed-release claim. Final qualification and
the B2 comparison remain pending in the [phase report](README.md).

## Follow-up: reuse completed queries rather than add another pass

After plan reuse, the Map CPU profile still attributed substantial inclusive
work to host conversion and arity/type queries. The host field candidate in
[backend-host](../../selfhost/tools/performance/phase63/backend-host/README.md)
computes constructor field converters once, preserving their original fuel,
order and last-self-tail selection. The State06 owner applied that patch only
after checking its source contract and exact output controls.

A second candidate reused checked application-spine annotations to avoid
reconstructing dependent argument telescopes. Its exact query/module controller
passed, but the first whole-request screen did not show a useful gain. The
candidate stays recorded under
[typed-spine](../../selfhost/tools/performance/phase63/typed-spine/README.md);
source simplification and net request time take precedence over removed query
counts. The production base used for the next arity candidate has reverted that
49-line experiment.

The next diagnostic instruments the genuine State06 B2 with exact-identity
WeakMaps, independently for arity and weak-head normalization. This is an
opportunity experiment, not a host-language production compiler optimization.
On the first Map screen, arity made 756 queries with 523 hits and 233 misses over
three exact book identities. It avoided 8,075 WNF wrapper entries. Single-run
request times were 1,443 ms baseline, 1,331 ms arity, 1,379 ms WNF and 1,332 ms
both. These observations suggest arity reuse is worth a small prototype; they
do not establish stable speed gains.

The first Numeric baseline was invalid for performance comparison: it created
the Base cache and took 3.62 seconds, while later workers read that cache. The
original receipt remains unchanged and must not support a speed claim. The
[v2 controller](../../selfhost/tools/performance/phase63/backend-host/memo-query-v2.md)
requires the exact preferred frame to exist before the request, pins its bytes
before/after, records actual reads and forbids cache writes during measurement.
All memo variants use the same supplied-API driver lane, which is itself distinct
from ordinary owned-API request latency.

The resulting production candidate is deliberately narrower than that identity
memo: [call-arity](../../selfhost/tools/performance/phase63/call-arity/README.md)
retains arity at the exact point where the existing call-body scan already
computes it. A tagged private fact passes through the existing SCC grouping
into the existing per-name fact index. Emitter and host consumers reuse it;
call analysis itself remains raw, and native/foreign/missing entries fall back.
This adds 19 lines, with no new index, prepass, type or mutable state. The public
`jd_arity(book,d)` stays unchanged because arbitrary same-name definitions cannot
safely share a cached answer.

Independent source review found no change to demand, call-row evaluation order,
budgets, component leaders/widths or bounce fields. Internal metadata gains an
explicit arity child; complete emitted modules remain the equality oracle.
At the time this sub-report was written, the root was preparing State08 and
its exact-query/module controller. No production speed gain is claimed for this
unmeasured candidate here.
