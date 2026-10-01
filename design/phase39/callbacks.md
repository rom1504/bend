# P39-004: known callbacks before fusion

Prospective design, 2026-10-01. Baseline: installed Phase37 checked03. Start from
actual function-valued inputs and dynamic captures; do not infer them from a
benchmark name or from generic runtime `apply` samples.

## The first static result changes selection

The current list pipeline is **first order in the source**. Its bench calls
`suma(dbl(keep_gt1(p37.list(...))),0)`. The fixture explicitly replaces generic
mapping with specialized recursive functions because of affine checking.
It cannot demonstrate callback specialization. Its dispatch cost belongs to
known first-order recursive components, and must retain that experiment owner.

The closures fixture does contain `compose` and a recursively built `chain`.
Each level captures a dynamic scalar offset and another closure. This is a real
callback case, but it has no materialized list. Inspect it independently rather
than promising a list speedup from that mechanism.

## Small discriminating experiment

Author a separate fixed-signature scalar callback fixture with explicit dynamic
captures and a materialized input/result list. Keep list construction, traversal
and reduction unchanged in the direct-callback variant. Compare baseline,
direct-but-unfused and pinned TypeScript output. A future fused variant is a
separate hypothesis with direct-unfused as its comparator.

The first signature is U32 to U32 with a captured U32 parameter. Preserve each
capture's evaluation exactly once and its original lifetime. Do not introduce
arbitrary callback types, environment recursion or a whole closure-analysis IR.
If the language cannot check the reusable callback fixture, retain that refusal
and use a checked specialized witness rather than claiming an unchecked program.

Current `JPure` rejects function-valued arguments and fields. A direct emitter
case does not fill this proof gap. Any production proposal must prove the exact
callback code, closed capture values, complete saturation and public fallback;
it must not admit a function merely because it has the expected source name.

## Controls, bounds and stopping

Use zero, one and non-cycle list lengths, varied offsets/seeds, complete small
list outputs and an independent integer oracle. Include multiple callback
identities, partial/extra calls, retained closures, changing captures, getter
reentry, native replacement and early/late callback errors. Keep arrays/lists
materialized so allocation removal is not confused with call specialization.

Count generic transitions and actual direct callback entries in a separate
diagnostic module. Time clean variants only, first under 20/60-second ceilings.
Root alone executes target/build/profile work under the recorded serial limits.

Stop if no real callback remains, dynamic environments require a broad new proof
system, source checking refuses the intended affine reuse, or direct calls do not
improve clean timing. Keep first-order list findings even if callback work defers.
The current fallback and conformance results remain unchanged until scoped
semantic gates and an actual compiler candidate establish otherwise.

Findings and acquired identities go in
[the implementation report](../../implementation/phase39/callbacks.md).
