# Preserve the dependency cost of eliminated ownership wrappers

The projection optimization shortened a worker's dependency chain as well as
removing its discarded result tuples. The existing three-round forced-inline
policy consequently forced the owned cleanup wrapper and additional callers
into their parents. Root's saved-C ablation isolates this hint change as the
cause of the local-fold regression: restoring the prior hints restores parity
while retaining the optimized observer body.

This candidate changes one expression in `nfp_replaced`. Successful projection
keeps the old dependency list followed by the new dependency list, rather than
replacing the former. Membership-based consumers treat this concatenation as a
conservative union; duplicates have no semantic effect. Every actual new call
remains represented. The original dependency horizon provides a stable cost
floor across this wrapper-elimination rewrite, so fewer calls in the rewritten
body do not automatically justify more forced inlining. Clang remains free to
inline ordinary `INLINE` functions.

The pass operates after original worker admission, and the original dependencies
already satisfied readiness, including its existing native-definition exception.
Audited `NF_Worker.deps` consumers are readiness and
forced-inline membership checks; emitted bodies, parameters, results, scheduler
wrappers and ownership cleanup read other fields. Late scalar routes can add
conservative edges as before. No worker name or application selects this rule.

The fixed-point argument is simple: eligibility and emitted code stay identical
to the parent; replacement dependency sets only grow. By induction, each of the
three immutable selected-name sets is a subset of the corresponding parent
set. Thus this edit can only demote forced hints. It preserves dependency cost,
not the original body's byte budget: a future rewrite crossing the size cutoff
may still warrant a separate profitability decision. This is an intentionally
small conservative policy, not a general inlining cost model.

`prepare.py` authenticates and composes the exact parent recipe and verifies
full inversion to the installed Phase98 source. It runs no compiler or target.
API admission and actual hint-only output comparison must precede timing and
native-chain qualification. Consumed parent candidates and methods remain
unchanged.

The saved-C graph model in `projection-cost-model01/report.json` checks all 45
native runtime-continuity products and all 17 focused application/control
products. Their actual C graphs reproduce the current forced hints exactly.
Adding the original structural composition's edges predicts exact restoration
of every prior hint on all 62 products, without extra or missed demotions.
Local fold loses exactly four forced-hint tokens on two workers. This is a
data-only prediction for those products.

Root's later `projection-cost-api01` checked acquisition passes. The offline
`projection-cost-activation02/report.json` audit confirms its three actual app
products differ from qualified candidate03 only in forced-inline tokens, and
restore exactly the depth02 hints: two workers for indexing and graph planning,
three for rendering. All optimized body and ownership bytes are unchanged.
Four actual runtime products also equal the retained hint-ablation C byte for
byte. Their exact builds, binaries and complete raw outputs authenticate 32
matching-product observations inside the 128-observation four-role comparison.
These are inherited observations, with zero fresh executions by this audit.
The early activation01 snapshot pinned an unfinished mutable batch manifest;
it is retained with an explicit invalidation note and superseded by activation02.
This does not qualify a native candidate04 image or establish fresh runtime gains.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase102/projection-cost/prepare.py \
  --parent selfhost/build/phase102/projection-cold-source01/changes.json \
  --out selfhost/build/phase102/projection-cost-source01
```
