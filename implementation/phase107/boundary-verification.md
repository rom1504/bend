# Optional pipeline with boundary verification

Prepared source only: no checker, compiler, runtime or timing target was run for
this change. The hypothesis and remaining gates are in
[P107-008](../../experiments/phase107/P107-008-boundary-verification.md).

[`inline/pipeline.bend`](../../selfhost/tools/performance/phase107/inline/pipeline.bend)
adds 80 lines and 12 functions, with no new IR/type, verifier, transformation engine
or production change. Append it after the existing Phase107 optimization modules;
export only `nx_pipeline_fast`. Existing standalone pass files remain unchanged.

The new wrapper performs one input verification and, for valid input, one final
verification using the existing `nx_r_finish` fallback. Private orchestration
reuses tail, inlining, reachability, memory and folding cores. It keeps every
capacity/eligibility limit and exact deterministic pass order. Demand expansion
still sees original callee bodies and shares entry-returned fuel with remaining
functions. Both internal prunes preserve direct and address-taken references.

The wrapper skips intermediate verifier calls; it does not cache or weaken the
verifier. Exact equivalence depends on each internal core preserving validity.
The checked composition is retained as the reference, with intermediate validity
and complete products required by
[`pipeline-controls.json`](../../selfhost/tools/performance/phase107/inline/pipeline-controls.json).
Malformed input is unchanged; a malformed final candidate falls back to the
original. Neither behavior constitutes a proof of whole-pipeline semantics.

Source/data checks found no new definition-name collisions in Phase106/107 and
confirmed the reused transformation cores do not invoke public guarded passes.
All manifest source hashes are recorded. Bend parsing/type checking and exact
product/runtime comparisons remain root-owned pending targets; no speedup is
claimed. Savings would affect optimizer latency, while final verification,
eligibility scans, node counting, renaming and serialization remain real costs.
