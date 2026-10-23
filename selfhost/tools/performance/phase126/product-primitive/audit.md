# Flat observer result and late dependency closure

This is an isolated experiment, not a qualified compiler selection. No target,
compiler or API was executed by the author of this module; the root agent owns
those checks and measurements. `manifest01.json` freezes the first prototype.

## Decisive observed obstruction

Root's authenticated `selfhost/build/phase126/product-inspect01/report.json`
reports the same chain for record aggregation and evening:

* `$product.Map.bit.go` has result arity2 and rejects with `product result shape
  mismatch`, although its listed nonrecursive dependencies are already ready.
* Both public and product `Map.bit.at` candidates are otherwise error-free and
  wait for that precise product symbol.
* Public `Map.bit` waits for the public `at`; its own product candidate also has
  a result-shape mismatch.
* Existing observer preparation supplies a borrowed reader and the public
  result1 `$direct.Map.bit.go` adapter. It supplies no product adapter and does
  not repeat dependency closure afterward.

Replacing a missing product symbol with the public adapter would be wrong:
their result ABIs differ. Simply enabling more dependency passes cannot fix
the missing semantic representation. The new adapter establishes that exact
representation first.

The diagnostic independently confirms that Nat/U32 formatting `show.go` and
`show.fin` remain mutually dependent. This experiment does not admit cycles or
address that separate barrier. Nat.divmod remains the original boxed primitive;
there is no new arithmetic/runtime helper in this candidate.

## Mechanism and proof boundary

The existing request-bound `P118BPlan` still selects and rederives the observer,
including its original ownership, permission, wrapper-use and residual checks.
The old borrowed reader and public owning adapter are preserved exactly.

An additional private adapter is allowed only when the existing checked type
layout yields a known one-to-eight-field product result and **no flattened
input arguments**. Its certified residual must be precisely that constructor,
with the exact field count, and every field must already be a variable or word
literal. Nested constructors, computation, calls, opaque results and altered
input layouts decline. The adapter invokes the identical borrowed reader with
the original argument order, then returns the exact residual fields as the
existing `P113DResult` vector. The public owning/boxed adapter remains available
to all other callers.

The existing observer proof ensures that returned owning roots occur exactly
once and that the observation is used exactly once. Scalar literals require no
ownership transfer. Removing the outer constructor does not drop or duplicate
its fields; those fields become owned private results, just as for existing
product lowering. There is no ownership credit, destructive borrowed read,
changed recursion or new runtime representation.

The added functions are verified with the existing projection-aware borrowed
verifier. Only when a new product adapter exists does the prototype reprepare
the candidate catalogue and invoke the existing bounded32-pass direct closure.
It seeds the catalogue with actual verified signatures and preserves its
callee-before-caller order. Original unknown and cyclic dependencies still
decline; final verification checks exact argument and result counts, so an
incorrect product/public substitution cannot become legal merely by matching
a name. The complete merged catalogue is verified again, followed by the
unchanged private-array and transport namespace guards, before emission.

The original request, complete original generic/static program and original
verification gate are retained. The array certificate remains bound to that
same request. No generic verifier or additive runtime-import rule changes.

## Integration and cost limits

Overrides are only `p118b_functions` and `p118b_emit_verified`.
`p126bp_original_functions` is an exact renamed copy of the old implementation;
the manifest records the static equality check. Eleven pure controls cover
positive shape, constants, wrong input/result layouts, nested computation
refusal, complete function verification, and refusal of a wrong reader result
ABI. Refused fabricated records are analysis inputs only, never native targets.

This first experiment deliberately reuses candidate preparation rather than
adding a cache or changing compiler data structures. Requests with no added
flat observer adapter keep the old composition path. Requests with one pay
another candidate scan and full merged verification. Newly admitted functions
have not passed the earlier inliner/range pipeline; exact semantics are checked,
but runtime quality and compiler cost both need measurement. That overhead is
a reason to reject or redesign placement if the runtime improvement is small.

The first falsifier is ordinary complete output plus actual admission of the
product observer and at/bit chain on record aggregation, map churn and evening.
Then compare clean runtime and compilation cost. No full bootstrap campaign is
justified merely because more functions become direct. If the chain becomes
direct but boxed Nat.divmod is still materially hot, a QBE-local two-result
primitive interface is the next independent experiment; do not change the
shared C product predicate, whose dispatch assumes array primitives.
