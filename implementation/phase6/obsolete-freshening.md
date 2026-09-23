# Superseded freshening removal

The isolated P6-006 candidate removes 184 physical Bend lines, reducing
`front/freshen.bend` from 245 to 61 lines. Fourteen obsolete recursive helpers,
their laws and their exclusive `FFreshTerms` result type are removed. The active
explicit-stack implementation and its public entry points are unchanged.

A production-module and maintained-tool/test reference scan found no outside
caller, including string references used for dynamic export selection. The
independent review broadened that scan to historical performance tools and
confirmed the result. Documented `f_load_origins` APIs were found in maintained
tests and host fallbacks and deliberately retained; a production-only audit is
insufficient for deciding whether an API is dead.

The genuine checked/equality build passes all 21 maintained acceptance/phase
controls, retaining the same seven exact diagnostic differences. All 54 selected
bootstrap roots remain unchanged. More strongly, the complete selected checked
API is byte-identical to the release (SHA-256 `5969c53d34a0…`), as is its equality
derivative (`e2b5463678a2…`). Their runtime behavior therefore does not change.
No runtime speed gain is claimed. All-definition source roots shrink, so the
later combined compiler-library and fixed-point gates must use the new source.

Two setup failures before the source mutation/compiler launch are retained:
a wrong working directory and an invalid orchestration expression. Neither is
counted as a successful gate. No production/default edit has occurred at this
isolated checkpoint. Root will integrate the reviewed patch with the next named
batch and validate that combined compiler separately.

- [Plan](../../experiments/phase6/P6-006-obsolete-freshening.md)
- [Independent review](cleanup-independent-review.md)
- [Patch](obsolete-freshening-candidate.patch)
- [Evidence manifest](obsolete-freshening-evidence/manifest.json)
