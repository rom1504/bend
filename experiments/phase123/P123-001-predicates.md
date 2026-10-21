# P123-001: retain exact predicates through private scalar lowering

Status: planned. [Design](../../design/phase123/typed-private-computations.md).

Hypothesis: proven0/1 comparison results are normalized and re-tested after
inlining, preventing compact compare/select code and increasing register pressure.
General exact identities can remove this work without broad range analysis.

Falsify on frozen editdist and independent unsigned/unknown-value controls.
Measure activation, instructions/spills, runtime and whole compiler cost. Preserve
the verifier and rejected attempts. A smaller body without a runtime win is not
enough for retention. Phase120's earlier neutral Boolean attempt is a comparator.
