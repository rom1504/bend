# Tree residual wrapper dispatch

Prospective hypothesis, 2026-10-03. Correctness unchecked, measurement not run,
decision investigate. Installed denominator is Phase40 checked06, unchanged pin
018751270e800bc222a93dad7f257083ee53a5f7. Root owns every execution job.

The existing flow structural worker still evaluates saturated `warp_node` through
two generic calls per nonzero Node (checked06 tree-bitonic.mjs line792).
`warp_node` itself already dispatches directly to the existing warp structural
worker after its Node match (line790). Its Leaf result must remain a fresh Leaf.
The compiler component planner excludes this acyclic wrapper solely through the
positive-self-reference test in selfhost/src/back/js/tree.bend:154. The finite
selector proof excludes its named warp call in finite.bend:72.

Test only wrapper dispatch: replace saturated warp_node call sites in exact saved
checked06 output with a full-graph-guarded wrapper using the existing warp worker.
Keep both original generic fallback expressions and all tagged intermediate
values. Do not change warp, flow, constructors, frames, root entry or runtime.
Compare full shape values, child identity, fresh leaves, mutation/getter refusal,
error cleanup, uneven/shared inputs and 30000-frame stack behavior before timing.
The unchanged/noise pair must be byte identical. A tree8 screen is the cheapest
performance falsifier; no meaningful gain defers compiler integration.

If the ablation survives, consider admitting acyclic ADT-first wrappers only when
they directly call an independently admitted structural component. Reuse the
existing typed component prefix, leaf emitter, complete pure graph and backedge
checks. Do not globally remove the positive-self-reference gate, introduce named
benchmark admission, broaden scalar-first selection or bypass stronger islands.
Zero own references is insufficient: retain `j_component_backedges` over the
entire admitted graph against the wrapper name. A worker-to-wrapper backedge
would otherwise introduce depth-proportional native wrapper calls.
This source criterion remains prospective; saved-output results cannot establish
actual compiler admission, source proof soundness or normal request cost.

Budget: investigation20minutes, first candidate5minutes, derivation<1second,
controls estimated2–5seconds/200MiB, tree8 screen20seconds. Root runs all jobs
serially with the established CPU3/Node24.18/heap1GiB/RSS2GiB contracts. Report
investigator wall time separately from queued execution time.
