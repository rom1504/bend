# Phase173: checked helper summaries for early owned decomposition

This is a bounded experimental analysis, not production admission and not a
compiler-correctness proof. Its implementation is
`selfhost/tests/phase173/owned-decomposition-summary.bend`. The main transformation
is owned separately by the shared-lowering investigation.

The important source evidence is the independently captured erased body in
`selfhost/build/phase173/erased-pattern-capture01/bodies.json`. `ks` and
`k_with_children` are complete **Mat chains**, rather than the initially expected
outer lambda followed by a match application. A getter arm contains exactly the
constructor-field lambdas and a field projection. A setter arm contains those
field lambdas, then a replacement lambda whose binder ID differs between arms,
then the rebuilt constructor. The KLiteral arm reconstructs all original fields
and does not use the replacement. The automatic transformation must still
evaluate the replacement computation on that variant, or preserve the complete
original fallback computation.

The semantic summary retains exact constructor identity, field count, scalar
mask, getter/setter field binder IDs and result terms. It does not select helpers
by their source names. `p173od_pair(book, getterName, setterName)` reads the actual
cached erased definitions and returns a summary only when all of these checks
hold:

* Both are ordinary definitions with no templates, native marker or foreign body.
* Both match the same ordered constructor chain, ending in the existing Efq
  fallback, with no duplicated constructor tests.
* Each selected constructor is an actual catalogue entry with the exact encoded
  identity and live field count. Its owner is an ordinary, zero-parameter Data
  ADT; erased fields, arrays, primitives and unknown layouts are declined.
* Each field arm contains exactly the declared number of quantity-2 lambdas with
  distinct binder IDs. Parameter and replacement collisions are declined.
* Getter values are a field variable or a closed constructor/NWord tree, with
  no calls, references, effects or free variables. Constants have a 32-node
  budget.
* Setter values reconstruct the same constructor with positional field origins
  unchanged except at most one occurrence of the replacement. Swaps, missing
  fields, unknown expressions and duplicated replacement values are declined.

The direct-Mat path uses zero only as an absent-root-binder sentinel and refuses
actual field/replacement binder zero. Per-arm replacement binders normalize to
the first arm's ID after validating the original positional origins; that ID
must be disjoint from every getter/setter field. This preserves the existing
summary interface without assuming that branch-local binders are globally the
same variable. An explicit lambda/match form is a secondary conservative path.

Bounds are eight constructor variants, sixteen fields and thirty-two nodes per
closed constant. No general normalization, field-layout search or new backend
representation is added. The analysis returns the unchanged failure result for
unsupported shapes. Constructor masks and quantity annotations remain part of
admission; the generated branch must not silently change a quantity-1 field
into a duplicated field.

The match chain check is not a claim that an arbitrary unsafe helper is total:
the transformation retains its original fallback for unselected variants.
Likewise, `law` declarations in this module are forward function contracts;
they are not mathematical equivalence theorems or independent BendTT proofs.

The first test is actual admission on the captured helpers plus ordinary
unrelated getters/setters, followed by independently checked complete results
and explicit strict-evaluation/refusal controls. Only then should machine-code
inspection ask whether one early decomposition removes the root's repeated
sharing/reconstruction work. Source checking, finite execution, dynamic speed
and whole-compiler benefit remain separate gates.

Cost caveat: summary construction should be reused per selected helper pair or
guarded by cheap candidate rejection before full-compiler experiments. Repeating
helper preparation for every application would merely move work into a new
compiler pass. No target was run by this summary implementation agent.
