# P123-001: retain exact predicates through private scalar lowering

Status: implemented; focused controls/runtime pass, original45 qualification complete. [Design](../../design/phase123/typed-private-computations.md).

Hypothesis: proven0/1 comparison results are normalized and re-tested after
inlining, preventing compact compare/select code and increasing register pressure.
General exact identities can remove this work without broad range analysis.

Falsify on frozen editdist and independent unsigned/unknown-value controls.
Measure activation, instructions/spills, runtime and whole compiler cost. Preserve
the verifier and rejected attempts. A smaller body without a runtime win is not
enough for retention. Phase120's earlier neutral Boolean attempt is a comparator.

The versioned-origin model02 keeps exact model01 QBE on the two fast cases.
Editdist short screen428→278ms; recurrence neutral. Four transfer cases also
neutral.600 independent bitvector pairs and the full original/after verifier pass.
Two-case hosted compiler cost+0.53%; no native image throughput claim.

Final combination and assembler policy:405 original45 observations pass,
2.15074→2.00584×upstream; positive log-slowdown1.01575→0.94810. Three-case
hosted request cost0.97485×parent;95 source lines added. Qualified native images
and installed selections unchanged. See implementation/phase123/README.md.
