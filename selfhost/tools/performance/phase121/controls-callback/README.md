# Independent callback source controls

`callback-controls.bend` contains ordinary checked-source candidates, with helper
definitions before use. Fifteen cases cross counts0/1/2/17/257 and
seeds0/1/4294967295. Each prints count, seed and three complete results:

1. `braided`: renamed generic composition/factory, capture
   `add(mul(from_nat(pred),4294967291),7)` and leaf `add(mul(value,33),capture)`.
   This should admit the new scalar callback fusion.
2. `through_escaped`: obtains the same function from an escaping `escaped`
   definition before applying it. Both public roots should refuse this fusion.
3. `backwards`: uses well-typed `link_back(A,B,C,f:B->C,g:A->B)` returning
   `x => f(g(x))`. It must refuse forward-composition admission and evaluate in
   the opposite order. The independent model asserts that the two-element
   cases distinguish the orders.

`prepare.py` generates the75-line independent expected stdout through arithmetic
loops, preserving each U32 wrapping point. Exact sources, model and expected data
are pinned in `manifest.json`. No compiler or target run was performed during
preparation. Actual activation/refusal inspection and generated-program output
checks remain separate required observations.
