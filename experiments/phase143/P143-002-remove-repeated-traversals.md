# P143-002 — remove repeated cold traversals

Two small structural hypotheses, kept separate until measured:

1. Ordinary `nr_walk` still performs linear membership over its growing done
   list. The incremental owner path already avoids that search. Reuse the same
   collision-safe set without any incremental cache machinery. Preserve exact
   queue/name/fact order, initial done/facts, missing/native/foreign definitions
   and every erasure computation. Historical ordinary `nb_contains` context is
   about3.08% of samples, not this caller's exclusive cost. Plausible whole-build
   saving is a few percent, with larger scaling gains only as a discriminator.
2. `nd_comb_fresh` repeatedly scans one immutable body and argument list for a
   sequence of fresh IDs; two active callers use64 IDs. An exact local occurrence
   summary can replace up to128 syntax walks. Preserve zero-count laziness,
   Var-leaf traversal, environment collisions and U32/nc_id wrapping. The recent
   raw-stage occurrence contexts cover20.62% of a cold-seed interior, not an
   ordinary whole-build or caller-exclusive saving estimate. Measure summary
   construction and small-arity losses before selecting it.

First gates: independently checked append-only old/new APIs; exact complete
results on actual compiler products, finite boundary controls and valid generated
source-size workloads. Native integration only after useful measured work removal.
Neither hypothesis changes final verifiers, proofs or optimization policy. Do not
claim the150s milestone from component ratios.
