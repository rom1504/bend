# Strictness repair and diagnostic query

Keep version01 unchanged and unselected: Bend eagerly evaluates Boolean operands,
so its conjunction did not enforce the size gate before the new traversal.
Version02 uses nested `nt_choose` for type eligibility, size, arity and traversal.
The worklist additionally spends a maximum of256nodes and short-circuits exact
matches through `nt_choose`. The original dependency check is retained.

Use `strict-subterm02.bend`, overriding only `nq_layout_leaf`; do not combine both
module versions. `p123l_inspect(request,name)` returns the candidate NQ signature;
`p123l_type(request,name)` returns its checked type telescope. Query `rle` and
`rle.step` before generating QBE. A strict subtree must occur literally after the
existing field-head resolution: if aliases obscure it, decline rather than add a
new normalizer. Correctness output and actual transformed activation remain
separate checks. No source check, target run or build was performed by this audit.
