# P69-003 — Construct known partial applications directly

- Owner: closure-factory agent; integration and native measurement: root.
- Registered: 2026-10-11, before implementation or target execution.
- Objective: native emitted-program parity through general closure lowering.
- Correctness: untested proposal; no compiler or release promotion.
- Measurement: source evidence only; no new execution result.
- Related: [Phase68 closure evidence](../../implementation/phase68/c23-parity-survey.md#4-known-closure-construction-can-remove-an-entire-stage).

## Claim and invariant

Known partial applications currently enter the definition's curried factory and
dispatch once for each supplied argument. A user definition whose actual leading
lambda telescope covers its whole native arity has no body work to perform at
those stages. Evaluate the supplied arguments in their original left-to-right
order, construct the remaining telescope with those words as captures, and let
its final closure jump to the existing full-arity direct entry.

The first implementation admits ordinary Ref heads, Def bodies, no foreign or
native primitive provenance, at least one argument, fewer arguments than the
native arity, and actual leading live lambdas equal to that arity. It does not
infer that a declared function type proves a lambda value. This retains the raw
fallback when matching, effects, errors or other body work precedes a missing
argument. Explicit bang calls, dynamic heads, exact/overapplication and escaping
unapplied names retain their paths. Ordinary calls to a definition also used by
a bang need threaded controls because metadata is conservatively per-definition.

Reuse existing let/lambda ownership lowering and direct-call ABI; do not add a
runtime representation or optimize names belonging to the measured corpus.

## Cheapest disproof and planned gates

1. Source inspect the exact admission and fresh-ID reservation, then build a
   checked B1 under root's sole guarded CPU3 target lane.
2. Compare independently specified typed controls: two/three-argument partials,
   an erased polymorphic prefix, multiple missing arguments, shared heap captures,
   stored and duplicated closures, different capture/argument errors, and ordinary
   versus explicit bang calls. Exercise one and four threads where appropriate.
3. Raw controls admit syntactic lambdas but reject a type-only function or matcher
   with early demand; foreign and intrinsic partial calls must remain unchanged.
4. Emit the closure family plus an unrelated higher-order control. Confirm fewer
   generic applies/environments before three balanced native timing rotations
   against current candidate and pinned upstream using the same Clang recipe.
5. Reject on any changed oracle/error ordering, invalid capture lifetime, material
   held-out regression, or absence of the predicted code-shape reduction.

The baseline added-cycle counts are 16,432 applies and 12,318 total allocations
versus upstream 8,224 and 8,214. This patch is expected to remove the extra curry
stage, not all dynamic application. Runtime gain remains unmeasured. Direct local
lambda capture specialization is a separate follow-up, not part of this claim.

## Preservation

Patch and source-only derivation live under
`selfhost/tools/performance/phase69/closure-factory/`. Root records selected image,
source state, exact commands and all output/measurement attempts in the Phase69
implementation report. This registration remains prospective and unchanged.
