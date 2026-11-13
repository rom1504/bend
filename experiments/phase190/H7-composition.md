# H7: legal coalescing and predicate composition

Hypothesis: copy/loop argument affinity can remove transport that weighted
coloring leaves behind, while known outer predicate results make immediately
nested equal/complement predicates redundant. Neither rule changes the
interference graph, runtime ABI, widths or fallback semantics.

Frozen final API: coalesce-api01, selected full source60b0b0265bca50d423beb865237800f53eeeb9f2e7caed270bf7be39933068d7.
The final focused controls pass12/24/9 metadata cases for coalescing,
complements and local values. Independent C observations pass in both object
and assembly formats. This is finite evidence, not an equivalence theorem.

Four balanced runtime06 rounds on the six frozen development programs:
bundle0.758268× freshly timed baseline and3.368413× mature C. Fold is
0.367119× baseline, with27 hot instructions and zero frame references versus
66/21 originally. Same-run local predecessor is0.868552× baseline.
The two additions were measured together; their individual effects are unknown.

All six beat baseline. Against local, Map regresses3.827%, expression0.982%;
expression has1.175× max/min spread. Retain all observations. No claim that
these six results establish broad parity, native qualification or installation.

Selected for held-out/native testing. The next instruction-selection hypothesis
is scaled-index memory operands and persistent narrow loop state: C still does
two fold updates in15 instructions. More colors alone cannot erase that gap.

Evidence: [runtime06 summary](../../selfhost/build/phase190/development-summary06.json),
[machine audit](../../implementation/phase190/baseline-machine.md),
[portable receipts](../../implementation/phase190/evidence/REPRODUCE.md).
