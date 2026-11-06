# Independent review of lazy scalar eligibility

Source-only review: no blocking semantic or ownership mismatch found for the
finite immutable compiler plans admitted by the existing pipeline. This review
does not claim execution, a new proof, or a measured speedup.

The original predicate in
[`borrowed-regions.bend`](../../selfhost/src/back/qbe/borrowed-regions.bend)
conjoins pure observations of the same book and plan. The candidate in
[`lazy-eligibility.bend`](../../selfhost/tests/phase169/lazy-eligibility.bend)
retains every True condition, but reaches parameter construction, layout
construction and `no_emit` only after the cheaper conditions pass. Root count
is computed once and tested before scalar classification. Neither operation
mutates the book, plan, registry or runtime state. The predicate returns a Bool;
there is no original externally reported diagnostic whose precedence changes.

`no_emit` constructs and checks an `NC_Code` value; it does not execute the
generated text or perform IO. All predicates terminate over the ordinary finite
input structures here. Consequently skipping a rejected branch preserves this
predicate's result. This argument does not cover forged cyclic host values or
equivalence of allocation failure and divergence on arbitrary unsafe inputs.

The change grants no new worker authority. `p128bs_find` still sees the actual
post-inlining functions and checks the public signature, result, leaf body and
arity. Worker construction, owning fallback, root releases and independent final
verification are unchanged. The closures capture the same immutable inputs;
the candidate uses explicit shared annotations for values required along more
than one path. Source admission remains an execution gate owned by the parent.

The sixteen literal controls preserve an exact renamed original predicate and
compare both answers with fixed expectations. They cover one/two/duplicate
roots, existing plan error, bad wrapper/result/observation, zero/three roots,
unknown and non-native scalar, both generated-name collisions, unbound and
unsupported emission, and a plan error with invalid emission. In particular,
duplicate roots retain the original count-only behavior. These are finite
controls, not a proof over all plans; complete real output comparison remains
necessary. See the [author's preparation and test plan](lazy-eligibility.md).

Reviewed identities:

| Input | SHA256 |
|---|---|
| Candidate module, 1,668 bytes | `e5eacc671b8207c614e30d3ac9ca2f3e262d4c962f2c50cdae810a8d74388eab` |
| Controls, 3,575 bytes | `adbf0164eb96f260865835ac6964b636e66b195ba870b51245fd83d575addd72` |
| Maintained original module, 60,920 bytes | `bc94f8cd6ce2dc8927e05e12a64e846bb69c4a39b93df6353eeae19ca24e12b7` |
| Prepared API source, 1,618,381 bytes | `749b758ba18e8bac222c691890d2323f0744ea99138cf16b8bd4666b049f9c4c` |
