# Phase155 pipeline tournament: IDs 14–16

Prepared against maintained source at `c9de3ee`; no target executions, production
edits or performance claims. Root owns checked/native screening. The additive
[module](../../../selfhost/tests/phase155/pipeline.bend) exports two old/new
`(n: U32) -> String` pairs and `p155b_controls() -> Bool`. The
[spec](spec.json) records the common harness interface; no additional experimental
modules are needed, only the current compiler declarations reached by these roots.

**14 — reject the apparent ready-index opportunity before benchmarking.**
`p126bp_close` does reconstruct candidates, but ordinary preparation goes through
`p128raw_plan_finish`, retaining the original raw candidates. Its late closure
uses `p128raw_close`, which passes those retained values to the original
`p113d_passes`; `p113d_pass_function` already drops ready names before dependency
admission. Timing the old replay path would manufacture a saving absent from the
current ordinary route. Initial raw lowering has no final ready index. A private
worker's readiness alone does not prove its generic entry, continuation, closure,
descriptor or static references dead, nor preserve encounter-order IDs. No
benchmark pair is offered for this already-addressed case.

**15 — a residual duplicate use-set in flat binding.**
`flat-products.bend:p113pl_bind_flat` calls `nc_uses(body)` for `p111_keep` and
`nc_live_env(env,body)` for held bindings. The latter builds the same set again
for nonempty `env`. `p113px_known` still reaches this function after reconstructing
the continuation body. The boxed path already uses `p112_liveness_uses(rest)`;
ordinary constructor and bangs catalogues are already shared by Phase144. Those
older improvements are explicitly excluded.

The witness compares the exact two original consumers with one shared immutable
`NU_Set`. It constructs a fresh compiler-shaped term, runs both complete consumers
and renders every produced keep's destination/type/symbol/arguments plus every
live binding's ID/name/kind/order. Mixed owning/nonowning bindings, duplicate IDs,
maximum U32 IDs, unused bindings and malformed Var-with-child semantics are
covered. This isolates the remaining analysis seam; it does not include body
substitution, recursive lowering, emission or final verification. A win therefore
requires a later complete flat-binding transfer before promotion or any regional
estimate. `n` creates n repeated five-variable branches, including preparation.

**16 — fuse immutable body summaries, without crossing a rewrite.**
The reference runs current `p113i_clean`, `p113i_size` and `p113i_stack` over the
same actual direct/scalar statement grammar. The candidate visits each nested
body once, preserving leaf policies, 4,096 node saturation and 65,536 stack
saturation. All three results are consumed, not only eligibility. Construction,
temporary summary allocation and output text remain in the kernel cost. Generated
n-block fixtures have independent expected `clean`, size `min(4096,7*n+1)`, and
stack `min(65536,96*n)` within the tested range. Additional controls cover dirty
names, a refused scalar return, nested branch shapes, all scalar leaf classes,
oversized allocations and saturation.

This is a reusable-analysis discriminator, not an optimizer replacement.
`p113i_function` analyzes the original body; `p113i_functions_step` may publish a
rewritten body through `p113i_table_function`. Any integration must compute fresh
facts for that rewritten body. An unchanged-body correspondence or explicit
summary transport is required before reusing facts across consumers. Original
parameter/result/budget/return checks and independent verification remain intact.
This kernel's full tuple may do more work than a short-circuit admission failure;
no speedup is assumed, and boxed summary overhead may make fusion slower.

The controls are compiler-data observations, not unsafe native failure probes or
BendTT proofs. No whole-compiler savings follow from these synthetic inputs. Stop
after the shared small screen if gains disappear under construction/observation,
or if only the obsolete ID14 path can support a headline.
