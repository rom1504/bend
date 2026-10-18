# Demand-aware inlining

Closing status: implemented, qualified on finite controls and retained in the
experimental pipeline. The [phase report](README.md) supplies current composed
runtime/optimizer findings; this note preserves the original policy rationale.

The optional 56-line `inline/demand.bend` adds `nx_inline_demand` without editing
`entry.bend` or any production compiler source. It reuses the existing verifier,
purity summaries, inliner work records, function-order restoration and complete
direct/address reachability scanner. No new IR or runtime representation is added.

The policy runs entry optimization first, prunes once, then processes surviving
non-entry functions once with the original callee list and remaining shared
fuel. A final prune/verifier check preserves validity and original definition
order. `nx_e_restore` uses the pruned list at the final stage so absent definitions
are not accidentally restored. `NxFunc` references remain roots. Zero budget,
invalid input and the outer capacity limits return the original program.

The two pruning points deliberately avoid a subtle dependency hazard: although
an earlier optimized helper may no longer reference another definition, a later
expansion of its original body can still need that definition. Keeping the
initial reachable set through the remaining pass makes original-body expansion
safe without dynamic dependency repair. The tradeoff is that some helpers made
dead during the remaining pass may still be optimized.

The hypothesis and admission criteria are in
[P107-005](../../experiments/phase107/P107-005-demand-inlining.md). The new
[`demand-controls.json`](../../selfhost/tools/performance/phase107/inline/demand-controls.json)
pins existing source/control inputs and specifies reused fixtures plus
invalid-input refusal. No fixture oracle was changed. Preparation included only
source/data inspection; parent-run
[demand-audit01](../../selfhost/build/phase107/demand-audit01/report.json) later
passed 88 transformation pairs, 272 distinct model executions and three detected
semantic mutants. The initial approximately 473 ms `many` pass cost motivated
the experiment; it is not a matched denominator for every later composition.

[Artifacts06](../../selfhost/build/phase107/artifacts06/report.json) and
[measure07](../../selfhost/build/phase107/measure07/report.json) use demand-aware
composition. They do not isolate a standalone demand-policy speedup. Repeated
structural verification remained expensive, leading to the
[boundary-verification experiment](boundary-verification.md), whose exact-product
and warmed timing evidence has separate scope. Global purity scans, renaming,
verification/pruning and serialization still cost work. Production defaults are
unchanged; neither composed finite equality nor local laws prove all rewrites.
