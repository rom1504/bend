# Independent architecture review of root-preserving observers

Reviewed `design/phase69/root-preserving-observers.md` against the existing
native layout, field-read, worker-admission, product and ownership APIs. This
review used source inspection only; it does not qualify an implementation.

The proposed separate, bounded read-only emitter is a reasonable first scope.
Its environment must contain only borrowed cursors and proved immediate
scalars, while an outer ordinary adapter keeps the owning inputs alive. Passing
borrowed values through ordinary `NC_Binding` lowering would be unsafe because
that path inserts keeps, drops and consuming destructures. A 350–600-line
complete feature is plausible with the stated small grammar and existing
worker envelope. It is a scope estimate, not a delivery guarantee; 150 lines
is more credible for an initial recognizer than the complete proof, emitter,
adapter and checked-boundary integration.

## Required invariants

1. Alpha-rename every bound ID of each helper invocation, including internal
   match and let binders. Two expansions of the same helper must not reuse an
   origin identity. Syntax-only substitution prevents accidental evaluation,
   but does not by itself establish this freshness invariant.
2. Constructor origin facts are branch-local and include the instantiated
   owner, constructor identity and exact field order. A fact learned in one
   match arm cannot simplify a reconstruction in another arm.
3. The public wrapper must use each retained owned root exactly once in the
   admitted first scope. A duplicate root projection needs a keep, and an
   omitted root needs a drop; neither follows from structural value equality.
4. The adapter's owning root slots must be separate from mutable observer
   cursor parameters. Tail updates may replace cursors with children while
   the original adapter roots still determine both lifetime and final output.
5. An ordinary helper is usable only when its actual admitted dependency
   closure is available and its checked result is immediate, or a product of
   proved immediates. Scalar arguments alone do not prove scalar output. Keep
   the helper's success/error test and ordered call even if its scalar result
   is dead. No borrowed cursor can cross that ordinary helper boundary.

The design owner incorporated these obligations after review.

## Existing helper traps

`nc_field_word` is not a universal borrowed field read. Its U32/F32 word-view
cases call `native_word`, which allocates a Word list. Its array cases use a
separate block representation. Generic one-field user constructors can also
be packed, so reading every constructor through `term_peek` is unsound.

The observer needs an explicit supported representation descriptor before
using these helpers. Start with genuine boxed recursive constructor roots and
immediate scalar fields. Exclude native scalar word-view patterns, arrays,
unsupported packed fields and exceptional native layouts. A source ADT having
one nullary constructor and one recursive constructor is not enough to prove
heap layout: Base Nat also has that source shape but an immediate runtime
representation. Backend representation distinctions are legitimate; selecting
the optimization by particular benchmark or Base function names is not.

Existing `NF_Worker` envelopes and `NC_Code` are useful, but worker admission
and generic segment adapters do not automatically prove an observer's result
mapping. Keep the observer's scalar-only private output distinct from the
ordinary boxed public output. Optional admission must leave an already valid
ordinary worker intact. Build against the final admitted scalar dependency
set, not optimistic product signatures whose callees can later be rejected.

## Bounds and checked permission

Use one monotonically decreasing analysis/expansion budget per candidate.
Resetting the full budget at every branch or helper call can still yield
exponential total work. Bound emitted candidates and residual size separately.
Compiler-generated plan/origin tags must not become trusted merely because
they appear in a caller-supplied KTerm or BookCache payload.

Checked typing alone does not establish absence of foreign pointer identity,
mutation or forged representations. Use the explicit checked permission and
the stronger reachable foreign/layout restriction described in the design.
Do not silently inherit permission from a scalar-array optimization whose
representation claim is weaker. Raw and device compilation retain their
original route, including their existing error policy.

## Most valuable prototype gate

Before writing the emitter, produce plans and refusal reasons for both
witnessed reconstruction patterns and unrelated renamed user list ADTs. Include
two calls to the same helper, crossed branch origins, reordered constructor
fields, a duplicated wrapper root, a dead failing scalar call, and a recursive
call whose result is unused. These distinguish a bounded semantic recognizer
from a syntax pattern that happens to match the diagnostic programs.

Rejecting a valid but unsupported case is acceptable. Accepting one of those
counterexamples is a stop condition. If the bounded analysis cannot recognize
the measured cases without substantial extra normalization, reconsider the
scope before growing a second general-purpose backend.
