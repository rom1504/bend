# Imports-only ablation

Question: can explicit verified direct imports provide the useful call-path and
registry savings without replacing generic lowering or adding a mixed verifier?
This is an independent experiment, not an optimization attributed to omitted
generic bodies.

Acquire the maintained source with only
`selfhost/tests/phase164/hybrid-imports-only.bend` and its optional finite controls.
Do not include the mixed or retained-original modules. There are two renderer
overrides: `p134e_prepare` and `p134e_private`. Call the original `p134e_plan`
entry and use the original `p134e_begin`/`p134e_next` streaming protocol.
`p164j_summary` accepts an already completed plan and counts original segments,
final direct functions and selected imports; it does not run lowering.

The complete original generic bodies, original verifier, direct verifier,
optimization pipeline, static image and descriptor fields remain. A selected
original segment must have zero incoming captures, zero flags, one result and
at most 32 arguments. Its final direct signature must be public and match that
arity and single-result ABI. This is the same public identity already used by
the existing backend's checked direct public wrapper. The proposal grants no
authority to a raw signature supplied independently of that checked pipeline.

Selected owners enter the existing ordinary-worker registry at rank zero with
an actual `p112w_*` to `p113d_*` forwarding function. They do not receive invented
generic worker plans. Their real original bodies are excluded from registry
candidate construction to avoid duplicate private symbols, while the **full
original fusion index** remains available to all legitimate generic analyses.
Every other candidate uses the old analysis and bounded registry passes.

The renderer preserves the original array, live-register and cold-constructor
capability policy exactly. The forwarding ABI matches the existing public
direct worker ABI; no scheduler callback or runtime operation is newly admitted.

Compare complete emitted sources and independent runtime outputs on the same
three cases as the mixed candidate. Report hosted lowering/render cost and
generated runtime separately. This route retains generic construction cost;
any compiler saving should come from registry analysis/emission or changed
downstream machine input, not be credited to skipped generic lowering. Likewise,
a runtime gain would support composable direct imports as a mechanism without
proving that body omission caused that gain.
