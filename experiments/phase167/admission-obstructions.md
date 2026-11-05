# Phase167 — the admission barrier is not eleven bad functions

Offline analysis of the completed `reasons01/report.json`, produced from the
same checked verifier workload. No compiler or generated program executed here.
[Machine-readable graph census](admission-obstructions.json) and
[reproducible analyzer](tools/admission-graph.py) pin that receipt and retain
every error, SCC member, blocked row and dependency-only counterfactual.

## Exact populations

127 raw candidate identities contain116 empty-error rows and11 error rows.
**55 raw candidate owners** occur in the admitted output; the generated tail-SCC
helper `$p126scc.0` brings final functions to56. The other61 empty-error candidates
all have missing admitted callees. No missing callee in those61 is absent from
both the candidate catalogue and final admitted population.

There are **four additional error-free blocked SCCs**, beyond the11 explicit
lowering-error sites. Partitioning the61 by transitive obstruction gives:

| Error-free blocked candidates | Count |
|---|---:|
| Reach blocked cycles but no explicit-error row |20|
| Reach both blocked cycles and explicit errors |32|
| Reach explicit errors but no blocked cycle |9|

Thus “fix eleven errors and all61 admit” is false. Conversely, simply increasing
the32-pass admission budget cannot remove these dependency cycles or error sites.
The graph counts describe structural readiness, not physical hotness.

## Distinct cycle obligations

| Error-free SCC | External unadmitted prerequisites | Blocked rows reaching it | Dependency-ready if this SCC alone were safely discharged |
|---|---|---:|---:|
| `String.cmp ↔ String.cmp.fin` |None|46|16|
| `index_remove ↔ index_remove_step` |None|6|4|
| `p111v_body ↔ p111v_stmt` |Calls/join/value/memory/operator/offset/step paths|13|0|
| `$product.p111v_schema ↔ $product.p111v_schema_stmt` |Comparison and declaration paths|15|0|

The first two are closed against already admitted dependencies and are independent
root obstructions. The other two add real cycle obligations even after their
external blockers are repaired. Fixing both closed SCCs makes20 existing
error-free rows dependency-ready in this graph. Discharging all four cycles still
makes only20 ready while the explicit errors remain. The affected sets overlap;
46+6+13+15 is not a count of additional functions.

These are genuine non-tail obligations in at least the two closed cases:
`String.cmp.fin` reconstructs strings after its recursive comparison
(`upstream-phase66/bend2/base.bend:1903`), while `index_remove_step` constructs
`Con{h,recursiveResult}` on its False branch
([core/index.bend:201](../../selfhost/src/core/index.bend:201)).
Existing `p126sc_pair_safe` requires an internal call's residual block to be
exactly its single result ([product-composition.bend:553](../../selfhost/src/back/qbe/product-composition.bend:553)).
Bypassing that rule would introduce unrestricted machine-stack growth; the
counterfactual counts do not authorize doing so.

## Explicit errors and the cascade

| Error site | Diagnostic | Error-free blocked rows reaching it |
|---|---|---:|
| `p131i_insert` |non-tail self call|32|
| `p111v_name_chars` |non-tail self call|17|
| `p111v_args` |non-tail self call|16|
| `p111v_intersection` |non-tail self call|15|
| `p111v_raw_name_chars` |non-tail self call|10|
| workload `p167w_segments` |non-tail self call|3|
| `index_insert` |non-tail self call|2|
| `$product.p111v_body` |product result shape mismatch|2|
| `$product.p111v_stmt` |product result shape mismatch|0|
| `nt_choose`, `kc` |dynamic call|0 each|

The persistent update cascade is concrete:
`p131i_insert → index_set → p111v_put → p111v_assign/decl/...` when read as
“blocks its callers.” But32 is **not** the number immediately rescued by repairing
insertion. `p131i_insert` also depends on unadmitted `index_leaf`, `index_join`
and `p131i_original_set`; the legacy path reaches `index_insert`, whose own
non-tail recursion and helper cycle must be handled. Similarly, the body/stmt
cycle remains after local insertion or comparison repair.

Three explicit error sites have no reverse dependency among the61: the two
dynamic chooser workers and the optional product stmt worker. Their failure
counts must not be mistaken for equally useful root fixes. The workload's segment
builder is also a fixture computation, not necessarily a full-compiler hotspot.

## What changes the next experiment

The cheapest new architectural test is **semantic representation selection before
dependency admission**, beginning with the comparison SCC. The optimized compiler
already synthesizes a borrowed scalar comparison and composes its observers;
the reduced pipeline removed that later rescue. Generating that source-authorized
observation representation early could break a closed SCC and its16-row dependency
cascade without a general native recursion implementation. This must reuse the
independent borrowed-body/lifetime checks and regenerate actual demanded entries;
it is not permission to whitelist `String.cmp` by name or accept a fake boxed body.

For preserving recursive results such as index removal/insertion, a general
constructor-continuation transformation or explicit resumable frames is the
distinct required capability. Test it on complete persistent update plus retained
old-root consumption and an unrelated recursive tree, rather than another
handwritten insertion-only rewrite. The body/stmt and product schema SCCs then
test whether that capability composes across functions and product results.

The graph provides a precise reason to test these in order; it provides no
runtime gain estimate. Require full checked output, bounded stack/memory and the
already established compile/runtime quality gates. Failed candidate call lists
can be partial after the first error, so the analyzer treats errors as terminal
barriers. New successful lowering may reveal more dependencies and must be
recensused. All numbers here are specific to the current verifier workload.

## Completed observer experiment: the predicted cascade occurred exactly

The additive observer-before-admission module passed checked API acquisition and
all35 finite controls. The completed `observer-inspect01` receipt records:

| Quantity | Prior raw demand | Observer-first |
|---|---:|---:|
| Source names |117|117|
| Final direct functions |56|73|
| Generic fallback families |49|37|
| Demanded admitted factories |0|0|
| Adapters |38|36|
| Scheduled segments |1,223|983|
| Unique demanded identities |1,175|947|

Exactly **one source owner** was supplied by observer synthesis, producing two
seed functions.116 source names remained for raw lowering, yielding126 raw
candidates and71 nonseed admitted functions. Comparison with the retained old
direct-name set finds17 additions and no removals. The new reader is
`$p118borrow.read.String.cmp`; the other16 names are **exactly** the16 predicted
by the `cycle-0` dependency closure in `admission-obstructions.json`, not merely
the same count. That independently confirms the proposed dependency mechanism.
It does not show that any16 arbitrary functions would have equivalent benefit.

Matched fresh-process prepared-Base source-to-executable screens are
**31.343044s baseline →23.350522s observer-first (25.50% less)**. The two emission
receipts bind identical source, Base, checked API, preparation carrier and method
identities. Backend plus rendering is21.311187→13.627361s; the candidate's earlier
chunk materialization is included. These are single complete build observations,
not repeated medians or full self-compilation.

Four alternating runtime pairs give **0.437725s →0.649529s**, still
**1.48387× slower** than the optimized baseline. All eight samples have exact
`768\n`, empty stderr and exit zero. The runtime baseline is the retained
`clean01/baseline` product; its QBE is byte-identical to the fresh
`observer-baseline01` baseline, but their whole ELFs differ. Do not claim the
new baseline ELF was timed or that the ELFs are identical.

Evidence under `selfhost/build/phase167/`: `observer-controls01/report.json`,
`observer-inspect01/report.json`, `observer-build01/{report.json,emit/report.json}`,
`observer-baseline01/{report.json,emit/report.json}`,
`observer-runtime01/report.json`, and prior `inspect01/report.json`.

**Conclusion:** early semantic representation selection demonstrably breaks a
closed admission obstruction and recovers a precise dependent group. The combined
prototype compiles this real workload faster, but still fails generated-code
quality and does not establish a faster self-hosted generation, a promoted
compiler, or the10× complete cold-build target. The root's unrelated semantic
transfer is a separate gate; it cannot turn this runtime deficit into a pass.

### Final matched executable check

A subsequent bounded `observer-runtime02/report.json` run closes the earlier
retained-baseline distinction: it times the actual newly built
`observer-baseline01` and `observer-build01` ELFs in four alternating pairs.
Medians are0.441204748s and0.655356054s, ratio1.4853785. All eight outputs are
exactly768 with successful exit. The earlier runtime01 paragraph describes only
that preliminary screen. Both plain-demand and observer Map/IO semantic gates
also pass frozen value/count oracles (`map-oracle01`, `observer-map-oracle01`).
This does not change the failed runtime-quality gate or authorize promotion.
